#!/usr/bin/env python3
"""
Consolidate all countries records into proper source files.
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

# Load all legitimate country names from legacy
with open(LEGACY_FILE) as f:
    legacy_data = json.load(f)
legit_countries = {W.normalize(w['word']) for w in legacy_data.get('words', [])}

# Load all records from countries folder
src_folder = os.path.join(SRC_DIR, 'countries')
all_records = {}

for fn in os.listdir(src_folder):
    if not fn.endswith('.json'):
        continue
    fp = os.path.join(src_folder, fn)
    try:
        with open(fp) as f:
            recs = json.load(f)
        if not isinstance(recs, list):
            continue
        for r in recs:
            word_norm = W.normalize(r.get('word', ''))
            if word_norm in legit_countries:
                if word_norm not in all_records:
                    all_records[word_norm] = r
    except:
        pass

# Also load from other geography files (cities, places, etc.)
for other_folder in ['cities', 'places', 'landmarks']:
    other_src = os.path.join(SRC_DIR, other_folder)
    if os.path.exists(other_src):
        for fn in os.listdir(other_src):
            if not fn.endswith('.json'):
                continue
            fp = os.path.join(other_src, fn)
            try:
                with open(fp) as f:
                    recs = json.load(f)
                if not isinstance(recs, list):
                    continue
                for r in recs:
                    word_norm = W.normalize(r.get('word', ''))
                    if word_norm in legit_countries:
                        if word_norm not in all_records:
                            all_records[word_norm] = r
            except:
                pass

print(f"Found {len(all_records)} legitimate country records")

# Filter to only countries that haven't been processed yet
done = set()
for p in W.iter_source_files(src_folder):
    try:
        recs = W.load_records(p)
        for r in recs:
            done.add(W.normalize(r['word']))
    except:
        pass

remaining = {k: v for k, v in all_records.items() if k not in done}
print(f"{len(remaining)} countries still need processing")

# Save consolidated records
if all_records:
    records_list = list(all_records.values())
    out_file = os.path.join(src_folder, 'countries_consolidated.json')
    with open(out_file, 'w', encoding='utf-8') as f:
        json.dump(records_list, f, ensure_ascii=False, indent=2)
    print(f"Saved consolidated to {out_file}")

# Remove duplicate files
for fn in ['part01.json', 'part02.json'] + [f for f in os.listdir(src_folder) if f.startswith('gen') and f != 'countries_consolidated.json']:
    fp = os.path.join(src_folder, fn)
    if os.path.exists(fp):
        try:
            os.remove(fp)
            print(f"Removed: {fn}")
        except:
            pass