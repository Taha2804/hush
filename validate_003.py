import json, sys, os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Latvia",
    "category": "geography_places",
    "subcategory": "Baltic States",
    "difficulty": "medium",
    "description": "A Baltic nation on the Baltic Sea coast with medieval towns and art nouveau architecture.",
    "tags": ["europe", "country", "baltic"],
    "hints": {
      "easy": ["Baltic Sea", "Riga capital", "Amber coast", "Medieval old", "Forest land", "Euro currency"],
      "medium": ["Daugava river", "Gauja valley", "Art nouveau", "Hanseatic past", "Folk songs", "Sigulda caves"],
      "hard": ["Livonian coast", "Latgalian clay", "Jurmala resort", "Rundale palace", "Kemeri bog", "Dainu festivals"]
    },
    "imposters": {
      "easy": ["Lithuania", "Estonia", "Finland"],
      "medium": ["Poland", "Belarus", "Sweden"],
      "hard": ["Vilnius", "Tallinn", "Helsinki"]
    }
  },
  {
    "word": "Estonia",
    "category": "geography_places",
    "subcategory": "Baltic States",
    "difficulty": "medium",
    "description": "A Baltic nation with medieval capital Tallinn and digital innovation reputation.",
    "tags": ["europe", "country", "baltic"],
    "hints": {
      "easy": ["Baltic Sea", "Tallinn old", "Digital nation", "Islands many", "Forest cover", "Euro currency"],
      "medium": ["Lahemaa park", "Saaremaa island", "E-residency", "Medieval walls", "Folk culture", "Song festival"],
      "hard": ["Estonian language", "Seto people", "Viljandi town", "Narva castle", "Kihnu island", "Hiiumaa ferry"]
    },
    "imposters": {
      "easy": ["Latvia", "Finland", "Lithuania"],
      "medium": ["Poland", "Russia", "Sweden"],
      "hard": ["Riga", "Helsinki", "Vilnius"]
    }
  },
  {
    "word": "Slovakia",
    "category": "geography_places",
    "subcategory": "Central Europe",
    "difficulty": "medium",
    "description": "A Central European nation with High Tatra peaks, medieval castles and folk traditions.",
    "tags": ["europe", "country", "mountains"],
    "hints": {
      "easy": ["High Tatras", "Bratislava city", "Danube river", "Castle ruins", "Folk music", "Euro currency"],
      "medium": ["Spis castle", "Slovak paradise", "Orava castle", "Wooden churches", "Sheep cheese", "Cave systems"],
      "hard": ["Gerlachovsky peak", "Ako karst", "Tokaj wine", "Huta Slavia", "Fujara pipe", "Velky roven"]
    },
    "imposters": {
      "easy": ["Czechia", "Hungary", "Slovenia"],
      "medium": ["Poland", "Austria", "Ukraine"],
      "hard": ["Prague", "Budapest", "Ljubljana"]
    }
  },
  {
    "word": "Slovenia",
    "category": "geography_places",
    "subcategory": "Central Europe",
    "difficulty": "medium",
    "description": "A Central European nation with Alpine peaks, Adriatic coast and cave systems.",
    "tags": ["europe", "country", "alpine"],
    "hints": {
      "easy": ["Lake Bled", "Ljubljana city", "Julian Alps", "Adriatic coast", "Cave world", "Euro currency"],
      "medium": ["Postojna cave", "Triglav peak", "Soca river", "Predjama castle", "Lipizzaner horses", "Kras region"],
      "hard": ["Skocjan caves", "Vipava valley", "Idrija mercury", "Planica jumps", "Kranjska klobasa", "Ptuj town"]
    },
    "imposters": {
      "easy": ["Croatia", "Slovakia", "Austria"],
      "medium": ["Italy", "Hungary", "Czechia"],
      "hard": ["Zagreb", "Bratislava", "Vienna"]
    }
  },
  {
    "word": "Serbia",
    "category": "geography_places",
    "subcategory": "Balkans",
    "difficulty": "medium",
    "description": "A Balkan nation at the Danube crossroads with medieval monasteries and vibrant culture.",
    "tags": ["europe", "country", "balkans"],
    "hints": {
      "easy": ["Belgrade city", "Danube river", "Orthodox faith", "Rakia drink", "Medieval forts", "Folk music"],
      "medium": ["Novi Sad", "Tara canyon", "Studenica monastery", "Exit festival", "Plum brandy", "Vojvodina plain"],
      "hard": ["Golubac fortress", "Djavolja varos", "Kopaonik ski", "Zica monastery", "Guca trumpet", "Sremski Karlovci"]
    },
    "imposters": {
      "easy": ["Croatia", "Bosnia", "Bulgaria"],
      "medium": ["Hungary", "Romania", "Montenegro"],
      "hard": ["Zagreb", "Sarajevo", "Sofia"]
    }
  },
  {
    "word": "Bulgaria",
    "category": "geography_places",
    "subcategory": "Balkans",
    "difficulty": "medium",
    "description": "A Balkan nation with Black Sea coast, ancient Thracian sites and rose oil production.",
    "tags": ["europe", "country", "balkans"],
    "hints": {
      "easy": ["Black Sea", "Sofia capital", "Rose valley", "Yogurt land", "Cyrillic script", "Mountain peaks"],
      "medium": ["Rila monastery", "Plovdiv old", "Seven lakes", "Thracian tomb", "Bansko ski", "Melnik wine"],
      "hard": ["Madara rider", "Pirin mountain", "Koprivshtitsa", "Rose festival", "Nestinar fire", "Belogradchik rocks"]
    },
    "imposters": {
      "easy": ["Romania", "Serbia", "Greece"],
      "medium": ["Turkey", "North Macedonia", "Moldova"],
      "hard": ["Bucharest", "Belgrade", "Athens"]
    }
  },
  {
    "word": "Albania",
    "category": "geography_places",
    "subcategory": "Balkans",
    "difficulty": "medium",
    "description": "A Balkan nation with Adriatic Ionian coasts, Ottoman heritage and rugged mountains.",
    "tags": ["europe", "country", "balkans"],
    "hints": {
      "easy": ["Tirana capital", "Adriatic coast", "Double eagle", "Bunkers many", "Mediterranean", "Skanderbeg hero"],
      "medium": ["Berat city", "Gjirokaster", "Albanian Alps", "Ksamil beach", "Besa honor", "Raki drink"],
      "hard": ["Butrint ruins", "Ohrid lake", "Theth valley", "Kruja castle", "Llogara pass", "Vlora bay"]
    },
    "imposters": {
      "easy": ["Greece", "Kosovo", "Montenegro"],
      "medium": ["Italy", "North Macedonia", "Croatia"],
      "hard": ["Athens", "Pristina", "Podgorica"]
    }
  },
  {
    "word": "Montenegro",
    "category": "geography_places",
    "subcategory": "Balkans",
    "difficulty": "medium",
    "description": "A small Balkan nation with dramatic bay, rugged mountains and medieval towns.",
    "tags": ["europe", "country", "balkans"],
    "hints": {
      "easy": ["Bay Kotor", "Podgorica city", "Black mountain", "Adriatic coast", "Durmitor peaks", "Tara canyon"],
      "medium": ["Sveti Stefan", "Ostrog monastery", "Lovcen mountain", "Skadar lake", "Perast islets", "Njegos mausoleum"],
      "hard": ["Bigorski lake", "Prokletije", "Cetinje old", "Ulcinj beach", "Kolashin ski", "Plav lake"]
    },
    "imposters": {
      "easy": ["Albania", "Croatia", "Serbia"],
      "medium": ["Bosnia", "Slovenia", "Kosovo"],
      "hard": ["Tirana", "Dubrovnik", "Belgrade"]
    }
  },
  {
    "word": "Cyprus",
    "category": "geography_places",
    "subcategory": "Mediterranean",
    "difficulty": "medium",
    "description": "An eastern Mediterranean island nation with ancient ruins, divided capital and copper history.",
    "tags": ["europe", "country", "island"],
    "hints": {
      "easy": ["Mediterranean", "Nicosia divided", "Aphrodite birth", "Halloumi cheese", "Copper island", "Beach resorts"],
      "medium": ["Troodos mountains", "Paphos mosaics", "Kyrenia harbor", "Salamis ruins", "Commandaria wine", "Lefkara lace"],
      "hard": ["Akamas peninsula", "Kourion theatre", "Choirokoitia", "Stavrovouni", "Avakas gorge", "Omodos village"]
    },
    "imposters": {
      "easy": ["Greece", "Malta", "Lebanon"],
      "medium": ["Turkey", "Israel", "Egypt"],
      "hard": ["Athens", "Valletta", "Beirut"]
    }
  },
  {
    "word": "Malta",
    "category": "geography_places",
    "subcategory": "Mediterranean",
    "difficulty": "medium",
    "description": "A tiny Mediterranean archipelago with megalithic temples, baroque capital and naval history.",
    "tags": ["europe", "country", "island"],
    "hints": {
      "easy": ["Mediterranean", "Valletta capital", "Megalithic temples", "Knights hospitaller", "Blue lagoon", "English speaking"],
      "medium": ["Mdina silent", "Gozo island", "Hypogeum", "Marsaxlokk boats", "Festa season", "Pastizzi snack"],
      "hard": ["Ggantija temples", "Dingli cliffs", "Comino blue", "Tarxien complex", "Mnajdra stones", "Xaghra circle"]
    },
    "imposters": {
      "easy": ["Cyprus", "Sicily", "Greece"],
      "medium": ["Italy", "Tunisia", "Crete"],
      "hard": ["Nicosia", "Palermo", "Athens"]
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
    out_path = os.path.join(out_dir, '004_countries.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')