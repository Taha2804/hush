import json
import sys
sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Generate records for all remaining words across all batches
batch1 = [
    ("Security camera", "Security", "security, video, surveillance", ["Webcam", "Dashcam"], ["Alarm", "Recorder"], ["Flight drone", "Entry sensor"]),
    ("Doorbell camera", "Security", "security, home, video", ["Intercom", "Webcam"], ["Knocker", "Chime"], ["Smart lock", "Entry sensor"]),
    ("Gaming laptop", "Computers", "computer, gaming, laptop", ["Desktop", "Ultrabook"], ["Console", "Workstation"], ["Gaming PC", "Mainframe"]),
    ("Stylus", "Input", "input, drawing, tablet", ["Crayon", "Mouse"], ["Finger", "Trackpad"], ["Chalk", "Brush"]),
    ("Graphics tablet", "Input", "input, art, drawing", ["Sketchbook", "Scanner"], ["Mouse", "Trackpad"], ["Lightbox", "Touchscreen"]),
    ("Keycaps", "Hardware", "keyboard, hardware, keyboards", ["Typewriter", "Mouse"], ["Keys", "Springs"], ["Case housing", "Internal plate"]),
    ("Smart glasses", "Wearables", "wearable, glasses, augmented-reality", ["Smartwatch", "Headset"], ["Earbuds", "Earphone"], ["VR visor", "Contact lenses"]),
    ("Headset", "Audio", "audio, headphones, communication", ["Earbuds", "Speaker"], ["Radio", "Stethoscope"], ["Binoculars", "Microphone"]),
    ("Charging cable", "Accessories", "accessory, charging, cable", ["Power bank", "Splitter"], ["Socket", "Hose"], ["Docking base", "Station point"]),
    ("Adapter", "Accessories", "accessory, converter, hardware", ["Charger", "Cord"], ["Transformer", "Bridge"], ["Circuit breaker", "Voltage converter"]),
]

recs = []
for word, subcat, tagstr, imp_easy, imp_med, imp_hard in batch1:
    tags = [t.strip() for t in tagstr.split(',')]
    rec = {
        "word": word,
        "category": "science_technology",
        "subcategory": subcat,
        "difficulty": "easy",
        "description": f"A technology device used for {tags[0]}.",
        "tags": tags,
        "hints": {
            "easy": ["Home use", "Modern gadget", "Digital tool", "Electronic device", "Tech accessory", "Vision aid"],
            "medium": ["Connected feature", "Energy efficient", "Wireless capability", "User interface", "Design element", "Tech function"],
            "hard": ["Advanced tech", "Engineering specification", "Technical standard", "Innovation era", "Device component", "System integration"]
        },
        "imposters": {
            "easy": imp_easy,
            "medium": imp_med,
            "hard": imp_hard
        }
    }
    recs.append(rec)

# Validate
errs_all = []
for r in recs:
    errs, warns = W.validate_record(r, cats, lists)
    if errs:
        print('FAIL:', r['word'], 'errs:', errs[:2])
        errs_all.append((r['word'], errs))
    elif warns:
        print('WARN:', r['word'], 'warns:', warns)

print(f'Total: {len(recs)} records, {len(errs_all)} failed')
if errs_all:
    for w, e in errs_all[:5]:
        print(f'  {w}: {e[0]}')