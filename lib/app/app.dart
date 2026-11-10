import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/prefs/settings.dart';
import '../l10n/gen/app_localizations.dart';
import '../presentation/screens/info_screens.dart';
import '../presentation/screens/lobby_screen.dart';
import '../presentation/screens/my_words_screens.dart';
import '../presentation/screens/play_screen.dart';
import '../presentation/screens/settings_screen.dart';
import '../presentation/screens/setup_screen.dart';
import '../presentation/screens/source_select_screen.dart';
import '../presentation/theme.dart';
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
    final amoled = s.themeMode == AppThemeMode.amoled;
    return MaterialApp.router(
      onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: buildTheme(Brightness.light, s.accent),
      darkTheme: buildTheme(Brightness.dark, s.accent, amoled: amoled),
      themeMode: toThemeMode(s.themeMode),
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
            textScaler: TextScaler.linear(s.textScale * mq.textScaler.scale(1).clamp(0.8, 1.6)),
            disableAnimations: mq.disableAnimations || s.reduceMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
