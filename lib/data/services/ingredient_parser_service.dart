import '../../core/constants/app_constants.dart';
import 'recipe_json_ld.dart';

class ParsedIngredientLine {
  const ParsedIngredientLine({
    required this.itemName,
    this.quantityValue,
    this.quantityUnit,
    required this.originalLine,
  });

  final String itemName;
  final double? quantityValue;
  final String? quantityUnit;
  final String originalLine;

  bool get hasQuantity => quantityValue != null && quantityUnit != null;
}

class IngredientParserService {
  const IngredientParserService();

  static const _unicodeFractions = {
    '½': 0.5,
    '⅓': 1 / 3,
    '⅔': 2 / 3,
    '¼': 0.25,
    '¾': 0.75,
    '⅕': 0.2,
    '⅖': 0.4,
    '⅗': 0.6,
    '⅘': 0.8,
    '⅙': 1 / 6,
    '⅚': 5 / 6,
    '⅛': 0.125,
    '⅜': 0.375,
    '⅝': 0.625,
    '⅞': 0.875,
  };

  static final _countUnits = RegExp(
    r'^(x|pcs?|pieces?|cloves?|cups?|tbsp|tsp|tablespoons?|teaspoons?|slices?|bunches?|cans?|packets?|pinch(?:es)?)$',
    caseSensitive: false,
  );

  static final _weightVolumeUnits = RegExp(
    r'^(g|grams?|kg|kilograms?|ml|milliliters?|millilitres?|l|liters?|litres?)$',
    caseSensitive: false,
  );

  static final _leadingQuantity = RegExp(
    r'^((?:\d+\s+)?\d+/\d+|\d+(?:\.\d+)?|[½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])(?:\s*[½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])?\s*',
  );

  ParsedIngredientLine parse(String raw) {
    final originalLine = raw.trim();
    final line = normalizeIngredientLine(raw);
    if (line.isEmpty) {
      return ParsedIngredientLine(
        itemName: '',
        originalLine: originalLine,
      );
    }

    final attached = RegExp(
      r'^((?:\d+\s+)?\d+/\d+|\d+(?:\.\d+)?|[½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])(?:\s*[½⅓⅔¼¾⅕⅖⅗⅘⅙⅚⅛⅜⅝⅞])?\s*(g|kg|ml|l|grams?|kilograms?|milliliters?|millilitres?|liters?|litres?)\b',
      caseSensitive: false,
    ).firstMatch(line);

    if (attached != null) {
      final qty = _parseQuantity(attached.group(1)!);
      final unit = _normalizeUnit(attached.group(2)!);
      final itemName = line.substring(attached.end).trim();
      if (qty != null && unit != null && itemName.isNotEmpty) {
        return ParsedIngredientLine(
          itemName: _capitalizeItemName(itemName),
          quantityValue: qty,
          quantityUnit: unit,
          originalLine: originalLine,
        );
      }
    }

    final leading = _leadingQuantity.firstMatch(line);
    if (leading != null) {
      final qty = _parseQuantity(leading.group(1)!.trim());
      var remainder = line.substring(leading.end).trim();

      if (qty != null && remainder.isNotEmpty) {
        final unitMatch = RegExp(
          r'^(x|pcs?|pieces?|cloves?|cups?|tbsp|tsp|tablespoons?|teaspoons?|slices?|bunches?|cans?|packets?|g|grams?|kg|kilograms?|ml|milliliters?|millilitres?|l|liters?|litres?)\b\.?\s*',
          caseSensitive: false,
        ).firstMatch(remainder);

        if (unitMatch != null) {
          final unit = _normalizeUnit(unitMatch.group(1)!);
          remainder = remainder.substring(unitMatch.end).trim();
          if (unit != null && remainder.isNotEmpty) {
            return ParsedIngredientLine(
              itemName: _capitalizeItemName(remainder),
              quantityValue: qty,
              quantityUnit: unit,
              originalLine: originalLine,
            );
          }
        }

        return ParsedIngredientLine(
          itemName: _capitalizeItemName(remainder),
          quantityValue: qty,
          quantityUnit: QuantityUnits.count,
          originalLine: originalLine,
        );
      }
    }

    return ParsedIngredientLine(
      itemName: _capitalizeItemName(line),
      originalLine: originalLine,
    );
  }

  double? _parseQuantity(String raw) {
    var text = raw.trim();
    if (text.isEmpty) return null;

    for (final entry in _unicodeFractions.entries) {
      text = text.replaceAll(entry.key, ' ${entry.value} ');
    }
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(text);
    if (mixed != null) {
      final whole = int.parse(mixed.group(1)!);
      final num = int.parse(mixed.group(2)!);
      final den = int.parse(mixed.group(3)!);
      if (den == 0) return null;
      return whole + num / den;
    }

    final fraction = RegExp(r'^(\d+)/(\d+)$').firstMatch(text);
    if (fraction != null) {
      final num = int.parse(fraction.group(1)!);
      final den = int.parse(fraction.group(2)!);
      if (den == 0) return null;
      return num / den;
    }

    return double.tryParse(text);
  }

  String? _normalizeUnit(String raw) {
    final unit = raw.trim().toLowerCase().replaceAll('.', '');
    if (unit == 'g' || unit == 'gram' || unit == 'grams') return QuantityUnits.g;
    if (unit == 'kg' || unit == 'kilogram' || unit == 'kilograms') {
      return QuantityUnits.kg;
    }
    if (unit == 'ml' || unit == 'milliliter' || unit == 'milliliters' ||
        unit == 'millilitre' || unit == 'millilitres') {
      return QuantityUnits.ml;
    }
    if (unit == 'l' || unit == 'liter' || unit == 'liters' ||
        unit == 'litre' || unit == 'litres') {
      return QuantityUnits.l;
    }
    if (_countUnits.hasMatch(unit)) return QuantityUnits.count;
    if (_weightVolumeUnits.hasMatch(unit)) return _normalizeUnit(unit);
    return null;
  }

  String _capitalizeItemName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed[0].toUpperCase() + trimmed.substring(1);
  }
}

String formatMealIngredient({
  required String displayName,
  double? quantityValue,
  String? quantityUnit,
}) {
  if (quantityValue == null || quantityUnit == null) {
    return displayName;
  }
  final qtyText = formatQuantityValue(quantityValue, quantityUnit);
  return '$qtyText $displayName';
}

String formatQuantityValue(double value, String unit) {
  if (unit == QuantityUnits.count) {
    if (value == value.roundToDouble()) {
      return '×${value.toInt()}';
    }
    return '×$value';
  }
  if (value == value.roundToDouble()) {
    return '${value.toInt()} $unit';
  }
  return '$value $unit';
}

double? scaleQuantity(double? value, double factor) {
  if (value == null) return null;
  return value * factor;
}
