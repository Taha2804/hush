import '../domain/models/word_entry.dart';
import '../domain/word_pipeline.dart';
import '../domain/word_source.dart';
import 'sources/my_words_source.dart';
import 'sources/offline_source.dart';
import 'sources/online/online_source.dart';

/// Lists the available word sources. Adding a new source = one class that
/// extends [WordSource] + one line in [sources].
class SourceRegistry {
  SourceRegistry({
    required this.online,
    required this.offline,
    required this.myWords,
    required this.pipeline,
  });

  final OnlineSearchSource online;
  final OfflinePackSource offline;
  final MyWordsSource myWords;
  final WordPipeline pipeline;

  late final OnlineCacheSource onlineCache = OnlineCacheSource(online);

  List<WordSource> get sources => [online, offline, myWords];

  WordSource byId(String id) =>
      sources.firstWhere((s) => s.id == id, orElse: () => offline);

  Future<String> categoryName(String sourceId, String category) async {
    if (sourceId == MyWordsSource.sourceId) return myWords.categoryName(category);
    return offline.categoryName(category);
  }

  /// Resolves the word pools for a round, running the shared pipeline on
  /// every source's output and applying the fallback order
  /// Online -> online cache -> Offline Packs.
  Future<ResolvedWords> resolve(String sourceId, List<String> categories) {
    final source = byId(sourceId);
    List<WordEntry> clean(List<WordEntry> raw, WordSource s) =>
        pipeline.clean(raw, requireHints: s.requiresHints);
    if (source.id == OnlineSearchSource.sourceId) {
      return resolveWords(
        primary: online,
        cache: onlineCache,
        fallback: offline,
        categories: categories,
        clean: clean,
      );
    }
    if (source.id == MyWordsSource.sourceId) {
      return resolveWords(primary: myWords, fallback: offline, categories: categories, minWords: 1, clean: clean);
    }
    return resolveWords(primary: offline, categories: categories, minWords: 1, clean: clean);
  }
}
