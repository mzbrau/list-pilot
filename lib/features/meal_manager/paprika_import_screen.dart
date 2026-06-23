import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../data/services/paprika_import_service.dart';

class PaprikaImportScreen extends ConsumerStatefulWidget {
  const PaprikaImportScreen({super.key});

  @override
  ConsumerState<PaprikaImportScreen> createState() =>
      _PaprikaImportScreenState();
}

class _PaprikaImportScreenState extends ConsumerState<PaprikaImportScreen> {
  String? _folderPath;
  bool _importing = false;
  int _progressCurrent = 0;
  int _progressTotal = 0;
  String? _currentFileName;
  PaprikaImportResult? _result;

  Future<void> _pickFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Paprika export folder',
    );
    if (!mounted || path == null) return;
    setState(() {
      _folderPath = path;
      _result = null;
    });
  }

  Future<void> _import() async {
    final folderPath = _folderPath;
    if (folderPath == null || _importing) return;

    setState(() {
      _importing = true;
      _result = null;
      _progressCurrent = 0;
      _progressTotal = 0;
      _currentFileName = null;
    });

    try {
      final result = await ref.read(paprikaImportServiceProvider).importFolder(
            folderPath,
            onProgress: (current, total, fileName) {
              if (!mounted) return;
              setState(() {
                _progressCurrent = current;
                _progressTotal = total;
                _currentFileName = fileName;
              });
            },
          );
      if (!mounted) return;
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _importing = false;
          _currentFileName = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import from Paprika'),
      ),
      body: kIsWeb
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Paprika import is not supported on web. '
                  'Use the mobile or desktop app.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Export your recipes from Paprika as HTML, then choose '
                  'the export folder. You can select the top-level export '
                  'folder or the Recipes subfolder inside it.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _importing ? null : _pickFolder,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Choose folder'),
                ),
                if (_folderPath != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _folderPath!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _folderPath == null || _importing ? null : _import,
                  icon: _importing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.download_outlined),
                  label: Text(_importing ? 'Importing…' : 'Import recipes'),
                ),
                if (_importing) ...[
                  const SizedBox(height: 24),
                  if (_progressTotal > 0) ...[
                    LinearProgressIndicator(
                      value: _progressCurrent / _progressTotal,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$_progressCurrent of $_progressTotal'
                      '${_currentFileName != null ? ' — $_currentFileName' : ''}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else
                    const LinearProgressIndicator(),
                ],
                if (_result != null) ...[
                  const SizedBox(height: 24),
                  _ImportSummaryCard(result: _result!),
                ],
              ],
            ),
    );
  }
}

class _ImportSummaryCard extends StatelessWidget {
  const _ImportSummaryCard({required this.result});

  final PaprikaImportResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Import complete',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('Imported: ${result.imported}'),
            Text('Skipped (already exist): ${result.skipped}'),
            Text('Failed: ${result.failed}'),
            if (result.errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('${result.errors.length} error(s)'),
                children: [
                  for (final error in result.errors)
                    ListTile(
                      dense: true,
                      title: Text(error.fileName),
                      subtitle: Text(error.message),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
