#!/usr/bin/env python3
"""Generate v2 records for the final 3 countries: Mauritius, Seychelles, Mali."""

import json
import sys
sys.path.insert(0, ".")

from tool.words.wordlib import load_categories, Lists, validate_record

lists = Lists()
cats_list = load_categories()
cats = {c['id']: c for c in cats_list}

records = []

# 1. Mauritius - Fix: description must not reuse hint phrases
records.append({
    "word": "Mauritius",
    "category": "geography_places",
    "subcategory": "Indian Ocean",
    "difficulty": "hard",
    "description": "A tropical island state in the Indian Ocean celebrated for its lagoons and biodiversity.",
    "tags": ["indian", "ocean", "island"],
    "hints": {
        "easy": ["Indian Ocean", "Island nation", "Coral reefs", "Extinct dodo", "Port Louis", "Tropical climate"],
        "medium": ["Sugar cane", "Volcanic origin", "Mauritian culture", "Seven colored earth", "Island paradise", "Hindu temples"],
        "hard": ["Dodo extinction", "Chamarel colors", "Economic success", "Multicultural", "Tourism hub", "Endemic birds"]
    },
    "imposters": {
        "easy": ["Maldives", "Seychelles"],
        "medium": ["Madagascar", "Comoros"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 2. Seychelles - Fix: description must not reuse hint phrases
records.append({
    "word": "Seychelles",
    "category": "geography_places",
    "subcategory": "Indian Ocean",
    "difficulty": "hard",
    "description": "An Indian Ocean archipelago famed for its rare palm trees and marine reserves.",
    "tags": ["indian", "ocean", "archipelago"],
    "hints": {
        "easy": ["Indian Ocean", "Island group", "Giant tortoises", "Pristine beaches", "Victoria capital", "Granite islands"],
        "medium": ["Coco de mer", "Aldabra atoll", "Marine parks", "Rare birds", "Island hopping", "Conservation"],
        "hard": ["Unique palms", "Tortoise sanctuary", "Granite boulders", "Marine reserves", "Eco tourism", "Smallest Africa"]
    },
    "imposters": {
        "easy": ["Maldives", "Mauritius"],
        "medium": ["Comoros", "Madagascar"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 3. Mali - Fix: description must not reuse hint phrases
records.append({
    "word": "Mali",
    "category": "geography_places",
    "subcategory": "West Africa",
    "difficulty": "hard",
    "description": "A landlocked West African state with historic desert cities and river trade routes.",
    "tags": ["west", "african", "landlocked"],
    "hints": {
        "easy": ["West Africa", "Landlocked state", "Great river", "Timbuktu", "Bamako", "Sahel region"],
        "medium": ["Ancient manuscripts", "Gold mining", "Salt trade", "Djenné mosque", "Saharan edge", "Musical heritage"],
        "hard": ["Manuscript libraries", "Mud architecture", "Trans-Saharan", "Griot tradition", "Cotton economy", "Islamic scholars"]
    },
    "imposters": {
        "easy": ["Senegal", "Burkina Faso"],
        "medium": ["Chad", "Mauritania"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# Write records
output_path = "tool/words/src/countries/gen007.json"
with open(output_path, "w", encoding="utf8") as f:
    json.dump(records, f, indent=1, ensure_ascii=False)

print(f"Wrote {len(records)} records to {output_path}")

# Validate
errors = 0
for i, r in enumerate(records):
    errs, warns = validate_record(r, cats, lists)
    if errs:
        print(f"Record {i} ({r['word']}): ERRORS:")
        for e in errs:
            print(f"  - {e}")
        errors += 1
    else:
        print(f"Record {i} ({r['word']}): OK" + (f", warnings: {warns}" if warns else ""))

if errors == 0:
    print(f"\nAll {len(records)} records passed validation!")
else:
    print(f"\n{errors} records had errors. Fix before importing.")