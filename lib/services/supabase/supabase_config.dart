import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized configuration for Supabase Online Multiplayer.
/// Reads from build-time `--dart-define` parameters with persistent local fallback.
class SupabaseConfig {
  static const String _defaultUrlEnv = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://vctdkitastvopatlwkhc.supabase.co',
  );
  static const String _defaultAnonKeyEnv = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static const String _prefsUrlKey = 'hushbug.supabase.url';
  static const String _prefsKeyKey = 'hushbug.supabase.anon_key';

  static String _url = _defaultUrlEnv;
  static String _anonKey = _defaultAnonKeyEnv;

  static String get url => _url;
  static String get anonKey => _anonKey;

  static bool get isConfigured => _url.trim().isNotEmpty && _anonKey.trim().isNotEmpty;

  /// Loads any custom saved credentials from SharedPreferences.
  static Future<void> init(SharedPreferences prefs) async {
    final savedUrl = prefs.getString(_prefsUrlKey);
    final savedKey = prefs.getString(_prefsKeyKey);

    if (savedUrl != null && savedUrl.isNotEmpty) {
      _url = savedUrl;
    }
    if (savedKey != null && savedKey.isNotEmpty) {
      _anonKey = savedKey;
    }
  }

  /// Allows setting credentials dynamically from in-app settings modal.
  static Future<void> saveCredentials(SharedPreferences prefs, {required String url, required String anonKey}) async {
    _url = url.trim();
    _anonKey = anonKey.trim();
    await prefs.setString(_prefsUrlKey, _url);
    await prefs.setString(_prefsKeyKey, _anonKey);
  }
}
