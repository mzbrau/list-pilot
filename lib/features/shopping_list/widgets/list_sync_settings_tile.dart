import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class ListSyncSettingsTile extends ConsumerWidget {
  const ListSyncSettingsTile({
    super.key,
    required this.list,
  });

  final ShoppingList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premium = ref.watch(premiumEntitlementProvider).valueOrNull;
    final signedIn = ref.watch(syncAuthStateProvider).valueOrNull != null;
    final sync = ref.watch(syncServiceProvider);
    final canSync = premium?.isPremium == true && signedIn && sync != null;

    return SwitchListTile(
      secondary: Icon(
        list.syncEnabled ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
      ),
      title: const Text('Cloud sync'),
      subtitle: Text(
        canSync
            ? (list.syncEnabled
                ? 'This list syncs across your devices'
                : 'Keep this list on this device only')
            : 'Premium and sign-in required',
      ),
      value: list.syncEnabled,
      onChanged: canSync
          ? (enabled) async {
              try {
                await sync!.setListSyncEnabled(
                  listId: list.id,
                  enabled: enabled,
                );
                if (enabled && list.globalId != null) {
                  await sync.engine.enableListRealtime(list.globalId!);
                } else {
                  await sync.engine.disableListRealtime();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sync update failed: $e')),
                  );
                }
              }
            }
          : null,
    );
  }
}
