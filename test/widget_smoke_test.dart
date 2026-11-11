import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/app/app.dart';
import 'package:hushbug/app/providers.dart';
import 'package:hushbug/data/db/app_db.dart';
import 'package:hushbug/data/sources/online/json_fetcher.dart';
import 'package:hushbug/data/sources/online/online_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app boots to Home without Daily Challenges', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDb(NativeDatabase.memory());
    addTearDown(db.close);
    final boot = Bootstrap(
      prefs: prefs,
      db: db,
      assetLoader: (p) async => File(p).readAsStringSync(),
      blocklistText: '',
      brandsText: '',
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        bootstrapProvider.overrideWithValue(boot),
        // No live network in tests.
        onlineSourceProvider.overrideWithValue(OnlineSearchSource(
            db: db, blocklistText: '', brandsText: '', fetcher: FixtureFetcher({}), useIsolate: false)),
      ],
      child: const HushbugApp(),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Hushbug'), findsWidgets);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.byTooltip('Daily Mission'), findsNothing);
    expect(find.textContaining('DAILY CHALLENGE'), findsNothing);
  });
}
