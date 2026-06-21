import 'dart:io';
import 'dart:typed_data';

import 'package:pdfrx/pdfrx.dart';

class ReceiptPdfService {
  Future<String> extractTextFromFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return extractTextFromBytes(bytes);
  }

  Future<String> extractTextFromBytes(Uint8List bytes) async {
    final document = await PdfDocument.openData(bytes);
    try {
      final buffer = StringBuffer();
      for (final page in document.pages) {
        final pageText = (await page.loadText()).fullText.trim();
        if (pageText.isNotEmpty) {
          if (buffer.isNotEmpty) {
            buffer.writeln();
          }
          buffer.write(pageText);
        }
      }
      return buffer.toString();
    } finally {
      await document.dispose();
    }
  }
}
