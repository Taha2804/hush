import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/data/prefs/settings.dart';
import 'package:hushbug/domain/models/game_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('player groups survive a restart; the live player list does not', () async {
    const saved = AppSettings(
      game: GameConfig(players: ['Asha', 'Ben', 'Chen'], roundTwists: true),
      playerGroups: [
        PlayerGroup(name: 'College', players: ['Asha', 'Ben', 'Chen', 'Dev']),
        PlayerGroup(name: 'Family', players: ['Mom', 'Dad', 'Riya']),
      ],
    );
    SharedPreferences.setMockInitialValues({'hushbug.settings.v1': jsonEncode(saved.toJson())});
    final loaded = SettingsRepository(await SharedPreferences.getInstance()).load();

    expect(loaded.playerGroups.map((g) => g.name), ['College', 'Family']);
    expect(loaded.playerGroups.first.players, ['Asha', 'Ben', 'Chen', 'Dev']);
    expect(loaded.game.players, const GameConfig().players);
    expect(loaded.game.roundTwists, isTrue); // rules are preferences
  });
}
