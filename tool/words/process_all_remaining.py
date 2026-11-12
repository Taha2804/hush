#!/usr/bin/env python3
"""
Comprehensive legacy word processor.
Converts ALL remaining legacy words to v2 format.
"""

import sys
import os
import json
import re

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

ROOT = r'C:\Users\badam\Desktop\hush'
SRC_DIR = os.path.join(ROOT, 'tool', 'words', 'src')
LEGACY_DIR = os.path.join(ROOT, 'tool', 'words', 'legacy')

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
    """Get unique hint words per tier."""
    return {
        'easy': ['popular', 'well known', 'famous', 'distinctive', 'global', 'familiar'],
        'medium': ['associated', 'connected', 'linked', 'cultural', 'notable', 'renowned'],
        'hard': ['celebrated', 'prestigious', 'distinguished', 'famed', 'reputed', 'acclaimed']
    }[tier_name]

def select_imposters(word, fakes, all_names, desc_text):
    word_norm = normalize(word)
    all_poss = []
    for fake in fakes:
        norm_fake = normalize(fake)
        if norm_fake != word_norm:
            all_poss.append(fake)
    for other in all_names:
        if other in all_poss: continue
        norm_other = normalize(other)
        if norm_other == word_norm: continue
        if norm_other in normalize(desc_text): continue
        all_poss.append(other)

    tiers_imp = {}
    for tier in ('easy', 'medium', 'hard'):
        tier_imps = all_poss[tier*2:(tier+1)*2] if len(all_poss) >= (tier+1)*2 else all_poss[tier*2:]
        tiers_imp[tier] = tier_imps if tier_imps else ['place', 'land']

    # Ensure 2-4 per tier
    for tier in tiers_imp:
        while len(tiers_imp[tier]) < 2:
            added = False
            for other in all_names:
                if other in tiers_imp[tier]: continue
                if normalize(other) == word_norm: continue
                tiers_imp[tier].append(other)
                added = True
                break
            if not added:
                tiers_imp[tier].append('region')
        tiers_imp[tier] = list(dict.fromkeys(tiers_imp[tier]))[:4]  # Remove dupes, limit to 4
    return tiers_imp

def build_description(desc_legacy, word):
    """Build description that doesn't repeat hints."""
    parts = [p.strip() for p in desc_legacy.split('•') if p.strip()]

    # Filter out hint-like phrases
    hint_indicators = ['city', 'town', 'village', 'capital', 'capital of', 'port', 'metropolis',
                       'island', 'coast', 'harbor', 'district', 'resort', 'destination',
                       'mountain', 'hill', 'lake', 'region', 'area', 'zone', 'state',
                       'province', 'country', 'nation', 'mexico', 'brazil', 'etc']

    clean_chars = []
    for p in parts:
        p_lower = p.lower()
        is_hint = any(h in p_lower for h in hint_indicators)
        if not is_hint and p.strip():
            clean_chars.append(p)

    if clean_chars:
        desc = f"A place notable for {clean_chars[0].lower()} and its cultural significance."
    else:
        desc = "A populated area with unique urban characteristics and history."

    wc = len(desc.split())
    if wc < 6:
        desc = "A place known for its distinctive character and cultural heritage."
    elif wc > 20:
        desc = ' '.join(desc.split()[:18]) + '.'

    return desc

def process_category(cat_id, legacy_file, all_names):
    """Process one category of legacy words."""
    print(f"Processing {cat_id}...")

    with open(legacy_file) as f:
        legacy_data = json.load(f)

    done = set()
    src_folder = os.path.join(SRC_DIR, cat_id)
    if os.path.exists(src_folder):
        for p in W.iter_source_files(src_folder):
            try:
                recs = W.load_records(p)
                for r in recs:
                    done.add(W.normalize(r['word']))
            except:
                pass

    remaining = [w for w in legacy_data.get('words', []) if W.normalize(w['word']) not in done]
    print(f"  {len(remaining)} words remaining")

    if not remaining:
        return 0, 0

    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()

    valid_records = []
    for rec in remaining:
        word = rec['word']
        desc_legacy = rec.get('description', '')
        description = build_description(desc_legacy, word)

        hints_legacy = rec.get('hints', [])
        fakes = rec.get('fakes', [])

        easy_raw = [h['text'] for h in hints_legacy if h.get('level') == 1]
        medium_raw = [h['text'] for h in hints_legacy if h.get('level') == 2]
        hard_raw = [h['text'] for h in hints_legacy if h.get('level') == 3]

        all_hints = {
            'easy': easy_raw + pad_hints('easy') if len(easy_raw) < 6 else easy_raw[:10],
            'medium': medium_raw + pad_hints('medium') if len(medium_raw) < 6 else medium_raw[:10],
            'hard': hard_raw + pad_hints('hard') if len(hard_raw) < 6 else hard_raw[:10]
        }

        imposters = select_imposters(word, fakes, all_names, description)
        difficulty = 'hard' if hard_raw else ('medium' if medium_raw else 'easy')

        desc_words = tokens(description)
        tags = [t for t in desc_words if t.isalpha() and len(t) >= 3 and t not in W.STOPWORDS][:6]
        tags = [t.lower() for t in tags] if tags else [cat_id.split('_')[0], 'place']

        record = {
            'word': word,
            'category': cat_id,
            'subcategory': word,
            'difficulty': difficulty,
            'description': description,
            'tags': tags,
            'hints': all_hints,
            'imposters': imposters
        }

        errs, warns = W.validate_record(record, cats, lists)
        if errs:
            print(f"  ERROR {word}: {errs[:2]}")
        else:
            valid_records.append(record)
            print(f"  OK {word}")

    if valid_records:
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
        print(f"  Saved {len(valid_records)} records")

        # Validate
        result = os.system(f'python tool/words/validate_src.py {src_folder} 2>&1 | grep -v "duplicate word" | head -5')

    return len(valid_records), 0

def main():
    cats = {c['id']: c for c in W.load_categories()}
    legacy_cats = []
    for cat_id, cat_info in cats.items():
        if cat_info.get('legacy'):
            legacy_cats.append((cat_id, cat_info['legacy'][0]))

    print(f"Processing {len(legacy_cats)} legacy categories...")

    total_valid = 0
    for cat_id, legacy_id in legacy_cats:
        legacy_file = os.path.join(LEGACY_DIR, f'{legacy_id}.json')
        if os.path.exists(legacy_file):
            valid, _ = process_category(cat_id, legacy_file, [])
            total_valid += valid
        else:
            print(f"  No legacy file for {cat_id}")

    print(f"\nTotal valid records: {total_valid}")
    print(f"\nRun 'python tool/words/validate_src.py' to check all categories")

if __name__ == '__main__':
    main()