import 'models/word_entry.dart';
import 'text_utils.dart';

/// A family-friendly blocklist plus a brand list. Content is loaded from
/// bundled text files (one entry per line, `#` comments allowed).
class Blocklist {
  Blocklist({Iterable<String> blocked = const [], Iterable<String> brands = const []})
      : _blocked = _split(blocked),
        _brands = _split(brands);

  Blocklist._raw(this._blocked, this._brands);

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
          (single: b._blocked.single.difference(adultAllowed), phrases: b._blocked.phrases), b._brands);
    }
    if (e.category == 'brands_products') {
      b = Blocklist._raw(b._blocked, (single: <String>{}, phrases: const <String>[]));
    }
    return b;
  }

  factory Blocklist.fromText({String blocked = '', String brands = ''}) =>
      Blocklist(blocked: _lines(blocked), brands: _lines(brands));

  static final empty = Blocklist();

  final ({Set<String> single, List<String> phrases}) _blocked;
  final ({Set<String> single, List<String> phrases}) _brands;

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
