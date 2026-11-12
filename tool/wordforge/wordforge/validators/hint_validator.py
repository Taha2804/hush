"""Hint validation mirroring lib/domain/validators.dart rejectHint()."""

from __future__ import annotations

from typing import List, Optional

from .text_utils import content_stems, normalize, related_forms, tokens


class HintValidator:
    """Validates a single hint against the secret word."""

    def __init__(self, blocklist: Optional[set] = None):
        self.blocklist = blocklist or set()

    def validate(self, word: str, hint: str) -> Optional[str]:
        """Returns null when acceptable, else a reason string."""
        if not hint or not hint.strip():
            return "empty"
        h = hint.strip()
        if normalize(h) == normalize(word):
            return "is-word"
        if related_forms(word, h):
            return "variant"
        if normalize(h).count(normalize(word)) > 0:
            return "is-word"
        # A hint that is just the word with a common prefix is too direct.
        if len(h) >= 4 and normalize(word).startswith(normalize(h)):
            return "is-word"
        if h in self.blocklist:
            return "blocked"
        if len(tokens(h)) < 2:
            return "too-short"
        return None


class HintSetValidator:
    """Validates a set of hints as a whole."""

    def __init__(self, min_per_tier: int = 6, max_per_tier: int = 10):
        self.min_per_tier = min_per_tier
        self.max_per_tier = max_per_tier

    def validate_tier(self, tier_hints: List[str]) -> List[str]:
        """Returns list of issue reasons for a single difficulty tier."""
        issues: List[str] = []
        if len(tier_hints) < self.min_per_tier:
            issues.append(f"need {self.min_per_tier}-{self.max_per_tier} hints, got {len(tier_hints)}")
        if len(tier_hints) > self.max_per_tier:
            issues.append(f"too many hints ({len(tier_hints)} > {self.max_per_tier})")
        seen = set()
        for h in tier_hints:
            key = normalize(h)
            if key in seen:
                issues.append(f"duplicate hint '{h}'")
            seen.add(key)
        # Reject hints that are all of the same type (a hint list, not a hint set).
        stems = [content_stems(h) for h in tier_hints]
        if len(stems) >= 3:
            overlap = set.intersection(*stems) if stems else set()
            if len(overlap) >= 3:
                issues.append("hints are near-duplicates")
        return issues