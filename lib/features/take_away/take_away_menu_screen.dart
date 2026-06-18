import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/providers/app_providers.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/take_away_repository.dart';
import '../../router/navigation_helpers.dart';
import 'widgets/take_away_menu_item_tile.dart';

class _EditableMenuItem {
  _EditableMenuItem({
    this.id,
    this.itemNumber,
    required this.name,
    required this.priceDisplay,
    this.priceAmount,
  });

  final int? id;
  String? itemNumber;
  String name;
  String priceDisplay;
  double? priceAmount;
}

class TakeAwayMenuScreen extends ConsumerStatefulWidget {
  const TakeAwayMenuScreen({
    super.key,
    required this.listId,
    required this.menuId,
  });

  final int listId;
  final int menuId;

  @override
  ConsumerState<TakeAwayMenuScreen> createState() => _TakeAwayMenuScreenState();
}

class _TakeAwayMenuScreenState extends ConsumerState<TakeAwayMenuScreen> {
  bool _isEditing = false;
  bool _saving = false;

  final _restaurantController = TextEditingController();
  final _locationController = TextEditingController();
  final _mapsController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currencyController = TextEditingController();
  List<_EditableMenuItem> _editItems = [];

  @override
  void dispose() {
    _restaurantController.dispose();
    _locationController.dispose();
    _mapsController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  void _startEditing(TakeAwayMenu menu, List<TakeAwayMenuItem> items) {
    setState(() {
      _isEditing = true;
      _restaurantController.text = menu.restaurantName;
      _locationController.text = menu.location ?? '';
      _mapsController.text = menu.mapsUrl ?? '';
      _websiteController.text = menu.website ?? '';
      _phoneController.text = menu.phone ?? '';
      _currencyController.text = menu.currency ?? '';
      _editItems = items
          .map(
            (item) => _EditableMenuItem(
              id: item.id,
              itemNumber: item.itemNumber,
              name: item.name,
              priceDisplay: item.priceDisplay,
              priceAmount: item.priceAmount,
            ),
          )
          .toList();
    });
    ref.read(takeAwayRepositoryProvider).setMenuEditing(widget.menuId);
  }

  Future<void> _cancelEditing() async {
    await ref.read(takeAwayRepositoryProvider).finalizeMenu(widget.menuId);
    if (mounted) setState(() => _isEditing = false);
  }

  Future<void> _saveEditing() async {
    final name = _restaurantController.text.trim();
    if (name.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(takeAwayRepositoryProvider).updateMenu(
            menuId: widget.menuId,
            restaurantName: name,
            location: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            mapsUrl: _mapsController.text.trim().isEmpty
                ? null
                : _mapsController.text.trim(),
            website: _websiteController.text.trim().isEmpty
                ? null
                : _websiteController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            menuUrl: null,
            currency: _currencyController.text.trim().isEmpty
                ? null
                : _currencyController.text.trim(),
          );
      await ref.read(takeAwayRepositoryProvider).replaceMenuItems(
            widget.menuId,
            _editItems
                .where((item) => item.name.trim().isNotEmpty)
                .map(
                  (item) => TakeAwayMenuItemDraft(
                    itemNumber: item.itemNumber?.trim().isEmpty == true
                        ? null
                        : item.itemNumber?.trim(),
                    name: item.name.trim(),
                    priceDisplay: item.priceDisplay.trim().isEmpty
                        ? '—'
                        : item.priceDisplay.trim(),
                    priceAmount: item.priceAmount,
                  ),
                )
                .toList(),
          );
      await ref.read(takeAwayRepositoryProvider).finalizeMenu(widget.menuId);
      if (mounted) setState(() => _isEditing = false);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _launchUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchPhone(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    await launchUrl(uri);
  }

  double? _parsePriceAmount(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final menuAsync = ref.watch(takeAwayMenuProvider(widget.menuId));
    final itemsAsync = ref.watch(takeAwayMenuItemsProvider(widget.menuId));
    final orderAsync = ref.watch(takeAwayOrderProvider(widget.menuId));
    final theme = Theme.of(context);
    final lineCount = orderAsync.valueOrNull?.lines.length ?? 0;

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: overviewBackButton(context),
          title: menuAsync.when(
            data: (menu) => Text(menu?.restaurantName ?? 'Menu'),
            loading: () => const Text('Menu'),
            error: (_, __) => const Text('Menu'),
          ),
          actions: [
            if (!_isEditing)
              TextButton.icon(
                onPressed: () =>
                    context.push('/take-away/${widget.listId}/menu/${widget.menuId}/order'),
                icon: Badge(
                  isLabelVisible: lineCount > 0,
                  label: Text('$lineCount'),
                  child: const Icon(Icons.shopping_bag_outlined, size: 20),
                ),
                label: const Text('Order'),
              ),
            if (_isEditing) ...[
              TextButton(
                onPressed: _saving ? null : _cancelEditing,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _saving ? null : _saveEditing,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ] else
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit menu',
                onPressed: () {
                  final menu = menuAsync.valueOrNull;
                  final items = itemsAsync.valueOrNull;
                  if (menu != null && items != null) {
                    _startEditing(menu, items);
                  }
                },
              ),
          ],
        ),
        body: menuAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (menu) {
            if (menu == null) {
              return const Center(child: Text('Menu not found'));
            }
            return itemsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (items) {
                if (_isEditing) {
                  return _buildEditingBody(theme);
                }
                return _buildReadOnlyBody(context, theme, menu, items);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildReadOnlyBody(
    BuildContext context,
    ThemeData theme,
    TakeAwayMenu menu,
    List<TakeAwayMenuItem> items,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.restaurantName,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (menu.location != null && menu.location!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: menu.mapsUrl != null
                            ? () => _launchUrl(menu.mapsUrl)
                            : null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                menu.location!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: menu.mapsUrl != null
                                      ? theme.colorScheme.primary
                                      : null,
                                  decoration: menu.mapsUrl != null
                                      ? TextDecoration.underline
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (menu.website != null && menu.website!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl(menu.website),
                        child: Row(
                          children: [
                            Icon(
                              Icons.language_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                menu.website!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  decoration: TextDecoration.underline,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (menu.phone != null && menu.phone!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchPhone(menu.phone),
                        child: Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              menu.phone!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return TakeAwayMenuItemTile(
                item: item,
                readOnly: true,
                onAdd: () => ref
                    .read(takeAwayRepositoryProvider)
                    .addOrIncrementLine(widget.menuId, item.id),
              );
            },
            childCount: items.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildEditingBody(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _restaurantController,
          decoration: const InputDecoration(labelText: 'Restaurant name'),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(labelText: 'Location'),
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _mapsController,
          decoration: const InputDecoration(labelText: 'Google Maps link'),
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _websiteController,
          decoration: const InputDecoration(labelText: 'Website'),
          keyboardType: TextInputType.url,
          autocorrect: false,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _currencyController,
          decoration: const InputDecoration(labelText: 'Currency'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Text('Menu items', style: theme.textTheme.titleMedium),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _editItems.add(_EditableMenuItem(name: '', priceDisplay: ''));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add item'),
            ),
          ],
        ),
        ...List.generate(_editItems.length, (index) {
          final item = _editItems[index];
          return Card(
            key: ValueKey(item.id ?? 'new-$index'),
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: item.itemNumber,
                          decoration: const InputDecoration(labelText: 'No.'),
                          onChanged: (v) => item.itemNumber = v,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() => _editItems.removeAt(index));
                        },
                        icon: const Icon(Icons.delete_outline),
                        color: theme.colorScheme.error,
                      ),
                    ],
                  ),
                  TextFormField(
                    initialValue: item.name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (v) => item.name = v,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: item.priceDisplay,
                    decoration: const InputDecoration(labelText: 'Price'),
                    onChanged: (v) {
                      item.priceDisplay = v;
                      item.priceAmount = _parsePriceAmount(v);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
