import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Keyboard",
    "category": "science_technology",
    "subcategory": "Computing",
    "difficulty": "medium",
    "description": "A computer input device with keys for typing characters, numbers, and symbols into an electronic system.",
    "tags": ["technology", "input", "computing"],
    "hints": {
      "easy": ["Typing device", "QWERTY layout", "Keycaps", "Typing tool", "Computer accessory", "Character input"],
      "medium": ["Mechanical switch", "Ergonomic design", "Key travel", "Shortcut keys", "Backlit keys", "Key rollover"],
      "hard": ["Actuation point", "Cherry MX brown", "NKRO support", "Scissor switch", "Membrane mechanism", "Key roll"]
    },
    "imposters": {
      "easy": ["Mouse", "Keypad"],
      "medium": ["Trackpad", "Stylus"],
      "hard": ["Control panel", "Switch panel"]
    }
  },
  {
    "word": "Mouse",
    "category": "science_technology",
    "subcategory": "Computing",
    "difficulty": "medium",
    "description": "A handheld pointing device that controls cursor movement on a screen through optical or laser motion detection.",
    "tags": ["technology", "input", "computing"],
    "hints": {
      "easy": ["Point and click", "Left click", "Right click", "Cursor control", "Wireless", "Scroll wheel"],
      "medium": ["Optical sensor", "Laser tracking", "Ergonomic shape", "Wired connection", "DPI settings", "Button config"],
      "hard": ["Acceleration curve", "Palm grip style", "Surface tracking", "Sensor pixel count", "Click force", "Polling rate"]
    },
    "imposters": {
      "easy": ["Trackball", "Joystick"],
      "medium": ["Graphics tablet", "Stylus"],
      "hard": ["Touchscreen", "Touchpad"]
    }
  },
  {
    "word": "Television",
    "category": "science_technology",
    "subcategory": "Entertainment",
    "difficulty": "easy",
    "description": "An electronic display device for receiving and viewing broadcast, cable, or recorded moving images and visual content.",
    "tags": ["technology", "entertainment", "display"],
    "hints": {
      "easy": ["Screen", "Remote", "Channel", "Watching", "Sitcom", "News"],
      "medium": ["High definition", "Flat screen", "LCD panel", "HDMI input", "Cable box", "Satellite"],
      "hard": ["OLED technology", "Refresh rate", "HDR compatibility", "Smart platform", "Local dimming", "HDMI ports"]
    },
    "imposters": {
      "easy": ["Monitor", "Projector"],
      "medium": ["Screen", "Display panel"],
      "hard": ["Video wall", "Digital sign"]
    }
  },
  {
    "word": "Calculator",
    "category": "science_technology",
    "subcategory": "Electronics",
    "difficulty": "medium",
    "description": "An electronic device used to perform mathematical calculations and arithmetic operations including advanced functions.",
    "tags": ["technology", "electronics", "calculations"],
    "hints": {
      "easy": ["Keypad", "Equals button", "Addition", "Subtraction", "Memory", "Display"],
      "medium": ["Scientific mode", "Programmable", "Solar powered", "Unit conversion", "Trigonometric functions", "Statistical mode"],
      "hard": ["Reverse Polish notation", "Floating point", "Complex calculation", "Programmable steps", "Binary mode", "Hexadecimal"]
    },
    "imposters": {
      "easy": ["Abacus", "Phone"],
      "medium": ["Computer", "Spreadsheet"],
      "hard": ["Algorithm", "Function key"]
    }
  },
  {
    "word": "X-ray",
    "category": "science_technology",
    "subcategory": "Medical",
    "difficulty": "medium",
    "description": "High-energy electromagnetic radiation used to image internal body structures through skeletal penetration.",
    "tags": ["technology", "medical", "imaging"],
    "hints": {
      "easy": ["Medical scan", "Hospital", "Bone view", "Radiology", "Diagnostic imaging", "Invisible rays"],
      "medium": ["Roentgen radiation", "CT imaging", "Mammography test", "Lead protection", "Image receptor", "Contrast study"],
      "hard": ["Penetration depth", "Exposure setting", "Radiation dose", "Digital detector", "Grid filter", "Compression paddle"]
    },
    "imposters": {
      "easy": ["Ultrasound", "MRI"],
      "medium": ["CT scan", "PET scan"],
      "hard": ["Mammogram", "Bone test"]
    }
  },
  {
    "word": "Cookie",
    "category": "science_technology",
    "subcategory": "Internet",
    "difficulty": "easy",
    "description": "A small text file stored by websites on a user's computer to remember preferences and track web activity.",
    "tags": ["technology", "internet", "web"],
    "hints": {
      "easy": ["Browser file", "Website data", "Login helper", "Preferences saved", "Tracking file", "Web storage"],
      "medium": ["First party data", "Third party tracking", "Session data", "Persistent file", "HttpOnly flag", "Secure flag"],
      "hard": ["SameSite policy", "Fingerprinting method", "Cross-site tracking", "Privacy regulation", "Storage lifetime", "Domain restriction"]
    },
    "imposters": {
      "easy": ["Cache", "History"],
      "medium": ["Password", "Bookmark"],
      "hard": ["Tracker", "Malware"]
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
    out_path = os.path.join(out_dir, '027_technology.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')