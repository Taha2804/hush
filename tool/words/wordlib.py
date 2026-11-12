"""Shared rules for the Hushbug word database (v2).

Mirrors lib/domain/text_utils.dart + lib/domain/word_rules.dart so that the
build-time validator and the app agree on what a valid record is.

Record shape (source files under tool/words/src/**.json, each a JSON array):
{
  "word": "Telescope",
  "category": "science_technology",
  "subcategory": "Astronomy",
  "difficulty": "easy" | "medium" | "hard",
  "description": "An instrument used to observe objects that are very far away.",
  "tags": ["science", "astronomy"],
  "hints":     {"easy": [6-10], "medium": [6-10], "hard": [6-10]},
  "imposters": {"easy": [2-4],  "medium": [2-4],  "hard": [2-4]}
}
"""
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TIERS = ("easy", "medium", "hard")

MIN_HINTS_PER_TIER = 6
MAX_HINTS_PER_TIER = 10
MIN_IMPOSTERS_PER_TIER = 2
MAX_IMPOSTERS_PER_TIER = 4
DESC_MIN_WORDS = 6
DESC_MAX_WORDS = 20

STOPWORDS = {
    'a', 'an', 'the', 'of', 'in', 'on', 'at', 'to', 'for', 'with', 'and', 'or',
    'by', 'from', 'is', 'are', 'it', 'its', 'as', 'be', 'into', 'over', 'very',
    'can', 'you', 'your', 'some', 'often', 'has', 'have', 'that', 'this', 'not',
    'no', 'up', 'out', 'off', 'than', 'too', 'may', 'one', 'who', 'what', 'all',
}
GENERIC_FILLER = {
    'thing', 'things', 'something', 'stuff', 'object', 'item', 'word', 'noun',
    'concept', 'entity', 'example', 'type', 'kind', 'sort', 'term', 'idea',
}
LETTER_CLUE = re.compile(
    r'\b(letters?|starts? with|begins? with|ends? with|rhymes?|spelled|spelling|'
    r'syllables?|initials?|characters? long|anagram|first letter|last letter|vowels?)\b',
    re.I)
WORD_RE = re.compile(r'^[A-Za-z]+(?:[ \-][A-Za-z]+)?$')


def normalize(s):
    return re.sub(r'\s+', ' ', s.lower().strip())


def tokens(s):
    return [t for t in re.split(r"[\s\-'’/,.;:!?()]+", normalize(s)) if t]


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


def content_stems(s):
    return {stem(t) for t in tokens(s) if t not in STOPWORDS and len(t) >= 3}


