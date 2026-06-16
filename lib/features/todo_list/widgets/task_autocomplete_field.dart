import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/services/todo_section_service.dart';

class TaskAutocompleteField extends ConsumerStatefulWidget {
  const TaskAutocompleteField({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<TaskAutocompleteField> createState() =>
      _TaskAutocompleteFieldState();
}

class _TaskAutocompleteFieldState extends ConsumerState<TaskAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<String> _suggestions = [];
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
        final results = await ref
            .read(todoRepositoryProvider)
            .searchTaskTitles(widget.listId, query);
        if (mounted) {
          setState(() {
            _suggestions = results;
            _showSuggestions = _focusNode.hasFocus;
          });
        }
      },
    );
  }

  Future<void> _submit({String? suggestion}) async {
    final text = suggestion ?? _controller.text.trim();
    if (text.isEmpty) return;

    await ref.read(todoRepositoryProvider).addTask(
          listId: widget.listId,
          displayName: text,
          scheduledDate: TodoSectionService.startOfDay(DateTime.now()),
        );

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
            hintText: 'Add a task…',
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
                  final title = _suggestions[index];
                  return ListTile(
                    dense: true,
                    title: _highlightMatch(title, _controller.text),
                    subtitle: Text(
                      'Previous task',
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () => _submit(suggestion: title),
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
