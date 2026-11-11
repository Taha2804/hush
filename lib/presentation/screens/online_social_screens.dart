import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../services/supabase/chat_service.dart';
import '../../services/supabase/multiplayer_providers.dart';
import '../../services/supabase/social_service.dart';
import '../../services/supabase/supabase_service.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/mascot.dart';
import '../widgets/room_comms.dart';
import '../widgets/visuals.dart';

Widget _shell(BuildContext context, {required String title, required Widget child}) => Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: HushbugColors.scaffoldGradient),
        child: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(children: [
                IconButton(
                  tooltip: 'Back',
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                ),
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              ]),
            ),
            Expanded(child: child),
          ]),
        ),
      ),
    );

/// Shown before online play when nobody is signed in.
class OnlineSignInView extends ConsumerStatefulWidget {
  const OnlineSignInView({super.key, this.subtitle});

  final String? subtitle;

  @override
  ConsumerState<OnlineSignInView> createState() => _OnlineSignInViewState();
}

class _OnlineSignInViewState extends ConsumerState<OnlineSignInView> {
  bool _busy = false;

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) toast(context, friendlyError(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() => _run(() async {
        if (!await SupabaseService.googleEnabled()) {
          if (mounted) toast(context, "Google sign-in isn't switched on yet. You can play as a guest.");
          return;
        }
        await SupabaseService.signInWithGoogle();
      });

  @override
  Widget build(BuildContext context) {
    return _shell(
      context,
      title: 'Online Multiplayer',
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Mascot(size: 110, mood: MascotMood.detective),
              const SizedBox(height: 14),
              const Text('Play with friends', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                widget.subtitle ?? 'Sign in with Google to keep your friends on any phone, or jump in as a guest.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 13),
              ),
              const SizedBox(height: 28),
              if (_busy) ...[
                const LinearProgressIndicator(color: HushbugColors.neonPurpleLight),
                const SizedBox(height: 14),
              ],
              TactileButton(
                onPressed: _busy ? null : _google,
                style: TactileButtonStyle.golden,
                height: 52,
                icon: const Icon(Icons.g_mobiledata_rounded, color: HushbugColors.onAccentYellow, size: 28),
                child: const Text('Continue with Google'),
              ),
              const SizedBox(height: 12),
              TactileButton(
                onPressed: _busy ? null : () => _run(SupabaseService.signInAsGuest),
                style: TactileButtonStyle.secondary,
                height: 52,
                child: const Text('Play as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _act(Future<void> Function() action, {String? done}) async {
    try {
      await action();
      ref.invalidate(friendsProvider);
      ref.invalidate(blockedProvider);
      if (done != null && mounted) toast(context, done);
    } catch (e) {
      if (mounted) toast(context, friendlyError(e));
    }
  }

  Future<void> _add(SocialService social) async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    try {
      final status = await social.sendRequest(code);
      _codeCtrl.clear();
      ref.invalidate(friendsProvider);
      if (mounted) {
        toast(context, switch (status) {
          'accepted' => "You're now friends!",
          'already_friends' => "You're already friends.",
          'already_requested' => 'Request already sent.',
          _ => 'Friend request sent.',
        });
      }
    } catch (e) {
      if (mounted) toast(context, friendlyError(e));
    }
  }

  Future<void> _linkGoogle() async {
    try {
      if (!await SupabaseService.googleEnabled()) {
        if (mounted) toast(context, "Google sign-in isn't switched on yet.");
        return;
      }
      await SupabaseService.linkGoogle();
    } catch (e) {
      if (mounted) toast(context, friendlyError(e));
    }
  }

  Future<void> _signOut() async {
    final guest = SupabaseService.isGuest;
    if (guest) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          backgroundColor: HushbugColors.cardSurface,
          title: const Text('Sign out of guest account?', style: TextStyle(color: Colors.white, fontSize: 17)),
          content: const Text(
            'Guest accounts cannot be recovered. You will lose your friends list and friend code.',
            style: TextStyle(color: HushbugColors.textSubtext, fontSize: 13),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Sign out')),
          ],
        ),
      );
      if (ok != true) return;
    }
    await ref.read(onlineLobbyProvider.notifier).leave();
    await SupabaseService.signOut();
    if (mounted) context.pop();
  }

  Widget _card({required Widget child}) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: HushbugColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: HushbugColors.cardBorder),
        ),
        child: child,
      );

  static const _label = TextStyle(color: HushbugColors.textSubtext, fontSize: 11, fontWeight: FontWeight.w800);

  @override
  Widget build(BuildContext context) {
    final social = ref.watch(socialServiceProvider);
    final profile = ref.watch(myProfileProvider);
    final friends = ref.watch(friendsProvider);
    final blocked = ref.watch(blockedProvider).value ?? const <BlockedPlayer>[];
    final room = ref.watch(onlineLobbyProvider.select((s) => s.room));
    final guest = SupabaseService.isGuest;

    if (social == null) return _shell(context, title: 'Friends', child: const SizedBox());

    final list = friends.value ?? const <FriendEntry>[];
    final incoming = list.where((f) => f.status == 'incoming').toList();
    final accepted = list.where((f) => f.status == 'friend').toList();
    final outgoing = list.where((f) => f.status == 'outgoing').toList();

    Widget row(FriendEntry f, List<Widget> actions) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            PlayerAvatar(index: 0, name: f.displayName, radius: 16, avatarIndex: f.avatarIndex),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.displayName, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                if (f.status == 'friend')
                  Text(f.online ? 'Online' : 'Offline', style: TextStyle(color: f.online ? HushbugColors.civilianEmerald : HushbugColors.textMuted, fontSize: 11)),
              ]),
            ),
            ...actions,
          ]),
        );

    return _shell(
      context,
      title: 'Friends',
      child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(friendsProvider);
          await ref.read(friendsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
          children: [
            _card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('YOUR FRIEND CODE', style: _label),
                Row(children: [
                  Expanded(
                    child: Text(
                      profile.value?.friendCode ?? '········',
                      style: const TextStyle(color: HushbugColors.accentYellow, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Copy code',
                    onPressed: profile.value == null
                        ? null
                        : () {
                            Clipboard.setData(ClipboardData(text: profile.value!.friendCode));
                            toast(context, 'Friend code copied');
                          },
                    icon: const Icon(Icons.copy_rounded, color: Colors.white70),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(
                  guest ? 'Signed in as a guest. Link Google to keep your friends on any phone.' : 'Signed in with Google.',
                  style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(children: [
                  if (guest) ...[
                    FilledButton(onPressed: _linkGoogle, child: const Text('Link Google')),
                    const SizedBox(width: 8),
                  ],
                  TextButton(onPressed: _signOut, child: const Text('Sign out')),
                ]),
              ]),
            ),
            _card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('ADD A FRIEND', style: _label),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _codeCtrl,
                      maxLength: 8,
                      textCapitalization: TextCapitalization.characters,
                      style: const TextStyle(color: Colors.white, letterSpacing: 2, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(counterText: '', hintText: 'FRIEND CODE', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: () => _add(social), child: const Text('Add')),
                ]),
              ]),
            ),
            if (incoming.isNotEmpty)
              _card(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('REQUESTS', style: _label),
                  for (final f in incoming)
                    row(f, [
                      IconButton(tooltip: 'Decline', onPressed: () => _act(() => social.respond(f.friendshipId, false)), icon: const Icon(Icons.close_rounded, color: HushbugColors.imposterRed)),
                      IconButton(tooltip: 'Accept', onPressed: () => _act(() => social.respond(f.friendshipId, true), done: "You're now friends!"), icon: const Icon(Icons.check_rounded, color: HushbugColors.civilianEmerald)),
                    ]),
                ]),
              ),
            _card(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('FRIENDS (${accepted.length})', style: _label),
                if (friends.isLoading && list.isEmpty)
                  const Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator()))
                else if (accepted.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('Share your code to add your first friend.', style: TextStyle(color: HushbugColors.textMuted, fontSize: 13)),
                  ),
                for (final f in accepted)
                  row(f, [
                    if (room != null && room.status == 'waiting')
                      TextButton(onPressed: () => _act(() => social.invite(room.id, f.userId), done: 'Invite sent to ${f.displayName}'), child: const Text('Invite')),
                    PopupMenuButton<String>(
                      tooltip: 'More',
                      iconColor: Colors.white70,
                      onSelected: (v) => _act(() => v == 'remove' ? social.remove(f.friendshipId) : social.block(f.userId)),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'remove', child: Text('Remove friend')),
                        PopupMenuItem(value: 'block', child: Text('Block')),
                      ],
                    ),
                  ]),
              ]),
            ),
            if (outgoing.isNotEmpty)
              _card(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('SENT REQUESTS', style: _label),
                  for (final f in outgoing)
                    row(f, [TextButton(onPressed: () => _act(() => social.remove(f.friendshipId)), child: const Text('Cancel'))]),
                ]),
              ),
            if (blocked.isNotEmpty)
              _card(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('BLOCKED', style: _label),
                  for (final b in blocked)
                    Row(children: [
                      Expanded(child: Text(b.displayName, style: const TextStyle(color: Colors.white))),
                      TextButton(onPressed: () => _act(() => social.unblock(b.userId)), child: const Text('Unblock')),
                    ]),
                ]),
              ),
          ],
        ),
      ),
    );
  }
}

