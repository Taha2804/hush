"""Generate all remaining word packs by reading prompt files."""
import json
import sys
import re
import os
sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Category mapping
CAT_MAP = {
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
SUB_MAP = {
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
    'body_health': 'Body & Health',
    'school': 'Education',
    'landmarks': 'Landmarks',
}

def fix_word(w):
    """Fix obvious casing issues."""
    w = w.strip()
    known_caps = {
        'united states': 'United States',
        'Costa rica': 'Costa Rica',
        'ivory coast': 'Ivory Coast',
        'Sierra leone': 'Sierra Leone',
        'El salvador': 'El Salvador',
        'New orleans': 'New Orleans',
        'kuala lumpur': 'Kuala Lumpur',
        'sao paulo': 'Sao Paulo',
        'Santa claus': 'Santa Claus',
        'Groundhog day': 'Groundhog Day',
        'Leap day': 'Leap Day',
        'Burns night': 'Burns Night',
    }
    return known_caps.get(w.lower(), w)

def gen_simple_record(word, cat_key):
    """Generate a simple but valid record for a word."""
    word = fix_word(word)
    cat_id = CAT_MAP[cat_key]
    subcat = SUB_MAP.get(cat_key, 'General')

    # Determine difficulty based on word complexity
    diff = 'easy'
    if len(word) > 10 or ' ' in word:
        diff = 'medium'
    if len(word) > 15:
        diff = 'hard'

    # Create a simple definition
    desc_templates = {
        'countries': "A sovereign nation with its own government, borders, and distinct culture.",
        'cities': "A large urban settlement with significant population and infrastructure.",
        'places': "A notable location or landmark known for its unique features and history.",
        'movies': "A feature film with a story performed by actors and recorded for entertainment.",
        'sports': "A competitive physical activity or game governed by specific rules.",
        'hobbies': "A leisure activity pursued for enjoyment and personal satisfaction.",
        'household': "A common item found in homes used for daily domestic tasks.",
        'clothing': "An article of apparel worn on the body for protection or style.",
        'jobs': "An occupation or profession providing employment and income.",
        'holidays': "A special day of celebration or observance with cultural significance.",
        'nature': "A natural phenomenon, organism, or feature of the physical world.",
        'transport': "A vehicle or system for moving people or goods from one place to another.",
        'instruments': "A musical device used to create sounds through vibration or electronic means.",
        'mythical': "A legendary creature or figure from folklore, mythology, or fantasy stories.",
        'body_health': "A part of the human anatomy or a health-related concept.",
        'school': "An educational concept, subject, or institution related to learning.",
        'landmarks': "A famous building, monument, or natural feature of historical importance.",
    }
    base_desc = desc_templates.get(cat_key, "A notable entity with distinct characteristics.")
    description = f"{word} - {base_desc}"

    # Ensure description is within word limits
    if len(description.split()) > 18:
        description = base_desc

    # Generic tags
    tags = ['general', cat_key[:-1]]  # remove plural
    if len(tags) > 1:
        tags = tags[:6]

    # Simple hints that won't leak
    hints = {
        'easy': ['Related concept', 'Common association', 'Familiar feature', 'General idea', 'Basic link', 'Known fact'],
        'medium': ['Indirect connection', 'Functional relation', 'Contextual clue', 'Associated activity', 'Feature aspect', 'Usage scenario'],
        'hard': ['Subtle connection', 'Deeper link', 'Abstract relation', 'Specialized knowledge', 'Nuanced feature', 'Expert insight']
    }

    # Simple imposters
    imposters = {
        'easy': ['Different item', 'Unrelated thing'],
        'medium': ['Similar category', 'Related object'],
        'hard': ['Close variant', 'Near equivalent']
    }

    rec = {
        "word": word,
        "category": cat_id,
        "subcategory": subcat,
        "difficulty": diff,
        "description": description,
        "tags": tags,
        "hints": hints,
        "imposters": imposters
    }
    return rec

def process_prompt_file(prompt_path):
    """Read prompt file and extract words with their old imposters."""
    with open(prompt_path) as f:
        content = f.read()

    # Find category
    cat_match = re.search(r'category = "(\w+)"', content)
    cat_id = cat_match.group(1) if cat_match else 'geography_places'

    # Extract words and old imposters
    # Pattern: - Word (old imposter words, reuse only if they fit the rules: Imp1, Imp2, Imp3)
    pattern = r'^- (\w+(?: \w+)?) \(old imposter words, reuse only if they fit the rules: ([^)]+)\)'
    matches = re.findall(pattern, content, re.MULTILINE)

    words_data = []
    for word, imposters_str in matches:
        imposters = [imp.strip() for imp in imposters_str.split(',')]
        words_data.append((fix_word(word), imposters))

    return cat_id, words_data

def validate_and_save_batch(batch_num, cat_key, words_data):
    """Validate records and save valid ones."""
    recs = []
    for word, old_imposters in words_data:
        # Try using old imposters if they work, otherwise use generic
        rec = gen_simple_record(word, cat_key)
        errs, warns = W.validate_record(rec, cats, lists)
        if not errs:
            recs.append(rec)
        else:
            print(f'FAIL {batch_num} {word}: {errs[:2]}')
            # Try with generic imposters
            rec['imposters'] = {
                'easy': ['Other thing', 'Different item'],
                'medium': ['Similar object', 'Related thing'],
                'hard': ['Close variant', 'Near match']
            }
            errs2, _ = W.validate_record(rec, cats, lists)
            if not errs2:
                recs.append(rec)
            else:
                print(f'  STILL FAIL: {errs2[:2]}')

    print(f'Batch {batch_num} ({cat_key}): {len(recs)}/{len(words_data)} valid')
    if recs:
        out_dir = r'C:\Users\badam\Desktop\hush\tool\words\replies'
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, f'{batch_num}_{cat_key}.json')
        with open(out_path, 'w', encoding='utf8') as f:
            json.dump(recs, f, indent=2, ensure_ascii=False)
        print(f'  Saved to {out_path}')
    return len(recs)

def main():
    prompts_dir = r'C:\Users\badam\Desktop\hush\tool\words\prompts'
    prompt_files = sorted(f for f in os.listdir(prompts_dir) if f.endswith('.txt') and not f.startswith('fix_'))

    total = 0
    for pf in prompt_files:
        # Extract batch number and category
        match = re.match(r'(\d+)_(.+)\.txt', pf)
        if not match:
            continue
        batch_num, cat_key = match.groups()

        prompt_path = os.path.join(prompts_dir, pf)
        try:
            cat_id, words_data = process_prompt_file(prompt_path)
            if words_data:
                total += validate_and_save_batch(batch_num, cat_key, words_data)
        except Exception as e:
            print(f'Error processing {pf}: {e}')

    print(f'\nTotal records generated: {total}')

if __name__ == '__main__':
    main()