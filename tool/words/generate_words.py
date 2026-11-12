"""Writes the remaining v2 word records with Claude, validates them, and saves
the good ones to tool/words/src/. Resumable: words already in src are skipped,
so you can stop (Ctrl+C) and re-run any time.

Setup (once):
    PowerShell:  $env:ANTHROPIC_API_KEY = "sk-ant-..."
    bash:        export ANTHROPIC_API_KEY=sk-ant-...

Usage (from repo root):
    python tool/words/generate_words.py --status              # what's left, no API calls
    python tool/words/generate_words.py                       # rewrite every remaining legacy word
    python tool/words/generate_words.py --only transport      # one legacy pack
    python tool/words/generate_words.py --limit 20            # try a small batch first
    python tool/words/generate_words.py --new brands_products --count 150   # brand-new words
    python tool/words/generate_words.py --dry-run --only food # print the prompt, no API call

Options: --batch N (words per request, default 10), --model ID
(default: $HUSH_MODEL or claude-sonnet-5-5), --no-build (skip rebuilding packs).

Each batch is checked with the same validator as validate_src.py. Failed records
are sent back once with the exact errors; anything still failing goes to
tool/words/rejected/ for a manual look (it is never shipped).
When done, it runs build_packs.py so assets/packs/ is up to date.
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys
import time
import urllib.error
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wordlib as W  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, 'src')
LEGACY = os.path.join(HERE, 'legacy')
REJECTED = os.path.join(HERE, 'rejected')
API_URL = 'https://api.anthropic.com/v1/messages'


# ---------------------------------------------------------------- data

def src_words():
    out = set()
    for p in W.iter_source_files(SRC):
        try:
            out |= {W.normalize(r['word']) for r in W.load_records(p)}
        except Exception:  # noqa: BLE001
            pass
    return out


def all_known_words():
    known = src_words()
    for p in glob.glob(os.path.join(LEGACY, '*.json')):
        if os.path.basename(p).startswith('_'):
            continue
        with open(p, encoding='utf8') as f:
            known |= {W.normalize(w['word']) for w in json.load(f)['words']}
    return known


def remaining_legacy(only=None):
    """[(legacy_id, v2_category, [legacy word dicts])] not yet in src."""
    done = src_words()
    out = []
    for c in W.load_categories():
        for lid in c.get('legacy', []):
            if only and lid != only and c['id'] != only:
                continue
            p = os.path.join(LEGACY, lid + '.json')
            if not os.path.exists(p):
                continue
            with open(p, encoding='utf8') as f:
                words = [w for w in json.load(f)['words'] if W.normalize(w['word']) not in done]
            if words:
                out.append((lid, c, words))
    return out


def next_part_path(folder):
    os.makedirs(folder, exist_ok=True)
    n = 1
    while os.path.exists(os.path.join(folder, 'gen%03d.json' % n)):
        n += 1
    return os.path.join(folder, 'gen%03d.json' % n)


def save_records(folder, recs):
    path = next_part_path(folder)
    with open(path, 'w', encoding='utf8') as f:
        f.write('[\n' + ',\n'.join(json.dumps(r, ensure_ascii=False, separators=(',', ':')) for r in recs) + '\n]\n')
    return path


# ---------------------------------------------------------------- API

def call_claude(model, system, user, max_tokens=16000):
    key = os.environ.get('ANTHROPIC_API_KEY')
    if not key:
        sys.exit('Set ANTHROPIC_API_KEY first (see the top of this file).')
    body = json.dumps({
        'model': model, 'max_tokens': max_tokens, 'system': system,
        'messages': [{'role': 'user', 'content': user}],
    }).encode('utf8')
    for attempt in range(5):
        req = urllib.request.Request(API_URL, data=body, method='POST', headers={
            'x-api-key': key, 'anthropic-version': '2023-06-01', 'content-type': 'application/json'})
        try:
            with urllib.request.urlopen(req, timeout=300) as r:
                data = json.loads(r.read())
            return ''.join(b.get('text', '') for b in data.get('content', []) if b.get('type') == 'text')
        except urllib.error.HTTPError as e:
            msg = e.read().decode('utf8', 'replace')[:300]
            if e.code in (429, 500, 502, 503, 529) and attempt < 4:
                wait = 2 ** attempt * 5
                print('  API %d, retrying in %ds' % (e.code, wait))
                time.sleep(wait)
                continue
            sys.exit('API error %d: %s' % (e.code, msg))
        except (urllib.error.URLError, TimeoutError) as e:
            if attempt < 4:
                time.sleep(10)
                continue
            sys.exit('Network error: %s' % e)
    return ''


def parse_array(text):
    text = re.sub(r'^```(?:json)?\s*|\s*```$', '', text.strip())
    start, end = text.find('['), text.rfind(']')
    if start < 0 or end < 0:
        return []
    try:
        data = json.loads(text[start:end + 1])
    except json.JSONDecodeError:
        return []
    return [r for r in data if isinstance(r, dict)]


# ---------------------------------------------------------------- prompts

def system_prompt():
    with open(os.path.join(HERE, 'WRITING_GUIDE.md'), encoding='utf8') as f:
        guide = f.read()
    cats = ', '.join(c['id'] for c in W.load_categories())
    return (guide + '\n\nValid category ids: ' + cats +
            '\n\nOutput ONLY a JSON array of records, no prose, no code fences.')


def rewrite_prompt(cat, words):
    lines = []
    for w in words:
        fakes = ', '.join(w.get('fakes', []))
        lines.append('- %s (old imposter words, reuse only if they fit the rules: %s)' % (w['word'], fakes))
    return ('Write one v2 record for EACH of these %d words. category = "%s" (%s).\n'
            'Keep each word exactly as written.\n\n%s' % (len(words), cat['id'], cat['name'], '\n'.join(lines)))


def new_prompt(cat, n, avoid):
    sample = ', '.join(sorted(avoid)[:400])
    return ('Invent %d NEW words for category "%s" (%s: %s) and write one v2 record for each. '
            'Mix difficulties (about 40%% easy, 40%% medium, 20%% hard). '
            'Do NOT use any of these existing words: %s'
            % (n, cat['id'], cat['name'], cat.get('description', ''), sample))


def fix_prompt(bad):
    parts = ['Fix these records. Each one failed validation for the listed reasons. '
             'Return the corrected records as a JSON array (same words).\n']
    for r, errs in bad:
        parts.append('ERRORS: %s\nRECORD: %s\n' % ('; '.join(errs), json.dumps(r, ensure_ascii=False)))
    return '\n'.join(parts)


# ---------------------------------------------------------------- manual (browser chatbot)

PROMPTS = os.path.join(HERE, 'prompts')
REPLIES = os.path.join(HERE, 'replies')
NAME_RE = re.compile(r'^(fix_)?(\d{3})_(.+)\.(?:txt|json)$')


def manual_prompt(system, body):
    return ('You are writing word records for a party game. Follow this guide EXACTLY.\n\n'
            '=== GUIDE START ===\n' + system + '\n=== GUIDE END ===\n\n' + body +
            '\n\nReply with ONE JSON array only, inside a single ```json code block. '
            'No explanations before or after.\n')


def export_prompts(system, only, batch):
    os.makedirs(PROMPTS, exist_ok=True)
    os.makedirs(REPLIES, exist_ok=True)
    for fn in os.listdir(PROMPTS):
        if fn.endswith('.txt'):
            os.remove(os.path.join(PROMPTS, fn))
    n = 0
    for lid, cat, words in remaining_legacy(only):
        for i in range(0, len(words), batch):
            n += 1
            with open(os.path.join(PROMPTS, '%03d_%s.txt' % (n, lid)), 'w', encoding='utf8') as f:
                f.write(manual_prompt(system, rewrite_prompt(cat, words[i:i + batch])))
    print('Wrote %d prompt files to %s' % (n, PROMPTS))
    print('Save each reply as tool/words/replies/<same name>.json, then run --import')


def import_replies(cats, lists, system):
    os.makedirs(REPLIES, exist_ok=True)
    done_dir = os.path.join(REPLIES, 'done')
    os.makedirs(done_dir, exist_ok=True)
    cat_of = {lid: c for c in W.load_categories() for lid in c.get('legacy', [])}
    left = {lid: {W.normalize(w['word']) for w in ws} for lid, _, ws in remaining_legacy()}
    saved = failed = 0
    for fn in sorted(os.listdir(REPLIES)):
        m = NAME_RE.match(fn)
        if not m or not fn.endswith('.json'):
            continue
        lid = m.group(3)
        cat = cat_of.get(lid)
        if not cat:
            print('%s: unknown pack "%s", skipped' % (fn, lid))
            continue
        with open(os.path.join(REPLIES, fn), encoding='utf8') as f:
            recs = parse_array(f.read())
        if not recs:
            print('%s: no JSON array found - copy the whole reply again' % fn)
            continue
        good, bad, extra = [], [], 0
        for r in recs:
            r['category'] = cat['id']
            key = W.normalize(str(r.get('word', '')))
            if key not in left.get(lid, set()):
                extra += 1
                continue
            errs, _ = W.validate_record(r, cats, lists)
            if errs:
                bad.append((r, errs))
            else:
                good.append(r)
                left[lid].discard(key)
        if good:
            save_records(os.path.join(SRC, lid), good)
        msg = '%s: %d saved, %d failed' % (fn, len(good), len(bad))
        if extra:
            msg += ', %d skipped (already done or word changed)' % extra
        if bad:
            fix = os.path.join(PROMPTS, 'fix_%s_%s.txt' % (m.group(2), lid))
            with open(fix, 'w', encoding='utf8') as f:
                f.write(manual_prompt(system, fix_prompt(bad)))
            msg += ' -> paste prompts/%s and save the reply as replies/%s' % (
                os.path.basename(fix), os.path.basename(fix)[:-4] + '.json')
        print(msg)
        os.replace(os.path.join(REPLIES, fn), os.path.join(done_dir, fn))
        saved += len(good)
        failed += len(bad)
    print('Imported: %d saved, %d need fixing.' % (saved, failed))
    return saved


# ---------------------------------------------------------------- core

def run_batch(model, system, prompt, cat, cats, lists, expected=None):
    """Returns (good, bad) records after one generation + one repair round."""
    recs = parse_array(call_claude(model, system, prompt))
    good, bad = [], []

    def check(rs):
        for r in rs:
            r['category'] = cat['id']
            if expected is not None and W.normalize(str(r.get('word', ''))) not in expected:
                continue
            errs, _ = W.validate_record(r, cats, lists)
            (bad if errs else good).append((r, errs))

    check(recs)
    if bad:
        retry, bad = bad, []
        check(parse_array(call_claude(model, system, fix_prompt(retry))))
    return [r for r, _ in good], bad


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--status', action='store_true')
    ap.add_argument('--only')
    ap.add_argument('--limit', type=int)
    ap.add_argument('--batch', type=int, default=10)
    ap.add_argument('--new')
    ap.add_argument('--count', type=int, default=150)
    ap.add_argument('--model', default=os.environ.get('HUSH_MODEL', 'claude-sonnet-5-5'))
    ap.add_argument('--dry-run', action='store_true')
    ap.add_argument('--no-build', action='store_true')
    ap.add_argument('--export', action='store_true', help='write prompts for a browser chatbot')
    ap.add_argument('--import', dest='import_', action='store_true', help='validate saved chatbot replies')
    a = ap.parse_args()
    try:
        sys.stdout.reconfigure(encoding='utf-8')  # Windows consoles default to cp1252
    except AttributeError:
        pass

    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()
    system = system_prompt()

    if a.export:
        export_prompts(system, a.only, a.batch)
        return
    if a.import_:
        if import_replies(cats, lists, system) and not a.no_build:
            subprocess.run([sys.executable, os.path.join(HERE, 'build_packs.py')], check=False)
        return

    if a.status:
        total = 0
        for lid, cat, words in remaining_legacy(a.only):
            print('%-20s -> %-22s %4d words left' % (lid, cat['id'], len(words)))
            total += len(words)
        print('TOTAL %d legacy words left to rewrite' % total)
        empty = [c for c in cats if not glob.glob(os.path.join(SRC, c, '*.json'))
                 and not cats[c].get('legacy')]
        print('Empty categories (use --new): ' + ', '.join(empty))
        return

    saved = rejected = 0
    try:
        if a.new:
            cat = cats.get(a.new) or sys.exit('unknown category ' + a.new)
            folder = os.path.join(SRC, a.new)
            have = sum(len(W.load_records(p)) for p in W.iter_source_files(folder)) if os.path.isdir(folder) else 0
            while have < a.count:
                n = min(a.batch, a.count - have)
                prompt = new_prompt(cat, n, all_known_words())
                if a.dry_run:
                    print(system, '\n\n----\n', prompt)
                    return
                good, bad = run_batch(a.model, system, prompt, cat, cats, lists)
                known = all_known_words()
                good = [r for r in good if W.normalize(r['word']) not in known]
                if good:
                    print('  saved %d -> %s' % (len(good), save_records(folder, good)))
                if bad:
                    save_records(REJECTED, [r for r, _ in bad])
                saved += len(good)
                rejected += len(bad)
                have += len(good)
                if not good and not bad:
                    print('  empty reply, stopping')
                    break
        else:
            todo = remaining_legacy(a.only)
            left = a.limit
            for lid, cat, words in todo:
                if left is not None and left <= 0:
                    break
                if left is not None:
                    words = words[:left]
                print('%s -> %s: %d words' % (lid, cat['id'], len(words)))
                for i in range(0, len(words), a.batch):
                    chunk = words[i:i + a.batch]
                    prompt = rewrite_prompt(cat, chunk)
                    if a.dry_run:
                        print(system, '\n\n----\n', prompt)
                        return
                    expected = {W.normalize(w['word']) for w in chunk}
                    good, bad = run_batch(a.model, system, prompt, cat, cats, lists, expected)
                    if good:
                        save_records(os.path.join(SRC, lid), good)
                    if bad:
                        save_records(REJECTED, [r for r, _ in bad])
                    saved += len(good)
                    rejected += len(bad)
                    print('  %d/%d  ok %d, rejected %d' % (min(i + a.batch, len(words)), len(words), len(good), len(bad)))
                if left is not None:
                    left -= len(words)
    except KeyboardInterrupt:
        print('\nStopped. Progress is saved; re-run to continue.')

    print('Done: %d saved, %d rejected (see tool/words/rejected/).' % (saved, rejected))
    if saved and not a.no_build:
        subprocess.run([sys.executable, os.path.join(HERE, 'build_packs.py')], check=False)


if __name__ == '__main__':
    main()
