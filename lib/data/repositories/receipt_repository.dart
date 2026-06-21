import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';

class ReceiptLineDraft {
  const ReceiptLineDraft({
    required this.originalDescription,
    required this.englishName,
    this.catalogItemId,
    required this.categoryId,
    this.articleNumber,
    this.unitPrice,
    this.quantity,
    this.quantityUnit,
    required this.lineTotal,
    required this.sortOrder,
  });

  final String originalDescription;
  final String englishName;
  final int? catalogItemId;
  final String categoryId;
  final String? articleNumber;
  final double? unitPrice;
  final double? quantity;
  final String? quantityUnit;
  final double lineTotal;
  final int sortOrder;
}

class ReceiptImportDraft {
  const ReceiptImportDraft({
    required this.shopName,
    required this.purchasedAt,
    this.receiptNumber,
    required this.totalAmount,
    required this.lines,
    this.currency = 'SEK',
  });

  final String shopName;
  final DateTime purchasedAt;
  final String? receiptNumber;
  final double totalAmount;
  final List<ReceiptLineDraft> lines;
  final String currency;
}

class DuplicateReceiptException implements Exception {
  DuplicateReceiptException(this.existingReceiptId);

  final int existingReceiptId;

  @override
  String toString() => 'Receipt already imported';
}

class ReceiptRepository {
  ReceiptRepository(this._db, {Directory? storageRoot})
      : _storageRoot = storageRoot;

  final AppDatabase _db;
  final Directory? _storageRoot;

  Stream<List<ReceiptList>> watchAllLists() => _db.watchAllReceiptLists();

  Future<ReceiptList?> getListById(int id) => _db.getReceiptListById(id);

