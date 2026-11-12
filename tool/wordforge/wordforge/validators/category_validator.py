"""Category validation.

Ensures each word belongs to the correct category and that categories have
sufficient word counts and diversity.
"""

from __future__ import annotations

from typing import Dict, List, Optional, Set

from wordforge.database.models import WordRecord


class CategoryValidator:
    """Validates category assignments and pack-level requirements."""

    VALID_CATEGORIES = {
        "animals_wildlife", "food_drinks", "science_technology", "geography_places",
        "movies_entertainment", "sports_games", "hobbies_leisure", "everyday_objects",
        "professions_jobs", "history_culture", "nature_environment", "vehicles_transport",
        "music_art", "brands_products", "internet_social", "mythology_fiction",
        "body_health", "business_finance", "education_knowledge", "travel_tourism",
        "after_dark",
    }

    ADULT_CATEGORIES = {"after_dark"}

    def __init__(self, min_words_per_pack: int = 60):
        self.min_words_per_pack = min_words_per_pack

    def validate_category_id(self, category: str) -> Optional[str]:
        """Returns error message if category is invalid, else None."""
        if category not in self.VALID_CATEGORIES:
            return f"invalid category '{category}'"
        return None

    def validate_adult_flag(self, category: str, is_adult: bool) -> Optional[str]:
        """Checks that is_adult matches the category."""
        is_adult_category = category in self.ADULT_CATEGORIES
        if is_adult_category != is_adult:
            return f"is_adult={is_adult} does not match category '{category}'"
        return None

    def validate_pack(self, words: List[WordRecord]) -> List[str]:
        """Validates the entire pack as a unit."""
        issues: List[str] = []
        if len(words) < self.min_words_per_pack:
            issues.append(f"pack has {len(words)} words, minimum is {self.min_words_per_pack}")

        # Check diversity: too many words from the same subcategory
        sub_counts: Dict[str, int] = {}
        for w in words:
            sub = w.subcategory or "uncategorized"
            sub_counts[sub] = sub_counts.get(sub, 0) + 1
        for sub, count in sub_counts.items():
            if count > len(words) * 0.3:
                issues.append(f"subcategory '{sub}' dominates ({count}/{len(words)} words)")

        # Check difficulty distribution
        diff_counts = {"easy": 0, "medium": 0, "hard": 0}
        for w in words:
            diff_counts[w.difficulty.value] += 1
        for diff, count in diff_counts.items():
            if count == 0:
                issues.append(f"no {diff} difficulty words")
            elif count > len(words) * 0.8:
                issues.append(f"{diff} difficulty dominates ({count}/{len(words)} words)")
        return issues