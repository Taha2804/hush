"""Difficulty classification validation.

Ensures hint and imposter difficulty levels are internally consistent and
match the expected semantic progression (easy → direct, hard → subtle).
"""

from __future__ import annotations

from typing import List, Optional

from wordforge.database.models import Hint, ImposterWord


class DifficultyValidator:
    """Validates that hint and imposter difficulty tiers are correctly ordered."""

    def validate_hints(self, hints: List[Hint]) -> List[str]:
        """Returns list of issue reasons for hint difficulty ordering."""
        issues: List[str] = []
        by_level = {3: [], 2: [], 1: []}
        for h in hints:
            by_level.setdefault(h.level, []).append(h.text)

        # Check each tier exists and has content
        for level, label in [(3, "easy"), (2, "medium"), (1, "hard")]:
            if not by_level.get(level):
                issues.append(f"hint level {label} is empty")

        # Check progression: easy hints should be more direct than hard hints
        easy = by_level.get(3, [])
        hard = by_level.get(1, [])
        if easy and hard:
            for eh in easy:
                for hh in hard:
                    if self._is_too_similar(eh, hh):
                        issues.append(f"easy hint '{eh}' is too similar to hard hint '{hh}'")
        return issues

    def validate_imposters(self, imposters: List[ImposterWord]) -> List[str]:
        """Returns list of issue reasons for imposter difficulty ordering."""
        issues: List[str] = []
        by_level = {1: [], 2: [], 3: []}
        for i in imposters:
            by_level.setdefault(i.level, []).append(i.text)

        for level, label in [(1, "easy"), (2, "medium"), (3, "hard")]:
            if not by_level.get(level):
                issues.append(f"imposter level {label} is empty")

        # Easy imposters should be noticeably different; hard should be very close.
        # This is semantic and we can't fully check without LLM, but we can flag
        # identical strings across tiers.
        all_imp = [(i.level, i.text) for i in imposters]
        seen = {}
        for level, text in all_imp:
            key = text.lower().strip()
            if key in seen:
                issues.append(f"imposter '{text}' appears in multiple tiers")
            seen[key] = level
        return issues

    def _is_too_similar(self, a: str, b: str) -> bool:
        """Heuristic for semantic similarity between two hint strings."""
        from .text_utils import normalize, tokens
        ta = set(normalize(a).split())
        tb = set(normalize(b).split())
        if not ta or not tb:
            return False
        overlap = len(ta & tb) / min(len(ta), len(tb))
        return overlap > 0.7