import 'package:flutter_test/flutter_test.dart';
import 'package:hushbug/domain/blocklist.dart';
import 'package:hushbug/domain/models/word_entry.dart';
import 'package:hushbug/domain/validators.dart';

void main() {
  final bl = Blocklist(blocked: ['beer', 'gun'], brands: ['coca cola', 'nike']);

  group('word filter', () {
    test('accepts', () {
      for (final w in ['Pizza', 'Ice cream', 'T-shirt', 'Owl', 'Hot air balloon'.substring(0, 7)]) {
        expect(rejectWord(w, blocklist: bl), isNull, reason: w);
      }
    });
    test('rejects', () {
      expect(rejectWord('Ox'), 'length');
      expect(rejectWord('Supercalifragilistic'), 'length');
      expect(rejectWord('Apollo 11'), 'format');
      expect(rejectWord('Mercury (planet)'), 'format');
      expect(rejectWord('Hot air balloon'), 'format');
      expect(rejectWord('List of cats'), 'format');
      expect(rejectWord('List cats'), 'meta-page');
      expect(rejectWord('Beer', blocklist: bl), 'blocklist');
    });
  });

  group('hint validator', () {
    test('good hints', () {
      for (final h in ['Italian dish', 'Shared at parties', 'Comes in slices', 'Topped with cheese']) {
        expect(rejectHint('Pizza', h, blocklist: bl), isNull, reason: h);
      }
      expect(rejectHint('Ice cream', 'Melts in summer'), isNull);
    });
    test('contains word / stem / plural', () {
      expect(rejectHint('Pizza', 'Pizza oven'), 'contains-word');
      expect(rejectHint('Cherry', 'Cherries on cake'), 'contains-word');
      expect(rejectHint('Box', 'Boxes'), 'contains-word');
      expect(rejectHint('Popcorn', 'Made from corn'), 'contains-word');
      expect(rejectHint('Ice cream', 'Cold ice'), 'contains-word');
    });
    test('synonym', () {
      expect(rejectHint('Car', 'Automobile', synonyms: {'automobile', 'auto'}), 'synonym');
    });
    test('letter / length clues', () {
      expect(rejectHint('Pizza', 'Starts with P'), 'letter-or-length');
      expect(rejectHint('Pizza', 'Five letters'), 'letter-or-length');
      expect(rejectHint('Pizza', 'Has 5 letters'), 'letter-or-length');
      expect(rejectHint('Pizza', 'Rhymes with visa'), 'letter-or-length');
    });
    test('brand / proper noun', () {
      // v2: proper nouns (e.g. 'Galileo') are allowed as hard hints.
      expect(rejectHint('Shoe', 'nike product', blocklist: bl), 'brand');
    });
    test('too long, blocklist, off-domain', () {
      expect(rejectHint('Pizza', 'A round baked dish with cheese'), 'too-long');
      expect(rejectHint('Pizza', 'Goes with beer', blocklist: bl), 'blocklist');
      expect(rejectHint('Pizza', 'A thing'), 'off-domain');
      expect(rejectHint('Pizza', 'it is'), 'off-domain');
    });
  });

  group('fake validator', () {
    test('good fakes', () {
      for (final f in ['Pasta', 'Burger', 'Calzone']) {
        expect(rejectFake('Pizza', f), isNull, reason: f);
      }
    });
    test('bad fakes', () {
      expect(rejectFake('Pizza', 'Pizza'), 'same-word');
      expect(rejectFake('Pizza', 'Pizzas'), 'stem-or-substring');
      expect(rejectFake('Apple', 'Pineapple'), 'stem-or-substring');
      expect(rejectFake('Ice cream', 'Ice tea'), isNull);
      expect(rejectFake('Ice cream', 'Cream'), 'stem-or-substring');
      expect(rejectFake('Green tea', 'Tea green'), 'stem-or-substring');
      expect(rejectFake('Car', 'Auto', synonyms: {'auto'}), 'synonym');
    });
  });

  test('cleanEntry drops invalid hints/fakes and duplicates', () {
    const e = WordEntry(
      id: 'x',
      category: 'Food',
      word: 'Pizza',
      source: 't',
      hints: [
        Hint(text: 'Italian dish', level: 1),
        Hint(text: 'italian dish', level: 2),
        Hint(text: 'Pizza slice', level: 3),
        Hint(text: 'Comes in slices', level: 3),
        Hint(text: 'Bad level', level: 7),
      ],
      imposters: [ImposterWord(text: 'Pasta'), ImposterWord(text: 'Pizzas'), ImposterWord(text: 'Pasta')],
    );
    final c = cleanEntry(e);
    expect(c.entry.hints.map((h) => h.text), ['Italian dish', 'Comes in slices']);
    expect(c.entry.fakeWords, ['Pasta']);
    expect(c.rejectedHints.length, 3);
  });
}
