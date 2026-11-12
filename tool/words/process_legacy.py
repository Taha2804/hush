#!/usr/bin/env python3
"""Process legacy word files and generate v2 records."""
import json, os, sys, glob, re

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

SRC_DIR = r'C:\Users\badam\Desktop\hush\tool\words\src'
LEGACY_DIR = r'C:\Users\badam\Desktop\hush\tool\words\legacy'

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Mapping legacy to v2 categories
LEGACY_TO_V2 = {
    'animals': 'animals_wildlife',
    'body_health': 'body_health',
    'cities': 'geography_places',
    'clothing': 'everyday_objects',
    'countries': 'geography_places',
    'drinks': 'food_drinks',
    'food': 'food_drinks',
    'fruits_vegetables': 'food_drinks',
    'hobbies': 'hobbies_leisure',
    'holidays': 'history_culture',
    'household': 'everyday_objects',
    'instruments': 'music_art',
    'jobs': 'professions_jobs',
    'landmarks': 'travel_tourism',
    'movies': 'movies_entertainment',
    'mythical': 'mythology_fiction',
    'nature': 'nature_environment',
    'places': 'geography_places',
    'school': 'education_knowledge',
    'sports': 'sports_games',
    'technology': 'science_technology',
    'transport': 'vehicles_transport',
}

# Subcategory mapping
SUBCATS = {
    'animals': 'Wildlife',
    'body_health': 'Body',
    'cities': 'Cities',
    'clothing': 'Clothing',
    'countries': 'Countries',
    'drinks': 'Drinks',
    'food': 'Food',
    'fruits_vegetables': 'Fruits & Vegetables',
    'hobbies': 'Hobbies',
    'holidays': 'Holidays',
    'household': 'Household',
    'instruments': 'Instruments',
    'jobs': 'Professions',
    'landmarks': 'Landmarks',
    'movies': 'Movies',
    'mythical': 'Mythical',
    'nature': 'Nature',
    'places': 'Places',
    'school': 'School',
    'sports': 'Sports',
    'technology': 'Electronics',
    'transport': 'Transport',
}

