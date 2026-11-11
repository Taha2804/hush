// Data models for Supabase Online Multiplayer Game Sessions.

class OnlineRoom {
  const OnlineRoom({
    required this.id,
    required this.code,
    required this.hostId,
    required this.status,
    required this.maxPlayers,
    required this.config,
    this.voicePolicy = const {},
    this.totalRounds = 3,
    this.currentRound = 0,
    this.createdAt,
  });

  final int totalRounds;
  final int currentRound;
  String get voteMode => config['voteMode'] == 'sequential' ? 'sequential' : 'simultaneous';
  String get voteVisibility => config['voteVisibility'] == 'public' ? 'public' : 'private';

  final Map<String, dynamic> voicePolicy;
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
        voicePolicy: Map<String, dynamic>.from(j['voice_policy'] as Map? ?? {}),
        totalRounds: (j['total_rounds'] as num?)?.toInt() ?? 3,
        currentRound: (j['current_round'] as num?)?.toInt() ?? 0,
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
    this.chatMuted = false,
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
  final bool chatMuted;
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
        chatMuted: (j['chat_muted'] as bool?) ?? false,
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
    this.revotes = 0,
    this.matchRound = 1,
    this.voteMode = 'simultaneous',
    this.voteVisibility = 'private',
    this.voters = const [],
    this.lastVoteSummary,
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
  final int revotes;
  final int matchRound;
  final String voteMode;
  final String voteVisibility;

  /// Players who have handed in a ballot in the current vote (never targets).
  final List<String> voters;

  /// Set when a vote closes: counts, plus who voted for whom in public mode.
  final Map<String, dynamic>? lastVoteSummary;

  bool get isSequentialVote => voteMode == 'sequential';
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
        revotes: (j['revotes'] as num?)?.toInt() ?? 0,
        matchRound: (j['match_round'] as num?)?.toInt() ?? 1,
        voteMode: j['vote_mode']?.toString() ?? 'simultaneous',
        voteVisibility: j['vote_visibility']?.toString() ?? 'private',
        voters: (j['voters'] as List? ?? []).map((e) => e.toString()).toList(),
        lastVoteSummary: j['last_vote_summary'] is Map ? Map<String, dynamic>.from(j['last_vote_summary'] as Map) : null,
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
    this.description,
    this.teammates = const [],
  });

  final bool isImposter;
  final String word;
  final String? hint;
  final String? fakeWord;

  /// What the word means. Only players who get the real word receive it.
  final String? description;
  final List<String> teammates;

  factory OnlinePrivateAssignment.fromJson(Map<String, dynamic> j) => OnlinePrivateAssignment(
        isImposter: (j['is_imposter'] as bool?) ?? false,
        word: j['word']?.toString() ?? '',
        hint: j['hint']?.toString(),
        fakeWord: j['fake_word']?.toString(),
        description: j['description']?.toString(),
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

class DiscussionEndRequest {
  const DiscussionEndRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.status,
    required this.approvals,
    required this.eligible,
    required this.expiresAt,
  });

  final String id;
  final String? requesterId;
  final String requesterName;
  final String status;
  final int approvals;
  final int eligible;
  final DateTime expiresAt;

  bool get isPending => status == 'pending' && expiresAt.isAfter(DateTime.now());

  factory DiscussionEndRequest.fromJson(Map<String, dynamic> j) => DiscussionEndRequest(
        id: j['id'].toString(),
        requesterId: j['requester_id']?.toString(),
        requesterName: j['requester_name']?.toString() ?? 'Someone',
        status: j['status']?.toString() ?? 'expired',
        approvals: (j['approvals'] as num?)?.toInt() ?? 0,
        eligible: (j['eligible'] as num?)?.toInt() ?? 0,
        expiresAt: DateTime.tryParse(j['expires_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      );
}

class MatchStanding {
  const MatchStanding(this.playerId, this.displayName, this.points);
  final String playerId;
  final String displayName;
  final int points;
}

/// What an invitation or typed room code points to.
class RoomPreview {
  const RoomPreview({required this.status, this.code, this.hostName, this.playerCount = 0, this.maxPlayers = 12});

  /// open, member, started, full, expired or not_found.
  final String status;
  final String? code;
  final String? hostName;
  final int playerCount;
  final int maxPlayers;

  bool get canJoin => status == 'open' || status == 'member';

  String get problem => switch (status) {
        'not_found' => 'No room has that code. It may have been closed.',
        'expired' => 'This room has expired.',
        'full' => 'This room is full.',
        'started' => 'That game has already started.',
        _ => '',
      };

  factory RoomPreview.fromJson(Map<String, dynamic> j) => RoomPreview(
        status: j['status']?.toString() ?? 'not_found',
        code: j['code']?.toString(),
        hostName: j['host_name']?.toString(),
        playerCount: (j['player_count'] as num?)?.toInt() ?? 0,
        maxPlayers: (j['max_players'] as num?)?.toInt() ?? 12,
      );
}
