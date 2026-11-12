"""Validation pipeline: validates records and produces reports."""

from __future__ import annotations

from typing import Dict, List

from wordforge.database.models import WordPack
from wordforge.validators.structural_validator import StructuralValidator


class ValidationPipeline:
    """Runs all validation stages and produces a comprehensive report."""

    def __init__(self, min_words_per_pack: int = 60):
        self.validator = StructuralValidator(min_words_per_pack=min_words_per_pack)

    def run(self, pack: WordPack) -> Dict:
        """Run validation and return structured results."""
        report = self.validator.validate_pack(pack)
        return {
            "pack_id": report.pack_id,
            "total_words": report.total_words,
            "passed": report.passed,
            "failed": report.failed,
            "warnings": report.warnings,
            "is_clean": report.is_clean,
            "issues": [
                {
                    "pack": i.pack_id,
                    "word": i.word,
                    "message": i.message,
                    "category": i.category,
                    "severity": i.severity,
                    "field": i.field,
                }
                for i in report.issues
            ],
        }