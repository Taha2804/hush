import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Achievement definition and progress tracking.
class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.maxProgress,
    this.progress = 0,
    this.unlocked = false,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final int maxProgress;
  final int progress;
  final bool unlocked;

  Achievement copyWith({
    int? progress,
    bool? unlocked,
  }) =>
      Achievement(
        id: id,
        title: title,
        description: description,
        iconName: iconName,
        maxProgress: maxProgress,
        progress: progress ?? this.progress,
        unlocked: unlocked ?? this.unlocked,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'progress': progress,
        'unlocked': unlocked,
      };

  static Achievement fromJson(Map<String, dynamic> json, Achievement base) {
    final prog = (json['progress'] as num?)?.toInt() ?? 0;
    final isUnlocked = (json['unlocked'] as bool?) ?? false;
    return base.copyWith(
      progress: prog,
      unlocked: isUnlocked || prog >= base.maxProgress,
    );
  }
}

/// Full Game History Record.
class GameHistoryRecord {
  const GameHistoryRecord({
    required this.id,
    required this.timestamp,
    required this.secretWord,
    required this.fakeWord,
    required this.category,
    required this.winner,
    required this.players,
    required this.imposters,
    required this.scores,
  });

  final String id;
  final DateTime timestamp;
  final String secretWord;
  final String? fakeWord;
  final String category;
  final String winner; // 'crew' or 'imposter'
  final List<String> players;
  final List<String> imposters;
  final Map<String, int> scores;

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'secretWord': secretWord,
        'fakeWord': fakeWord,
        'category': category,
        'winner': winner,
        'players': players,
        'imposters': imposters,
        'scores': scores,
      };

  factory GameHistoryRecord.fromJson(Map<String, dynamic> json) => GameHistoryRecord(
        id: json['id'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        secretWord: json['secretWord'] as String? ?? '',
        fakeWord: json['fakeWord'] as String?,
        category: json['category'] as String? ?? 'General',
        winner: json['winner'] as String? ?? 'crew',
        players: (json['players'] as List? ?? []).map((e) => e.toString()).toList(),
        imposters: (json['imposters'] as List? ?? []).map((e) => e.toString()).toList(),
        scores: {
          for (final e in (json['scores'] as Map? ?? {}).entries)
            e.key.toString(): (e.value as num).toInt(),
        },
      );
}

/// Player Profile, Stats, Achievements & Daily Challenge State Store.
class GameStats {
  const GameStats({
    this.totalGames = 14,
    this.crewVictories = 9,
    this.imposterVictories = 5,
    this.currentWinStreak = 3,
    this.bestWinStreak = 6,
    this.timesCaughtAsImposter = 2,
    this.successfulDeceptions = 5,
    this.playerLevel = 4,
    this.playerXp = 820,
    this.mostPlayedCategory = 'Movies',
    this.selectedAvatar = 0,
    this.dailyChallengeCompleted = false,
    this.dailyStreak = 4,
    this.history = const [],
    this.unlockedCosmetics = const ['classic', 'detective'],
    this.selectedCosmetic = 'classic',
  });

  final int totalGames;
  final int crewVictories;
  final int imposterVictories;
  final int currentWinStreak;
  final int bestWinStreak;
  final int timesCaughtAsImposter;
  final int successfulDeceptions;
  final int playerLevel;
  final int playerXp;
  final String mostPlayedCategory;
  final int selectedAvatar;
  final bool dailyChallengeCompleted;
  final int dailyStreak;
  final List<GameHistoryRecord> history;
  final List<String> unlockedCosmetics;
  final String selectedCosmetic;

  double get winPercentage =>
      totalGames > 0 ? ((crewVictories + imposterVictories) / totalGames * 100).clamp(0, 100) : 0.0;

  int get xpForNextLevel => playerLevel * 250;

  Map<String, dynamic> toJson() => {
        'totalGames': totalGames,
        'crewVictories': crewVictories,
        'imposterVictories': imposterVictories,
        'currentWinStreak': currentWinStreak,
        'bestWinStreak': bestWinStreak,
        'timesCaughtAsImposter': timesCaughtAsImposter,
        'successfulDeceptions': successfulDeceptions,
        'playerLevel': playerLevel,
        'playerXp': playerXp,
        'mostPlayedCategory': mostPlayedCategory,
        'selectedAvatar': selectedAvatar,
        'dailyChallengeCompleted': dailyChallengeCompleted,
        'dailyStreak': dailyStreak,
        'history': [for (final h in history) h.toJson()],
        'unlockedCosmetics': unlockedCosmetics,
        'selectedCosmetic': selectedCosmetic,
      };

