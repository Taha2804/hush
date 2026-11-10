import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/db/app_db.dart';
import '../data/prefs/settings.dart';
import '../data/source_registry.dart';
import '../data/sources/my_words_source.dart';
import '../data/sources/offline_source.dart';
import '../data/sources/online/online_source.dart';
import '../domain/blocklist.dart';
import '../domain/random_service.dart';
import '../domain/state_store.dart';
import '../domain/word_pipeline.dart';
import 'services.dart';

/// Values created in main() before runApp and injected via overrides.
class Bootstrap {
  Bootstrap({
    required this.prefs,
    required this.db,
    required this.assetLoader,
    required this.blocklistText,
    required this.brandsText,
  });
  final SharedPreferences prefs;
  final AppDb db;
  final AssetLoader assetLoader;
  final String blocklistText;
  final String brandsText;
}

final bootstrapProvider = Provider<Bootstrap>((ref) => throw UnimplementedError('override in main'));

final dbProvider = Provider<AppDb>((ref) => ref.watch(bootstrapProvider).db);

final randomProvider = Provider<RandomService>((ref) => RandomService());

final blocklistProvider = Provider<Blocklist>((ref) {
  final b = ref.watch(bootstrapProvider);
  return Blocklist.fromText(blocked: b.blocklistText, brands: b.brandsText);
});

final stateStoreProvider =
    Provider<GameStateStore>((ref) => GameStateStore(DriftKeyValueStore(ref.watch(dbProvider))));

final pipelineProvider = Provider<WordPipeline>((ref) => WordPipeline(
      store: ref.watch(stateStoreProvider),
      random: ref.watch(randomProvider),
      blocklist: ref.watch(blocklistProvider),
    ));

final onlineSourceProvider = Provider<OnlineSearchSource>((ref) {
  final b = ref.watch(bootstrapProvider);
  return OnlineSearchSource(db: b.db, blocklistText: b.blocklistText, brandsText: b.brandsText);
});

final offlineSourceProvider = Provider<OfflinePackSource>((ref) => OfflinePackSource(
      ref.watch(bootstrapProvider).assetLoader,
      myWords: ref.watch(myWordsSourceProvider),
    ));

final myWordsSourceProvider = Provider<MyWordsSource>((ref) => MyWordsSource(ref.watch(dbProvider)));

final registryProvider = Provider<SourceRegistry>((ref) => SourceRegistry(
      online: ref.watch(onlineSourceProvider),
      offline: ref.watch(offlineSourceProvider),
      myWords: ref.watch(myWordsSourceProvider),
      pipeline: ref.watch(pipelineProvider),
    ));

final soundProvider = Provider<SoundService>((ref) => SoundService());

class SettingsNotifier extends Notifier<AppSettings> {
  late SettingsRepository _repo;

  @override
  AppSettings build() {
    _repo = SettingsRepository(ref.watch(bootstrapProvider).prefs);
    return _repo.load();
  }

  void update(AppSettings Function(AppSettings s) f) {
    state = f(state);
    _repo.save(state);
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// The source chosen for this session (survives between rounds).
class CurrentSourceNotifier extends Notifier<String?> {
  @override
  String? build() {
    final s = ref.read(settingsProvider);
    return s.askSourceEveryLaunch ? null : s.lastSource;
  }

  void set(String id) {
    state = id;
    ref.read(settingsProvider.notifier).update((s) => s.copyWith(lastSource: () => id));
  }
}

final currentSourceProvider = NotifierProvider<CurrentSourceNotifier, String?>(CurrentSourceNotifier.new);
