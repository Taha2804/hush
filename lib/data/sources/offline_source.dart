import 'dart:convert';

import '../../domain/models/word_entry.dart';
import '../../domain/pack_validator.dart';
import '../../domain/text_utils.dart';
import '../../domain/word_source.dart';
import 'my_words_source.dart';

/// Loads a bundled asset as text (rootBundle.loadString in the app,
/// File reads in tests).
typedef AssetLoader = Future<String> Function(String path);

class PackInfo {
  const PackInfo(this.id, this.name, this.count,
      {this.isCustom = false, this.isAdult = false, this.description = '', this.icon = 'category'});
  final String id;
  final String name;
  final int count;
  final bool isCustom;
  final bool isAdult;
  final String description;
  final String icon;
}

/// Source 2: bundled Offline Packs (always available) with integrated Custom Packs support.
class OfflinePackSource extends WordSource {
  OfflinePackSource(this._load, {this.myWords});

  final AssetLoader _load;
  final MyWordsSource? myWords;
  List<PackInfo>? _bundledIndex;
  final Map<String, List<WordEntry>> _cache = {};

  static const sourceId = 'offline';

  @override
  String get id => sourceId;
  @override
  String get name => 'Offline Packs';
  @override
  bool get requiresInternet => false;

  @override
  Future<bool> isAvailable() async => true;

  Future<List<PackInfo>> _index() async {
    if (_bundledIndex == null) {
      final raw = jsonDecode(await _load('assets/packs/index.json')) as List;
      _bundledIndex = [
        for (final p in raw)
          () {
            final m = PackMeta.fromJson(Map<String, dynamic>.from(p as Map));
            return PackInfo(m.id, m.name, m.count,
                isAdult: m.isAdult, description: m.description, icon: m.icon);
          }(),
      ];
    }
    return _bundledIndex!;
  }

  /// The 18+ packs (shown only after the age confirmation).
  Future<List<PackInfo>> adultPacks() async => [for (final p in await _index()) if (p.isAdult) p];

  /// Standard packs plus custom packs. Adult packs are never included here,
  /// so they can't reach Random Mix by accident.
  Future<List<PackInfo>> packs() async {
    final allPacks = [for (final p in await _index()) if (!p.isAdult) p];

    // Dynamically include active custom packs from My Words into Offline Packs
    if (myWords != null) {
      final customPacks = await myWords!.packs();
      for (final cp in customPacks) {
        if (cp.wordCount > 0) {
          allPacks.insert(0, PackInfo('my${cp.id}', cp.name, cp.wordCount, isCustom: true));
        }
      }
    }
    return allPacks;
  }

  Future<String> categoryName(String id) async {
    if (id.startsWith('my') && myWords != null) {
      return await myWords!.categoryName(id);
    }
    final list = [...await packs(), ...await adultPacks()];
    return list.firstWhere((p) => p.id == id, orElse: () => PackInfo(id, id, 0)).name;
  }

  @override
  Future<List<String>> categories() async => [for (final p in await packs()) p.id];

  @override
  Future<List<WordEntry>> fetchWords(String category, int count) async {
    // If it's a custom pack ID, delegate directly to MyWordsSource
    if (category.startsWith('my') && myWords != null) {
      return await myWords!.fetchWords(category, count);
    }

    List<WordEntry> entries;
    final cached = _cache[category];
    if (cached != null) {
      entries = List<WordEntry>.from(cached);
    } else {
      final adult = (await adultPacks()).any((p) => p.id == category);
      final text = await _load(adult ? 'assets/packs/adult/$category.json' : 'assets/packs/$category.json');
      final issues = <PackIssue>[];
      entries = parsePack(jsonDecode(text) as Map<String, dynamic>, issues);
      _cache[category] = entries;
      entries = List<WordEntry>.from(entries);
    }

    // Merge any custom words if a custom pack with a matching name exists
    if (myWords != null) {
      final catName = await categoryName(category);
      final customPacks = await myWords!.packs();
      final matchingPacks = customPacks.where((p) => p.name.trim().toLowerCase() == catName.trim().toLowerCase());
      for (final mp in matchingPacks) {
        final customWords = await myWords!.fetchWords('my${mp.id}', count);
        final existingWords = entries.map((e) => normalize(e.word)).toSet();
        for (final cw in customWords) {
          if (!existingWords.contains(normalize(cw.word))) {
            entries.add(cw);
          }
        }
      }
    }

    return entries;
  }
}
