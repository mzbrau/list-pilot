import 'package:intl/intl.dart';

final receiptCurrencyFormat = NumberFormat.currency(
  locale: 'sv_SE',
  symbol: 'kr',
  decimalDigits: 2,
);

String formatReceiptAmount(double amount) {
  return receiptCurrencyFormat.format(amount).replaceAll('\u00A0', ' ');
}

String formatReceiptQuantity(double? quantity, String? unit) {
  if (quantity == null) return '';
  final qtyText = quantity == quantity.roundToDouble()
      ? quantity.toInt().toString()
      : quantity.toString();
  if (unit == null || unit.isEmpty) return qtyText;
  return '$qtyText $unit';
}
