import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Doorbell camera",
    "category": "science_technology",
    "subcategory": "Home Security",
    "difficulty": "easy",
    "description": "A front entrance device combining a visitor button and video lens to see callers via smartphone.",
    "tags": ["technology", "security", "home"],
    "hints": {
      "easy": ["Porch visitor view", "Rings your phone", "Entryway viewer", "Package watch", "Visitor alert", "Smart button"],
      "medium": ["Two way audio", "Porch lens unit", "Motion alert porch", "Visitor detection", "Doorway feed", "Smart chime"],
      "hard": ["Corner mount wedge", "Cloud video storage", "PIR motion detection", "Transformer unit", "Chime connector", "Field of view angle"]
    },
    "imposters": {
      "easy": ["Security camera", "Intercom"],
      "medium": ["Peephole", "Webcam"],
      "hard": ["Keypad", "Handset"]
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
    out_path = os.path.join(out_dir, '026_doorbell_camera.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')