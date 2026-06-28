import 'dart:io' show Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'firebase_initializer.dart';

/// Wraps Firebase Authentication with federated providers.
class SyncAuthService {
  SyncAuthService({FirebaseAuth? auth}) : _authOverride = auth;

  final FirebaseAuth? _authOverride;
  FirebaseAuth? _auth;

  FirebaseAuth get _firebaseAuth => _authOverride ?? (_auth ??= FirebaseAuth.instance);
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges {
    if (!FirebaseInitializer.isInitialized && _authOverride == null) {
      return Stream<User?>.value(null);
    }
    return _firebaseAuth.authStateChanges();
  }

  User? get currentUser => _authOverride != null || _auth != null
      ? _firebaseAuth.currentUser
      : null;

  String? get currentUid => currentUser?.uid;

  bool get isSignedIn => currentUid != null;

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return _firebaseAuth.signInWithPopup(provider);
    }
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw StateError('Google sign-in cancelled');
    }
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: auth.accessToken,
      idToken: auth.idToken,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success || result.accessToken == null) {
      throw StateError('Facebook sign-in failed');
    }
    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );
    return _firebaseAuth.signInWithCredential(credential);
  }

  Future<UserCredential> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw UnsupportedError('Apple Sign-In is only available on Apple platforms');
    }
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauth = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    return _firebaseAuth.signInWithCredential(oauth);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await _firebaseAuth.signOut();
  }
}