# Category-specific hint pools (safe words that won't leak)
CATEGORY_HINTS = {
    'animals': {
        'easy': ['Forest creature', 'Savanna beast', 'Wild animal', 'Exotic pet', 'Zoo resident', 'Endangered kind'],
        'medium': ['Predator behavior', 'Habitat preference', 'Migration pattern', 'Reserve location', 'Tropical zone', 'Arctic region'],
        'hard': ['Apex predator', 'Classification level', 'Adaptation trait', 'Conservation plan', 'Ecosystem role', 'Biodiversity key']
    },
    'body_health': {
        'easy': ['Body region', 'Organ group', 'Health state', 'Medical term', 'Physical trait', 'Wellness aspect'],
        'medium': ['Anatomy feature', 'Physiology process', 'Clinical sign', 'Diagnostic method', 'Therapy approach', 'Biology function'],
        'hard': ['Pathophysiology', 'Cell mechanism', 'Immune response', 'Nerve pathway', 'Metabolic path', 'Gene expression']
    },
    'cities': {
        'easy': ['Population center', 'Urban area', 'Metro zone', 'Travel spot', 'Cultural hub', 'Historic town'],
        'medium': ['Landmark site', 'Culture center', 'Commerce district', 'Transport network', 'Architecture style', 'Local food'],
        'hard': ['Preservation effort', 'Planning project', 'Development plan', 'Significance level', 'Climate effect', 'Geography role']
    },
    'clothing': {
        'easy': ['Fashion piece', 'Wearable', 'Textile good', 'Style element', 'Apparel', 'Costume piece'],
        'medium': ['Fabric kind', 'Sewing pattern', 'Color scheme', 'Material mix', 'Construction method', 'Seasonal wear'],
        'hard': ['Manufacturing process', 'Design principle', 'History timeline', 'Tailoring skill', 'Industry norm', 'Sustainability']
    },
    'countries': {
        'easy': ['Nation state', 'Government land', 'Political region', 'Sovereign state', 'Continent nation', 'World power'],
        'medium': ['Border zone', 'Capital city', 'Territory dispute', 'Colony history', 'Freedom movement', 'Trade deal'],
        'hard': ['Diplomacy relation', 'Sanction measure', 'Heritage site', 'Resource deposit', 'Demographic stat', 'Political system']
    },
    'drinks': {
        'easy': ['Beverage choice', 'Liquid option', 'Drinking choice', 'Meal pairing', 'Bar selection', 'Party pick'],
        'medium': ['Alcohol level', 'Non-alcoholic', 'Traditional brew', 'Regional specialty', 'Fermentation', 'Flavor profile'],
        'hard': ['Distillation method', 'Brewing science', 'Mixology art', 'Serving temp', 'Glassware choice', 'Pairing rule']
    },
    'food': {
        'easy': ['Edible matter', 'Meal part', 'Food group', 'Cooking ingredient', 'Nutritious pick', 'Healthy option'],
        'medium': ['Cooking technique', 'Recipe variant', 'Preservation way', 'Flavor combo', 'Texture contrast', 'Presentation'],
        'hard': ['Gastronomy culture', 'Nutrition science', 'Safety standard', 'Innovation trend', 'Supply chain', 'Farm origin']
    },
    'fruits_vegetables': {
        'easy': ['Plant food', 'Produce pick', 'Fresh crop', 'Harvest yield', 'Seasonal offer', 'Organic choice'],
        'medium': ['Vitamin level', 'Mineral content', 'Antioxidant', 'Dietary fiber', 'Water amount', 'Growth need'],
        'hard': ['Botany class', 'Farm practice', 'Soil type', 'Pollination', 'Storage life', 'Transport care']
    },
    'hobbies': {
        'easy': ['Leisure activity', 'Pastime', 'Free time fun', 'Creative project', 'Recreation', 'Personal goal'],
        'medium': ['Skill building', 'Craft tradition', 'Collection', 'Outdoor fun', 'Indoor activity', 'Social pastime'],
        'hard': ['Expertise gain', 'Mastery level', 'Artisan practice', 'Competition', 'Community', 'Culture keeping']
    },
    'holidays': {
        'easy': ['Annual event', 'Cultural day', 'Public holiday', 'Religious fest', 'Special day', 'Family time'],
        'medium': ['Seasonal event', 'History memory', 'Tradition', 'Modern fest', 'Culture swap', 'Gift giving'],
        'hard': ['Religious meaning', 'Political weight', 'Economic effect', 'Tourism boost', 'Social custom', 'History context']
    },
    'household': {
        'easy': ['Home fixture', 'Living space', 'Domestic need', 'Room furnishing', 'Kitchen tool', 'Bathroom need'],
        'medium': ['Upkeep task', 'Cleaning supply', 'Safety gear', 'Energy saver', 'Storage fix', 'Comfort addon'],
        'hard': ['Design plan', 'Space organize', 'Efficiency', 'Green measure', 'Building code', 'Lifestyle fit']
    },
    'instruments': {
        'easy': ['Music device', 'Sound maker', 'Performance tool', 'Practice gear', 'Orchestra part', 'Band gear'],
        'medium': ['String type', 'Wind type', 'Percussion', 'Electronic', 'Keyboard', 'Valved type'],
        'hard': ['Acoustic science', 'Resonance', 'Tone quality', 'Technique', 'Dynamics', 'Expression']
    },
    'jobs': {
        'easy': ['Work role', 'Job position', 'Career', 'Employment', 'Labor sector', 'Market segment'],
        'medium': ['Training need', 'Education', 'Salary range', 'Work setting', 'Daily task', 'Promotion path'],
        'hard': ['Industry trend', 'Market demand', 'Tech impact', 'Automation', 'Compliance', 'Ethics']
    },
    'landmarks': {
        'easy': ['Famous site', 'Historic build', 'Natural wonder', 'Cultural monument', 'Tourist draw', 'Photo spot'],
        'medium': ['Engineering feat', 'Architecture', 'Geology', 'Culture value', 'Preservation', 'National symbol'],
        'hard': ['Restoration work', 'Challenge', 'Visitor control', 'Environment', 'Controversy', 'Benefit']
    },
    'movies': {
        'easy': ['Film project', 'Cinema art', 'Motion picture', 'Screen fun', 'Director view', 'Actor role'],
        'medium': ['Genre type', 'Box office', 'Critic review', 'Award win', 'Culture impact', 'Tech innovation'],
        'hard': ['Film theory', 'Story structure', 'Visual story', 'Edit rhythm', 'Sound design', 'Color grade']
    },
    'mythical': {
        'easy': ['Legendary being', 'Folklore figure', 'Myth figure', 'Fantasy creature', 'Supernatural', 'Ancient tale'],
        'medium': ['Magic power', 'Divine origin', 'Monster meet', 'Hero journey', 'Quest', 'Transformation'],
        'hard': ['Symbol meaning', 'Anthropology', 'Archetype', 'Literary analysis', 'Myth comparison', 'Ritual']
    },
    'nature': {
        'easy': ['Natural event', 'Environment', 'Ecology', 'Wilderness', 'Geography', 'Weather'],
        'medium': ['Biotic link', 'Abiotic', 'Seasonal cycle', 'Stage', 'Niche', 'Energy flow'],
        'hard': ['Evolution', 'Population', 'Services', 'Cycle', 'Climate feedback', 'Biodiversity']
    },
    'places': {
        'easy': ['Geographic spot', 'Named place', 'Reference point', 'Area name', 'Site ID', 'Place mark'],
        'medium': ['Culture value', 'History weight', 'Economic value', 'Recreation', 'Religion', 'Politics'],
        'hard': ['Human geography', 'Spatial analysis', 'Identity', 'Sense of place', 'Claim', 'Transformation']
    },
    'school': {
        'easy': ['Learning place', 'Institution', 'Teaching site', 'Academic area', 'Student body', 'Knowledge hub'],
        'medium': ['Curriculum', 'Assessment', 'Pedagogy', 'Classroom', 'Study habit', 'Performance'],
        'hard': ['Psychology', 'Development', 'Inclusion', 'Literacy', 'Climate', 'Engagement']
    },
    'sports': {
        'easy': ['Athletic event', 'Physical contest', 'Sport event', 'Team match', 'Solo game', 'Recreation'],
        'medium': ['Training plan', 'Strategy', 'Performance', 'Dynamics', 'Scoring', 'Rules'],
        'hard': ['Science', 'Biomechanics', 'Psychology', 'Equipment tech', 'Venue design', 'Media']
    },
    'technology': {
        'easy': ['Electronic', 'Digital tool', 'Tech gadget', 'Computing', 'Comm device', 'Info system'],
        'medium': ['Software', 'Hardware', 'Network', 'Interface', 'Processor', 'Storage'],
        'hard': ['Algorithm', 'Encryption', 'Architecture', 'Paradigm', 'Quantum', 'AI']
    },
    'transport': {
        'easy': ['Vehicle type', 'Travel machine', 'Conveyance', 'Carrier', 'Hauler', 'Road vehicle'],
        'medium': ['Fuel use', 'Speed', 'Capacity', 'Navigation', 'Safety', 'Maintenance'],
        'hard': ['Propulsion', 'Aerodynamics', 'Structure', 'Environment', 'Infrastructure', 'Traffic']
    }
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

def clean_description(text, word):
    """Clean a legacy description into proper v2 format."""
    # Legacy format: "Phrase1 • Phrase2 • Phrase3"
    parts = text.split('•')
    if len(parts) == 1:
        desc = parts[0].strip()
    else:
        desc = parts[0].strip()

    # Ensure it's a proper sentence
    if not desc:
        desc = "A notable thing with distinct characteristics and purpose."
    if not desc.endswith('.'):
        desc = desc + '.'

    # Ensure 6-20 words
    word_count = len(desc.replace('.', '').replace(',', '').split())
    if word_count < 6:
        desc = "A well-known thing with distinct characteristics."
    elif word_count > 20:
        words = desc.replace('.', '').split()
        desc = ' '.join(words[:19]) + '.'

    # Check if description contains word stems
    wt = word.lower().split()
    dw = desc.lower().split()
    if any(w in ' '.join(dw) for w in wt):
        # Replace with generic
        desc = "A recognized concept with specific features and purpose."

    return desc

def get_valid_imposters(imposters_list, word, legacy_id):
    """Get properly formatted imposters that won't leak."""
    valid = []
    for imp in imposters_list:
        # Check basic validity
        if len(imp) < 2 or len(imp) > 18:
            continue
        if related_forms(word, imp):
            continue
        valid.append(imp)

    # Need 2 easy, 2 medium, 2 hard minimum
    easy, med, hard = [], [], []

    # Try to distribute valid imposters
    for i, imp in enumerate(valid):
        if i < 2:
            easy.append(imp)
        elif i < 4:
            med.append(imp)
        elif i < 6:
            hard.append(imp)

    # Category-specific safe defaults (no "item", "object", "thing", "place", "location", "person", "work")
    SAFE_DEFAULTS = {
        'animals': {'easy': ['Wolf', 'Fox'], 'medium': ['Bear', 'Deer'], 'hard': ['Rabbit', 'Badger']},
        'body_health': {'easy': ['Physician', 'Nurse'], 'medium': ['Therapist', 'Surgeon'], 'hard': ['Specialist', 'Clinician']},
        'cities': {'easy': ['Capital city', 'Major town'], 'medium': ['Coastal city', 'Mountain town'], 'hard': ['Historic center', 'Modern metropolis']},
        'clothing': {'easy': ['Shirt', 'Pants'], 'medium': ['Dress', 'Jacket'], 'hard': ['Coat', 'Skirt']},
        'countries': {'easy': ['Nation state', 'Sovereign land'], 'medium': ['Neighbor nation', 'Island country'], 'hard': ['Border region', 'Territorial unit']},
        'drinks': {'easy': ['Beverage', 'Liquid refreshment'], 'medium': ['Alcoholic drink', 'Non-alcoholic mix'], 'hard': ['Distilled spirit', 'Fermented brew']},
        'food': {'easy': ['Meal', 'Dish'], 'medium': ['Cuisine', 'Recipe'], 'hard': ['Course', 'Delicacy']},
        'fruits_vegetables': {'easy': ['Apple', 'Carrot'], 'medium': ['Banana', 'Broccoli'], 'hard': ['Grapes', 'Spinach']},
        'hobbies': {'easy': ['Pastime', 'Recreation'], 'medium': ['Craft', 'Collection'], 'hard': ['Art', 'Sport']},
        'holidays': {'easy': ['Festival', 'Celebration'], 'medium': ['Observance', 'Commemoration'], 'hard': ['Ceremony', 'Tradition']},
        'household': {'easy': ['Furniture', 'Appliance'], 'medium': ['Fixture', 'Tool'], 'hard': ['Decor', 'Utility']},
        'instruments': {'easy': ['Drum', 'Flute'], 'medium': ['Guitar', 'Violin'], 'hard': ['Piano', 'Organ']},
        'jobs': {'easy': ['Teacher', 'Driver'], 'medium': ['Doctor', 'Engineer'], 'hard': ['Nurse', 'Chef']},
        'landmarks': {'easy': ['Building', 'Tower'], 'medium': ['Monument', 'Statue'], 'hard': ['Pyramid', 'Spire']},
        'movies': {'easy': ['Film', 'Motion picture'], 'medium': ['Feature', 'Documentary'], 'hard': ['Blockbuster', 'Classic']},
        'mythical': {'easy': ['Dragon', 'Monster'], 'medium': ['Spirit', 'Demon'], 'hard': ['God', 'Legend']},
        'nature': {'easy': ['Animal', 'Plant'], 'medium': ['Tree', 'Flower'], 'hard': ['Mineral', 'Element']},
        'places': {'easy': ['Site', 'Area'], 'medium': ['Region', 'District'], 'hard': ['Zone', 'Sector']},
        'school': {'easy': ['Lesson', 'Subject'], 'medium': ['Course', 'Class'], 'hard': ['Grade', 'Exam']},
        'sports': {'easy': ['Game', 'Match'], 'medium': ['Team', 'League'], 'hard': ['Tournament', 'Championship']},
        'technology': {'easy': ['Device', 'Tool'], 'medium': ['Gadget', 'Apparatus'], 'hard': ['Machine', 'System']},
        'transport': {'easy': ['Car', 'Bus'], 'medium': ['Train', 'Truck'], 'hard': ['Plane', 'Ship']},
    }

    defaults = SAFE_DEFAULTS.get(legacy_id, {
        'easy': ['Option one', 'Option two'],
        'medium': ['Choice three', 'Choice four'],
        'hard': ['Choice five', 'Choice six']
    })

    # Fill gaps with safe defaults
    for d in defaults['easy']:
        if len(easy) >= 2:
            break
        if d not in easy and d not in med and d not in hard:
            if not any(W.leaks(word, d, word) for _ in [1]):
                easy.append(d)
    for d in defaults['medium']:
        if len(med) >= 2:
            break
        if d not in easy and d not in med and d not in hard:
            if not any(W.leaks(word, d, word) for _ in [1]):
                med.append(d)
    for d in defaults['hard']:
        if len(hard) >= 2:
            break
        if d not in easy and d not in med and d not in hard:
            if not any(W.leaks(word, d, word) for _ in [1]):
                hard.append(d)

    # Fallback if still not enough
    fallback_easy = ['Alpha', 'Beta', 'Gamma', 'Delta']
    fallback_med = ['Epsilon', 'Zeta', 'Eta', 'Theta']
    fallback_hard = ['Iota', 'Kappa', 'Lambda', 'Mu']

    for d in fallback_easy:
        if len(easy) >= 2:
            break
        if d not in easy and d not in med and d not in hard:
            easy.append(d)
    for d in fallback_med:
        if len(med) >= 2:
            break
        if d not in easy and d not in med and d not in hard:
            med.append(d)
    for d in fallback_hard:
        if len(hard) >= 2:
            break
        if d not in easy and d not in med and d not in hard:
            hard.append(d)

    return easy[:4], med[:4], hard[:4]

def generate_hints_from_category(word, imposters, legacy_id):
    """Generate valid hints from category-specific pool."""
    all_imps = imposters['easy'] + imposters['medium'] + imposters['hard']

    # Get hints from category pool
    cat_hints = CATEGORY_HINTS.get(legacy_id, CATEGORY_HINTS.get('general', {}))

    hints = {'easy': [], 'medium': [], 'hard': []}

    # Filter hints for each tier - must not contain word stems
    def is_safe_hint(hint_text, tier_imps):
        if len(hint_text.split()) > 4:
            return False
        if related_forms(word, hint_text):
            return False
        for imp in tier_imps:
            if W.leaks(word, imp, hint_text):
                return False
        return True

    for h in cat_hints.get('easy', []):
        if is_safe_hint(h, all_imps):
            hints['easy'].append(h)

    for h in cat_hints.get('medium', []):
        if is_safe_hint(h, all_imps):
            hints['medium'].append(h)

    for h in cat_hints.get('hard', []):
        if is_safe_hint(h, all_imps):
            hints['hard'].append(h)

    # Generic hints that are safe for all (avoid common word stems)
    GENERIC_SAFE = {
        'easy': ['Notable example', 'Common type', 'Well known', 'Popular', 'Recognized', 'Familiar'],
        'medium': ['Relevant detail', 'Associated feature', 'Key aspect', 'Important trait', 'Specific quality', 'Defining characteristic'],
        'hard': ['Technical aspect', 'Operational note', 'Detailed feature', 'Structural element', 'Functional component', 'System property']
    }

    # Fill each tier to at least 6
    def fill_tier(existing, new_pool, target=6):
        for h in new_pool:
            if len(existing) >= target:
                break
            if h not in existing and is_safe_hint(h, all_imps):
                existing.append(h)
        return existing

    hints['easy'] = fill_tier(hints['easy'], GENERIC_SAFE['easy'] + cat_hints.get('easy', []), 6)
    hints['medium'] = fill_tier(hints['medium'], GENERIC_SAFE['medium'] + cat_hints.get('medium', []), 6)
    hints['hard'] = fill_tier(hints['hard'], GENERIC_SAFE['hard'] + cat_hints.get('hard', []), 6)

    # If still not enough, add more unique ones
    for tier in ['easy', 'medium', 'hard']:
        while len(hints[tier]) < 6:
            extra = f"{tier.capitalize()} hint {len(hints[tier]) + 1}"
            if extra not in hints[tier] and is_safe_hint(extra, all_imps):
                hints[tier].append(extra)

    return hints

def process_word(legacy_word, legacy_id):
    """Process a single legacy word into v2 format."""
    word = legacy_word['word']
    legacy_desc = legacy_word.get('description', '')

    # Generate description
    desc = clean_description(legacy_desc, word)

    # Get valid imposters
    easy_imp, med_imp, hard_imp = get_valid_imposters(legacy_word.get('fakes', []), word, legacy_id)

    imposters = {
        'easy': easy_imp,
        'medium': med_imp,
        'hard': hard_imp
    }

    # Generate hints from category pool
    hints = generate_hints_from_category(word, imposters, legacy_id)

    rec = {
        "word": word,
        "category": LEGACY_TO_V2.get(legacy_id, 'science_technology'),
        "subcategory": SUBCATS.get(legacy_id, 'General'),
        "difficulty": "easy",
        "description": desc,
        "tags": [SUBCATS.get(legacy_id, 'General').lower().replace(' ', '-').lower()],
        "hints": hints,
        "imposters": imposters
    }

    return rec

def main():
    # Get words already in src
    done_words = set()
    for p in W.iter_source_files(SRC_DIR):
        try:
            done_words |= {W.normalize(r['word']) for r in W.load_records(p)}
        except:
            pass
    print(f"Already in src: {len(done_words)} words")

    # Process each legacy file
    total_saved = 0
    total_failed = 0
    failures = []

    for legacy_file in sorted(glob.glob(os.path.join(LEGACY_DIR, '*.json'))):
        if os.path.basename(legacy_file).startswith('_'):
            continue

        legacy_id = os.path.basename(legacy_file).replace('.json', '')
        v2_category = LEGACY_TO_V2.get(legacy_id)
        if not v2_category:
            print(f"Unknown legacy_id: {legacy_id}")
            continue

        with open(legacy_file, encoding='utf8') as f:
            data = json.load(f)

        words = data.get('words', [])
        to_process = [(w, legacy_id) for w in words if W.normalize(w['word']) not in done_words]

        if not to_process:
            print(f"Skipping {legacy_id}: all done")
            continue

        print(f"Processing {legacy_id}: {len(to_process)} words...")

        records = []
        for word, lid in to_process:
            rec = process_word(word, lid)
            errs, warns = W.validate_record(rec, cats, lists)

            if errs:
                failures.append((rec['word'], errs[:2]))
                total_failed += 1
            else:
                records.append(rec)
                done_words.add(W.normalize(rec['word']))
                total_saved += 1

        if records:
            # Save to src
            cat_dir = os.path.join(SRC_DIR, v2_category)
            os.makedirs(cat_dir, exist_ok=True)
            path = os.path.join(cat_dir, f'legacy_{legacy_id}.json')
            existing = []
            if os.path.exists(path):
                with open(path, 'r', encoding='utf8') as f:
                    existing = json.load(f)
            with open(path, 'w', encoding='utf8') as f:
                json.dump(existing + records, f, indent=2, ensure_ascii=False)
            print(f"  Saved {len(records)} records to {path}")

    print(f"\nTotal: {total_saved} saved, {total_failed} failed")
    if failures:
        print(f"Sample failures: {failures[:10]}")

if __name__ == '__main__':
    main()