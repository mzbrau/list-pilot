import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

typedef HttpGet = Future<http.Response> Function(Uri url, {Map<String, String>? headers});

class RecipePageFetchException implements Exception {
  const RecipePageFetchException(this.message);
  final String message;

  @override
  String toString() => message;
}

const recipeBrowserUserAgent =
    'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

Map<String, String> recipePageFetchHeaders(Uri url) {
  final origin = Uri(scheme: url.scheme, host: url.host, port: url.hasPort ? url.port : null);
  return {
    'User-Agent': recipeBrowserUserAgent,
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8',
    'Accept-Language': 'en-AU,en;q=0.9',
    'Referer': origin.toString(),
  };
}

Map<String, String> recipeImageFetchHeaders({String? referer}) {
  return {
    'User-Agent': recipeBrowserUserAgent,
    'Accept': 'image/avif,image/webp,image/apng,image/*,*/*;q=0.8',
    if (referer != null && referer.isNotEmpty) 'Referer': referer,
  };
}

typedef PageHtmlFetcher = Future<String> Function(Uri url);
typedef WebViewHtmlFetcher = Future<String> Function(Uri url);

class RecipePageFetcher {
  RecipePageFetcher({
    HttpGet? httpGet,
    WebViewHtmlFetcher? webViewFetcher,
  })  : _httpGet = httpGet ?? http.get,
        _webViewFetcher = webViewFetcher ?? _fetchHtmlViaWebView;

  final HttpGet _httpGet;
  final WebViewHtmlFetcher _webViewFetcher;

  Future<String> fetchHtml(Uri url) async {
    if (kIsWeb) {
      try {
        return await _fetchHtmlViaHttpOnly(url);
      } on http.ClientException {
        throw const RecipePageFetchException(
          'Failed to fetch page. This site may use HTTP features '
          'unsupported in the browser — try the mobile or desktop app.',
        );
      } on HttpException catch (e) {
        throw RecipePageFetchException('Failed to fetch page: ${e.message}');
      } on SocketException catch (e) {
        throw RecipePageFetchException('Failed to fetch page: ${e.message}');
      }
    }

    try {
      return await _fetchHtmlViaHttpOnly(url);
    } on http.ClientException {
      return _webViewFetcher(url);
    } on HttpException {
      return _webViewFetcher(url);
    } on SocketException {
      return _webViewFetcher(url);
    } on RecipePageFetchException {
      return _webViewFetcher(url);
    }
  }

  Future<String> _fetchHtmlViaHttpOnly(Uri url) async {
    final response = await _httpGet(
      url,
      headers: recipePageFetchHeaders(url),
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return response.body;
    }

    if (kIsWeb) {
      throw RecipePageFetchException(
        'Failed to fetch page (${response.statusCode}). '
        'This site may block web imports — try the mobile or desktop app.',
      );
    }

    throw RecipePageFetchException('HTTP ${response.statusCode}');
  }

  static Future<String> _fetchHtmlViaWebView(Uri url) async {
    final completer = Completer<String>();
    late final HeadlessInAppWebView headless;

    headless = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(
        userAgent: recipeBrowserUserAgent,
        javaScriptEnabled: true,
      ),
      initialUrlRequest: URLRequest(url: WebUri(url.toString())),
      onLoadStop: (controller, loadedUrl) async {
        if (completer.isCompleted) return;
        try {
          final html = await controller.getHtml();
          completer.complete(html ?? '');
        } catch (e) {
          completer.completeError(
            RecipePageFetchException('Failed to read page content: $e'),
          );
        }
      },
      onReceivedError: (controller, request, error) {
        if (completer.isCompleted) return;
        if (request.isForMainFrame ?? false) {
          completer.completeError(
            RecipePageFetchException('Failed to load page: ${error.description}'),
          );
        }
      },
    );

    await headless.run();

    try {
      return await completer.future.timeout(
        const Duration(seconds: 25),
        onTimeout: () {
          throw const RecipePageFetchException('Timed out loading page in browser');
        },
      );
    } finally {
      await headless.dispose();
    }
  }
}

Future<String> defaultFetchRecipePageHtml(Uri url) {
  return RecipePageFetcher().fetchHtml(url);
}
