"""Validates Hushbug word source files.

Usage (from repo root):
    python tool/words/validate_src.py                  # everything under tool/words/src
    python tool/words/validate_src.py tool/words/src/animals   # one folder or file
    python tool/words/validate_src.py --report out.md  # also write a Markdown report

Exit code 1 when any record has errors. Nothing is ever deleted: invalid records
are reported so they can be corrected.
"""
import collections
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wordlib as W  # noqa: E402


def main(argv):
    report = None
    if '--report' in argv:
        i = argv.index('--report')
        report = argv[i + 1]
        argv = argv[:i] + argv[i + 2:]
    targets = argv or [os.path.join(W.ROOT, 'tool', 'words', 'src')]
    files = []
    for t in targets:
        if os.path.isdir(t):
            files += list(W.iter_source_files(t))
        else:
            files.append(t)
    cats = {c['id']: c for c in W.load_categories()}
    lists = W.Lists()
    total = bad = warned = 0
    seen = {}
    lines = []
    reasons = collections.Counter()
    for path in files:
        try:
            recs = W.load_records(path)
        except Exception as e:  # noqa: BLE001
            lines.append('FILE %s: cannot parse: %s' % (path, e))
            bad += 1
            continue
        for r in recs:
            total += 1
            errs, warns = W.validate_record(r, cats, W.Lists() if False else lists)
            key = W.normalize(str(r.get('word', '')))
            if key in seen:
                warns.append('duplicate word (also in %s)' % seen[key])
            else:
                seen[key] = os.path.relpath(path, W.ROOT)
            if errs or warns:
                rel = os.path.relpath(path, W.ROOT)
                for e in errs:
                    lines.append('ERROR %s :: %s :: %s' % (rel, r.get('word'), e))
                    reasons[e.split(':')[0].split('"')[0].strip() + ': ' + e.split(':')[-1].strip().split(' (')[0]] += 1
                for w in warns:
                    lines.append('WARN  %s :: %s :: %s' % (rel, r.get('word'), w))
            if errs:
                bad += 1
            elif warns:
                warned += 1
    summary = '%d records, %d with errors, %d with warnings only' % (total, bad, warned)
    out = '\n'.join(lines + [summary])
    print(out)
    if report:
        with open(report, 'w', encoding='utf8') as f:
            f.write('# Word validation report\n\n%s\n\n## Most common problems\n\n' % summary)
            for k, v in reasons.most_common(30):
                f.write('- %s — %d\n' % (k, v))
            f.write('\n## Details\n\n```\n%s\n```\n' % '\n'.join(lines))
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
