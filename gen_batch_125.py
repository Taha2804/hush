import json
import sys
import os

sys.path.insert(0, r'C:/Users/badam/Desktop/hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Snowplow",
    "category": "vehicles_transport",
    "subcategory": "Winter",
    "difficulty": "medium",
    "description": "A vehicle with a large front blade that pushes snow off roads and paths.",
    "tags": ["snow", "winter", "road"],
    "hints": {
      "easy": ["Winter vehicle", "Clears streets", "Big blade", "Road clearing", "Ice scraping", "Morning work"],
      "medium": ["Blade angle", "Salt spreader", "Night shift", "Highway patrol", "Clear lanes", "Winter duty"],
      "hard": ["Hydraulic lift", "Carbide edge", "Push speed", "Route priority", "Scraper truck", "Blade wing"]
    },
    "imposters": {
      "easy": ["Bulldozer", "Tractor"],
      "medium": ["Snowmobile", "Sander"],
      "hard": ["Grader", "Loader"]
    }
  },
  {
    "word": "Snowmobile",
    "category": "vehicles_transport",
    "subcategory": "Winter",
    "difficulty": "medium",
    "description": "A motorized vehicle with tracks and skis for traveling over snow and ice.",
    "tags": ["snow", "winter", "recreation"],
    "hints": {
      "easy": ["Winter ride", "Tracked vehicle", "Front skis", "Trail riding", "Cold weather", "Two stroke"],
      "medium": ["Track drive", "Handlebar steer", "Engine rev", "Trail network", "Deep powder", "Ice lake"],
      "hard": ["Suspension travel", "Track lugs", "Carb heat", "Throttle control", "Powder ride", "Groomed trail"]
    },
    "imposters": {
      "easy": ["Sled", "ATV"],
      "medium": ["Quad bike", "Watercraft"],
      "hard": ["Snow tractor", "Dirt bike"]
    }
  },
  {
    "word": "Sled",
    "category": "vehicles_transport",
    "subcategory": "Winter",
    "difficulty": "easy",
    "description": "A flat-bottomed device for sliding downhill over snow or ice.",
    "tags": ["snow", "winter", "play"],
    "hints": {
      "easy": ["Downhill slide", "Hill ride", "Plastic sheet", "Winter fun", "Kid play", "Snow glide"],
      "medium": ["Runner blade", "Steering rope", "Curved shape", "Snow hill", "Fast descent", "Sliding fun"],
      "hard": ["Low friction", "Gravity propelled", "Winter sport", "Sliding vehicle", "Snow track", "Ice runner"]
    },
    "imposters": {
      "easy": ["Sleigh", "Skis"],
      "medium": ["Toboggan", "Luge"],
      "hard": ["Wooden board", "Winter gear"]
    }
  },
  {
    "word": "Sleigh",
    "category": "vehicles_transport",
    "subcategory": "Winter",
    "difficulty": "easy",
    "description": "A large open vehicle on runners pulled by horses or reindeer over snow.",
    "tags": ["snow", "horse", "traditional"],
    "hints": {
      "easy": ["Horse drawn", "Snow ride", "Bells jingle", "Winter transport", "Open carriage", "Reindeer pull"],
      "medium": ["Runner blades", "Curved front", "Blanket ride", "One horse open", "Snow glide", "Winter journey"],
      "hard": ["Dash through", "Jingle bells", "Ride through", "Winter travel", "Horse vehicle", "Snow vehicle"]
    },
    "imposters": {
      "easy": ["Sled", "Cart"],
      "medium": ["Wagon", "Buggy"],
      "hard": ["Coach", "Phaeton"]
    }
  },
  {
    "word": "Carriage",
    "category": "vehicles_transport",
    "subcategory": "Historical",
    "difficulty": "medium",
    "description": "A four-wheeled horse-drawn vehicle for carrying passengers.",
    "tags": ["horse", "historical", "transport"],
    "hints": {
      "easy": ["Horse drawn", "Passenger ride", "Four wheels", "Old transport", "Driver seat", "Door entry"],
      "medium": ["Sprung wheels", "Royal coach", "Private hire", "Street cab", "Wheel seat", "Whip crack"],
      "hard": ["Suspending springs", "Coach built", "Horse pair", "Town coach", "Travel vehicle", "Trade vehicle"]
    },
    "imposters": {
      "easy": ["Wagon", "Cart"],
      "medium": ["Sleigh", "Buggy"],
      "hard": ["Coach", "Phaeton"]
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
    out_dir = r'C:/Users/badam/Desktop/hush\tool\words\replies\done'
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, '125_transport.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')
