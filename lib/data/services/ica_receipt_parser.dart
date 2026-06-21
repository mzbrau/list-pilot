class IcaReceiptLineItem {
  const IcaReceiptLineItem({
    required this.description,
    this.articleNumber,
    this.unitPrice,
    this.quantity,
    this.quantityUnit,
    required this.lineTotal,
    this.isPromo = false,
  });

  final String description;
  final String? articleNumber;
  final double? unitPrice;
  final double? quantity;
  final String? quantityUnit;
  final double lineTotal;
  final bool isPromo;
}

class IcaParsedReceipt {
  const IcaParsedReceipt({
    required this.shopName,
    required this.purchasedAt,
    this.receiptNumber,
    required this.totalAmount,
    required this.lines,
  });

  final String shopName;
  final DateTime purchasedAt;
  final String? receiptNumber;
  final double totalAmount;
  final List<IcaReceiptLineItem> lines;
}

class IcaReceiptParseException implements Exception {
  IcaReceiptParseException(this.message);

  final String message;

  @override
  String toString() => message;
}

class IcaReceiptParser {
  static final _datePattern = RegExp(r'^(\d{4}-\d{2}-\d{2})$', multiLine: true);
  static final _timePattern = RegExp(r'^(\d{2}:\d{2})$', multiLine: true);
  static final _totalPattern = RegExp(
    r'Totalt\s+SEK\s+([\d,]+)',
    caseSensitive: false,
  );
  static final _productLine = RegExp(
    r'^(\*)?'
    r'(.+?)\s+'
    r'(\d{7})\s+'
    r'([\d,]+)\s+'
    r'([\d,]+)\s+'
    r'(st|kg)\s+'
    r'([\d,]+)'
    r'\s*$',
  );
  static final _discountLine = RegExp(
    r'kr/st\s+-[\d,]+$|kr/kg\s+-[\d,]+$|rabatt\d+%\s+-[\d,]+$',
    caseSensitive: false,
  );

  static const _skipPrefixes = [
    'betalat',
    'moms %',
    'moms netto',
    'erhållen rabatt',
    'avrundning',
    'betalningsinformation',
    'term:',
    'debit',
    'butik:',
    'ref:',
    'personlig kod',
    'köp ',
    'varav moms',
    'totalt sek',
    'spara kvittot',
    'få kvittot',
    'läs mer',
    'kosmetik',
    '1 års garanti',
    'originalkvitto',
    'välkommen',
    'returkod',
    'lojalitetspoäng',
    'återbetalning',
    'kontant ',
    'debit mastercard',
    'contactless',
    'datum',
    'tid',
    'org nr',
    'kvitto nr',
    'kassa',
    'kassör',
    'beskrivning',
    'kvitto',
    'maxi ica',
    'gymnasiegatan',
    '44248',
    'störst på',
    'dygnet runt',
    'org.nr',
    'www.maxi',
    '-- ',
    'kort ',
    'tvr:',
    'aid:',
    'swe:',
    'rsp:',
  ];

  IcaParsedReceipt parse(String text) {
    final lines = text.split('\n').map((line) => line.trim()).toList();

    final dateMatch = _datePattern.firstMatch(text);
    if (dateMatch == null) {
      throw IcaReceiptParseException('Could not find receipt date');
    }
    final dateParts = dateMatch.group(1)!.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);

    var hour = 0;
    var minute = 0;
    final timeIndex = lines.indexWhere((line) => line == dateMatch.group(1));
    if (timeIndex >= 0 && timeIndex + 1 < lines.length) {
      final timeMatch = _timePattern.firstMatch(lines[timeIndex + 1]);
      if (timeMatch != null) {
        final timeParts = timeMatch.group(1)!.split(':');
        hour = int.parse(timeParts[0]);
        minute = int.parse(timeParts[1]);
      }
    }

    final shopName = _extractShopName(lines);
    final receiptNumber = _extractReceiptNumber(lines);

    final totalMatch = _totalPattern.firstMatch(text);
    if (totalMatch == null) {
      throw IcaReceiptParseException('Could not find receipt total');
    }
    final totalAmount = _parseSwedishNumber(totalMatch.group(1)!);

    final items = <IcaReceiptLineItem>[];
    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      final lower = line.toLowerCase();
      if (_skipPrefixes.any(lower.startsWith)) continue;
      if (_discountLine.hasMatch(lower)) continue;
      if (RegExp(r'^kort [\d,]+$').hasMatch(lower)) continue;

      final match = _productLine.firstMatch(line);
      if (match == null) continue;

      items.add(
        IcaReceiptLineItem(
          isPromo: match.group(1) == '*',
          description: match.group(2)!.trim(),
          articleNumber: match.group(3),
          unitPrice: _parseSwedishNumber(match.group(4)!),
          quantity: _parseSwedishNumber(match.group(5)!),
          quantityUnit: match.group(6),
          lineTotal: _parseSwedishNumber(match.group(7)!),
        ),
      );
    }

    if (items.isEmpty) {
      throw IcaReceiptParseException('No product lines found on receipt');
    }

    return IcaParsedReceipt(
      shopName: shopName,
      purchasedAt: DateTime(year, month, day, hour, minute),
      receiptNumber: receiptNumber,
      totalAmount: totalAmount,
      lines: items,
    );
  }

  String _extractShopName(List<String> lines) {
    final kvittoIndex = lines.indexWhere((line) => line == 'Kvitto');
    if (kvittoIndex >= 0 && kvittoIndex + 1 < lines.length) {
      final candidate = lines[kvittoIndex + 1].trim();
      if (candidate.isNotEmpty && candidate != 'Kvitto') {
        return candidate;
      }
    }
    return 'ICA Store';
  }

  String? _extractReceiptNumber(List<String> lines) {
    const headers = ['Datum', 'Tid', 'Org nr', 'Kvitto nr', 'Kassa', 'Kassör'];
    final headerIndex = headers.indexOf('Kvitto nr');
    if (headerIndex < 0) return null;

    final valuesStart = lines.indexWhere(
      (line) => RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(line),
    );
    if (valuesStart < 0) return null;

    final valueIndex = valuesStart + headerIndex;
    if (valueIndex >= lines.length) return null;
    final value = lines[valueIndex].trim();
    return RegExp(r'^\d+$').hasMatch(value) ? value : null;
  }

  static double _parseSwedishNumber(String value) {
    return double.parse(value.replaceAll(',', '.').trim());
  }
}
