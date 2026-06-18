import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../data/repositories/take_away_repository.dart';
import '../../data/services/menu_import_service.dart';
import '../../router/navigation_helpers.dart';

class _DraftMenuItem {
  _DraftMenuItem({
    this.itemNumber,
    required this.name,
    required this.priceDisplay,
    this.priceAmount,
  });

  String? itemNumber;
  String name;
  String priceDisplay;
  double? priceAmount;
}

class TakeAwayMenuImportScreen extends ConsumerStatefulWidget {
  const TakeAwayMenuImportScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<TakeAwayMenuImportScreen> createState() =>
      _TakeAwayMenuImportScreenState();
}

class _TakeAwayMenuImportScreenState
    extends ConsumerState<TakeAwayMenuImportScreen> {
  final _urlController = TextEditingController();
  final _restaurantController = TextEditingController();
  final _locationController = TextEditingController();
  final _mapsController = TextEditingController();
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _currencyController = TextEditingController();

  bool _importing = false;
  bool _saving = false;
  bool _hasPreview = false;
  List<_DraftMenuItem> _items = [];

  @override
  void dispose() {
    _urlController.dispose();
    _restaurantController.dispose();
    _locationController.dispose();
    _mapsController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _currencyController.dispose();
    super.dispose();
  }

  Future<void> _import() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _importing = true);
    try {
      final language = ref.read(menuImportLanguageProvider);
      final result = await ref.read(menuImportServiceProvider).importFromUrl(
            url,
            language: language,
          );
      setState(() {
        _hasPreview = true;
        _restaurantController.text = result.restaurantName;
        _locationController.text = result.location ?? '';
        _mapsController.text = result.mapsUrl ?? '';
        _websiteController.text = result.website ?? '';
        _phoneController.text = result.phone ?? '';
        _currencyController.text = result.currency ?? '';
        _items = result.items
            .map(
              (item) => _DraftMenuItem(
                itemNumber: item.itemNumber,
                name: item.name,
                priceDisplay: item.priceDisplay,
                priceAmount: item.priceAmount,
              ),
            )
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _save() async {
    final name = _restaurantController.text.trim();
    if (name.isEmpty) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one menu item')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final menuId = await ref.read(takeAwayRepositoryProvider).createMenuFromImport(
            listId: widget.listId,
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
            menuUrl: _urlController.text.trim().isEmpty
                ? null
                : _urlController.text.trim(),
            currency: _currencyController.text.trim().isEmpty
                ? null
                : _currencyController.text.trim(),
            items: _items
                .map(
                  (item) => TakeAwayMenuItemDraft(
                    itemNumber: item.itemNumber?.trim().isEmpty == true
                        ? null
                        : item.itemNumber?.trim(),
                    name: item.name.trim(),
                    priceDisplay: item.priceDisplay.trim(),
                    priceAmount: item.priceAmount,
                  ),
                )
                .where((item) => item.name.isNotEmpty)
                .toList(),
            finalize: true,
          );
      if (mounted) {
        context.pop();
        context.push('/take-away/${widget.listId}/menu/$menuId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addItem() {
    setState(() {
      _items.add(_DraftMenuItem(name: '', priceDisplay: ''));
    });
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  double? _parsePriceAmount(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^\d.,]'), '').replaceAll(',', '.');
    return double.tryParse(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language = ref.watch(menuImportLanguageProvider);

    return popOrGoHomeScope(
      child: Scaffold(
        appBar: AppBar(
          leading: overviewBackButton(context),
          title: const Text('Import menu'),
          actions: [
            if (_hasPreview)
              TextButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'Menu URL',
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
              autocorrect: false,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: language.code,
              decoration: const InputDecoration(labelText: 'Language'),
              items: menuImportLanguages
                  .map(
                    (lang) => DropdownMenuItem(
                      value: lang.code,
                      child: Text(lang.label),
                    ),
                  )
                  .toList(),
              onChanged: (code) {
                if (code != null) {
                  ref.read(menuImportLanguageProvider.notifier).setLanguage(
                        menuImportLanguageByCode(code),
                      );
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _importing ? null : _import,
              icon: _importing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_outlined),
              label: Text(_importing ? 'Importing…' : 'Import with AI'),
            ),
            if (_hasPreview) ...[
              const SizedBox(height: 24),
              Text('Restaurant details', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
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
                  Text('Menu items (${_items.length})',
                      style: theme.textTheme.titleMedium),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(_items.length, (index) {
                final item = _items[index];
                return Card(
                  key: ValueKey('import-item-$index-${item.name}'),
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
                                decoration:
                                    const InputDecoration(labelText: 'No.'),
                                onChanged: (v) => item.itemNumber = v,
                              ),
                            ),
                            IconButton(
                              onPressed: () => _removeItem(index),
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
                          decoration:
                              const InputDecoration(labelText: 'Price'),
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
          ],
        ),
      ),
    );
  }
}
