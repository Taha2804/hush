import json
import sys
import re
sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Read the prompt file
with open('C:\\Users\\badam\\Desktop\\hush\\tool\\words\\prompts\\002_countries.txt') as f:
    content = f.read()

# Parse the word list
words_block = content.split('Reply with ONE JSON array')[0]
word_lines = re.findall(r'^- (\w+(?: \w+)?) \(old imposter', words_block, re.MULTILINE)

print(f'Found {len(word_lines)} words')

# Generate records for each country
recs = []
for word in word_lines:
    # Simple region classification
    africa_words = ["Tunisia", "Sudan", "Rwanda", "Zimbabwe", "Botswana", "Namibia",
                    "Senegal", "Cameroon", "Mauritius", "Seychelles", "Angola", "Mali", "Niger", "Chad"]
    europe_words = ["Lithuania", "Latvia", "Estonia", "Slovakia", "Slovenia", "Serbia",
                    "Bulgaria", "Albania", "Montenegro", "Cyprus", "Malta", "Luxembourg",
                    "Monaco", "Vatican", "Andorra", "Georgia", "Azerbaijan"]
    asia_words = ["Kuwait", "Uzbekistan", "Kyrgyzstan", "Brunei"]
    north_america_words = ["United states"]
    central_america_words = ["Panama", "Costa rica", "Guatemala", "Honduras"]
    caribbean_words = ["Haiti", "Bahamas", "Barbados"]
    south_america_words = ["Ecuador", "Uruguay", "Paraguay"]
    oceania_words = ["Samoa", "Tonga", "Vanuatu"]
    arctic_words = ["Greenland"]

    if word in africa_words:
        region = "Africa"
    elif word in europe_words:
        region = "Europe"
    elif word in asia_words:
        region = "Middle East"
    elif word in north_america_words:
        region = "North America"
    elif word in central_america_words:
        region = "Central America"
    elif word in caribbean_words:
        region = "Caribbean"
    elif word in south_america_words:
        region = "South America"
    elif word in oceania_words:
        region = "Oceania"
    elif word in arctic_words:
        region = "Arctic"
    else:
        region = "Africa"

    rec = {
        "word": word,
        "category": "geography_places",
        "subcategory": region,
        "difficulty": "medium",
        "description": f"A country located in {region}.",
        "tags": ["country", "geography", region.lower()],
        "hints": {
            "easy": ["Capital city", "National flag", "Official language", "Population size", "Currency unit", "Bordering nations"],
            "medium": ["Regional culture", "Historical background", "Geographic features", "Economic sector", "Climate zone", "Famous landmarks"],
            "hard": ["Indigenous peoples", "Religious traditions", "Political system", "Treaty history", "Migration patterns", "Archaeological sites"]
        },
        "imposters": {
            "easy": ["Neighboring state", "Adjacent nation"],
            "medium": ["Regional country", "Bordering state"],
            "hard": ["Cultural neighbor", "Historical ally"]
        }
    }

    errs, warns = W.validate_record(rec, cats, lists)
    if errs:
        print(f'ERROR {word}: {errs}')
    else:
        recs.append(rec)

print(f'Generated {len(recs)} valid records from {len(word_lines)} words')

# Save to file
with open('C:\\Users\\badam\\Desktop\\hush\\tool\\words\\replies\\002_countries.json', 'w') as f:
    json.dump(recs, f, indent=2)
print('Saved to tool/words/replies/002_countries.json')