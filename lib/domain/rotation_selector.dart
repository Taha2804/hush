import 'models/word_entry.dart';
import 'random_service.dart';

/// Persisted usage of a rotating pool (hints or fake words) for one word.
class RotationUsage {
  RotationUsage({Set<int>? shown, this.last}) : shown = shown ?? <int>{};

  final Set<int> shown;
  int? last;

  Map<String, dynamic> toJson() => {'shown': shown.toList(), 'last': last};

  factory RotationUsage.fromJson(Map<String, dynamic> json) => RotationUsage(
        shown: Set<int>.from(
            (json['shown'] as List? ?? const []).map((e) => (e as num).toInt())),
        last: (json['last'] as num?)?.toInt(),
      );
}

/// Picks indices from a pool so that every item is shown before any repeat,
/// and the same item is never shown twice in a row (when pool size > 1).
///
/// When [levels] is given, only items at [targetLevel] are used (or, if the
/// word has none at that level, the nearest level that exists). Rotation
/// happens *within* that level, so a difficulty never drifts into another
/// level's hints just because its own hints were already shown.
int pickRotating({
  required int count,
  required RotationUsage usage,
  required RandomService random,
  List<int>? levels,
  int? targetLevel,
}) {
  if (count <= 0) return -1;
  usage.shown.removeWhere((i) => i < 0 || i >= count);
  if (usage.last != null && usage.last! >= count) usage.last = null;

  var pool = [for (var i = 0; i < count; i++) i];
  if (levels != null && targetLevel != null) {
    for (var d = 0; d <= 2; d++) {
      final atD = pool.where((i) => (levels[i] - targetLevel).abs() == d).toList();
      if (atD.isNotEmpty) {
        // Prefer the easier side on ties (e.g. target 2 with only 1s and 3s).
        final higher = atD.where((i) => levels[i] >= targetLevel).toList();
        pool = d > 0 && higher.isNotEmpty ? higher : atD;
        break;
      }
    }
  }

  var candidates = [for (final i in pool) if (!usage.shown.contains(i)) i];
  if (candidates.isEmpty) {
    // Everything in this pool was shown: start a new cycle for the pool only.
    usage.shown.removeAll(pool);
    candidates = [for (final i in pool) if (pool.length == 1 || i != usage.last) i];
  }
  final idx = random.pick(candidates);
  usage.shown.add(idx);
  usage.last = idx;
  return idx;
}

/// Hint rotation per word (R3).
class HintSelector {
  HintSelector(this.random);
  final RandomService random;

  /// Returns the chosen hint, or null if the word has no hints.
  Hint? select(WordEntry entry, int level, RotationUsage usage) {
    if (entry.hints.isEmpty) return null;
    final i = pickRotating(
      count: entry.hints.length,
      usage: usage,
      random: random,
      levels: [for (final h in entry.hints) h.level],
      targetLevel: level,
    );
    return entry.hints[i];
  }
}

/// Fake-word rotation per word (R3, Fake Word mode).
class FakeWordSelector {
  FakeWordSelector(this.random);
  final RandomService random;

  String? select(WordEntry entry, RotationUsage usage) {
    if (entry.fakeWords.isEmpty) return null;
    final i = pickRotating(
      count: entry.fakeWords.length,
      usage: usage,
      random: random,
    );
    return entry.fakeWords[i];
  }
}
