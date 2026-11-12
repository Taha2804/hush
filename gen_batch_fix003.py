import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Kuwait",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "easy",
    "description": "A small oil-rich emirate on the Arabian Gulf with modern cities and wealthy finance sector.",
    "tags": ["middle-east", "gulf", "oil"],
    "hints": {
      "easy": ["Arabian Gulf", "Oil exports", "Modern cities", "Wealthy finance", "Desert nation", "Sheikh ruler"],
      "medium": ["Kuwait Towers", "Sovereign wealth", "OPEC founding", "Desert climate", "Pearl history", "Cultural heritage"],
      "hard": ["Al-Sabah dynasty", "Bubiyan island", "Failaka island", "Kuwaiti dinar", "Coastal capital", "Oil exports"]
    },
    "imposters": {
      "easy": ["Qatar", "Bahrain"],
      "medium": ["UAE", "Saudi Arabia"],
      "hard": ["Oman", "Iraq"]
    }
  },
  {
    "word": "Tunisia",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A North African nation with Mediterranean coastline and ancient Carthage heritage.",
    "tags": ["north-africa", "mediterranean", "historical"],
    "hints": {
      "easy": ["North Africa", "Mediterranean sea", "Carthage ruins", "Tunis capital", "Jasmine flower", "Sahara desert"],
      "medium": ["Arab Spring", "Sidi Bouzid", "Olive groves", "Roman columns", "Bardo museum", "Coastal resorts"],
      "hard": ["Carthage empire", "El Djem amphitheatre", "Kairouan mosque", "Chott el Jerid", "Ichkeul park", "Hammamet tourism"]
    },
    "imposters": {
      "easy": ["Algeria", "Libya"],
      "medium": ["Morocco", "Egypt"],
      "hard": ["Malta", "Sicily"]
    }
  },
  {
    "word": "Rwanda",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "An East African nation known for its hills, mountain gorillas and recent development.",
    "tags": ["east-africa", "hills", "development"],
    "hints": {
      "easy": ["East Africa", "Thousand hills", "Kigali capital", "Mountain gorillas", "Green landscape", "Development progress"],
      "medium": ["Volcanoes park", "Lake Kivu", "Nyungwe forest", "Kinyarwanda language", "Community work", "Cleanliness campaign"],
      "hard": ["Gorilla trekking", "Golden monkeys", "Dian Fossey", "Akagera park", "Hilly terrain", "African success"]
    },
    "imposters": {
      "easy": ["Burundi", "Uganda"],
      "medium": ["Tanzania", "Congo"],
      "hard": ["Kenya", "Ethiopia"]
    }
  },
  {
    "word": "Zimbabwe",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A southern African nation with Victoria Falls and ancient ruins, now stable and developing.",
    "tags": ["southern-africa", "falls", "developing"],
    "hints": {
      "easy": ["Southern Africa", "Victoria Falls", "Harare capital", "Wildlife parks", "Shona people", "Wildlife"],
      "medium": ["Mana Pools", "Hwange park", "Matobo hills", "Kariba lake", "Tobacco farming", "Growing economy"],
      "hard": ["Zambezi river", "Stone architecture", "Mosi-oa-Tunya", "Eastern highlands", "Baobab trees", "Independence 1980"]
    },
    "imposters": {
      "easy": ["Zambia", "Botswana"],
      "medium": ["Mozambique", "South Africa"],
      "hard": ["Namibia", "Malawi"]
    }
  },
  {
    "word": "Botswana",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A southern African country with the Okavango Delta, wildlife and stable democracy.",
    "tags": ["southern-africa", "delta", "democracy"],
    "hints": {
      "easy": ["Southern Africa", "Landlocked", "Gaborone capital", "Okavango Delta", "Wildlife safari", "Diamond mines"],
      "medium": ["Kalahari desert", "Chobe park", "Makgadikgadi pans", "Bushmen culture", "Cattle farming", "Pula currency"],
      "hard": ["Mokoro canoe", "Big five safari", "Tsodilo hills", "Moremi reserve", "Desert adaptation", "Conservation leader"]
    },
    "imposters": {
      "easy": ["Namibia", "Zambia"],
      "medium": ["Zimbabwe", "South Africa"],
      "hard": ["Angola", "Malawi"]
    }
  },
  {
    "word": "Namibia",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A southwestern African nation with Namib Desert and incredible wildlife parks.",
    "tags": ["southern-africa", "desert", "wildlife"],
    "hints": {
      "easy": ["Southwest Africa", "Namib Desert", "Windhoek city", "Skeleton Coast", "Wildlife park", "German history"],
      "medium": ["Sossusvlei dunes", "Fish River Canyon", "Swakopmund town", "Etosha park", "Himba people", "Diamond mining"],
      "hard": ["Welwitschia plant", "Namib-Naukluft park", "Spitzkoppe peaks", "Twyfelfontein rock", "Benguela current", "Independence 1990"]
    },
    "imposters": {
      "easy": ["Botswana", "Angola"],
      "medium": ["South Africa", "Zambia"],
      "hard": ["Botswana", "Zimbabwe"]
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
    out_path = os.path.join(out_dir, 'fix_003_countries.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')