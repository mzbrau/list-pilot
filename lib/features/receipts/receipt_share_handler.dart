import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/receipt_repository.dart';
import '../../data/services/ica_receipt_parser.dart';
import '../../data/services/receipt_import_service.dart';
import '../../data/services/receipt_share_service.dart';
import '../../router/app_router.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(receiptShareServiceProvider).initialize();
    });
  }

  BuildContext? get _overlayContext => rootNavigatorKey.currentContext;

  Future<BuildContext?> _waitForOverlayContext({int maxAttempts = 20}) async {
    for (var i = 0; i < maxAttempts; i++) {
      final context = rootNavigatorKey.currentContext;
      if (context != null) return context;
      await Future<void>.delayed(Duration.zero);
      if (!mounted) return null;
    }
    return rootNavigatorKey.currentContext;
  }

  void _showSnackBar(SnackBar snackBar) {
    final overlayContext = _overlayContext;
    if (overlayContext != null) {
      ScaffoldMessenger.of(overlayContext).showSnackBar(snackBar);
    }
  }

  String _singleImportMessage(bool aiConfigured) {
    return aiConfigured
        ? 'Importing shared receipt — translating items with AI…'
        : 'Importing shared receipt…';
  }

  String _batchImportMessage(
    bool aiConfigured,
    int current,
    int total,
    String? fileName,
  ) {
    final base = aiConfigured
        ? 'Importing shared receipts — translating items with AI…'
        : 'Importing shared receipts…';
    if (total <= 0) return base;
    final progress = '$current of $total';
    if (fileName != null) {
      return '$base\n$progress — $fileName';
    }
    return '$base\n$progress';
  }

  Future<T> _runWithProgressDialog<T>({
    required BuildContext overlayContext,
    required String initialMessage,
    required Future<T> Function(ValueNotifier<String> message) action,
  }) async {
    final message = ValueNotifier(initialMessage);
    final navigator = Navigator.of(overlayContext, rootNavigator: true);

    unawaited(
      showDialog<void>(
        context: overlayContext,
        barrierDismissible: false,
        builder: (dialogContext) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: ValueListenableBuilder<String>(
              valueListenable: message,
              builder: (context, text, _) => Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 24),
                  Expanded(child: Text(text)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await Future<void>.delayed(Duration.zero);

    try {
      return await action(message);
    } finally {
      message.dispose();
      if (navigator.mounted && navigator.canPop()) {
        navigator.pop();
      }
    }
  }

  int? _currentReceiptListId() {
    final location = ref
        .read(routerProvider)
        .routerDelegate
        .currentConfiguration
        .uri
        .toString();
    final match = RegExp(r'/receipts/(\d+)').firstMatch(location);
    return match != null ? int.tryParse(match.group(1)!) : null;
  }

  Future<void> _handlePendingShare(PendingReceiptShare pending) async {
    if (_handling) return;
    _handling = true;
    var importAttempted = false;

    try {
      final lists = await ref.read(receiptListsProvider.future);
      if (!mounted) return;

      int? listId;
      var pickerUnavailable = false;
      var userCancelledPicker = false;

      if (lists.isEmpty) {
        listId = await ref.read(receiptRepositoryProvider).createList('Receipts');
      } else if (lists.length == 1) {
        listId = lists.first.id;
      } else {
        final currentListId = _currentReceiptListId();
        if (currentListId != null && lists.any((list) => list.id == currentListId)) {
          listId = currentListId;
        } else {
          final overlayContext = await _waitForOverlayContext();
          if (overlayContext == null) {
            pickerUnavailable = true;
          } else if (!overlayContext.mounted) {
            pickerUnavailable = true;
          } else {
            listId = await _pickList(lists, overlayContext);
            if (listId == null) {
              userCancelledPicker = true;
            }
          }
        }
      }

      if (pickerUnavailable) {
        _showSnackBar(
          const SnackBar(
            content: Text('Could not import shared receipt — please try again'),
          ),
        );
        return;
      }

      if (userCancelledPicker) {
        _showSnackBar(const SnackBar(content: Text('Import cancelled')));
        return;
      }

      if (listId == null || !mounted) return;

      final overlayContext = await _waitForOverlayContext();
      if (overlayContext == null || !overlayContext.mounted) {
        _showSnackBar(
          const SnackBar(
            content: Text('Could not import shared receipt — please try again'),
          ),
        );
        return;
      }

      importAttempted = true;
      if (pending.filePaths.length == 1) {
        await _importSingle(listId, pending.filePaths.first, overlayContext);
      } else {
        await _importBatch(listId, pending.filePaths, overlayContext);
      }
    } finally {
      if (importAttempted) {
        await ref.read(receiptShareServiceProvider).resetIntent();
        ref.read(pendingReceiptShareProvider.notifier).state = null;
      }
      _handling = false;
    }
  }

  Future<void> _importSingle(
    int listId,
    String path,
    BuildContext overlayContext,
  ) async {
    final aiConfigured = ref.read(receiptImportServiceProvider).aiConfigured;

    await _runWithProgressDialog<void>(
      overlayContext: overlayContext,
      initialMessage: _singleImportMessage(aiConfigured),
      action: (_) async {
        try {
          final receiptId =
              await ref.read(receiptShareServiceProvider).importToList(
                    listId: listId,
                    sourcePath: path,
                  );
          if (!mounted) return;
          _showSnackBar(
            const SnackBar(content: Text('Shared receipt imported')),
          );
          ref.read(routerProvider).push('/receipts/$listId/receipt/$receiptId');
        } on DuplicateReceiptException catch (e) {
          _showSnackBar(
            SnackBar(
              content: Text('Receipt already imported (#${e.existingReceiptId})'),
            ),
          );
          ref.read(routerProvider).push('/receipts/$listId');
        } on IcaReceiptParseException catch (e) {
          _showSnackBar(SnackBar(content: Text(e.message)));
        } on ReceiptImportException catch (e) {
          _showSnackBar(SnackBar(content: Text(e.message)));
        } catch (e) {
          _showSnackBar(SnackBar(content: Text('Import failed: $e')));
        }
      },
    );
  }

  Future<void> _importBatch(
    int listId,
    List<String> paths,
    BuildContext overlayContext,
  ) async {
    final aiConfigured = ref.read(receiptImportServiceProvider).aiConfigured;

    await _runWithProgressDialog<void>(
      overlayContext: overlayContext,
      initialMessage: _batchImportMessage(aiConfigured, 0, paths.length, null),
      action: (message) async {
        try {
          final result = await ref.read(receiptImportServiceProvider).importPdfs(
                paths,
                listId: listId,
                onProgress: (current, total, fileName) {
                  message.value = _batchImportMessage(
                    aiConfigured,
                    current,
                    total,
                    fileName,
                  );
                },
              );
          if (!mounted) return;

          final parts = <String>[
            '${result.imported} imported',
            if (result.skipped > 0) '${result.skipped} skipped',
            if (result.failed > 0) '${result.failed} failed',
          ];
          _showSnackBar(
            SnackBar(content: Text('Shared receipts: ${parts.join(', ')}')),
          );
          ref.read(routerProvider).push('/receipts/$listId');
        } catch (e) {
          _showSnackBar(SnackBar(content: Text('Import failed: $e')));
        }
      },
    );
  }

  Future<int?> _pickList(List<ReceiptList> lists, BuildContext overlayContext) {
    return showModalBottomSheet<int>(
      context: overlayContext,
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
