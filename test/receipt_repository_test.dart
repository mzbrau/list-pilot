import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:list_pilot/data/database/app_database.dart';
import 'package:list_pilot/data/repositories/receipt_repository.dart';
import 'package:list_pilot/data/services/receipt_insights_service.dart';

void main() {
  late AppDatabase db;
  late ReceiptRepository repo;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('receipt_repo_test');
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ReceiptRepository(db, storageRoot: tempDir);
  });

  tearDown(() async {
    await db.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('createList and importReceipt', () async {
    final listId = await repo.createList('Groceries');
    final receiptId = await repo.importReceipt(
      listId: listId,
      draft: ReceiptImportDraft(
        shopName: 'ICA',
        purchasedAt: DateTime(2026, 5, 27, 21, 17),
        receiptNumber: '7923',
        totalAmount: 55.90,
        lines: const [
          ReceiptLineDraft(
            originalDescription: 'Aprikos 500g',
            englishName: 'Apricots',
            categoryId: 'fruit_veg',
            lineTotal: 46.90,
            sortOrder: 0,
          ),
        ],
      ),
      sourcePdfPath: 'test/fixtures/ica_receipt_sample.txt',
    );

    final receipt = await repo.getReceiptById(receiptId);
    expect(receipt?.shopName, 'ICA');
    expect(receipt?.totalAmount, 55.90);

    final lines = await repo.watchLinesForReceipt(receiptId).first;
    expect(lines, hasLength(1));
    expect(lines.first.englishName, 'Apricots');
  });

  test('duplicate import is rejected', () async {
    final listId = await repo.createList('Groceries');
    final draft = ReceiptImportDraft(
      shopName: 'ICA',
      purchasedAt: DateTime(2026, 5, 27, 21, 17),
      receiptNumber: '7923',
      totalAmount: 55.90,
      lines: const [
        ReceiptLineDraft(
          originalDescription: 'Aprikos 500g',
          englishName: 'Apricots',
          categoryId: 'fruit_veg',
          lineTotal: 46.90,
          sortOrder: 0,
        ),
      ],
    );

    await repo.importReceipt(
      listId: listId,
      draft: draft,
      sourcePdfPath: 'test/fixtures/ica_receipt_sample.txt',
    );

    expect(
      () => repo.importReceipt(
        listId: listId,
        draft: draft,
        sourcePdfPath: 'test/fixtures/ica_receipt_sample.txt',
      ),
      throwsA(isA<DuplicateReceiptException>()),
    );
  });

  test('insights aggregate monthly and top items', () {
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
      Receipt(
        id: 2,
        listId: 1,
        shopName: 'ICA',
        purchasedAt: DateTime(2026, 6, 4),
        totalAmount: 80,
        receiptNumber: '2',
        pdfFileName: '2.pdf',
        currency: 'SEK',
        createdAt: DateTime(2026, 6, 4),
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
          quantity: 1,
          quantityUnit: 'st',
          lineTotal: 60,
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
          lineTotal: 40,
          sortOrder: 1,
        ),
        receipt: receipts[0],
      ),
      ReceiptLineWithReceipt(
        line: ReceiptLine(
          id: 3,
          receiptId: 2,
          originalDescription: 'Kyckling',
          englishName: 'Chicken',
          catalogItemId: null,
          categoryId: 'meat',
          articleNumber: null,
          unitPrice: null,
          quantity: 1,
          quantityUnit: 'st',
          lineTotal: 50,
          sortOrder: 0,
        ),
        receipt: receipts[1],
      ),
    ];

    final snapshot = service.build(receipts: receipts, lines: lines);
    expect(snapshot.tripPoints, hasLength(2));
    expect(snapshot.categoryTotals.first.categoryId, 'meat');
    expect(snapshot.categoryTotals.first.total, 110);
    expect(snapshot.topItems.first.name, 'Chicken');
    expect(snapshot.topItems.first.total, 110);
    expect(snapshot.monthlyCategorySpend, hasLength(2));
  });
}
