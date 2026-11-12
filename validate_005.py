import json, sys, os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Luxembourg",
    "category": "geography_places",
    "subcategory": "Benelux",
    "difficulty": "medium",
    "description": "A small European nation with stone fortresses and financial district in the west.",
    "tags": ["europe", "country", "benelux"],
    "hints": {
      "easy": ["Fortress", "Ardennes", "Bourgmestre", "Porte de France", "Green valleys", "Railway hub"],
      "medium": ["Graslei", "KMSKA", "European investment", "Throm bone", "Rhineland", "Eupen"],
      "hard": ["Oesling", "Kneiff", "Munsters", "Sauer valley", "Schumann", "Witt"]
    },
    "imposters": {
      "easy": ["Belgium", "Netherlands", "Switzerland"],
      "medium": ["France", "Germany", "UK"],
      "hard": ["Eupen", "Arlon", "Marche"]}
    }
  },
  {
    "word": "Monaco",
    "category": "geography_places",
    "subcategory": "Western Europe",
    "difficulty": "easy",
    "description": "A glamorous Mediterranean city-state famous for its casino and luxury yachts.",
    "tags": ["europe", "country", "city-state"],
    "hints": {
      "easy": ["Mediterranean", "Casino", "Yacht", "Glamour", "Sunny", "Coastal"],
      "medium": ["Fortune", "Princess", "Conference", "Rock", "Urban", "State"],
      "hard": ["Monte Carlo", "Grimaldi", "Fontvieille"]}
    ,
    "imposters": {
      "easy": ["Luxembourg", "Andorra", "San marino"],
      "medium": ["Vatican", "Liechtenstein", "Sicily"],
      "hard": ["Monte Carlo", "Fontvieille", "Condamine"]}
    }
  },
  {
    "word": "Vatican",
    "category": "geography_places",
    "subcategory": "Southern Europe",
    "difficulty": "hard",
    "description": "An independent city-state within Rome, spiritual center of the Church.",
    "tags": ["europe", "country", "city-state"],
    "hints": {
      "easy": ["Rome within", "St Peters", "Catholic", "Pope", "Independent", "Smallest"],
      "medium": ["Apostolic", "Swiss guard", "Sistine", "Vatican city", "Gregorian", "Latin"],
      "hard": ["Basilica", "Museums", "Urbi et orbi", "Roman curia", "Succession", "Cardinals"]}
    ,
    "imposters": {
      "easy": ["Monaco", "Malta", "San marino"],
      "medium": ["Luxembourg", "Andorra", "Liechtenstein"],
      "hard": ["St Peters", "Apostolic", "Clementine"]}
    }
  },
  {
    "word": "Andorra",
    "category": "geography_places",
    "subcategory": "Southern Europe",
    "difficulty": "easy",
    "description": "A Pyrenean microstate between France and Spain with ski resorts and duty-free shops.",
    "tags": ["europe", "country", "pyrenees"],
    "hints": {
      "easy": ["Pyrenees", "Between", "Catalan", "Ski", "Duty-free", "Tax haven"],
      "medium": ["Arinsal", "Pal", "Grandvalira", "Vallnord", "Sant", "Julià"],
      "hard": ["Ordino", "Nurderobert", "Roc del Quer"]}
    ,
    "imposters": {
      "easy": ["Monaco", "Liechtenstein", "Luxembourg"],
      "medium": ["Spain", "France", "Catalonia"],
      "hard": ["Pirineus", "Val d Andorra", "Ordino"]}
    }
  },
  {
    "word": "Georgia",
    "category": "geography_places",
    "subcategory": "Caucasus",
    "difficulty": "medium",
    "description": "A mountainous nation at the crossroads of Europe and Asia with ancient wine traditions.",
    "tags": ["europe", "country", "caucasus"],
    "hints": {
      "easy": ["Mountain", "Tbilisi", "Wine", "Black Sea", "Crossroads", "Script"],
      "medium": ["Svaneti", "Kazbegi", "Martvili", "Prometheus", "Ushguli", "Bagrati"],
      "hard": ["Sighnaghi", "Kakheti", "Racha", "Lower Svaneti", "Upper", "Mtatsminda"]}
    ,
    "imposters": {
      "easy": ["Armenia", "Azerbaijan", "Turkey"],
      "medium": ["Russia", "Iran", "Georgia"],
      "hard": ["Tbilisi", "Baku", "Yerevan"]}
    }
  },
  {
    "word": "Azerbaijan",
    "category": "geography_places",
    "subcategory": "Caucasus",
    "difficulty": "medium",
    "description": "A nation at the crossing of Europe and Asia with Caspian sea and oil wealth.",
    "tags": ["europe", "country", "caucasus"],
    "hints": {
      "easy": ["Caspian", "Baku", "Flame", "Oil", "Silk road", "Mugham"],
      "medium": ["Garay", "Nakhchivan", "Abbas", "Yanar", "Karabakh", "Lankaran"],
      "hard": ["Zangezur", "Absheron", "Goygol", "Shirvan", "Lahij", "Guba"]}
    ,
    "imposters": {
      "easy": ["Georgia", "Armenia", "Turkey"],
      "medium": ["Russia", "Iran", "Georgia"],
      "hard": ["Baku", "Ganja", "Mingechevir"]}
    }
  },
  {
    "word": "Uzbekistan",
    "category": "geography_places",
    "subcategory": "Central Asia",
    "difficulty": "hard",
    "description": "A Central Asian landlocked nation with Silk Road cities and Islamic architecture.",
    "tags": ["asia", "country", "central"],
    "hints": {
      "easy": ["Silk road", "Tashkent", "Samarkand", "Aral", "Registan", "Islamic"],
      "medium": ["Khiva", "Bukhara", "Shakhrisabz", "Fergana", "Amu Darya", "Syr Darya"],
      "hard": ["Karakalpak", "Navoi", "Nukus", "Yangiyul", "Kitab", "Gijduvan"]}
    ,
    "imposters": {
      "easy": ["Kazakhstan", "Tajikistan", "Turkmenistan"],
      "medium": ["Kyrgyzstan", "Afghanistan", "Tajikistan"],
      "hard": ["Tashkent", "Samarkand", "Bukhara"]}
    }
  },
  {
    "word": "Kyrgyzstan",
    "category": "geography_places",
    "subcategory": "Central Asia",
    "difficulty": "hard",
    "description": "A Central Asian nation with Tien Shan mountains and nomadic yurt traditions.",
    "tags": ["asia", "country", "central"],
    "hints": {
      "easy": ["Tian Shan", "Bishkek", "Nomadic", "Silk road", "Issyk", "Kul"],
      "medium": ["Karakol", "Song Kul", "Ala Archa", "Issyk Kul", "Kyrgyz", "Manas"],
      "hard": ["Too too", "Kyrk Choko", "Saimaluu", "Chatkal", "Jeti Oguz", "Barskaun"]}
    ,
    "imposters": {
      "easy": ["Kazakhstan", "Tajikistan", "Mongolia"],
      "medium": ["Uzbekistan", "Kazakhstan", "Afghanistan"],
      "hard": ["Bishkek", "Osh", "Karacol"]}
    }
  },
  {
    "word": "Brunei",
    "category": "geography_places",
    "subcategory": "Southeast Asia",
    "difficulty": "medium",
    "description": "A small Bornean nation with sultanate wealth, mosques and tropical rainforests.",
    "tags": ["asia", "country", "southeast"],
    "hints": {
      "easy": ["Borneo", "Sultan", "Mosque", "Wealth", "Rainforest", "South China"],
      "medium": ["Istana", "South China sea", "Miri", "Temburong", "Johor"],
      "hard": ["Bandar", "Seri Begawan", "Temburong"]}
    ,
    "imposters": {
      "easy": ["Malaysia", "Singapore", "Qatar"],
      "medium": ["Philippines", "Indonesia", "Malaysia"],
      "hard": ["Bandar", "Temburong", "Tutong"]}
    }
  },
  {
    "word": "Samoa",
    "category": "geography_places",
    "subcategory": "Polynesia",
    "difficulty": "easy",
    "description": "A Polynesian nation with two main islands, traditional culture and ocean vistas.",
    "tags": ["asia", "country", "polynesia"],
    "hints": {
      "easy": ["Two islands", "Polynesian", "Apia", "Ocean", "Coconut", "Dance"],
      "medium": ["Upolu", "Savaii", "Fale", "Fa'a Samoa", "Orchid", "Kava"],
      "hard": ["Manono", "Apolima", "Salelologa", "Vaiusu", "Matautu", "Fagalii"]}
    ,
    "imposters": {
      "easy": ["Tonga", "Fiji", "Tahiti"],
      "medium": ["Hawaii", "Cook", "Tahiti"],
      "hard": ["Apia", "Salelologa", "Vaiusu"]}
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
    out_path = os.path.join(out_dir, '005_countries.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')