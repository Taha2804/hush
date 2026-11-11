import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_config.dart';

/// How long any single backend call may take before the app gives up.
const rpcTimeout = Duration(seconds: 15);

/// Turns backend errors into something fit to show a player.
String friendlyError(Object e) {
  if (e is TimeoutException) return 'The connection is slow. Please try again.';
  if (e is PostgrestException) return e.message;
  if (e is AuthException) return e.message;
  final text = e.toString();
  if (text.contains('SocketException') || text.contains('ClientException') || text.contains('Failed host lookup')) {
    return 'No connection. Check your internet and try again.';
  }
  return 'Something went wrong. Please try again.';
}

/// Connection to Supabase and the player's login.
class SupabaseService {
  static const authRedirect = 'com.hushbug.hushbug://login-callback';

  static SupabaseClient? _client;
  static bool _initialized = false;

  static SupabaseClient? get client => _client;
  static bool get isInitialized => _initialized && _client != null;
  static User? get currentUser => _client?.auth.currentUser;
  static String? get currentUserId => currentUser?.id;
  static bool get isGuest => currentUser?.isAnonymous ?? true;

  static Future<bool> initialize() async {
    if (!SupabaseConfig.isConfigured) return false;
    try {
      if (!_initialized) {
        await Supabase.initialize(
          url: SupabaseConfig.url,
          publishableKey: SupabaseConfig.publishableKey,
          authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
          realtimeClientOptions: const RealtimeClientOptions(eventsPerSecond: 10),
        );
        _initialized = true;
      }
      _client = Supabase.instance.client;
      return true;
    } catch (e, stack) {
      debugPrint('Hushbug Supabase initialize error: $e\n$stack');
      return false;
    }
  }

  static Future<void> signInAsGuest() async {
    await _client!.auth.signInAnonymously();
  }

  static Future<void> signInWithGoogle() async {
    await _client!.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: authRedirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Upgrades a guest to a Google login, keeping the same account and friends.
  static Future<void> linkGoogle() async {
    await _client!.auth.linkIdentity(
      OAuthProvider.google,
      redirectTo: authRedirect,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  static Future<void> signOut() async {
    await _client!.auth.signOut();
  }

  /// Whether Google login has been switched on in the Supabase project.
  static Future<bool> googleEnabled() async {
    try {
      final res = await Dio().get<Map<String, dynamic>>(
        '${SupabaseConfig.url}/auth/v1/settings',
        options: Options(headers: {'apikey': SupabaseConfig.publishableKey}),
      );
      return res.data?['external']?['google'] == true;
    } catch (_) {
      return false;
    }
  }
}
