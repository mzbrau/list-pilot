import '../database/app_database.dart';

class CategorySpendTotal {
  const CategorySpendTotal({
    required this.categoryId,
    required this.total,
  });

  final String categoryId;
  final double total;
}

class ItemSpendTotal {
  const ItemSpendTotal({
    required this.name,
    required this.total,
    required this.purchaseCount,
  });

  final String name;
  final double total;
  final int purchaseCount;
}

class MonthlyCategorySpend {
  const MonthlyCategorySpend({
    required this.year,
    required this.month,
    required this.categoryTotals,
  });

  final int year;
  final int month;
  final Map<String, double> categoryTotals;

  double get total =>
      categoryTotals.values.fold(0.0, (sum, value) => sum + value);
}

class ReceiptTripPoint {
  const ReceiptTripPoint({
    required this.receiptId,
    required this.shopName,
    required this.purchasedAt,
    required this.totalAmount,
  });

  final int receiptId;
  final String shopName;
  final DateTime purchasedAt;
  final double totalAmount;
}

class ReceiptInsightsSnapshot {
  const ReceiptInsightsSnapshot({
    required this.tripPoints,
    required this.monthlyCategorySpend,
    required this.categoryTotals,
    required this.topItems,
  });

  final List<ReceiptTripPoint> tripPoints;
  final List<MonthlyCategorySpend> monthlyCategorySpend;
  final List<CategorySpendTotal> categoryTotals;
  final List<ItemSpendTotal> topItems;
}

class ReceiptInsightsService {
  ReceiptInsightsSnapshot build({
    required List<Receipt> receipts,
    required List<ReceiptLineWithReceipt> lines,
  }) {
    final tripPoints = receipts
        .map(
          (receipt) => ReceiptTripPoint(
            receiptId: receipt.id,
            shopName: receipt.shopName,
            purchasedAt: receipt.purchasedAt,
            totalAmount: receipt.totalAmount,
          ),
        )
        .toList()
      ..sort((a, b) => a.purchasedAt.compareTo(b.purchasedAt));

    final monthlyMap = <String, Map<String, double>>{};
    final categoryMap = <String, double>{};
    final itemMap = <String, _ItemAccumulator>{};

    for (final entry in lines) {
      final line = entry.line;
      final receipt = entry.receipt;
      final monthKey =
          '${receipt.purchasedAt.year}-${receipt.purchasedAt.month.toString().padLeft(2, '0')}';
      monthlyMap.putIfAbsent(monthKey, () => {});
      monthlyMap[monthKey]![line.categoryId] =
          (monthlyMap[monthKey]![line.categoryId] ?? 0) + line.lineTotal;

      categoryMap[line.categoryId] =
          (categoryMap[line.categoryId] ?? 0) + line.lineTotal;

      final itemName = line.englishName.trim().toLowerCase();
      final accumulator = itemMap.putIfAbsent(
        itemName,
        () => _ItemAccumulator(displayName: line.englishName.trim()),
      );
      accumulator.total += line.lineTotal;
      accumulator.count += 1;
    }

    final monthlyCategorySpend = monthlyMap.entries.map((entry) {
      final parts = entry.key.split('-');
      return MonthlyCategorySpend(
        year: int.parse(parts[0]),
        month: int.parse(parts[1]),
        categoryTotals: entry.value,
      );
    }).toList()
      ..sort((a, b) {
        final yearCompare = a.year.compareTo(b.year);
        if (yearCompare != 0) return yearCompare;
        return a.month.compareTo(b.month);
      });

    final categoryTotals = categoryMap.entries
        .map(
          (entry) => CategorySpendTotal(
            categoryId: entry.key,
            total: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    final topItems = itemMap.values
        .map(
          (item) => ItemSpendTotal(
            name: item.displayName,
            total: item.total,
            purchaseCount: item.count,
          ),
        )
        .toList()
      ..sort((a, b) => b.total.compareTo(a.total));

    return ReceiptInsightsSnapshot(
      tripPoints: tripPoints,
      monthlyCategorySpend: monthlyCategorySpend,
      categoryTotals: categoryTotals,
      topItems: topItems.take(10).toList(),
    );
  }
}

class _ItemAccumulator {
  _ItemAccumulator({required this.displayName});

  final String displayName;
  double total = 0;
  int count = 0;
}