  Future<int> createList(String name) async {
    final now = DateTime.now();
    return _db.into(_db.receiptLists).insert(
          ReceiptListsCompanion.insert(
            name: name.trim(),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> renameList(int id, String name) async {
    await (_db.update(_db.receiptLists)..where((t) => t.id.equals(id))).write(
      ReceiptListsCompanion(
        name: Value(name.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteList(int id) async {
    final receipts = await (_db.select(_db.receipts)
          ..where((t) => t.listId.equals(id)))
        .get();
    for (final receipt in receipts) {
      await deleteReceipt(receipt.id);
    }
    await _deleteReceiptDirectory(id);
    await (_db.delete(_db.receiptAiInsightRuns)
          ..where((t) => t.listId.equals(id)))
        .go();
    await (_db.delete(_db.receiptLists)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Receipt>> watchReceiptsForList(int listId) =>
      _db.watchReceiptsForList(listId);

  Future<Receipt?> getReceiptById(int id) => _db.getReceiptById(id);

  Stream<Receipt?> watchReceiptById(int id) => _db.watchReceiptById(id);

  Stream<List<ReceiptLine>> watchLinesForReceipt(int receiptId) =>
      _db.watchLinesForReceipt(receiptId);

  Future<List<ReceiptLineWithReceipt>> getLinesForList(int listId) =>
      _db.getLinesForList(listId);

  Future<bool> isDuplicate({
    required int listId,
    required DateTime purchasedAt,
    String? receiptNumber,
  }) async {
    final existing = await _db.findDuplicateReceipt(
      listId: listId,
      purchasedAt: purchasedAt,
      receiptNumber: receiptNumber,
    );
    return existing != null;
  }

  Future<int> importReceipt({
    required int listId,
    required ReceiptImportDraft draft,
    required String sourcePdfPath,
  }) async {
    final existing = await _db.findDuplicateReceipt(
      listId: listId,
      purchasedAt: draft.purchasedAt,
      receiptNumber: draft.receiptNumber,
    );
    if (existing != null) {
      throw DuplicateReceiptException(existing.id);
    }

    final now = DateTime.now();
    final receiptId = await _db.into(_db.receipts).insert(
          ReceiptsCompanion.insert(
            listId: listId,
            shopName: draft.shopName.trim(),
            purchasedAt: draft.purchasedAt,
            totalAmount: draft.totalAmount,
            receiptNumber: Value(draft.receiptNumber),
            pdfFileName: 'pending.pdf',
            currency: Value(draft.currency),
            createdAt: now,
          ),
        );

    final pdfFileName = '$receiptId.pdf';
    await _copyPdfToStorage(
      listId: listId,
      receiptId: receiptId,
      sourcePath: sourcePdfPath,
      fileName: pdfFileName,
    );

    await (_db.update(_db.receipts)..where((t) => t.id.equals(receiptId))).write(
      ReceiptsCompanion(pdfFileName: Value(pdfFileName)),
    );

    await _replaceLines(receiptId, draft.lines);
    await _touchListUpdated(listId);
    return receiptId;
  }

  Future<void> deleteReceipt(int receiptId) async {
    final receipt = await getReceiptById(receiptId);
    if (receipt == null) return;

    await (_db.delete(_db.receiptLines)
          ..where((t) => t.receiptId.equals(receiptId)))
        .go();
    await (_db.delete(_db.receipts)..where((t) => t.id.equals(receiptId))).go();

    final pdfPath = await resolvePdfPath(
      listId: receipt.listId,
      fileName: receipt.pdfFileName,
    );
    final file = File(pdfPath);
    if (await file.exists()) {
      await file.delete();
    }
    await _touchListUpdated(receipt.listId);
  }

  Future<String> resolvePdfPath({
    required int listId,
    required String fileName,
  }) async {
    final dir = await _receiptDirectory(listId);
    return p.join(dir.path, fileName);
  }

  Stream<ReceiptAiInsightRun?> watchLatestAiInsight(int listId) =>
      _db.watchLatestAiInsight(listId);

  Future<void> saveAiInsightRun({
    required int listId,
    required String content,
  }) async {
    await (_db.delete(_db.receiptAiInsightRuns)
          ..where((t) => t.listId.equals(listId)))
        .go();
    await _db.into(_db.receiptAiInsightRuns).insert(
          ReceiptAiInsightRunsCompanion.insert(
            listId: listId,
            generatedAt: DateTime.now(),
            content: content.trim(),
          ),
        );
  }

  Future<void> _replaceLines(int receiptId, List<ReceiptLineDraft> lines) async {
    await (_db.delete(_db.receiptLines)
          ..where((t) => t.receiptId.equals(receiptId)))
        .go();
    for (final line in lines) {
      await _db.into(_db.receiptLines).insert(
            ReceiptLinesCompanion.insert(
              receiptId: receiptId,
              originalDescription: line.originalDescription,
              englishName: line.englishName,
              catalogItemId: Value(line.catalogItemId),
              categoryId: line.categoryId,
              articleNumber: Value(line.articleNumber),
              unitPrice: Value(line.unitPrice),
              quantity: Value(line.quantity),
              quantityUnit: Value(line.quantityUnit),
              lineTotal: line.lineTotal,
              sortOrder: Value(line.sortOrder),
            ),
          );
    }
  }

  Future<void> _copyPdfToStorage({
    required int listId,
    required int receiptId,
    required String sourcePath,
    required String fileName,
  }) async {
    final dir = await _receiptDirectory(listId);
    final target = File(p.join(dir.path, fileName));
    await File(sourcePath).copy(target.path);
  }

  Future<Directory> _receiptDirectory(int listId) async {
    final root = _storageRoot ?? await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'receipts', '$listId'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _deleteReceiptDirectory(int listId) async {
    final root = _storageRoot ?? await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'receipts', '$listId'));
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }

  Future<void> _touchListUpdated(int listId) async {
    await (_db.update(_db.receiptLists)..where((t) => t.id.equals(listId))).write(
      ReceiptListsCompanion(updatedAt: Value(DateTime.now())),
    );
  }
}
