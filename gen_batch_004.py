import json
import sys
import os

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

recs = [
  {
    "word": "Cairo",
    "category": "geography_places",
    "subcategory": "Cities",
    "difficulty": "medium",
    "description": "A major Egyptian city on the Nile River near the ancient pyramids.",
    "tags": ["egypt", "africa", "nile"],
    "hints": {
      "easy": ["Nile River", "Egypt", "Arabic language", "Millions of people", "African capital", "Desert climate"],
      "medium": ["Pyramids nearby", "Coptic history", "Islamic architecture", "Tahrir Square", "Old district", "Mohammed Ali mosque"],
      "hard": ["Saladin citadel", "Mamluk era", "British occupation", "Tower structure", "Mohamed Ali square", "Nile delta region"]
    },
    "imposters": {
      "easy": ["Alexandria", "Giza"],
      "medium": ["Luxor", "Aswan"],
      "hard": ["Heliopolis", "Fustat"]
    }
  },
  {
    "word": "London",
    "category": "geography_places",
    "subcategory": "Cities",
    "difficulty": "easy",
    "description": "The capital city of England and the United Kingdom on the River Thames.",
    "tags": ["england", "uk", "europe"],
    "hints": {
      "easy": ["England country", "United Kingdom", "Big Ben clock", "River Thames water", "Capital status", "Historic monarchy"],
      "medium": ["Westminster palace", "Parliament building", "Royal family home", "Financial centre", "Underground transit", "Brexit vote"],
      "hard": ["City proper boundary", "Westminster Abbey site", "Entertainment venue", "Shard skyscraper", "Mayoral office", "Metropolitan area"]
    },
    "imposters": {
      "easy": ["Manchester", "Birmingham"],
      "medium": ["Liverpool", "Leeds"],
      "hard": ["Bristol", "Newcastle"]
    }
  },
  {
    "word": "Paris",
    "category": "geography_places",
    "subcategory": "Cities",
    "difficulty": "easy",
    "description": "The capital city of France, famous for art, fashion and a tall iron tower.",
    "tags": ["france", "europe", "art"],
    "hints": {
      "easy": ["France nation", "Capital status", "Iron lattice tower", "Romantic atmosphere", "Bright lights", "Seine river water"],
      "medium": ["Notre Dame cathedral", "Louvre art museum", "Moulin Rouge venue", "French gastronomy", "Wide avenue shopping", "Victory arch monument"],
      "hard": ["Grand Palais exhibition", "Opéra Garnier ballet", "Montmartre hill district", "Saint-Germain quarter", "Belleville neighbourhood", "Former mayor position"]
    },
    "imposters": {
      "easy": ["Lyon", "Marseille"],
      "medium": ["Nice", "Bordeaux"],
      "hard": ["Toulouse", "Strasbourg"]
    }
  },
  {
    "word": "New York",
    "category": "geography_places",
    "subcategory": "Cities",
    "difficulty": "easy",
    "description": "The largest city on the US East Coast with tall buildings and cultural landmarks.",
    "tags": ["usa", "america", "east-coast"],
    "hints": {
      "easy": ["American nation", "Skyscrapers tall", "Statue with torch", "Manhattan island", "Empire state tall", "Big apple nickname"],
      "medium": ["Brooklyn borough", "Queens airport", "Central park green", "Wall Street finance", "Broadway theatre", "Times Square lights"],
      "hard": ["Fifth Avenue luxury", "SoHo gallery", "Meatpacking district", "Lower east side", "Governor island", "Mayoral office"]
    },
    "imposters": {
      "easy": ["Los Angeles", "Chicago"],
      "medium": ["San Francisco", "Boston"],
      "hard": ["Miami", "Seattle"]
    }
  },
  {
    "word": "Tokyo",
    "category": "geography_places",
    "subcategory": "Cities",
    "difficulty": "medium",
    "description": "The capital city of Japan known for its modern technology and traditional culture.",
    "tags": ["japan", "asia", "modern"],
    "hints": {
      "easy": ["Japan nation", "Capital city", "Modern urban landscape", "Population millions", "Mount Fuji view", "Island nation"],
      "medium": ["Shibuya crossing", "Sushi restaurant", "Sumo wrestling", "Cherry blossom season", "Bullet train station", "Waseda university"],
      "hard": ["Shinjuku ward", "Imperial Palace grounds", "Tōkaidō rail line", "Ginza shopping", "Metropolitan government", "Literary award"]
    },
    "imposters": {
      "easy": ["Osaka", "Kyoto"],
      "medium": ["Yokohama", "Nagoya"],
      "hard": ["Kobe", "Hiroshima"]
    }
  },
  {
    "word": "Sydney",
    "category": "geography_places",
    "subcategory": "Cities",
    "difficulty": "medium",
    "description": "A major Australian coastal city with a famous opera house and harbour bridge.",
    "tags": ["australia", "oceania", "coastal"],
    "hints": {
      "easy": ["Australia nation", "Coastal location", "Opera shell houses", "Harbour steel arch", "Oceania region", "Southern hemisphere"],
      "medium": ["Bondi ocean beach", "Darling fish market", "Taronga zoo animals", "Mardi Gras parade", "Botanical gardens", "City skyline"],
      "hard": ["Mrs Macquaries point", "Cronulla sand beaches", "Pitt street shops", "Light rail tram", "Coastal plain area", "Federal assembly"]
    },
    "imposters": {
      "easy": ["Melbourne", "Brisbane"],
      "medium": ["Perth", "Adelaide"],
      "hard": ["Gold Coast", "Canberra"]
    }
  },
  {
    "word": "Sao Paulo",
    "category": "geography_places",
    "subcategory": "Cities",
    "difficulty": "hard",
    "description": "A large Brazilian city known for Carnival and samba culture by the coast.",
    "tags": ["brazil", "south-america", "coastal"],
    "hints": {
      "easy": ["Brazil nation", "South America", "Atlantic ocean coast", "Carnival festival", "Samba music dance", "Christ statue nearby"],
      "medium": ["Copacabana beach", "Ipanema shore", "Tijuca rainforest", "Maracanã stadium", "Port industrial zone", "World cup victory"],
      "hard": ["Sambadrome parade", "Pedro II emperor", "Garrincha football star", "New year celebration", "Paulista avenue", "State governor"]
    },
    "imposters": {
      "easy": ["Salvador", "Recife"],
      "medium": ["Fortaleza", "Belo Horizonte"],
      "hard": ["Curitiba", "Brasilia"]
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
    out_path = os.path.join(out_dir, '004_cities.json')
    with open(out_path, 'w', encoding='utf8') as f:
        json.dump(recs, f, indent=2, ensure_ascii=False)
    print('Wrote', out_path)
else:
    print('ERRORS - file not written')