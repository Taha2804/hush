# Changelog

## Unreleased

- **Player groups**: save the current players as a named group and load it
  next time with one tap; groups can be renamed, edited (add/remove players)
  and deleted. Groups survive restarts (the live player list does not).
- **My Words**: delete a pack straight from the list, "Delete all words" in a
  pack, undo after removing a word, and "Delete all My Words packs" in
  App preferences.
- **Settings redesign**: the Settings page now shows only game rules, grouped
  (Round flow, Imposter rules, Voting & scoring, Fun extras), each with a
  plain-language description that updates with the chosen value. Theme,
  language, sound, start-up and data moved to *App preferences*.
  "Ask me every time the app opens" is explained where it appears.
- **Fun extras**: Round twists (8 random clue rules), Imposter teammates
  (imposters see each other) and Crew always starts.
- **Fix: hint difficulty** — hint rotation was shared across levels, so once
  a word's Easy hints were used it drifted into Medium/Hard hints (and vice
  versa). Rotation now stays within the chosen level, and Easy gives two
  specific hints, making the difficulty gap clear.

- App icon: the Hushbug mascot on a purple gradient for Android (adaptive +
  themed/monochrome), Windows and macOS. Rendered by
  `tool/render_icons_test.dart`, applied with `flutter_launcher_icons`.
- Unnamed / default players show their number in the avatar.

- App restarts now start a fresh session: player names, imposter count and
  the scoreboard reset to defaults. Preferences (theme, language, sound,
  game rules, categories, word source) are still remembered.
- Dark-mode toggle in the app bar, gradient header, category icons, coloured
  player avatars and reveal cards.

## 1.0.0 (2026-11-07)

First release.

* Pass-and-play imposter game for 3–20 players: Source Select → Setup → Reveal → Clues → Discussion → Vote → Result.
* Modes: Classic, Hint, Fake Word, multiple imposters, Speed round, "Maybe nobody".
* Three word sources: Online Search (Wikipedia/Wikidata/ConceptNet/Datamuse with a drift cache),
  Offline Packs (22 packs, 3,386 words), My Words (editor with import/export and online enrichment).
* `RandomService` built on `Random.secure()`: persistent shuffle bags, recent history, hint/fake rotation,
  and independent imposter and starter draws, all statistically tested.
* Material 3 with Light/Dark/AMOLED themes and 6 accents, English and Hindi, an original CustomPainter mascot,
  card-flip and confetti animations, keyboard shortcuts, accessibility semantics.
* Pack builder and validator tools, plus a GitHub Actions workflow that tests and builds Android, Windows and macOS.
