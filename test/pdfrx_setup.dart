import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pdfrx/pdfrx.dart';

const _pdfiumRelease = 'chromium%2F7202';
final _tmpRoot = Directory('${Directory.current.path}/test/.tmp');
final _cacheRoot = Directory('${_tmpRoot.path}/cache');

/// Configures PDFium for unit tests. Skips download if [PDFIUM_PATH] is set.
Future<void> setupPdfrxForTests() async {
  final envPath = Platform.environment['PDFIUM_PATH'];
  if (envPath != null && await File(envPath).exists()) {
    Pdfrx.pdfiumModulePath = envPath;
  } else {
    Pdfrx.pdfiumModulePath = await _downloadPdfiumModulePath();
  }

  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (methodCall) async {
    return _cacheRoot.path;
  });

  try {
    await _cacheRoot.delete(recursive: true);
  } catch (_) {}
}

Future<String> _downloadPdfiumModulePath() async {
  final match = RegExp(r'"([^_]+)_([^_]+)"').firstMatch(Platform.version)!;
  final platform = match.group(1)!;
  final arch = match.group(2)!;

  if (platform == 'windows' && arch == 'x64') {
    return _downloadPdfium('win', arch, 'bin/pdfium.dll');
  }
  if (platform == 'linux' && (arch == 'x64' || arch == 'arm64')) {
    return _downloadPdfium(platform, arch, 'lib/libpdfium.so');
  }
  if (platform == 'macos') {
    return _downloadPdfium('mac', arch, 'lib/libpdfium.dylib');
  }

  throw UnsupportedError('Unsupported test platform: $platform-$arch');
}

Future<String> _downloadPdfium(
  String platform,
  String arch,
  String modulePath,
) async {
  final tmpDir = Directory('${_tmpRoot.path}/$platform-$arch');
  final targetPath = '${tmpDir.path}/$modulePath';
  if (await File(targetPath).exists()) {
    return targetPath;
  }

  final uri = Uri.parse(
    'https://github.com/bblanchon/pdfium-binaries/releases/download/$_pdfiumRelease/pdfium-$platform-$arch.tgz',
  );
  final response = await http.get(uri);
  if (response.statusCode != 200) {
    throw StateError('Failed to download PDFium from $uri');
  }

  final archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(response.bodyBytes));
  try {
    await tmpDir.delete(recursive: true);
  } catch (_) {}
  await extractArchiveToDisk(archive, tmpDir.path);
  return targetPath;
}
