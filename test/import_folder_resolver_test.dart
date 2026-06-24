import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:list_pilot/core/io/import_folder_resolver.dart';
import 'package:path/path.dart' as p;

void main() {
  group('isImportableFileName', () {
    test('matches extensions case-insensitively', () {
      expect(
        isImportableFileName('Recipe.html', extensions: {'.html'}),
        isTrue,
      );
      expect(
        isImportableFileName('receipt.PDF', extensions: {'.pdf'}),
        isTrue,
      );
      expect(
        isImportableFileName('notes.txt', extensions: {'.html', '.pdf'}),
        isFalse,
      );
    });

    test('skips configured file names case-insensitively', () {
      expect(
        isImportableFileName(
          'index.html',
          extensions: {'.html'},
          skipFileNames: {'index.html'},
        ),
        isFalse,
      );
      expect(
        isImportableFileName(
          'INDEX.HTML',
          extensions: {'.html'},
          skipFileNames: {'index.html'},
        ),
        isFalse,
      );
      expect(
        isImportableFileName(
          'Bruschetta.html',
          extensions: {'.html'},
          skipFileNames: {'index.html'},
        ),
        isTrue,
      );
    });
  });

  group('countImportableFiles', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('import_folder_test');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('counts html files recursively and skips index.html', () async {
      final recipesDir = Directory(p.join(tempDir.path, 'Recipes'));
      await recipesDir.create(recursive: true);
      await File(p.join(tempDir.path, 'index.html')).writeAsString('<html/>');
      await File(p.join(recipesDir.path, 'Soup.html')).writeAsString('<html/>');
      await File(p.join(recipesDir.path, 'Salad.html')).writeAsString('<html/>');
      await File(p.join(recipesDir.path, 'readme.txt')).writeAsString('nope');

      final handle = ImportFolderHandle(path: tempDir.path, isTemporary: false);
      final count = await countImportableFiles(
        handle,
        extensions: const {'.html'},
      );

      expect(count, 2);
    });

    test('counts pdf files', () async {
      await File(p.join(tempDir.path, 'a.pdf')).writeAsString('%PDF');
      await File(p.join(tempDir.path, 'b.PDF')).writeAsString('%PDF');
      await File(p.join(tempDir.path, 'c.html')).writeAsString('<html/>');

      final handle = ImportFolderHandle(path: tempDir.path, isTemporary: false);
      final count = await countImportableFiles(
        handle,
        extensions: const {'.pdf'},
        skipFileNames: const {},
      );

      expect(count, 2);
    });

    test('returns zero for missing folder', () async {
      final missing = ImportFolderHandle(
        path: p.join(tempDir.path, 'missing'),
        isTemporary: false,
      );
      final count = await countImportableFiles(
        missing,
        extensions: const {'.html'},
      );
      expect(count, 0);
    });
  });

  group('ImportFolderHandle', () {
    test('dispose removes temporary directory', () async {
      final tempDir = await Directory.systemTemp.createTemp('import_handle_test');
      await File(p.join(tempDir.path, 'file.txt')).writeAsString('x');

      final handle = ImportFolderHandle(
        path: tempDir.path,
        isTemporary: true,
        tempDirectory: tempDir,
      );

      await handle.dispose();
      expect(await tempDir.exists(), isFalse);
    });

    test('dispose is a no-op for non-temporary handles', () async {
      final tempDir = await Directory.systemTemp.createTemp('import_handle_test');
      final handle = ImportFolderHandle(path: tempDir.path, isTemporary: false);

      await handle.dispose();
      expect(await tempDir.exists(), isTrue);
      await tempDir.delete(recursive: true);
    });
  });
}
