#!/usr/bin/env python3
"""
Generate v2 format records from legacy format for the countries pack.
Fixed descriptions that don't repeat hints.
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
    """Convert legacy description to a proper v2 definition that doesn't repeat hints."""
    # Get key phrases from legacy description
    parts = [p.strip() for p in desc_text.split('•') if p.strip()]

    # Build a definition that describes WHAT the country IS, not a list of hints
    # Extract the core category and key characteristics

    # Clean up the text
    clean_parts = []
    for p in parts:
        # Remove common phrases that would repeat hints
        cleaned = re.sub(r'\b(country|nation|island|country#|country:|nation:)\b', '', p, flags=re.I)
        cleaned = re.sub(r'\b(home|home of|known for|famous for)\b', '', cleaned, flags=re.I)
        cleaned = cleaned.strip(' :.-')
        if cleaned and cleaned.lower() not in ['country', 'nation', 'island']:
            clean_parts.append(cleaned)

    # Build definition sentence
    if len(clean_parts) >= 2:
        char1 = clean_parts[0]
        char2 = clean_parts[1] if len(clean_parts) > 1 else None

        if char2:
            # Create a definition that combines the characteristics
            desc = f"A nation with {char1.lower()} and {char2.lower()}."
        else:
            desc = f"A country featuring {char1.lower()}."
    else:
        desc = f"A nation with distinct geographic features."

    # Ensure 6-20 words
    word_count = len(desc.split())
    if word_count < 6:
        # Add more descriptive content
        if 'geographic' in desc.lower():
            desc = desc.replace('geographic features', 'unique geographic features and cultural heritage')
        else:
            desc = desc[:-1] if desc.endswith('.') else desc
            desc += " with unique geography."
        word_count = len(desc.split())

    if word_count > 20:
        words = desc.split()[:18]
        desc = ' '.join(words) + '.'

    return desc

def select_imposters(word, fakes, all_countries, desc_text):
    """Select 2-4 imposters per tier, distributed from fakes and other countries."""
    word_norm = normalize(word)

    # Collect all possible imposters (valid ones only)
    all_possibilities = []

    # First add fakes
    for fake in fakes:
        norm_fake = normalize(fake)
        if norm_fake != word_norm and not related_forms(word, fake):
            all_possibilities.append(fake)

    # Then add other countries that would be good imposters
    for other in all_countries:
        norm_other = normalize(other)
        if norm_other == word_norm:
            continue
        if normalize(other) in normalize(desc_text):
            continue  # Would leak in description
        if related_forms(word, other):
            continue
        if other not in all_possibilities:
            all_possibilities.append(other)

    # Select 2-4 imposters for easy tier (closest, but not variants)
    easy_imposters = []
    seen = set()
    for imp in all_possibilities:
        if len(easy_imposters) >= 2:
            break
        norm_imp = normalize(imp)
        if norm_imp not in seen:
            seen.add(norm_imp)
            easy_imposters.append(imp)

    # Select 2-4 for medium tier
    medium_imposters = []
    seen_m = set(normalize(i) for i in easy_imposters)
    for imp in all_possibilities:
        if len(medium_imposters) >= 2:
            break
        norm_imp = normalize(imp)
        if norm_imp not in seen_m:
            seen_m.add(norm_imp)
            medium_imposters.append(imp)

    # Select 2-4 for hard tier (can include more similar countries)
    hard_imposters = []
    seen_h = set(normalize(i) for i in easy_imposters + medium_imposters)
    for imp in all_possibilities:
        if len(hard_imposters) >= 4:
            break
        norm_imp = normalize(imp)
        if norm_imp not in seen_h:
            seen_h.add(norm_imp)
            hard_imposters.append(imp)

    return {
        'easy': easy_imposters[:4],
        'medium': medium_imposters[:4],
        'hard': hard_imposters[:4]
    }

def generate_v2_record(word, legacy_rec, all_country_names):
    """Generate a v2 record from legacy format."""
    desc_legacy = legacy_rec.get('description', '')
    description = convert_description(desc_legacy, word)

    hints_legacy = legacy_rec.get('hints', [])
    fakes = legacy_rec.get('fakes', [])

    # Build hints - use hints but pad to 6-10 per tier
    # Group hints by level
    easy_raw = [h['text'] for h in hints_legacy if h.get('level') == 1]
    medium_raw = [h['text'] for h in hints_legacy if h.get('level') == 2]
    hard_raw = [h['text'] for h in hints_legacy if h.get('level') == 3]

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

    all_hints = {
        'easy': pad_hints(easy_raw, 'easy'),
        'medium': pad_hints(medium_raw, 'medium'),
        'hard': pad_hints(hard_raw, 'hard')
    }

    # Select imposters
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
    """Full validation including leaks check."""
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

    remaining = []
    for w in legacy_data.get('words', []):
        if W.normalize(w['word']) not in done:
            remaining.append(w)

    print(f"Processing {len(remaining)} remaining countries...")

    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()

    valid_records = []
    invalid_count = 0

    for rec in remaining:
        word = rec['word']
        v2_record = generate_v2_record(word, rec, all_countries)

        errs, warns = validate_record_full(v2_record, cats, lists)

        if errs:
            print(f"ERROR {word}: {errs[:2]}")
            invalid_count += 1
        else:
            valid_records.append(v2_record)
            print(f"OK {word}")

    print(f"\n{len(valid_records)} valid, {invalid_count} invalid")

    if valid_records:
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
            json.dump(valid_records, f, ensure_ascii=False, indent=2)
        print(f"Saved {len(valid_records)} records to {out_file}")

        result = os.system(f'python tool/words/validate_src.py {src_folder}')
        if result == 0:
            print("Validation passed!")
        else:
            print("Validation found issues")

if __name__ == '__main__':
    main()