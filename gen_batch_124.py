import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Tow truck",
    "category": "vehicles_transport",
    "subcategory": "Emergency",
    "difficulty": "medium",
    "description": "A large vehicle equipped to lift and transport broken down cars to repair facilities.",
    "tags": ["truck", "repair", "service"],
    "hints": {
      "easy": ["Car recovery", "Flatbed loader", "Accident helper", "Roadside aid", "Heavy duty", "Winch vehicle"],
      "medium": ["Boom arm", "Hook pull", "Mechanic friend", "Broken car", "Service vehicle", "Wheel lift"],
      "hard": ["Crane vehicle", "Hydraulic lift", "Recovery operation", "Auto transport", "Roadside help", "Heavy rescue"]
    },
    "imposters": {
      "easy": ["Ambulance", "Fire truck"],
      "medium": ["Lorry", "Wrecker"],
      "hard": ["Forklift", "Picker"]
    }
  },
  {
    "word": "Garbage truck",
    "category": "vehicles_transport",
    "subcategory": "City Services",
    "difficulty": "easy",
    "description": "A large vehicle that collects and transports waste from homes and businesses to disposal facilities.",
    "tags": ["waste", "city", "service"],
    "hints": {
      "easy": ["Trash collection", "City service", "Cans pickup", "Street cleaner", "Waste haul", "Roll-on"],
      "medium": ["Compaction bin", "Landfill route", "Municipal vehicle", "Dumpster emptying", "Trash day", "Bin lift"],
      "hard": ["Refuse carrier", "Landfill transport", "Waste management", "Compaction cycle", "Collection route", "Bin service"]
    },
    "imposters": {
      "easy": ["Recycling van", "Mail truck"],
      "medium": ["Dump truck", "Sweeper"],
      "hard": ["Compactor", "Hauler"]
    }
  },
  {
    "word": "Dump truck",
    "category": "vehicles_transport",
    "subcategory": "Construction",
    "difficulty": "medium",
    "description": "A truck with a large open bed that tilts to unload materials like sand, gravel or debris.",
    "tags": ["truck", "construction", "materials"],
    "hints": {
      "easy": ["Load emptier", "Building vehicle", "Gravel hauler", "Sand mover", "Debris carrier", "Bed lift"],
      "medium": ["Tilting bed", "Hydraulic lift", "Building supply", "Earth mover", "Scoop loader", "Bulk load"],
      "hard": ["Load capacity", "Tip operation", "Scoop material", "Building site", "Gravel transport", "Bed mechanism"]
    },
    "imposters": {
      "easy": ["Bulldozer", "Crane"],
      "medium": ["Lorry", "Tractor"],
      "hard": ["Mixer truck", "Excavator"]
    }
  },
  {
    "word": "Cement mixer",
    "category": "vehicles_transport",
    "subcategory": "Construction",
    "difficulty": "medium",
    "description": "A truck carrying a rotating drum to keep cement in liquid form during transport to building sites.",
    "tags": ["cement", "building", "mixing"],
    "hints": {
      "easy": ["Building hauler", "Rotating drum", "Building supply", "Slurry transport", "Construction truck", "Wet mix"],
      "medium": ["Drum rotation", "Ready mix", "Pour site", "Batching plant", "Delivery truck", "Mixing truck"],
      "hard": ["Aggregate mixing", "Slump test", "Set time", "Fuel tank", "Load rotation", "Mixing cycle"]
    },
    "imposters": {
      "easy": ["Van", "Pickup"],
      "medium": ["Bulldozer", "Tanker"],
      "hard": ["Pump equipment", "Skid steer"]
    }
  },
  {
    "word": "Steamroller",
    "category": "vehicles_transport",
    "subcategory": "Construction",
    "difficulty": "medium",
    "description": "A heavy wheeled vehicle used to smooth and level surfaces like streets and pavements during construction.",
    "tags": ["road", "construction", "smoothing"],
    "hints": {
      "easy": ["Surface press", "Pavement press", "Heavy wheel", "Flatten machine", "Flat operator", "Flattened ground"],
      "medium": ["Cast iron drum", "Compaction wheel", "Street flatter", "Helper machine", "Surface finish", "Rolling drum"],
      "hard": ["Single drum", "Static wheel", "Pneumatic tire", "Finish surface", "Compaction effort", "Smooth operator"]
    },
    "imposters": {
      "easy": ["Bulldozer", "Grader"],
      "medium": ["Tractor", "Scraper"],
      "hard": ["Compactor", "Asphalt paver"]
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
    out_path = os.path.join(out_dir, '124_transport.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')
