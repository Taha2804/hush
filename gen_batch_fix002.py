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
    "description": "A small oil-rich emirate on the Persian Gulf coast with a sovereign wealth fund.",
    "tags": ["middle-east", "gulf", "oil"],
    "hints": {
      "easy": ["Persian Gulf", "Oil wealth", "Kuwait City", "Emirate ruled", "Small nation", "Desert climate"],
      "medium": ["Kuwait Towers", "Sovereign fund", "OPEC member", "1990 invasion", "Pearl diving", "Constitutional emirate"],
      "hard": ["Al Sabah dynasty", "Bubiyan island", "Failaka island", "Kuwaiti dinar", "Coastal capital", "Oil exports"]
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
    "description": "A North African Mediterranean nation where the Arab Spring uprisings began in 2010.",
    "tags": ["north-africa", "mediterranean", "arab-spring"],
    "hints": {
      "easy": ["North Africa", "Mediterranean coast", "Tunis capital", "Arab Spring", "Ancient Carthage", "Sahara desert"],
      "medium": ["Sidi Bouzid", "Jasmine revolution", "Olive oil", "Roman ruins", "Bardo museum", "Coastal tourism"],
      "hard": ["Carthage ruins", "El Djem amphitheatre", "Kairouan mosque", "Chott el Jerid", "Ichkeul park", "Hammamet resort"]
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
    "description": "A small East African nation known as the land of a thousand hills with mountain gorillas.",
    "tags": ["east-africa", "hills", "gorillas"],
    "hints": {
      "easy": ["East Africa", "Thousand hills", "Kigali capital", "Mountain gorillas", "Genocide memorial", "Green landscape"],
      "medium": ["Volcanoes park", "Lake Kivu", "Nyungwe forest", "Kinyarwanda language", "Umuganda community", "Clean streets"],
      "hard": ["Gorilla trekking", "Golden monkeys", "Dian Fossey", "Akagera park", "Hilly terrain", "African leader"]
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
    "description": "A southern African nation with Victoria Falls and ancient stone ruins at Great Zimbabwe.",
    "tags": ["southern-africa", "falls", "ruins"],
    "hints": {
      "easy": ["Southern Africa", "Victoria Falls", "Harare capital", "Great Zimbabwe", "Wildlife parks", "Shona people"],
      "medium": ["Mana Pools", "Hwange park", "Matobo hills", "Kariba lake", "Tobacco farms", "Hyperinflation"],
      "hard": ["Zambezi river", "Stone architecture", "Mos-oa-Tunya", "Eastern highlands", "Baobab trees", "Independence 1980"]
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
    "description": "A landlocked southern African country with the Okavango Delta and stable democracy.",
    "tags": ["southern-africa", "delta", "democracy"],
    "hints": {
      "easy": ["Southern Africa", "Landlocked", "Gaborone capital", "Okavango Delta", "Diamond mines", "Stable government"],
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
    "description": "A southwestern African nation with the Namib Desert and German colonial architecture.",
    "tags": ["southern-africa", "desert", "german"],
    "hints": {
      "easy": ["Southwest Africa", "Namib Desert", "Windhoek capital", "Skeleton Coast", "Etosha park", "German buildings"],
      "medium": ["Sossusvlei dunes", "Fish River Canyon", "Swakopmund town", "Kolmanskop ghost", "Himba people", "Diamonds"],
      "hard": ["Welwitschia plant", "Namib-Naukluft", "Spitzkoppe peaks", "Twyfelfontein rock", "Benguela current", "Independence 1990"]
    },
    "imposters": {
      "easy": ["Botswana", "Angola"],
      "medium": ["South Africa", "Zambia"],
      "hard": ["Botswana", "Zimbabwe"]
    }
  },
  {
    "word": "Senegal",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A West African nation on the Atlantic coast with vibrant music and the island of Gorée.",
    "tags": ["west-africa", "atlantic", "music"],
    "hints": {
      "easy": ["West Africa", "Atlantic coast", "Dakar capital", "Gorée island", "Wolof language", "Teranga hospitality"],
      "medium": ["Lac Rose pink", "Saint-Louis colonial", "Mbalax music", "Baobab trees", "Fishing boats", "Peanut farming"],
      "hard": ["Gorée slave house", "Djoudj sanctuary", "Niokolo-Koba", "Lamine Diack", "Senegalese wrestling", "Independence 1960"]
    },
    "imposters": {
      "easy": ["Mali", "Guinea"],
      "medium": ["Mauritania", "Gambia"],
      "hard": ["Ivory Coast", "Guinea-Bissau"]
    }
  },
  {
    "word": "Cameroon",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A Central African nation with diverse landscapes from rainforest to savanna and Mount Cameroon volcano.",
    "tags": ["central-africa", "volcano", "bilingual"],
    "hints": {
      "easy": ["Central Africa", "Mount Cameroon", "Yaoundé capital", "Douala port", "French English", "Rainforest"],
      "medium": ["Volcanic peak", "Waza park", "Bamenda highlands", "Lake Nyos", "Cocoa coffee", "Bantu peoples"],
      "hard": ["Mount Fako active", "Dja reserve", "Foumban palace", "Kribi coast", "Bilingual nation", "Africa in miniature"]
    },
    "imposters": {
      "easy": ["Nigeria", "Chad"],
      "medium": ["CAR", "Congo"],
      "hard": ["Gabon", "Equatorial Guinea"]
    }
  },
  {
    "word": "Ecuador",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A South American country on the equator with the Galápagos Islands and Andes mountains.",
    "tags": ["south-america", "equator", "galapagos"],
    "hints": {
      "easy": ["Equator line", "Galápagos Islands", "Quito capital", "Andes mountains", "Pacific coast", "Amazon rainforest"],
      "medium": ["Mitad del Mundo", "Darwin finches", "Cotopaxi volcano", "Cloud forest", "Banana exports", "Oil production"],
      "hard": ["Yasuni park", "Cuenca colonial", "Baños thermal", "Quilotoa crater", "Otavalo market", "Dollar currency"]
    },
    "imposters": {
      "easy": ["Colombia", "Peru"],
      "medium": ["Bolivia", "Chile"],
      "hard": ["Panama", "Venezuela"]
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
    out_path = os.path.join(out_dir, 'fix_002_countries.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')