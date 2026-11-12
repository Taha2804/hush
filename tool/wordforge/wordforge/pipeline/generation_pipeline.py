"""Generation pipeline: orchestrates the full collect → generate → validate flow."""

from __future__ import annotations

import asyncio
import json
import os
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional

from wordforge.database.models import (
    Hint,
    ImposterWord,
    PackMeta,
    RecordStatus,
    WordDifficulty,
    WordPack,
    WordRecord,
)
from wordforge.generators.description_generator import (
    DescriptionGenerator,
    HintGenerator,
    ImposterGenerator,
    DifficultyClassifier,
    LLMClient,
    LLMConfig,
)
from wordforge.pipeline.validation_pipeline import ValidationPipeline
from wordforge.validators.category_validator import CategoryValidator


@dataclass
class GenerationConfig:
    hints_per_tier: int = 6
    imposters_per_tier: int = 3
    min_words_per_pack: int = 60
    max_words_per_pack: int = 200


class GenerationPipeline:
    """Full generation pipeline for a single category."""

    def __init__(
        self,
        category_id: str,
        category_name: str,
        target_count: int,
        config: GenerationConfig,
        llm_config: LLMConfig,
        output_dir: str = "output/generated",
    ):
        self.category_id = category_id
        self.category_name = category_name
        self.target_count = target_count
        self.config = config
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)

        self.llm = LLMClient(llm_config)
        self.desc_gen = DescriptionGenerator(self.llm)
        self.hint_gen = HintGenerator(self.llm)
        self.imp_gen = ImposterGenerator(self.llm)
        self.diff_cls = DifficultyClassifier(self.llm)
        self.validator = ValidationPipeline(config.min_words_per_pack)
        self.cat_validator = CategoryValidator(config.min_words_per_pack)

    def _load_candidates(self) -> List[str]:
        """Load candidate words from source files."""
        source_file = Path(f"tool/words/categories.json")
        # For now, we'll generate candidates from the category configuration
        # In practice, this would load from wikipedia/wikidata collectors
        return []

    async def _generate_record(self, word: str, subcategory: Optional[str] = None) -> WordRecord:
        """Generate a complete word record."""
        # Description
        description = await self.desc_gen.generate(word, self.category_name, subcategory)

        # Difficulty
        diff_str = await self.diff_cls.classify(word, self.category_name)
        difficulty = WordDifficulty(diff_str)

        # Hints
        hints_data = await self.hint_gen.generate(word, self.category_name, description)
        hints = []
        for level, label in [(3, "easy"), (2, "medium"), (1, "hard")]:
            for text in hints_data.get(label, [])[: self.config.hints_per_tier]:
                hints.append(Hint(text=text, level=level))

        # Imposters
        hints_list = [h.text for h in hints]
        imps_data = await self.imp_gen.generate(word, self.category_name, description, hints_list)
        imposters = []
        for level, label in [(1, "easy"), (2, "medium"), (3, "hard")]:
            for text in imps_data.get(label, [])[: self.config.imposters_per_tier]:
                imposters.append(ImposterWord(text=text, level=level))

        word_id = f"wf:{self.category_id}:{word.lower().replace(' ', '-')}"

        return WordRecord(
            id=word_id,
            word=word,
            category=self.category_id,
            subcategory=subcategory,
            difficulty=difficulty,
            tags=[],
            is_adult=self.category_id == "after_dark",
            hints=hints,
            imposters=imposters,
            description=description,
            source="wordforge",
            status=RecordStatus.GENERATED,
        )

    async def generate_pack(
        self,
        candidates: List[str],
        resume_from: Optional[str] = None,
    ) -> WordPack:
        """Generate a full pack from candidate words."""
        records: List[WordRecord] = []
        skip = resume_from is not None

        for word in candidates:
            if skip:
                if word == resume_from:
                    skip = False
                else:
                    continue

            print(f"Generating: {word}")
            try:
                record = await self._generate_record(word)
                records.append(record)

                # Checkpoint every 10 records
                if len(records) % 10 == 0:
                    self._save_checkpoint(records)

                if len(records) >= self.target_count:
                    break
            except Exception as e:
                print(f"  Error generating {word}: {e}")

        # Build pack meta
        diff_counts = {"easy": 0, "medium": 0, "hard": 0}
        for r in records:
            diff_counts[r.difficulty.value] += 1

        meta = PackMeta(
            id=self.category_id,
            name=self.category_name,
            description=f"Generated WordForge pack for {self.category_name}",
            icon="category",
            is_adult=self.category_id == "after_dark",
            count=len(records),
            difficulty=diff_counts,
            schema_version=3,
            content_version="1.0.0",
            generated_at=datetime.utcnow().isoformat() + "Z",
            source="wordforge",
        )

        pack = WordPack(meta=meta, words=records)
        return pack

    def _save_checkpoint(self, records: List[WordRecord]):
        """Save progress checkpoint."""
        cp_file = self.output_dir / f"{self.category_id}_checkpoint.json"
        data = [r.as_pack_json() for r in records]
        with open(cp_file, "w") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    def _load_checkpoint(self) -> Optional[List[WordRecord]]:
        """Load from checkpoint if exists."""
        cp_file = self.output_dir / f"{self.category_id}_checkpoint.json"
        if not cp_file.exists():
            return None
        with open(cp_file) as f:
            data = json.load(f)
        return [WordRecord.from_pack_json(self.category_id, w, source="wordforge") for w in data]


async def generate_category(
    category_id: str,
    category_name: str,
    target: int,
    candidates: List[str],
    llm_config: LLMConfig,
    gen_config: GenerationConfig,
    output_dir: str = "output/generated",
) -> WordPack:
    """Convenience function to generate a single category pack."""
    pipeline = GenerationPipeline(
        category_id, category_name, target, gen_config, llm_config, output_dir
    )
    return await pipeline.generate_pack(candidates)


async def generate_all_categories(
    category_targets: Dict[str, int],
    candidates_by_category: Dict[str, List[str]],
    llm_config: LLMConfig,
    gen_config: GenerationConfig,
    output_dir: str = "output/generated",
) -> Dict[str, WordPack]:
    """Generate multiple categories sequentially."""
    results = {}
    for cat_id, target in category_targets.items():
        if cat_id not in candidates_by_category:
            print(f"No candidates for {cat_id}, skipping")
            continue
        print(f"\n=== Generating {cat_id} ({target} words) ===")
        pack = await generate_category(
            cat_id,
            [c["name"] for c in category_targets if c["id"] == cat_id][0] if False else cat_id,
            target,
            candidates_by_category[cat_id],
            llm_config,
            gen_config,
            output_dir,
        )
        results[cat_id] = pack
    return results