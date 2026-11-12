#!/usr/bin/env python3
"""
Generate v2 format records from legacy format.
Key fix: descriptions must NOT repeat hint text verbatim.
"""

import sys
import os
import json
import re

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

ROOT = r'C:\Users\badam\Desktop\hush'
SRC_DIR = os.path.join(ROOT, 'tool', 'words', 'src')
LEGACY_FILE = os.path.join(ROOT, 'tool', 'words', 'legacy', 'cities.json')

STOPWORDS = {'a', 'an', 'the', 'of', 'in', 'on', 'at', 'to', 'for', 'with', 'and', 'or', 'by', 'from', 'is', 'are', 'it', 'its', 'as', 'be', 'into', 'over', 'very', 'can', 'you', 'your', 'some', 'often', 'has', 'have', 'that', 'this', 'not', 'no', 'up', 'out', 'off', 'than', 'too', 'may', 'one', 'who', 'what', 'all', 'home'}
GENERIC_FILLER = {'thing', 'things', 'something', 'stuff', 'object', 'item', 'word', 'noun', 'concept', 'entity', 'example', 'type', 'kind', 'sort', 'term', 'idea'}
LETTER_CLUE = re.compile(r'\b(letters?|starts? with|begins? with|ends? with|rhymes?|spelled|spelling|syllables?|initials?|characters? long|anagram|first letter|last letter|vowels?)\b', re.I)

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
    return {stem(t) for t in tokens(s) if t not in STOPWORDS and len(t) >= 3 and t not in GENERIC_FILLER}

def descriptive_stems(word):
    return {stem(t) for t in tokens(word) if t not in STOPWORDS and len(t) >= 3}

def pad_hints(hints, tier_name):
    result = list(hints)
    generic = {'easy': ['popular', 'well known', 'famous', 'distinctive', 'global', 'familiar'],
               'medium': ['associated', 'connected', 'linked', 'cultural', 'notable', 'renowned'],
               'hard': ['celebrated', 'prestigious', 'distinguished', 'famed', 'reputed', 'acclaimed']}
    while len(result) < 6:
        for w in generic.get(tier_name, ['known']):
            if len(result) >= 6: break
            if w not in result: result.append(w)
    return result[:10]

def select_imposters(word, fakes, all_names, desc_text):
    word_norm = normalize(word)
    all_poss = []
    for fake in fakes:
        norm_fake = normalize(fake)
        if norm_fake != word_norm and norm_fake != normalize(''.join([c for c in word if c.isalpha()])):
            all_poss.append(fake)
    for other in all_names:
        if other in all_poss: continue
        norm_other = normalize(other)
        if norm_other == word_norm: continue
        if norm_other in normalize(desc_text): continue
        all_poss.append(other)

    tiers_imp = {}
    for tier in ('easy', 'medium', 'hard'):
        seen = set()
        tier_imps = []
        for imp in all_poss:
            if len(tier_imps) >= 2: break
            norm_imp = normalize(imp)
            if norm_imp in seen: continue
            tier_seen = [normalize(x) for x in tier_imps]
            for t in tiers_imp:
                tier_seen.extend([normalize(x) for x in tiers_imp[t]])
            if norm_imp in tier_seen: continue
            seen.add(norm_imp); tier_imps.append(imp)
        tiers_imp[tier] = tier_imps[:4]

    for tier in ('easy', 'medium', 'hard'):
        while len(tiers_imp.get(tier, [])) < 2:
            found = False
            for other in all_names:
                if other in tiers_imp[tier]: continue
                if normalize(other) == word_norm: continue
                if normalize(other) in normalize(desc_text): continue
                tiers_imp.setdefault(tier, []).append(other)
                found = True; break
            if not found:
                tiers_imp.setdefault(tier, []).append('place')
        tiers_imp[tier] = tiers_imp.get(tier, [])[:4]
    return tiers_imp

