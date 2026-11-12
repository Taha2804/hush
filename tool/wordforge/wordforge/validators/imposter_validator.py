"""Imposter validation mirroring lib/domain/word_rules.dart imposterConflict()."""

from __future__ import annotations

from typing import List, Optional

from .text_utils import leaks_imposter, normalize, related_forms


class ImposterValidator:
    """Validates an imposter alternative against the secret word."""

    def validate(self, word: str, imposter: str, hints: List[str], description: Optional[str]) -> Optional[str]:
        """Returns null when safe, else a reason string."""
        if not imposter or not imposter.strip():
            return "empty"
        if normalize(imposter) == normalize(word):
            return "same-word"
        if related_forms(word, imposter):
            return "variant"
        if description and leaks_imposter(word, imposter, description):
            return "in-description"
        for h in hints:
            if normalize(h) == normalize(imposter):
                return "is-hint"
            if leaks_imposter(word, imposter, h):
                return "in-hint"
        return None


def imposter_conflict(word: str, imposter: str, hints: List[str], description: Optional[str]) -> Optional[str]:
    """Convenience wrapper returning the conflict reason, or null if safe."""
    return ImposterValidator().validate(word, imposter, hints, description)


def safe_imposters(word: str, imposters: List[str], hints: List[str], description: Optional[str]) -> List[str]:
    """Return only imposters that are safe to hand out."""
    return [i for i in imposters if imposter_conflict(word, i, hints, description) is None]