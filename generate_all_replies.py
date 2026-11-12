#!/usr/bin/env python3
"""
Generate all remaining v2 word records for Hushbug.
Processes each prompt file in tool/words/prompts/ and writes validated
replies to tool/words/replies/.
"""
import json
import os
import re
import sys

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

PROMPTS_DIR = r'C:\Users\badam\Desktop\hush\tool\words\prompts'
REPLIES_DIR = r'C:\Users\badam\Desktop\hush\tool\words\replies'

# Map prompt filename -> category ID
PROMPT_TO_CAT = {
    # technology (already done 001-021)
    '022_technology.txt': 'science_technology',
    '023_technology.txt': 'science_technology',
    # countries
    '024_countries.txt': 'geography_places',
    '025_countries.txt': 'geography_places',
    '026_countries.txt': 'geography_places',
    '027_countries.txt': 'geography_places',
    # cities
    '028_cities.txt': 'geography_places',
    '029_cities.txt': 'geography_places',
    '030_cities.txt': 'geography_places',
    '031_cities.txt': 'geography_places',
    # places
    '032_places.txt': 'geography_places',
    '033_places.txt': 'geography_places',
    '034_places.txt': 'geography_places',
    '035_places.txt': 'geography_places',
    # movies
    '036_movies.txt': 'movies_entertainment',
    '037_movies.txt': 'movies_entertainment',
    '038_movies.txt': 'movies_entertainment',
    '039_movies.txt': 'movies_entertainment',
    # sports
    '040_sports.txt': 'sports_games',
    '041_sports.txt': 'sports_games',
    '042_sports.txt': 'sports_games',
    '043_sports.txt': 'sports_games',
    # hobbies
    '044_hobbies.txt': 'hobbies_leisure',
    '045_hobbies.txt': 'hobbies_leisure',
    '046_hobbies.txt': 'hobbies_leisure',
    '047_hobbies.txt': 'hobbies_leisure',
    # household
    '048_household.txt': 'everyday_objects',
    '049_household.txt': 'everyday_objects',
    '050_household.txt': 'everyday_objects',
    '051_household.txt': 'everyday_objects',
    # clothing
    '052_clothing.txt': 'everyday_objects',
    '053_clothing.txt': 'everyday_objects',
    '054_clothing.txt': 'everyday_objects',
    '055_clothing.txt': 'everyday_objects',
    # jobs
    '056_jobs.txt': 'professions_jobs',
    '057_jobs.txt': 'professions_jobs',
    '058_jobs.txt': 'professions_jobs',
    '059_jobs.txt': 'professions_jobs',
    # holidays
    '060_holidays.txt': 'history_culture',
    '061_holidays.txt': 'history_culture',
    '062_holidays.txt': 'history_culture',
    '063_holidays.txt': 'history_culture',
    # nature
    '064_nature.txt': 'nature_environment',
    '065_nature.txt': 'nature_environment',
    '066_nature.txt': 'nature_environment',
    '067_nature.txt': 'nature_environment',
    # transport
    '068_transport.txt': 'vehicles_transport',
    '069_transport.txt': 'vehicles_transport',
    '070_transport.txt': 'vehicles_transport',
    '071_transport.txt': 'vehicles_transport',
    '072_transport.txt': 'vehicles_transport',
    '073_transport.txt': 'vehicles_transport',
    '074_transport.txt': 'vehicles_transport',
    '075_transport.txt': 'vehicles_transport',
    # instruments
    '076_instruments.txt': 'music_art',
    '077_instruments.txt': 'music_art',
    '078_instruments.txt': 'music_art',
    '079_instruments.txt': 'music_art',
    # mythical
    '080_mythical.txt': 'mythology_fiction',
    '081_mythical.txt': 'mythology_fiction',
    '082_mythical.txt': 'mythology_fiction',
    '083_mythical.txt': 'mythology_fiction',
    '084_mythical.txt': 'mythology_fiction',
    '085_mythical.txt': 'mythology_fiction',
    # body_health
    '086_body_health.txt': 'body_health',
    '087_body_health.txt': 'body_health',
    '088_body_health.txt': 'body_health',
    '089_body_health.txt': 'body_health',
    # school
    '090_school.txt': 'education_knowledge',
    '091_school.txt': 'education_knowledge',
    '092_school.txt': 'education_knowledge',
    '093_school.txt': 'education_knowledge',
    # landmarks
    '094_landmarks.txt': 'travel_tourism',
    '095_landmarks.txt': 'travel_tourism',
    '096_landmarks.txt': 'travel_tourism',
    '097_landmarks.txt': 'travel_tourism',
}

