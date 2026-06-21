import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/receipt_repository.dart';
import '../../data/services/ica_receipt_parser.dart';
import '../../data/services/receipt_import_service.dart';
import '../../data/services/receipt_share_service.dart';

class ReceiptShareHandler extends ConsumerStatefulWidget {
  const ReceiptShareHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<ReceiptShareHandler> createState() => _ReceiptShareHandlerState();
}

class _ReceiptShareHandlerState extends ConsumerState<ReceiptShareHandler> {
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(receiptShareServiceProvider).initialize();
    });
  }

  Future<void> _handlePendingShare(PendingReceiptShare pending) async {
    if (_handling) return;
    _handling = true;

    try {
      final lists = await ref.read(receiptListsProvider.future);
      if (!mounted) return;

      int? listId;
      if (lists.isEmpty) {
        listId = await ref.read(receiptRepositoryProvider).createList('Receipts');
      } else if (lists.length == 1) {
        listId = lists.first.id;
      } else {
        listId = await _pickList(lists);
      }

      if (listId == null || !mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      try {
        final receiptId = await ref.read(receiptShareServiceProvider).importToList(
              listId: listId,
              sourcePath: pending.filePath,
            );
        if (!mounted || receiptId == null) return;
        messenger.showSnackBar(
          const SnackBar(content: Text('Shared receipt imported')),
        );
        context.push('/receipts/$listId/receipt/$receiptId');
      } on DuplicateReceiptException catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Receipt already imported (#${e.existingReceiptId})')),
        );
        context.push('/receipts/$listId');
      } on IcaReceiptParseException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
      } on ReceiptImportException catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(e.message)));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
      }
    } finally {
      ref.read(pendingReceiptShareProvider.notifier).state = null;
      _handling = false;
    }
  }

  Future<int?> _pickList(List<ReceiptList> lists) async {
    return showModalBottomSheet<int>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text('Import shared receipt to'),
            ),
            for (final list in lists)
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: Text(list.name),
                onTap: () => Navigator.pop(context, list.id),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Create new receipts list'),
              onTap: () async {
                final navigator = Navigator.of(context);
                final name = await showDialog<String>(
                  context: context,
                  builder: (dialogContext) {
                    final controller = TextEditingController(text: 'Receipts');
                    return AlertDialog(
                      title: const Text('New receipts list'),
                      content: TextField(
                        controller: controller,
                        autofocus: true,
                        decoration: const InputDecoration(hintText: 'List name'),
                        onSubmitted: (value) => Navigator.pop(dialogContext, value),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, controller.text),
                          child: const Text('Create'),
                        ),
                      ],
                    );
                  },
                );
                if (name == null || name.trim().isEmpty) return;
                final id = await ref.read(receiptRepositoryProvider).createList(name);
                if (navigator.mounted) {
                  navigator.pop(id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<PendingReceiptShare?>(pendingReceiptShareProvider, (previous, next) {
      if (next != null) {
        _handlePendingShare(next);
      }
    });

    return widget.child;
  }
}
