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
    this.nestedScroll = false,
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
  final bool nestedScroll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final children = [
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
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            recipeLink!,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => _handleRecipeLinkTap(context, recipeLink!),
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
    ];

    if (!nestedScroll) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: children,
      );
    }

    return CustomScrollView(
      key: const PageStorageKey('meal-detail-other'),
      slivers: [
        SliverOverlapInjector(
          handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(children),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRecipeLinkTap(BuildContext context, String link) async {
    final launched = await openRecipeLink(link);
    if (!context.mounted) return;
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open recipe link')),
      );
    }
  }

  static Uri? normalizeRecipeLinkUri(String link) {
    var normalized = link.trim();
    if (normalized.isEmpty) return null;
    if (!normalized.contains('://')) {
      normalized = 'https://$normalized';
    }
    return Uri.tryParse(normalized);
  }

  static Future<bool> openRecipeLink(String link) async {
    final uri = normalizeRecipeLinkUri(link);
    if (uri == null) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}
