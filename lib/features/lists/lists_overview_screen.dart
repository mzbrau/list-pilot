import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';

class ListsOverviewScreen extends ConsumerWidget {
  const ListsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(shoppingListsProvider);
    final shopStatsEnabled = ref.watch(shopStatsEnabledProvider);
    final mealManagerEnabled = ref.watch(mealManagerEnabledProvider);
    final mealPlanningEnabled = ref.watch(mealPlanningEnabledProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('List Pilot'),
        actions: [
          if (mealManagerEnabled)
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Meal Manager',
              onPressed: () => context.push('/meal-manager'),
            ),
          if (mealPlanningEnabled)
            IconButton(
              icon: const Icon(Icons.restaurant_menu_outlined),
              tooltip: 'Meal Planning',
              onPressed: () => context.push('/meals'),
            ),
          if (shopStatsEnabled)
            IconButton(
              icon: const Icon(Icons.bar_chart_outlined),
              tooltip: 'Shop Stats',
              onPressed: () => context.push('/stats'),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => _showSettingsSheet(context, ref),
          ),
        ],
      ),
      body: listsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (lists) {
          if (lists.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _MealFeatureCards(
                  mealManagerEnabled: mealManagerEnabled,
                  mealPlanningEnabled: mealPlanningEnabled,
                ),
                const SizedBox(height: 24),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No shopping lists yet',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create a list for each store you visit',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealFeatureCards(
                    mealManagerEnabled: mealManagerEnabled,
                    mealPlanningEnabled: mealPlanningEnabled,
                  ),
                );
              }
              final list = lists[index - 1];
              return _ListCard(list: list);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createList(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New list'),
      ),
    );
  }

  Future<void> _createList(BuildContext context, WidgetRef ref) async {
    final name = await _showNameDialog(context, title: 'New list');
    if (name == null || name.trim().isEmpty) return;

    final id = await ref.read(listRepositoryProvider).createList(name);
    if (context.mounted) context.push('/list/$id');
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return _SettingsSheet(
          onExportCatalog: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              final result =
                  await ref.read(catalogExportServiceProvider).exportToFile();
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (!context.mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Exported ${result.customItemCount} custom and '
                    '${result.recategorizedItemCount} recategorized items to '
                    '${result.displayLocation}',
                  ),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              messenger.showSnackBar(
                SnackBar(content: Text('Export failed: $e')),
              );
            }
          },
          onExportMeals: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              final result =
                  await ref.read(mealExportServiceProvider).exportToFile();
              if (sheetContext.mounted) Navigator.pop(sheetContext);
              if (!context.mounted) return;
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    'Exported ${result.mealCount} meals and '
                    '${result.checkOffCount} history entries to '
                    '${result.displayLocation}',
                  ),
                ),
              );
            } catch (e) {
              if (!context.mounted) return;
              messenger.showSnackBar(
                SnackBar(content: Text('Export failed: $e')),
              );
            }
          },
        );
      },
    );
  }
}

class _SettingsSheet extends ConsumerStatefulWidget {
  const _SettingsSheet({
    required this.onExportCatalog,
    required this.onExportMeals,
  });

  final Future<void> Function() onExportCatalog;
  final Future<void> Function() onExportMeals;

  @override
  ConsumerState<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<_SettingsSheet> {
  bool _exportingCatalog = false;
  bool _exportingMeals = false;
  late final TextEditingController _aiUriController;
  late final TextEditingController _aiKeyController;
  late final TextEditingController _aiModelController;
  bool _aiFieldsInitialized = false;

  @override
  void initState() {
    super.initState();
    _aiUriController = TextEditingController();
    _aiKeyController = TextEditingController();
    _aiModelController = TextEditingController();
  }

  @override
  void dispose() {
    _aiUriController.dispose();
    _aiKeyController.dispose();
    _aiModelController.dispose();
    super.dispose();
  }

  void _initAiFields(AiConfig config) {
    if (_aiFieldsInitialized) return;
    _aiFieldsInitialized = true;
    _aiUriController.text = config.apiUri ?? '';
    _aiKeyController.text = config.apiKey ?? '';
    _aiModelController.text = config.modelName ?? '';
  }

  Future<void> _saveAiConfig() async {
    await ref.read(aiConfigProvider.notifier).update(
          apiUri: _aiUriController.text.trim(),
          apiKey: _aiKeyController.text.trim(),
          modelName: _aiModelController.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI settings saved')),
      );
    }
  }

  Future<void> _handleExportCatalog() async {
    if (_exportingCatalog) return;
    setState(() => _exportingCatalog = true);
    try {
      await widget.onExportCatalog();
    } finally {
      if (mounted) setState(() => _exportingCatalog = false);
    }
  }

