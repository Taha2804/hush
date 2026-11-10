import 'random_service.dart';

/// How many most-recently dealt items must not reappear in the first
/// [ShuffleBag.boundaryWindow] positions after a reshuffle.
const _window = 10;

/// Serializable state of a persistent shuffle bag.
class ShuffleBagState {
  ShuffleBagState({
    List<String>? remaining,
    Set<String>? dealt,
    List<String>? recent,
    this.cycles = 0,
  })  : remaining = remaining ?? <String>[],
        dealt = dealt ?? <String>{},
        recent = recent ?? <String>[];

  /// Items still in the bag, in deal order.
  final List<String> remaining;

  /// Items already dealt during the current cycle.
  final Set<String> dealt;

  /// Last up to 10 dealt items (oldest first) across cycle boundaries.
  final List<String> recent;

  /// Number of times the bag has been (re)filled.
  int cycles;

  Map<String, dynamic> toJson() => {
        'remaining': remaining,
        'dealt': dealt.toList(),
        'recent': recent,
        'cycles': cycles,
      };

  factory ShuffleBagState.fromJson(Map<String, dynamic> json) => ShuffleBagState(
        remaining: List<String>.from(json['remaining'] as List? ?? const []),
        dealt: Set<String>.from(json['dealt'] as List? ?? const []),
        recent: List<String>.from(json['recent'] as List? ?? const []),
        cycles: (json['cycles'] as num?)?.toInt() ?? 0,
      );
}

/// Persistent shuffle bag ("deck of cards") over a pool of item ids.
///
/// * The pool is shuffled once and dealt one by one.
/// * It is refilled and reshuffled ONLY when empty.
/// * After a reshuffle, none of the last 10 dealt items is placed in the
///   first 10 positions (when the pool is large enough to allow it).
/// * The pool may grow or shrink between deals (online source): new ids
///   are inserted at random positions among the remaining items.
class ShuffleBag {
  ShuffleBag(this.state, this.random);

  static const boundaryWindow = _window;

  final ShuffleBagState state;
  final RandomService random;

  int get remainingCount => state.remaining.length;

  /// Reconcile the bag with the current [pool].
  void sync(Set<String> pool) {
    state.remaining.removeWhere((id) => !pool.contains(id));
    state.dealt.removeWhere((id) => !pool.contains(id));
    final known = {...state.remaining, ...state.dealt};
    final fresh = pool.where((id) => !known.contains(id)).toList();
    random.shuffleInPlace(fresh);
    for (final id in fresh) {
      final pos = random.nextInt(state.remaining.length + 1);
      state.remaining.insert(pos, id);
    }
  }

  void _refill(Set<String> pool) {
    final order = random.shuffled(pool);
    state.dealt.clear();
    state.cycles++;
    final recent = state.recent.toSet();
    final head = order.length < _window ? order.length : _window;
    if (order.length > _window && recent.isNotEmpty) {
      for (var i = 0; i < head; i++) {
        if (!recent.contains(order[i])) continue;
        // Swap with a random non-recent item from the tail region.
        final candidates = <int>[
          for (var j = _window; j < order.length; j++)
            if (!recent.contains(order[j])) j,
        ];
        if (candidates.isEmpty) break;
        final j = random.pick(candidates);
        final tmp = order[i];
        order[i] = order[j];
        order[j] = tmp;
      }
    }
    state.remaining
      ..clear()
      ..addAll(order);
  }

  /// Deals the next item from [pool]. Items for which [avoid] returns true
  /// (e.g. words in the global recent history) are skipped while any other
  /// item remains in the bag. Returns null only if [pool] is empty.
  String? deal(Set<String> pool, {bool Function(String id)? avoid}) {
    if (pool.isEmpty) return null;
    sync(pool);
    if (state.remaining.isEmpty) _refill(pool);
    var index = 0;
    if (avoid != null) {
      final i = state.remaining.indexWhere((id) => !avoid(id));
      if (i >= 0) index = i;
    }
    final id = state.remaining.removeAt(index);
    state.dealt.add(id);
    state.recent.add(id);
    while (state.recent.length > _window) {
      state.recent.removeAt(0);
    }
    return id;
  }
}
