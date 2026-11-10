import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/presentation/widgets/visuals.dart';

void main() {
  test('default player names show their number', () {
    expect(avatarLabel('Player 1', 0), '1');
    expect(avatarLabel('player 12', 11), '12');
    expect(avatarLabel('खिलाड़ी 3', 2, localizedPlayerPrefix: 'खिलाड़ी 0'), '3');
  });

  test('empty names show their seat number', () {
    expect(avatarLabel('  ', 4), '5');
  });

  test('real names show their first letter', () {
    expect(avatarLabel('asha', 0), 'A');
    expect(avatarLabel('Room 101', 0), 'R');
    expect(avatarLabel('Playerone', 0), 'P');
  });
}
