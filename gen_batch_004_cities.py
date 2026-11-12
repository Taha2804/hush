#!/usr/bin/env python3
"""Generate v2 records for 004 cities batch (Macau, Auckland, Honolulu, Havana, Cancun)."""

import json
import sys
sys.path.insert(0, ".")

from tool.words.wordlib import load_categories, Lists, validate_record

lists = Lists()
cats_list = load_categories()
cats = {c['id']: c for c in cats_list}

records = []

# 1. Macau - Fix: "Macau tourism" contains-word
records.append({
    "word": "Macau",
    "category": "geography_places",
    "subcategory": "Macau",
    "difficulty": "hard",
    "description": "A Special Administrative Region of China with famous casinos and Portuguese heritage.",
    "tags": ["china", "administrative", "region"],
    "hints": {
        "easy": ["Portuguese colony", "Casino hub", "Southeast Asia", "Special region", "Dong", "Historic center"],
        "medium": ["Gambling capital", "Lisbon influence", "Rua do Cunha", "Ruins of St. Paul", "Cultural blend", "Grand Lisboa"],
        "hard": ["Oliveira casino", "Historic peninsula", "Fusion culture", "Economic zone", "Cultural heritage", "Gaming district"]
    },
    "imposters": {
        "easy": ["Hong Kong", "Singapore"],
        "medium": ["Wellington", "Sydney"],
        "hard": ["Tokyo", "Seoul", "Manila", "Bangkok"]
    }
})

# 2. Auckland - OK with warning
records.append({
    "word": "Auckland",
    "category": "geography_places",
    "subcategory": "Auckland",
    "difficulty": "hard",
    "description": "New Zealand's largest metropolis on the North Island with active volcanoes.",
    "tags": ["new", "zealand", "volcanic"],
    "hints": {
        "easy": ["North Island city", "Volcanic plain", "Harbour city", "Sky Tower", "Polynesian", "Gateway to NZ"],
        "medium": ["Volcanic field", "Hauraki Gulf", "Bridge to north", "Maori settlement", "Urban center", "Island nation"],
        "hard": ["Volcanic cones", "Harbor suburbs", "Bridge to Waiheke", "Cultural melting", "Economic hub", "Natural harbour"]
    },
    "imposters": {
        "easy": ["Christchurch", "Wellington"],
        "medium": ["Melbourne", "Sydney"],
        "hard": ["Tokyo", "Osaka", "Hilo", "San Francisco"]
    }
})

# 3. Honolulu - Fix: remove "Hawaiian capital" (loose-synonym)
records.append({
    "word": "Honolulu",
    "category": "geography_places",
    "subcategory": "Honolulu",
    "difficulty": "hard",
    "description": "The capital city of Hawaii on Oahu Island with a famous harbor.",
    "tags": ["hawaii", "capital", "harbor"],
    "hints": {
        "easy": ["Hawaii capital", "Pacific city", "Diamond Head", "Harbor inlet", "Tropical city", "Ala Moana"],
        "medium": ["Waikiki beach", "Pacific port", "Sunset beach", "Hawaiian culture", "Pearl Harbor", "Island paradise"],
        "hard": ["Diamond head crater", "Surf culture", "Harbor entrance", "Cultural blend", "Island capital", "Warm breeze"]
    },
    "imposters": {
        "easy": ["Miami", "Sydney"],
        "medium": ["Fiji", "Singapore"],
        "hard": ["Tokyo", "Hilo", "Nassau", "San Juan"]
    }
})

# 4. Havana - Fix duplicates and Old Havana contains-word
records.append({
    "word": "Havana",
    "category": "geography_places",
    "subcategory": "Havana",
    "difficulty": "hard",
    "description": "Cuba's capital city with colonial architecture and historic harbor.",
    "tags": ["cuba", "capital", "colonial"],
    "hints": {
        "easy": ["Cuba capital", "Caribbean city", "Colonial architecture", "Harbor inlet", "Malecón", "Spanish style"],
        "medium": ["Historic district", "Harbor district", "Cultural heritage", "Piano city", "Tropical port", "Café culture"],
        "hard": ["Historic peninsula", "Pastel colors", "Music heritage", "Sunset views", "Historic port", "Cultural icon"]
    },
    "imposters": {
        "easy": ["Miami", "San Juan"],
        "medium": ["Cartagena", "La Paz"],
        "hard": ["Tokyo", "Hilo", "Nassau", "Kingston"]
    }
})

# 5. Cancun - Fix: description repeats hints, remove those hints
records.append({
    "word": "Cancun",
    "category": "geography_places",
    "subcategory": "Cancun",
    "difficulty": "hard",
    "description": "A glamorous resort destination on Mexico's Caribbean coast with diverse attractions.",
    "tags": ["mexico", "resort", "caribbean"],
    "hints": {
        "easy": ["Mexican getaway", "Caribbean coast", "Hotel zone", "Tourist haven", "Sunny beaches", "Ocean view"],
        "medium": ["Underwater museum", "Snorkel heaven", "Mayan ruins", "Coral reef", "All-inclusive", "Beach life"],
        "hard": ["Art underwater", "Marine life", "Ancient structures", "Clear water", "Fun destination", "Coastal spot"]
    },
    "imposters": {
        "easy": ["Tulum", "Miami"],
        "medium": ["Cuba", "Belize"],
        "hard": ["Hilo", "Nassau", "San Juan", "Kingston"]
    }
})

# Write records
output_path = "tool/words/src/countries/gen004.json"
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