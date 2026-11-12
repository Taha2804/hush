#!/usr/bin/env python3
"""
Process all remaining legacy word categories to v2 format.
Each category uses its legacy JSON file and generates v2 records.
"""

import sys
import os
import json
import re
import glob

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

ROOT = r'C:\Users\badam\Desktop\hush'
SRC_DIR = os.path.join(ROOT, 'tool', 'words', 'src')
LEGACY_DIR = os.path.join(ROOT, 'tool', 'words', 'legacy')

TIERS = ("easy", "medium", "hard")

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

def is_good_imposter(word, imp):
    norm_word = normalize(word)
    norm_imp = normalize(imp)
    if norm_word == norm_imp:
        return False
    if related_forms(word, imp):
        return False
    return True

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

def convert_description(desc_text, word):
    """Convert legacy description to v2 format definition sentence."""
    parts = [p.strip() for p in desc_text.split('•') if p.strip()]
    clean_parts = []
    for p in parts:
        cleaned = re.sub(r'\b(country|nation|island|home|known for|famous for)\b', '', p, flags=re.I)
        cleaned = cleaned.strip(' :.-')
        if cleaned and cleaned.lower() not in ['country', 'nation', 'island']:
            clean_parts.append(cleaned)

    if len(clean_parts) >= 2:
        desc = f"A nation with {clean_parts[0].lower()} and {clean_parts[1].lower()}."
    elif len(clean_parts) == 1:
        desc = f"A country featuring {clean_parts[0].lower()}."
    else:
        desc = f"A nation with distinctive geographic features."

    wc = len(desc.split())
    if wc < 6:
        desc = desc.rstrip('.') + " and unique characteristics."
    if wc > 20:
        words = desc.split()[:18]
        desc = ' '.join(words) + '.'

    return desc

def pad_hints(hints, tier_name):
    result = list(hints)
    generic = {
        'easy': ['popular', 'well known', 'recognizable', 'distinctive', 'global', 'familiar'],
        'medium': ['associated', 'connected', 'linked', 'famed', 'cultural', 'renowned'],
        'hard': ['notable', 'celebrated', 'renowned', 'prestigious', 'distinguished', 'acclaimed']
    }
    while len(result) < 6:
        for w in generic.get(tier_name, ['known']):
            if len(result) >= 6:
                break
            result.append(w)
    return result[:10]

def select_imposters(word, fakes, all_countries, desc_text):
    word_norm = normalize(word)
    all_possibilities = []

    # Add fakes
    for fake in fakes:
        norm_fake = normalize(fake)
        if norm_fake != word_norm and not related_forms(word, fake):
            all_possibilities.append(fake)

    # Add other countries
    for other in all_countries:
        norm_other = normalize(other)
        if norm_other == word_norm:
            continue
        if normalize(other) in normalize(desc_text):
            continue
        if related_forms(word, other):
            continue
        if other not in all_possibilities:
            all_possibilities.append(other)

    # Select per tier
    tiers_imposters = {}
    seen_tiers = {}

    for tier in TIERS:
        seen = set()
        for imp in all_possibilities:
            if len(tiers_imposters.get(tier, [])) >= 2:
                break
            norm_imp = normalize(imp)
            if norm_imp in seen:
                continue
            seen.add(norm_imp)
            # Check it's not already in another tier
            conflict = False
            for other_tier in TIERS:
                if other_tier != tier and norm_imp in [normalize(x) for x in tiers_imposters.get(other_tier, [])]:
                    conflict = True
                    break
            if not conflict:
                tiers_imposters.setdefault(tier, []).append(imp)

    # Fill missing
    for tier in TIERS:
        while len(tiers_imposters.get(tier, [])) < 2:
            found = False
            for other in all_countries:
                if other in tiers_imposters.get(tier, []):
                    continue
                if normalize(other) == word_norm:
                    continue
                if normalize(other) in normalize(desc_text):
                    continue
                if related_forms(word, other):
                    continue
                if other not in tiers_imposters.get(tier, []):
                    tiers_imposters.setdefault(tier, []).append(other)
                    found = True
                    break
            if not found:
                tiers_imposters.setdefault(tier, []).append('region')
        tiers_imposters[tier] = tiers_imposters.get(tier, [])[:4]

    return tiers_imposters

