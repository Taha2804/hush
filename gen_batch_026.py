import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Completely separate vocabulary - no token sharing
recs = [
  {
    "word": "Dryad",
    "category": "mythology_fiction",
    "subcategory": "Nature",
    "difficulty": "medium",
    "description": "A tree spirit from ancient myth who watches the forest.",
    "tags": ["myth", "nature", "spirit"],
    "hints": {
      "easy": ["Green forest", "Bark cover", "Woodland walk", "Leaf pile", "Nature trail", "Canopy sky"],
      "medium": ["Root system", "Branch reach", "Moss bed", "Leaf crunch", "Forest hush", "Woodland path"],
      "hard": ["Old growth", "Ancient oak", "Season change", "Woodland deep", "Forest core", "Nature's heart"]
    },
    "imposters": {
      "easy": ["Pixie", "Wisp"],
      "medium": ["Fae", "Nymph"],
      "hard": ["Oread", "Aurore"]
    }
  },
  {
    "word": "Selkie",
    "category": "mythology_fiction",
    "subcategory": "Seal",
    "difficulty": "medium",
    "description": "A seal-folk from Celtic lore who sheds its skin to become human.",
    "tags": ["myth", "celtic", "seal"],
    "hints": {
      "easy": ["Ocean waves", "Coastal sand", "Rocky shore", "Morning mist", "Sea foam", "Tide pool"],
      "medium": ["Seal colony", "Puppy play", "Beach stroll", "Coastal walk", "Ocean spray", "Morning dew"],
      "hard": ["Wildlife tour", "Marine tour", "Seal watching", "Coastal tour", "Ocean tour", "Sea tour"]
    },
    "imposters": {
      "easy": ["Mermaid", "Siren"],
      "medium": ["Kelpie", "Nixie"],
      "hard": ["Finfolk", "Bluecap"]
    }
  },
  {
    "word": "Kelpie",
    "category": "mythology_fiction",
    "subcategory": "Water",
    "difficulty": "medium",
    "description": "A shape-shifting water horse from Scottish folklore.",
    "tags": ["myth", "scottish", "water"],
    "hints": {
      "easy": ["River bend", "Loch side", "Misty dawn", "Water flow", "Stone bridge", "Cottage lane"],
      "medium": ["Highland loch", "Mountain stream", "Ancient stone", "Rural path", "Country lane", "Old road"],
      "hard": ["Scottish folk", "Highland tale", "River legend", "Mountain legend", "Glen story", "Loch tale"]
    },
    "imposters": {
      "easy": ["Pegasus", "Hippocamp"],
      "medium": ["Selkie", "Nixie"],
      "hard": ["Each uisge", "Aughisky"]
    }
  },
  {
    "word": "Golem",
    "category": "mythology_fiction",
    "subcategory": "Clay",
    "difficulty": "medium",
    "description": "An animated figure from Jewish folklore made from clay or mud.",
    "tags": ["myth", "jewish", "clay"],
    "hints": {
      "easy": ["Clay pot", "Mud brick", "Stone wall", "Ancient text", "Synagogue wall", "Prayer scroll"],
      "medium": ["Torah study", "Synagogue go", "Sabbath rest", "Jewish life", "Hebrew words", "Prayer book"],
      "hard": ["Prague ghetto", "Jewish history", "Eastern Europe", "Ancient city", "Jewish people", "Old city"]
    },
    "imposters": {
      "easy": ["Gargoyle", "Robot"],
      "medium": ["Titan", "Homunculus"],
      "hard": ["Automaton", "Construct"]
    }
  },
  {
    "word": "Genie",
    "category": "mythology_fiction",
    "subcategory": "Lamp",
    "difficulty": "easy",
    "description": "A supernatural being from Middle Eastern tales who grants wishes.",
    "tags": ["myth", "arabian", "magic"],
    "hints": {
      "easy": ["Desert tent", "Oasis water", "Caravan stop", "Market square", "Sand dune", "Canyon walls"],
      "medium": ["Arabian nights", "Bedouin tale", "Market day", "Canyon road", "Oasis town", "Sand sail"],
      "hard": ["Middle east", "Desert life", "Nomadic folk", "Trade route", "Oasis life", "Market folk"]
    },
    "imposters": {
      "easy": ["Djinn", "Fairy"],
      "medium": ["Wizard", "Sorcerer"],
      "hard": ["Ifrit", "Marid"]
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
    out_path = os.path.join(out_dir, '026_mythical.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')