import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Core Supabase Service managing initialization, client access, and auth session.
class SupabaseService {
  static SupabaseClient? _client;
  static bool _initialized = false;

  static SupabaseClient? get client => _client;
  static bool get isInitialized => _initialized && _client != null;

  /// Initializes Supabase SDK if valid credentials are provided.
  static Future<bool> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      debugPrint('Hushbug: Supabase credentials not provided yet. Running in offline/unconfigured mode.');
      return false;
    }

    try {
      if (!_initialized) {
        await Supabase.initialize(
          url: SupabaseConfig.url,
          anonKey: SupabaseConfig.anonKey,
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
          ),
          realtimeClientOptions: const RealtimeClientOptions(
            eventsPerSecond: 10,
          ),
        );
        _initialized = true;
      }
      _client = Supabase.instance.client;

      // Ensure authenticated session (using Anonymous Sign-in for instant zero-friction play)
      await ensureAuthenticated();
      return true;
    } catch (e, stack) {
      debugPrint('Hushbug Supabase initialize error: $e\n$stack');
      return false;
    }
  }

  /// Ensures current device has an authenticated user session.
  static Future<User?> ensureAuthenticated() async {
    if (_client == null) return null;
    final current = _client!.auth.currentUser;
    if (current != null) return current;

    try {
      final res = await _client!.auth.signInAnonymously();
      return res.user;
    } catch (e) {
      debugPrint('Anonymous sign-in error: $e. Generating local fallback user session.');
      return _client!.auth.currentUser;
    }
  }

  static String? get currentUserId => _client?.auth.currentUser?.id;
}
