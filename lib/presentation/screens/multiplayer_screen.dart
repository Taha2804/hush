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
import '../widgets/neon.dart';
import '../widgets/room_comms.dart';
import '../widgets/visuals.dart';
import 'online_social_screens.dart';
import '../widgets/hush_loader.dart';
import '../widgets/busy_overlay.dart';

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
      await ref.read(manualBusyProvider.notifier).run('Saving your name…', () => social.myProfile(displayName: name.trim()).timeout(rpcTimeout));
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
      _openGame(await ref.read(manualBusyProvider.notifier).run('Starting the game…', () => svc.startGame(room.id)));
    } catch (e) {
      if (mounted) toast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  /// Friends list with one-tap invites, plus a share link for everyone else.
  void _showInviteSheet(OnlineRoom room) {
    ref.invalidate(friendsProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => _InviteFriendsSheet(room: room, onShare: () => _share(room)),
    );
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
    var clueSeconds = ((room.config['clueSeconds'] as num?) ?? 60).toInt().clamp(20, 180);
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
                  label('TIME FOR EACH CLUE'),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  IconButton.filledTonal(
                    tooltip: 'Less time',
                    onPressed: clueSeconds > 20 ? () => setSheet(() => clueSeconds -= 10) : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  SizedBox(
                    width: 120,
                    child: Text('${clueSeconds}s',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: HushbugColors.accentYellow, fontSize: 22, fontWeight: FontWeight.w900)),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'More time',
                    onPressed: clueSeconds < 180 ? () => setSheet(() => clueSeconds += 10) : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ]),
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
                            await lobby.updateSettings(totalRounds: rounds, voteMode: mode, voteVisibility: visibility, clueSeconds: clueSeconds);
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
    return NeonBackdrop(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              child: Row(
                children: [
                  NeonRoundButton(
                    icon: Icons.arrow_back_rounded,
                    label: room != null ? 'Leave room' : 'Back',
                    size: 48,
                    onPressed: () => room != null ? _confirmLeave() : context.pop(),
                  ),
                  Expanded(child: NeonTitle(room != null ? 'Lobby' : 'Play online', size: 24)),
                  NeonRoundButton(icon: Icons.group_rounded, label: 'Friends', size: 48, onPressed: () => context.push('/friends')),
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
    final uid = SupabaseService.currentUserId;
    final details = [
      room.voteMode == 'sequential' ? 'One at a time' : 'Everyone votes at once',
      room.voteVisibility == 'public' ? 'votes shown after' : 'secret ballots',
    ].join(' · ');

    return Column(children: [
      GlassPanel(
        radius: 32,
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
        child: Row(children: [
          Expanded(
            child: Semantics(
              label: 'Room code ${room.code.split('').join(' ')}',
              child: ExcludeSemantics(
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                  for (final ch in room.code.split(''))
                    Container(
                      width: 34,
                      height: 42,
                      decoration: BoxDecoration(color: const Color(0xFF3B2470), borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      child: Text(ch, style: const TextStyle(fontFamily: 'Fredoka', fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFE8DBFF))),
                    ),
                ]),
              ),
            ),
          ),
          NeonRoundButton(icon: Icons.copy_rounded, label: 'Copy room code', size: 46, onPressed: () => _copy(room.code, 'Room code')),
          const SizedBox(width: 6),
          NeonRoundButton(icon: Icons.share_rounded, label: 'Share invite', size: 46, active: true, onPressed: () => _share(room)),
        ]),
      ),
      const SizedBox(height: 10),
      CommBar(onOpenChat: context.openRoomChat),
      if (lobby.offline)
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Text('Connection lost. Reconnecting…', style: TextStyle(color: HushbugColors.accentYellow, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      Expanded(
        child: lobby.players.isEmpty
            ? const Center(child: HushbugLoader(text: 'Joining the room…'))
            : SingleChildScrollView(
                padding: const EdgeInsets.only(top: 28, bottom: 8),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 30,
                  children: [
                    for (final p in lobby.players)
                      SizedBox(
                        width: 100,
                        child: Appear(
                          key: ValueKey(p.playerId),
                          child: GestureDetector(
                            onTap: p.playerId == uid ? null : () => showPlayerActions(context, ref, p),
                            child: NeonSeat(
                              name: p.playerId == uid ? '${p.displayName} (you)' : p.displayName,
                              avatarIndex: p.avatarIndex,
                              crown: p.isHost,
                              tick: !p.isHost && p.isReady,
                              highlight: p.isHost,
                              dim: !p.isConnected,
                              caption: !p.isConnected ? 'Offline' : (p.isHost || p.isReady ? null : 'Not ready'),
                            ),
                          ),
                        ),
                      ),
                    if (inLobby)
                      SizedBox(
                        width: 100,
                        child: Semantics(
                          button: true,
                          label: 'Invite friends',
                          child: InkResponse(
                            onTap: () => _showInviteSheet(room),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color(0x99C9B0FF), width: 2)),
                                child: const Icon(Icons.add_rounded, size: 32, color: Color(0xFFE6D2FF)),
                              ),
                              const SizedBox(height: 6),
                              const Text('Invite', style: TextStyle(color: Color(0xFFC9B0FF), fontSize: 13, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
      Semantics(
        button: isHost && inLobby,
        label: '${room.totalRounds} rounds, $details${isHost && inLobby ? '. Change room settings' : ''}',
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: isHost && inLobby ? () => _openRoomSettings(room) : null,
          child: GlassPanel(
            radius: 24,
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: ExcludeSemantics(
              child: Row(children: [
                const Icon(Icons.settings_rounded, color: Color(0xFFC9B0FF)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${room.totalRounds} round${room.totalRounds == 1 ? '' : 's'}',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                    Text(details, style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 13, fontWeight: FontWeight.w700)),
                  ]),
                ),
                if (isHost && inLobby) const Icon(Icons.chevron_right_rounded, color: Color(0xFFE6D2FF)),
              ]),
            ),
          ),
        ),
      ),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(
          child: TactileButton(onPressed: _confirmLeave, style: TactileButtonStyle.secondary, height: 58, child: const Text('Leave')),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: !inLobby
              ? TactileButton(onPressed: _backToGame, style: TactileButtonStyle.golden, height: 58, child: const Text('Back to game'))
              : isHost
                  ? TactileButton(
                      onPressed: lobby.players.length >= 3 && !_starting ? _start : null,
                      style: TactileButtonStyle.golden,
                      height: 58,
                      icon: _starting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: HushbugColors.onAccentYellow))
                          : const Icon(Icons.play_arrow_rounded, size: 30),
                      child: Text(_starting ? 'Starting…' : (lobby.players.length >= 3 ? 'Start' : 'Need 3 players')),
                    )
                  : TactileButton(
                      onPressed: () => ref.read(onlineLobbyProvider.notifier).toggleReady(),
                      style: lobby.isReady ? TactileButtonStyle.secondary : TactileButtonStyle.golden,
                      height: 58,
                      child: Text(lobby.isReady ? 'Not ready' : "I'm ready!"),
                    ),
        ),
      ]),
    ]);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => GlassPanel(padding: const EdgeInsets.all(16), child: child);
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

class _InviteFriendsSheet extends ConsumerStatefulWidget {
  const _InviteFriendsSheet({required this.room, required this.onShare});
  final OnlineRoom room;
  final VoidCallback onShare;

  @override
  ConsumerState<_InviteFriendsSheet> createState() => _InviteFriendsSheetState();
}

class _InviteFriendsSheetState extends ConsumerState<_InviteFriendsSheet> {
  final _invited = <String>{};
  final _sending = <String>{};

  Future<void> _invite(FriendEntry f) async {
    final social = ref.read(socialServiceProvider);
    if (social == null || _sending.contains(f.userId)) return;
    setState(() => _sending.add(f.userId));
    try {
      await social.invite(widget.room.id, f.userId).timeout(rpcTimeout);
      if (mounted) setState(() => _invited.add(f.userId));
    } catch (e) {
      if (mounted) toast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _sending.remove(f.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final friends = ref.watch(friendsProvider);
    final inRoom = {for (final p in ref.watch(onlineLobbyProvider).players) p.playerId};
    final list = [
      for (final f in friends.value ?? const <FriendEntry>[])
        if (f.status == 'friend') f,
    ]..sort((a, b) => (b.online ? 1 : 0) - (a.online ? 1 : 0));

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.7),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const NeonTitle('Invite friends', size: 24),
            const SizedBox(height: 4),
            Text('They get a pop-up to join room ${widget.room.code}.',
                textAlign: TextAlign.center, style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            Flexible(
              child: friends.isLoading && list.isEmpty
                  ? const Center(child: HushbugLoader(size: 70, text: 'Loading your friends…'))
                  : list.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Text('No friends yet. Share the link below, or add friends with their friend code in the Friends screen.',
                              textAlign: TextAlign.center, style: TextStyle(color: HushbugColors.textSubtext, fontSize: 14, fontWeight: FontWeight.w700)),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: list.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (_, i) {
                            final f = list[i];
                            final here = inRoom.contains(f.userId);
                            final invited = _invited.contains(f.userId);
                            final sending = _sending.contains(f.userId);
                            return GlassPanel(
                              radius: 30,
                              padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                              child: Row(children: [
                                NeonSeat(name: f.displayName, avatarIndex: f.avatarIndex, size: 46, showName: false),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(f.displayName, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                    Row(children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: f.online ? HushbugColors.civilianEmerald : HushbugColors.textMuted),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(f.online ? 'Online' : 'Offline', style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 12, fontWeight: FontWeight.w700)),
                                    ]),
                                  ]),
                                ),
                                SizedBox(
                                  width: 112,
                                  child: here
                                      ? const Center(child: Text('In the room', style: TextStyle(color: HushbugColors.civilianEmerald, fontSize: 13, fontWeight: FontWeight.w800)))
                                      : TactileButton(
                                          onPressed: invited || sending ? null : () => _invite(f),
                                          style: TactileButtonStyle.golden,
                                          height: 44,
                                          child: Text(sending ? 'Sending…' : (invited ? 'Invited ✓' : 'Invite'), style: const TextStyle(fontSize: 15)),
                                        ),
                                ),
                              ]),
                            );
                          },
                        ),
            ),
            const SizedBox(height: 14),
            TactileButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onShare();
              },
              style: TactileButtonStyle.neonPurple,
              height: 54,
              icon: const Icon(Icons.share_rounded, size: 22),
              child: const Text('Share invite link'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.push('/friends');
              },
              child: const Text('Add a friend by code'),
            ),
          ]),
        ),
      ),
    );
  }
}
