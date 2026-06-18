import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/core/constants/app_constants.dart';
import 'package:list_pilot/data/services/ingredient_parser_service.dart';

void main() {
  const parser = IngredientParserService();

  group('IngredientParserService', () {
    test('parses attached weight unit', () {
      final result = parser.parse('750g potatoes');
      expect(result.quantityValue, 750);
      expect(result.quantityUnit, QuantityUnits.g);
      expect(result.itemName, 'Potatoes');
    });

    test('parses spaced weight unit', () {
      final result = parser.parse('500 g chicken breast');
      expect(result.quantityValue, 500);
      expect(result.quantityUnit, QuantityUnits.g);
      expect(result.itemName, 'Chicken breast');
    });

    test('parses count with unit word', () {
      final result = parser.parse('2 cups flour');
      expect(result.quantityValue, 2);
      expect(result.quantityUnit, QuantityUnits.count);
      expect(result.itemName, 'Flour');
    });

    test('parses fraction quantity', () {
      final result = parser.parse('1/2 onion');
      expect(result.quantityValue, 0.5);
      expect(result.quantityUnit, QuantityUnits.count);
      expect(result.itemName, 'Onion');
    });

    test('parses mixed fraction', () {
      final result = parser.parse('1 1/2 tbsp olive oil');
      expect(result.quantityValue, 1.5);
      expect(result.quantityUnit, QuantityUnits.count);
      expect(result.itemName, 'Olive oil');
    });

    test('parses x count', () {
      final result = parser.parse('1 x egg');
      expect(result.quantityValue, 1);
      expect(result.quantityUnit, QuantityUnits.count);
      expect(result.itemName, 'Egg');
    });

    test('parses line without quantity', () {
      final result = parser.parse('salt and pepper');
      expect(result.quantityValue, isNull);
      expect(result.quantityUnit, isNull);
      expect(result.itemName, 'Salt and pepper');
    });

    test('strips leading bullets', () {
      final result = parser.parse('• 750g potatoes');
      expect(result.quantityValue, 750);
      expect(result.itemName, 'Potatoes');
    });

    test('parses kg unit', () {
      final result = parser.parse('2kg potatoes');
      expect(result.quantityValue, 2);
      expect(result.quantityUnit, QuantityUnits.kg);
      expect(result.itemName, 'Potatoes');
    });
  });

  group('formatMealIngredient', () {
    test('formats with quantity', () {
      expect(
        formatMealIngredient(
          displayName: 'Potatoes',
          quantityValue: 750,
          quantityUnit: QuantityUnits.g,
        ),
        '750 g Potatoes',
      );
    });

    test('formats without quantity', () {
      expect(
        formatMealIngredient(displayName: 'Salt'),
        'Salt',
      );
    });
  });

  group('scaleQuantity', () {
    test('scales value', () {
      expect(scaleQuantity(750, 1.5), 1125);
    });

    test('returns null for null input', () {
      expect(scaleQuantity(null, 2), isNull);
    });
  });
}
