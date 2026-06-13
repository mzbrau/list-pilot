import 'package:flutter/material.dart';

class ListProgressTitle extends StatelessWidget {
  const ListProgressTitle({
    super.key,
    required this.listName,
    required this.remaining,
    required this.total,
  });

  final String listName;
  final int remaining;
  final int total;

  static const double _titleHeight = kToolbarHeight - 16;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (total == 0) {
      return SizedBox(
        height: _titleHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            listName,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return SizedBox(
      height: _titleHeight,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                listName,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$remaining/$total',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
