import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Luxembourg",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A small European grand duchy between Belgium, Germany and France known for banking.",
    "tags": ["europe", "benelux", "banking"],
    "hints": {
      "easy": ["Small country", "European nation", "Grand duchy", "Wealthy banking", "Three borders", "French german"],
      "medium": ["Benelux union", "Luxembourgish tongue", "Fortress city", "EU institutions", "Iron industry", "Schueberfouer fair"],
      "hard": ["Grand Duke Henri", "Alzette river", "Bock casemates", "Mudam museum", "Euro currency", "GDP per capita"]
    },
    "imposters": {
      "easy": ["Belgium", "Monaco"],
      "medium": ["Liechtenstein", "Andorra"],
      "hard": ["San Marino", "Vatican"]
    }
  },
  {
    "word": "Monaco",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A tiny Mediterranean principality on the French Riviera known for casinos and luxury.",
    "tags": ["europe", "mediterranean", "luxury"],
    "hints": {
      "easy": ["Tiny principality", "French Riviera", "Monte Carlo", "Formula One", "Casino", "Prince palace"],
      "medium": ["Mediterranean coast", "Grimaldi dynasty", "Tax haven", "Yacht harbour", "Larvotto beach", "Opera house"],
      "hard": ["Monte Carlo district", "Prince Albert II", "Grace Kelly", "Oceanographic museum", "La Condamine", "Fontvieille district"]
    },
    "imposters": {
      "easy": ["Luxembourg", "Andorra"],
      "medium": ["San Marino", "Liechtenstein"],
      "hard": ["Vatican", "Malta"]
    }
  },
  {
    "word": "Vatican",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "easy",
    "description": "The smallest independent state in the world, headquarters of the Roman Catholic Church.",
    "tags": ["europe", "religion", "city-state"],
    "hints": {
      "easy": ["Smallest state", "Pope residence", "Catholic church", "St Peter's", "Sistine Chapel", "Holy See"],
      "medium": ["Vatican museums", "Swiss Guard", "Papal audience", "Latin tongue", "City state", "Religious centre"],
      "hard": ["Roman Curia", "Papal apartments", "Apostolic palace", "Vatican library", "Extraterritorial", "Pontifical academy"]
    },
    "imposters": {
      "easy": ["Monaco", "Malta"],
      "medium": ["San Marino", "Andorra"],
      "hard": ["Liechtenstein", "Luxembourg"]
    }
  },
  {
    "word": "Andorra",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A small principality in the Pyrenees mountains between France and Spain known for skiing.",
    "tags": ["europe", "pyrenees", "skiing"],
    "hints": {
      "easy": ["Pyrenees mountains", "France Spain", "Small principality", "Ski resorts", "Duty free", "Co-princes"],
      "medium": ["Andorra la Vella", "Catalan language", "Mountain valleys", "Tax shopping", "Romanesque churches", "Hiking trails"],
      "hard": ["Vallnord ski", "Grandvalira slopes", "Madriu valley", "UNESCO heritage", "Caldea spa", "Euro currency"]
    },
    "imposters": {
      "easy": ["Monaco", "Liechtenstein"],
      "medium": ["Luxembourg", "San Marino"],
      "hard": ["Vatican", "Malta"]
    }
  },
  {
    "word": "Georgia",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A country at the intersection of Europe and Asia in the Caucasus region with ancient viticulture.",
    "tags": ["caucasus", "europe", "asia"],
    "hints": {
      "easy": ["Caucasus region", "Europe Asia", "Tbilisi capital", "Wine making", "Mountain scenery", "Orthodox church"],
      "medium": ["Kakheti vineyards", "Svaneti towers", "Kazbegi peak", "Black Sea coast", "Unique alphabet", "Supra feast"],
      "hard": ["Qvevri clay vessels", "Medea golden fleece", "Batumi boulevard", "Ushguli village", "Polyphonic singing", "Jvari monastery"]
    },
    "imposters": {
      "easy": ["Armenia", "Azerbaijan"],
      "medium": ["Turkey", "Russia"],
      "hard": ["Ukraine", "Moldova"]
    }
  },
  {
    "word": "Azerbaijan",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A Caspian Sea nation in the Caucasus with oil wealth and ancient fire temples.",
    "tags": ["caucasus", "caspian", "oil"],
    "hints": {
      "easy": ["Caspian Sea", "Baku capital", "Oil wealth", "Fire land", "Caucasus region", "Azerbaijani tongue"],
      "medium": ["Flame towers", "Maiden tower", "Gobustan petroglyphs", "Mud volcanoes", "Carpet weaving", "Silk road"],
      "hard": ["Yanar Dag fire", "Heydar Aliyev", "Baku boulevard", "Ateshgah temple", "Khinalug village", "Caspian coast"]
    },
    "imposters": {
      "easy": ["Georgia", "Armenia"],
      "medium": ["Turkey", "Iran"],
      "hard": ["Kazakhstan", "Turkmenistan"]
    }
  },
  {
    "word": "Uzbekistan",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A Central Asian nation on the ancient Silk Road with famous Islamic architecture.",
    "tags": ["central-asia", "silk-road", "architecture"],
    "hints": {
      "easy": ["Central Asia", "Silk Road", "Samarkand city", "Bukhara old", "Registan square", "Islamic tiles"],
      "medium": ["Tashkent capital", "Khiva walls", "Chorsu bazaar", "Timur legacy", "Plov rice dish", "Ceramic blue"],
      "hard": ["Shah-i-Zinda necropolis", "Bibi-Khanym mosque", "Ulugh Beg observatory", "Ichan Kala fortress", "Afrasiyab ruins", "Navoi theatre"]
    },
    "imposters": {
      "easy": ["Kazakhstan", "Tajikistan"],
      "medium": ["Turkmenistan", "Kyrgyzstan"],
      "hard": ["Afghanistan", "Mongolia"]
    }
  },
  {
    "word": "Kyrgyzstan",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "hard",
    "description": "A mountainous Central Asian country with nomadic traditions and alpine lakes.",
    "tags": ["central-asia", "mountains", "nomadic"],
    "hints": {
      "easy": ["Central Asia", "Tian Shan mountains", "Bishkek capital", "Yurt dwelling", "Horse culture", "Alpine lakes"],
      "medium": ["Issyk-Kul lake", "Song Kul pasture", "Eagle hunting", "Tribal system", "Oral tradition", "Mountain passes"],
      "hard": ["Kochkor village", "Tash Rabat caravanserai", "Sary-Chelek reserve", "Epic poetry", "Komuz instrument", "Ala-Too range"]
    },
    "imposters": {
      "easy": ["Kazakhstan", "Tajikistan"],
      "medium": ["Mongolia", "Uzbekistan"],
      "hard": ["Turkmenistan", "Afghanistan"]
    }
  },
  {
    "word": "Brunei",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A small wealthy sultanate on Borneo island with oil riches and Islamic architecture.",
    "tags": ["southeast-asia", "borneo", "sultanate"],
    "hints": {
      "easy": ["Borneo island", "Sultanate rule", "Oil wealth", "Tiny nation", "Mosque golden", "Rainforest"],
      "medium": ["Bandar Seri Begawan", "Hassanal Bolkiah", "Water village", "Omar Ali Saifuddien", "Royal regalia", "Gadong market"],
      "hard": ["Kampong Ayer stilt", "Jame Asr Hassanil", "Ulu Temburong park", "Currency stamp", "Malay monarchy", "Borneo rainforest"]
    },
    "imposters": {
      "easy": ["Malaysia", "Singapore"],
      "medium": ["Qatar", "Bahrain"],
      "hard": ["Kuwait", "Oman"]
    }
  },
  {
    "word": "Samoa",
    "category": "geography_places",
    "subcategory": "Countries",
    "difficulty": "medium",
    "description": "A Polynesian island nation in the Pacific with traditional communal culture.",
    "tags": ["pacific", "polynesia", "island"],
    "hints": {
      "easy": ["Pacific island", "Polynesian culture", "Apia capital", "Coconut palms", "Lagoon blue", "Tattoo traditional"],
      "medium": ["Fale house", "Siva dance", "Kava ceremony", "Matai chief", "Tapa cloth", "Coral reef"],
      "hard": ["Fa'a Samoa way", "Treaty place", "Lalomanu beach", "To Sua trench", "Island language", "Independence day"]
    },
    "imposters": {
      "easy": ["Tonga", "Fiji"],
      "medium": ["Tahiti", "Cook Straits"],
      "hard": ["Niue", "Tuvalu"]
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
    out_path = os.path.join(out_dir, '005_countries.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')