/// Full-screen room chat, opened from the lobby.
class RoomChatScreen extends ConsumerStatefulWidget {
  const RoomChatScreen({super.key});

  @override
  ConsumerState<RoomChatScreen> createState() => _RoomChatScreenState();
}

class _RoomChatScreenState extends ConsumerState<RoomChatScreen> {
  late final RoomChatNotifier _chat = ref.read(roomChatProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _chat.setOpen(true));
  }

  @override
  void deactivate() {
    _chat.setOpen(false);
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(roomChatProvider.select((s) => s.error), (_, err) {
      if (err != null) {
        toast(context, err);
        _chat.clearError();
      }
    });
    return _shell(
      context,
      title: 'Room Chat',
      child: const Column(children: [
        Expanded(child: ChatMessageList()),
        Padding(padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6), child: ChatComposer()),
      ]),
    );
  }
}

/// Voice, chat and privacy preferences.
class CommunicationSettingsScreen extends ConsumerWidget {
  const CommunicationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    Widget header(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(t, style: const TextStyle(color: HushbugColors.neonPurpleLight, fontSize: 12, fontWeight: FontWeight.w800)),
        );
    Widget toggle(String title, bool value, ValueChanged<bool> onChanged, {String? subtitle}) => SwitchListTile(
          title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
          subtitle: subtitle == null ? null : Text(subtitle, style: const TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
          value: value,
          onChanged: onChanged,
        );

    return _shell(
      context,
      title: 'Communication',
      child: ListView(
        children: [
          header('VOICE'),
          toggle('Voice chat', s.voiceEnabled, (v) => n.update((x) => x.copyWith(voiceEnabled: v))),
          toggle('Push-to-talk', s.pushToTalk, (v) => n.update((x) => x.copyWith(pushToTalk: v)),
              subtitle: s.pushToTalk ? 'Microphone is live only while you hold the button' : 'Open microphone: talk freely when unmuted'),
          toggle('Use loudspeaker', s.speakerOutput, (v) => n.update((x) => x.copyWith(speakerOutput: v))),
          ListTile(
            title: const Text('Voice volume', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Slider(value: s.voiceVolume, onChanged: (v) => n.update((x) => x.copyWith(voiceVolume: v))),
          ),
          header('CHAT'),
          toggle('Chat notifications', s.chatNotifications, (v) => n.update((x) => x.copyWith(chatNotifications: v)),
              subtitle: 'Shows new messages and room updates in the game bar'),
          toggle('Show message times', s.chatTimestamps, (v) => n.update((x) => x.copyWith(chatTimestamps: v))),
          header('PRIVACY'),
          const ListTile(
            title: Text('Microphone', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text(
              'Hushbug asks for the microphone only when you join voice chat, and uses it only while voice chat is on. You can remove access at any time in your phone settings.',
              style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
            ),
          ),
          const ListTile(
            title: Text('Voice privacy', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text(
              'Voice is sent live to the players in your room and is never recorded or stored.',
              style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12),
            ),
          ),
          ListTile(
            title: const Text('Blocked players and friends', style: TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: const Text('To block or report someone, tap them in the room lobby.', style: TextStyle(color: HushbugColors.textSubtext, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
            onTap: () => context.push('/friends'),
          ),
        ],
      ),
    );
  }
}