  Future<void> _handleExportMeals() async {
    if (_exportingMeals) return;
    setState(() => _exportingMeals = true);
    try {
      await widget.onExportMeals();
    } finally {
      if (mounted) setState(() => _exportingMeals = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final versionAsync = ref.watch(appVersionProvider);
    final shopStatsEnabled = ref.watch(shopStatsEnabledProvider);
    final mealManagerEnabled = ref.watch(mealManagerEnabledProvider);
    final mealPlanningEnabled = ref.watch(mealPlanningEnabledProvider);
    final aiConfig = ref.watch(aiConfigProvider);
    final listsAsync = ref.watch(shoppingListsProvider);
    final defaultListId = ref.watch(defaultShoppingListIdProvider);
    final theme = Theme.of(context);
    _initAiFields(aiConfig);

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Appearance',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.brightness_auto),
            title: const Text('System'),
            onTap: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.light_mode),
            title: const Text('Light'),
            onTap: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark'),
            onTap: () {
              ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);
              Navigator.pop(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Features',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.timer_outlined),
            title: const Text('Shop Stats'),
            subtitle: const Text('Time your shops and compare to past trips'),
            value: shopStatsEnabled,
            onChanged: (value) {
              ref.read(shopStatsEnabledProvider.notifier).setEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.menu_book_outlined),
            title: const Text('Meal Manager'),
            subtitle: const Text('Browse and create recipes'),
            value: mealManagerEnabled,
            onChanged: (value) {
              ref.read(mealManagerEnabledProvider.notifier).setEnabled(value);
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.restaurant_menu_outlined),
            title: const Text('Meal Planning'),
            subtitle: const Text('Plan meals and fill your shopping list'),
            value: mealPlanningEnabled,
            onChanged: (value) {
              ref.read(mealPlanningEnabledProvider.notifier).setEnabled(value);
            },
          ),
          if (mealManagerEnabled) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'AI Import',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OpenAI-compatible API for importing recipes from webpages '
                '(uses /chat/completions).',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _aiUriController,
                decoration: const InputDecoration(
                  labelText: 'API URI',
                  hintText: 'https://api.openai.com/v1',
                ),
                keyboardType: TextInputType.url,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _aiKeyController,
                decoration: const InputDecoration(labelText: 'API Key'),
                obscureText: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _aiModelController,
                decoration: const InputDecoration(
                  labelText: 'Model name',
                  hintText: 'gpt-4o-mini',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _saveAiConfig,
                  child: const Text('Save AI settings'),
                ),
              ),
            ),
          ],
          if (mealPlanningEnabled) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Meal Planning',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          listsAsync.when(
            loading: () => const ListTile(
              title: Text('Default shopping list'),
              subtitle: Text('Loading lists…'),
            ),
            error: (e, _) => ListTile(
              title: const Text('Default shopping list'),
              subtitle: Text('Error: $e'),
            ),
            data: (lists) {
              if (lists.isEmpty) {
                return const ListTile(
                  leading: Icon(Icons.shopping_cart_outlined),
                  title: Text('Default shopping list'),
                  subtitle: Text('Create a shopping list first'),
                  enabled: false,
                );
              }
              return ListTile(
                leading: const Icon(Icons.shopping_cart_outlined),
                title: const Text('Default shopping list'),
                subtitle: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: lists.any((l) => l.id == defaultListId)
                        ? defaultListId
                        : null,
                    hint: const Text('Select a list'),
                    items: [
                      for (final list in lists)
                        DropdownMenuItem(
                          value: list.id,
                          child: Text(list.name),
                        ),
                    ],
                    onChanged: (value) {
                      ref
                          .read(defaultShoppingListIdProvider.notifier)
                          .setListId(value);
                    },
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: _exportingMeals
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.download_outlined),
            title: const Text('Export meals'),
            subtitle: const Text('Save meals and eat history as JSON'),
            enabled: !_exportingMeals,
            onTap: _handleExportMeals,
          ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Catalog',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading: _exportingCatalog
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.download_outlined),
            title: const Text('Export custom catalog'),
            subtitle: const Text(
              'Save custom and recategorized items as JSON',
            ),
            enabled: !_exportingCatalog,
            onTap: _handleExportCatalog,
          ),
          versionAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (info) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                'Version ${info.version} (${info.buildNumber})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _MealFeatureCards extends StatelessWidget {
  const _MealFeatureCards({
    required this.mealManagerEnabled,
    required this.mealPlanningEnabled,
  });

  final bool mealManagerEnabled;
  final bool mealPlanningEnabled;

  @override
  Widget build(BuildContext context) {
    if (!mealManagerEnabled && !mealPlanningEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        if (mealManagerEnabled) ...[
          const _MealManagerCard(),
          if (mealPlanningEnabled) const SizedBox(height: 12),
        ],
        if (mealPlanningEnabled) const _MealPlanningCard(),
      ],
    );
  }
}

class _MealManagerCard extends StatelessWidget {
  const _MealManagerCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/meal-manager'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.tertiaryContainer,
                child: Icon(
                  Icons.menu_book_outlined,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Manager',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create and browse your recipes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealPlanningCard extends StatelessWidget {
  const _MealPlanningCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/meals'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.secondaryContainer,
                child: Icon(
                  Icons.restaurant_menu_outlined,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Meal Planning',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Plan your week and fill your shopping list',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListCard extends ConsumerWidget {
  const _ListCard({required this.list});

  final ShoppingList list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.MMMd().add_jm();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.push('/list/${list.id}'),
        onLongPress: () => _showListOptions(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.store_outlined,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      list.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Updated ${dateFormat.format(list.updatedAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showListOptions(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () => Navigator.pop(context, 'rename'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || action == null) return;

    if (action == 'rename') {
      final name = await _showNameDialog(
        context,
        title: 'Rename list',
        initialValue: list.name,
      );
      if (name != null && name.trim().isNotEmpty) {
        await ref.read(listRepositoryProvider).renameList(list.id, name);
      }
    } else if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete list?'),
          content: Text('Delete "${list.name}" and all its items?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await ref.read(listRepositoryProvider).deleteList(list.id);
      }
    }
  }
}

Future<String?> _showNameDialog(
  BuildContext context, {
  required String title,
  String? initialValue,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'List name'),
        textCapitalization: TextCapitalization.sentences,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
