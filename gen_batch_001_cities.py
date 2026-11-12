import json, sys, os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Karachi",
    "category": "geography_places",
    "subcategory": "Cities of Asia",
    "difficulty": "medium",
    "description": "A sprawling Pakistani port city on the Arabian Sea with millions of residents.",
    "tags": ["pakistan", "city", "port", "arabian-sea"],
    "hints": {
      "easy": ["Port city", "Millions people", "Arabian coast", "Pakistan hub", "Busy streets", "Sea breeze"],
      "medium": ["Indus delta", "Textile industry", "Quaid mausoleum", "Monsoon season", "Railway junction", "Clifton beach"],
      "hard": ["Ghizri creek", "Korangi crossing", "Malir river", "Saddar bazaar", "Defence housing", "Gulshan e iqbal"]
    },
    "imposters": {
      "easy": ["Lahore", "Mumbai", "Dhaka"],
      "medium": ["Faisalabad", "Rawalpindi", "Multan"],
      "hard": ["Hyderabad", "Peshawar", "Quetta"]
    }
  },
  {
    "word": "Manila",
    "category": "geography_places",
    "subcategory": "Cities of Asia",
    "difficulty": "easy",
    "description": "The Philippine capital on Luzon island with a historic walled district.",
    "tags": ["philippines", "city", "capital", "luzon"],
    "hints": {
      "easy": ["Capital city", "Luzon island", "Walled district", "Pasig river", "Tropical heat", "Jeepney rides"],
      "medium": ["Intramuros walls", "Rizal park", "Binondo chinatown", "Bay sunset view", "Catholic churches", "Makati skyline"],
      "hard": ["Quiapo market", "Divisoria stalls", "Luneta grounds", "Ermita district", "Malacanang palace", "Paco park"]
    },
    "imposters": {
      "easy": ["Cebu", "Jakarta", "Bangkok"],
      "medium": ["Davao", "Baguio", "Iloilo"],
      "hard": ["Cagayan", "Zamboanga", "General Santos"]
    }
  },
  {
    "word": "Jakarta",
    "category": "geography_places",
    "subcategory": "Cities of Asia",
    "difficulty": "medium",
    "description": "Indonesia's vast capital on Java island known for traffic and tropical climate.",
    "tags": ["indonesia", "city", "capital", "java"],
    "hints": {
      "easy": ["Capital city", "Java island", "Traffic jams", "Tropical heat", "Millions live", "Monas tower"],
      "medium": ["Kota Tua district", "Thousand islands", "Sudirman avenue", "Tanah Abang", "Flood season", "Satay stalls"],
      "hard": ["Glodok market", "Menteng elite", "Ancol dreamland", "Kemayoran airport", "Senayan stadium", "Cikini hospital"]
    },
    "imposters": {
      "easy": ["Bali", "Manila", "Kuala Lumpur"],
      "medium": ["Surabaya", "Bandung", "Medan"],
      "hard": ["Semarang", "Makassar", "Palembang"]
    }
  },
  {
    "word": "Sao Paulo",
    "category": "geography_places",
    "subcategory": "Cities of South America",
    "difficulty": "easy",
    "description": "Brazil's largest metropolis and financial center with diverse culture and skyscrapers.",
    "tags": ["brazil", "city", "financial", "metropolis"],
    "hints": {
      "easy": ["Brazil hub", "Skyscrapers", "Paulista avenue", "Millions people", "Coffee trade", "Traffic chaos"],
      "medium": ["Ibirapuera park", "Liberdade district", "Museum art", "Helicopter fleet", "Street art", "Football passion"],
      "hard": ["Vila Madalena", "Jardins luxury", "Se cathedral", "Mercadao market", "Pinheiros river", "Guarulhos airport"]
    },
    "imposters": {
      "easy": ["Rio", "Buenos Aires", "Mexico City"],
      "medium": ["Brasilia", "Salvador", "Fortaleza"],
      "hard": ["Campinas", "Santos", "Ribeirao"]
    }
  },
  {
    "word": "Nashville",
    "category": "geography_places",
    "subcategory": "Cities of North America",
    "difficulty": "easy",
    "description": "Tennessee's capital known for country music heritage and famous venues.",
    "tags": ["usa", "city", "tennessee", "music"],
    "hints": {
      "easy": ["Music City", "Country music", "Tennessee capital", "Grand Ole Opry", "Honky tonks", "Guitar town"],
      "medium": ["Ryman auditorium", "Broadway district", "Songwriter rounds", "Hot chicken", "Cumberland river", "Vanderbilt campus"],
      "hard": ["Bluebird cafe", "Music row studios", "Printers alley", "Germantown historic", "Shelby park", "Centennial park"]
    },
    "imposters": {
      "easy": ["Memphis", "Austin", "Atlanta"],
      "medium": ["Knoxville", "Chattanooga", "Clarksville"],
      "hard": ["Murfreesboro", "Franklin", "Hendersonville"]
    }
  },
  {
    "word": "Houston",
    "category": "geography_places",
    "subcategory": "Cities of North America",
    "difficulty": "easy",
    "description": "A Texas metropolis with space center, energy industry and diverse neighborhoods.",
    "tags": ["usa", "city", "texas", "energy"],
    "hints": {
      "easy": ["Space center", "Texas city", "Oil industry", "Bayou city", "Diverse people", "Hot summers"],
      "medium": ["Mission control", "Buffalo bayou", "Museum district", "Galleria mall", "Medical center", "Port facilities"],
      "hard": ["Montrose arts", "Heights historic", "Rice university", "Ship channel", "NRG stadium", "Kemah boardwalk"]
    },
    "imposters": {
      "easy": ["Dallas", "Austin", "Atlanta"],
      "medium": ["San Antonio", "Fort Worth", "El Paso"],
      "hard": ["Galveston", "Corpus Christi", "Laredo"]
    }
  },
  {
    "word": "Atlanta",
    "category": "geography_places",
    "subcategory": "Cities of North America",
    "difficulty": "easy",
    "description": "Georgia's capital with civil rights history, major airport and tree-lined streets.",
    "tags": ["usa", "city", "georgia", "capital"],
    "hints": {
      "easy": ["Georgia capital", "Peachtree streets", "Soda headquarters", "Busy airport", "Civil rights", "Tree canopy"],
      "medium": ["MLK historic site", "Centennial park", "Fox theatre", "Beltline trail", "Piedmont park", "Sweet Auburn"],
      "hard": ["Decatur square", "Inman park", "Little five points", "West end", "Buckhead towers", "College park"]
    },
    "imposters": {
      "easy": ["Houston", "Nashville", "Charlotte"],
      "medium": ["Savannah", "Augusta", "Columbus"],
      "hard": ["Marietta", "Roswell", "Sandy Springs"]
    }
  },
  {
    "word": "Denver",
    "category": "geography_places",
    "subcategory": "Cities of North America",
    "difficulty": "easy",
    "description": "Colorado's mile-high city near the Rocky Mountains with outdoor lifestyle.",
    "tags": ["usa", "city", "colorado", "mountains"],
    "hints": {
      "easy": ["Mile high", "Rocky Mountains", "Colorado city", "Outdoor life", "Microbrewery scene", "Snowy winters"],
      "medium": ["Red rocks amphitheatre", "LoDo district", "Union station", "Cherry creek", "City park", "Coors field"],
      "hard": ["RiNo arts", "Highlands square", "Sloan lake", "Stapleton airport", "Cherry hills", "Green mountain"]
    },
    "imposters": {
      "easy": ["Boise", "Phoenix", "Austin"],
      "medium": ["Boulder", "Fort Collins", "Pueblo"],
      "hard": ["Aurora", "Lakewood", "Thornton"]
    }
  },
  {
    "word": "Venice Beach",
    "category": "geography_places",
    "subcategory": "Cities of North America",
    "difficulty": "easy",
    "description": "A Los Angeles coastal neighborhood famous for boardwalk, skate culture and street performers.",
    "tags": ["usa", "city", "california", "beach"],
    "hints": {
      "easy": ["Boardwalk", "Skate park", "Street performers", "Pacific ocean", "Los Angeles", "Outdoor gym"],
      "medium": ["Abbot Kinney", "Canals historic", "Sunset drumming", "Basketball courts", "Ocean front walk", "Local art"],
      "hard": ["Windward avenue", "Speedway alley", "Rose avenue", "Washington blvd", "Palms district", "Marina del rey"]
    },
    "imposters": {
      "easy": ["Malibu", "Miami Beach", "Santa Monica"],
      "medium": ["Huntington Beach", "Newport Beach", "Laguna Beach"],
      "hard": ["Manhattan Beach", "Redondo Beach", "Hermosa Beach"]
    }
  },
  {
    "word": "Ottawa",
    "category": "geography_places",
    "subcategory": "Cities of North America",
    "difficulty": "medium",
    "description": "Canada's capital on the Ottawa River with parliament buildings and winter skating.",
    "tags": ["canada", "city", "capital", "parliament"],
    "hints": {
      "easy": ["Parliament hill", "Rideau canal", "Winter skating", "Maple leaf", "Bilingual center", "Cold winters"],
      "medium": ["Byward market", "Gatineau park", "National gallery", "Tulip festival", "Supreme court", "Chateau Laurier"],
      "hard": ["Sparks street", "Centretown west", "Westboro village", "Kanata tech", "Barrhaven south", "Orleans east"]
    },
    "imposters": {
      "easy": ["Toronto", "Montreal", "Washington"],
      "medium": ["Quebec City", "Halifax", "Winnipeg"],
      "hard": ["Kingston", "London", "Hamilton"]
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
    else:
        print('OK:', r['word'])

if not any_err:
    print('\nALL PASSED!')
    out_dir = r'C:\Users\badam\Desktop\hush\tool\words\replies'
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, '001_cities.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('\nERRORS - file not written')