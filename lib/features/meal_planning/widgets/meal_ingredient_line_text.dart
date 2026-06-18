import 'package:flutter/material.dart';

import '../../../data/services/ingredient_parser_service.dart';

class MealIngredientLineText extends StatelessWidget {
  const MealIngredientLineText({
    super.key,
    required this.displayName,
    this.quantityValue,
    this.quantityUnit,
    this.style,
    this.scaledQuantityValue,
  });

  final String displayName;
  final double? quantityValue;
  final String? quantityUnit;
  final TextStyle? style;
  final double? scaledQuantityValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = style ?? theme.textTheme.bodyLarge;
    final qtyValue = scaledQuantityValue ?? quantityValue;

    if (qtyValue == null || quantityUnit == null) {
      return Text(displayName, style: baseStyle);
    }

    final qtyText = formatQuantityValue(qtyValue, quantityUnit!);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: qtyText,
            style: baseStyle?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          TextSpan(text: ' $displayName', style: baseStyle),
        ],
      ),
    );
  }
}