def parse_prompt(filepath):
    """Extract words and old imposter suggestions from a prompt file."""
    with open(filepath, encoding='utf8') as f:
        content = f.read()
    # Find the word list section
    words = []
    for line in content.split('\n'):
        m = re.match(r'^- (.+?) \(old imposter words, reuse only if they fit the rules: (.+?)\)', line)
        if m:
            word = m.group(1).strip()
            imposters = [i.strip() for i in m.group(2).split(',')]
            words.append({'word': word, 'old_imposters': imposters})
    return words

def generate_records(words, category):
    """Generate v2 records for the given words and category."""
    # Subcategory mapping based on category
    subcat_map = {
        'science_technology': {
            'Electric razor': 'Appliances',
            'Hearing aid': 'Medical',
            'Pacemaker': 'Medical',
            'Antenna': 'Electronics',
            'Satellite dish': 'Electronics',
            'Cable': 'Electronics',
            'Plug': 'Electronics',
            'Switch': 'Electronics',
            'Thermostat': 'Home Automation',
            'Alarm system': 'Home Security',
            'Security camera': 'Home Security',
            'Doorbell camera': 'Home Security',
            'Gaming laptop': 'Computing',
            'Stylus': 'Computing',
            'Graphics tablet': 'Computing',
            'Keycaps': 'Computing',
            'Smart glasses': 'Wearables',
            'Headset': 'Audio',
            'Charging cable': 'Electronics',
            'Adapter': 'Electronics',
            'Drone': 'Robotics',
            '3d printer': 'Manufacturing',
            'Smartwatch': 'Wearables',
            'E reader': 'Computing',
            'Bluetooth': 'Electronics',
            'Wifi': 'Electronics',
            'Fiber optics': 'Electronics',
            'Hard disk': 'Storage',
            'Ethernet': 'Electronics',
            'Semiconductor': 'Electronics',
            'Pixel art': 'Graphics',
            'Emulator': 'Computing',
            'Bookmark': 'Computing',
            'Hashtag': 'Internet',
        },
        'geography_places': {},
        'movies_entertainment': {},
        'sports_games': {},
        'hobbies_leisure': {},
        'everyday_objects': {},
        'professions_jobs': {},
        'history_culture': {},
        'nature_environment': {},
        'vehicles_transport': {},
        'music_art': {},
        'mythology_fiction': {},
        'body_health': {},
        'education_knowledge': {},
        'travel_tourism': {},
    }

    # Difficulty heuristics
    def guess_difficulty(word):
        common_easy = ['car', 'bus', 'train', 'plane', 'phone', 'book', 'game', 'food', 'water', 'dog', 'cat']
        w = word.lower()
        if any(w.startswith(e) for e in common_easy) or len(w) <= 6:
            return 'easy'
        if len(w) > 12:
            return 'hard'
        return 'medium'

    recs = []
    for w in words:
        word = w['word']
        subcat = subcat_map.get(category, {}).get(word, 'General')
        diff = guess_difficulty(word)

        # Create a basic record structure - this is a template
        # In reality, we need custom content per word
        rec = {
            "word": word,
            "category": category,
            "subcategory": subcat,
            "difficulty": diff,
            "description": f"A placeholder description for {word}.",
            "tags": [category.replace('_', '')],
            "hints": {
                "easy": ["hint one", "hint two", "hint three", "hint four", "hint five", "hint six"],
                "medium": ["hint one", "hint two", "hint three", "hint four", "hint five", "hint six"],
                "hard": ["hint one", "hint two", "hint three", "hint four", "hint five", "hint six"],
            },
            "imposters": {
                "easy": ["imposter one", "imposter two"],
                "medium": ["imposter one", "imposter two"],
                "hard": ["imposter one", "imposter two"],
            }
        }
        recs.append(rec)
    return recs

def main():
    os.makedirs(REPLIES_DIR, exist_ok=True)

    total_words = 0
    for fname, cat in PROMPT_TO_CAT.items():
        fpath = os.path.join(PROMPTS_DIR, fname)
        if not os.path.exists(fpath):
            continue
        words = parse_prompt(fpath)
        if not words:
            continue
        total_words += len(words)
        print(f'{fname}: {len(words)} words -> {cat}')

    print(f'Total: {total_words} words to process')
    # This is a template - actual generation needs custom content per word
    print('This script is a template. Need to implement per-word content generation.')

if __name__ == '__main__':
    main()