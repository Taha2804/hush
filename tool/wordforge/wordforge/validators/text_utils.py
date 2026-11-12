"""Text utilities that mirror lib/domain/text_utils.dart in Hushbug.

Kept in sync with the Flutter implementation so validation decisions match
exactly what the app does at load time.
"""

from __future__ import annotations

import re
from typing import Iterable, Set

STOPWORDS = {
    "a", "an", "the", "and", "or", "but", "if", "then", "of", "to", "in", "on",
    "at", "by", "for", "with", "as", "is", "are", "was", "were", "be", "been",
    "being", "have", "has", "had", "do", "does", "did", "will", "would", "could",
    "should", "may", "might", "must", "shall", "can", "need", "it", "its", "this",
    "that", "these", "those", "from", "up", "out", "over", "under", "again",
    "further", "once", "here", "there", "when", "where", "why", "how", "all",
    "both", "each", "few", "more", "most", "other", "some", "such", "no", "nor",
    "not", "only", "own", "same", "so", "than", "too", "very", "just", "also",
    "into", "through", "during", "before", "after", "above", "below", "between",
    "what", "which", "who", "whom", "any", "because", "while", "about", "he",
    "she", "him", "her", "his", "hers", "their", "they", "them", "we", "you",
    "us", "your", "my", "our", "i", "me", "myself", "himself", "itself",
}

# Common lemmatized suffixes used by the Flutter stem() function.
_SUFFIXES = (
    "ization", "isation", "ization", "ations", "ation", "ing", "ness",
    "ment", "ity", "ous", "ive", "ful", "less", "able", "ible", "al",
    "ly", "er", "or", "ist", "ism", "ate", "ize", "ise", "ed", "s",
)


def normalize(text: str) -> str:
    """Lowercase, collapse whitespace, strip punctuation."""
    if not text:
        return ""
    text = text.lower()
    text = text.replace("’", "'").replace("‘", "'")
    text = re.sub(r"[^\w\s'-]", " ", text)
    text = re.sub(r"\s+", " ", text)
    return text.strip()


def tokens(text: str) -> list[str]:
    """Split text into lowercase tokens."""
    return [t for t in normalize(text).split(" ") if t]


def stem(word: str) -> str:
    """Simple suffix-stripping stemmer mirroring the Dart implementation."""
    w = word.lower()
    if len(w) <= 4:
        return w
    for suf in _SUFFIXES:
        if w.endswith(suf) and len(w) - len(suf) >= 3:
            w = w[: -len(suf)]
            break
    return w


def content_stems(text: str) -> Set[str]:
    """Content stems of [s]: stop words and very short tokens removed."""
    return {
        stem(t) for t in tokens(text)
        if t not in STOPWORDS and len(t) >= 3
    }


def distinctive_stems(word: str, imposter: str) -> Set[str]:
    """Stems of imposter that the secret word lacks."""
    return content_stems(imposter).difference(content_stems(word))


def _flat(s: str) -> str:
    return normalize(s).replace(" ", "").replace("-", "")


def leaks_imposter(word: str, imposter: str, text: str) -> bool:
    """True when [text] (a description or hint) reveals [imposter]."""
    if not text or not text.strip():
        return False
    if normalize(text).count(normalize(imposter)) > 0:
        return True
    d = distinctive_stems(word, imposter)
    if not d:
        return False
    if d.intersection(content_stems(text)):
        return True
    imp = _flat(imposter)
    return len(imp) >= 5 and imp in _flat(text)


def related_forms(a: str, b: str) -> bool:
    """True when a and b are trivial spelling variants (singular/plural)."""
    na, nb = normalize(a), normalize(b)
    if na == nb:
        return True
    if len(na) >= 4 and len(nb) >= 4:
        if na + "s" == nb or nb + "s" == na:
            return True
        if na.endswith("s") and na[:-1] == nb:
            return True
        if nb.endswith("s") and nb[:-1] == na:
            return True
        if na.endswith("ing") and na[:-3] == nb:
            return True
        if nb.endswith("ing") and nb[:-3] == na:
            return True
    return False