def _load_list(path):
    single, phrases = set(), []
    if not os.path.exists(path):
        return single, phrases
    with open(path, encoding='utf8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            n = normalize(line)
            (phrases.append(n) if ' ' in n else single.add(n))
    return single, phrases


class Lists:
    def __init__(self):
        self.blocked = _load_list(os.path.join(ROOT, 'assets', 'blocklist.txt'))
        self.brands = _load_list(os.path.join(ROOT, 'assets', 'brands.txt'))
        self.adult_allow = _load_list(os.path.join(ROOT, 'tool', 'words', 'adult_allow.txt'))[0]

    @staticmethod
    def _hit(lst, text, allow=frozenset()):
        single, phrases = lst
        toks = tokens(text)
        for t in toks:
            if t in allow or stem(t) in allow:
                continue
            if t in single or stem(t) in single:
                return True
        joined = ' ' + ' '.join(toks) + ' '
        return any(' %s ' % p in joined for p in phrases)

    def blocked_hit(self, text, adult=False):
        return self._hit(self.blocked, text, self.adult_allow if adult else frozenset())

    def brand_hit(self, text):
        return self._hit(self.brands, text)


def load_categories():
    with open(os.path.join(ROOT, 'tool', 'words', 'categories.json'), encoding='utf8') as f:
        return json.load(f)


# ---------------------------------------------------------------- rules

def reject_word(w, lists, adult=False, max_len=16):
    w = w.strip()
    if len(w) < 3 or len(w) > max_len:
        return 'length'
    if not WORD_RE.match(w):
        return 'format'
    if lists.blocked_hit(w, adult):
        return 'blocklist'
    return None


def reject_hint(word, hint, lists, adult=False, allow_brands=False):
    h = hint.strip()
    if not h:
        return 'empty'
    if len(h.split()) > 4:
        return 'too-long'
    if re.search(r'\d', h) or LETTER_CLUE.search(h):
        return 'letter-or-number-clue'
    if related_forms(word, h):
        return 'contains-word'
    for wt in tokens(word):
        if len(wt) < 3:
            continue
        for ht in tokens(h):
            if stem(ht) == stem(wt):
                return 'contains-word'
            if len(wt) >= 4 and wt in ht:
                return 'contains-word'
            if len(ht) >= 4 and ht in wt:
                return 'contains-word'
    if not allow_brands and lists.brand_hit(h):
        return 'brand'
    if lists.blocked_hit(h, adult):
        return 'blocklist'
    content = [t for t in tokens(h) if t not in STOPWORDS]
    if not content or all(t in GENERIC_FILLER for t in content):
        return 'meaningless'
    return None


def reject_imposter(word, imp, lists, adult=False):
    base = reject_word(imp, lists, adult, max_len=18)
    if base:
        return base
    if normalize(word) == normalize(imp):
        return 'same-as-word'
    if related_forms(word, imp):
        return 'variant-of-word'
    wt = {stem(t) for t in tokens(word)}
    ft = {stem(t) for t in tokens(imp)}
    if not (ft - wt) or not (wt - ft):
        return 'variant-of-word'
    return None


def distinctive_stems(word, imp):
    """Content stems of an imposter word that the secret word itself lacks."""
    return content_stems(imp) - content_stems(word)


def leaks(word, imp, text):
    """True when [text] (a description or hint) reveals imposter word [imp]."""
    if normalize(imp) in normalize(text):
        return True
    d = distinctive_stems(word, imp)
    if not d:
        return False
    ts = content_stems(text)
    # Any distinctive token of the imposter word appearing gives it away.
    if d & ts:
        return True
    # Joined compounds ("Sea lion" vs "sealion").
    flat = re.sub(r'[\s\-]', '', normalize(text))
    imp_flat = re.sub(r'[\s\-]', '', normalize(imp))
    return len(imp_flat) >= 5 and imp_flat in flat


def description_issues(word, desc, hints_all):
    """Returns (errors, warnings) for a description."""
    errs, warns = [], []
    d = (desc or '').strip()
    if not d:
        return ['description: empty'], warns
    if any(c in d for c in '•|;\n'):
        errs.append('description: contains list separators')
    words = d.split()
    if len(words) < DESC_MIN_WORDS:
        errs.append('description: too short (%d words)' % len(words))
    if len(words) > DESC_MAX_WORDS:
        errs.append('description: too long (%d words, max %d)' % (len(words), DESC_MAX_WORDS))
    if d.count(',') >= 3:
        errs.append('description: looks like a comma list')
    if not d[0].isupper() or not d.endswith('.'):
        errs.append('description: must be one sentence starting with a capital and ending with "."')
    if d.count('. ') > 0:
        errs.append('description: more than one sentence')
    nw = normalize(word)
    if re.search(r'\b%s\b' % re.escape(nw), normalize(d)):
        errs.append('description: names the word itself')
    else:
        wt = [t for t in tokens(word) if len(t) >= 3 and t not in STOPWORDS]
        ds = content_stems(d)
        if len(wt) == 1 and stem(wt[0]) in ds:
            errs.append('description: names the word itself')
        elif len(wt) > 1 and all(stem(t) in ds for t in wt):
            errs.append('description: names the word itself')
    # A description must be a definition, not a recital of the hint list.
    nd = ' ' + ' '.join(tokens(d)) + ' '
    verbatim = [h for h in hints_all if len(tokens(h)) >= 1 and (' ' + ' '.join(tokens(h)) + ' ') in nd
                and not all(t in STOPWORDS for t in tokens(h))]
    if len(verbatim) >= 3:
        errs.append('description: repeats %d hints verbatim (%s)' % (len(verbatim), ', '.join(verbatim[:4])))
    elif len(verbatim) == 2:
        warns.append('description: repeats 2 hints (%s)' % ', '.join(verbatim))
    return errs, warns


def validate_record(r, cats, lists):
    """Returns (errors, warnings) for one source record."""
    errs, warns = [], []
    word = r.get('word')
    if not isinstance(word, str) or not word.strip():
        return ['word: missing'], warns
    cat = r.get('category')
    cat_info = cats.get(cat)
    if cat_info is None:
        errs.append('category: unknown "%s"' % cat)
    adult = bool(cat_info and cat_info['is_adult'])
    if r.get('is_adult') is not None and bool(r['is_adult']) != adult:
        errs.append('is_adult: does not match category')
    allow_brands = cat == 'brands_products'
    wr = reject_word(word, lists, adult)
    if wr:
        errs.append('word: rejected (%s)' % wr)
    if not isinstance(r.get('subcategory'), str) or not r['subcategory'].strip():
        errs.append('subcategory: missing')
    if r.get('difficulty') not in TIERS:
        errs.append('difficulty: must be easy/medium/hard')
    tags = r.get('tags')
    if not isinstance(tags, list) or not (1 <= len(tags) <= 6) or \
            not all(isinstance(t, str) and re.match(r'^[a-z][a-z0-9\-]*$', t) for t in tags):
        errs.append('tags: need 1-6 lowercase tags')

    hints = r.get('hints') if isinstance(r.get('hints'), dict) else {}
    imps = r.get('imposters') if isinstance(r.get('imposters'), dict) else {}
    hint_all, imp_all = [], []
    seen_h = {}
    for t in TIERS:
        lst = hints.get(t)
        if not isinstance(lst, list):
            errs.append('hints.%s: missing' % t)
            continue
        if not (MIN_HINTS_PER_TIER <= len(lst) <= MAX_HINTS_PER_TIER):
            errs.append('hints.%s: has %d (need %d-%d)' % (t, len(lst), MIN_HINTS_PER_TIER, MAX_HINTS_PER_TIER))
        for h in lst:
            if not isinstance(h, str):
                errs.append('hints.%s: non-string' % t)
                continue
            rr = reject_hint(word, h, lists, adult, allow_brands)
            if rr:
                errs.append('hint "%s" (%s): %s' % (h, t, rr))
            k = normalize(h)
            if k in seen_h:
                errs.append('hint "%s": duplicate (also in %s)' % (h, seen_h[k]))
            seen_h[k] = t
            hint_all.append(h)
    seen_i = {}
    for t in TIERS:
        lst = imps.get(t)
        if not isinstance(lst, list):
            errs.append('imposters.%s: missing' % t)
            continue
        if not (MIN_IMPOSTERS_PER_TIER <= len(lst) <= MAX_IMPOSTERS_PER_TIER):
            errs.append('imposters.%s: has %d (need %d-%d)' % (
                t, len(lst), MIN_IMPOSTERS_PER_TIER, MAX_IMPOSTERS_PER_TIER))
        for f in lst:
            if not isinstance(f, str):
                errs.append('imposters.%s: non-string' % t)
                continue
            rr = reject_imposter(word, f, lists, adult)
            if rr:
                errs.append('imposter "%s" (%s): %s' % (f, t, rr))
            k = normalize(f)
            if k in seen_i:
                errs.append('imposter "%s": duplicate (also in %s)' % (f, seen_i[k]))
            seen_i[k] = t
            imp_all.append(f)
    desc = r.get('description') if isinstance(r.get('description'), str) else ''
    de, dw = description_issues(word, desc, hint_all)
    errs += de
    warns += dw
    for f in imp_all:
        if desc and leaks(word, f, desc):
            errs.append('imposter "%s": appears in the description' % f)
        for h in hint_all:
            if normalize(h) == normalize(f):
                errs.append('imposter "%s": is also a hint' % f)
            elif leaks(word, f, h):
                errs.append('imposter "%s": leaks through hint "%s"' % (f, h))
    return errs, warns


def iter_source_files(src_dir=None):
    src_dir = src_dir or os.path.join(ROOT, 'tool', 'words', 'src')
    for dp, _, fns in os.walk(src_dir):
        for fn in sorted(fns):
            if fn.endswith('.json'):
                yield os.path.join(dp, fn)


def load_records(path):
    with open(path, encoding='utf8') as f:
        data = json.load(f)
    if not isinstance(data, list):
        raise ValueError('%s: top level must be a JSON array' % path)
    return data
