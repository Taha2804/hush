# Design notes and decisions

Decisions made where the specification was open or ambiguous.

## Branding
* Name **Hushbug**, a beetle with a finger on its lips. Four moods (shush, suspicious, happy, sad),
  all drawn in `lib/presentation/widgets/mascot.dart` with `CustomPainter`.
* Sounds are synthesised by `tool/gen_sounds.dart` (no third-party audio assets).

## Game rules
* **Single imposter:** one vote decides the round. Voting out a crew member means the imposter wins
  immediately. Elimination rounds only apply when there are 2+ imposters, as the spec describes.
* **Multiple imposters:** after each crew elimination the game returns to Discussion (the timer restarts),
  then to Vote. The game ends when all imposters are caught or imposters ≥ remaining crew.
* **Ties:** with *Revote*, the next vote is limited to the tied players. After **2 revotes** a persisting tie
  goes to the imposters, so a 2–2 deadlock can't loop forever.
* **Simple voting:** the group votes aloud and taps the top player. An *It's a tie* button lets them pick
  the tied players.
* **Private voting:** each alive player votes in turn behind a "pass the device" screen. Players can't vote
  for themselves (unless only 2 candidates remain).
* **"Maybe nobody":** a *No imposter* ballot appears only when the toggle is on, so it doesn't give the
  chaos round away. Voting *No imposter* when there was none means the crew wins. Accusing someone when there
  was nobody means "Chaos wins" (no points). Voting *No imposter* when there was one means the imposters win.
* **Last chance:** shown when the last imposter is caught. The imposter types a guess, which is matched
  case- and plural-insensitively. The group can also accept a close guess ("Close enough") or decline.
  In Fake Word mode the imposter, who didn't know their role, also gets this guess.
* **Scoring:** crew win = +1 for every crew member (including eliminated crew). Imposter win = +2 for each
  imposter. Chaos win = 0. Scores are keyed by player name and persisted, and players removed from the list
  are hidden from the board.
* **Double reveal prevention:** once a card has been shown and hidden it is locked ("Card seen"), and
  **Next** only unlocks after the card was seen. This is strict on purpose.
* **FLAG_SECURE:** enabled for the whole Play screen (reveal through vote) and released on Result and on exit.
* **Speed round:** when the per-clue timer runs out, a tick sounds and play advances to the next player automatically.
* **Fake Word mode** only deals words that have a fake. If none are available it falls back to Hint mode
  for that round and shows a notice.
* The starter roulette is purely cosmetic. The starter is drawn by the engine before the animation starts.

## Word sources
* **Category ids are shared** between Online and Offline (`animals`, `food`, …), so names and selections line up.
  For Online, each id maps to Wikipedia list pages, categories and Wikidata classes in `category_config.dart`.
  These mappings are best-effort: a missing page or class just yields no candidates and is negative-cached for 3 days.
* **Pageviews** come from the MediaWiki `prop=pageviews` module (60 days, batched with the candidate query)
  instead of one REST call per article. This keeps requests low and respects Wikimedia rate limits.
  Wikidata sitelink counts act as a second familiarity signal.
* **Isolates:** candidate search and enrichment run in `Isolate.run` with a fresh `Dio` inside the isolate.
  Results go back as plain maps, and the main isolate writes them to drift. Tests run the same code inline
  with recorded fixtures (`useIsolate: false`).
* **First run online:** if a category has fewer than 5 enriched words, the app waits for the first batch
  (up to 25 s, with a loading state on *Start game*). After that, top-ups and pre-enrichment run in the background.
* **"Pre-enrich the next 5"** keeps at least 5 enriched, unused words per category, so the next deal never
  waits on the network.
* **Fallback:** Online → online cache → Offline Packs. Offline Packs use the same category ids, so the
  fallback serves the same categories. Online and its cache share one shuffle bag.
* **Cross-pack duplicates** (e.g. *Kiwi* in Animals and Fruits) are allowed and reported as **warnings** by
  the validator. Duplicates inside a pack are errors. The global recent history still prevents back-to-back
  repeats across categories.
* **My Words:** hints you type default to level 2 (medium). Hints from online enrichment keep their levels.
  The hint selector falls back to the nearest level, so any mix works.
* **Custom topic** packs are saved without hints. *Find hints online* in the pack editor (✨) enriches all
  words that need hints in one go.

## Hint validator
* "Same domain" is enforced in two ways. Online hints are only built from relations of the word itself
  (ConceptNet edges, Datamuse triggers, the Wikipedia description), and the validator rejects hints made
  only of stopwords or generic filler ("a thing", "something").
* "Proper noun" means any capitalised token after the first word, plus a bundled brand list
  (`assets/brands.txt`). Leading proper adjectives ("European nation") are allowed.
* Letter/length clues: any digit, or phrases like *letters, starts with, rhymes, spelled, syllable, initials,
  vowel*. Pack hints were written to avoid these, including the innocent meanings.
* Fakes may share a generic head token with the real word ("Orange juice" → "Apple juice") but must differ in at
  least one meaningful token. They can't be the word itself, its plural/stem, a substring, or a synonym.
* The blocklist is family-friendly: profanity, adult content, drugs, alcohol, tobacco, violence and hate.
  It applies to words, hints, fakes, custom topics, bulk paste and imports.

## Randomness details
* Reshuffle boundary: after refilling, any of the last 10 dealt items found in the first 10 positions is
  swapped with a random non-recent item from position 10 onward. This needs a pool larger than 10, which all
  packs exceed.
* The global history (200 words) is a soft constraint. The bag skips history words while non-history words
  remain in the bag, and never breaks the "no repeat before the bag empties" rule.
* *Avoid same imposter back-to-back* removes the previous imposters from the draw when enough players remain.
  It is off by default, so true randomness is the default.

## UI
* Themes: System, Light, Dark, AMOLED (true black surfaces), and 6 accent colours.
* Text size is an in-app multiplier on top of the OS text scale (85–150%).
* *Reduce motion* also follows the OS "remove animations" setting.
* Category names come from the packs and stay in English in the Hindi UI. All UI chrome is translated.
* About lists all data credits and links to Flutter's licence page.

## Build environment
* Developed on Windows with Flutter 3.47.0 stable.
* Windows desktop builds need Visual Studio with the C++ workload, and macOS builds need Xcode.
  CI builds both on hosted runners.
