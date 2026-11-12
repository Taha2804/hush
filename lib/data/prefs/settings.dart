import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/categories.dart';
import '../../domain/models/game_config.dart';

/// User preferences (persisted in shared_preferences).
class AppSettings {
  const AppSettings({
    this.language = 'en',
    this.sound = true,
    this.haptics = true,
    this.reduceMotion = false,
    this.askSourceEveryLaunch = true,
    this.lastSource,
    this.game = const GameConfig(),
    this.scores = const {},
    this.selectedCategories = const {},
    this.playerGroups = const [],
    this.playerAvatars = const {},
    this.voiceEnabled = true,
    this.pushToTalk = false,
    this.speakerOutput = true,
    this.voiceVolume = 1.0,
    this.chatNotifications = true,
    this.chatTimestamps = true,
    this.adultConfirmed = false,
  });

  final String language;
  final bool sound;
  final bool haptics;
  final bool reduceMotion;
  final bool askSourceEveryLaunch;
  final String? lastSource;
  final GameConfig game;
  final Map<String, int> scores;

  /// Selected categories remembered per source id.
  final Map<String, List<String>> selectedCategories;

  /// Saved player-name presets.
  final List<PlayerGroup> playerGroups;

  /// Custom avatar index (0..7) chosen per player name.
  final Map<String, int> playerAvatars;

  // Online voice and chat preferences.
  final bool voiceEnabled;
  final bool pushToTalk;
  final bool speakerOutput;
  final double voiceVolume;
  final bool chatNotifications;
  final bool chatTimestamps;

  /// The user confirmed they are 18+ (required before the After Dark
  /// category can be enabled). Never set by default.
  final bool adultConfirmed;

  AppSettings copyWith({
    String? language,
    bool? sound,
    bool? haptics,
    bool? reduceMotion,
    bool? askSourceEveryLaunch,
    String? Function()? lastSource,
    GameConfig? game,
    Map<String, int>? scores,
    Map<String, List<String>>? selectedCategories,
    List<PlayerGroup>? playerGroups,
    Map<String, int>? playerAvatars,
    bool? voiceEnabled,
    bool? pushToTalk,
    bool? speakerOutput,
    double? voiceVolume,
    bool? chatNotifications,
    bool? chatTimestamps,
    bool? adultConfirmed,
  }) =>
      AppSettings(
        language: language ?? this.language,
        sound: sound ?? this.sound,
        haptics: haptics ?? this.haptics,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        askSourceEveryLaunch: askSourceEveryLaunch ?? this.askSourceEveryLaunch,
        lastSource: lastSource != null ? lastSource() : this.lastSource,
        game: game ?? this.game,
        scores: scores ?? this.scores,
        selectedCategories: selectedCategories ?? this.selectedCategories,
        playerGroups: playerGroups ?? this.playerGroups,
        playerAvatars: playerAvatars ?? this.playerAvatars,
        voiceEnabled: voiceEnabled ?? this.voiceEnabled,
        pushToTalk: pushToTalk ?? this.pushToTalk,
        speakerOutput: speakerOutput ?? this.speakerOutput,
        voiceVolume: voiceVolume ?? this.voiceVolume,
        chatNotifications: chatNotifications ?? this.chatNotifications,
        chatTimestamps: chatTimestamps ?? this.chatTimestamps,
        adultConfirmed: adultConfirmed ?? this.adultConfirmed,
      );

  Map<String, dynamic> toJson() => {
        'language': language,
        'sound': sound,
        'haptics': haptics,
        'reduceMotion': reduceMotion,
        'askSourceEveryLaunch': askSourceEveryLaunch,
        'lastSource': lastSource,
        'game': game.toJson(),
        'scores': scores,
        'selectedCategories': selectedCategories,
        'playerGroups': [for (final g in playerGroups) g.toJson()],
        'playerAvatars': playerAvatars,
        'voiceEnabled': voiceEnabled,
        'pushToTalk': pushToTalk,
        'speakerOutput': speakerOutput,
        'voiceVolume': voiceVolume,
        'chatNotifications': chatNotifications,
        'chatTimestamps': chatTimestamps,
        'adultConfirmed': adultConfirmed,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    T pick<T>(String k, T fallback) => j[k] is T ? j[k] as T : fallback;
    GameConfig game;
    try {
      game = GameConfig.fromJson(Map<String, dynamic>.from(j['game'] as Map));
    } catch (_) {
      game = const GameConfig();
    }
    // Older saves used pack ids that were merged into the v2 categories.
    game = game.copyWith(
      categories: migrateCategoryIds(game.categories),
      adultContent: game.adultContent && pick('adultConfirmed', false),
    );
    return AppSettings(
      language: pick('language', 'en'),
      sound: pick('sound', true),
      haptics: pick('haptics', true),
      reduceMotion: pick('reduceMotion', false),
      askSourceEveryLaunch: pick('askSourceEveryLaunch', true),
      lastSource: j['lastSource'] as String?,
      game: game,
      scores: {
        for (final e in (j['scores'] as Map? ?? const {}).entries)
          e.key.toString(): (e.value as num).toInt(),
      },
      selectedCategories: {
        for (final e in (j['selectedCategories'] as Map? ?? const {}).entries)
          e.key.toString(): migrateCategoryIds(List<String>.from(e.value as List)),
      },
      playerGroups: [
        for (final g in (j['playerGroups'] as List? ?? const []))
          if (g is Map) PlayerGroup.fromJson(Map<String, dynamic>.from(g)),
      ],
      playerAvatars: {
        for (final e in (j['playerAvatars'] as Map? ?? const {}).entries)
          e.key.toString(): (e.value as num).toInt(),
      },
      voiceEnabled: pick('voiceEnabled', true),
      pushToTalk: pick('pushToTalk', false),
      speakerOutput: pick('speakerOutput', true),
      voiceVolume: pick<num>('voiceVolume', 1.0).toDouble().clamp(0.0, 1.0),
      chatNotifications: pick('chatNotifications', true),
      chatTimestamps: pick('chatTimestamps', true),
      adultConfirmed: pick('adultConfirmed', false),
    );
  }
}

/// A saved set of player names ("group preset"). Survives app restarts.
class PlayerGroup {
  const PlayerGroup({required this.name, required this.players});
  final String name;
  final List<String> players;

  Map<String, dynamic> toJson() => {'name': name, 'players': players};
  factory PlayerGroup.fromJson(Map<String, dynamic> j) => PlayerGroup(
        name: (j['name'] ?? '').toString(),
        players: [for (final p in (j['players'] as List? ?? const [])) p.toString()],
      );
}

class SettingsRepository {
  SettingsRepository(this.prefs);
  final SharedPreferences prefs;
  static const _key = 'hushbug.settings.v1';

  /// Loads saved preferences for a fresh app launch.
  ///
  /// Only real preferences survive a restart (theme, language, sound, game
  /// rules, chosen categories...). Session data — player names, the imposter
  /// count that depends on them, and the scoreboard — starts fresh.
  AppSettings load() {
    final raw = prefs.getString(_key);
    if (raw == null) return const AppSettings();
    try {
      return freshSession(AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>));
    } catch (_) {
      return const AppSettings();
    }
  }

  static AppSettings freshSession(AppSettings s) {
    const defaults = GameConfig();
    return s.copyWith(
      game: s.game.copyWith(players: defaults.players, imposterCount: defaults.imposterCount),
      scores: const {},
    );
  }

  Future<void> save(AppSettings s) => prefs.setString(_key, jsonEncode(s.toJson()));
}
