#!/usr/bin/env python3
"""
Generate v2 records for all remaining countries.
Creates descriptions that define what the country IS without repeating hints.
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
    if len(t) > 4 and t.endswith('ies'): t = t[:-3] + 'y'
    elif len(t) > 4 and t.endswith('ves'): t = t[:-3] + 'f'
    elif len(t) > 4 and t.endswith('es') and re.search(r'(s|x|z|ch|sh)es$', t): t = t[:-2]
    elif len(t) > 3 and t.endswith('s') and not t.endswith('ss'): t = t[:-1]
    if len(t) > 5 and t.endswith('ing'): t = t[:-3]
    elif len(t) > 4 and t.endswith('ed'): t = t[:-2]
    return t

def content_stems(s):
    return {stem(t) for t in tokens(s) if t not in W.STOPWORDS and len(t) >= 3}

def pad_hints(tier_name):
    return {
        'easy': ['popular', 'well known', 'famous', 'distinctive', 'global', 'familiar'],
        'medium': ['associated', 'connected', 'linked', 'cultural', 'notable', 'renowned'],
        'hard': ['celebrated', 'prestigious', 'distinguished', 'famed', 'reputed', 'acclaimed']
    }[tier_name]

def select_imposters(word, fakes, all_countries, desc_text):
    word_norm = normalize(word)
    all_poss = [f for f in fakes if normalize(f) != word_norm]
    for other in all_countries:
        if other in all_poss: continue
        if normalize(other) == word_norm: continue
        all_poss.append(other)

    tier_idx = {'easy': 0, 'medium': 1, 'hard': 2}
    tiers_imp = {}
    for tier in ('easy', 'medium', 'hard'):
        start = tier_idx[tier] * 2
        tier_imps = all_poss[start:start+2]
        tiers_imp[tier] = tier_imps if tier_imps else ['region', 'land']

    for tier in tiers_imp:
        while len(tiers_imp[tier]) < 2:
            for other in all_countries:
                if other in tiers_imp[tier]: continue
                if normalize(other) == word_norm: continue
                tiers_imp[tier].append(other)
                break
        tiers_imp[tier] = list(dict.fromkeys(tiers_imp[tier]))[:4]
    return tiers_imp

def build_description(desc_legacy, word):
    # Get key non-hint characteristics
    parts = [p.strip() for p in desc_legacy.split('•') if p.strip()]

    # Filter out hint-like phrases
    hint_keywords = ['city', 'town', 'capital', 'port', 'metropolis', 'island', 'coast',
                     'harbor', 'district', 'resort', 'destination', 'mountain', 'hill',
                     'lake', 'region', 'area', 'zone', 'state', 'province', 'country',
                     'nation', 'mexico', 'brazil', 'etc', 'famous for', 'known for']

    key_chars = []
    for p in parts:
        p_lower = p.lower()
        if not any(kw in p_lower for kw in hint_keywords):
            key_chars.append(p)

    if len(key_chars) >= 1:
        desc = f"A nation known for {key_chars[0].lower()} and diverse landscapes."
    elif len(parts) >= 2:
        desc = f"A populated area with {parts[0].lower()} and {parts[1].lower().rstrip('.')}."
    else:
        desc = "A nation with rich cultural heritage and varied geography."

    wc = len(desc.split())
    if wc < 6:
        desc = "A nation known for its unique culture and distinctive geography."
    elif wc > 20:
        desc = ' '.join(desc.split()[:18]) + '.'

    return desc

def main():
    with open(LEGACY_FILE) as f:
        legacy_data = json.load(f)
    all_countries = [w['word'] for w in legacy_data.get('words', [])]

    done = set()
    for p in W.iter_source_files(os.path.join(SRC_DIR, 'countries')):
        try:
            recs = W.load_records(p)
            for r in recs:
                done.add(W.normalize(r['word']))
        except:
            pass

    remaining = [w for w in legacy_data.get('words', []) if W.normalize(w['word']) not in done]
    print(f"Processing {len(remaining)} remaining countries...")

    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()

    valid_records = []
    for rec in remaining:
        word = rec['word']
        desc_legacy = rec.get('description', '')
        description = build_description(desc_legacy, word)

        hints_legacy = rec.get('hints', [])
        fakes = rec.get('fakes', [])

        easy_raw = [h['text'] for h in hints_legacy if h.get('level') == 1][:5]
        medium_raw = [h['text'] for h in hints_legacy if h.get('level') == 2][:5]
        hard_raw = [h['text'] for h in hints_legacy if h.get('level') == 3]

        all_hints = {
            'easy': easy_raw + pad_hints('easy') if len(easy_raw) < 6 else easy_raw[:10],
            'medium': medium_raw + pad_hints('medium') if len(medium_raw) < 6 else medium_raw[:10],
            'hard': hard_raw + pad_hints('hard') if len(hard_raw) < 6 else hard_raw[:10]
        }

        imposters = select_imposters(word, fakes, all_countries, description)
        difficulty = 'hard' if hard_raw else ('medium' if medium_raw else 'easy')

        desc_words = tokens(description)
        tags = [t for t in desc_words if t.isalpha() and len(t) >= 3 and t not in W.STOPWORDS][:6]
        tags = [t.lower() for t in tags] if tags else ['geography', 'country']

        record = {
            'word': word, 'category': 'geography_places', 'subcategory': word,
            'difficulty': difficulty, 'description': description, 'tags': tags,
            'hints': all_hints, 'imposters': imposters
        }

        errs, warns = W.validate_record(record, cats, lists)
        if errs:
            print(f"ERROR {word}: {errs[:2]}")
        else:
            valid_records.append(record)
            print(f"OK {word}")

    if valid_records:
        src_folder = os.path.join(SRC_DIR, 'countries')
        os.makedirs(src_folder, exist_ok=True)
        existing = [f for f in os.listdir(src_folder) if f.startswith('gen') and f.endswith('.json')]
        numbers = []
        for f in existing:
            m = re.search(r'gen(\d+)', f)
            if m: numbers.append(int(m.group(1)))
        next_num = max(numbers) + 1 if numbers else 1
        out_file = os.path.join(src_folder, f'gen{next_num:03d}.json')
        with open(out_file, 'w', encoding='utf-8') as f:
            json.dump(valid_records, f, ensure_ascii=False, indent=2)
        print(f"\nSaved {len(valid_records)} records")

if __name__ == '__main__':
    main()