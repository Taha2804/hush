import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';

/// Screen preview for Future Online Multiplayer mode (Rooms, Lobby, Friends).
class MultiplayerScreen extends StatefulWidget {
  const MultiplayerScreen({super.key});

  @override
  State<MultiplayerScreen> createState() => _MultiplayerScreenState();
}

class _MultiplayerScreenState extends State<MultiplayerScreen> {
  final _roomCodeCtrl = TextEditingController(text: 'BUG-4892');
  bool _inLobby = false;

  final List<String> _lobbyPlayers = ['Maya (Host)', 'Sam', 'Alex', 'Jordan'];

  @override
  void dispose() {
    _roomCodeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => context.pop(),
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
                      'Online Multiplayer (Beta Preview)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: _inLobby ? _buildLobbyView() : _buildRoomSelectionView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomSelectionView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const Mascot(size: 110, mood: MascotMood.detective),
            const SizedBox(height: 12),
            const Text(
              'Party Across Devices',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect with friends on their own phones or computers. Cross-platform room codes make party setup effortless.',
              textAlign: TextAlign.center,
              style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13),
            ),
          ],
        ),

        // Create or Join Cards
        Column(
          children: [
            // Create Room Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: HushbugColors.cardSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_circle_outline_rounded, color: HushbugColors.neonPurpleLight, size: 24),
                      SizedBox(width: 10),
                      Text('Create Private Room',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Host a private deduction game and share the 6-character room code with your friends.',
                      style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
                  const SizedBox(height: 14),
                  TactileButton(
                    onPressed: () => setState(() => _inLobby = true),
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: HushbugColors.cardSurface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: HushbugColors.cardBorder, width: 1.2),
              ),
              child: Column(
                children: [
                  const Row(
                    children: [
                      Icon(Icons.login_rounded, color: HushbugColors.accentYellow, size: 24),
                      SizedBox(width: 10),
                      Text('Join Existing Room',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
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
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: HushbugColors.accentYellow,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w900,
                          fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'ROOM CODE',
                        hintStyle: TextStyle(color: HushbugColors.textMuted, letterSpacing: 1),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TactileButton(
                    onPressed: () => setState(() => _inLobby = true),
                    style: TactileButtonStyle.golden,
                    height: 48,
                    child: const Text('Enter Room'),
                  ),
                ],
              ),
            ),
          ],
        ),

        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline_rounded, color: HushbugColors.textMuted, size: 14),
            SizedBox(width: 6),
            Text(
              'Online matchmaking server interface architecture preview',
              style: TextStyle(color: HushbugColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLobbyView() {
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
                  const Text('ROOM CODE',
                      style: TextStyle(color: HushbugColors.textSubtext, fontSize: 10, fontWeight: FontWeight.bold)),
                  Text(
                    _roomCodeCtrl.text,
                    style: const TextStyle(
                        color: HushbugColors.accentYellow,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Copy Code',
                onPressed: () {},
                icon: const Icon(Icons.copy_rounded, color: Colors.white70),
              ),
            ],
          ),
        ),

        // Connected Players List
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListView.builder(
              itemCount: _lobbyPlayers.length,
              itemBuilder: (context, i) {
                final name = _lobbyPlayers[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: HushbugColors.cardSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HushbugColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      PlayerAvatar(index: i, name: name, radius: 14),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x3310B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('READY',
                            style: TextStyle(
                                color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

        // Start / Leave Buttons
        Row(
          children: [
            Expanded(
              child: TactileButton(
                onPressed: () => setState(() => _inLobby = false),
                style: TactileButtonStyle.secondary,
                height: 52,
                child: const Text('Leave'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: TactileButton(
                onPressed: () => context.push('/setup'),
                style: TactileButtonStyle.golden,
                height: 52,
                child: const Text('Launch Game'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
