import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';

/// Drag-to-reorder aisle categories. Used for first-run onboarding and Settings.
class CategoryOrderScreen extends ConsumerStatefulWidget {
  const CategoryOrderScreen({
    super.key,
    this.isOnboarding = false,
  });

  final bool isOnboarding;

  @override
  ConsumerState<CategoryOrderScreen> createState() =>
      _CategoryOrderScreenState();
}

class _CategoryOrderScreenState extends ConsumerState<CategoryOrderScreen> {
  List<Category>? _ordered;
  bool _saving = false;

  Future<void> _save() async {
    final ordered = _ordered;
    if (ordered == null || _saving) return;

    setState(() => _saving = true);
    try {
      await ref.read(catalogRepositoryProvider).updateCategorySortOrders(
            ordered.map((c) => c.id).toList(),
          );
      if (widget.isOnboarding) {
        await ref
            .read(categoryOrderOnboardingCompleteProvider.notifier)
            .markComplete();
        if (!mounted) return;
        context.go('/');
      } else {
        if (!mounted) return;
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isOnboarding ? 'Your shop path' : 'Reorder categories',
        ),
        automaticallyImplyLeading: !widget.isOnboarding,
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          _ordered ??= List<Category>.from(categories);
          final ordered = _ordered!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Drag categories to match the order you walk through the shop. '
                  'Items within each category are still sorted by what you check off.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                  itemCount: ordered.length,
                  onReorderItem: (oldIndex, newIndex) {
                    setState(() {
                      final item = ordered.removeAt(oldIndex);
                      ordered.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final category = ordered[index];
                    return ListTile(
                      key: ValueKey(category.id),
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      title: Text(category.name),
                      trailing: Text(
                        '${index + 1}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  },
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(widget.isOnboarding ? 'Done' : 'Save'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
