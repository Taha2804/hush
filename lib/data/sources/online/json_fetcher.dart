import 'dart:async';
import 'dart:convert';
import 'dart:collection';

import 'package:dio/dio.dart';

/// Descriptive User-Agent per the Wikimedia User-Agent policy.
const hushbugUserAgent =
    'HushbugPartyGame/1.0 (open-source offline party game; https://github.com/hushbug/hushbug) dio';

/// Minimal port so the pipeline can run against recorded fixtures in tests.
abstract class JsonFetcher {
  /// Returns decoded JSON, or throws on failure.
  Future<dynamic> getJson(Uri uri, {Map<String, String>? headers});
}

class _Semaphore {
  _Semaphore(this.max);
  final int max;
  int _active = 0;
  final _waiters = Queue<Completer<void>>();

  Future<void> acquire() {
    if (_active < max) {
      _active++;
      return Future.value();
    }
    final c = Completer<void>();
    _waiters.add(c);
    return c.future;
  }

  void release() {
    if (_waiters.isNotEmpty) {
      _waiters.removeFirst().complete();
    } else {
      _active--;
    }
  }
}

/// dio-backed fetcher: 8 s timeouts, max 5 concurrent requests, retry with
/// exponential backoff, honours Retry-After on 429/503.
class DioJsonFetcher implements JsonFetcher {
  DioJsonFetcher({Dio? dio, int maxConcurrent = 5, this.maxRetries = 3})
      : _sem = _Semaphore(maxConcurrent),
        _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 8),
              receiveTimeout: const Duration(seconds: 8),
              sendTimeout: const Duration(seconds: 8),
              headers: {
                'User-Agent': hushbugUserAgent,
                'Api-User-Agent': hushbugUserAgent,
                'Accept': 'application/json',
              },
            ));

  final Dio _dio;
  final _Semaphore _sem;
  final int maxRetries;

  @override
  Future<dynamic> getJson(Uri uri, {Map<String, String>? headers}) async {
    await _sem.acquire();
    try {
      for (var attempt = 0;; attempt++) {
        try {
          final r = await _dio.getUri<dynamic>(uri,
              options: Options(headers: headers, responseType: ResponseType.plain));
          final data = r.data;
          return data is String ? jsonDecode(data) : data;
        } on DioException catch (e) {
          final status = e.response?.statusCode;
          final retryable = status == null || status == 429 || status >= 500;
          if (!retryable || attempt >= maxRetries) rethrow;
          var wait = Duration(milliseconds: 600 * (1 << attempt));
          final ra = e.response?.headers.value('retry-after');
          final secs = ra == null ? null : int.tryParse(ra.trim());
          if (secs != null) wait = Duration(seconds: secs.clamp(1, 30));
          await Future<void>.delayed(wait);
        }
      }
    } finally {
      _sem.release();
    }
  }
}

/// Serves canned responses keyed by URL substring. Used in tests (no live
/// network) — unmatched URLs throw, like an offline device.
class FixtureFetcher implements JsonFetcher {
  FixtureFetcher(this.fixtures);
  final Map<String, dynamic> fixtures;
  final List<Uri> requested = [];

  @override
  Future<dynamic> getJson(Uri uri, {Map<String, String>? headers}) async {
    requested.add(uri);
    final s = Uri.decodeFull(uri.toString());
    for (final e in fixtures.entries) {
      if (s.contains(e.key)) {
        final v = e.value;
        return v is String ? jsonDecode(v) : v;
      }
    }
    throw StateError('No fixture for $s');
  }
}
