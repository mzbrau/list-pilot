import 'package:flutter/material.dart';

import '../../../core/utils/list_background_color_utils.dart';

/// Curated pastel palette for list card backgrounds (Material shade 100).
const listBackgroundPalette = <Color>[
  Color(0xFFFFCDD2), // red 100
  Color(0xFFF8BBD0), // pink 100
  Color(0xFFE1BEE7), // purple 100
  Color(0xFFC5CAE9), // indigo 100
  Color(0xFFBBDEFB), // blue 100
  Color(0xFFB2EBF2), // cyan 100
  Color(0xFFB2DFDB), // teal 100
  Color(0xFFC8E6C9), // green 100
  Color(0xFFDCEDC8), // light green 100
  Color(0xFFFFF9C4), // yellow 100
  Color(0xFFFFE0B2), // orange 100
  Color(0xFFD7CCC8), // brown 100
];

/// Dark palette for list card backgrounds (Material shade 700–800).
const listBackgroundDarkPalette = <Color>[
  Color(0xFFD32F2F), // red 700
  Color(0xFFC2185B), // pink 700
  Color(0xFF7B1FA2), // purple 700
  Color(0xFF303F9F), // indigo 700
  Color(0xFF1976D2), // blue 700
  Color(0xFF0097A7), // cyan 700
  Color(0xFF00796B), // teal 700
  Color(0xFF388E3C), // green 700
  Color(0xFF689F38), // light green 700
  Color(0xFFFBC02D), // yellow 700
  Color(0xFFF57C00), // orange 700
  Color(0xFF455A64), // blue grey 700
];

/// Result of an explicit color choice (including clearing to none).
class ListBackgroundColorChoice {
  const ListBackgroundColorChoice(this.colorValue);

  /// `null` means no background color.
  final int? colorValue;
}

/// Shows a bottom sheet with preset color swatches and a "None" option.
///
/// Returns a [ListBackgroundColorChoice] when the user picks a swatch,
/// or `null` if the sheet is dismissed without a selection.
Future<ListBackgroundColorChoice?> showListBackgroundColorPicker(
  BuildContext context, {
  int? currentColor,
}) {
  return showModalBottomSheet<ListBackgroundColorChoice>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ListBackgroundColorPickerSheet(
      currentColor: currentColor,
    ),
  );
}

class _ListBackgroundColorPickerSheet extends StatelessWidget {
  const _ListBackgroundColorPickerSheet({this.currentColor});

  final int? currentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Background color',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose a background color for this list',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ColorSwatch(
                  label: 'None',
                  isSelected: currentColor == null,
                  onTap: () => Navigator.pop(
                    context,
                    const ListBackgroundColorChoice(null),
                  ),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.block,
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Light',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final color in listBackgroundPalette)
                  _ColorSwatch(
                    swatchColor: color,
                    isSelected: currentColor == color.toARGB32(),
                    onTap: () => Navigator.pop(
                      context,
                      ListBackgroundColorChoice(color.toARGB32()),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Dark',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final color in listBackgroundDarkPalette)
                  _ColorSwatch(
                    swatchColor: color,
                    isSelected: currentColor == color.toARGB32(),
                    onTap: () => Navigator.pop(
                      context,
                      ListBackgroundColorChoice(color.toARGB32()),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.isSelected,
    required this.onTap,
    required this.child,
    this.label,
    this.swatchColor,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;
  final String? label;
  final Color? swatchColor;

  @override
  Widget build(BuildContext context) {
    final checkColor = swatchColor != null
        ? listBackgroundTitleColor(swatchColor!)
        : Theme.of(context).colorScheme.primary;
    final borderColor = swatchColor != null
        ? listBackgroundTitleColor(swatchColor!)
        : Theme.of(context).colorScheme.primary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            child,
            if (isSelected)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: borderColor,
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.check,
                  color: checkColor,
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
