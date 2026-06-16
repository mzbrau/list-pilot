import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../data/database/app_database.dart';

class MealDetailStepsTab extends ConsumerStatefulWidget {
  const MealDetailStepsTab({
    super.key,
    required this.mealId,
    required this.isEditing,
    this.draftSteps,
    this.onDraftStepsChanged,
  });

  final int? mealId;
  final bool isEditing;
  final List<String>? draftSteps;
  final ValueChanged<List<String>>? onDraftStepsChanged;

  @override
  ConsumerState<MealDetailStepsTab> createState() =>
      MealDetailStepsTabState();
}

class MealDetailStepsTabState extends ConsumerState<MealDetailStepsTab> {
  final _editableListKey = GlobalKey<_EditableStepsListState>();

  Future<void> savePendingChanges() async {
    await _editableListKey.currentState?.saveAllSteps();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.mealId == null) {
      return _DraftStepsEditor(
        steps: widget.draftSteps ?? [],
        isEditing: widget.isEditing,
        onChanged: widget.onDraftStepsChanged ?? (_) {},
      );
    }

    final stepsAsync = ref.watch(mealStepsProvider(widget.mealId!));

    return stepsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (steps) {
        if (!widget.isEditing) {
          if (steps.isEmpty) {
            return Center(
              child: Text(
                'No steps yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: steps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final step = steps[index];
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    child: Text('${index + 1}'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.instruction,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              );
            },
          );
        }

        return _EditableStepsList(
          key: _editableListKey,
          mealId: widget.mealId!,
          steps: steps,
        );
      },
    );
  }
}

class _EditableStepsList extends ConsumerStatefulWidget {
  const _EditableStepsList({
    super.key,
    required this.mealId,
    required this.steps,
  });

  final int mealId;
  final List<MealStep> steps;

  @override
  ConsumerState<_EditableStepsList> createState() =>
      _EditableStepsListState();
}

class _EditableStepsListState extends ConsumerState<_EditableStepsList> {
  late List<MealStep> _steps;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _steps = List.of(widget.steps);
    _syncControllers();
  }

  @override
  void didUpdateWidget(_EditableStepsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.steps != widget.steps) {
      _steps = List.of(widget.steps);
      _syncControllers();
    }
  }

  void _syncControllers() {
    for (final step in _steps) {
      _controllers.putIfAbsent(
        step.id,
        () => TextEditingController(text: step.instruction),
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _persistOrder() async {
    await ref.read(mealRepositoryProvider).reorderSteps(
          widget.mealId,
          _steps.map((s) => s.id).toList(),
        );
  }

  Future<void> _addStep() async {
    await ref.read(mealRepositoryProvider).addStep(
          mealId: widget.mealId,
          instruction: 'New step',
        );
  }

  Future<void> saveAllSteps() async {
    final repo = ref.read(mealRepositoryProvider);
    for (final step in _steps) {
      final text = _controllers[step.id]?.text.trim() ?? step.instruction;
      if (text.isEmpty) continue;
      await repo.updateStep(id: step.id, instruction: text);
    }
    await _persistOrder();
  }

  Future<void> _saveStep(MealStep step) async {
    final text = _controllers[step.id]?.text.trim() ?? step.instruction;
    if (text.isEmpty) return;
    await ref.read(mealRepositoryProvider).updateStep(
          id: step.id,
          instruction: text,
        );
  }

  Future<void> _deleteStep(MealStep step) async {
    _controllers.remove(step.id)?.dispose();
    await ref.read(mealRepositoryProvider).deleteStep(step.id);
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return Column(
        children: [
          const Expanded(
            child: Center(child: Text('No steps yet')),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              label: const Text('Add step'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _steps.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = _steps.removeAt(oldIndex);
                _steps.insert(newIndex, item);
              });
              _persistOrder();
            },
            itemBuilder: (context, index) {
              final step = _steps[index];
              final controller = _controllers[step.id]!;
              return Card(
                key: ValueKey(step.id),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Step ${index + 1}',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _saveStep(step),
                    onEditingComplete: () => _saveStep(step),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteStep(step),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: _addStep,
            icon: const Icon(Icons.add),
            label: const Text('Add step'),
          ),
        ),
      ],
    );
  }
}

class _DraftStepsEditor extends StatefulWidget {
  const _DraftStepsEditor({
    required this.steps,
    required this.isEditing,
    required this.onChanged,
  });

  final List<String> steps;
  final bool isEditing;
  final ValueChanged<List<String>> onChanged;

  @override
  State<_DraftStepsEditor> createState() => _DraftStepsEditorState();
}

class _DraftStepsEditorState extends State<_DraftStepsEditor> {
  void _updateStep(int index, String value) {
    final list = List<String>.from(widget.steps);
    list[index] = value;
    widget.onChanged(list);
  }

  void _deleteStep(int index) {
    final list = List<String>.from(widget.steps)..removeAt(index);
    widget.onChanged(list);
  }

  void _addStep() {
    widget.onChanged([...widget.steps, 'New step']);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!widget.isEditing && widget.steps.isEmpty) {
      return Center(
        child: Text(
          'No steps yet',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: widget.steps.length,
            itemBuilder: (context, index) {
              final step = widget.steps[index];
              if (!widget.isEditing) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        child: Text('${index + 1}'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(step, style: theme.textTheme.bodyLarge)),
                    ],
                  ),
                );
              }
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: TextFormField(
                    initialValue: step,
                    decoration: InputDecoration(
                      labelText: 'Step ${index + 1}',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    onChanged: (value) => _updateStep(index, value),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteStep(index),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.isEditing)
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              onPressed: _addStep,
              icon: const Icon(Icons.add),
              label: const Text('Add step'),
            ),
          ),
      ],
    );
  }
}
