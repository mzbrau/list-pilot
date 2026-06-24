import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../router/navigation_helpers.dart';
import 'receipt_formatters.dart';
import 'widgets/receipt_line_catalog_match_sheet.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  const ReceiptDetailScreen({
    super.key,
    required this.listId,
    required this.receiptId,
  });

  final int listId;
  final int receiptId;

  Future<void> _openPdf(WidgetRef ref) async {
    final receipt = await ref.read(receiptRepositoryProvider).getReceiptById(receiptId);
    if (receipt == null) return;
    final path = await ref.read(receiptRepositoryProvider).resolvePdfPath(
          listId: listId,
          fileName: receipt.pdfFileName,
        );
    await OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptAsync = ref.watch(receiptProvider(receiptId));
    final linesAsync = ref.watch(receiptLinesProvider(receiptId));
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: overviewBackButton(context),
          title: receiptAsync.when(
            data: (receipt) => Text(receipt?.shopName ?? 'Receipt'),
            loading: () => const Text('Receipt'),
            error: (_, __) => const Text('Receipt'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'Open PDF',
              onPressed: () => _openPdf(ref),
            ),
          ],
        ),
        body: receiptAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (receipt) {
            if (receipt == null) {
              return const Center(child: Text('Receipt not found'));
            }

            final categories = categoriesAsync.valueOrNull ?? [];
            final categoryNames = {
              for (final category in categories) category.id: category.name,
            };

            return linesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (lines) {
                final grouped = <String, List<ReceiptLine>>{};
                for (final line in lines) {
                  grouped.putIfAbsent(line.categoryId, () => []).add(line);
                }

                final sortedCategoryIds = grouped.keys.toList()
                  ..sort(
                    (a, b) => (categoryNames[a] ?? a).compareTo(categoryNames[b] ?? b),
                  );

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              receipt.shopName,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(dateFormat.format(receipt.purchasedAt)),
                            if (receipt.receiptNumber != null) ...[
                              const SizedBox(height: 4),
                              Text('Receipt #${receipt.receiptNumber}'),
                            ],
                            const SizedBox(height: 12),
                            Text(
                              formatReceiptAmount(receipt.totalAmount),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final categoryId in sortedCategoryIds) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          categoryNames[categoryId] ?? categoryId,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Card(
                        child: Column(
                          children: [
                            for (final line in grouped[categoryId]!) ...[
                              _ReceiptLineTile(line: line),
                              if (line != grouped[categoryId]!.last)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ReceiptLineTile extends ConsumerWidget {
  const _ReceiptLineTile({required this.line});

  final ReceiptLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMatched = line.catalogItemId != null;
    final catalogAsync = isMatched
        ? ref.watch(catalogItemProvider(line.catalogItemId!))
        : null;
    final catalogName = catalogAsync?.valueOrNull?.displayName;

    return ListTile(
      leading: IconButton(
        icon: Icon(
          isMatched ? Icons.link : Icons.link_off,
          color: isMatched ? theme.colorScheme.primary : theme.colorScheme.outline,
        ),
        tooltip: isMatched
            ? (catalogName != null ? 'Catalog: $catalogName' : 'Catalog match')
            : 'Link to catalog item',
        visualDensity: VisualDensity.compact,
        onPressed: () => ReceiptLineCatalogMatchSheet.show(context, line: line),
      ),
      title: Text(line.englishName),
      subtitle: line.originalDescription != line.englishName
          ? Text(line.originalDescription)
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatReceiptAmount(line.lineTotal)),
          if (line.quantity != null)
            Text(
              formatReceiptQuantity(line.quantity, line.quantityUnit),
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }
}
