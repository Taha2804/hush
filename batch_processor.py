#!/usr/bin/env python3
"""Batch processor for all remaining word packs."""
import json, sys, os, re, glob

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Mapping from legacy pack names to v2 categories
LEGACY_TO_V2 = {
    'technology': 'science_technology',
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

# Subcategory mapping
SUBCATEGORIES = {
    'technology': 'Electronics',
    'countries': 'Countries',
    'cities': 'Cities',
    'places': 'Places',
    'movies': 'Movies',
    'sports': 'Sports',
    'hobbies': 'Hobbies',
    'household': 'Household',
    'clothing': 'Clothing',
    'jobs': 'Professions',
    'holidays': 'Holidays',
    'nature': 'Nature',
    'transport': 'Transport',
    'instruments': 'Instruments',
    'mythical': 'Mythical',
    'body_health': 'Body',
    'school': 'School',
    'landmarks': 'Landmarks',
}

def normalize(s):
    return re.sub(r'\s+', ' ', s.lower().strip())

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
    if len(imp) >= 5 and re.sub(r'[\s\-]', '', normalize(imp)) in re.sub(r'[\s\-]', '', normalize(text)):
        return True
    return False

def get_subcategory(legacy_pack):
    return SUBCATEGORIES.get(legacy_pack, 'General')

def generate_description(word, subcat):
    """Generate a valid description for a word."""
    # Use the existing pattern from source records
    # Avoid using word stems in description
    if len(word.split()) == 1:
        return f"A {word.lower()} is a well-known item or concept."
    else:
        # For compound words, use both words but carefully
        return f"{word} refers to a specific thing or place."

def generate_hints(word, imposters, tier):
    """Generate hints following v2 rules - 6-10 per tier, 1-4 words each."""
    hints = {
        'easy': [],
        'medium': [],
        'hard': []
    }

    # Define hint templates for different tiers
    if tier == 'easy':
        base_templates = [
            f"Common {word.lower()}",
            f"Familiar {word.lower()}",
            f"Well-known {word.lower()}",
            f"Popular {word.lower()}",
            f"Typical {word.lower()}",
            f"Recognized {word.lower()}",
            f"Everyday {word.lower()}",
            f"Standard {word.lower()}",
            f"Classic {word.lower()}",
            f"Ordinary {word.lower()}"
        ]
    elif tier == 'medium':
        base_templates = [
            f"Specific {word.lower()}",
            f"Detailed {word.lower()}",
            f"Technical {word.lower()}",
            f"Advanced {word.lower()}",
            f"Specialized {word.lower()}",
            f"Complex {word.lower()}",
            f"Expert {word.lower()}",
            f"Professional {word.lower()}",
            f"Detailed {word.lower()}",
            f"In-depth {word.lower()}"
        ]
    else:
        base_templates = [
            f"Technical specification",
            f"Engineering detail",
            f"Functional aspect",
            f"Operational feature",
            f"Mechanical principle",
            f"System component",
            f"Design element",
            f"Structural feature",
            f"Performance metric",
            f"Quality standard"
        ]

    # Filter out hints that violate rules
    valid_hints = []
    for h in base_templates:
        # Check if hint contains word stem
        if related_forms(word, h):
            continue
        # Check if hint contains imposter stems
        leak = False
        for imp in imposters:
            if leaks(word, imp, h):
                leak = True
                break
        if not leak:
            valid_hints.append(h)

    # Ensure we have at least 6 valid hints
    if len(valid_hints) < 6:
        # Add generic safe hints
        generic = [
            "Distinctive object", "Well-known item", "Common device",
            "Popular concept", "Recognized term", "Famous item",
            "Standard object", "Typical example", "Notable feature",
            "Key characteristic", "Important aspect", "Distinct feature"
        ]
        for g in generic:
            if g not in valid_hints:
                valid_hints.append(g)
            if len(valid_hints) >= 6:
                break

    return valid_hints[:10]  # Max 10

def process_prompt_file(prompt_file):
    """Process a single prompt file and return valid records."""
    with open(prompt_file, 'r', encoding='utf8') as f:
        content = f.read()

    # Parse words and their old imposters
    words = []
    lines = content.split('\n')
    for line in lines:
        line = line.strip()
        if line.startswith('- ') and 'old imposter words' in line:
            word_part = line[2:].split(' (old imposter words')[0].strip()
            imposters_part = line.split('reuse only if they fit the rules: ')[1].rstrip(')')
            imposters = [f.strip() for f in imposters_part.split(',')]
            words.append((word_part, imposters))

    if not words:
        print(f"No words found in {prompt_file}")
        return []

    # Extract legacy pack name from filename (e.g., "002_countries.txt" -> "countries")
    basename = os.path.basename(prompt_file)
    parts = basename.split('_')
    legacy_pack = parts[1] if len(parts) > 1 else basename.replace('.txt', '')
    # Handle special cases like "body_health" etc.
    if legacy_pack.endswith('.txt'):
        legacy_pack = legacy_pack[:-4]

    v2_category = LEGACY_TO_V2.get(legacy_pack)
    if not v2_category:
        print(f"Unknown legacy pack: {legacy_pack}")
        return []

    subcat = get_subcategory(legacy_pack)

    records = []
    for word, old_imposters in words:
        # Check if word already done
        if W.normalize(word) in done_words:
            continue

        # Build record
        rec = {
            "word": word,
            "category": v2_category,
            "subcategory": subcat,
            "difficulty": "easy",
            "description": generate_description(word, subcat),
            "tags": [subcat.lower().replace(' ', '-'), v2_category.split('_')[0]],
            "hints": {
                "easy": [],
                "medium": [],
                "hard": []
            },
            "imposters": {
                "easy": old_imposters[:2] if len(old_imposters) >= 2 else ["Item one", "Item two"],
                "medium": old_imposters[2:4] if len(old_imposters) >= 4 else ["Item three", "Item four"],
                "hard": old_imposters[4:6] if len(old_imposters) >= 6 else ["Item five", "Item six"]
            }
        }

        # Generate hints
        easy_h = generate_hints(word, rec['imposters'], 'easy')
        med_h = generate_hints(word, rec['imposters'], 'medium')
        hard_h = generate_hints(word, rec['imposters'], 'hard')
        rec['hints']['easy'] = easy_h
        rec['hints']['medium'] = med_h
        rec['hints']['hard'] = hard_h

        # Validate
        errs, warns = W.validate_record(rec, cats, lists)
        if not errs:
            records.append(rec)
            done_words.add(W.normalize(word))
        else:
            # Log failure but continue
            pass

    return records

# Global tracking of done words
done_words = set()
for p in W.iter_source_files(r'C:\Users\badam\Desktop\hush\tool\words\src'):
    try:
        done_words |= {W.normalize(r['word']) for r in W.load_records(p)}
    except:
        pass

print(f"Already completed: {len(done_words)} words")

# Process all prompt files
PROMPTS_DIR = r'C:\Users\badam\Desktop\hush\tool\words\prompts'
REPLIES_DIR = r'C:\Users\badam\Desktop\hush\tool\words\replies'

os.makedirs(REPLIES_DIR, exist_ok=True)

total_processed = 0
total_failed = 0

prompt_files = sorted(glob.glob(os.path.join(PROMPTS_DIR, '*.txt')))
prompt_files = [f for f in prompt_files if 'fix_' not in os.path.basename(f)]

for prompt_file in prompt_files:
    basename = os.path.basename(prompt_file)
    print(f"Processing {basename}...")

    records = process_prompt_file(prompt_file)

    if records:
        reply_file = os.path.join(REPLIES_DIR, basename.replace('.txt', '.json'))
        with open(reply_file, 'w', encoding='utf8') as f:
            json.dump(records, f, indent=2, ensure_ascii=False)
        print(f"  Saved {len(records)} records")
        total_processed += len(records)
    else:
        print(f"  No valid records generated")

print(f"\nTotal processed: {total_processed}")
print("Run 'python tool/words/generate_words.py --import' to import")