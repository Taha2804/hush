import 'dart:ui';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/db/app_db.dart';
import 'services/supabase/supabase_config.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Error Boundary Protection
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Hushbug FlutterError: ${details.exceptionAsString()}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Hushbug PlatformDispatcher error: $error\n$stack');
    return true;
  };

  try {
    final prefs = await SharedPreferences.getInstance();
    final db = AppDb(driftDatabase(name: 'hushbug'));
    final blocklist = await rootBundle.loadString('assets/blocklist.txt');
    final brands = await rootBundle.loadString('assets/brands.txt');

    // Initialize Supabase Online Multiplayer subsystem
    await SupabaseConfig.init(prefs);
    await SupabaseService.initialize();

    runApp(ProviderScope(
      overrides: [
        bootstrapProvider.overrideWithValue(Bootstrap(
          prefs: prefs,
          db: db,
          assetLoader: (path) => rootBundle.loadString(path, cache: false),
          blocklistText: blocklist,
          brandsText: brands,
        )),
      ],
      child: const HushbugApp(),
    ));
  } catch (e, stack) {
    debugPrint('Failed to initialize Hushbug: $e\n$stack');
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF15131D),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.bug_report, size: 48, color: Color(0xFFFFD166)),
                const SizedBox(height: 16),
                const Text(
                  'Hushbug Initialization Notice',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '$e',
                  style: const TextStyle(color: Color(0xFFA59EC0), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
