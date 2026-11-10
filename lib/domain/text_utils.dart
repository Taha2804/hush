/// Small, dependency-free text helpers shared by validators and selectors.
library;

String normalize(String s) =>
    s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

/// Splits on whitespace, hyphens and apostrophes; lower-cased.
List<String> tokens(String s) => normalize(s)
    .split(RegExp(r"[\s\-'’/,.;:!?()]+"))
    .where((t) => t.isNotEmpty)
    .toList();

/// Very small English stemmer, good enough to catch plurals and common
/// suffixes ("cherries" -> "cherry", "boxes" -> "box", "baking" -> "bak").
String stem(String token) {
  var t = token.toLowerCase();
  if (t.length > 4 && t.endsWith('ies')) {
    t = '${t.substring(0, t.length - 3)}y';
  } else if (t.length > 4 && t.endsWith('ves')) {
    t = '${t.substring(0, t.length - 3)}f';
  } else if (t.length > 4 &&
      t.endsWith('es') &&
      RegExp(r'(s|x|z|ch|sh)es$').hasMatch(t)) {
    t = t.substring(0, t.length - 2);
  } else if (t.length > 3 && t.endsWith('s') && !t.endsWith('ss')) {
    t = t.substring(0, t.length - 1);
  }
  if (t.length > 5 && t.endsWith('ing')) {
    t = t.substring(0, t.length - 3);
  } else if (t.length > 4 && t.endsWith('ed')) {
    t = t.substring(0, t.length - 2);
  }
  return t;
}

/// True when [a] and [b] are the same word modulo plural/stem, or one
/// clearly contains the other (substring of length >= 4).
bool relatedForms(String a, String b) {
  final x = normalize(a).replaceAll(RegExp(r'[\s\-]'), '');
  final y = normalize(b).replaceAll(RegExp(r'[\s\-]'), '');
  if (x.isEmpty || y.isEmpty) return false;
  if (x == y || stem(x) == stem(y)) return true;
  if (x.length >= 4 && y.contains(x)) return true;
  if (y.length >= 4 && x.contains(y)) return true;
  return false;
}

String slugify(String s) => normalize(s)
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

const stopwords = <String>{
  'a', 'an', 'the', 'of', 'in', 'on', 'at', 'to', 'for', 'with', 'and', 'or',
  'by', 'from', 'is', 'are', 'it', 'its', 'as', 'be', 'into', 'over', 'very',
  'can', 'you', 'your', 'some', 'often', 'has', 'have', 'that', 'this', 'not',
  'no', 'up', 'out', 'off', 'than', 'too', 'may', 'one', 'who', 'what', 'all',
};
