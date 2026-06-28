import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/io/import_folder_resolver.dart';
import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/receipt_repository.dart';
import '../../data/services/ica_receipt_parser.dart';
import '../../data/services/receipt_import_service.dart';
import '../../router/navigation_helpers.dart';
import 'receipt_formatters.dart';

class ReceiptsListScreen extends ConsumerStatefulWidget {
  const ReceiptsListScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<ReceiptsListScreen> createState() => _ReceiptsListScreenState();
}

class _ReceiptsListScreenState extends ConsumerState<ReceiptsListScreen> {
  bool _importing = false;
  int _progressCurrent = 0;
  int _progressTotal = 0;
  String? _currentFileName;
  ReceiptImportResult? _batchResult;

  Future<void> _renameList(BuildContext context, ReceiptList list) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: list.name);
        return AlertDialog(
          title: const Text('Rename list'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'List name'),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (name != null && name.trim().isNotEmpty) {
      await ref.read(receiptRepositoryProvider).renameList(list.id, name);
    }
  }

  Future<void> _showImportOptions() async {
    if (_importing) return;

    final action = await showModalBottomSheet<_ImportAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: const Text('Add receipt'),
              onTap: () => Navigator.pop(context, _ImportAction.single),
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.folder_open_outlined),
                title: const Text('Import folder'),
                onTap: () => Navigator.pop(context, _ImportAction.folder),
              ),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;
    switch (action) {
      case _ImportAction.single:
        await _importPdf();
      case _ImportAction.folder:
        await _importFolder();
    }
  }

  Future<void> _importPdf() async {
    if (_importing) return;
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;

    setState(() {
      _importing = true;
      _batchResult = null;
    });
    try {
      final receiptId = await ref.read(receiptImportServiceProvider).importPdf(
            listId: widget.listId,
            sourcePdfPath: path,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt imported')),
      );
      context.push('/receipts/${widget.listId}/receipt/$receiptId');
    } on DuplicateReceiptException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Receipt already imported (#${e.existingReceiptId})')),
      );
    } on IcaReceiptParseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } on ReceiptImportException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _importFolder() async {
    if (_importing) return;

    setState(() {
      _importing = true;
      _batchResult = null;
      _progressCurrent = 0;
      _progressTotal = 0;
      _currentFileName = null;
    });

    ImportFolderHandle? handle;
    try {
      handle = await pickImportFolder(
        dialogTitle: 'Choose receipts folder',
      );
      if (!mounted || handle == null) return;

      final fileCount = await countImportableFiles(
        handle,
        extensions: const {'.pdf'},
        skipFileNames: const {},
      );
      if (!mounted) return;

      if (fileCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No PDF files found in the selected folder.'),
          ),
        );
        return;
      }

      final result = await ref.read(receiptImportServiceProvider).importFolder(
            handle.path,
            listId: widget.listId,
            onProgress: (current, total, fileName) {
              if (!mounted) return;
              setState(() {
                _progressCurrent = current;
                _progressTotal = total;
                _currentFileName = fileName;
              });
            },
          );
      if (!mounted) return;

      setState(() => _batchResult = result);

      if (result.imported == 1 && result.failed == 0 && result.skipped == 0) {
        context.push(
          '/receipts/${widget.listId}/receipt/${result.importedReceiptIds.first}',
        );
      }
    } on ReceiptImportException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      await handle?.dispose();
      if (mounted) {
        setState(() {
          _importing = false;
          _currentFileName = null;
        });
      }
    }
  }

  Future<void> _confirmDeleteReceipt(Receipt receipt) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete receipt?'),
        content: Text(
          'Remove the ${DateFormat.yMMMd().format(receipt.purchasedAt)} receipt from ${receipt.shopName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(receiptRepositoryProvider).deleteReceipt(receipt.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(receiptListProvider(widget.listId));
    final receiptsAsync = ref.watch(receiptsForListProvider(widget.listId));
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: overviewBackButton(context),
          title: listAsync.when(
            data: (list) => Text(list?.name ?? 'Receipts'),
            loading: () => const Text('Receipts'),
            error: (_, __) => const Text('Receipts'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.insights_outlined),
              tooltip: 'Insights',
              onPressed: () => context.push('/receipts/${widget.listId}/insights'),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Rename',
              onPressed: () {
                final list = listAsync.valueOrNull;
                if (list != null) {
                  _renameList(context, list);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_importing) ...[
              if (_progressTotal > 0)
                LinearProgressIndicator(value: _progressCurrent / _progressTotal)
              else
                const LinearProgressIndicator(),
              if (_progressTotal > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '$_progressCurrent of $_progressTotal'
                    '${_currentFileName != null ? ' — $_currentFileName' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    ref.read(receiptImportServiceProvider).aiConfigured
                        ? 'Translating items with AI…'
                        : 'Importing receipt…',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
            ],
            if (_batchResult != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _ImportSummaryCard(result: _batchResult!),
              ),
            Expanded(
              child: receiptsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (receipts) {
                  if (receipts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: theme.colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No receipts yet',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Import a PDF receipt or share one from Kivra to List Pilot.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: receipts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final receipt = receipts[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.6),
                            child: Icon(
                              Icons.receipt_outlined,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          title: Text(receipt.shopName),
                          subtitle: Text(dateFormat.format(receipt.purchasedAt)),
                          trailing: Text(
                            formatReceiptAmount(receipt.totalAmount),
                            style: theme.textTheme.titleMedium,
                          ),
                          onTap: () => context.push(
                            '/receipts/${widget.listId}/receipt/${receipt.id}',
                          ),
                          onLongPress: () => _confirmDeleteReceipt(receipt),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: _importing
            ? const FloatingActionButton(
                onPressed: null,
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : FloatingActionButton.extended(
                onPressed: _showImportOptions,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Add receipt'),
              ),
      ),
    );
  }
}

enum _ImportAction { single, folder }

class _ImportSummaryCard extends StatelessWidget {
  const _ImportSummaryCard({required this.result});

  final ReceiptImportResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Import complete', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Text('Imported: ${result.imported}'),
            if (result.skipped > 0) Text('Skipped (duplicates): ${result.skipped}'),
            if (result.failed > 0) Text('Failed: ${result.failed}'),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Errors'),
                tilePadding: EdgeInsets.zero,
                children: [
                  for (final error in result.errors)
                    ListTile(
                      dense: true,
                      title: Text(error.fileName),
                      subtitle: Text(error.message),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
