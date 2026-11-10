# Hushbug 🐞🤫

**Find the faker. Keep the secret.**

Hushbug is a 100% free, pass-and-play "imposter" party word game for 3–20 players on one device.
Android, Windows and macOS are built from one Flutter codebase. It has no ads, no accounts, no analytics
and no purchases, and every mode, theme, option and word source is unlocked.

The mascot (a shushing beetle), name, UI and all pack content are original. The mascot is drawn
entirely with `CustomPainter`.

---

## Quick start

Requirements: Flutter **stable** (built with 3.47 / Dart 3.13).

```bash
flutter pub get
dart run build_runner build        # freezed / json_serializable / drift (generated files are committed too)
flutter gen-l10n                   # English + Hindi strings from lib/l10n/*.arb
flutter run                        # pick a connected Android device
flutter run -d windows             # needs Windows + Visual Studio "Desktop development with C++"
flutter run -d macos               # needs a Mac with Xcode
```

### Tests and validators

```bash
flutter test                       # engine, randomness statistics, bags, rotation, persistence,
                                   # validators, online pipeline (recorded fixtures), packs, widgets
dart run tool/validate_packs.dart  # schema, duplicates, hint rules and fake rules; exits 1 on any error
```

### Release builds

```bash
flutter build apk --release        # -> build/app/outputs/flutter-apk/app-release.apk
flutter build windows --release    # -> build/windows/x64/runner/Release/   (Windows host only)
flutter build macos --release      # -> build/macos/Build/Products/Release/Hushbug.app  (macOS host only)
```

> Windows builds need a Windows machine with Visual Studio (not VS Code) and the
> *Desktop development with C++* workload. macOS builds need a Mac with Xcode.
> The GitHub Actions workflow (`.github/workflows/ci.yml`) runs the tests and builds all
> three artifacts on hosted runners, so you can get every build without owning all three platforms.

---

## How to play

1. **Setup**: add players, pick categories (or *Random mix*), a mode, a timer and the number of clue rounds.
2. **Reveal**: pass the device. Each player press-and-holds (or taps) to see their secret card.
   The card can't be reopened after you let go, and Android blocks screenshots while cards are on screen.
3. **Clues**: a randomly chosen starter goes first (with a little roulette). Everyone says ONE word.
4. **Discussion**: a countdown with pause/skip, plus a sound and haptic buzz at the end.
5. **Vote**: either tap the most-voted player or pass the device around for private ballots.
   Ties go to a revote or to the imposters (configurable). With multiple imposters, elimination rounds continue.
6. **Result**: confetti, the imposter(s), the secret word (and the fake word if used), an optional
   last-chance guess, and a running scoreboard. **Play again** keeps players and scores.

**Modes:** Classic · Hint · Fake Word · multiple imposters · Speed round · "Maybe nobody" (configurable chance that there is no imposter).

Keyboard: **Space/Enter** = next, **hold Space** on a card = reveal (hold mode), **Esc** = back.

---

## Word sources

The *Choose word source* screen offers three sources. *Ask me every time the app opens* is on by default.
When it's off, the last source is remembered and the app opens straight on Setup. **Change source** is always
visible, and switching keeps players and scores.

All sources implement `WordSource` (`lib/domain/word_source.dart`). Every source's output goes through the shared
`WordPipeline` (`lib/domain/word_pipeline.dart`): word filter → blocklist → hint/fake validator →
persistent shuffle bag → global recent-history → hint/fake rotation.

### 1. Online Search (no API keys)

`lib/data/sources/online/`

| Step | Service |
|---|---|
| Candidates | Wikipedia `generator=links` on "List of …" pages and `generator=categorymembers`, plus Wikidata SPARQL (instances/subclasses of configured classes) |
| Familiarity ranking | Wikimedia pageviews (`prop=pageviews`, last 60 days) plus Wikidata sitelink counts |
| Hints | Wikipedia REST summary `description` (level 1), ConceptNet `IsA/PartOf/AtLocation/UsedFor/HasProperty/CapableOf/HasA/MadeOf/RelatedTo` ordered by weight, Datamuse `rel_trg` |
| Fake words | Siblings from the same list/category/class that also appear in Datamuse `ml` or ConceptNet `RelatedTo`, never synonyms (`rel_syn`, ConceptNet `Synonym`), plurals, stems or substrings |

* Network: `dio`, 8 s timeouts, at most 5 concurrent requests, retry with exponential backoff, `Retry-After` honoured,
  descriptive User-Agent (Wikimedia policy), negative cache for failed lookups.
* Cache: drift/SQLite. Prefetches ~80 candidates per category in a **background isolate**, tops up when fewer than 20
  unused words remain, uses a 30-day TTL, enriches lazily, and keeps 5 enriched words ahead.
