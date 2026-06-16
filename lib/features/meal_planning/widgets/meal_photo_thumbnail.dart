import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class MealPhotoThumbnail extends ConsumerWidget {
  const MealPhotoThumbnail({
    super.key,
    required this.meal,
    this.width = 48,
    this.height = 48,
    this.borderRadius = 8,
    this.iconSize = 24,
  });

  final Meal meal;
  final double width;
  final double height;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (meal.photoPath == null) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          Icons.restaurant_outlined,
          size: iconSize,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return FutureBuilder<File?>(
      future:
          ref.read(mealPhotoServiceProvider).resolvePhotoFile(meal.photoPath),
      builder: (context, snapshot) {
        final file = snapshot.data;
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: file != null
              ? Image.file(
                  file,
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: width,
                  height: height,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.restaurant_outlined,
                    size: iconSize,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        );
      },
    );
  }
}

class MealPhotoDisplay extends ConsumerWidget {
  const MealPhotoDisplay({
    super.key,
    this.photoPath,
    this.photoFile,
    this.onTap,
    this.height = 220,
  });

  final String? photoPath;
  final File? photoFile;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Widget image;
    if (photoFile != null) {
      image = Image.file(photoFile!, width: double.infinity, height: height, fit: BoxFit.cover);
    } else if (photoPath != null) {
      image = FutureBuilder<File?>(
        future: ref.read(mealPhotoServiceProvider).resolvePhotoFile(photoPath),
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (file != null) {
            return Image.file(file, width: double.infinity, height: height, fit: BoxFit.cover);
          }
          return _placeholder(theme, height);
        },
      );
    } else {
      image = _placeholder(theme, height);
    }

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: image,
      ),
    );
  }

  Widget _placeholder(ThemeData theme, double height) {
    return Container(
      width: double.infinity,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.restaurant_outlined,
        size: 64,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
