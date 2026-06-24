import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../../core/providers/app_providers.dart';

class PendingReceiptShare {
  const PendingReceiptShare({required this.filePaths});

  final List<String> filePaths;
}

class ReceiptShareService {
  ReceiptShareService(this._ref);

  final Ref _ref;
  StreamSubscription<List<SharedMediaFile>>? _mediaSubscription;

  Future<void> initialize() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      _mediaSubscription ??=
          ReceiveSharingIntent.instance.getMediaStream().listen(_handleSharedFiles);
      final initial = await ReceiveSharingIntent.instance.getInitialMedia();
      await _handleSharedFiles(initial);
    }
  }

  void dispose() {
    _mediaSubscription?.cancel();
  }

  Future<void> _handleSharedFiles(List<SharedMediaFile> files) async {
    if (files.isEmpty) return;

    final pdfPaths = files
        .where(
          (file) =>
              file.path.toLowerCase().endsWith('.pdf') ||
              file.type == SharedMediaType.file,
        )
        .map((file) => file.path)
        .where((path) => path.toLowerCase().endsWith('.pdf'))
        .toList();

    if (pdfPaths.isEmpty) {
      await resetIntent();
      return;
    }

    _ref.read(pendingReceiptShareProvider.notifier).state =
        PendingReceiptShare(filePaths: pdfPaths);
  }

  Future<void> resetIntent() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await ReceiveSharingIntent.instance.reset();
    }
  }

  Future<int> importToList({
    required int listId,
    required String sourcePath,
  }) {
    return _ref.read(receiptImportServiceProvider).importPdf(
          listId: listId,
          sourcePdfPath: sourcePath,
        );
  }
}

final pendingReceiptShareProvider =
    StateProvider<PendingReceiptShare?>((ref) => null);

final receiptShareServiceProvider = Provider<ReceiptShareService>((ref) {
  final service = ReceiptShareService(ref);
  ref.onDispose(service.dispose);
  return service;
});
