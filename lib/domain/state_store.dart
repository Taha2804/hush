import 'dart:convert';

import 'rotation_selector.dart';
import 'shuffle_bag.dart';

/// Persistence port for randomness state (bags, recent history, hint and
/// fake-word usage). The app uses a drift-backed implementation; tests use
/// [InMemoryStateStore] or a file-backed drift DB.
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> deletePrefix(String prefix);
}

class InMemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> data = {};

  @override
  Future<String?> read(String key) async => data[key];

  @override
  Future<void> write(String key, String value) async => data[key] = value;

  @override
  Future<void> deletePrefix(String prefix) async =>
      data.removeWhere((k, _) => k.startsWith(prefix));
}

/// Typed facade over a [KeyValueStore].
class GameStateStore {
  GameStateStore(this.kv);
  final KeyValueStore kv;

  static const historyLimit = 200;

  Future<Map<String, dynamic>?> _json(String key) async {
    final raw = await kv.read(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String bagKey(String sourceId, String category) => 'bag:$sourceId:$category';

  Future<ShuffleBagState> loadBag(String sourceId, String category) async {
    final j = await _json(bagKey(sourceId, category));
    return j == null ? ShuffleBagState() : ShuffleBagState.fromJson(j);
  }

  Future<void> saveBag(String sourceId, String category, ShuffleBagState s) =>
      kv.write(bagKey(sourceId, category), jsonEncode(s.toJson()));

  Future<List<String>> loadHistory() async {
    final j = await _json('history');
    return List<String>.from(j?['words'] as List? ?? const []);
  }

  Future<void> saveHistory(List<String> words) {
    final trimmed = words.length > historyLimit
        ? words.sublist(words.length - historyLimit)
        : words;
    return kv.write('history', jsonEncode({'words': trimmed}));
  }

  Future<RotationUsage> loadHintUsage(String wordId) async {
    final j = await _json('hint:$wordId');
    return j == null ? RotationUsage() : RotationUsage.fromJson(j);
  }

  Future<void> saveHintUsage(String wordId, RotationUsage u) =>
      kv.write('hint:$wordId', jsonEncode(u.toJson()));

  Future<RotationUsage> loadFakeUsage(String wordId) async {
    final j = await _json('fake:$wordId');
    return j == null ? RotationUsage() : RotationUsage.fromJson(j);
  }

  Future<void> saveFakeUsage(String wordId, RotationUsage u) =>
      kv.write('fake:$wordId', jsonEncode(u.toJson()));

  Future<void> clearSource(String sourceId) => kv.deletePrefix('bag:$sourceId:');
}
