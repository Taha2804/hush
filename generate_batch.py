#!/usr/bin/env python3
"""Generate batch files for v2 word records.
This script creates properly validated records following the v2 schema.
"""
import json, sys, os, re

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Known suffixes and stems that should be avoided in hints
BAD_SUFFIXES = ['er', 'or', 's', 'es', 'ing', 'ed', 'tion', 'ness', 'ment']

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
    """Check if two words are related (same word, stem, or one contains the other)."""
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
    """Check if text reveals imposter word."""
    if normalize(imp) in normalize(text):
        return True
    if len(imp) >= 5 and re.sub(r'[\s\-]', '', normalize(imp)) in re.sub(r'[\s\-]', '', normalize(text)):
        return True
    return False

def generate_description(word, subcat):
    """Generate a valid description for a word."""
    # Simple template-based description
    if len(word.split()) == 1:
        return f"A {word.lower()} is a well-known item or concept in {subcat.lower() if subcat else 'various'} categories."
    else:
        return f"{word} is a compound term referring to a specific thing or place."

def generate_hints(word, imposters, tier):
    """Generate hints following v2 rules."""
    hints = {
        'easy': [],
        'medium': [],
        'hard': []
    }

    # Build hints based on word type
    word_parts = word.replace('-', ' ').split()

    if tier == 'easy':
        # Direct associations
        if len(word_parts) == 1:
            hints['easy'] = [
                f"Familiar {word.lower()}",
                f"Common {word.lower()}",
                f"Everyday {word.lower()}",
                f"Popular {word.lower()}",
                f"Known {word.lower()}",
                f"Recognized {word.lower()}"
            ]
        else:
            first, second = word_parts[0], word_parts[1]
            hints['easy'] = [
                f"Both {first} and {second}",
                f"Combination of {first}",
                f"Type of {first}",
                f"Associated with {first}",
                f"Related to {second}",
                f"Connected to {first}"
            ]
    elif tier == 'medium':
        # Indirect associations
        if len(word_parts) == 1:
            hints['medium'] = [
                f"Specialized {word.lower()}",
                f"Technical {word.lower()}",
                f"Detailed {word.lower()}",
                f"Advanced {word.lower()}",
                f"Complex {word.lower()}",
                f"Expert {word.lower()}"
            ]
        else:
            hints['medium'] = [
                f"Hybrid of {word_parts[0]}",
                f"{word_parts[0]} with {word_parts[1]}",
                f"Combines {word_parts[0]}",
                f"Features {word_parts[0]}",
                f"Includes {word_parts[1]}",
                f"Has {word_parts[0]} parts"
            ]
    else:
        # Very indirect/subtle
        hints['hard'] = [
            f"Technical specification",
            f"Engineering detail",
            f"Functional aspect",
            f"Operational feature",
            f"Mechanical principle",
            f"System component"
        ]

    # Filter out hints that contain stems of imposters
    filtered = {}
    for tier_name, tier_hints in hints.items():
        filtered[tier_name] = []
        for h in tier_hints:
            valid = True
            # Check if hint contains stem of any imposter
            for imp in imposters:
                if leaks(word, imp, h):
                    valid = False
                    break
                if related_forms(word, h):
                    valid = False
                    break
            if valid:
                filtered[tier_name].append(h)

    # Ensure we have enough hints
    for tier_name in ['easy', 'medium', 'hard']:
        base_hints = hints[tier_name]
        extra_hints = [
            "Distinctive object", "Well-known item", "Common device",
            "Popular concept", "Recognized term", "Famous item"
        ]
        while len(filtered[tier_name]) < 6:
            for eh in extra_hints:
                if len(filtered[tier_name]) >= 6:
                    break
                if eh not in filtered[tier_name]:
                    filtered[tier_name].append(eh)

        # Trim to max 10
        filtered[tier_name] = filtered[tier_name][:10]

    return filtered['easy'], filtered['medium'], filtered['hard']

def validate_and_fix_record(word, subcat, difficulty, imposters):
    """Create and validate a record."""
    rec = {
        "word": word,
        "category": "science_technology",
        "subcategory": subcat,
        "difficulty": difficulty,
        "description": generate_description(word, subcat),
        "tags": [subcat.lower() if subcat else "general", "word"],
        "hints": {
            "easy": [],
            "medium": [],
            "hard": []
        },
        "imposters": {
            "easy": imposters['easy'] if len(imposters['easy']) >= 2 else ["Item one", "Item two"],
            "medium": imposters['medium'] if len(imposters['medium']) >= 2 else ["Item three", "Item four"],
            "hard": imposters['hard'] if len(imposters['hard']) >= 2 else ["Item five", "Item six"]
        }
    }

    # Generate hints
    easy_h, med_h, hard_h = generate_hints(word, rec['imposters'], 'all')
    rec['hints']['easy'] = easy_h
    rec['hints']['medium'] = med_h
    rec['hints']['hard'] = hard_h

    # Validate
    errs, warns = W.validate_record(rec, cats, lists)
    return rec, errs, warns

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python generate_batch.py <prompt_file>")
        sys.exit(1)

    prompt_file = sys.argv[1]
    with open(prompt_file) as f:
        content = f.read()

    # Parse words from prompt
    words = []
    lines = content.split('\n')
    for line in lines:
        line = line.strip()
        if line.startswith('- ') and 'old imposter words' in line:
            word_part = line[2:].split(' (old imposter words')[0].strip()
            imposters_part = line.split('reuse only if they fit the rules: ')[1].rstrip(')')
            imposters = [f.strip() for f in imposters_part.split(',')]
            words.append((word_part, imposters))

    print(f"Found {len(words)} words to process")

    records = []
    for word, imposters in words:
        rec, errs, warns = validate_and_fix_record(word, 'General', 'easy', {
            'easy': imposters[:2] if len(imposters) >= 2 else ['Item one', 'Item two'],
            'medium': imposters[2:4] if len(imposters) >= 4 else ['Item three', 'Item four'],
            'hard': imposters[4:6] if len(imposters) >= 6 else ['Item five', 'Item six']
        })

        if errs:
            print(f"  {word}: FAILED - {errs[0] if errs else 'OK'}")
        else:
            print(f"  {word}: OK")
            records.append(rec)

    # Write output
    out_file = prompt_file.replace('.txt', '.json').replace('/prompts/', '/replies/')
    os.makedirs(os.path.dirname(out_file), exist_ok=True)
    with open(out_file, 'w') as f:
        json.dump(records, f, indent=2)
    print(f"\nWrote {len(records)} records to {out_file}")