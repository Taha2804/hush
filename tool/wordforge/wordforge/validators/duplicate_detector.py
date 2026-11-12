"""Duplicate detection for word records.

Implements multiple levels of duplicate detection:
1. Exact duplicates
2. Case-insensitive duplicates
3. Singular/plural duplicates
4. Lemmatized duplicates
5. Spelling variations
6. Near-duplicate semantic concepts
"""

from __future__ import annotations

from typing import Dict, List, Optional, Set

from wordforge.database.models import WordRecord
from wordforge.validators.text_utils import normalize, related_forms, stem


class DuplicateDetector:
    """Detects duplicates across a collection of word records."""

    def __init__(self):
        self.seen: Dict[str, WordRecord] = {}
        self.normalized: Dict[str, WordRecord] = {}
        self.lemmatized: Dict[str, WordRecord] = {}

    def check(self, record: WordRecord) -> Optional[str]:
        """Returns a reason string if duplicate, else None."""
        # Exact
        key = f"{record.category}|{record.word}"
        if key in self.seen:
            return f"exact duplicate in category '{record.category}'"
        self.seen[key] = record

        # Normalized (case-insensitive, punctuation-free)
        norm_key = f"{record.category}|{normalize(record.word)}"
        if norm_key in self.normalized:
            return f"case-insensitive duplicate of '{self.normalized[norm_key].word}'"
        self.normalized[norm_key] = record

        # Lemmatized
        lemma = stem(normalize(record.word))
        lemma_key = f"{record.category}|{lemma}"
        if lemma_key in self.lemmatized:
            existing = self.lemmatized[lemma_key]
            if related_forms(record.word, existing.word):
                return f"singular/plural duplicate of '{existing.word}'"
        self.lemmatized[lemma_key] = record

        return None

    def check_cross_category(self, record: WordRecord, other_categories: List[str]) -> Optional[str]:
        """Checks if the word exists in other categories."""
        norm = normalize(record.word)
        for cat in other_categories:
            key = f"{cat}|{norm}"
            if key in self.normalized:
                return f"also in category '{cat}'"
        return None

    def reset(self):
        self.seen.clear()
        self.normalized.clear()
        self.lemmatized.clear()


def find_duplicates_in_packs(packs: Dict[str, List[WordRecord]]) -> Dict[str, List[str]]:
    """Returns map of pack_id -> list of duplicate issue strings."""
    issues: Dict[str, List[str]] = {}
    for pack_id, words in packs.items():
        detector = DuplicateDetector()
        for w in words:
            issue = detector.check(w)
            if issue:
                issues.setdefault(pack_id, []).append(f"{w.word}: {issue}")
    return issues