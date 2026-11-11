import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../services/invite_links.dart';
import '../../services/supabase/models.dart';
import '../../services/supabase/multiplayer_providers.dart';
import '../../services/supabase/social_service.dart';
import '../../services/supabase/supabase_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/visuals.dart';
import 'online_social_screens.dart';
import '../widgets/hush_loader.dart';
import '../widgets/busy_overlay.dart';

final _previewProvider = FutureProvider.autoDispose.family<RoomPreview, String>((ref, code) async {
  ref.watch(authUserProvider); // Re-check after sign-in: "member" depends on who asks.
  final svc = ref.watch(supabaseRoomServiceProvider);
  if (svc == null) throw Exception('offline');
  return svc.peekRoom(code);
});

/// Shown when an invitation link or a friend's invite is opened. Joining
/// always needs the player to tap Join.
class InviteScreen extends ConsumerStatefulWidget {
  const InviteScreen({super.key, required this.code});
  final String code;

  @override
  ConsumerState<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends ConsumerState<InviteScreen> {
  bool _joining = false;

  Future<void> _clearPending() => InviteLinks.clearPending(ref.read(bootstrapProvider).prefs);

  Future<void> _join() async {
    if (_joining) return;
    setState(() => _joining = true);
    final profile = await ref.read(manualBusyProvider.notifier).run('Joining the room…', () => ref.read(myProfileProvider.future).catchError((_) => null));
    final ok = await ref.read(onlineLobbyProvider.notifier).joinRoom(
          code: widget.code,
          displayName: profile?.displayName ?? 'Player',
          avatar: profile?.avatarIndex ?? 0,
        );
    if (!mounted) return;
    setState(() => _joining = false);
    if (ok) {
      await _clearPending();
      if (mounted) context.go('/multiplayer');
    } else {
      toast(context, ref.read(onlineLobbyProvider).error ?? 'Could not join the room.');
      ref.read(onlineLobbyProvider.notifier).clearError();
      ref.invalidate(_previewProvider(widget.code));
    }
  }

  Future<void> _decline() async {
    await _clearPending();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider).value ?? SupabaseService.currentUser;
    final preview = ref.watch(_previewProvider(widget.code));

    if (!InviteLinks.isValidCode(widget.code)) {
      return _frame(context, _Problem(text: "That invitation link isn't valid.", onClose: _decline));
    }
    if (user == null) {
      // The invite stays saved, so it is shown again right after sign-in.
      return const OnlineSignInView(subtitle: 'Sign in to accept your room invitation.');
    }

    return _frame(
      context,
      preview.when(
        loading: () => const Column(mainAxisSize: MainAxisSize.min, children: [
          HushbugLoader(text: 'Checking your invitation…'),
        ]),
        error: (_, _) => _Problem(
          text: 'No connection. Check your internet and try again.',
          onRetry: () => ref.invalidate(_previewProvider(widget.code)),
          onClose: _decline,
        ),
        data: (room) => !room.canJoin
            ? _Problem(text: room.problem, onClose: _decline)
            : Column(mainAxisSize: MainAxisSize.min, children: [
                const Mascot(size: 110, mood: MascotMood.happy),
                const SizedBox(height: 14),
                Text("You're invited!", style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(
                  '${room.hostName ?? 'A friend'} is hosting room ${room.code}.\n${room.playerCount} of ${room.maxPlayers} players are in.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 14),
                ),
                const SizedBox(height: 28),
                TactileButton(
                  onPressed: _joining ? null : _join,
                  style: TactileButtonStyle.golden,
                  height: 52,
                  icon: _joining
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: HushbugColors.onAccentYellow))
                      : null,
                  child: Text(room.status == 'member' ? 'Return to Room' : 'Join Room'),
                ),
                const SizedBox(height: 10),
                TextButton(onPressed: _joining ? null : _decline, child: const Text('Not now')),
              ]),
      ),
    );
  }

  Widget _frame(BuildContext context, Widget child) => Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
          child: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: child))),
        ),
      );
}

class _Problem extends StatelessWidget {
  const _Problem({required this.text, required this.onClose, this.onRetry});
  final String text;
  final VoidCallback onClose;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
        const Mascot(size: 100, mood: MascotMood.sad),
        const SizedBox(height: 14),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        if (onRetry != null) FilledButton(onPressed: onRetry, child: const Text('Try again')),
        TextButton(onPressed: onClose, child: const Text('Back to Home')),
      ]);
}
