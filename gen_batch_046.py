import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Toolbox",
    "category": "everyday_objects",
    "subcategory": "Storage",
    "difficulty": "easy",
    "description": "A rectangular container with compartments for holding and organizing tools.",
    "tags": ["tool", "storage", "organization"],
    "hints": {
      "easy": ["Metal box", "Tools inside", "Compartments", "Workshop", "Screwdriver", "Fix-it"],
      "medium": ["Socket set", "Spanner collection", "Hammer storage", "Bench organizer", "Drawer insert", "Tool roll"],
      "hard": ["Metal lattice", "Stackable units", "Mobile base", "Custom foam", "Label system", "Quick access"]
    },
    "imposters": {
      "easy": ["Drawer", "Suitcase", "Bucket"],
      "medium": ["Tool bag", "Gear case"],
      "hard": ["Tool bag", "Portable workbench"]
    }
  },
  {
    "word": "Flashlight",
    "category": "everyday_objects",
    "subcategory": "Lighting",
    "difficulty": "easy",
    "description": "A portable hand-held electric device that produces light from a bulb or LED.",
    "tags": ["light", "portable", "electric"],
    "hints": {
      "easy": ["Battery powered", "Hand-held", "On-off switch", "Bulb or LED", "Beam of light", "Darkness"],
      "medium": ["Incandescent lamp", "LED technology", "Tactical beam", "Focus adjustable", "Switch mechanism", "Energy cell"],
      "hard": ["Photonic emitter", "Semiconductor diode", "Reflector dish", "Lens optic", "Circuit driver", "Thermal management"]
    },
    "imposters": {
      "easy": ["Lantern", "Candle"],
      "medium": ["Torch", "Electric lamp"],
      "hard": ["Strobe light", "Halogen lamp"]
    }
  },
  {
    "word": "Extension cord",
    "category": "everyday_objects",
    "subcategory": "Electrical",
    "difficulty": "medium",
    "description": "A flexible cable with plugs at both ends used to extend the reach of an electrical outlet.",
    "tags": ["cable", "electrical", "power"],
    "hints": {
      "easy": ["Plug-in cable", "Wall socket", "Reaches farther", "Two ends", "Flexible wire", "Electrical device"],
      "medium": ["Three-prong plug", "Ground wire", "Insulated jacket", "Reel mechanism", "Cable length", "Power strip"],
      "hard": ["Copper conductor", "Wire gauge", "PVC insulation", "Grounding conductor", "Connector housing", "Dielectric strength"]
    },
    "imposters": {
      "easy": ["Charger", "Plug"],
      "medium": ["Power strip", "Surge protector"],
      "hard": ["Extension reel", "Retractable cord"]
    }
  },
  {
    "word": "Doorbell",
    "category": "everyday_objects",
    "subcategory": "Security",
    "difficulty": "easy",
    "description": "A signalling device at a house entrance that announces visitors by sound or light.",
    "tags": ["house", "entry", "alert"],
    "hints": {
      "easy": ["House entrance", "Ring button", "Chime sound", "Visitor announce", "Front door", "Wall mounted"],
      "medium": ["Electric circuit", "Wiring connection", "Transformer unit", "Chime mechanism", "Battery powered", "Wireless system"],
      "hard": ["AC to DC converter", "Electromagnetic relay", "Audio frequency generator", "Piezoelectric buzzer", "Solid state circuit", "Network enabled"]
    },
    "imposters": {
      "easy": ["Knocker", "Alarm"],
      "medium": ["Intercom", "Video door"],
      "hard": ["Motion sensor", "Smart lock"]
    }
  },
  {
    "word": "Lock",
    "category": "everyday_objects",
    "subcategory": "Security",
    "difficulty": "easy",
    "description": "A device that fastens objects together by sliding a bolt or turning a key to prevent unauthorized access.",
    "tags": ["security", "fasten", "device"],
    "hints": {
      "easy": ["Key required", "Fastens door", "Security device", "Bolt or latch", "Turn clockwise", "Latch mechanism"],
      "medium": ["Deadbolt", "Padlock", "Combination", "Keyway", "Tumbler pins", "Cylinder lock"],
      "hard": ["Pin tumbler", "Wafer lock", "Disc detainer", "Magnet lock", "Keypad entry", "Biometric scanner"]
    },
    "imposters": {
      "easy": ["Chain", "Latch"],
      "medium": ["Bolt", "Hasp"],
      "hard": ["Deadbolt", "Keyless entry"]
    }
  },
  {
    "word": "Key",
    "category": "everyday_objects",
    "subcategory": "Security",
    "difficulty": "easy",
    "description": "A specially shaped piece of metal used to operate a lock and gain access.",
    "tags": ["metal", "security", "access"],
    "hints": {
      "easy": ["Metal object", "Turns lock", "Opens door", "Bright and shiny", "Small and simple", "Access device"],
      "medium": ["Bitting cuts", "Keyway profile", "Tooth pattern", "Gouge marks", "Shoulder height", "Bow grip"],
      "hard": ["Pin depths", "Warding configuration", "Dimple key", "Laser cut", "Sidewinder", "Tubular key"]
    },
    "imposters": {
      "easy": ["Lock", "Card"],
      "medium": ["Code", "Combination"],
      "hard": ["Transponder", "Smart card"]
    }
  },
  {
    "word": "Umbrella",
    "category": "everyday_objects",
    "subcategory": "Protection",
    "difficulty": "easy",
    "description": "A folding canvas or plastic canopy on a metal pole used for protection against rain or sun.",
    "tags": ["rain", "protection", "accessory"],
    "hints": {
      "easy": ["Rain protection", "Folding canopy", "Metal pole", "Sun shade", "Rib spokes", "Carry handle"],
      "medium": ["Waterproof fabric", "Wind resistant", "Automatic open", "Cane handle", "Clear dome", "UV protection"],
      "hard": ["Canopy fabric", "Pole telescoping", "Rib bone structure", "Center shaft", "Ventilation vent", "Water repellent"]
    },
    "imposters": {
      "easy": ["Raincoat", "Parasol"],
      "medium": ["Sun hat", "Golf umbrella"],
      "hard": ["Walking stick", "Fishing pole"]
    }
  },
  {
    "word": "Coat hanger",
    "category": "everyday_objects",
    "subcategory": "Storage",
    "difficulty": "medium",
    "description": "A shaped wire or plastic device used to hang coats and clothing in a closet.",
    "tags": ["wire", "clothing", "closet"],
    "hints": {
      "easy": ["Wire shape", "Clothes hanger", "Shoulders fit", "Closet bar", "Wooden or plastic", "Hook top"],
      "medium": ["Wire triangle", "Spring tension", "Contoured shoulder", "Chrome finish", "Kidney shape", "Non-slip coating"],
      "hard": ["Wire gauge", "Spring steel", "Contour shoulder", "Lacquer finish", "Rotating hook", "Child size"]
    },
    "imposters": {
      "easy": ["Hook", "Rail"],
      "medium": ["Peg", "Shelf"],
      "hard": ["Trouser hanger", "Skirt hanger"]
    }
  },
  {
    "word": "Clothespin",
    "category": "everyday_objects",
    "subcategory": "Laundry",
    "difficulty": "medium",
    "description": "A spring-loaded clip used to fasten clothing to a clothesline for drying.",
    "tags": ["clothing", "laundry", "spring"],
    "hints": {
      "easy": ["Clothes line", "Spring clip", "Laundry duty", "Pinchy grip", "Wooden or plastic", "Fastens wet"],
      "medium": ["Two arms", "Spring tension", "Teeth grip", "Slotted end", "Riveted joint", "Coating texture"],
      "hard": ["Spring steel", "Joint mechanism", "Surface texture", "Grip pressure", "Coating material", "Load capacity"]
    },
    "imposters": {
      "easy": ["Hanger", "Paperclip"],
      "medium": ["Clothes peg", "Linen clip"],
      "hard": ["Spring tension", "Joint mechanism"]
    }
  },
  {
    "word": "Alarm clock",
    "category": "everyday_objects",
    "subcategory": "Timekeeping",
    "difficulty": "easy",
    "description": "A clock that produces a loud sound at a preset time to wake a sleeper.",
    "tags": ["clock", "alarm", "time"],
    "hints": {
      "easy": ["Wake up sound", "Preset time", "Sleeper rouse", "Buzzer or beep", "Digital display", "Morning routine"],
      "medium": ["Snooze button", "Gradual volume", "Radio function", "Battery powered", "Plug-in mains", "Sleep cycle"],
      "hard": ["Circadian rhythm", "Sleep stage detection", "Optimal wake time", "Light-based rouse", "Smart alarm", "Sleep tracking"]
    },
    "imposters": {
      "easy": ["Watch", "Phone"],
      "medium": ["Timer", "Snooze"],
      "hard": ["Sleep cycle", "Sunrise simulation"]
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
    out_path = os.path.join(out_dir, '046_household.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')