#!/usr/bin/env python3
"""Generate v2 records for 003 countries batch (Uruguay, Paraguay, Panama, Costa Rica, Guatemala, Honduras, Haiti, Bahamas, Barbados, Lithuania).
Validates with wordlib.py and writes to tool/words/src/countries/gen003.json
"""

import json
import sys
sys.path.insert(0, ".")

from tool.words.wordlib import load_categories, Lists, validate_record

lists = Lists()
cats_list = load_categories()
cats = {c['id']: c for c in cats_list}

records = []

# 1. Uruguay - Fix: description must not repeat hints verbatim
records.append({
    "word": "Uruguay",
    "category": "geography_places",
    "subcategory": "Uruguay",
    "difficulty": "hard",
    "description": "A South American nation on the Atlantic coast with extensive river deltas.",
    "tags": ["south", "american", "coastal"],
    "hints": {
        "easy": ["River delta", "Montevideo", "Grasslands", "Plains", "Atlantic shore", "Eastern basin"],
        "medium": ["Beef production", "Mate culture", "Port city", "Independence day", "Gaucho heritage", "Rio de la Plata"],
        "hard": ["First world cup host", "Constitutional democracy", "Secular republic", "Small nation", "Border dispute", "Economic reform"]
    },
    "imposters": {
        "easy": ["Argentina", "Paraguay"],
        "medium": ["Brazil", "Chile"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 2. Paraguay - OK
records.append({
    "word": "Paraguay",
    "category": "geography_places",
    "subcategory": "Paraguay",
    "difficulty": "hard",
    "description": "A South American landlocked nation at the confluence of two major rivers.",
    "tags": ["south", "american", "landlocked"],
    "hints": {
        "easy": ["South American", "Landlocked country", "River junction", "Central plateau", "Asunción", "Guarani"],
        "medium": ["Hydroelectric", "Chaco region", "Rural economy", "Star flag", "Independence heritage", "Subtropical"],
        "hard": ["Huge dam", "Two languages", "Harp music", "Lace weaving", "Notable landmark", "Celebrated feature"]
    },
    "imposters": {
        "easy": ["Uruguay", "Bolivia"],
        "medium": ["Argentina", "Chile"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 3. Panama - Fix: "Panama City" contains-word
records.append({
    "word": "Panama",
    "category": "geography_places",
    "subcategory": "Panama",
    "difficulty": "hard",
    "description": "A Central American country with a vital interoceanic passage.",
    "tags": ["central", "american", "canal"],
    "hints": {
        "easy": ["Central American", "Isthmus country", "Tropical climate", "Capital city", "Pacific coast", "Caribbean port"],
        "medium": ["Canal waterway", "Ocean link", "Rainforest corridor", "Straw hat origin", "Bird diversity", "Economic hub"],
        "hard": ["Famous canal", "Ocean crossing", "Straw hats", "Rainforest", "Unique passage", "Global trade"]
    },
    "imposters": {
        "easy": ["Costa Rica", "Nicaragua"],
        "medium": ["Belize", "Honduras"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 4. Costa Rica - Fix: "Central American" and "Costa Rican peace" contain-word
records.append({
    "word": "Costa Rica",
    "category": "geography_places",
    "subcategory": "Costa Rica",
    "difficulty": "hard",
    "description": "A Central American nation known for biodiversity and peaceful neutrality.",
    "tags": ["central", "american", "biodiversity"],
    "hints": {
        "easy": ["Green country", "Peaceful neutrality", "Tropical paradise", "Pacific coast", "Cloud cover", "No army"],
        "medium": ["No standing army", "Pura vida philosophy", "High rainfall", "Sloths and toucans", "Volcanoes", "Eco-tourism"],
        "hard": ["Cloud forests", "Endemic species", "No military", "National peace", "Unique wildlife", "Protected areas"]
    },
    "imposters": {
        "easy": ["Panama", "El Salvador"],
        "medium": ["Belize", "Guatemala"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 5. Guatemala - Fix: "Guatemala City" contains-word
records.append({
    "word": "Guatemala",
    "category": "geography_places",
    "subcategory": "Guatemala",
    "difficulty": "hard",
    "description": "A Central American nation featuring ancient Mayan civilization.",
    "tags": ["central", "american", "mayan"],
    "hints": {
        "easy": ["Mayan heritage", "Volcanoes", "Highlands region", "Capital city", "Lake surface", "Tikal ruins"],
        "medium": ["Mayan ruins", "Colorful textiles", "Volcano lakes", "Quetzal bird", "Indigenous culture", "Pacific coast"],
        "hard": ["Ancient temples", "Textile crafts", "Mountain lakes", "National bird", "Pre-Columbian", "Cultural heritage"]
    },
    "imposters": {
        "easy": ["Honduras", "El Salvador"],
        "medium": ["Mexico", "Belize"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 6. Honduras - OK (has warning but that's acceptable)
records.append({
    "word": "Honduras",
    "category": "geography_places",
    "subcategory": "Honduras",
    "difficulty": "hard",
    "description": "A Central American nation with Caribbean coastline and Pacific ports.",
    "tags": ["central", "american", "caribbean"],
    "hints": {
        "easy": ["Central American", "Caribbean coast", "Pacific ports", "Northern mountains", "Tegucigalpa", "Banana exports"],
        "medium": ["Mayan ruins", "Coral reefs", "Banana industry", "Hurricane path", "Copán ruins", "Regional hub"],
        "hard": ["Banana plantations", "Rainforest canopy", "Historic site", "Storm tracks", "Economic resource", "Coastal access"]
    },
    "imposters": {
        "easy": ["Guatemala", "Nicaragua"],
        "medium": ["Belize", "El Salvador"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 7. Haiti - Fix: Dominican Republic leaks "Republic" through hints, use different medium imposter
records.append({
    "word": "Haiti",
    "category": "geography_places",
    "subcategory": "Haiti",
    "difficulty": "hard",
    "description": "A Caribbean island nation sharing Hispaniola with its eastern neighbor.",
    "tags": ["caribbean", "island", "nation"],
    "hints": {
        "easy": ["Caribbean island", "French creole", "Port-au-Prince", "Black republic", "Island share", "Spanish colony"],
        "medium": ["Revolution history", "Vibrant art", "Mountain highlands", "Cultural blend", "Deforestation issues", "Independence triumph"],
        "hard": ["First republic", "Artistic culture", "Terrain challenges", "Historical significance", "Resilient people", "Economic struggles"]
    },
    "imposters": {
        "easy": ["Cuba", "Jamaica"],
        "medium": ["Puerto Rico", "Bahamas"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 8. Bahamas - OK (has warning but acceptable)
records.append({
    "word": "Bahamas",
    "category": "geography_places",
    "subcategory": "Bahamas",
    "difficulty": "hard",
    "description": "An island chain in the Caribbean with turquoise waters and historic salt ponds.",
    "tags": ["caribbean", "island", "chain"],
    "hints": {
        "easy": ["Caribbean islands", "Turquoise waters", "Nassau capital", "British territory", "Archipelago", "Atlantic outpost"],
        "medium": ["Swimming pigs", "Pink sand beaches", "Coral reefs", "Straw market", "Maritime history", "Sunny climate"],
        "hard": ["Pink sand shores", "Barrier reef", "Salt ponds", "Freedom trading", "Tropical paradise", "Marine ecosystem"]
    },
    "imposters": {
        "easy": ["Jamaica", "Cuba"],
        "medium": ["Dominican Republic", "Bermuda"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 9. Barbados - Fix: "Rum production" is blocklisted
records.append({
    "word": "Barbados",
    "category": "geography_places",
    "subcategory": "Barbados",
    "difficulty": "hard",
    "description": "A Caribbean island nation with rugged terrain and sugarcane fields.",
    "tags": ["caribbean", "island", "nation"],
    "hints": {
        "easy": ["Caribbean island", "Eastern Caribbean", "Bridgetown", "British colony", "Tropical island", "Cultural festival"],
        "medium": ["Cricket passion", "Flying fish cuisine", "Sugarcane economy", "Distilled spirits", "Independence day", "Parliamentary"],
        "hard": ["Fish cuisine", "Cane fields", "Cricket stadium", "Cultural festivals", "Naval base", "Distinctive flag"]
    },
    "imposters": {
        "easy": ["Jamaica", "Trinidad"],
        "medium": ["Cuba", "Bahamas"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# 10. Lithuania - Fix: "Lithuanian language" contains-word
records.append({
    "word": "Lithuania",
    "category": "geography_places",
    "subcategory": "Lithuania",
    "difficulty": "hard",
    "description": "A Baltic nation bordered by three countries and with a long coastline.",
    "tags": ["baltic", "european", "nation"],
    "hints": {
        "easy": ["Baltic state", "European union", "Vilnius capital", "Southeast coast", "Amber coast", "Hill of crosses"],
        "medium": ["Basketball fervor", "Amber jewelry", "Grand duchy", "Native language", "National anthem", "Forest country"],
        "hard": ["Amber treasures", "Medieval state", "Coastal regions", "Ancient heritage", "National symbols", "Historical legacy"]
    },
    "imposters": {
        "easy": ["Latvia", "Estonia"],
        "medium": ["Poland", "Belarus"],
        "hard": ["China", "Japan", "France", "Italy"]
    }
})

# Write records
output_path = "tool/words/src/countries/gen003.json"
with open(output_path, "w", encoding="utf8") as f:
    json.dump(records, f, indent=1, ensure_ascii=False)

print(f"Wrote {len(records)} records to {output_path}")

# Validate
errors = 0
for i, r in enumerate(records):
    errs, warns = validate_record(r, cats, lists)
    if errs:
        print(f"Record {i} ({r['word']}): ERRORS:")
        for e in errs:
            print(f"  - {e}")
        errors += 1
    else:
        print(f"Record {i} ({r['word']}): OK" + (f", warnings: {warns}" if warns else ""))

if errors == 0:
    print(f"\nAll {len(records)} records passed validation!")
else:
    print(f"\n{errors} records had errors. Fix before importing.")