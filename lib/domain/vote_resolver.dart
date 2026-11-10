/// Target id used for the "No imposter" ballot.
const noImposterVote = -1;

sealed class VoteOutcome {
  const VoteOutcome();
}

/// A single player (or [noImposterVote]) received the most votes.
class VoteDecided extends VoteOutcome {
  const VoteDecided(this.target);
  final int target;
}

/// Several targets share the highest count.
class VoteTie extends VoteOutcome {
  const VoteTie(this.targets);
  final List<int> targets;
}

class NoVotes extends VoteOutcome {
  const NoVotes();
}

/// Counts ballots (voter -> target). Pure and deterministic.
class VoteResolver {
  const VoteResolver();

  Map<int, int> tally(Map<int, int> ballots) {
    final counts = <int, int>{};
    for (final t in ballots.values) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
    return counts;
  }

  VoteOutcome resolve(Map<int, int> ballots) {
    if (ballots.isEmpty) return const NoVotes();
    final counts = tally(ballots);
    final top = counts.values.reduce((a, b) => a > b ? a : b);
    final leaders = counts.entries.where((e) => e.value == top).map((e) => e.key).toList()
      ..sort();
    return leaders.length == 1 ? VoteDecided(leaders.first) : VoteTie(leaders);
  }
}
