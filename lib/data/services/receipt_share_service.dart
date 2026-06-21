import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../core/providers/app_providers.dart';
import '../repositories/receipt_repository.dart';

class PendingReceiptShare {
  const PendingReceiptShare({required this.filePath});

  final String filePath;
}

class ReceiptShareService {
  ReceiptShareService(this._ref);

  final Ref _ref;
  StreamSubscription<List<SharedMediaFile>>? _mediaSubscription;

  void initialize() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      ReceiveSharingIntent.instance.getInitialMedia().then(_handleSharedFiles);
      _mediaSubscription =
          ReceiveSharingIntent.instance.getMediaStream().listen(_handleSharedFiles);
    }
  }

  void dispose() {
    _mediaSubscription?.cancel();
  }

  Future<void> _handleSharedFiles(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;

    final pdf = files.firstWhere(
      (file) =>
          file.path.toLowerCase().endsWith('.pdf') ||
          file.type == SharedMediaType.file,
      orElse: () => files.first,
    );
    if (!pdf.path.toLowerCase().endsWith('.pdf')) {
      ReceiveSharingIntent.instance.reset();
      return;
    }

    _ref.read(pendingReceiptShareProvider.notifier).state =
        PendingReceiptShare(filePath: pdf.path);
    ReceiveSharingIntent.instance.reset();
  }

  Future<int?> importToList({
    required int listId,
    required String sourcePath,
  }) async {
    try {
      return await _ref.read(receiptImportServiceProvider).importPdf(
            listId: listId,
            sourcePdfPath: sourcePath,
          );
    } on DuplicateReceiptException {
      rethrow;
    }
  }
}

final pendingReceiptShareProvider =
    StateProvider<PendingReceiptShare?>((ref) => null);

final receiptShareServiceProvider = Provider<ReceiptShareService>((ref) {
  final service = ReceiptShareService(ref);
  ref.onDispose(service.dispose);
  return service;
});