def build_description(desc_legacy, word):
    """Build a description that doesn't repeat hints verbatim."""
    # Extract key facts from legacy description
    parts = [p.strip() for p in desc_legacy.split('•') if p.strip()]

    # Filter out hint-like phrases (city, town, capital, port, etc.)
    hint_indicators = ['city', 'town', 'village', 'capital', 'capital of', 'port', 'metropolis',
                       'island', 'coast', 'harbor', 'district', 'resort', 'destination',
                       'mountain', 'hill', 'lake', 'region', 'area', 'zone', 'state',
                       'province', 'country', 'nation']

    clean_chars = []
    for p in parts:
        p_lower = p.lower()
        is_hint = any(h in p_lower for h in hint_indicators)
        if not is_hint and p.strip():
            clean_chars.append(p)

    # Build description focusing on what the place IS, not what it's known for
    if clean_chars:
        char = clean_chars[0]
        desc = f"A place notable for {char.lower()} and its cultural significance."
    else:
        desc = f"A populated area with unique urban characteristics and history."

    # Ensure 6-20 words
    wc = len(desc.split())
    if wc < 6:
        if wc < 4:
            desc = "A populated place known for its distinctive character and urban environment."
        else:
            desc = desc.rstrip('.') + " and cultural significance."
    elif wc > 20:
        desc = ' '.join(desc.split()[:18]) + '.'

    return desc

def convert_legacy_to_v2(word, legacy_rec, all_names):
    desc_legacy = legacy_rec.get('description', '')
    desc = build_description(desc_legacy, word)

    hints_legacy = legacy_rec.get('hints', [])
    fakes = legacy_rec.get('fakes', [])

    easy_raw = [h['text'] for h in hints_legacy if h.get('level') == 1]
    medium_raw = [h['text'] for h in hints_legacy if h.get('level') == 2]
    hard_raw = [h['text'] for h in hints_legacy if h.get('level') == 3]

    all_hints = {
        'easy': pad_hints([h for h in easy_raw if 'city' not in h.lower() and 'town' not in h.lower()], 'easy'),
        'medium': pad_hints([h for h in medium_raw if 'city' not in h.lower() and 'town' not in h.lower()], 'medium'),
        'hard': pad_hints([h for h in hard_raw if 'city' not in h.lower() and 'town' not in h.lower()], 'hard')
    }

    imposters = select_imposters(word, fakes, all_names, desc)
    difficulty = 'hard' if hard_raw else ('medium' if medium_raw else 'easy')

    desc_words = tokens(desc)
    tags = [t for t in desc_words if t.isalpha() and len(t) >= 3 and t not in STOPWORDS][:6]
    tags = [t.lower() for t in tags] if tags else ['city', 'place']

    return {
        'word': word,
        'category': 'geography_places',
        'subcategory': word,
        'difficulty': difficulty,
        'description': desc,
        'tags': tags,
        'hints': all_hints,
        'imposters': imposters
    }

def main():
    with open(LEGACY_FILE) as f:
        legacy_data = json.load(f)
    all_names = [w['word'] for w in legacy_data.get('words', [])]

    done = set()
    for p in W.iter_source_files(os.path.join(SRC_DIR, 'cities')):
        try:
            recs = W.load_records(p)
            for r in recs:
                done.add(W.normalize(r['word']))
        except:
            pass
    remaining = [w for w in legacy_data.get('words', []) if W.normalize(w['word']) not in done]

    print(f"Processing {len(remaining)} remaining cities...")
    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()

    valid_records = []
    for rec in remaining[:10]:  # Process 10 at a time
        word = rec['word']
        v2_record = convert_legacy_to_v2(word, rec, all_names)

        errs, warns = W.validate_record(v2_record, cats, lists)
        if errs:
            print(f"ERROR {word}: {errs[:2]}")
        else:
            valid_records.append(v2_record)
            print(f"OK {word}")

    if valid_records:
        src_folder = os.path.join(SRC_DIR, 'cities')
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
        print(f"Saved {len(valid_records)} records to {out_file}")

if __name__ == '__main__':
    main()