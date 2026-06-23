import 'package:flutter/material.dart';

class RecipeScaleControl extends StatelessWidget {
  const RecipeScaleControl({
    super.key,
    required this.scaleFactor,
    required this.onScaleChanged,
  });

  final double scaleFactor;
  final ValueChanged<double> onScaleChanged;

  String _formatScale(double value) {
    if (value == value.roundToDouble()) {
      return '×${value.toInt()}';
    }
    return '×$value';
  }

  Future<void> _showEditor(BuildContext context) async {
    final controller = TextEditingController(
      text: scaleFactor == scaleFactor.roundToDouble()
          ? scaleFactor.toInt().toString()
          : scaleFactor.toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Recipe scale'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final preset in [0.5, 1.0, 1.5, 2.0])
                    ActionChip(
                      label: Text(_formatScale(preset)),
                      onPressed: () => Navigator.pop(context, preset),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Custom scale',
                  hintText: 'e.g. 1.5',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                if (value != null && value > 0) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );

    controller.dispose();
    if (result != null) {
      onScaleChanged(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDefault = scaleFactor == 1.0;

    return Wrap(
      spacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ActionChip(
          label: Text(_formatScale(scaleFactor)),
          backgroundColor: isDefault
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.secondaryContainer,
          labelStyle: TextStyle(
            color: isDefault
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSecondaryContainer,
            fontWeight: isDefault ? FontWeight.normal : FontWeight.w600,
          ),
          onPressed: () => _showEditor(context),
        ),
        if (!isDefault)
          TextButton(
            onPressed: () => onScaleChanged(1.0),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Reset'),
          ),
      ],
    );
  }
}
