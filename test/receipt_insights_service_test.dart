import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/services/receipt_insights_service.dart';

void main() {
  test('aggregates category totals and top items', () {
    final service = ReceiptInsightsService();
    final receipts = [
      Receipt(
        id: 1,
        listId: 1,
        shopName: 'ICA',
        purchasedAt: DateTime(2026, 5, 27),
        totalAmount: 100,
        receiptNumber: '1',
        pdfFileName: '1.pdf',
        currency: 'SEK',
        createdAt: DateTime(2026, 5, 27),
      ),
    ];
    final lines = [
      ReceiptLineWithReceipt(
        line: ReceiptLine(
          id: 1,
          receiptId: 1,
          originalDescription: 'Kyckling',
          englishName: 'Chicken',
          catalogItemId: null,
          categoryId: 'meat',
          articleNumber: null,
          unitPrice: null,
          quantity: 2,
          quantityUnit: 'st',
          lineTotal: 120,
          sortOrder: 0,
        ),
        receipt: receipts[0],
      ),
      ReceiptLineWithReceipt(
        line: ReceiptLine(
          id: 2,
          receiptId: 1,
          originalDescription: 'Banan',
          englishName: 'Bananas',
          catalogItemId: null,
          categoryId: 'fruit_veg',
          articleNumber: null,
          unitPrice: null,
          quantity: 1,
          quantityUnit: 'kg',
          lineTotal: 20,
          sortOrder: 1,
        ),
        receipt: receipts[0],
      ),
    ];

    final snapshot = service.build(receipts: receipts, lines: lines);
    expect(snapshot.categoryTotals.first.categoryId, 'meat');
    expect(snapshot.topItems.first.name, 'Chicken');
    expect(snapshot.monthlyCategorySpend.single.year, 2026);
    expect(snapshot.monthlyCategorySpend.single.month, 5);
  });
}
