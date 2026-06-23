import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/services/meal_plan_ai_suggest_service.dart';

class AiMealSuggestOptionsDialog extends ConsumerStatefulWidget {
  const AiMealSuggestOptionsDialog({
    super.key,
    required this.initial,
  });

  final MealPlanAiSuggestOptions initial;

  static Future<MealPlanAiSuggestOptions?> show(
    BuildContext context,
    WidgetRef ref,
  ) {
    final initial = ref.read(mealPlanAiSuggestPrefsProvider);
    return showDialog<MealPlanAiSuggestOptions>(
      context: context,
      builder: (context) => AiMealSuggestOptionsDialog(initial: initial),
    );
  }

  @override
  ConsumerState<AiMealSuggestOptionsDialog> createState() =>
      _AiMealSuggestOptionsDialogState();
}

class _AiMealSuggestOptionsDialogState
    extends ConsumerState<AiMealSuggestOptionsDialog> {
  late final TextEditingController _queryController;
  late bool _prioritizeRecent;
  late bool _offerAlternatives;
  late int _suggestionCount;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initial.query);
    _prioritizeRecent = widget.initial.prioritizeNotMadeRecently;
    _offerAlternatives = widget.initial.offerAlternatives;
    _suggestionCount = widget.initial.suggestionCount;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final catalog =
        await ref.read(mealRepositoryProvider).getMealCatalogForAi();
    if (!mounted) return;
    if (catalog.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add meals to Meal Manager before requesting suggestions.',
          ),
        ),
      );
      return;
    }

    final options = MealPlanAiSuggestOptions(
      query: _queryController.text.trim(),
      prioritizeNotMadeRecently: _prioritizeRecent,
      offerAlternatives: _offerAlternatives,
      suggestionCount: _suggestionCount,
    );
    await ref.read(mealPlanAiSuggestPrefsProvider.notifier).save(options);
    if (!mounted) return;
    Navigator.pop(context, options);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Suggest meals'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: 'What are you looking for?',
                hintText: 'e.g. light dinners, one vegetarian night',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prioritize recipes not made recently'),
              value: _prioritizeRecent,
              onChanged: (value) => setState(() => _prioritizeRecent = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Offer alternatives'),
              subtitle: const Text('Include substitute picks for each suggestion'),
              value: _offerAlternatives,
              onChanged: (value) =>
                  setState(() => _offerAlternatives = value),
            ),
            const SizedBox(height: 8),
            Text(
              'Suggestion count',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: MealPlanAiSuggestOptions.suggestionCountChoices
                  .map(
                    (count) => ButtonSegment<int>(
                      value: count,
                      label: Text('$count'),
                    ),
                  )
                  .toList(),
              selected: {_suggestionCount},
              onSelectionChanged: (selection) {
                setState(() => _suggestionCount = selection.first);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Suggest'),
        ),
      ],
    );
  }
}
