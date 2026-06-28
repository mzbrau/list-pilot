import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/sync/firebase_initializer.dart';

class SyncAuthButtons extends ConsumerWidget {
  const SyncAuthButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(syncServiceProvider);
    if (sync == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () => _signIn(context, ref, sync.auth.signInWithGoogle),
          icon: const Icon(Icons.login),
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => _signIn(context, ref, sync.auth.signInWithFacebook),
          icon: const Icon(Icons.facebook_outlined),
          label: const Text('Continue with Facebook'),
        ),
        if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _signIn(context, ref, sync.auth.signInWithApple),
            icon: const Icon(Icons.apple),
            label: const Text('Continue with Apple'),
          ),
        ],
      ],
    );
  }

  Future<void> _signIn(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() action,
  ) async {
    try {
      await FirebaseInitializer.ensureInitialized();
      await action();
      final sync = ref.read(syncServiceProvider);
      final uid = sync?.auth.currentUid;
      if (uid != null) {
        ref.read(premiumEntitlementProvider.notifier).watchUid(uid);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $e')),
        );
      }
    }
  }
}
