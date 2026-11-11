"""Adds a short description to every word in assets/packs that lacks one.

The description is built from the word's own hints, broad to specific
(for example "Wild animal • Big cat • Lives in a pride • Loud roar"), so it
always describes that exact word and works offline. Hand-written
descriptions already in a pack are kept.

    python tool/add_pack_descriptions.py          # add missing descriptions
    python tool/add_pack_descriptions.py --check  # only report problems
"""
import glob
import json
import os
import re
import sys

PACKS = "assets/packs"


def describe(word):
    hints = sorted(word.get("hints", []), key=lambda h: h.get("level", 0))
    seen, parts = set(), []
    for h in hints:
        text = h["text"].strip()
        key = text.lower()
        if text and key not in seen:
            seen.add(key)
            parts.append(text)
    return " • ".join(parts)


def problems(word):
    w = word["word"]
    d = (word.get("description") or "").strip()
    out = []
    if len(d) < 8:
        out.append("description too short")
    if re.search(r"\b" + re.escape(w.lower()) + r"\b", d.lower()):
        out.append("description gives the word away")
    if len(word.get("hints", [])) < 6:
        out.append("fewer than 6 hints")
    if len(word.get("fakes", [])) < 3:
        out.append("fewer than 3 fake words")
    return out


def main():
    check_only = "--check" in sys.argv
    total = added = 0
    issues = []
    for path in sorted(glob.glob(os.path.join(PACKS, "*.json"))):
        if path.endswith("index.json"):
            continue
        with open(path, encoding="utf8") as f:
            pack = json.load(f)
        changed = False
        for i, word in enumerate(pack["words"]):
            total += 1
            if not check_only and not (word.get("description") or "").strip():
                # Keep "description" right after "word" so packs stay readable.
                rebuilt = {}
                for k, v in word.items():
                    rebuilt[k] = v
                    if k == "word":
                        rebuilt["description"] = describe(word)
                pack["words"][i] = word = rebuilt
                added += 1
                changed = True
            for p in problems(word):
                issues.append(f"{os.path.basename(path)}: {word['word']}: {p}")
        if changed:
            with open(path, "w", encoding="utf8", newline="\n") as f:
                json.dump(pack, f, ensure_ascii=False, indent=1)
                f.write("\n")
    print(f"{total} words, {added} descriptions added, {len(issues)} problems")
    for line in issues[:40]:
        print("  " + line)
    return 1 if issues else 0


if __name__ == "__main__":
    sys.exit(main())
