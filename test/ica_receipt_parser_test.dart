import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/data/services/ica_receipt_parser.dart';

void main() {
  late String sampleText;

  setUp(() {
    sampleText = File('test/fixtures/ica_receipt_sample.txt').readAsStringSync();
  });

  test('parses shop, date, time, total, and line items', () {
    final result = IcaReceiptParser().parse(sampleText);

    expect(result.shopName, 'Maxi ICA Stormarknad Kungälv');
    expect(result.purchasedAt, DateTime(2026, 5, 27, 21, 17));
    expect(result.receiptNumber, '7923');
    expect(result.totalAmount, 55.90);
    expect(result.lines, hasLength(2));
    expect(result.lines.first.description, 'Aprikos 500g');
    expect(result.lines.first.articleNumber, '2984674');
    expect(result.lines.first.quantity, 1.0);
    expect(result.lines.first.quantityUnit, 'st');
    expect(result.lines.first.lineTotal, 46.90);
    expect(result.lines.last.description, 'Norrlands-Leväjn');
    expect(result.lines.last.lineTotal, 28.70);
  });

  test('throws when date is missing', () {
    expect(
      () => IcaReceiptParser().parse('Totalt SEK 10,00'),
      throwsA(isA<IcaReceiptParseException>()),
    );
  });

  test('parseSwedishNumber handles common ICA formats', () {
    expect(IcaReceiptParser.parseSwedishNumber('55,90'), 55.90);
    expect(IcaReceiptParser.parseSwedishNumber('2,027,91'), 2027.91);
    expect(IcaReceiptParser.parseSwedishNumber('1.166,63'), 1166.63);
    expect(IcaReceiptParser.parseSwedishNumber('1,166,63'), 1166.63);
    expect(IcaReceiptParser.parseSwedishNumber('1.166.63'), 1166.63);
  });

  test('parses receipt with comma-grouped thousands total', () {
    final text =
        File('test/fixtures/ica_receipt_large_total.txt').readAsStringSync();
    final result = IcaReceiptParser().parse(text);

    expect(result.totalAmount, 2027.91);
    expect(result.lines, hasLength(1));
    expect(result.lines.first.lineTotal, 22.60);
  });
}
