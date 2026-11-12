"""Process all remaining legacy word batches and generate validated v2 records."""
import json, sys, os, re, glob

sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Load all legacy data
LEGACY = r'C:\Users\badam\Desktop\hush\tool\words\legacy'
SRC = r'C:\Users\badam\Desktop\hush\tool\words\src'

# Track completed words
done_words = set()
for p in W.iter_source_files(SRC):
    try:
        done_words |= {W.normalize(r['word']) for r in W.load_records(p)}
    except:
        pass

print(f"Already completed: {len(done_words)} words")

# Process each legacy category
processed = 0
failed = 0

for leg_file in sorted(glob.glob(os.path.join(LEGACY, '*.json'))):
    fname = os.path.basename(leg_file)
    if fname.startswith('_'):
        continue

    with open(leg_file, encoding='utf8') as f:
        data = json.load(f)

    cat_id = data.get('id', fname.replace('.json', ''))
    cat_info = cats.get(cat_id)
    if not cat_info:
        print(f"Warning: Unknown category {cat_id}")
        continue

    print(f"\nProcessing {fname} ({cat_info['name']})")

    # Load existing records if any
    dest_dir = os.path.join(SRC, cat_id)
    os.makedirs(dest_dir, exist_ok=True)
    existing_records = []
    for existing_file in glob.glob(os.path.join(dest_dir, '*.json')):
        if 'gen' in existing_file:
            try:
                existing_records.extend(json.load(open(existing_file)))
            except:
                pass
    existing_words = {W.normalize(r['word']) for r in existing_records}

    # Find words to process
    words_to_process = [w for w in data.get('words', [])
                        if W.normalize(w['word']) not in done_words and
                        W.normalize(w['word']) not in existing_words]

    if not words_to_process:
        print(f"  No new words to process")
        continue

    print(f"  Words to process: {len(words_to_process)}")

    # Generate records for each word
    new_records = []
    for w in words_to_process:
        # Map to existing subcategory if possible
        subcat = cat_info.get('subcategory', 'General')
        if subcat not in ['General', 'General category']:
            subcat = subcat.replace(' ', '')[:20]

        rec = {
            "word": w['word'],
            "category": cat_id,
            "subcategory": subcat,
            "difficulty": "easy",  # Default, will refine
            "description": w.get('description', f"A {cat_info.get('name', 'thing')}.")[:200],
            "tags": [cat_id.split('_')[0], cat_info.get('name', '').lower().replace(' ', '_')],
            "hints": {
                "easy": [],
                "medium": [],
                "hard": []
            },
            "imposters": {
                "easy": w.get('fakes', [])[:4] if w.get('fakes') else [],
                "medium": [],
                "hard": []
            }
        }

        # Validate and fix
        errs, warns = W.validate_record(rec, cats, lists)
        if errs:
            print(f"  FAIL: {w['word']} - {errs[:2]}")
            failed += 1
        else:
            new_records.append(rec)
            done_words.add(W.normalize(w['word']))
            processed += 1

    # Save new records
    if new_records:
        out_file = os.path.join(dest_dir, f'gen{len(existing_records)+1:03d}.json')
        with open(out_file, 'w', encoding='utf8') as f:
            json.dump(new_records, f, indent=2)
        print(f"  Saved {len(new_records)} records to {out_file}")

print(f"\nTotal: {processed} processed, {failed} failed")