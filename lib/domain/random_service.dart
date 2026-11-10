import 'dart:math';

/// The single source of randomness for every gameplay decision.
///
/// Production code uses [Random.secure]. Tests inject a seeded [Random].
/// All shuffles are Fisher-Yates.
class RandomService {
  RandomService([Random? random]) : _r = random ?? Random.secure();

  final Random _r;

  int nextInt(int max) => _r.nextInt(max);
  double nextDouble() => _r.nextDouble();

  /// True with probability [p] (0..1).
  bool chance(double p) {
    if (p <= 0) return false;
    if (p >= 1) return true;
    return _r.nextDouble() < p;
  }

  /// In-place Fisher-Yates shuffle.
  void shuffleInPlace<T>(List<T> list) {
    for (var i = list.length - 1; i > 0; i--) {
      final j = _r.nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }

  List<T> shuffled<T>(Iterable<T> items) {
    final list = List<T>.of(items);
    shuffleInPlace(list);
    return list;
  }

  T pick<T>(List<T> items) {
    if (items.isEmpty) throw ArgumentError('Cannot pick from an empty list');
    return items[_r.nextInt(items.length)];
  }

  /// Uniform random subset of size [k] (partial Fisher-Yates), in draw order.
  List<T> sample<T>(List<T> items, int k) {
    if (k < 0 || k > items.length) {
      throw ArgumentError('k=$k out of range for ${items.length} items');
    }
    final list = List<T>.of(items);
    for (var i = 0; i < k; i++) {
      final j = i + _r.nextInt(list.length - i);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list.sublist(0, k);
  }

  /// Picks an index with probability proportional to [weights].
  int pickWeightedIndex(List<double> weights) {
    if (weights.isEmpty) throw ArgumentError('No weights');
    final total = weights.fold<double>(0, (a, b) => a + (b < 0 ? 0 : b));
    if (total <= 0) return _r.nextInt(weights.length);
    var x = _r.nextDouble() * total;
    for (var i = 0; i < weights.length; i++) {
      final w = weights[i] < 0 ? 0 : weights[i];
      if (x < w) return i;
      x -= w;
    }
    return weights.length - 1;
  }
}