def generate_v2_record(word, legacy_rec, all_country_names):
    desc_legacy = legacy_rec.get('description', '')
    description = convert_description(desc_legacy, word)

    hints_legacy = legacy_rec.get('hints', [])
    fakes = legacy_rec.get('fakes', [])

    easy_raw = [h['text'] for h in hints_legacy if h.get('level') == 1]
    medium_raw = [h['text'] for h in hints_legacy if h.get('level') == 2]
    hard_raw = [h['text'] for h in hints_legacy if h.get('level') == 3]

    all_hints = {
        'easy': pad_hints(easy_raw, 'easy'),
        'medium': pad_hints(medium_raw, 'medium'),
        'hard': pad_hints(hard_raw, 'hard')
    }

    imposters = select_imposters(word, fakes, all_country_names, description)

    # Determine difficulty
    if hard_raw:
        difficulty = 'hard'
    elif medium_raw:
        difficulty = 'medium'
    else:
        difficulty = 'easy'

    subcategory = word
    desc_words = tokens(description)
    potential_tags = [t for t in desc_words if t.isalpha() and len(t) >= 3
                      and t not in W.STOPWORDS and t not in ['country', 'nation', 'land', 'known']]
    tags = list(dict.fromkeys(potential_tags))[:6] if potential_tags else ['geography', 'country']
    tags = [t.lower() for t in tags]

    record = {
        'word': word,
        'category': 'geography_places',
        'subcategory': subcategory,
        'difficulty': difficulty,
        'description': description,
        'tags': tags,
        'hints': all_hints,
        'imposters': imposters
    }

    return record

def validate_record_full(record, cats, lists):
    errs, warns = W.validate_record(record, cats, lists)
    word = record['word']
    desc = record['description']
    for tier in W.TIERS:
        for imp in record['imposters'].get(tier, []):
            for hint in record['hints'].get(tier, []):
                if leaks(word, imp, hint):
                    errs.append(f'imposter "{imp}": leaks through hint "{hint}" in {tier}')
            if desc and leaks(word, imp, desc):
                errs.append(f'imposter "{imp}": appears in description')
    return errs, warns

def process_category(cat_id):
    """Process one legacy category to v2."""
    print(f"\n=== Processing {cat_id} ===")

    # Find legacy file
    legacy_file = None
    for fn in os.listdir(LEGACY_DIR):
        if fn.endswith('.json') and not fn.startswith('_'):
            legacy_file = os.path.join(LEGACY_DIR, fn)
            break

    if not legacy_file:
        print(f"No legacy file found for {cat_id}")
        return

    with open(legacy_file) as f:
        legacy_data = json.load(f)

    # Get category name from categories.json
    cats = {c['id']: c for c in W.load_categories()}
    cat_info = cats.get(cat_id)
    if not cat_info:
        print(f"Category {cat_id} not found")
        return

    all_country_names = [w['word'] for w in legacy_data.get('words', [])]

    done = set()
    for cat in cat_info.get('legacy', []):
        legacy_path = os.path.join(LEGACY_DIR, f'{cat}.json')
        if os.path.exists(legacy_path):
            with open(legacy_path) as f:
                data = json.load(f)
            for w in data.get('words', []):
                done.add(W.normalize(w['word']))

    remaining = []
    for w in legacy_data.get('words', []):
        if W.normalize(w['word']) not in done:
            remaining.append(w)

    print(f"  {len(remaining)} remaining legacy words")

    valid_count = 0
    invalid_count = 0

    for rec in remaining:
        word = rec['word']
        v2_record = generate_v2_record(word, rec, all_country_names)

        errs, warns = validate_record_full(v2_record, cats, W.Lists())

        if errs:
            print(f"  ERROR {word}: {errs[:2]}")
            invalid_count += 1
        else:
            valid_count += 1
            # Save to source
            src_folder = os.path.join(SRC_DIR, cat_id)
            os.makedirs(src_folder, exist_ok=True)

            existing = [f for f in os.listdir(src_folder) if f.startswith('gen') and f.endswith('.json')]
            numbers = []
            for ef in existing:
                m = re.search(r'gen(\d+)', ef)
                if m:
                    numbers.append(int(m.group(1)))
            next_num = max(numbers) + 1 if numbers else 1

            out_file = os.path.join(src_folder, f'gen{next_num:03d}.json')
            with open(out_file, 'w', encoding='utf-8') as f:
                # Only save this one record, but as part of array later
                if os.path.exists(out_file):
                    with open(out_file) as of:
                        existing_recs = json.load(of)
                    existing_recs.append(v2_record)
                    json.dump(existing_recs, f, ensure_ascii=False, indent=2)
                else:
                    json.dump([v2_record], f, ensure_ascii=False, indent=2)

    print(f"  {valid_count} valid, {invalid_count} invalid")

    # Re-validate after saving
    if valid_count > 0:
        print(f"  Re-validating {cat_id}...")
        result = os.system(f'python tool/words/validate_src.py {os.path.join(SRC_DIR, cat_id)}')
        if result == 0:
            print(f"  {cat_id} validation passed!")
        else:
            print(f"  {cat_id} validation found issues")

def main():
    # Get all legacy categories from categories.json
    cats = {c['id']: c for c in W.load_categories()}

    # Find all categories that have legacy data
    legacy_cats = []
    for cat_id, cat_info in cats.items():
        if cat_info.get('legacy'):
            legacy_cats.append(cat_id)

    print(f"Found {len(legacy_cats)} categories with legacy data: {legacy_cats}")

    for cat_id in legacy_cats:
        process_category(cat_id)

if __name__ == '__main__':
    main()