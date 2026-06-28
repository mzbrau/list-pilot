import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class BillingEntitlement {
  const BillingEntitlement({
    required this.isPremium,
    this.expiresAt,
    this.platform,
    this.productId,
    this.promotionalPlanId,
  });

  final bool isPremium;
  final DateTime? expiresAt;
  final String? platform;
  final String? productId;
  final String? promotionalPlanId;

  factory BillingEntitlement.free() => const BillingEntitlement(isPremium: false);

  factory BillingEntitlement.fromFirestore(Map<String, dynamic>? data) {
    if (data == null) return BillingEntitlement.free();
    final expiresAt = data['expiresAt'];
    DateTime? expiry;
    if (expiresAt is Timestamp) {
      expiry = expiresAt.toDate().toUtc();
    }
    final isPremium = data['isPremium'] == true &&
        (expiry == null || expiry.isAfter(DateTime.now().toUtc()));
    return BillingEntitlement(
      isPremium: isPremium,
      expiresAt: expiry,
      platform: data['platform'] as String?,
      productId: data['productId'] as String?,
      promotionalPlanId: data['promotionalPlanId'] as String?,
    );
  }
}

/// Google Play Billing with server-side verification via Cloud Function.
class SyncBillingService {
  SyncBillingService({
    required FirebaseFirestore firestore,
    FirebaseFunctions? functions,
    InAppPurchase? iap,
  })  : _firestore = firestore,
        _functions = functions ?? FirebaseFunctions.instance,
        _iap = iap ?? InAppPurchase.instance;

  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final InAppPurchase _iap;

  static const premiumProductId = 'list_pilot_premium_yearly';

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;

  Future<bool> isStoreAvailable() => _iap.isAvailable();

  Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails({premiumProductId});
    return response.productDetails;
  }

  Stream<BillingEntitlement> watchEntitlement(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('billing')
        .snapshots()
        .map((snap) => BillingEntitlement.fromFirestore(snap.data()));
  }

  Future<BillingEntitlement> getEntitlement(String uid) async {
    final doc = await _firestore
        .collection('users')
        .doc(uid)
        .collection('private')
        .doc('billing')
        .get();
    return BillingEntitlement.fromFirestore(doc.data());
  }

  void startPurchaseListener({
    required String uid,
    required void Function(PurchaseDetails purchase) onVerified,
    void Function(Object error)? onError,
  }) {
    _purchaseSub?.cancel();
    _purchaseSub = _iap.purchaseStream.listen(
      (purchases) async {
        for (final purchase in purchases) {
          try {
            if (purchase.productID != premiumProductId) continue;
            if (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored) {
              await verifyPlayPurchase(
                uid: uid,
                purchaseToken: purchase.verificationData.serverVerificationData,
                productId: purchase.productID,
              );
              onVerified(purchase);
            }
            if (purchase.pendingCompletePurchase) {
              await _iap.completePurchase(purchase);
            }
          } catch (e) {
            onError?.call(e);
          }
        }
      },
      onError: onError,
    );
  }

  Future<void> dispose() async {
    await _purchaseSub?.cancel();
    _purchaseSub = null;
  }

  Future<void> buy(ProductDetails product) {
    final param = PurchaseParam(productDetails: product);
    return _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() => _iap.restorePurchases();

  Future<void> verifyPlayPurchase({
    required String uid,
    required String purchaseToken,
    required String productId,
    String? offerId,
  }) async {
    final callable = _functions.httpsCallable('verifyPlayPurchase');
    await callable.call<Map<String, dynamic>>({
      'uid': uid,
      'purchaseToken': purchaseToken,
      'productId': productId,
      if (offerId != null) 'offerId': offerId,
      'platform': 'play',
    });
  }
}
