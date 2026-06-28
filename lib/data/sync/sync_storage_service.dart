import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SyncStorageService {
  SyncStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadMealPhoto({
    required String syncSpaceId,
    required String mealGlobalId,
    required File sourceFile,
  }) async {
    final bytes = await sourceFile.readAsBytes();
    final fullBytes = await _encodeWebp(bytes, maxDimension: 1200, quality: 85);
    final thumbBytes = await _encodeWebp(bytes, maxDimension: 400, quality: 80);

    final basePath = 'syncSpaces/$syncSpaceId/images/meals/$mealGlobalId';
    await _storage.ref('$basePath/full.webp').putData(
          fullBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
    await _storage.ref('$basePath/thumb.webp').putData(
          thumbBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
    return basePath;
  }

  Future<File?> downloadMealPhoto({
    required String storageBasePath,
    required String mealGlobalId,
    bool thumbnail = false,
  }) async {
    final variant = thumbnail ? 'thumb.webp' : 'full.webp';
    final ref = _storage.ref('$storageBasePath/$variant');
    final bytes = await ref.getData();
    if (bytes == null) return null;

    final docs = await getApplicationDocumentsDirectory();
    final relative = p.join('meal_photos', '$mealGlobalId.webp');
    final file = File(p.join(docs.path, relative));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<String> uploadReceiptPdf({
    required String syncSpaceId,
    required String receiptGlobalId,
    required File pdfFile,
  }) async {
    final stat = await pdfFile.length();
    if (stat > 5 * 1024 * 1024) {
      throw StateError('Receipt PDF exceeds 5 MB limit');
    }
    final path = 'syncSpaces/$syncSpaceId/receipts/$receiptGlobalId.pdf';
    await _storage.ref(path).putFile(
          pdfFile,
          SettableMetadata(contentType: 'application/pdf'),
        );
    return path;
  }

  Future<File?> downloadReceiptPdf({
    required String storagePath,
    required String receiptGlobalId,
    required int listId,
  }) async {
    final ref = _storage.ref(storagePath);
    final bytes = await ref.getData();
    if (bytes == null) return null;

    final docs = await getApplicationDocumentsDirectory();
    final relative = p.join('receipts', '$listId', '$receiptGlobalId.pdf');
    final file = File(p.join(docs.path, relative));
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> deleteMealPhotos({
    required String syncSpaceId,
    required String mealGlobalId,
  }) async {
    final base = _storage.ref(
      'syncSpaces/$syncSpaceId/images/meals/$mealGlobalId',
    );
    try {
      await base.child('full.webp').delete();
      await base.child('thumb.webp').delete();
    } catch (_) {
      // Best-effort cleanup.
    }
  }

  Future<Uint8List> _encodeWebp(
    Uint8List input, {
    required int maxDimension,
    required int quality,
  }) async {
    final decoded = img.decodeImage(input);
    if (decoded == null) return input;
    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? maxDimension : null,
      height: decoded.height > decoded.width ? maxDimension : null,
    );
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }
}
