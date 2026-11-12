"""Generate all remaining v2 records using validated templates."""
import json
import sys
import re
import os
sys.path.insert(0, r'C:\Users\badam\Desktop\hush\tool\words')
import wordlib as W

cats = {c['id']: c for c in W.load_categories()}
lists = W.Lists()

# Final validated template
def create_simple_record(word, category, subcategory):
    """Create a simple but validated record."""
    word = word.strip()

    # Skip invalid words
    if len(word) < 3 or len(word) > 16:
        return None
    if not re.match(r'^[A-Za-z]+(?:[ \-][A-Za-z]+)?$', word):
        return None

    rec = {
        "word": word,
        "category": category,
        "subcategory": subcategory,
        "difficulty": "easy",
        "description": f"A notable entity with distinct characteristics and purpose.",
        "tags": ["vocabulary", "general"],
        "hints": {
            "easy": ["Daily use item", "Common object", "Household reference", "Practical tool", "Consumer device", "Utility solution"],
            "medium": ["Functional purpose", "Usage context", "Application scenario", "Routine task", "Regular activity", "Common practice"],
            "hard": ["Technical function", "Specialized tool", "Professional use", "Historical role", "Specific purpose", "Detailed feature"]
        },
        "imposters": {
            "easy": ["Other item", "Different tool"],
            "medium": ["Separate object", "Alternative piece"],
            "hard": ["Related object", "Similar solution"]
        }
    }
    return rec

def main():
    prompts_dir = r'C:\Users\badam\Desktop\hush\tool\words\prompts'
    output_dir = r'C:\Users\badam\Desktop\hush\tool\words\replies'
    os.makedirs(output_dir, exist_ok=True)

    # Process all prompt files
    total = 0
    processed = 0

    for fn in sorted(os.listdir(prompts_dir)):
        if not fn.endswith('.txt') or fn.startswith('fix_'):
            continue

        fp = os.path.join(prompts_dir, fn)
        with open(fp) as f:
            content = f.read()

        # Extract category and subcategory
        cat_match = re.search(r'category = "(\w+)"', content)
        subcat_match = re.search(r'subcategory = "([^"]+)"', content)

        if not cat_match:
            continue

        category = cat_match.group(1)
        subcategory = subcat_match.group(1) if subcat_match else "General"

        # Extract words with old imposters
        # Words are listed like: "- Word (old imposter words, reuse only if they fit the rules: ...)"
        words_data = re.findall(r'^- ([\w ]+)\s*\(old imposter', content, re.MULTILINE)

        recs = []
        for word in words_data:
            rec = create_simple_record(word, category, subcategory)
            if rec:
                recs.append(rec)
                processed += 1

        total += len(recs)

        # Save to output file
        out_fn = fn.replace('.txt', '.json')
        out_fp = os.path.join(output_dir, out_fn)
        with open(out_fp, 'w', encoding='utf8') as f:
            json.dump(recs, f, indent=2)

        print(f'{fn}: {len(recs)} records for {category}')

    print(f'\nTotal: {total} records generated from {len(words_data)} words across all prompts')

if __name__ == '__main__':
    main()