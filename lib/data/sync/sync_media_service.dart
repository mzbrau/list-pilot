import 'dart:io';

import 'sync_service.dart';
import 'sync_storage_service.dart';

/// Uploads and downloads binary assets for synced entities.
class SyncMediaService {
  SyncMediaService(this._sync);

  final SyncService _sync;

  SyncStorageService get storage => _sync.storage;

  Future<String?> uploadMealPhoto({
    required String mealGlobalId,
    required File sourceFile,
  }) async {
    final syncSpaceId = await _sync.spaceService.getActiveSpaceId();
    if (syncSpaceId == null) return null;
    return _sync.storage.uploadMealPhoto(
      syncSpaceId: syncSpaceId,
      mealGlobalId: mealGlobalId,
      sourceFile: sourceFile,
    );
  }

  Future<File?> downloadMealPhoto({
    required String mealGlobalId,
    required String storageBasePath,
    bool thumbnail = false,
  }) {
    return _sync.storage.downloadMealPhoto(
      storageBasePath: storageBasePath,
      mealGlobalId: mealGlobalId,
      thumbnail: thumbnail,
    );
  }

  Future<String?> uploadReceiptPdf({
    required String receiptGlobalId,
    required File pdfFile,
  }) async {
    final syncSpaceId = await _sync.spaceService.getActiveSpaceId();
    if (syncSpaceId == null) return null;
    return _sync.storage.uploadReceiptPdf(
      syncSpaceId: syncSpaceId,
      receiptGlobalId: receiptGlobalId,
      pdfFile: pdfFile,
    );
  }

  Future<File?> downloadReceiptPdf({
    required String storagePath,
    required String receiptGlobalId,
    required int listId,
  }) {
    return _sync.storage.downloadReceiptPdf(
      storagePath: storagePath,
      receiptGlobalId: receiptGlobalId,
      listId: listId,
    );
  }
}
