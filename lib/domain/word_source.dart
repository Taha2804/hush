import 'models/word_entry.dart';

/// Common contract for every word source. Add a new source by implementing
/// this class and registering it in the SourceRegistry.
abstract class WordSource {
  String get id;
  String get name;
  bool get requiresInternet;

  Future<bool> isAvailable();

  /// Human-readable reason when [isAvailable] is false.
  Future<String?> unavailableReason() async => null;

  /// Categories this source can serve (ids).
  Future<List<String>> categories();

  /// Returns up to [count] words of [category] (may return the whole pool).
  Future<List<WordEntry>> fetchWords(String category, int count);

  /// Whether this source's words must carry >= 3 valid hints.
  bool get requiresHints => true;
}

/// Result of [resolveWords]: the pool plus an optional one-line notice.
class ResolvedWords {
  ResolvedWords(this.pools, this.sourceUsed, {this.notice});
  final Map<String, List<WordEntry>> pools;
  final String sourceUsed;
  final String? notice;

  int get total => pools.values.fold(0, (a, b) => a + b.length);
}

/// Fallback order: primary source -> its cache (if any) -> [fallback] source.
/// [minWords] is the minimum pool size that counts as "enough".
Future<ResolvedWords> resolveWords({
  required WordSource primary,
  required List<String> categories,
  WordSource? cache,
  WordSource? fallback,
  int minWords = 5,
  int count = 200,
  List<WordEntry> Function(List<WordEntry>, WordSource)? clean,
}) async {
  Future<Map<String, List<WordEntry>>> load(WordSource s, List<String> cats) async {
    final out = <String, List<WordEntry>>{};
    for (final c in cats) {
      try {
        final raw = await s.fetchWords(c, count);
        final list = clean != null ? clean(raw, s) : raw;
        if (list.isNotEmpty) out[c] = list;
      } catch (_) {
        // treated as empty
      }
    }
    return out;
  }

  int size(Map<String, List<WordEntry>> m) => m.values.fold(0, (a, b) => a + b.length);

  if (await _safeAvailable(primary)) {
    final p = await load(primary, categories);
    if (size(p) >= minWords) return ResolvedWords(p, primary.id);
  }
  if (cache != null) {
    final c = await load(cache, categories);
    if (size(c) >= minWords) {
      return ResolvedWords(c, cache.id, notice: 'offline_using_cache');
    }
  }
  if (fallback != null) {
    final fbCats = await fallback.categories();
    final wanted = categories.where(fbCats.contains).toList();
    final f = await load(fallback, wanted.isEmpty ? fbCats : wanted);
    return ResolvedWords(f, fallback.id, notice: 'offline_using_packs');
  }
  return ResolvedWords(const {}, primary.id, notice: 'no_words');
}

Future<bool> _safeAvailable(WordSource s) async {
  try {
    return await s.isAvailable();
  } catch (_) {
    return false;
  }
}