  factory GameStats.fromJson(Map<String, dynamic> j) {
    return GameStats(
      totalGames: (j['totalGames'] as num?)?.toInt() ?? 14,
      crewVictories: (j['crewVictories'] as num?)?.toInt() ?? 9,
      imposterVictories: (j['imposterVictories'] as num?)?.toInt() ?? 5,
      currentWinStreak: (j['currentWinStreak'] as num?)?.toInt() ?? 3,
      bestWinStreak: (j['bestWinStreak'] as num?)?.toInt() ?? 6,
      timesCaughtAsImposter: (j['timesCaughtAsImposter'] as num?)?.toInt() ?? 2,
      successfulDeceptions: (j['successfulDeceptions'] as num?)?.toInt() ?? 5,
      playerLevel: (j['playerLevel'] as num?)?.toInt() ?? 4,
      playerXp: (j['playerXp'] as num?)?.toInt() ?? 820,
      mostPlayedCategory: (j['mostPlayedCategory'] as String?) ?? 'Movies',
      selectedAvatar: (j['selectedAvatar'] as num?)?.toInt() ?? 0,
      dailyChallengeCompleted: (j['dailyChallengeCompleted'] as bool?) ?? false,
      dailyStreak: (j['dailyStreak'] as num?)?.toInt() ?? 4,
      history: [
        for (final h in (j['history'] as List? ?? []))
          if (h is Map) GameHistoryRecord.fromJson(Map<String, dynamic>.from(h)),
      ],
      unlockedCosmetics: (j['unlockedCosmetics'] as List? ?? ['classic', 'detective']).map((e) => e.toString()).toList(),
      selectedCosmetic: (j['selectedCosmetic'] as String?) ?? 'classic',
    );
  }

  GameStats copyWith({
    int? totalGames,
    int? crewVictories,
    int? imposterVictories,
    int? currentWinStreak,
    int? bestWinStreak,
    int? timesCaughtAsImposter,
    int? successfulDeceptions,
    int? playerLevel,
    int? playerXp,
    String? mostPlayedCategory,
    int? selectedAvatar,
    bool? dailyChallengeCompleted,
    int? dailyStreak,
    List<GameHistoryRecord>? history,
    List<String>? unlockedCosmetics,
    String? selectedCosmetic,
  }) =>
      GameStats(
        totalGames: totalGames ?? this.totalGames,
        crewVictories: crewVictories ?? this.crewVictories,
        imposterVictories: imposterVictories ?? this.imposterVictories,
        currentWinStreak: currentWinStreak ?? this.currentWinStreak,
        bestWinStreak: bestWinStreak ?? this.bestWinStreak,
        timesCaughtAsImposter: timesCaughtAsImposter ?? this.timesCaughtAsImposter,
        successfulDeceptions: successfulDeceptions ?? this.successfulDeceptions,
        playerLevel: playerLevel ?? this.playerLevel,
        playerXp: playerXp ?? this.playerXp,
        mostPlayedCategory: mostPlayedCategory ?? this.mostPlayedCategory,
        selectedAvatar: selectedAvatar ?? this.selectedAvatar,
        dailyChallengeCompleted: dailyChallengeCompleted ?? this.dailyChallengeCompleted,
        dailyStreak: dailyStreak ?? this.dailyStreak,
        history: history ?? this.history,
        unlockedCosmetics: unlockedCosmetics ?? this.unlockedCosmetics,
        selectedCosmetic: selectedCosmetic ?? this.selectedCosmetic,
      );
}

/// Predefined list of game achievements.
final List<Achievement> defaultAchievements = [
  const Achievement(
    id: 'master_deceiver',
    title: 'Master Deceiver',
    description: 'Win 10 games as an imposter.',
    iconName: 'masks',
    maxProgress: 10,
    progress: 5,
  ),
  const Achievement(
    id: 'detective',
    title: 'Top Detective',
    description: 'Catch 20 imposters across rounds.',
    iconName: 'search',
    maxProgress: 20,
    progress: 9,
  ),
  const Achievement(
    id: 'invisible_imposter',
    title: 'Invisible Imposter',
    description: 'Win without receiving a single vote.',
    iconName: 'visibility_off',
    maxProgress: 1,
    progress: 1,
    unlocked: true,
  ),
  const Achievement(
    id: 'survivor',
    title: 'Ultimate Survivor',
    description: 'Survive 5 consecutive rounds without elimination.',
    iconName: 'shield',
    maxProgress: 5,
    progress: 3,
  ),
  const Achievement(
    id: 'smooth_talker',
    title: 'Smooth Talker',
    description: 'Successfully deceive the squad 3 times in a row.',
    iconName: 'record_voice_over',
    maxProgress: 3,
    progress: 2,
  ),
  const Achievement(
    id: 'party_starter',
    title: 'Party Starter',
    description: 'Host a game session with 6 or more players.',
    iconName: 'celebration',
    maxProgress: 1,
    progress: 1,
    unlocked: true,
  ),
];
