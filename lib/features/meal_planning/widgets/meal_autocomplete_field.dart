import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class MealAutocompleteField extends ConsumerStatefulWidget {
  const MealAutocompleteField({super.key});

  @override
  ConsumerState<MealAutocompleteField> createState() =>
      _MealAutocompleteFieldState();
}

class _MealAutocompleteFieldState extends ConsumerState<MealAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<Meal> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: AppConstants.autocompleteDebounceMs),
      () async {
        final query = _controller.text;
        if (query.trim().isEmpty) {
          if (mounted) setState(() => _suggestions = []);
          return;
        }
        final results =
            await ref.read(mealRepositoryProvider).searchMeals(query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _showSuggestions = _focusNode.hasFocus;
          });
        }
      },
    );
  }

  Future<void> _submit({Meal? meal}) async {
    final repo = ref.read(mealRepositoryProvider);
    final Meal resolved;
    if (meal != null) {
      resolved = meal;
    } else {
      final text = _controller.text.trim();
      if (text.isEmpty) return;
      resolved = await repo.getOrCreateMeal(displayName: text);
    }

    await repo.addMealToPlan(resolved.id);

    _controller.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: 'Add a meal…',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add_circle),
              color: theme.colorScheme.primary,
              onPressed: () => _submit(),
            ),
          ),
          onSubmitted: (_) => _submit(),
          onTap: () => setState(() => _showSuggestions = true),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.surfaceContainerHighest,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant,
                ),
                itemBuilder: (context, index) {
                  final item = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: _highlightMatch(item.displayName, _controller.text),
                    subtitle: Text(
                      item.isUserAdded ? 'Custom meal' : 'Saved meal',
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () => _submit(meal: item),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _highlightMatch(String text, String query) {
    if (query.trim().isEmpty) return Text(text);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.trim().toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    if (index < 0) return Text(text);

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + lowerQuery.length),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text.substring(index + lowerQuery.length)),
        ],
      ),
    );
  }
}
