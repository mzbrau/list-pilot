import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../meal_planning/widgets/meal_photo_thumbnail.dart';

class MealManagerGridTile extends ConsumerWidget {
  const MealManagerGridTile({
    super.key,
    required this.meal,
    required this.onTap,
    this.onLongPress,
    this.onAddToPlan,
    this.isSelecting = false,
    this.isSelected = false,
  });

  final Meal meal;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onAddToPlan;
  final bool isSelecting;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  MealPhotoThumbnail(
                    meal: meal,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 0,
                    iconSize: 40,
                  ),
                  if (isSelecting)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Material(
                        color: theme.colorScheme.surface.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: Checkbox(
                          value: isSelected,
                          onChanged: (_) => onTap(),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  if (!isSelecting && onAddToPlan != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Material(
                        color: theme.colorScheme.surface.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: IconButton(
                          icon: const Icon(Icons.playlist_add_outlined),
                          tooltip: 'Add to meal plan',
                          visualDensity: VisualDensity.compact,
                          onPressed: onAddToPlan,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                meal.displayName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
