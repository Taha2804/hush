import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../services/supabase/multiplayer_providers.dart';
import '../../services/supabase/supabase_config.dart';
import '../../services/supabase/supabase_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';

/// Screen for Online Multiplayer Lobby and Room Setup using Supabase.
class MultiplayerScreen extends ConsumerStatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  ConsumerState<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends ConsumerState<MultiplayerScreen> {
  final _roomCodeCtrl = TextEditingController();
  final _playerNameCtrl = TextEditingController();
  int _avatarIndex = 0;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    final initialName = settings.game.players.firstOrNull ?? 'Player 1';
    _playerNameCtrl.text = initialName;
    _avatarIndex = settings.playerAvatars[initialName] ?? 0;
  }

  @override
  void dispose() {
    _roomCodeCtrl.dispose();
    _playerNameCtrl.dispose();
    super.dispose();
  }

  String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = math.Random();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  Future<void> _handleHost() async {
    final name = _playerNameCtrl.text.trim().isEmpty ? 'Host' : _playerNameCtrl.text.trim();
    final code = _generateRoomCode();
    final config = ref.read(settingsProvider).game.toJson();

    final ok = await ref.read(onlineLobbyProvider.notifier).createRoom(
          code: code,
          displayName: name,
          avatar: _avatarIndex,
          config: config,
        );

    if (!ok && mounted) {
      final err = ref.read(onlineLobbyProvider).error ?? 'Failed to create room.';
      _showSetupCredentialsDialog(context, errorMsg: err);
    }
  }

  Future<void> _handleJoin() async {
    final code = _roomCodeCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      toast(context, 'Please enter a 6-character room code.');
      return;
    }
    final name = _playerNameCtrl.text.trim().isEmpty ? 'Player' : _playerNameCtrl.text.trim();

    final ok = await ref.read(onlineLobbyProvider.notifier).joinRoom(
          code: code,
          displayName: name,
          avatar: _avatarIndex,
        );

    if (!ok && mounted) {
      final err = ref.read(onlineLobbyProvider).error ?? 'Failed to join room.';
      _showSetupCredentialsDialog(context, errorMsg: err);
    }
  }

  Future<void> _handleStartOnlineGame() async {
    final lobby = ref.read(onlineLobbyProvider);
    final room = lobby.room;
    if (room == null) return;

    final gameService = ref.read(supabaseGameServiceProvider);
    if (gameService == null) return;

    // Deal word from offline pack source
    final registry = ref.read(registryProvider);
    final offlinePacks = await registry.offline.categories();
    final category = offlinePacks.isNotEmpty ? offlinePacks.first : 'General';
    final resolved = await registry.resolve('offline', [category]);
    final pipeline = ref.read(pipelineProvider);
    final dealt = await pipeline.deal(
      sourceId: 'offline',
      pools: resolved.pools,
      hintLevel: 2,
    );

    final word = dealt?.entry.word ?? 'Astronaut';
    final hint = dealt?.hint ?? 'Space';

    try {
      final session = await gameService.startGame(
        roomId: room.id,
        category: category,
        word: word,
        hint: hint,
        imposterCount: (room.config['imposterCount'] as num?)?.toInt() ?? 1,
        discussionSeconds: (room.config['discussionSeconds'] as num?)?.toInt() ?? 180,
      );

      if (mounted) {
        context.push('/multiplayer/play/${session.sessionId}');
      }
    } catch (e) {
      if (mounted) toast(context, 'Error starting game: $e');
    }
  }

  void _showSetupCredentialsDialog(BuildContext context, {String? errorMsg}) {
    final urlCtrl = TextEditingController(text: SupabaseConfig.url);
    final keyCtrl = TextEditingController(text: SupabaseConfig.anonKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: HushbugColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Icon(Icons.cloud_sync_rounded, color: HushbugColors.accentYellow, size: 24),
            SizedBox(width: 10),
            Text('Supabase Configuration', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorMsg != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: HushbugColors.imposterBg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: HushbugColors.imposterRed.withValues(alpha: 0.5)),
                  ),
                  child: Text(errorMsg, style: const TextStyle(color: HushbugColors.imposterRed, fontSize: 11)),
                ),
                const SizedBox(height: 12),
              ],
              const Text(
                'To enable online rooms, connect to your Supabase project or deploy the database using the provided command script in supabase/setup_backend.sh.',
                style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: urlCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Project URL',
                  hintText: 'https://xyzcompany.supabase.co',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: keyCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Anon Public Key',
                  hintText: 'eyJhbGciOi...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final prefs = ref.read(bootstrapProvider).prefs;
              await SupabaseConfig.saveCredentials(prefs, url: urlCtrl.text, anonKey: keyCtrl.text);
              await SupabaseService.initialize();
              if (ctx.mounted) Navigator.of(ctx).pop();
              setState(() {});
              if (context.mounted) toast(context, 'Supabase credentials saved!');
            },
            child: const Text('Save & Connect'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lobby = ref.watch(onlineLobbyProvider);
    final inLobby = lobby.room != null;
    final isConnected = SupabaseConfig.isConfigured && SupabaseService.isInitialized;

    // Listen for room phase changes to auto-route to play screen when host starts game
    ref.listen(onlineLobbyProvider, (prev, next) async {
      if (next.room != null && next.room!.status == 'playing') {
        final gameService = ref.read(supabaseGameServiceProvider);
        if (gameService != null) {
          final session = await gameService.fetchSessionByRoom(next.room!.id);
          if (session != null && mounted) {
            context.push('/multiplayer/play/${session.id}');
          }
        }
      }
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () {
                        if (inLobby) {
                          ref.read(onlineLobbyProvider.notifier).leave();
                        } else {
                          context.pop();
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: HushbugColors.cardSurface.withValues(alpha: 0.8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: HushbugColors.cardBorder, width: 1),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                    const Text(
                      'Online Multiplayer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    // Supabase connection status pill / config modal
                    InkWell(
                      onTap: () => _showSetupCredentialsDialog(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: HushbugColors.cardSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isConnected ? HushbugColors.civilianEmerald.withValues(alpha: 0.6) : Colors.amber.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isConnected ? HushbugColors.civilianEmerald : Colors.amber,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isConnected ? 'Supabase' : 'Setup',
                              style: TextStyle(
                                color: isConnected ? HushbugColors.civilianEmerald : Colors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  child: inLobby ? _buildLobbyView(lobby) : _buildRoomSelectionView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomSelectionView() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Mascot(size: 100, mood: MascotMood.detective),
          const SizedBox(height: 10),
          const Text(
            'Party Across Devices',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          const Text(
            'Host or join private games using Supabase Realtime. Server-authoritative secret assignments protect game integrity.',
            textAlign: TextAlign.center,
            style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
          ),
          const SizedBox(height: 16),

          // Player Profile Bar
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HushbugColors.cardSurface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: HushbugColors.cardBorder),
            ),
            child: Row(
              children: [
                PlayerAvatar(index: 0, name: _playerNameCtrl.text, radius: 18, avatarIndex: _avatarIndex),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _playerNameCtrl,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      labelText: 'Your Nickname',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Create Room Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HushbugColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.add_circle_outline_rounded, color: HushbugColors.neonPurpleLight, size: 22),
                    SizedBox(width: 10),
                    Text('Host Private Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 6),
                const Text('Generate a unique 6-character room code and control round settings as host.',
                    style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
                const SizedBox(height: 14),
                TactileButton(
                  onPressed: _handleHost,
                  style: TactileButtonStyle.neonPurple,
                  height: 48,
                  child: const Text('Host New Room'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Join Room Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: HushbugColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.login_rounded, color: HushbugColors.accentYellow, size: 22),
                    SizedBox(width: 10),
                    Text('Join Existing Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF161224),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF3B2E63)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _roomCodeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: HushbugColors.accentYellow,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                    decoration: const InputDecoration(
                      hintText: '6-CHAR CODE',
                      hintStyle: TextStyle(color: HushbugColors.textMuted, letterSpacing: 1),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TactileButton(
                  onPressed: _handleJoin,
                  style: TactileButtonStyle.golden,
                  height: 48,
                  child: const Text('Enter Room'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyView(OnlineLobbyState lobby) {
    final room = lobby.room!;
    final isHost = lobby.isHost;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Room Code Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: HushbugColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: HushbugColors.neonPurple.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ROOM INVITATION CODE',
                      style: TextStyle(color: HushbugColors.textSubtext, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                    room.code,
                    style: const TextStyle(
                      color: HushbugColors.accentYellow,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Copy Code',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: room.code));
                      toast(context, 'Room code copied to clipboard!');
                    },
                    icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PLAYERS IN LOBBY (${lobby.players.length})',
              style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800),
            ),
            if (!isHost)
              Text(
                lobby.isReady ? 'READY TO PLAY' : 'TAP READY TO START',
                style: TextStyle(
                  color: lobby.isReady ? HushbugColors.civilianEmerald : HushbugColors.accentYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Connected Players List
        Expanded(
          child: ListView.builder(
            itemCount: lobby.players.length,
            itemBuilder: (context, i) {
              final p = lobby.players[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: HushbugColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: p.isHost ? HushbugColors.accentYellow.withValues(alpha: 0.5) : HushbugColors.cardBorder),
                ),
                child: Row(
                  children: [
                    PlayerAvatar(index: i, name: p.displayName, radius: 14, avatarIndex: p.avatarIndex),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            p.displayName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          if (p.isHost) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: HushbugColors.accentYellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('HOST', style: TextStyle(color: HushbugColors.accentYellow, fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.isReady || p.isHost ? const Color(0x3310B981) : Colors.white10,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.isHost ? 'HOST' : (p.isReady ? 'READY' : 'WAITING'),
                        style: TextStyle(
                          color: p.isReady || p.isHost ? const Color(0xFF34D399) : HushbugColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Start / Ready Action Row
        Row(
          children: [
            Expanded(
              child: TactileButton(
                onPressed: () => ref.read(onlineLobbyProvider.notifier).leave(),
                style: TactileButtonStyle.secondary,
                height: 52,
                child: const Text('Leave'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: isHost
                  ? TactileButton(
                      onPressed: lobby.players.length >= 3 ? _handleStartOnlineGame : null,
                      style: TactileButtonStyle.golden,
                      height: 52,
                      child: Text(lobby.players.length >= 3 ? 'Launch Game' : 'Need 3+ Players'),
                    )
                  : TactileButton(
                      onPressed: () => ref.read(onlineLobbyProvider.notifier).toggleReady(),
                      style: lobby.isReady ? TactileButtonStyle.secondary : TactileButtonStyle.golden,
                      height: 52,
                      child: Text(lobby.isReady ? 'Cancel Ready' : "I'm Ready!"),
                    ),
            ),
          ],
        ),
      ],
    );
  }
}
