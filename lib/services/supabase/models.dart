/// Data models for Supabase Online Multiplayer Game Sessions.

class OnlineRoom {
  const OnlineRoom({
    required this.id,
    required this.code,
    required this.hostId,
    required this.status,
    required this.maxPlayers,
    required this.config,
    this.createdAt,
  });

  final String id;
  final String code;
  final String hostId;
  final String status;
  final int maxPlayers;
  final Map<String, dynamic> config;
  final DateTime? createdAt;

  factory OnlineRoom.fromJson(Map<String, dynamic> j) => OnlineRoom(
        id: j['id']?.toString() ?? '',
        code: j['code']?.toString() ?? '',
        hostId: j['host_id']?.toString() ?? '',
        status: j['status']?.toString() ?? 'waiting',
        maxPlayers: (j['max_players'] as num?)?.toInt() ?? 12,
        config: Map<String, dynamic>.from(j['config'] as Map? ?? {}),
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? ''),
      );
}

class OnlineRoomPlayer {
  const OnlineRoomPlayer({
    required this.id,
    required this.roomId,
    required this.playerId,
    required this.displayName,
    required this.avatarIndex,
    required this.isHost,
    required this.isReady,
    required this.isConnected,
    this.joinedAt,
  });

  final String id;
  final String roomId;
  final String playerId;
  final String displayName;
  final int avatarIndex;
  final bool isHost;
  final bool isReady;
  final bool isConnected;
  final DateTime? joinedAt;

  factory OnlineRoomPlayer.fromJson(Map<String, dynamic> j) => OnlineRoomPlayer(
        id: j['id']?.toString() ?? '',
        roomId: j['room_id']?.toString() ?? '',
        playerId: j['player_id']?.toString() ?? '',
        displayName: j['display_name']?.toString() ?? 'Player',
        avatarIndex: (j['avatar_index'] as num?)?.toInt() ?? 0,
        isHost: (j['is_host'] as bool?) ?? false,
        isReady: (j['is_ready'] as bool?) ?? false,
        isConnected: (j['is_connected'] as bool?) ?? true,
        joinedAt: DateTime.tryParse(j['joined_at']?.toString() ?? ''),
      );
}

class OnlineGameSession {
  const OnlineGameSession({
    required this.id,
    required this.roomId,
    required this.roundNumber,
    required this.phase,
    required this.category,
    required this.mode,
    required this.starterId,
    required this.turnOrder,
    required this.clueStep,
    this.discussionStartTime,
    this.discussionEndTime,
    this.timerPaused = false,
    this.timerRemainingSeconds = 0,
    this.winner,
    this.winReason,
  });

  final String id;
  final String roomId;
  final int roundNumber;
  final String phase; // reveal, clue, discussion, vote, last_chance, result
  final String category;
  final String mode;
  final String starterId;
  final List<String> turnOrder;
  final int clueStep;
  final DateTime? discussionStartTime;
  final DateTime? discussionEndTime;
  final bool timerPaused;
  final int timerRemainingSeconds;
  final String? winner;
  final String? winReason;

  factory OnlineGameSession.fromJson(Map<String, dynamic> j) => OnlineGameSession(
        id: j['id']?.toString() ?? '',
        roomId: j['room_id']?.toString() ?? '',
        roundNumber: (j['round_number'] as num?)?.toInt() ?? 1,
        phase: j['phase']?.toString() ?? 'reveal',
        category: j['category']?.toString() ?? '',
        mode: j['mode']?.toString() ?? 'hint',
        starterId: j['starter_id']?.toString() ?? '',
        turnOrder: (j['turn_order'] as List? ?? []).map((e) => e.toString()).toList(),
        clueStep: (j['clue_step'] as num?)?.toInt() ?? 0,
        discussionStartTime: DateTime.tryParse(j['discussion_start_time']?.toString() ?? ''),
        discussionEndTime: DateTime.tryParse(j['discussion_end_time']?.toString() ?? ''),
        timerPaused: (j['timer_paused'] as bool?) ?? false,
        timerRemainingSeconds: (j['timer_remaining_seconds'] as num?)?.toInt() ?? 0,
        winner: j['winner']?.toString(),
        winReason: j['win_reason']?.toString(),
      );
}

class OnlineGamePlayer {
  const OnlineGamePlayer({
    required this.id,
    required this.sessionId,
    required this.playerId,
    required this.displayName,
    required this.avatarIndex,
    required this.isAlive,
    required this.isEliminated,
    this.eliminatedRound,
  });

  final String id;
  final String sessionId;
  final String playerId;
  final String displayName;
  final int avatarIndex;
  final bool isAlive;
  final bool isEliminated;
  final int? eliminatedRound;

  factory OnlineGamePlayer.fromJson(Map<String, dynamic> j) => OnlineGamePlayer(
        id: j['id']?.toString() ?? '',
        sessionId: j['session_id']?.toString() ?? '',
        playerId: j['player_id']?.toString() ?? '',
        displayName: j['display_name']?.toString() ?? 'Player',
        avatarIndex: (j['avatar_index'] as num?)?.toInt() ?? 0,
        isAlive: (j['is_alive'] as bool?) ?? true,
        isEliminated: (j['is_eliminated'] as bool?) ?? false,
        eliminatedRound: (j['eliminated_round'] as num?)?.toInt(),
      );
}

class OnlinePrivateAssignment {
  const OnlinePrivateAssignment({
    required this.isImposter,
    required this.word,
    this.hint,
    this.fakeWord,
    this.teammates = const [],
  });

  final bool isImposter;
  final String word;
  final String? hint;
  final String? fakeWord;
  final List<String> teammates;

  factory OnlinePrivateAssignment.fromJson(Map<String, dynamic> j) => OnlinePrivateAssignment(
        isImposter: (j['is_imposter'] as bool?) ?? false,
        word: j['word']?.toString() ?? '',
        hint: j['hint']?.toString(),
        fakeWord: j['fake_word']?.toString(),
        teammates: (j['teammates'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class OnlineClue {
  const OnlineClue({
    required this.id,
    required this.sessionId,
    required this.playerId,
    required this.clueStep,
    required this.roundNumber,
    required this.clueText,
    this.createdAt,
  });

  final String id;
  final String sessionId;
  final String playerId;
  final int clueStep;
  final int roundNumber;
  final String clueText;
  final DateTime? createdAt;

  factory OnlineClue.fromJson(Map<String, dynamic> j) => OnlineClue(
        id: j['id']?.toString() ?? '',
        sessionId: j['session_id']?.toString() ?? '',
        playerId: j['player_id']?.toString() ?? '',
        clueStep: (j['clue_step'] as num?)?.toInt() ?? 0,
        roundNumber: (j['round_number'] as num?)?.toInt() ?? 1,
        clueText: j['clue_text']?.toString() ?? '',
        createdAt: DateTime.tryParse(j['created_at']?.toString() ?? ''),
      );
}

class OnlineResult {
  const OnlineResult({
    required this.winner,
    required this.winReason,
    required this.secretWord,
    required this.imposters,
    required this.scores,
  });

  final String winner;
  final String winReason;
  final String secretWord;
  final List<String> imposters;
  final Map<String, dynamic> scores;

  factory OnlineResult.fromJson(Map<String, dynamic> j) => OnlineResult(
        winner: j['winner']?.toString() ?? 'nobody',
        winReason: j['win_reason']?.toString() ?? '',
        secretWord: j['secret_word']?.toString() ?? '',
        imposters: (j['imposters'] as List? ?? []).map((e) => e.toString()).toList(),
        scores: Map<String, dynamic>.from(j['scores'] as Map? ?? {}),
      );
}
