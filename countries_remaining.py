import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Mauritius",
    "category": "geography_places",
    "subcategory": "Island",
    "difficulty": "medium",
    "description": "An island nation in the Indian Ocean known for beaches, lagoons, and diverse culture.",
    "tags": ["geography", "island", "ocean"],
    "hints": {
      "easy": ["Island country", "Indian Ocean", "Tropical island", "Beach destination", "Flag", "Port Louis"],
      "medium": ["Sugar cane", "Sugar mill", "Creole culture", "Botanical garden", "Seven colored earth", "Dodo bird"],
      "hard": ["Mrigesthan", "Vanilla", "Strelet", "Ebony", "Kestrel", "Cervic"]
    },
    "imposters": {
      "easy": ["Madagascar", "Sri Lanka"],
      "medium": ["Reunion", "Seychelles"],
      "hard": ["Comoros", "Maldives"]
    }
  },
  {
    "word": "Seychelles",
    "category": "geography_places",
    "subcategory": "Island",
    "difficulty": "medium",
    "description": "An archipelago of islands in the Indian Ocean famous for coral reefs and unique rock formations.",
    "tags": ["geography", "island", "ocean"],
    "hints": {
      "easy": ["Island nation", "Indian Ocean", "Coral islands", "Paradise", "Aldabra", "Granite"],
      "medium": ["Mahe island", "Vallée de Mai", "Coco de Mer", "Giant tortoise", "Creole", "Snorkeling"],
      "hard": ["White bird", "Prism scale", "Marine park", "Hamilton", "Coco", "Atoll"]
    },
    "imposters": {
      "easy": ["Mauritius", "Madagascar"],
      "medium": ["Comoros", "Maldives"],
      "hard": ["Mayotte", "Chagos"]
    }
  },
  {
    "word": "Mali",
    "category": "geography_places",
    "subcategory": "West Africa",
    "difficulty": "medium",
    "description": "A West African nation with a major waterway and vast desert regions.",
    "tags": ["geography", "africa", "west"],
    "hints": {
      "easy": ["National country", "River", "Sahara", "Capital", "Flag", "Bamako"],
      "medium": ["Niger River", "Timbuktu", "Gold mining", "Manding", "Sahel zone", "Desert city"],
      "hard": ["Sahel", "Fula people", "Cattle", "Cercle", "Koulikoro", "Loop"]
    },
    "imposters": {
      "easy": ["Nigeria", "Ghana"],
      "medium": ["Burkina Faso", "Senegal"],
      "hard": ["Mauritania", "Guinea"]
    }
  }
]

any_err = False
for r in recs:
    errs, warns = W.validate_record(r, cats, lists)
    if errs:
        print('FAIL:', r['word'], 'errs:', errs, 'warns:', warns)
        any_err = True
    elif warns:
        print('WARN:', r['word'], 'warns:', warns)

if not any_err:
    print('ALL PASSED!')
    out_dir = r'C:\Users\badam\Desktop\hush\tool\words\replies'
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, '031_countries.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')