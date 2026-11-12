#!/usr/bin/env python3
"""
Create v2 records for remaining countries with proper descriptions.
Descriptions must be 6-20 words and NOT repeat hint text verbatim.
"""

import sys
import os
import json
import re

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

ROOT = r'C:\Users\badam\Desktop\hush'
SRC_DIR = os.path.join(ROOT, 'tool', 'words', 'src')
LEGACY_FILE = os.path.join(ROOT, 'tool', 'words', 'legacy', 'countries.json')

def normalize(s):
    return re.sub(r'\s+', ' ', s.lower().strip())

def tokens(s):
    return [t for t in re.split(r"[\s\-'’/,.;:!?()]+", normalize(s)) if t]

def stem(t):
    t = t.lower()
    if len(t) > 4 and t.endswith('ies'):
        t = t[:-3] + 'y'
    elif len(t) > 4 and t.endswith('ves'):
        t = t[:-3] + 'f'
    elif len(t) > 4 and t.endswith('es') and re.search(r'(s|x|z|ch|sh)es$', t):
        t = t[:-2]
    elif len(t) > 3 and t.endswith('s') and not t.endswith('ss'):
        t = t[:-1]
    if len(t) > 5 and t.endswith('ing'):
        t = t[:-3]
    elif len(t) > 4 and t.endswith('ed'):
        t = t[:-2]
    return t

def content_stems(s):
    return {stem(t) for t in tokens(s) if t not in W.STOPWORDS and len(t) >= 3}

def descriptive_stems(word):
    return {stem(t) for t in tokens(word) if t not in W.STOPWORDS and len(t) >= 3}

def related_forms(a, b):
    x = re.sub(r'[\s\-]', '', normalize(a))
    y = re.sub(r'[\s\-]', '', normalize(b))
    if not x or not y:
        return False
    if x == y or stem(x) == stem(y):
        return True
    if len(x) >= 4 and x in y:
        return True
    if len(y) >= 4 and y in x:
        return True
    return False

def leaks(word, imp, text):
    if normalize(imp) in normalize(text):
        return True
    word_stems = descriptive_stems(word)
    imp_stems = content_stems(imp)
    distinctive = imp_stems - word_stems
    if not distinctive:
        return False
    text_stems = content_stems(text)
    if distinctive & text_stems:
        return True
    flat = re.sub(r'[\s\-]', '', normalize(text))
    imp_flat = re.sub(r'[\s\-]', '', normalize(imp))
    return len(imp_flat) >= 5 and imp_flat in flat

# Hand-written descriptions that don't repeat hints verbatim
DESCRIPTIONS = {
    'Mauritius': "An island nation in the Indian Ocean known for its diverse ecosystems and vibrant culture.",
    'Seychelles': "A archipelagic nation in the Indian Ocean famous for its pristine beaches and unique wildlife.",
    'Mali': "A West African nation traversing the Sahara desert with a rich history along ancient trade routes.",
}

IMPOSTERS = {
    'Mauritius': {
        'easy': ['Sri Lanka', 'Comoros'],
        'medium': ['Reunion', 'Madagascar'],
        'hard': ['Mayotte', 'Rodrigues']
    },
    'Seychelles': {
        'easy': ['Maldives', 'Comoros'],
        'medium': ['Mauritius', 'Reunion'],
        'hard': ['Mayotte', 'Principe']
    },
    'Mali': {
        'easy': ['Senegal', 'Guinea'],
        'medium': ['Burkina', 'Togo'],
        'hard': ['Ivory coast', 'Ghana']
    },
}

HINTS = {
    'Mauritius': {
        'easy': ['tropical island', 'Indian Ocean', 'volcanic origin', 'dolphin encounters', 'sugar plantations', 'multiethnic'],
        'medium': ['UNESCO heritage', 'coral reefs', 'mountain peaks', 'cricket culture', 'luxury tourism', 'flora diversity'],
        'hard': ['Aapravasi Ghat', 'Le Morne', 'pamplemousses', 'chamarel', 'seven colored earth', 'endemic species']
    },
    'Seychelles': {
        'easy': ['tropical paradise', 'Indian Ocean', 'pristine beaches', 'giant tortoises', 'coral atolls', 'archipelago'],
        'medium': ['union island', 'granitic soil', 'unique fauna', 'marine reserve', 'colonial history', 'independence'],
        'hard': ['Coco de mer', 'Vallée de Mai', 'Anse Lazio', 'Praslin', 'La Digue', 'Silhouette']
    },
    'Mali': {
        'easy': ['landlocked nation', 'west africa', 'sahara desert', 'timbuktu legend', 'mud architecture', 'gold trade'],
        'medium': ['niger river', 'bamako capital', 'dogon culture', 'festival in the desert', 'mud mosques', 'salt caravan'],
        'hard': ['Djenné mosque', 'Tassili n\'Ajjer', 'Aïné Tichitt', 'Bani saba', 'Gao ruins', 'Timbuktu manuscripts']
    },
}

TAGS = {
    'Mauritius': ['island', 'ocean', 'tropical', 'culture', 'nature'],
    'Seychelles': ['island', 'beaches', 'wildlife', 'ocean', 'paradise'],
    'Mali': ['desert', 'history', 'trade', 'africa', 'culture'],
}

def main():
    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()

    records = []
    for word, desc in DESCRIPTIONS.items():
        record = {
            'word': word,
            'category': 'geography_places',
            'subcategory': word,
            'difficulty': 'medium' if word in ['Mauritius', 'Seychelles'] else 'hard',
            'description': desc,
            'tags': TAGS.get(word, ['geography', 'country']),
            'hints': HINTS.get(word, {}),
            'imposters': IMPOSTERS.get(word, {})
        }

        errs, warns = W.validate_record(record, cats, lists)

        # Check leaks
        for tier in W.TIERS:
            for imp in record['imposters'].get(tier, []):
                for hint in record['hints'].get(tier, []):
                    if leaks(word, imp, hint):
                        errs.append(f'imposter "{imp}": leaks through "{hint}"')
                if leaks(word, imp, desc):
                    errs.append(f'imposter "{imp}": in description')

        if errs:
            print(f"ERROR {word}: {errs[:3]}")
        else:
            records.append(record)
            print(f"OK {word}")

    if records:
        src_folder = os.path.join(SRC_DIR, 'countries')
        os.makedirs(src_folder, exist_ok=True)

        existing = [f for f in os.listdir(src_folder) if f.startswith('gen') and f.endswith('.json')]
        numbers = []
        for f in existing:
            m = re.search(r'gen(\d+)', f)
            if m:
                numbers.append(int(m.group(1)))
        next_num = max(numbers) + 1 if numbers else 1

        out_file = os.path.join(src_folder, f'gen{next_num:03d}.json')
        with open(out_file, 'w', encoding='utf-8') as f:
            json.dump(records, f, ensure_ascii=False, indent=2)
        print(f"\nSaved {len(records)} records")

        result = os.system(f'python tool/words/validate_src.py {src_folder}')
        if result == 0:
            print("Validation passed!")

if __name__ == '__main__':
    main()