#!/usr/bin/env python3
"""Generate v2 records for 005 cities batch (Santiago, Bogota, Philadelphia, Orlando, New Orleans)."""

import json
import sys
sys.path.insert(0, ".")

from tool.words.wordlib import load_categories, Lists, validate_record

lists = Lists()
cats_list = load_categories()
cats = {c['id']: c for c in cats_list}

records = []

# 1. Santiago - Fix: duplicate imposter "Lima" in easy and hard
records.append({
    "word": "Santiago",
    "category": "geography_places",
    "subcategory": "South America",
    "difficulty": "hard",
    "description": "Chile's capital city nestled in a valley surrounded by the Andes mountains.",
    "tags": ["chile", "capital", "andes"],
    "hints": {
        "easy": ["Chile capital", "Andes valley", "South America", "Metro system", "Cerro San Cristobal", "Plaza de Armas"],
        "medium": ["Mountain basin", "Vineyard area", "Bellavista neighborhood", "Andean backdrop", "Presidential palace", "Mapocho river"],
        "hard": ["Central valley", "Cordillera peaks", "Economic hub", "Cultural center", "Seismic zone", "Mountain setting"]
    },
    "imposters": {
        "easy": ["Lima", "Buenos Aires"],
        "medium": ["Bogota", "Quito"],
        "hard": ["Tokyo", "Madrid", "Caracas", "La Paz"]
    }
})

# 2. Bogota - Fix: imposter leaks through hints
records.append({
    "word": "Bogota",
    "category": "geography_places",
    "subcategory": "South America",
    "difficulty": "hard",
    "description": "Colombia's high-altitude capital on the Andean plateau with historic colonial districts.",
    "tags": ["colombia", "capital", "andes"],
    "hints": {
        "easy": ["Colombia capital", "Andean plateau", "High altitude", "Candelaria district", "Gold museum", "Monserrate"],
        "medium": ["Highland savanna", "Coffee culture", "Ciclovia Sundays", "Salt cathedral", "Cool climate", "Urban center"],
        "hard": ["Savanna plateau", "Historic center", "Coffee region", "Cultural capital", "Mountain metropolis", "Altitude city"]
    },
    "imposters": {
        "easy": ["Medellin", "Quito"],
        "medium": ["Caracas", "La Paz"],
        "hard": ["Tokyo", "Quito", "Madrid", "Lima"]
    }
})

# 3. Philadelphia - OK
records.append({
    "word": "Philadelphia",
    "category": "geography_places",
    "subcategory": "United States",
    "difficulty": "easy",
    "description": "A historic Pennsylvania city famed for its role in American independence.",
    "tags": ["pennsylvania", "history", "united-states"],
    "hints": {
        "easy": ["Liberty Bell", "Independence Hall", "Philly cheesesteak", "Rocky steps", "Brotherly love", "Founding city"],
        "medium": ["Founding fathers", "Colonial history", "Art museum steps", "Reading terminal", "Sports fans", "Constitution site"],
        "hard": ["Historic district", "Revolutionary war", "First capital", "Medical center", "University town", "Cultural hub"]
    },
    "imposters": {
        "easy": ["Boston", "New York"],
        "medium": ["Washington", "Baltimore"],
        "hard": ["Chicago", "Pittsburgh", "Richmond", "Hartford"]
    }
})

# 4. Orlando - Fix: description repeats hints
records.append({
    "word": "Orlando",
    "category": "geography_places",
    "subcategory": "United States",
    "difficulty": "easy",
    "description": "A central Florida city renowned for massive theme parks and entertainment complexes.",
    "tags": ["florida", "theme-parks", "united-states"],
    "hints": {
        "easy": ["Florida city", "Theme parks", "Magic kingdom", "Universal resort", "Sunshine state", "Tourist hub"],
        "medium": ["Theme park capital", "Entertainment complex", "International drive", "Convention center", "Resort corridor", "Family vacation"],
        "hard": ["Entertainment hub", "Central Florida", "Lake district", "Tourism economy", "Sunbelt city", "Theme destination"]
    },
    "imposters": {
        "easy": ["Miami", "Tampa"],
        "medium": ["Anaheim", "Fort Lauderdale"],
        "hard": ["Las Vegas", "San Diego", "Phoenix", "Atlanta"]
    }
})

# 5. New Orleans - OK with warnings
records.append({
    "word": "New Orleans",
    "category": "geography_places",
    "subcategory": "United States",
    "difficulty": "easy",
    "description": "A Louisiana city on the Mississippi River celebrated for jazz and carnival traditions.",
    "tags": ["louisiana", "jazz", "united-states"],
    "hints": {
        "easy": ["Louisiana city", "Jazz music", "Mardi Gras", "French Quarter", "Mississippi River", "Creole cuisine"],
        "medium": ["Bourbon Street", "Streetcars", "Voodoo culture", "Cajun food", "Above ground tombs", "Festival city"],
        "hard": ["Birthplace of jazz", "Delta region", "Historic port", "Cultural melting", "Hurricane zone", "Musical heritage"]
    },
    "imposters": {
        "easy": ["Memphis", "Houston"],
        "medium": ["Mobile", "Biloxi"],
        "hard": ["Atlanta", "Savannah", "Charleston", "Nashville"]
    }
})

# Write records
output_path = "tool/words/src/cities/gen001.json"
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