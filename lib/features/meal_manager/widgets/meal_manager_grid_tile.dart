import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../meal_planning/widgets/meal_photo_thumbnail.dart';

class MealManagerGridTile extends ConsumerWidget {
  const MealManagerGridTile({
    super.key,
    required this.meal,
    required this.onTap,
  });

  final Meal meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MealPhotoThumbnail(
                meal: meal,
                width: double.infinity,
                height: double.infinity,
                borderRadius: 0,
                iconSize: 40,
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
