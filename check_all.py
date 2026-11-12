#!/usr/bin/env python
import os
import json
import sys

ROOT = r'C:\Users\badam\Desktop\hush'
SRC_DIR = os.path.join(ROOT, 'tool', 'words', 'src')
REPLY_DIR = os.path.join(ROOT, 'tool', 'words', 'replies', 'done')

# Count total legacy words
total_legacy = 0
for cat in os.listdir(SRC_DIR):
    cat_dir = os.path.join(SRC_DIR, cat)
    if os.path.isdir(cat_dir):
        for f in os.listdir(cat_dir):
            if f.endswith('.json'):
                with open(os.path.join(cat_dir, f), 'r') as fp:
                    data = json.load(fp)
                    total_legacy += len(data)

# Count migrated words
total_migrated = 0
for f in os.listdir(REPLY_DIR):
    if f.endswith('.json'):
        with open(os.path.join(REPLY_DIR, f), 'r') as fp:
            data = json.load(fp)
            total_migrated += len(data)

# Count remaining in source (part files only)
total_in_part_files = 0
categories = ['countries', 'cities', 'places', 'movies', 'sports', 'hobbies',
              'household', 'clothing', 'jobs', 'holidays', 'nature', 'transport',
              'instruments', 'mythical', 'body_health', 'school', 'landmarks']

for cat in categories:
    cat_dir = os.path.join(SRC_DIR, cat)
    if os.path.exists(cat_dir):
        for f in os.listdir(cat_dir):
            if f.startswith('part') and f.endswith('.json'):
                with open(os.path.join(cat_dir, f), 'r') as fp:
                    data = json.load(fp)
                    total_in_part_files += len(data)

print(f"Total legacy words in source: {total_legacy}")
print(f"Total migrated records in replies: {total_migrated}")
print(f"Total in part files: {total_in_part_files}")
print(f"Remaining to migrate: {total_in_part_files}")
print(f"Migration progress: {total_migrated}/{total_legacy} = {100*total_migrated/total_legacy:.1f}%")