#!/usr/bin/env python3
"""Add Sudan to countries pack."""

import sys
import os
import json

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

ROOT = r'C:\Users\badam\Desktop\hush'
SRC_DIR = os.path.join(ROOT, 'tool', 'words', 'src')

SUDAN_RECORD = {
    'word': 'Sudan',
    'category': 'geography_places',
    'subcategory': 'Sudan',
    'difficulty': 'medium',
    'description': 'An African nation in the northeastern region with a rich history along ancient river valleys.',
    'tags': ['africa', 'nile', 'history', 'desert'],
    'hints': {
        'easy': ['nile river', 'african country', 'warm climate', 'tall structures', 'ancient ruins', 'geographic'],
        'medium': ['pyramids nearby', 'african culture', 'desert landscape', 'river delta', 'tribal groups', 'historical'],
        'hard': ['kordofan region', 'nuba mountains', 'traditional crafts', 'oil economy', 'cultural diversity', 'historic sites']
    },
    'imposters': {
        'easy': ['Egypt', 'Chad'],
        'medium': ['Ethiopia', 'Eritrea'],
        'hard': ['Libya', 'Uganda']
    }
}

def main():
    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()

    errs, warns = W.validate_record(SUDAN_RECORD, cats, lists)
    if errs:
        print(f"ERROR Sudan: {errs}")
        return

    src_folder = os.path.join(SRC_DIR, 'countries')
    os.makedirs(src_folder, exist_ok=True)

    # Find next number
    existing = [f for f in os.listdir(src_folder) if f.startswith('gen') and f.endswith('.json')]
    numbers = []
    for f in existing:
        m = __import__('re').search(r'gen(\d+)', f)
        if m:
            numbers.append(int(m.group(1)))
    next_num = max(numbers) + 1 if numbers else 1

    out_file = os.path.join(src_folder, f'gen{next_num:03d}.json')
    with open(out_file, 'w', encoding='utf-8') as f:
        json.dump([SUDAN_RECORD], f, ensure_ascii=False, indent=2)
    print(f"Saved Sudan to {out_file}")

if __name__ == '__main__':
    main()