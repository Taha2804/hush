# Hushbug word writing guide (v2)

Hushbug is an imposter party game. Every round one secret word is chosen.

- **Crew players** see the secret **word** plus its **description** (a short definition).
- In **Hint mode** the imposter does NOT see the word; they get exactly ONE **hint** taken
  from the hint pool of the chosen *Hint Difficulty* tier, so they can bluff.
- In **Fake Word mode** the imposter is secretly given an **imposter word** (a different
  but related word) from the tier matching the chosen *Imposter Difficulty*, and does not
  know they are the imposter.

Because crew players read the description and the imposter may get any hint, the four
fields are strictly separate and must never leak into each other.

## Record format

Each source file is a JSON **array** of records:

```json
{
  "word": "Telescope",
  "category": "science_technology",
  "subcategory": "Astronomy",
  "difficulty": "easy",
  "description": "An instrument used to observe objects that are very far away.",
  "tags": ["science", "astronomy", "equipment"],
  "hints": {
    "easy":   ["Stargazing", "Observatory", "Astronomer", "Night sky", "Planets", "Long tube"],
    "medium": ["Magnification", "Celestial", "Lens", "Tripod", "Eyepiece", "Moon craters"],
    "hard":   ["Galileo", "Focal length", "Light pollution", "Refraction", "Hubble", "Clear night"]
  },
  "imposters": {
    "easy":   ["Camera", "Projector"],
    "medium": ["Binoculars", "Microscope"],
    "hard":   ["Periscope", "Rangefinder"]
  }
}
```

- `category`: one id from `tool/words/categories.json`.
- `subcategory`: short Title Case grouping inside the category ("Big cats", "Desserts").
- `difficulty`: how well-known the WORD itself is: `easy` = everyone knows it,
  `medium` = most adults know it, `hard` = niche / needs general knowledge.
- `tags`: 1–6 lowercase tags (`a-z`, digits, `-`).

## Word
- 3–16 characters, one or two words, letters only (a single space or hyphen between words).
- Keep the existing spelling/casing of words you are given, but fix obvious casing
  ("New york" -> "New York").

## Description (crew only): a DEFINITION, not a clue list
- ONE sentence, 6–20 words (aim for 8–16), starts with a capital and ends with ".".
- Says what the thing actually IS, neutrally, like a good children's dictionary.
- Must NOT contain the word itself (or its plural/stem). For two-word words, don't use
  both of its words.
- Must NOT be a list (no "•", no ";", at most 2 commas).
- Must NOT recite the hints. Reusing at most one hint phrase is tolerated, never 3+.
- Must NOT mention ANY of the imposter words, or any distinctive part of them.
  (Zebra with imposter "Horse": "…related to horses" is FORBIDDEN.)
- Good: Volcano → "An opening in the Earth's surface through which molten rock can escape."
- Good: Penguin → "A flightless seabird known for its upright posture and swimming ability."
- Bad: "Stars, planets, astronomy, space, lenses." (list) / "Lava mountain eruption." (clues)

## Hints (given to the Hint-mode imposter, ONE per round)
Three tiers, **6–10 hints each** (aim for 6–7), all unique across tiers.
Each hint is 1–4 words, no digits, no spelling/letter clues ("starts with B").
A hint must NEVER be another name for the word: no synonyms, regional or foreign
names, nicknames or scientific names (Eggplant: NOT "Aubergine", "Brinjal",
"Solanum melongena"; Rome: NOT "Eternal City"). The same goes for imposter words.

- **easy**: recognizable, fairly direct associations. A player who sees one could
  probably guess the word or at least its area. (Telescope: Stargazing, Observatory)
- **medium**: indirect but meaningful; you must think about the link. (Magnification, Eyepiece)
- **hard**: subtle, less obvious, still logically connected, never random. (Focal length, Refraction)

Mix relationship types inside each tier: activity, location/environment, function/purpose,
associated person, context/situation, part/feature, cultural association.
Six near-identical hints ("Big cat", "Wild cat", "Feline") is NOT acceptable.

A hint must NOT:
- contain the word, its plural/stem, or a part of it ("Zebras", "Striped zebra");
- be a direct synonym or trivial variant of the word ("Spyglass" for Telescope);
- be meaningless filler ("Thing", "Object");
- be a brand name (except in `brands_products`), or anything on the blocklist;
- equal or contain any of this record's imposter words (or their distinctive part).

## Imposter words (Fake Word mode)
Three tiers, **2–4 each**, all unique across tiers. Same format rules as words
(letters, one/two words, ≤18 chars). Never the word itself, a plural/variant, or a synonym.

- **easy**: same broad category, but noticeably different; the crew should catch the
  imposter fairly easily. (Telescope → Camera, Projector)
- **medium**: a meaningful conceptual relationship; shares context or characteristics.
  (Telescope → Binoculars, Microscope)
- **hard**: very close: similar function, environment or look; takes careful discussion
  to separate. (Telescope → Periscope, Rangefinder). Close, but NOT a synonym.

The tiers must reflect real semantic closeness: hard is closer to the word than medium,
medium closer than easy. Think about it per word; don't apply a formula.

Imposter words must NOT appear anywhere in this record's description or hints, not even
partially. If a natural hint would mention an imposter ("Horse cousin" for Zebra with
imposter Horse), pick a different hint OR a different imposter.

## 18+ After Dark (`after_dark`)
Adult party vocabulary: dating, relationships, romance, nightlife, bars and clubs, adult
social situations, hangovers, breakups, mature pop culture. Cheeky is fine. NOT explicit:
no pornographic terms, sex acts or graphic anatomy. The family blocklist still applies,
except the nightlife terms listed in `tool/words/adult_allow.txt` (beer, wine, cocktail,
bar, hangover...). Descriptions stay short and neutral.

## Self-check (mandatory)
Run `python tool/words/validate_src.py <your folder>` and fix EVERY error before you
finish. Warnings are worth fixing too. Do not delete words to silence errors: fix them.
