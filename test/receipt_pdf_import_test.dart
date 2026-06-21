import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/services/ica_receipt_parser.dart';
import 'package:list_pilot/data/services/receipt_pdf_service.dart';

import 'pdfrx_setup.dart';

void main() {
  late ReceiptPdfService pdfService;
  late IcaReceiptParser parser;

  setUpAll(() async {
    await setupPdfrxForTests();
  });

  setUp(() {
    pdfService = ReceiptPdfService();
    parser = IcaReceiptParser();
  });

  test('parses large April receipt from Reference PDF', () async {
    final pdf = File('Reference/Maxi ICA Stormarknad Kungälv 2026-04-06.pdf');
    final text = await pdfService.extractTextFromFile(pdf.path);
    final result = parser.parse(text);

    expect(result.totalAmount, 2027.91);
    expect(result.lines.length, greaterThanOrEqualTo(50));
  });

  test('parses small May receipt from Reference PDF', () async {
    final pdf = File('Reference/Maxi ICA Stormarknad Kungälv 2026-05-27.pdf');
    final text = await pdfService.extractTextFromFile(pdf.path);
    final result = parser.parse(text);

    expect(result.totalAmount, 55.90);
    expect(result.lines, hasLength(2));
  });

  test('parses all Reference PDFs with product lines', () async {
    final referenceDir = Directory('Reference');
    final pdfs = referenceDir
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.pdf'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    expect(pdfs, isNotEmpty);

    for (final pdf in pdfs) {
      final text = await pdfService.extractTextFromFile(pdf.path);
      final result = parser.parse(text);

      expect(
        result.lines,
        isNotEmpty,
        reason: 'No product lines in ${pdf.uri.pathSegments.last}',
      );
      expect(result.totalAmount, greaterThan(0));
    }
  });
}
