import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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

    setState(() => _importing = true);
    try {
      final receiptId = await ref.read(receiptImportServiceProvider).importPdf(
            listId: widget.listId,
            sourcePdfPath: path,
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(
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
        body: receiptsAsync.when(
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
                      backgroundColor:
                          theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
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
                onPressed: _importPdf,
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Add receipt'),
              ),
      ),
    );
  }
}
