import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../services/invite_links.dart';
import '../../services/supabase/chat_service.dart';
import '../../services/supabase/models.dart';
import '../../services/supabase/multiplayer_providers.dart';
import '../../services/supabase/social_service.dart';
import '../../services/supabase/supabase_service.dart';
import '../../services/supabase/voice_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/motion.dart';
import '../widgets/room_comms.dart';
import '../widgets/visuals.dart';
import 'online_social_screens.dart';

/// Uppercases, drops spaces and symbols, and pulls a code out of a pasted
/// invitation link or message.
class RoomCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final raw = newValue.text;
    final pasted = raw.length - oldValue.text.length > 1;
    var code = pasted ? (InviteLinks.extractCode(raw) ?? '') : '';
    if (code.isEmpty) code = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (code.length > 6) code = code.substring(0, 6);
    return TextEditingValue(
      text: code,
      selection: TextSelection.collapsed(offset: code.length),
    );
  }
}

/// Online lobby: sign-in gate, host or join, then the waiting room.
class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  ConsumerState<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  final _codeCtrl = TextEditingController();
  String? _openedSessionId;
  bool _starting = false;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _codeCtrl.addListener(() => setState(() {}));
    _lifecycle = AppLifecycleListener(
      onResume: () {
        ref.read(onlineLobbyProvider.notifier).refresh();
        ref.read(voiceProvider.notifier).onAppResumed();
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _onSignedIn());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  void _onSignedIn() {
    if (!mounted || SupabaseService.currentUser == null) return;
    ref.read(onlineLobbyProvider.notifier).checkResumable();
  }

  ({String name, int avatar}) _me() {
    final p = ref.read(myProfileProvider).value;
    return (name: p?.displayName ?? 'Player', avatar: p?.avatarIndex ?? 0);
  }

  Future<void> _host() async {
    final me = _me();
    await ref
        .read(onlineLobbyProvider.notifier)
        .createRoom(displayName: me.name, avatar: me.avatar, config: ref.read(settingsProvider).game.toJson());
  }

  Future<void> _join([String? code]) async {
    final c = code ?? _codeCtrl.text;
    if (!InviteLinks.isValidCode(c)) {
      toast(context, 'Room codes are 6 letters and numbers, like 7TUPEM.');
      return;
    }
    FocusScope.of(context).unfocus();
    final me = _me();
    if (await ref.read(onlineLobbyProvider.notifier).joinRoom(code: c, displayName: me.name, avatar: me.avatar)) {
      _codeCtrl.clear();
    }
  }

  Future<void> _editName() async {
    final social = ref.read(socialServiceProvider);
    if (social == null) return;
    final ctrl = TextEditingController(text: _me().name);
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: HushbugColors.cardSurface,
        title: const Text('Your name', style: TextStyle(color: Colors.white, fontSize: 17)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 20,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white),
          onSubmitted: (v) => Navigator.pop(c, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, ctrl.text), child: const Text('Save')),
        ],
      ),
    );
    ctrl.dispose();
    if (name == null || name.trim().isEmpty) return;
    try {
      await social.myProfile(displayName: name.trim()).timeout(rpcTimeout);
      ref.invalidate(myProfileProvider);
    } catch (e) {
      if (mounted) toast(context, friendlyError(e));
    }
  }

  /// Opens the game screen once per round, replacing a finished round's screen.
  void _openGame(String sessionId) {
    if (!mounted || _openedSessionId == sessionId) return;
    _openedSessionId = sessionId;
    final router = GoRouter.of(context);
    final path = '/multiplayer/play/$sessionId';
    if (router.routerDelegate.currentConfiguration.uri.path.startsWith('/multiplayer/play/')) {
      router.pushReplacement(path);
    } else {
      router.push(path);
    }
  }

  Future<void> _followRoomIntoGame(String roomId) async {
    final session = await ref.read(supabaseGameServiceProvider)?.fetchSessionByRoom(roomId);
    if (session != null && session.phase != 'result') _openGame(session.id);
  }

  Future<void> _backToGame() async {
    final room = ref.read(onlineLobbyProvider).room;
    if (room == null) return;
    final session = await ref.read(supabaseGameServiceProvider)?.fetchSessionByRoom(room.id);
    if (session != null && mounted) context.push('/multiplayer/play/${session.id}');
  }

  Future<void> _start() async {
    final room = ref.read(onlineLobbyProvider).room;
    final svc = ref.read(supabaseGameServiceProvider);
    if (room == null || svc == null || _starting) return;
    setState(() => _starting = true);
    try {
      _openGame(await svc.startGame(room.id));
    } catch (e) {
      if (mounted) toast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  void _share(OnlineRoom room) {
    final link = InviteLinks.linkFor(room.code);
    SharePlus.instance.share(
      ShareParams(
        subject: 'Play Hushbug with me',
        text: "Join my Hushbug room! Tap $link or enter code ${room.code} in Online Multiplayer.",
      ),
    );
  }

  void _copy(String text, String what) {
    Clipboard.setData(ClipboardData(text: text));
    toast(context, '$what copied');
  }

  void _openRoomSettings(OnlineRoom room) {
    var rounds = room.totalRounds;
    var mode = room.voteMode;
    var visibility = room.voteVisibility;
    var clue = room.voicePolicy['clue'] != false;
    var vote = room.voicePolicy['vote'] != false;
    var saving = false;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: HushbugColors.cardSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) {
          Widget label(String t) => Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
            child: Text(
              t,
              style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          );
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Room settings',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  label('NUMBER OF ROUNDS'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Fewer rounds',
                        onPressed: rounds > 1 ? () => setSheet(() => rounds--) : null,
                        icon: const Icon(Icons.remove_rounded),
                      ),
                      SizedBox(
                        width: 120,
                        child: Text(
                          '$rounds round${rounds == 1 ? '' : 's'}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: HushbugColors.accentYellow, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'More rounds',
                        onPressed: rounds < 10 ? () => setSheet(() => rounds++) : null,
                        icon: const Icon(Icons.add_rounded),
                      ),
                    ],
                  ),
                  label('VOTING'),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'simultaneous', label: Text('Everyone at once')),
                      ButtonSegment(value: 'sequential', label: Text('One at a time')),
                    ],
                    selected: {mode},
                    onSelectionChanged: (v) => setSheet(() => mode = v.first),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'private', label: Text('Secret ballots')),
                      ButtonSegment(value: 'public', label: Text('Show who voted whom')),
                    ],
                    selected: {visibility},
                    onSelectionChanged: (v) => setSheet(() => visibility = v.first),
                  ),
                  label('VOICE CHAT'),
                  const ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 4),
                    title: Text('Secret word reveal', style: TextStyle(color: Colors.white)),
                    trailing: Text('Always off', style: TextStyle(color: HushbugColors.textMuted)),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('Voice during clues', style: TextStyle(color: Colors.white)),
                    value: clue,
                    onChanged: (v) => setSheet(() => clue = v),
                  ),
                  SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('Voice during voting', style: TextStyle(color: Colors.white)),
                    value: vote,
                    onChanged: (v) => setSheet(() => vote = v),
                  ),
                  const SizedBox(height: 12),
                  TactileButton(
                    onPressed: saving
                        ? null
                        : () async {
                            setSheet(() => saving = true);
                            final lobby = ref.read(onlineLobbyProvider.notifier);
                            await lobby.updateSettings(totalRounds: rounds, voteMode: mode, voteVisibility: visibility);
                            await lobby.setVoicePolicy(clue: clue, vote: vote);
                            if (c.mounted) Navigator.pop(c);
                          },
                    style: TactileButtonStyle.golden,
                    height: 50,
                    icon: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: HushbugColors.onAccentYellow),
                          )
                        : null,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lobby = ref.watch(onlineLobbyProvider);
    ref.watch(roomChatProvider); // Keeps chat subscribed while in a room.
    ref.watch(voiceProvider);

    ref.listen(authUserProvider.select((u) => u.value?.id), (prev, id) {
      if (id != null && prev == null) _onSignedIn();
    });
    ref.listen(onlineLobbyProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        toast(context, next.error!);
        ref.read(onlineLobbyProvider.notifier).clearError();
      }
      final room = next.room;
      if (room == null || room.status != 'playing') return;
      final newMatch = prev?.room?.status != 'playing';
      final newRound = prev?.room?.currentRound != room.currentRound;
      if (newMatch || newRound) _followRoomIntoGame(room.id);
    });

    final user = ref.watch(authUserProvider).value ?? SupabaseService.currentUser;
    if (user == null) return const OnlineSignInView();

    final room = lobby.room;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: room != null ? 'Leave room' : 'Back',
                      onPressed: () => room != null ? _confirmLeave() : context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Online Multiplayer',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Friends',
                      onPressed: () => context.push('/friends'),
                      icon: const Icon(Icons.group_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: room != null ? _lobbyView(lobby, room) : _entryView(lobby),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLeave() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: HushbugColors.cardSurface,
        title: const Text('Leave this room?', style: TextStyle(color: Colors.white, fontSize: 17)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Stay')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Leave')),
        ],
      ),
    );
    if (ok == true) await ref.read(onlineLobbyProvider.notifier).leave();
  }

  // ------------------------------------------------------------ entry

  Widget _entryView(OnlineLobbyState lobby) {
    final profile = ref.watch(myProfileProvider);
    final resumable = lobby.resumable;
    final busy = lobby.isLoading;
    final codeReady = InviteLinks.isValidCode(_codeCtrl.text);

    return ListView(
      children: [
        const Appear(
          scaleFrom: 0.92,
          child: Center(child: Mascot(size: 90, mood: MascotMood.detective)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Play with friends',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 16),

        // Profile name: saved to the account, reused everywhere.
        _Card(
          child: Row(
            children: [
              profile.isLoading && profile.value == null
                  ? const _Skeleton(width: 36, height: 36, circle: true)
                  : PlayerAvatar(
                      index: 0,
                      name: profile.value?.displayName ?? '',
                      radius: 18,
                      avatarIndex: profile.value?.avatarIndex ?? 0,
                    ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PLAYING AS',
                      style: TextStyle(color: HushbugColors.textSubtext, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                    profile.isLoading && profile.value == null
                        ? const _Skeleton(width: 110, height: 16)
                        : Text(
                            profile.value?.displayName ?? 'Player',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                  ],
                ),
              ),
              if (profile.hasError)
                TextButton(onPressed: () => ref.invalidate(myProfileProvider), child: const Text('Retry'))
              else
                TextButton.icon(onPressed: _editName, icon: const Icon(Icons.edit_rounded, size: 16), label: const Text('Edit')),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (resumable != null) ...[
          TactileButton(
            onPressed: busy ? null : () => _join(resumable.code),
            style: TactileButtonStyle.golden,
            height: 48,
            icon: const Icon(Icons.replay_rounded, color: HushbugColors.onAccentYellow, size: 20),
            child: Text('Rejoin room ${resumable.code}'),
          ),
          const SizedBox(height: 12),
        ],

        // Join: the most common action, so it comes first.
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Join a room',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text('Type or paste the code your friend shared.', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
              const SizedBox(height: 12),
              TextField(
                controller: _codeCtrl,
                enabled: !busy,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                inputFormatters: [RoomCodeFormatter()],
                textInputAction: TextInputAction.go,
                onSubmitted: (_) => _join(),
                style: const TextStyle(color: HushbugColors.accentYellow, letterSpacing: 8, fontWeight: FontWeight.w900, fontSize: 28),
                decoration: InputDecoration(
                  hintText: 'ABC123',
                  hintStyle: TextStyle(color: HushbugColors.textMuted.withValues(alpha: 0.5), letterSpacing: 8),
                  filled: true,
                  fillColor: const Color(0xFF161224),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF3B2E63)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF3B2E63)),
                  ),
                  suffixIcon: IconButton(
                    tooltip: 'Paste',
                    onPressed: busy
                        ? null
                        : () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            final code = InviteLinks.extractCode(data?.text ?? '');
                            if (code != null) {
                              _codeCtrl.text = code;
                            } else if (mounted) {
                              toast(context, 'No room code found on the clipboard.');
                            }
                          },
                    icon: const Icon(Icons.content_paste_rounded, color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TactileButton(
                onPressed: busy || !codeReady ? null : _join,
                style: TactileButtonStyle.golden,
                height: 50,
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: HushbugColors.onAccentYellow),
                      )
                    : null,
                child: Text(busy ? 'Joining…' : 'Join Room'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Host a room',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    SizedBox(height: 2),
                    Text('Get a code to share and pick the rounds.', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: TactileButton(
                  onPressed: busy ? null : _host,
                  style: TactileButtonStyle.neonPurple,
                  height: 46,
                  child: const Text('Host'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ lobby

  Widget _lobbyView(OnlineLobbyState lobby, OnlineRoom room) {
    final isHost = lobby.isHost;
    final inLobby = room.status != 'playing';
    final summary = [
      '${room.totalRounds} round${room.totalRounds == 1 ? '' : 's'}',
      room.voteMode == 'sequential' ? 'one-at-a-time voting' : 'everyone votes at once',
      room.voteVisibility == 'public' ? 'votes shown after' : 'secret ballots',
    ].join(' · ');

    return Column(
      children: [
        _Card(
          borderColor: HushbugColors.neonPurple.withValues(alpha: 0.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ROOM CODE',
                          style: TextStyle(color: HushbugColors.textSubtext, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        SelectableText(
                          room.code,
                          style: const TextStyle(
                            color: HushbugColors.accentYellow,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy code',
                    onPressed: () => _copy(room.code, 'Room code'),
                    icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                  ),
                  IconButton(
                    tooltip: 'Copy invite link',
                    onPressed: () => _copy(InviteLinks.linkFor(room.code), 'Invite link'),
                    icon: const Icon(Icons.link_rounded, color: Colors.white70),
                  ),
                  IconButton(
                    tooltip: 'Share invite',
                    onPressed: () => _share(room),
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(summary, style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
                  ),
                  if (isHost && inLobby)
                    TextButton.icon(
                      onPressed: () => _openRoomSettings(room),
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text('Settings'),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        CommBar(onOpenChat: context.openRoomChat),
        if (lobby.offline)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text('Connection lost. Reconnecting…', style: TextStyle(color: HushbugColors.accentYellow, fontSize: 12)),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'PLAYERS (${lobby.players.length}/${room.maxPlayers})',
              style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800),
            ),
            const Spacer(),
            if (!isHost && inLobby)
              Text(
                lobby.isReady ? 'YOU ARE READY' : 'TAP READY WHEN SET',
                style: TextStyle(
                  color: lobby.isReady ? HushbugColors.civilianEmerald : HushbugColors.accentYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: lobby.players.isEmpty
              ? const Center(child: CircularProgressIndicator(color: HushbugColors.neonPurpleLight))
              : ListView.builder(
                  itemCount: lobby.players.length,
                  itemBuilder: (context, i) => Appear(key: ValueKey(lobby.players[i].playerId), child: _playerRow(lobby.players[i])),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TactileButton(onPressed: _confirmLeave, style: TactileButtonStyle.secondary, height: 52, child: const Text('Leave')),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: !inLobby
                  ? TactileButton(onPressed: _backToGame, style: TactileButtonStyle.golden, height: 52, child: const Text('Back to Game'))
                  : isHost
                  ? TactileButton(
                      onPressed: lobby.players.length >= 3 && !_starting ? _start : null,
                      style: TactileButtonStyle.golden,
                      height: 52,
                      icon: _starting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: HushbugColors.onAccentYellow),
                            )
                          : null,
                      child: Text(_starting ? 'Starting…' : (lobby.players.length >= 3 ? 'Start Game' : 'Need 3+ Players')),
                    )
                  : TactileButton(
                      onPressed: () => ref.read(onlineLobbyProvider.notifier).toggleReady(),
                      style: lobby.isReady ? TactileButtonStyle.secondary : TactileButtonStyle.golden,
                      height: 52,
                      child: Text(lobby.isReady ? 'Not Ready' : "I'm Ready!"),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _playerRow(OnlineRoomPlayer p) {
    final isMe = p.playerId == SupabaseService.currentUserId;
    final (status, color) = !p.isConnected
        ? ('OFFLINE', HushbugColors.textMuted)
        : p.isHost
        ? ('HOST', HushbugColors.accentYellow)
        : p.isReady
        ? ('READY', const Color(0xFF34D399))
        : ('WAITING', HushbugColors.textMuted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: HushbugColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isMe ? null : () => showPlayerActions(context, ref, p),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.isHost ? HushbugColors.accentYellow.withValues(alpha: 0.5) : HushbugColors.cardBorder),
            ),
            child: Row(
              children: [
                VoiceAvatar(
                  playerId: p.playerId,
                  child: PlayerAvatar(index: 0, name: p.displayName, radius: 15, avatarIndex: p.avatarIndex),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isMe ? '${p.displayName} (You)' : p.displayName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: p.isConnected ? Colors.white : HushbugColors.textMuted,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    status,
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.borderColor});
  final Widget child;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: HushbugColors.cardSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor ?? HushbugColors.cardBorder, width: 1.2),
    ),
    child: child,
  );
}

/// Placeholder shape shown while content loads.
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.width, required this.height, this.circle = false});
  final double width;
  final double height;
  final bool circle;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white10,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : BorderRadius.circular(6),
    ),
  );
}
