import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class MealTagInput extends ConsumerStatefulWidget {
  const MealTagInput({
    super.key,
    required this.tags,
    required this.onTagsChanged,
    this.enabled = true,
  });

  final List<String> tags;
  final ValueChanged<List<String>> onTagsChanged;
  final bool enabled;

  @override
  ConsumerState<MealTagInput> createState() => _MealTagInputState();
}

class _MealTagInputState extends ConsumerState<MealTagInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<MealTag> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
            await ref.read(mealRepositoryProvider).searchTags(query);
        if (mounted) {
          setState(() {
            _suggestions = results
                .where((t) => !widget.tags
                    .any((tag) => tag.toLowerCase() == t.name.toLowerCase()))
                .toList();
            _showSuggestions = _focusNode.hasFocus;
          });
        }
      },
    );
  }

  void _addTag(String raw) {
    final tag = raw.trim();
    if (tag.isEmpty) return;
    if (widget.tags.any((t) => t.toLowerCase() == tag.toLowerCase())) return;
    widget.onTagsChanged([...widget.tags, tag]);
    _controller.clear();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
    });
  }

  void _removeTag(String tag) {
    widget.onTagsChanged(
      widget.tags.where((t) => t != tag).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!widget.enabled) {
      if (widget.tags.isEmpty) {
        return Text(
          'No tags',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.tags
            .map((tag) => Chip(label: Text(tag)))
            .toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.tags.map(
              (tag) => InputChip(
                label: Text(tag),
                onDeleted: () => _removeTag(tag),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            hintText: 'Add tag…',
            prefixIcon: Icon(Icons.label_outline),
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: _addTag,
          onTap: () => setState(() => _showSuggestions = true),
        ),
        if (_showSuggestions && _suggestions.isNotEmpty)
          Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(8),
            color: theme.colorScheme.surfaceContainerHighest,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(item.displayName),
                  onTap: () => _addTag(item.displayName),
                );
              },
            ),
          ),
      ],
    );
  }
}
