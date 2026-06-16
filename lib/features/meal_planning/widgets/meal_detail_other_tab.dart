import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'meal_tag_input.dart';

class MealDetailOtherTab extends StatelessWidget {
  const MealDetailOtherTab({
    super.key,
    required this.isEditing,
    required this.tags,
    required this.onTagsChanged,
    required this.notes,
    required this.portions,
    required this.recipeLink,
    required this.notesController,
    required this.portionsController,
    required this.recipeController,
    this.onRecipeLinkTap,
  });

  final bool isEditing;
  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final String notes;
  final int portions;
  final String? recipeLink;
  final TextEditingController notesController;
  final TextEditingController portionsController;
  final TextEditingController recipeController;
  final VoidCallback? onRecipeLinkTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tags',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        MealTagInput(
          tags: tags,
          onTagsChanged: onTagsChanged,
          enabled: isEditing,
        ),
        const SizedBox(height: 24),
        Text(
          'Notes',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (isEditing)
          TextField(
            controller: notesController,
            decoration: const InputDecoration(hintText: 'Notes'),
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
          )
        else if (notes.isEmpty)
          Text(
            'No notes',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Text(notes, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        Text(
          'Portions',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (isEditing)
          TextField(
            controller: portionsController,
            decoration: const InputDecoration(
              helperText: 'Number of people this meal normally feeds',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          )
        else
          Text(
            '$portions ${portions == 1 ? 'person' : 'people'}',
            style: theme.textTheme.bodyLarge,
          ),
        const SizedBox(height: 24),
        Text(
          'Recipe link',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        if (isEditing)
          TextField(
            controller: recipeController,
            decoration: const InputDecoration(hintText: 'https://…'),
            keyboardType: TextInputType.url,
          )
        else if (recipeLink == null || recipeLink!.isEmpty)
          Text(
            'No link',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          InkWell(
            onTap: onRecipeLinkTap,
            child: Text(
              recipeLink!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
      ],
    );
  }

  static Future<void> openRecipeLink(String link) async {
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
