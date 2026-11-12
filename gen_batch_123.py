import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Burrow",
    "category": "nature_environment",
    "subcategory": "Animal Homes",
    "difficulty": "easy",
    "description": "A tunnel or excavation made by a small animal underground for protection.",
    "tags": ["animal", "home", "underground"],
    "hints": {
      "easy": ["Underground space", "Dug out area", "Animal hideaway", "Tunnel system", "Secret passage", "Rabbit hole"],
      "medium": ["Excavated chamber", "Subterranean room", "Digging animal", "Safe place below", "Earthen structure", "Buried chamber"],
      "hard": ["Excavation system", "Habitat subsoil", "Soil dwelling", "Underground dwellers", "Earth chamber", "Subsurface habitat"]
    },
    "imposters": {
      "easy": ["Nest", "Hive"],
      "medium": ["Lair", "Mound"],
      "hard": ["Shelter", "Cave"]
    }
  },
  {
    "word": "Den",
    "category": "nature_environment",
    "subcategory": "Animal Homes",
    "difficulty": "easy",
    "description": "A shelter or hiding place used by wild animals such as lions and bears.",
    "tags": ["animal", "shelter", "wild"],
    "hints": {
      "easy": ["Wild home", "Lion sleep", "Bear rest", "Hideout place", "Forest area", "Night spot"],
      "medium": ["Mountain top", "Rocky opening", "Night hunter base", "Woodland area", "Feline place", "Stone home"],
      "hard": ["Natural stronghold", "Territory spot", "Wildlife place", "Animal resting", "Stony spot", "Forest hideaway"]
    },
    "imposters": {
      "easy": ["Burrow", "Nest"],
      "medium": ["Lair", "Covert"],
      "hard": ["Retreat", "Hole"]
    }
  }
]

any_err = False
for r in recs:
    errs, warns = W.validate_record(r, cats, lists)
    if errs:
        print('FAIL:', r['word'], 'errs:', errs)
        any_err = True
    elif warns:
        print('WARN:', r['word'], 'warns:', warns)

if not any_err:
    print('ALL PASSED!')
    out_dir = r'C:\Users\badam\Desktop\hush\tool\words\replies\done'
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, '123_nature.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')
