import 'dart:io';
import 'dart:typed_data';

import 'package:syncfusion_flutter_pdf/pdf.dart';

class ReceiptPdfService {
  Future<String> extractTextFromFile(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    return extractTextFromBytes(bytes);
  }

  String extractTextFromBytes(Uint8List bytes) {
    final document = PdfDocument(inputBytes: bytes);
    try {
      final extractor = PdfTextExtractor(document);
      final buffer = StringBuffer();
      for (var i = 0; i < document.pages.count; i++) {
        final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        if (pageText.isNotEmpty) {
          if (buffer.isNotEmpty) {
            buffer.writeln();
          }
          buffer.write(pageText);
        }
      }
      return buffer.toString();
    } finally {
      document.dispose();
    }
  }
}
