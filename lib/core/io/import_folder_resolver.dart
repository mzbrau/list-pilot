import 'dart:io';

import 'package:dir_picker/dir_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:saf_stream/saf_stream.dart';

/// A local filesystem folder path that [dart:io] can read.
///
/// On Android, [path] points at a temp copy of a SAF-picked tree.
/// Call [dispose] when finished to remove temporary copies.
class ImportFolderHandle {
  ImportFolderHandle({
    required this.path,
    required this.isTemporary,
    Directory? tempDirectory,
  }) : _tempDirectory = tempDirectory;

  final String path;
  final bool isTemporary;
  final Directory? _tempDirectory;

  Future<void> dispose() async {
    final tempDirectory = _tempDirectory;
    if (!isTemporary || tempDirectory == null) return;
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  }
}

/// Whether [fileName] matches [extensions] and is not in [skipFileNames].
bool isImportableFileName(
  String fileName, {
  required Set<String> extensions,
  Set<String> skipFileNames = const {},
}) {
  final lower = fileName.toLowerCase();
  final skipped = skipFileNames.map((name) => name.toLowerCase()).toSet();
  if (skipped.contains(lower)) return false;
  return extensions.any((ext) => lower.endsWith(ext.toLowerCase()));
}

/// Counts importable files under [handle.path] using recursive [dart:io] listing.
Future<int> countImportableFiles(
  ImportFolderHandle handle, {
  required Set<String> extensions,
  Set<String> skipFileNames = const {'index.html'},
}) async {
  final folder = Directory(handle.path);
  if (!await folder.exists()) return 0;

  var count = 0;
  await for (final entity in folder.list(recursive: true, followLinks: false)) {
    if (entity is! File) continue;
    if (isImportableFileName(
      p.basename(entity.path),
      extensions: extensions,
      skipFileNames: skipFileNames,
    )) {
      count++;
    }
  }
  return count;
}

/// Picks a folder and returns a path safe for [dart:io] import services.
Future<ImportFolderHandle?> pickImportFolder({
  required String dialogTitle,
}) async {
  if (kIsWeb) return null;

  if (Platform.isAndroid) {
    return _pickImportFolderAndroid();
  }

  final path = await FilePicker.platform.getDirectoryPath(
    dialogTitle: dialogTitle,
  );
  if (path == null) return null;
  return ImportFolderHandle(path: path, isTemporary: false);
}

Future<ImportFolderHandle?> _pickImportFolderAndroid() async {
  final location = await DirPicker.pick(
    options: const PickOptions.android(shouldPersist: false),
  );
  if (location == null) return null;

  final entries = await DirPicker.listEntries(location, recursive: true);
  final tempRoot = await getTemporaryDirectory();
  final importDir = await Directory(
    p.join(tempRoot.path, 'import_${DateTime.now().millisecondsSinceEpoch}'),
  ).create(recursive: true);

  final safStream = SafStream();
  for (final entry in entries) {
    if (entry.isDirectory) continue;
    final uri = entry.uri;
    if (uri == null) continue;

    final destPath = p.join(importDir.path, entry.relativePath);
    await Directory(p.dirname(destPath)).create(recursive: true);
    await safStream.copyToLocalFile(uri.toString(), destPath);
  }

  return ImportFolderHandle(
    path: importDir.path,
    isTemporary: true,
    tempDirectory: importDir,
  );
}
