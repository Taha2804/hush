import 'models/word_entry.dart';
import 'text_utils.dart';

/// A family-friendly blocklist plus a brand list. Content is loaded from
/// bundled text files (one entry per line, `#` comments allowed).
class Blocklist {
  Blocklist({
    Iterable<String> blocked = const [],
    Iterable<String> brands = const [],
    Map<String, Set<String>> synonyms = const {},
    Map<String, Set<String>> looseSynonyms = const {},
  })  : _blocked = _split(blocked),
        _brands = _split(brands),
        _synonyms = (strong: synonyms, loose: looseSynonyms);

  Blocklist._raw(this._blocked, this._brands, this._synonyms);

  /// Nightlife terms allowed only in the 18+ After Dark category. Mirrors
  /// tool/words/adult_allow.txt. Explicit sexual terms are never allowed.
  static const adultAllowed = <String>{
    'beer', 'wine', 'vodka', 'whisky', 'whiskey', 'tequila', 'rum', 'gin',
    'brandy', 'liquor', 'alcohol', 'alcoholic', 'drunk', 'hangover',
    'cocktail', 'bar', 'sexy', 'condom',
  };

  /// The list to apply to [e]: adult words get [adultAllowed] lifted, the
  /// Brands category may use brand names.
  Blocklist forEntry(WordEntry e) {
    var b = this;
    if (e.isAdult) {
      b = Blocklist._raw(
          (single: b._blocked.single.difference(adultAllowed), phrases: b._blocked.phrases), b._brands,
          b._synonyms);
    }
    if (e.category == 'brands_products') {
      b = Blocklist._raw(b._blocked, (single: <String>{}, phrases: const <String>[]), b._synonyms);
    }
    return b;
  }

  /// [synonyms]: lines like `eggplant: aubergine, brinjal` (assets/synonyms.txt,
  /// built by tool/words/build_synonyms.py). `word: a, b` are true other names
  /// (blocked as hints and imposter words); `word ~ a, b` are looser synonyms
  /// (blocked as hints only). Each name links to the head word both ways.
  factory Blocklist.fromText({String blocked = '', String brands = '', String synonyms = ''}) =>
      Blocklist(
        blocked: _lines(blocked),
        brands: _lines(brands),
        synonyms: _parseSynonyms(synonyms, ':'),
        looseSynonyms: _parseSynonyms(synonyms, '~'),
      );

  static Map<String, Set<String>> _parseSynonyms(String text, String sep) {
    final out = <String, Set<String>>{};
    for (final line in _lines(text)) {
      final parts = line.split(sep);
      if (parts.length != 2) continue;
      final head = normalize(parts[0]);
      final names = {
        for (final w in parts[1].split(',')) if (normalize(w).isNotEmpty && normalize(w) != head) normalize(w),
      };
      if (head.isEmpty || names.isEmpty) continue;
      (out[head] ??= <String>{}).addAll(names);
      for (final n in names) {
        (out[n] ??= <String>{}).add(head);
      }
    }
    return out;
  }

  static final empty = Blocklist();

  final ({Set<String> single, List<String> phrases}) _blocked;
  final ({Set<String> single, List<String> phrases}) _brands;
  final ({Map<String, Set<String>> strong, Map<String, Set<String>> loose}) _synonyms;

  /// Other names for [word] (e.g. Eggplant -> aubergine, brinjal). A hint that
  /// is just another name for the secret word gives it away. With
  /// [strongOnly], only true other names (used for imposter words, where
  /// close-but-different words like Toad/Frog are wanted).
  Set<String> synonymsOf(String word, {bool strongOnly = false}) {
    final k = normalize(word);
    final s = _synonyms.strong[k] ?? const <String>{};
    if (strongOnly) return s;
    return {...s, ...?_synonyms.loose[k]};
  }

  static Iterable<String> _lines(String text) => text
      .split(RegExp(r'\r?\n'))
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith('#'));

  static ({Set<String> single, List<String> phrases}) _split(Iterable<String> items) {
    final single = <String>{};
    final phrases = <String>[];
    for (final raw in items) {
      final n = normalize(raw);
      if (n.isEmpty) continue;
      if (n.contains(' ')) {
        phrases.add(n);
      } else {
        single.add(n);
      }
    }
    return (single: single, phrases: phrases);
  }

  static bool _hit(({Set<String> single, List<String> phrases}) list, String text) {
    final toks = tokens(text);
    for (final t in toks) {
      if (list.single.contains(t) || list.single.contains(stem(t))) return true;
    }
    if (list.phrases.isEmpty) return false;
    final joined = ' ${toks.join(' ')} ';
    return list.phrases.any((p) => joined.contains(' $p '));
  }

  /// True if [text] contains a blocked (not family-friendly) term.
  bool isBlocked(String text) => _hit(_blocked, text);

  /// True if [text] mentions a known brand.
  bool hasBrand(String text) => _hit(_brands, text);
}
