import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';
import '../../meal_planning/widgets/meal_photo_thumbnail.dart';

class MealManagerListTile extends ConsumerWidget {
  const MealManagerListTile({
    super.key,
    required this.meal,
    required this.onTap,
    this.onAddToPlan,
  });

  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback? onAddToPlan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tagsAsync = ref.watch(mealTagsProvider(meal.id));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              MealPhotoThumbnail(meal: meal),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.displayName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    tagsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (tags) {
                        if (tags.isEmpty) return const SizedBox.shrink();
                        final visible = tags.take(3).toList();
                        final overflow = tags.length - visible.length;
                        return Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            ...visible.map(
                              (tag) => Chip(
                                label: Text(tag.displayName),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                padding: EdgeInsets.zero,
                                labelPadding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                              ),
                            ),
                            if (overflow > 0)
                              Text(
                                '+$overflow',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (onAddToPlan != null)
                IconButton(
                  icon: const Icon(Icons.playlist_add_outlined),
                  tooltip: 'Add to meal plan',
                  onPressed: onAddToPlan,
                ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
