"""Description validation mirroring lib/domain/word_rules.dart.

Rejects: empty, list separators (•|;\\n), 3+ commas, too short/long,
multiple sentences, naming the word itself, and reciting 3+ hints verbatim.
"""

from __future__ import annotations

import re
from typing import Iterable, List, Optional

from .text_utils import STOPWORDS, content_stems, normalize, tokens


class DescriptionValidator:
    """Validates a word description against the strict rules."""

    def __init__(self, min_words: int = 6, max_words: int = 20):
        self.min_words = min_words
        self.max_words = max_words

    def validate(
        self,
        word: str,
        description: Optional[str],
        hints: Iterable[str] = (),
    ) -> Optional[str]:
        """Returns null when acceptable, else a reason string."""
        d = (description or "").strip()
        if not d:
            return "empty"

        if any(c in d for c in "•|;\n"):
            return "list"
        if d.count(",") >= 3:
            return "list"

        n = len(d.split())
        if n < self.min_words:
            return "too-short"
        if n > self.max_words:
            return "too-long"

        if re.search(r"[.!?]\s+\S", d):
            return "multiple-sentences"

        nd = normalize(d)
        nw = normalize(word)
        if nw and nw in nd:
            return "names-word"

        wt = [t for t in tokens(word) if len(t) >= 3 and t not in STOPWORDS]
        ds = content_stems(d)
        if len(wt) == 1 and wt[0] in ds:
            return "names-word"
        if len(wt) > 1 and all(t in ds for t in wt):
            return "names-word"

        padded = " " + " ".join(tokens(d)) + " "
        verbatim = 0
        for h in hints:
            ht = tokens(h)
            if not ht or all(t in STOPWORDS for t in ht):
                continue
            if (" " + " ".join(ht) + " ") in padded:
                verbatim += 1
        if verbatim >= 3:
            return "repeats-hints"
        return None