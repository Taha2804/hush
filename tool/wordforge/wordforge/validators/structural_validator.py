"""Structural validation for word records.

Performs all validation stages and produces a comprehensive report.
"""

from __future__ import annotations

from typing import Dict, List, Optional

from wordforge.database.models import (
    Hint,
    ImposterWord,
    PackMeta,
    ValidationIssue,
    ValidationReport,
    WordDifficulty,
    WordPack,
    WordRecord,
)
from wordforge.validators.category_validator import CategoryValidator
from wordforge.validators.description_validator import DescriptionValidator
from wordforge.validators.difficulty_validator import DifficultyValidator
from wordforge.validators.duplicate_detector import DuplicateDetector
from wordforge.validators.hint_validator import HintSetValidator, HintValidator
from wordforge.validators.imposter_validator import ImposterValidator
from wordforge.validators.text_utils import normalize


class StructuralValidator:
    """Main validation entry point. Mirrors lib/domain/pack_validator.dart."""

    def __init__(
        self,
        min_words_per_pack: int = 60,
        min_hints_per_tier: int = 6,
        max_hints_per_tier: int = 10,
        min_imposters_per_tier: int = 2,
    ):
        self.min_words = min_words_per_pack
        self.hint_validator = HintValidator()
        self.hint_set_validator = HintSetValidator(min_hints_per_tier, max_hints_per_tier)
        self.imposter_validator = ImposterValidator()
        self.difficulty_validator = DifficultyValidator()
        self.category_validator = CategoryValidator(min_words_per_pack)
        self.description_validator = DescriptionValidator()
        self.duplicate_detector = DuplicateDetector()

    def validate_record(
        self,
        record: WordRecord,
        pack_id: str,
        all_categories: Optional[List[str]] = None,
    ) -> List[ValidationIssue]:
        """Validate a single record and return all issues."""
        issues: List[ValidationIssue] = []

        # Required fields
        if not record.id:
            issues.append(ValidationIssue(pack_id, record.word or "?", "missing id", "structural"))
        if not record.word:
            issues.append(ValidationIssue(pack_id, "?", "missing word", "structural"))
        if not record.category:
            issues.append(ValidationIssue(pack_id, record.word or "?", "missing category", "structural"))

        # Category
        cat_issue = self.category_validator.validate_category_id(record.category)
        if cat_issue:
            issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=cat_issue, category="category"))

        adult_issue = self.category_validator.validate_adult_flag(record.category, record.is_adult)
        if adult_issue:
            issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=adult_issue, category="adult"))

        # Difficulty
        if not isinstance(record.difficulty, WordDifficulty):
            issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message="invalid difficulty enum", category="difficulty"))

        # Description
        hint_texts = [h.text for h in record.hints]
        desc_issue = self.description_validator.validate(record.word, record.description, hint_texts)
        if desc_issue:
            issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=f"description: {desc_issue}", category="description"))

        # Hints - individual
        for h in record.hints:
            hint_issue = self.hint_validator.validate(record.word, h.text)
            if hint_issue:
                issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=f"hint '{h.text}': {hint_issue}", category="hint"))

        # Hints - tier structure
        hints_by_tier = {3: [], 2: [], 1: []}
        for h in record.hints:
            hints_by_tier.setdefault(h.level, []).append(h.text)
        for level, label in [(3, "easy"), (2, "medium"), (1, "hard")]:
            tier_issues = self.hint_set_validator.validate_tier(hints_by_tier.get(level, []))
            for ti in tier_issues:
                issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=f"hint {label}: {ti}", category="hint"))

        # Imposters - individual
        hint_texts = [h.text for h in record.hints]
        for i in record.imposters:
            imp_issue = self.imposter_validator.validate(record.word, i.text, hint_texts, record.description)
            if imp_issue:
                issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=f"imposter '{i.text}': {imp_issue}", category="imposter"))

        # Imposters - tier structure (validate all tiers together)
        all_imposters = record.imposters
        tier_issues = self.difficulty_validator.validate_imposters(all_imposters)
        for ti in tier_issues:
            issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=f"imposter: {ti}", category="imposter"))

        # Cross-field
        if record.description:
            for i in record.imposters:
                if normalize(i.text) in normalize(record.description):
                    issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=f"imposter '{i.text}' appears in description", category="cross-field"))
        for h in record.hints:
            for i in record.imposters:
                if normalize(h.text) == normalize(i.text):
                    issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=f"hint '{h.text}' equals imposter '{i.text}'", category="cross-field"))

        # Duplicates (across pack)
        dup_issue = self.duplicate_detector.check(record)
        if dup_issue:
            issues.append(ValidationIssue(pack_id=pack_id, word=record.word, message=dup_issue, category="duplicate"))

        return issues

    def validate_pack(self, pack: WordPack) -> ValidationReport:
        """Validate an entire pack and return a report."""
        self.duplicate_detector.reset()
        all_issues: List[ValidationIssue] = []
        for record in pack.words:
            issues = self.validate_record(record, pack.meta.id)
            all_issues.extend(issues)

        # Pack-level
        pack_issues = self.category_validator.validate_pack(pack.words)
        for pi in pack_issues:
            all_issues.append(ValidationIssue(pack_id=pack.meta.id, word="-", message=pi, category="pack"))

        passed = sum(1 for _ in pack.words if not any(i.word == _.word for i in all_issues))
        failed = len(pack.words) - passed
        warnings = sum(1 for i in all_issues if i.severity == "warning")

        return ValidationReport(
            pack_id=pack.meta.id,
            issues=all_issues,
            total_words=len(pack.words),
            passed=passed,
            failed=failed,
            warnings=warnings,
        )