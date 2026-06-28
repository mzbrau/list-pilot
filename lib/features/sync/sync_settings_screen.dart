import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/sync/firebase_initializer.dart';
import 'widgets/premium_billing_section.dart';
import 'widgets/sharing_section.dart';
import 'widgets/sync_auth_buttons.dart';

class SyncSettingsScreen extends ConsumerStatefulWidget {
  const SyncSettingsScreen({super.key});

  @override
  ConsumerState<SyncSettingsScreen> createState() => _SyncSettingsScreenState();
}

class _SyncSettingsScreenState extends ConsumerState<SyncSettingsScreen> {
  bool _initializing = false;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _lazyInitFirebase();
  }

  Future<void> _lazyInitFirebase() async {
    setState(() {
      _initializing = true;
      _initError = null;
    });
    try {
      await FirebaseInitializer.ensureInitialized();
    } catch (e) {
      setState(() => _initError = e.toString());
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(syncAuthStateProvider);
    final premium = ref.watch(premiumEntitlementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Sync & Premium')),
      body: _initializing
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_initError != null)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Firebase is not configured yet. Run flutterfire configure '
                        'to enable cloud sync.\n\n$_initError',
                      ),
                    ),
                  ),
                const Text(
                  'Cloud sync is optional. Your lists always work offline locally.',
                  style: TextStyle(height: 1.4),
                ),
                const SizedBox(height: 16),
                auth.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Auth error: $e'),
                  data: (user) {
                    if (user == null) {
                      return const SyncAuthButtons();
                    }
                    return ListTile(
                      leading: const Icon(Icons.account_circle_outlined),
                      title: Text(user.email ?? user.uid),
                      subtitle: const Text('Signed in'),
                      trailing: TextButton(
                        onPressed: () =>
                            ref.read(syncServiceProvider)?.auth.signOut(),
                        child: const Text('Sign out'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                premium.when(
                  loading: () => const SizedBox.shrink(),
                  error: (e, _) => Text('Billing error: $e'),
                  data: (entitlement) => PremiumBillingSection(
                    entitlement: entitlement,
                    isSignedIn: auth.valueOrNull != null,
                  ),
                ),
                const SizedBox(height: 24),
                SharingSection(
                  enabled: premium.valueOrNull?.isPremium == true &&
                      auth.valueOrNull != null,
                ),
                const SizedBox(height: 16),
                Text(
                  'Enable sync per shopping list from the list menu. '
                  'Synced lists show a cloud icon on the overview.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
    );
  }
}