* If you're offline or there are too few words: online cache, then Offline Packs, with a one-line notice.
* **Custom topic** (My Words → 🔍): type any topic, preview the words found on matching Wikipedia category/list pages,
  remove or add words, and save them as a personal pack.
* Category → source mapping lives in `lib/data/sources/online/category_config.dart`.

### 2. Offline Packs (always available)

22 original packs in `assets/packs/*.json` with 3,386 words. Each word has 6 hints (2 per level) and 3+ fake words.

Packs are authored in a compact text format in `tool/packs_src/*.txt` (split into chunk files per category)
and converted to JSON by `tool/build_packs.dart`:

```
@id animals
@name Animals
Lion | Wild animal; Big cat | Lives in a pride; Loud roar | Golden mane; Savanna king | Tiger; Leopard; Cheetah
```

Fields: `word | level-1 hints | level-2 hints | level-3 hints | fake words`.

#### Adding a pack or category

1. Create `tool/packs_src/<id>.txt` starting with `@id <id>` and `@name <Display name>` (add more chunk files with the same `@id` as needed).
2. `dart run tool/build_packs.dart` regenerates `assets/packs/<id>.json` and `index.json`.
3. `dart run tool/validate_packs.dart` must report **0 errors** (each pack needs 150+ words).
4. Optional: add an entry to `onlineCategories` so the Online source can search the same category.

### 3. My Words (personal packs)

Create, rename and delete packs; add words one by one; bulk-paste (one per line); import CSV/JSON; export JSON.
Everything is stored locally.
Hints and fakes are optional: **Find hints online** auto-enriches through the online pipeline so you can review
and edit before saving. Without hints, the imposter's hint falls back to the pack name, and Fake Word mode skips
words that have no fake. Words that need hints get a *needs hints* badge.

CSV format: `word,hint1|hint2,fake1|fake2` (header optional). JSON: the exported `hushbug-pack` format, or a plain list of words.

---

## Hint quality rules (enforced in code for all sources)

`lib/domain/validators.dart`. A hint is rejected if it contains the word or its stem/plural, is a synonym, is a
letter/length clue, contains a brand or proper noun, is longer than 4 words, hits the family-friendly blocklist
(`assets/blocklist.txt`), or is only filler. Words with fewer than 3 valid hints are discarded (Online/Offline).
Word filter: 3–16 chars, 1–2 tokens, alphabetic (space/hyphen allowed), no list/disambiguation/year pages.

Difficulty: Easy = level 3 (specific), **Medium = level 2 (default)**, Hard = level 1 (vague).

## Randomness

`lib/domain/random_service.dart`. Every gameplay decision uses `Random.secure()` (a seeded `Random` is injected
only in tests), and all shuffles are Fisher–Yates.

* **Words:** a persistent shuffle bag per (source, category), reshuffled only when empty, with the last 10 dealt words
  kept out of the next first 10. There is also a 200-word global recent history, and Random mix uses
  weighted category picks. All of this state is stored in SQLite.
* **Imposters:** a uniform draw each round, independent of seating, names, word and previous rounds.
  *Avoid same imposter back-to-back* is optional (off by default).
* **Hints/fakes:** each word's hint pool rotates (all hints shown before any repeat, never the same one twice in a
  row), and this is persisted across restarts.
* **Starter:** drawn in a separate call after roles are assigned, uniform over all players, so P(imposter starts) = 1/n.

Statistical tests (`test/randomness_stats_test.dart`) run 24,000 rounds for n = 3, 5, 10, 20 with chi-square p > 0.001.

## Architecture

```
lib/
  domain/        pure Dart: GameEngine, RandomService, ShuffleBag, Hint/FakeWordSelector,
                 VoteResolver, WordPipeline, validators, WordSource + fallback resolver
  data/          drift DB, shared_preferences settings, sources (online/offline/my words), SourceRegistry
  app/           Riverpod providers, GameController, app shell + go_router
  presentation/  screens, theme, mascot, widgets
  l10n/          ARB files (en, hi) + generated localizations
tool/            build_packs, validate_packs, gen_sounds, pack sources
```

Riverpod · go_router · freezed + json_serializable · drift · shared_preferences · dio · audioplayers · file_picker.

## Credits

* Wikipedia & Wikidata: text CC BY-SA, Wikidata CC0
* ConceptNet: CC BY-SA 4.0
* Datamuse API
* Offline Packs, mascot, sounds (`tool/gen_sounds.dart`) and UI: original work for Hushbug

See `NOTES.md` for the decisions made where the spec was open, and `CHANGELOG.md`.
