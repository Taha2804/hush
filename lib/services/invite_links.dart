import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Room invitations: links, codes, and invites that must survive sign-in or
/// a fresh install.
///
/// Link format: `<INVITE_BASE_URL>/invite/<CODE>`. If the app is installed,
/// Android opens it directly (App Links). If not, the web page sends the
/// player to Google Play with `referrer=invite=<CODE>`, which Play hands back
/// to the app on its first launch.
class InviteLinks {
  static const baseUrl = String.fromEnvironment('INVITE_BASE_URL', defaultValue: 'https://hushbug.app');
  static const _pendingKey = 'hushbug.pending_invite';
  static const _referrerCheckedKey = 'hushbug.install_referrer_checked';
  static const _pendingLifetime = Duration(hours: 24);
  static final _codePattern = RegExp(r'^[A-HJ-NP-Z2-9]{6}$');

  static String linkFor(String code) => '$baseUrl/invite/$code';

  /// Pulls a 6-character room code out of a link, a pasted message or a code.
  static String? extractCode(String raw) {
    final upper = raw.toUpperCase();
    final fromPath = RegExp(r'INVITE/([A-Z0-9]{6})').firstMatch(upper)?.group(1);
    if (fromPath != null && _codePattern.hasMatch(fromPath)) return fromPath;
    final fromParam = RegExp(r'INVITE[=%3D]+([A-Z0-9]{6})').firstMatch(upper)?.group(1);
    if (fromParam != null && _codePattern.hasMatch(fromParam)) return fromParam;
    final compact = upper.replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (_codePattern.hasMatch(compact)) return compact;
    for (final m in RegExp(r'\b[A-Z0-9]{6}\b').allMatches(upper)) {
      if (_codePattern.hasMatch(m.group(0)!)) return m.group(0);
    }
    return null;
  }

  static bool isValidCode(String code) => _codePattern.hasMatch(code);

  static String? codeFromUri(Uri uri) {
    if (uri.host == 'login-callback') return null; // Sign-in redirects are not invites.
    return extractCode(uri.toString());
  }

  // ------------------------------------------------------------ pending invite

  static Future<void> savePending(SharedPreferences prefs, String code) =>
      prefs.setString(_pendingKey, jsonEncode({'code': code, 'at': DateTime.now().toIso8601String()}));

  static String? readPending(SharedPreferences prefs) {
    final raw = prefs.getString(_pendingKey);
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final at = DateTime.parse(j['at'] as String);
      if (DateTime.now().difference(at) > _pendingLifetime) {
        prefs.remove(_pendingKey);
        return null;
      }
      return j['code'] as String;
    } catch (_) {
      prefs.remove(_pendingKey);
      return null;
    }
  }

  static Future<void> clearPending(SharedPreferences prefs) => prefs.remove(_pendingKey);

  // ------------------------------------------------------------ sources

  /// Calls [onInvite] for the link that opened the app, every later link, and
  /// (once per install) an invite carried through Google Play.
  static Future<StreamSubscription<Uri>?> listen(SharedPreferences prefs, void Function(String code) onInvite) async {
    StreamSubscription<Uri>? sub;
    // Widget tests have no platform plugins.
    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) return null;
    try {
      final links = AppLinks();
      sub = links.uriLinkStream.listen((uri) {
        final code = codeFromUri(uri);
        if (code != null) {
          savePending(prefs, code);
          onInvite(code);
        }
      }, onError: (Object e) => debugPrint('Hushbug invite link error: $e'));
    } catch (e) {
      debugPrint('Hushbug invite links unavailable: $e');
    }

    final referrerCode = await _fromInstallReferrer(prefs);
    if (referrerCode != null) {
      await savePending(prefs, referrerCode);
    }
    final pending = readPending(prefs);
    if (pending != null) onInvite(pending);
    return sub;
  }

  static Future<String?> _fromInstallReferrer(SharedPreferences prefs) async {
    if (kIsWeb || !Platform.isAndroid || prefs.getBool(_referrerCheckedKey) == true) return null;
    await prefs.setBool(_referrerCheckedKey, true);
    try {
      final details = await PlayInstallReferrer.installReferrer;
      final referrer = Uri.decodeComponent(details.installReferrer ?? '');
      final code = Uri.splitQueryString(referrer)['invite'];
      if (code != null && isValidCode(code.toUpperCase())) return code.toUpperCase();
    } catch (e) {
      debugPrint('Hushbug install referrer unavailable: $e');
    }
    return null;
  }
}
