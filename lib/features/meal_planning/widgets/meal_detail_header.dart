import 'dart:io';

import 'package:flutter/material.dart';

import 'meal_photo_thumbnail.dart';

class MealDetailHeader extends StatelessWidget {
  const MealDetailHeader({
    super.key,
    required this.displayName,
    required this.photoPath,
    this.photoFile,
    this.lastEatenSummary,
    required this.isEditing,
    required this.nameController,
    this.onPhotoTap,
  });

  final String displayName;
  final String? photoPath;
  final File? photoFile;
  final String? lastEatenSummary;
  final bool isEditing;
  final TextEditingController nameController;
  final VoidCallback? onPhotoTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MealPhotoDisplay(
          photoPath: photoPath,
          photoFile: photoFile,
          onTap: isEditing ? onPhotoTap : null,
        ),
        const SizedBox(height: 16),
        if (isEditing)
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            textCapitalization: TextCapitalization.sentences,
            style: theme.textTheme.headlineSmall,
          )
        else
          Text(
            displayName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        if (lastEatenSummary != null) ...[
          const SizedBox(height: 8),
          Text(
            lastEatenSummary!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
