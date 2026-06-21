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
}
