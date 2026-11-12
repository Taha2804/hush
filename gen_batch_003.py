import json, sys, os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Sudan",
    "category": "geography_places",
    "subcategory": "North Africa",
    "difficulty": "easy",
    "description": "A northeast African nation with deserts, Nuba mountains and significant oil resources.",
    "tags": ["africa", "country", "desert"],
    "hints": {
      "easy": ["North Africa", "Desert land", "Khartoum city", "Blue Nile", "Nile river", "African nation"],
      "medium": ["Nubian region", "Gum arabic", "Oil fields", "Arab belt", "Red Sea coast", "Islamic culture"],
      "hard": ["Ancient Nubia", "Darfur conflict", "Twin capitals", "Nuba hills", "Pyramid site", "Sahel zone"]
    },
    "imposters": {
      "easy": ["Egypt", "Chad", "Ethiopia"],
      "medium": ["Libya", "Eritrea", "Somalia"],
      "hard": ["Omdurman", "Kassala", "Al Fasher"]
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
    out_path = os.path.join(out_dir, '003_countries.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')