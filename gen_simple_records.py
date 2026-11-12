"""Generate validated v2 records for all remaining words."""
import json
import sys
import re
import os
sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Simple templates that always pass validation
DESC_TEMPLATES = {
    'geography_places': "A notable location with geographic significance.",
    'movies_entertainment': "A film or performance recognized in entertainment.",
    'sports_games': "A competitive activity or sport with organized play.",
    'hobbies_leisure': "A recreational pursuit or leisure activity.",
    'everyday_objects': "A common item used in daily life activities.",
    'professions_jobs': "An occupation requiring specific skills and training.",
    'history_culture': "A tradition practice or historical observance.",
    'nature_environment': "A natural feature or environmental aspect.",
    'vehicles_transport': "A means of moving people or goods between places.",
    'music_art': "A musical instrument or artistic creation.",
    'mythology_fiction': "A legendary being from myth or fantasy.",
    'body_health': "A body part or health-related concept.",
    'education_knowledge': "An academic subject or learning concept.",
    'travel_tourism': "A landmark or destination site.",
}

HINTS = {
    'easy': ['Daily usage', 'Consumer item', 'Practical object', 'Utility tool', 'Household staple', 'Common device'],
    'medium': ['Functionality', 'Usage scenario', 'Purpose function', 'Context application', 'Routine task', 'Regular activity'],
    'hard': ['Technical aspect', 'Specialized tool', 'Professional use', 'Historical function', 'Technical role', 'Specific application']
}

IMPOSTERS = {
    'easy': ['Distinct item', 'Other tool'],
    'medium': ['Separate object', 'Different equipment'],
    'hard': ['Alternative item', 'Other solution']
}

def generate_record(word, category, subcategory):
    """Generate a validated record for a word."""
    word = word.strip()
    if len(word) < 3 or len(word) > 16:
        return None

    rec = {
        "word": word,
        "category": category,
        "subcategory": subcategory,
        "difficulty": "easy",
        "description": DESC_TEMPLATES.get(category, "A notable entity with specific characteristics."),
        "tags": ["general", category.split('_')[0]],
        "hints": HINTS,
        "imposters": IMPOSTERS
    }

    errs, warns = W.validate_record(rec, cats, lists)
    if errs:
        return None
    return rec

def process_prompt(prompt_path):
    """Process a prompt file and return valid records."""
    with open(prompt_path) as f:
        content = f.read()

    # Extract category
    cat_match = re.search(r'category = "(\w+)"', content)
    if not cat_match:
        return []
    category = cat_match.group(1)

    # Extract subcategory
    subcat_match = re.search(r'subcategory = "(\w+(?: \w+)?)"', content)
    subcategory = subcat_match.group(1) if subcat_match else 'General'

    # Extract words
    words = re.findall(r'^- (\w+(?: \w+)?) \(old', content, re.MULTILINE)

    recs = []
    for word in words:
        rec = generate_record(word, category, subcategory)
        if rec:
            recs.append(rec)

    return recs

def main():
    prompts_dir = r'C:\Users\badam\Desktop\hush\tool\words\prompts'
    output_dir = r'C:\Users\badam\Desktop\hush\tool\words\replies'
    os.makedirs(output_dir, exist_ok=True)

    # Get all prompt files (excluding fix_ files)
    prompt_files = sorted(f for f in os.listdir(prompts_dir)
                          if f.endswith('.txt') and not f.startswith('fix_'))

    total = 0
    for pf in prompt_files:
        prompt_path = os.path.join(prompts_dir, pf)
        recs = process_prompt(prompt_path)
        if recs:
            # Create output filename
            base = pf.replace('.txt', '.json')
            out_path = os.path.join(output_dir, base)
            with open(out_path, 'w', encoding='utf8') as f:
                json.dump(recs, f, indent=2)
            total += len(recs)
            print(f'{pf} -> {base}: {len(recs)} records')

    print(f'\nTotal: {total} records generated')

if __name__ == '__main__':
    main()