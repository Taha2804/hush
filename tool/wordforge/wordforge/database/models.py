"""Hushbug WordForge — Data models for word records and packs."""

from __future__ import annotations

import uuid
from enum import Enum
from typing import Any, Dict, List, Optional

from pydantic import BaseModel, Field, field_validator, model_validator


class WordDifficulty(str, Enum):
    """How well-known a secret word is. Independent of hint/imposter difficulty."""
    EASY = "easy"
    MEDIUM = "medium"
    HARD = "hard"


class RecordStatus(str, Enum):
    COLLECTED = "collected"
    GENERATED = "generated"
    VALIDATED = "validated"
    APPROVED = "approved"
    REJECTED = "rejected"


class Hint(BaseModel):
    """A single hint for the imposter in Hint mode."""
    text: str
    level: int  # 3 = easy (direct), 2 = medium, 1 = hard (subtle)


class ImposterWord(BaseModel):
    """An alternative word handed to imposters in Fake Word mode."""
    text: str
    level: int = Field(default=2)  # 1 = easy (broad area), 3 = hard (very close)


class WordRecord(BaseModel):
    """A complete playable word record.

    Mirrors the Flutter WordEntry model and the v2 pack JSON schema.
    """
    id: str
    word: str
    category: str
    subcategory: Optional[str] = None
    difficulty: WordDifficulty = WordDifficulty.MEDIUM
    tags: List[str] = Field(default_factory=list)
    is_adult: bool = False
    hints: List[Hint] = Field(default_factory=list)
    imposters: List[ImposterWord] = Field(default_factory=list)
    description: Optional[str] = None
    source: str = ""  # "offline", "online", "wordforge"
    status: RecordStatus = RecordStatus.COLLECTED

    @field_validator("word")
    @classmethod
    def word_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("word must not be empty")
        return v.strip()

    @field_validator("category")
    @classmethod
    def category_not_empty(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("category must not be empty")
        return v.strip()

    def has_hints(self) -> bool:
        return len(self.hints) > 0

    def has_imposters(self) -> bool:
        return len(self.imposters) > 0

    def hints_by_level(self) -> Dict[int, List[str]]:
        result = {}
        for h in self.hints:
            result.setdefault(h.level, []).append(h.text)
        return result

    def imposters_by_level(self) -> Dict[int, List[str]]:
        result = {}
        for i in self.imposters:
            result.setdefault(i.level, []).append(i.text)
        return result

    def as_pack_json(self) -> Dict[str, Any]:
        """Convert to v2 pack word format (hints/imposters grouped by tier)."""
        hints_grouped = {"easy": [], "medium": [], "hard": []}
        for h in self.hints:
            tier = {3: "easy", 2: "medium", 1: "hard"}.get(h.level, "medium")
            hints_grouped[tier].append(h.text)

        imps_grouped = {"easy": [], "medium": [], "hard": []}
        for i in self.imposters:
            tier = {1: "easy", 2: "medium", 3: "hard"}.get(i.level, "medium")
            if tier not in imps_grouped:
                imps_grouped[tier] = []
            imps_grouped[tier].append(i.text)

        d = {
            "word": self.word,
            "sub": self.subcategory if self.subcategory else None,
            "diff": self.difficulty.value,
            "desc": self.description if self.description else None,
            "tags": self.tags,
            "hints": hints_grouped,
            "imposters": imps_grouped,
        }
        return d

    @classmethod
    def from_pack_json(
        cls,
        pack_id: str,
        w: Dict[str, Any],
        adult: bool = False,
        source: str = "offline",
    ) -> WordRecord:
        """Parse a v2 pack word object into a WordRecord."""
        hints = []
        raw_hints = w.get("hints", {})
        hint_tier_level = {"easy": 3, "medium": 2, "hard": 1}
        if isinstance(raw_hints, dict):
            for tier, level in hint_tier_level.items():
                for h in raw_hints.get(tier, []) or []:
                    if isinstance(h, str):
                        hints.append(Hint(text=h, level=level))
        elif isinstance(raw_hints, list):
            for h in raw_hints:
                if isinstance(h, dict) and "text" in h:
                    hints.append(Hint(text=h["text"], level=h.get("level", 2)))

        imposters = []
        raw_imps = w.get("imposters", w.get("fakes", []))
        imp_tier_level = {"easy": 1, "medium": 2, "hard": 3}
        if isinstance(raw_imps, dict):
            for tier, level in imp_tier_level.items():
                for f in raw_imps.get(tier, []) or []:
                    if isinstance(f, str):
                        imposters.append(ImposterWord(text=f, level=level))
        elif isinstance(raw_imps, list):
            for f in raw_imps:
                if isinstance(f, str):
                    imposters.append(ImposterWord(text=f))

        diff_val = w.get("diff", "medium")
        try:
            difficulty = WordDifficulty(diff_val)
        except ValueError:
            difficulty = WordDifficulty.MEDIUM

        word = w.get("word", "?")
        word_id = w.get("word_id", f"offline:{pack_id}:{_slugify(word)}")

        desc = w.get("desc", w.get("description", None))
        if isinstance(desc, str) and desc.strip():
            desc = desc.strip()
        else:
            desc = None

        return cls(
            id=word_id,
            word=word,
            category=pack_id,
            subcategory=w.get("sub"),
            difficulty=difficulty,
            tags=w.get("tags", []),
            is_adult=adult,
            hints=hints,
            imposters=imposters,
            description=desc,
            source=source,
        )


class PackMeta(BaseModel):
    """Metadata for a word pack."""
    id: str
    name: str
    description: str = ""
    icon: str = "category"
    is_adult: bool = False
    count: int = 0
    difficulty: Dict[str, int] = Field(default_factory=dict)
    version: int = 2
    schema_version: int = 3
    content_version: str = "1.0.0"
    generated_at: Optional[str] = None
    source: str = ""


class WordPack(BaseModel):
    """A complete word pack ready for export."""
    meta: PackMeta
    words: List[WordRecord] = Field(default_factory=list)

    def as_json(self) -> Dict[str, Any]:
        """Convert to v2 pack JSON."""
        return {
            "id": self.meta.id,
            "name": self.meta.name,
            "version": self.meta.version,
            "schema_version": self.meta.schema_version,
            "is_adult": self.meta.is_adult,
            "content_version": self.meta.content_version,
            "generated_at": self.meta.generated_at,
            "words": [w.as_pack_json() for w in self.words],
        }


class ValidationIssue(BaseModel):
    """A single validation issue found during validation."""
    pack_id: str
    word: str
    message: str
    category: str = "validation"
    severity: str = "error"  # "error", "warning"
    field: Optional[str] = None


class ValidationReport(BaseModel):
    """Report of validation results."""
    pack_id: str
    issues: List[ValidationIssue] = Field(default_factory=list)
    total_words: int = 0
    passed: int = 0
    failed: int = 0
    warnings: int = 0

    @property
    def is_clean(self) -> bool:
        return self.failed == 0

    def errors(self) -> List[ValidationIssue]:
        return [i for i in self.issues if i.severity == "error"]

    def warnings(self) -> List[ValidationIssue]:
        return [i for i in self.issues if i.severity == "warning"]


def _slugify(word: str) -> str:
    """Create a URL-safe slug from a word."""
    import re
    slug = word.lower().strip()
    slug = re.sub(r"[^a-z0-9]+", "-", slug)
    slug = slug.strip("-")
    return slug