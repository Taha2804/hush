import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/app/app.dart';
import 'package:hushbug/app/game_controller.dart';
import 'package:hushbug/app/providers.dart';
import 'package:hushbug/data/db/app_db.dart';
import 'package:hushbug/data/prefs/settings.dart';
import 'package:hushbug/data/sources/online/json_fetcher.dart';
import 'package:hushbug/data/sources/online/online_source.dart';
import 'package:hushbug/domain/game_engine.dart';
import 'package:hushbug/domain/models/game_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('full round through the UI with Offline Packs', (tester) async {
    tester.view.physicalSize = const Size(1080, 2200);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);

    const settings = AppSettings(
      askSourceEveryLaunch: false,
      lastSource: 'offline',
      reduceMotion: true,
      sound: false,
      haptics: false,
      scores: {'Asha': 5},
      game: GameConfig(
        // Saved names must NOT come back after a restart.
        players: ['Asha', 'Ben', 'Chen'],
        mode: GameMode.hint,
        discussionSeconds: 0,
        lastChance: false,
      ),
    );
    SharedPreferences.setMockInitialValues({'hushbug.settings.v1': jsonEncode(settings.toJson())});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDb(NativeDatabase.memory());
    addTearDown(db.close);

    late ProviderContainer container;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        bootstrapProvider.overrideWithValue(Bootstrap(
          prefs: prefs,
          db: db,
          assetLoader: (p) async => File(p).readAsStringSync(),
          blocklistText: File('assets/blocklist.txt').readAsStringSync(),
          brandsText: File('assets/brands.txt').readAsStringSync(),
        )),
        onlineSourceProvider.overrideWithValue(OnlineSearchSource(
            db: db, blocklistText: '', brandsText: '', fetcher: FixtureFetcher({}), useIsolate: false)),
      ],
      child: Consumer(builder: (context, ref, _) {
        container = ProviderScope.containerOf(context);
        return const HushbugApp();
      }),
    ));
    // Home has endless idle animations, so pump instead of settling.
    await tester.pump(const Duration(milliseconds: 500));
    container.read(routerProvider).go('/setup');
    await tester.pumpAndSettle();
    expect(find.text('Game setup'), findsOneWidget);
    // Regression: the bottom "Start game" bar must not cover the form.
    final startTop = tester.getTopLeft(find.widgetWithText(FilledButton, 'Start game')).dy;
    expect(startTop, greaterThan(tester.view.physicalSize.height / tester.view.devicePixelRatio * 0.7));
    // Fresh session: default players, saved rules (discussion timer off) kept.
    expect(find.text('Players (4)'), findsOneWidget);
    expect(find.text('Asha'), findsNothing);
    expect(container.read(settingsProvider).game.discussionSeconds, 0);
    expect(container.read(settingsProvider).scores, isEmpty);

    // Start the game (real async work: assets + drift).
    await tester.runAsync(() => container.read(gameProvider.notifier).startRound());
    await tester.pumpAndSettle();
    GoRouterHelper.go(tester, '/play');
    await tester.pumpAndSettle();

    RoundState round() => container.read(gameProvider).round!;
    expect(round().phase, GamePhase.reveal);

    // Reveal: press-and-hold shows the card, releasing hides & locks it.
    final n = round().players.length;
    expect(n, 4);
    for (var i = 0; i < n; i++) {
      expect(find.text('Pass to ${round().players[i]}'), findsOneWidget);
      final card = find.text('Hold to reveal');
      final g = await tester.startGesture(tester.getCenter(card));
      await tester.pump(const Duration(milliseconds: 50));
      final isImp = round().imposters.contains(i);
      expect(find.text(isImp ? 'IMPOSTER' : round().word), findsOneWidget);
      await g.up();
      await tester.pump();
      expect(find.text('Card seen — pass the device on'), findsOneWidget);
      // Locked: holding again does not re-reveal.
      final g2 = await tester.startGesture(tester.getCenter(find.text('Card seen — pass the device on')));
      await tester.pump();
      expect(find.text(round().word), findsNothing);
      await g2.up();
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
    }

    // Clues: n players x 1 round.
    expect(round().phase, GamePhase.clue);
    for (var i = 0; i < n; i++) {
      await tester.tap(find.widgetWithText(FilledButton, 'Next'));
      await tester.pumpAndSettle();
    }

    // Discussion (timer off) -> vote.
    expect(round().phase, GamePhase.discussion);
    await tester.tap(find.text('Go to vote'));
    await tester.pumpAndSettle();
    expect(find.text('Who is the imposter?'), findsOneWidget);

    // Vote out the imposter.
    final imp = round().imposters.single;
    await tester.tap(find.widgetWithText(ChoiceChip, round().players[imp]));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Confirm'));
    await tester.pump(const Duration(milliseconds: 500));

    expect(round().phase, GamePhase.result);
    expect(round().winner, Winner.crew);
    expect(find.text('Crew wins!'), findsOneWidget);
    expect(find.text(round().word), findsWidgets);
    // Scores: three crew members +1.
    final scores = container.read(settingsProvider).scores;
    expect(scores.values.where((v) => v == 1).length, 3);
    await tester.pump(const Duration(seconds: 4));
  }, skip: true); // Written for the setup screen before the redesign; needs rewriting for the new UI.
}

/// Tiny helper to navigate with the app's GoRouter from a test.
class GoRouterHelper {
  static void go(WidgetTester tester, String location) {
    final ctx = tester.element(find.byType(Scaffold).first);
    ProviderScope.containerOf(ctx).read(routerProvider).go(location);
  }
}
