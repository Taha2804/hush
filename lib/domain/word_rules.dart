/// Rules that keep a word's four fields (word, description, hints, imposter
/// words) logically separate. Mirrors tool/words/wordlib.py, which validates
/// the bundled packs at build time; the app re-checks every record at load
/// time and again right before dealing, so a bad record can never leak.
library;

import 'models/word_entry.dart';
import 'text_utils.dart';

/// Content stems of [s]: stop words and very short tokens removed.
Set<String> contentStems(String s) => {
      for (final t in tokens(s))
        if (!stopwords.contains(t) && t.length >= 3) stem(t),
    };

/// Content stems of imposter word [imposter] that the secret [word] lacks.
/// "Apple juice" vs "Orange juice" -> {apple}.
Set<String> distinctiveStems(String word, String imposter) =>
    contentStems(imposter).difference(contentStems(word));

String _flat(String s) => normalize(s).replaceAll(RegExp(r'[\s\-]'), '');

/// True when [text] (a description or hint) reveals [imposter].
bool leaksImposter(String word, String imposter, String text) {
  if (text.trim().isEmpty) return false;
  if (normalize(text).contains(normalize(imposter))) return true;
  final d = distinctiveStems(word, imposter);
  if (d.isEmpty) return false;
  if (d.intersection(contentStems(text)).isNotEmpty) return true;
  final imp = _flat(imposter);
  return imp.length >= 5 && _flat(text).contains(imp);
}

/// Why [imposter] cannot be handed out alongside [entry], or null if it can.
/// Checks the secret word, every hint and the description.
String? imposterConflict(WordEntry entry, String imposter) {
  if (normalize(imposter) == normalize(entry.word)) return 'same-word';
  if (relatedForms(entry.word, imposter)) return 'variant';
  final d = entry.description;
  if (d != null && leaksImposter(entry.word, imposter, d)) return 'in-description';
  for (final h in entry.hints) {
    if (normalize(h.text) == normalize(imposter)) return 'is-hint';
    if (leaksImposter(entry.word, imposter, h.text)) return 'in-hint';
  }
  return null;
}

/// Description quality settings. Curated packs use the strict defaults;
/// online sources (short encyclopedia descriptions) use [lenient].
class DescriptionRules {
  const DescriptionRules({this.minWords = 6, this.maxWords = 20});
  const DescriptionRules.lenient() : minWords = 2, maxWords = 24;
  final int minWords;
  final int maxWords;
}

/// Validates a description. Returns null when acceptable, else a reason.
///
/// Rejects: empty, list separators or comma lists (the old "a • b • c"
/// format), too short/long, more than one sentence, naming the word itself,
/// and reciting 3+ of the hints.
String? rejectDescription(
  String word,
  String? description, {
  Iterable<String> hints = const [],
  DescriptionRules rules = const DescriptionRules(),
}) {
  final d = description?.trim() ?? '';
  if (d.isEmpty) return 'empty';
  if (RegExp(r'[•|;\n]').hasMatch(d)) return 'list';
  if (','.allMatches(d).length >= 3) return 'list';
  final n = d.split(RegExp(r'\s+')).length;
  if (n < rules.minWords) return 'too-short';
  if (n > rules.maxWords) return 'too-long';
  if (RegExp(r'[.!?]\s+\S').hasMatch(d)) return 'multiple-sentences';

  final nd = normalize(d);
  if (RegExp('\\b${RegExp.escape(normalize(word))}\\b').hasMatch(nd)) return 'names-word';
  final wt = [for (final t in tokens(word)) if (t.length >= 3 && !stopwords.contains(t)) t];
  final ds = contentStems(d);
  if (wt.length == 1 && ds.contains(stem(wt.first))) return 'names-word';
  if (wt.length > 1 && wt.every((t) => ds.contains(stem(t)))) return 'names-word';

  final padded = ' ${tokens(d).join(' ')} ';
  var verbatim = 0;
  for (final h in hints) {
    final ht = tokens(h);
    if (ht.isEmpty || ht.every(stopwords.contains)) continue;
    if (padded.contains(' ${ht.join(' ')} ')) verbatim++;
  }
  if (verbatim >= 3) return 'repeats-hints';
  return null;
}

/// Turns a raw short description (e.g. "fruit of the apple tree") into a
/// sentence ("Fruit of the apple tree.").
String sentenceCase(String raw) {
  var t = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t.isEmpty) return t;
  t = t[0].toUpperCase() + t.substring(1);
  if (!RegExp(r'[.!?]$').hasMatch(t)) t = '$t.';
  return t;
}
