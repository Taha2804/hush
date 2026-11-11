import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/gen/app_localizations.dart';
import '../presentation/screens/achievements_screen.dart';
import '../presentation/screens/info_screens.dart';
import '../presentation/screens/invite_screen.dart';
import '../presentation/screens/lobby_screen.dart';
import '../presentation/screens/multiplayer_screen.dart';
import '../presentation/screens/my_words_screens.dart';
import '../presentation/screens/online_play_screen.dart';
import '../presentation/screens/online_social_screens.dart';
import '../presentation/screens/play_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/setup_screen.dart';
import '../presentation/screens/source_select_screen.dart';
import '../presentation/screens/stats_screen.dart';
import '../presentation/theme.dart';
import '../presentation/widgets/room_comms.dart';
import '../services/invite_links.dart';
import 'providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (c, s) => const LobbyScreen()),
      GoRoute(path: '/lobby', builder: (c, s) => const LobbyScreen()),
      GoRoute(path: '/source', builder: (c, s) => const SourceSelectScreen()),
      GoRoute(path: '/setup', builder: (c, s) => const SetupScreen()),
      GoRoute(path: '/play', builder: (c, s) => const PlayScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/settings/app', builder: (c, s) => const AppPreferencesScreen()),
      GoRoute(path: '/how', builder: (c, s) => const HowToPlayScreen()),
      GoRoute(path: '/about', builder: (c, s) => const AboutScreen()),
      GoRoute(path: '/stats', builder: (c, s) => const StatsScreen()),
      GoRoute(path: '/achievements', builder: (c, s) => const AchievementsScreen()),
      GoRoute(path: '/invite/:code', builder: (c, s) => InviteScreen(code: s.pathParameters['code']!.toUpperCase())),
      GoRoute(path: '/multiplayer', builder: (c, s) => const MultiplayerScreen()),
      GoRoute(
        path: '/multiplayer/play/:id',
        builder: (c, s) => OnlinePlayScreen(sessionId: s.pathParameters['id']!),
      ),
      GoRoute(path: '/multiplayer/chat', builder: (c, s) => const RoomChatScreen()),
      GoRoute(path: '/friends', builder: (c, s) => const FriendsScreen()),
      GoRoute(path: '/settings/communication', builder: (c, s) => const CommunicationSettingsScreen()),
      GoRoute(path: '/mywords', builder: (c, s) => const MyWordsScreen()),
      GoRoute(
        path: '/mywords/:id',
        builder: (c, s) => PackEditorScreen(packId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(path: '/topic', builder: (c, s) => const TopicSearchScreen()),
    ],
  );
});

class HushbugApp extends ConsumerWidget {
  const HushbugApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      // Hushbug has one look: the dark theme.
      theme: buildTheme(Brightness.dark, 0),
      darkTheme: buildTheme(Brightness.dark, 0),
      themeMode: ThemeMode.dark,
      themeAnimationDuration: s.reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
      locale: Locale(s.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(mq.textScaler.scale(1).clamp(0.8, 1.6)),
            disableAnimations: mq.disableAnimations || s.reduceMotion,
          ),
          child: _InviteLinkListener(
            child: InviteOverlay(
              onAccept: (code) => router.push('/invite/$code'),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}

/// Opens the invitation screen for links that open the app, and for an
/// invitation saved before sign-in or carried through installation.
class _InviteLinkListener extends ConsumerStatefulWidget {
  const _InviteLinkListener({required this.child});
  final Widget child;

  @override
  ConsumerState<_InviteLinkListener> createState() => _InviteLinkListenerState();
}

class _InviteLinkListenerState extends ConsumerState<_InviteLinkListener> {
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    InviteLinks.listen(ref.read(bootstrapProvider).prefs, (code) {
      if (!mounted) return;
      final router = ref.read(routerProvider);
      final path = '/invite/$code';
      if (router.routerDelegate.currentConfiguration.uri.path != path) router.push(path);
    }).then((sub) => _sub = sub).catchError((_) => null);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
