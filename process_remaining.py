import subprocess
import os
import json
import sys

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

# Categories and their source files
categories = {
    'countries': 'geography_places',
    'cities': 'geography_places',
    'places': 'geography_places',
    'movies': 'movies_entertainment',
    'sports': 'sports_games',
    'hobbies': 'hobbies_leisure',
    'household': 'everyday_objects',
    'clothing': 'everyday_objects',
    'jobs': 'professions_jobs',
    'holidays': 'history_culture',
    'nature': 'nature_environment',
    'transport': 'vehicles_transport',
    'instruments': 'music_art',
    'mythical': 'mythology_fiction',
    'body_health': 'body_health',
    'school': 'education_knowledge',
    'landmarks': 'travel_tourism',
}

src_dir = r'C:\Users\badam\Desktop\hush\tool\words\src'

# Get all part files
part_files = []
for cat in categories:
    cat_dir = os.path.join(src_dir, cat)
    if os.path.exists(cat_dir):
        for f in os.listdir(cat_dir):
            if f.startswith('part') and f.endswith('.json'):
                part_files.append((cat, os.path.join(cat_dir, f)))

part_files.sort()

print(f"Found {len(part_files)} part files to process")
for i, (cat, f) in enumerate(part_files, 1):
    print(f"{i:2d}. {cat} -> {f}")