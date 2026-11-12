"""Builds the bundled v2 word packs (assets/packs/*.json + index.json).

Usage (from repo root):
    python tool/words/build_packs.py

Sources, per v2 category in tool/words/categories.json:
  1. v2 records from tool/words/src/**.json that pass validate_record (no errors).
  2. Legacy v1 words from tool/words/legacy/<legacy id>.json for words not yet
     rewritten. They keep their hints (v1 level 3/2/1 -> easy/medium/hard) and
     fakes (as medium imposters) but get NO description: the v1 "description"
     was a bullet list of clues, which v2 forbids showing to the crew.

A word appears in only one pack (v2 records win, then category order).
Adult categories go to assets/packs/adult/. Categories with no words are skipped.
"""
import json
import os
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wordlib as W  # noqa: E402

LEGACY_DIR = os.path.join(W.ROOT, 'tool', 'words', 'legacy')
OUT_DIR = os.path.join(W.ROOT, 'assets', 'packs')
V1_TIER = {3: 'easy', 2: 'medium', 1: 'hard'}


def v2_word(r):
    return {
        'word': r['word'],
        'sub': r.get('subcategory'),
        'diff': r.get('difficulty', 'medium'),
        'desc': r['description'],
        'tags': r.get('tags', []),
        'hints': {t: r['hints'].get(t, []) for t in W.TIERS},
        'imposters': {t: r['imposters'].get(t, []) for t in W.TIERS},
    }


def legacy_word(w):
    word = w['word']
    hints = {t: [] for t in W.TIERS}
    for h in w.get('hints', []):
        hints[V1_TIER.get(h.get('level'), 'medium')].append(h['text'])
    # v2 rule: an imposter word must not be the word, a variant of it, or be
    # given away by any hint. Drop the leaking hint when its tier keeps at
    # least one hint, otherwise drop the imposter word.
    fakes = []
    for f in w.get('fakes', []):
        if W.normalize(f) == W.normalize(word) or W.related_forms(word, f):
            continue
        ok = True
        for t in W.TIERS:
            bad = [h for h in hints[t] if W.leaks(word, f, h)]
            if not bad:
                continue
            if len(hints[t]) - len(bad) >= 1:
                hints[t] = [h for h in hints[t] if h not in bad]
            else:
                ok = False
        if ok:
            fakes.append(f)
    return {
        'word': word,
        'diff': 'medium',
        'hints': hints,
        'imposters': {'easy': [], 'medium': fakes, 'hard': []},
    }


def main():
    cats = W.load_categories()
    cat_ids = {c['id']: c for c in cats}
    lists = W.Lists()
    v2 = {c['id']: [] for c in cats}
    seen = set()
    skipped = 0
    for path in W.iter_source_files():
        for r in W.load_records(path):
            errs, _ = W.validate_record(r, cat_ids, lists)
            key = W.normalize(r['word'])
            if errs or key in seen or r.get('category') not in v2:
                skipped += 1
                continue
            seen.add(key)
            v2[r['category']].append(v2_word(r))

    if os.path.isdir(OUT_DIR):
        for fn in os.listdir(OUT_DIR):
            if fn.endswith('.json'):
                os.remove(os.path.join(OUT_DIR, fn))
        shutil.rmtree(os.path.join(OUT_DIR, 'adult'), ignore_errors=True)
    os.makedirs(OUT_DIR, exist_ok=True)

    index = []
    for c in cats:
        words = list(v2[c['id']])
        legacy_n = 0
        for lid in c.get('legacy', []):
            p = os.path.join(LEGACY_DIR, lid + '.json')
            if not os.path.exists(p):
                continue
            with open(p, encoding='utf8') as f:
                for w in json.load(f)['words']:
                    key = W.normalize(w['word'])
                    if key in seen:
                        continue
                    seen.add(key)
                    words.append(legacy_word(w))
                    legacy_n += 1
        if not words:
            continue
        words.sort(key=lambda w: w['word'].lower())
        adult = bool(c.get('is_adult'))
        pack = {'id': c['id'], 'name': c['name'], 'version': 2, 'is_adult': adult, 'words': words}
        out = os.path.join(OUT_DIR, 'adult') if adult else OUT_DIR
        os.makedirs(out, exist_ok=True)
        with open(os.path.join(out, c['id'] + '.json'), 'w', encoding='utf8') as f:
            json.dump(pack, f, ensure_ascii=False, separators=(',', ':'))
        diff = {t: sum(1 for w in words if w['diff'] == t) for t in W.TIERS}
        index.append({'id': c['id'], 'name': c['name'], 'description': c.get('description', ''),
                      'icon': c.get('icon', 'category'), 'is_adult': adult,
                      'count': len(words), 'difficulty': diff})
        print('%-22s %4d words (%4d v2, %4d legacy)' % (c['id'], len(words), len(words) - legacy_n, legacy_n))

    with open(os.path.join(OUT_DIR, 'index.json'), 'w', encoding='utf8') as f:
        json.dump(index, f, ensure_ascii=False, indent=1)
    print('%d packs, %d words; %d source records skipped (errors/duplicates)' %
          (len(index), sum(p['count'] for p in index), skipped))


if __name__ == '__main__':
    main()
