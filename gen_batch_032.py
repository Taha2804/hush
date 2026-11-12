import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Muay thai",
    "category": "sports_games",
    "subcategory": "Martial Arts",
    "difficulty": "medium",
    "description": "A Thai combat sport known as 'the art of eight limbs' using punches, kicks, elbows and knees.",
    "tags": ["martial", "thai", "combat"],
    "hints": {
      "easy": ["Thailand", "Fight sport", "Eight limbs", "Kickboxing", "Self defence", "Ring"],
      "medium": ["Art of eight limbs", "Elbow strikes", "Knee strikes", "Traditional wai", "Camp Muay Thai", "Oleg tactics"],
      "hard": ["Ritual danse", "Pranken music", "Mongkol headgear", "Prajied rope", "Full contact", "Thai boxing"]
    },
    "imposters": {
      "easy": ["Kickboxing", "Boxing"],
      "medium": ["Karate", "Taekwondo"],
      "hard": ["Judo", "Aikido"]
    }
  },
  {
    "word": "Kung fu",
    "category": "sports_games",
    "subcategory": "Martial Arts",
    "difficulty": "medium",
    "description": "A Chinese martial art system featuring both striking and grappling techniques.",
    "tags": ["chinese", "martial", "arts"],
    "hints": {
      "easy": ["China", "Martial art", "Kung fu", "Kicks and punches", "Temple style", "Dragon form"],
      "medium": ["Shaolin temple", "Animal forms", "Northern style", "Southern style", "Weapons practice", "Forms catalogue"],
      "hard": ["Chi kung breathing", "Iron body", "Qi circulation", "Five animal styles", "Wu dachi stance", "Soft hard"]
    },
    "imposters": {
      "easy": ["Karate", "Taekwondo"],
      "medium": ["Judo", "Aikido"],
      "hard": ["Muay thai", "Kempo"]
    }
  },
  {
    "word": "Pilates",
    "category": "sports_games",
    "subcategory": "Exercise",
    "difficulty": "medium",
    "description": "A physical fitness system focusing on core strength, flexibility and controlled movement.",
    "tags": ["exercise", "fitness", "core"],
    "hints": {
      "easy": ["Core strength", "Flexibility", "Exercise system", "Joseph Pilates", "Mat work", "Controlled movement"],
      "medium": ["Contrology", "Spring reformer", "Cadillac machine", "Pilates ring", "Breathing technique", "Core activation"],
      "hard": ["Powerhouse muscles", "Spinal articulation", "Pelvic floor", "Scapular stability", "Deep fascia", "Neuromuscular"]
    },
    "imposters": {
      "easy": ["Yoga", "Aerobics"],
      "medium": ["Zumba", "Stretching"],
      "hard": ["Barre", "Crossfit"]
    }
  },
  {
    "word": "Aerobics",
    "category": "sports_games",
    "subcategory": "Exercise",
    "difficulty": "medium",
    "description": "A system of physical exercise that improves oxygen consumption and cardiovascular fitness.",
    "tags": ["exercise", "cardio", "fitness"],
    "hints": {
      "easy": ["Cardiovascular", "Oxygen", "Fitness routine", "Step aerobics", "Music beat", "Sweat session"],
      "medium": ["Jane Fonda", "Step class", "Low impact", "High impact", "Aerobic dance", "Heart rate zone"],
      "hard": ["Anaerobic threshold", "VO2 max", "Lactate threshold", "Target heart rate", "Interval training", "Cross training"]
    },
    "imposters": {
      "easy": ["Pilates", "Zumba"],
      "medium": ["Cycling", "Running"],
      "hard": ["Swimming", "Rowing"]
    }
  },
  {
    "word": "Zumba",
    "category": "sports_games",
    "subcategory": "Dance Fitness",
    "difficulty": "medium",
    "description": "A dance fitness program combining Latin and international music with choreographed moves.",
    "tags": ["dance", "fitness", "latin"],
    "hints": {
      "easy": ["Latin music", "Dance fitness", "Zumba", "Hip shaking", "Exercise party", "Cardio workout"],
      "medium": ["Salsa steps", "Merengue rhythm", "Reggaeton beat", "Dance workout", "Fitness class", "Latin beat"],
      "hard": ["Bacardi rum", "Hip Latin", "Rhythm coordination", "Choreography memory", "Energy expenditure", "Party atmosphere"]
    },
    "imposters": {
      "easy": ["Aerobics", "Salsa"],
      "medium": ["Hip hop", "Belly dance"],
      "hard": ["Bollywood dance", "Flamenco"]
    }
  },
  {
    "word": "Bodybuilding",
    "category": "sports_games",
    "subcategory": "Strength",
    "difficulty": "medium",
    "description": "The sport of developing muscle mass and symmetry through weight training and nutrition.",
    "tags": ["strength", "muscle", "body"],
    "hints": {
      "easy": ["Muscle mass", "Weight training", "Bodybuilding", "Gym workout", "Protein diet", "Arnold Schwarzenegger"],
      "medium": ["Resistance training", "Hypertrophy", "Supplement diet", "Competition stage", "Posing routine", "Mr Olympia"],
      "hard": ["Anabolic steroids", "Mass phase", "Cutting cycle", "Symmetry assessment", "Postural balance", "Genetic potential"]
    },
    "imposters": {
      "easy": ["Weightlifting", "Powerlifting"],
      "medium": ["Strongman", "Crossfit"],
      "hard": ["Olympic weightlifting", "Bodybuilding"]
    }
  },
  {
    "word": "Powerlifting",
    "category": "sports_games",
    "subcategory": "Strength",
    "difficulty": "medium",
    "description": "A strength sport focusing on three maximal weight lifts: squat, bench press and deadlift.",
    "tags": ["strength", "lifting", "competition"],
    "hints": {
      "easy": ["Three lifts", "Maximum weight", "Powerlifting", "Gym strength", "Squat rack", "Deadlift platform"],
      "medium": ["Squat bench dead", "One rep max", "Plate loading", "Training max", "Progressive overload", "Personal record"],
      "hard": ["One repetition", "Squat depth", "Bench press arch", "Deadlift grip", "Conventional style", "Sumo deadlift"]
    },
    "imposters": {
      "easy": ["Weightlifting", "Bodybuilding"],
      "medium": ["Strongman", "Crossfit"],
      "hard": ["Olympic weightlifting", "Bench press"]
    }
  },
  {
    "word": "Arm wrestling",
    "category": "sports_games",
    "subcategory": "Combat",
    "difficulty": "medium",
    "description": "A sport where two participants arm wrestle each other trying to pin the other's arm to a table.",
    "tags": ["combat", "arm", "sport"],
    "hints": {
      "easy": ["Arm wrestling", "Table sport", "Winner takes", "Arm strength", "Pin the arm", "Competition"],
      "medium": ["Humerus bone", "Epicondyle ridge", "Supination force", "Shoulder socket", "Humero-ulnar joint", "Arm wrestling"],
      "hard": ["Humeral rotation", "Eccentric contraction", "Biomechanics", "Leverage advantage", "Humeral shaft", "Arm wrestling technique"]
    },
    "imposters": {
      "easy": ["Judo", "Sumo"],
      "medium": ["Boxing", "Wrestling"],
      "hard": ["Muay thai", "Brazilian jiu-jitsu"]
    }
  },
  {
    "word": "Hopscotch",
    "category": "sports_games",
    "subcategory": "Children",
    "difficulty": "easy",
    "description": "A children's playground game where players toss a marker into numbered squares and hop through them.",
    "tags": ["children", "game", "outdoor"],
    "hints": {
      "easy": ["Children game", "Number squares", "Hop and jump", "Marker toss", "Concrete court", "Balance"],
      "medium": ["Marker stone", "Numbered grid", "Single foot hop", "Both feet jump", "Turn player", "Court lines"],
      "hard": ["Concrete surface", "Number sequence", "Balance coordination", "Motor skills", "Child development", "Playground design"]
    },
    "imposters": {
      "easy": ["Jump rope", "Tag"],
      "medium": ["Marbles", "Red light green light"],
      "hard": ["Four square", "Dodgeball"]
    }
  },
  {
    "word": "Dodgeball",
    "category": "sports_games",
    "subcategory": "Team",
    "difficulty": "medium",
    "description": "A team sport where players throw balls at opponents trying to hit them eliminate them from play.",
    "tags": ["team", "sport", "throw"],
    "hints": {
      "easy": ["Team sport", "Throw balls", "Hit opponents", "Eliminate players", "Dodge balls", "Court game"],
      "medium": ["Six balls", "Court boundary", "Head shot out", "Catch ball", "Team strategy", "Dodgeball"],
      "hard": ["Rubber ball", "Cloth ball", "High velocity", "Target elimination", "Court dimensions", "Official rules"]
    },
    "imposters": {
      "easy": ["Handball", "Tag"],
      "medium": ["Volleyball", "Ball tag"],
      "hard": ["Cluster ball", "Attack ball"]
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
    out_path = os.path.join(out_dir, '032_sports.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')