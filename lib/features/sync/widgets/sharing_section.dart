import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

class SharingSection extends ConsumerStatefulWidget {
  const SharingSection({super.key, required this.enabled});

  final bool enabled;

  @override
  ConsumerState<SharingSection> createState() => _SharingSectionState();
}

class _SharingSectionState extends ConsumerState<SharingSection> {
  final _inviteController = TextEditingController();
  String? _lastInviteCode;

  @override
  void dispose() {
    _inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Household sharing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Invite others to edit the same synced lists. All members can edit; '
              'last write wins.',
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _createInvite,
              icon: const Icon(Icons.link),
              label: const Text('Create invite code'),
            ),
            if (_lastInviteCode != null) ...[
              const SizedBox(height: 8),
              SelectableText('Invite code: $_lastInviteCode'),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _inviteController,
              decoration: const InputDecoration(
                labelText: 'Join with invite code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _joinInvite,
              child: const Text('Join household'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createInvite() async {
    try {
      final sync = ref.read(syncServiceProvider);
      if (sync == null) return;
      final code = await sync.createInvite();
      setState(() => _lastInviteCode = code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite code created')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create invite: $e')),
        );
      }
    }
  }

  Future<void> _joinInvite() async {
    final code = _inviteController.text.trim();
    if (code.isEmpty) return;
    try {
      final sync = ref.read(syncServiceProvider);
      if (sync == null) return;
      await sync.joinWithInvite(code);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined sync space')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $e')),
        );
      }
    }
  }
}
