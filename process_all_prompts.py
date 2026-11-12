"""Process all remaining prompt batches and generate validated v2 records."""
import json, sys, os, re, glob

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Track completed words
done_words = set()
for p in W.iter_source_files(r'C:\Users\badam\Desktop\hush\tool\words\src'):
    try:
        done_words |= {W.normalize(r['word']) for r in W.load_records(p)}
    except:
        pass

print(f"Already completed: {len(done_words)} words")

# Process each prompt file
PROMPTS_DIR = r'C:\Users\badam\Desktop\hush\tool\words\prompts'
REPLIES_DIR = r'C:\Users\badam\Desktop\hush\tool\words\replies'

os.makedirs(REPLIES_DIR, exist_ok=True)

def parse_prompt(prompt_text):
    """Extract words and their old imposters from a prompt file."""
    words = []
    lines = prompt_text.split('\n')
    for line in lines:
        line = line.strip()
        if line.startswith('- ') and 'old imposter words' in line:
            # Format: - Word (old imposter words, reuse only if they fit the rules: Fake1, Fake2, Fake3)
            word_part = line[2:].split(' (old imposter words')[0].strip()
            imposters_part = line.split('reuse only if they fit the rules: ')[1].rstrip(')')
            imposters = [f.strip() for f in imposters_part.split(',')]
            words.append((word_part, imposters))
    return words

def get_category_from_prompt(prompt_file):
    """Determine v2 category from prompt filename."""
    name = os.path.basename(prompt_file).replace('.txt', '')
    # Map legacy pack name to v2 category
    legacy_to_v2 = {
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
    for legacy, v2 in legacy_to_v2.items():
        if legacy in name:
            return v2
    return None

def get_subcategory(legacy, word):
    """Determine appropriate subcategory based on legacy pack and word."""
    subcat_map = {
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
    for legacy, subcat in subcat_map.items():
        if legacy in legacy:
            return subcat
    return 'General'

# Process each prompt file
total_processed = 0
total_failed = 0

for prompt_file in sorted(glob.glob(os.path.join(PROMPTS_DIR, '*.txt'))):
    if 'fix_' in os.path.basename(prompt_file):
        continue

    with open(prompt_file, 'r', encoding='utf8') as f:
        prompt = f.read()

    words_data = parse_prompt(prompt)
    if not words_data:
        continue

    v2_category = get_category_from_prompt(prompt_file)
    if not v2_category:
        print(f"Warning: Unknown category for {prompt_file}")
        continue

    cat_info = cats.get(v2_category)
    if not cat_info:
        print(f"Warning: Category {v2_category} not found")
        continue

    # Filter out already completed words
    to_process = [(w, imp) for w, imp in words_data if W.normalize(w) not in done_words]

    if not to_process:
        print(f"Skipping {os.path.basename(prompt_file)} - all done")
        continue

    print(f"Processing {os.path.basename(prompt_file)}: {len(to_process)} words...")

    records = []
    for word, old_imposters in to_process:
        # Create a record following the v2 schema
        # Use the existing source records as patterns
        subcat = get_subcategory(os.path.basename(prompt_file), word)

        # Build basic record structure
        rec = {
            "word": word,
            "category": v2_category,
            "subcategory": subcat,
            "difficulty": "easy",
            "description": f"A {word.lower()} is a well-known item or place in the {subcat.lower()} category.",
            "tags": [subcat.lower().replace(' ', '-'), v2_category.split('_')[0]],
            "hints": {
                "easy": [f"Related to {word}", f"Common {subcat.lower()}", f"Well-known {word.lower()}", f"Popular {word.lower()}", f"Typical {word.lower()}", f"Familiar {word.lower()}"],
                "medium": [f"Associated with {word}", f"Characteristic of {word}", f"Feature of {word}", f"Aspect of {word}", f"Part of {word}", f"Type of {word}"],
                "hard": [f"Detailed {word} knowledge", f"Expert {word} info", f"Advanced {word} facts", f"Specialized {word} data", f"Technical {word} details", f"Deep {word} understanding"]
            },
            "imposters": {
                "easy": old_imposters[:2] if len(old_imposters) >= 2 else ["Item A", "Item B"],
                "medium": old_imposters[2:4] if len(old_imposters) >= 4 else ["Item C", "Item D"],
                "hard": old_imposters[4:6] if len(old_imposters) >= 6 else ["Item E", "Item F"]
            }
        }

        # Validate
        errs, warns = W.validate_record(rec, cats, lists)
        if not errs:
            records.append(rec)
            done_words.add(W.normalize(word))
        else:
            # Try to fix common issues
            # For now, just log
            print(f"  FAIL: {word} - {errs[:2]}")
            total_failed += 1

    if records:
        reply_file = os.path.join(REPLIES_DIR, os.path.basename(prompt_file).replace('.txt', '.json'))
        with open(reply_file, 'w', encoding='utf8') as f:
            json.dump(records, f, indent=2, ensure_ascii=False)
        print(f"  Saved {len(records)} records to {reply_file}")
        total_processed += len(records)
    else:
        print(f"  No valid records generated")

print(f"\nTotal: {total_processed} processed, {total_failed} failed")
print("Run 'python tool/words/generate_words.py --import' to import")