import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/sync/sync_billing_service.dart';

class PremiumBillingSection extends ConsumerStatefulWidget {
  const PremiumBillingSection({
    super.key,
    required this.entitlement,
    required this.isSignedIn,
  });

  final BillingEntitlement entitlement;
  final bool isSignedIn;

  @override
  ConsumerState<PremiumBillingSection> createState() =>
      _PremiumBillingSectionState();
}

class _PremiumBillingSectionState extends ConsumerState<PremiumBillingSection> {
  List<ProductDetails> _products = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _listenPurchases();
  }

  Future<void> _loadProducts() async {
    final sync = ref.read(syncServiceProvider);
    final billing = sync?.billing;
    if (billing == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final available = await billing.isStoreAvailable();
      if (!available) {
        setState(() => _loading = false);
        return;
      }
      final products = await billing.loadProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _listenPurchases() {
    final sync = ref.read(syncServiceProvider);
    final uid = sync?.auth.currentUid;
    final billing = sync?.billing;
    if (uid == null || billing == null) return;
    billing.startPurchaseListener(
          uid: uid,
          onVerified: (_) {
            ref.read(premiumEntitlementProvider.notifier).refresh();
            sync?.startIfEligible(isPremium: true);
          },
          onError: (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Purchase error: $e')),
              );
            }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isSignedIn) {
      return const ListTile(
        leading: Icon(Icons.workspace_premium_outlined),
        title: Text('Premium'),
        subtitle: Text('Sign in to subscribe and enable cloud sync'),
      );
    }

    if (widget.entitlement.isPremium) {
      final expiry = widget.entitlement.expiresAt;
      return Card(
        child: ListTile(
          leading: const Icon(Icons.verified_outlined),
          title: const Text('Premium active'),
          subtitle: Text(
            expiry != null
                ? 'Renews or expires ${expiry.toLocal()}'
                : 'Cloud sync enabled',
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Premium',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sync lists across devices, automatic backup, and household sharing.',
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_products.isEmpty)
              const Text('Billing unavailable on this device.')
            else
              FilledButton(
                onPressed: () {
                  final sync = ref.read(syncServiceProvider);
                  if (sync != null && _products.isNotEmpty) {
                    sync.billing.buy(_products.first);
                  }
                },
                child: Text('Subscribe — ${_products.first.price}'),
              ),
            TextButton(
              onPressed: () =>
                  ref.read(syncServiceProvider)?.billing.restorePurchases(),
              child: const Text('Restore purchases'),
            ),
          ],
        ),
      ),
    );
  }
}
