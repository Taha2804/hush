// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hushbug';

  @override
  String get tagline => 'Find the faker. Keep the secret.';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get settings => 'Settings';

  @override
  String get howToPlay => 'How to play';

  @override
  String get about => 'About';

  @override
  String get changeSource => 'Change source';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get chooseSource => 'Choose word source';

  @override
  String get badgeOnline => 'Online';

  @override
  String get badgeOffline => 'Offline';

  @override
  String get sourceOnlineName => 'Online Search';

  @override
  String get sourceOnlineDesc =>
      'Fresh, familiar words searched live from Wikipedia, Wikidata, ConceptNet and Datamuse, then cached on your device.';

  @override
  String get sourceOfflineName => 'Offline Packs';

  @override
  String get sourceOfflineDesc =>
      '22 hand-made packs with over 3,000 words. Always available.';

  @override
  String get sourceMyWordsName => 'My Words';

  @override
  String get sourceMyWordsDesc =>
      'Your own packs. Type, paste or import words.';

  @override
  String get reasonNoInternet => 'No internet connection';

  @override
  String get reasonNoPacks => 'Create a pack with at least one word first';

  @override
  String get askEveryLaunch => 'Ask me every time the app opens';

  @override
  String get manageMyWords => 'Manage my words';

  @override
  String get checking => 'Checking…';

  @override
  String get setup => 'Game setup';

  @override
  String get players => 'Players';

  @override
  String get addPlayer => 'Add player';

  @override
  String get playerName => 'Player name';

  @override
  String playerN(int n) {
    return 'Player $n';
  }

  @override
  String get removePlayer => 'Remove player';

  @override
  String get imposters => 'Imposters';

  @override
  String get categories => 'Categories';

  @override
  String get randomMix => 'Random mix (all)';

  @override
  String get mode => 'Mode';

  @override
  String get modeClassic => 'Classic';

  @override
  String get modeClassicDesc => 'The imposter only sees IMPOSTER.';

  @override
  String get modeHint => 'Hint';

  @override
  String get modeHintDesc => 'The imposter gets one hint about the word.';

  @override
  String get modeFake => 'Fake word';

  @override
  String get modeFakeDesc =>
      'The imposter gets a similar word and doesn\'t know they\'re the imposter.';

  @override
  String get discussionTimer => 'Discussion timer';

  @override
  String get off => 'Off';

  @override
  String minutes(int n) {
    return '$n min';
  }

  @override
  String seconds(int n) {
    return '$n s';
  }

  @override
  String get clueRounds => 'Clue rounds';

  @override
  String get hintLevel => 'Hint level';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get speedRound => 'Speed round';

  @override
  String get speedRoundDesc => 'Short timer for each clue';

  @override
  String get maybeNobody => 'Maybe nobody';

  @override
  String maybeNobodyDesc(int p) {
    return '$p% chance there is no imposter at all';
  }

  @override
  String get startGame => 'Start game';

  @override
  String get scoreboard => 'Scoreboard';

  @override
  String get resetScores => 'Reset scores';

  @override
  String sourceLabel(String name) {
    return 'Source: $name';
  }

  @override
  String get needThreePlayers => 'You need at least 3 players.';

  @override
  String get pickCategory => 'Pick at least one category.';

  @override
  String get moreOptions => 'More options';

  @override
  String passTo(String name) {
    return 'Pass to $name';
  }

  @override
  String get holdToReveal => 'Hold to reveal';

  @override
  String get tapToReveal => 'Tap to reveal';

  @override
  String get tapToHide => 'Tap to hide';

  @override
  String get releaseToHide => 'Release to hide';

  @override
  String get yourWord => 'Your secret word';

  @override
  String get imposterCard => 'IMPOSTER';

  @override
  String yourHint(String hint) {
    return 'Hint: $hint';
  }

  @override
  String get blendIn => 'Blend in. Don\'t get caught.';

  @override
  String get cardSeen => 'Card seen — pass the device on';

  @override
  String get privacyNote => 'Make sure nobody else can see the screen.';

  @override
  String playerOfTotal(int i, int n) {
    return 'Player $i of $n';
  }

  @override
  String get clueTime => 'Clue time';

  @override
  String startingPlayer(String name) {
    return '$name starts!';
  }

  @override
  String get picking => 'Picking who starts…';

  @override
  String get turnOrder => 'Turn order';

  @override
  String saysOneWord(String name) {
    return '$name, say ONE word';
  }

  @override
  String roundOf(int r, int total) {
    return 'Round $r of $total';
  }

  @override
  String get skipToDiscussion => 'Skip to discussion';

  @override
  String get discussion => 'Discussion';

  @override
  String get discussionPrompt => 'Who sounded suspicious? Talk it out.';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get skip => 'Skip';

  @override
  String get timeUp => 'Time\'s up!';

  @override
  String get goToVote => 'Go to vote';

  @override
  String get vote => 'Vote';

  @override
  String get whoIsImposter => 'Who is the imposter?';

  @override
  String get tapMostVoted =>
      'Vote out loud, then tap the player with the most votes.';

  @override
  String get itsATie => 'It\'s a tie';

  @override
  String get selectTied => 'Select the tied players';

  @override
  String get noImposter => 'No imposter';

  @override
  String castYourVote(String name) {
    return '$name, cast your secret vote';
  }

  @override
  String passDeviceTo(String name) {
    return 'Pass the device to $name';
  }

  @override
  String imReady(String name) {
    return 'I\'m $name — show the ballot';
  }

  @override
  String get revoteNotice => 'Tie! Vote again between the tied players.';

  @override
  String wasCrew(String name) {
    return '$name was crew!';
  }

  @override
  String wasImposter(String name) {
    return '$name was an imposter!';
  }

  @override
  String impostersLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n imposters are still hiding.',
      one: '1 imposter is still hiding.',
    );
    return '$_temp0';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get lastChance => 'Last chance!';

  @override
  String get lastChanceDesc =>
      'Imposter, guess the secret word to steal the win.';

  @override
  String get yourGuess => 'Your guess';

  @override
  String get submitGuess => 'Submit guess';

  @override
  String get countIt => 'Close enough — count it';

  @override
  String get giveUp => 'Give up';

  @override
  String get crewWins => 'Crew wins!';

  @override
  String get impostersWin => 'Imposters win!';

  @override
  String get nobodyWins => 'Chaos wins!';

  @override
  String get theImposterWas => 'The imposter was';

  @override
  String get theImpostersWere => 'The imposters were';

  @override
  String get nobodyWasImposter => 'There was no imposter!';

  @override
  String get secretWord => 'Secret word';

  @override
  String get fakeWordWas => 'Fake word';

  @override
  String get hintWas => 'Imposter\'s hint';

  @override
  String get playAgain => 'Play again';

  @override
  String get changeSetup => 'Change setup';

  @override
  String get reasonCaught => 'All imposters were caught.';

  @override
  String get reasonWrong => 'The crew voted out an innocent player.';

  @override
  String get reasonOutnumber => 'The imposters now match the crew in number.';

  @override
  String get reasonTie => 'A tie let the imposters escape.';

  @override
  String get reasonNoImposterRight =>
      'You correctly spotted that nobody was the imposter.';

  @override
  String get reasonNoImposterMissed => 'There was an imposter after all!';

  @override
  String get reasonVotedNobody =>
      'There was no imposter — you accused an innocent player.';

  @override
  String get reasonSteal => 'The imposter guessed the word!';

  @override
  String guessWas(String guess) {
    return 'Guess: $guess';
  }

  @override
  String points(int n) {
    return '+$n';
  }

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeAmoled => 'AMOLED';

  @override
  String get accentColor => 'Accent colour';

  @override
  String get language => 'Language';

  @override
  String get textSize => 'Text size';

  @override
  String get reduceMotion => 'Reduce motion';

  @override
  String get sound => 'Sound';

  @override
  String get haptics => 'Haptics';

  @override
  String get gameplay => 'Gameplay';

  @override
  String get revealStyle => 'Reveal style';

  @override
  String get revealHold => 'Hold to reveal';

  @override
  String get revealTap => 'Tap to reveal';

  @override
  String get tieRule => 'Tie rule';

  @override
  String get tieRevote => 'Revote';

  @override
  String get tieImposters => 'Imposter wins';

  @override
  String get voteStyle => 'Voting';

  @override
  String get voteSimple => 'Simple (tap the most voted)';

  @override
  String get votePrivate => 'Private pass-around voting';

  @override
  String get avoidSameImposter => 'Avoid same imposter back-to-back';

  @override
  String get maybeNobodyChance => '\"Maybe nobody\" chance';

  @override
  String get seating => 'Turn order';

  @override
  String get seatingFromStarter => 'Seating order from starter';

  @override
  String get seatingShuffled => 'Fully shuffled';

  @override
  String get lastChanceSetting => 'Imposter gets a last chance to guess';

  @override
  String get scoreboardSetting => 'Running scoreboard';

  @override
  String get wordSources => 'Word sources';

  @override
  String cachedWords(int n) {
    return '$n cached words';
  }

  @override
  String packsInfo(int packs, int words) {
    return '$packs packs, $words words';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get cacheCleared => 'Cache cleared';

  @override
  String get refreshing => 'Refreshing in the background…';

  @override
  String get resetHistory => 'Reset word history';

  @override
  String get historyReset => 'Word history reset';

  @override
  String get myWords => 'My Words';

  @override
  String get newPack => 'New pack';

  @override
  String get packName => 'Pack name';

  @override
  String get rename => 'Rename';

  @override
  String get addWord => 'Add word';

  @override
  String get editWord => 'Edit word';

  @override
  String get word => 'Word';

  @override
  String get bulkPaste => 'Bulk paste';

  @override
  String get bulkPasteHint => 'One word per line';

  @override
  String get importFile => 'Import CSV / JSON';

  @override
  String get exportJson => 'Export JSON';

  @override
  String get needsHints => 'needs hints';

  @override
  String get hintsOptional => 'Hints (optional, one per line)';

  @override
  String get fakesOptional => 'Fake words (optional, one per line)';

  @override
  String get autoEnrich => 'Find hints online';

  @override
  String get enriching => 'Searching for hints…';

  @override
  String get enrichFailed =>
      'Couldn\'t find good hints. You can type your own.';

  @override
  String wordsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n words',
      one: '1 word',
    );
    return '$_temp0';
  }

  @override
  String get noPacksYet => 'No packs yet. Create one or search a custom topic.';

  @override
  String get noWordsYet => 'No words yet. Add some!';

  @override
  String get customTopic => 'Custom topic';

  @override
  String get topicHint => 'Type any topic, e.g. Dinosaurs';

  @override
  String get search => 'Search';

  @override
  String get saveAsPack => 'Save as pack';

  @override
  String get noResults => 'No words found for this topic.';

  @override
  String imported(int n) {
    return 'Imported $n words';
  }

  @override
  String get exported => 'Exported';

  @override
  String get deletePackConfirm => 'Delete this pack and all its words?';

  @override
  String get needsInternet => 'Needs internet';

  @override
  String addedWords(int n) {
    return 'Added $n words';
  }

  @override
  String get removeWord => 'Remove';

  @override
  String get addCustomWord => 'Add a word';

  @override
  String get noticeCache => 'Offline — using cached online words.';

  @override
  String get noticePacks => 'Online words unavailable — using Offline Packs.';

  @override
  String get noticeNoWords => 'No words available for these categories.';

  @override
  String get noticeFakeFallback =>
      'No fake word available — playing Hint mode this round.';

  @override
  String get leaveGameTitle => 'Leave this game?';

  @override
  String get leaveGameBody =>
      'The current round will be lost. Players and scores are kept.';

  @override
  String get leave => 'Leave';

  @override
  String get howTitle => 'How to play';

  @override
  String get how1Title => '1. Set up';

  @override
  String get how1Body =>
      'Add 3–20 players, pick categories and a mode. Everyone sits in a circle around one device.';

  @override
  String get how2Title => '2. Secret cards';

  @override
  String get how2Body =>
      'Pass the device around. Each player privately reveals their card: the crew sees the secret word, the imposter does not.';

  @override
  String get how3Title => '3. One-word clues';

  @override
  String get how3Body =>
      'Starting with a random player, everyone says ONE word related to the secret word. Crew: prove you know it without giving it away. Imposter: bluff!';

  @override
  String get how4Title => '4. Discuss and vote';

  @override
  String get how4Body =>
      'Talk it over, then vote out the player you think is the imposter. With several imposters, keep voting until they are all caught — or they equal the crew.';

  @override
  String get how5Title => '5. Last chance';

  @override
  String get how5Body =>
      'A caught imposter may guess the secret word to steal the win.';

  @override
  String get howModesTitle => 'Modes';

  @override
  String get howModesBody =>
      'Classic: the imposter sees only IMPOSTER. Hint: the imposter gets one clue. Fake word: the imposter gets a similar word and doesn\'t know it. Maybe nobody: sometimes there is no imposter — vote \"No imposter\" to win.';

  @override
  String get howKeysTitle => 'Keyboard';

  @override
  String get howKeysBody =>
      'Space or Enter: next. Hold Space on a card to reveal it (hold mode). Esc: back.';

  @override
  String get aboutFree =>
      '100% free. No ads, no accounts, no tracking, no purchases. Every mode and word source is unlocked.';

  @override
  String get aboutCredits => 'Credits & data licences';

  @override
  String get creditWikipedia =>
      'Wikipedia & Wikidata — text under CC BY-SA; Wikidata under CC0';

  @override
  String get creditConceptNet => 'ConceptNet — CC BY-SA 4.0';

  @override
  String get creditDatamuse => 'Datamuse API — free word-finding service';

  @override
  String get creditPacks =>
      'Offline Packs — original content written for Hushbug';

  @override
  String version(String v) {
    return 'Version $v';
  }

  @override
  String get mascotLabel => 'Hushbug, a beetle putting a finger to its lips';

  @override
  String get groups => 'Groups';

  @override
  String get savedGroups => 'Saved groups';

  @override
  String get saveAsGroup => 'Save these players as a group';

  @override
  String get groupName => 'Group name';

  @override
  String get groupNameHint => 'e.g. College friends';

  @override
  String groupSaved(String name) {
    return 'Group \"$name\" saved';
  }

  @override
  String groupLoaded(String name, int n) {
    return 'Loaded \"$name\" ($n players)';
  }

  @override
  String get noGroupsYet =>
      'No saved groups yet. Type your players\' names once, then save them as a group to reuse next time.';

  @override
  String get editGroup => 'Edit group';

  @override
  String get newGroup => 'New group';

  @override
  String deleteGroupConfirm(String name) {
    return 'Delete the group \"$name\"? Your current player list stays as it is.';
  }

  @override
  String groupPlayers(int n) {
    return '$n players';
  }

  @override
  String groupExists(String name) {
    return 'A group called \"$name\" already exists. Replace it?';
  }

  @override
  String get replace => 'Replace';

  @override
  String get groupsHelp =>
      'Tap a group to load its players. Use the pencil to rename it or add/remove players.';

  @override
  String get deleteAllWords => 'Delete all words';

  @override
  String get clearPackConfirm =>
      'Remove every word from this pack? The pack itself stays.';

  @override
  String wordRemoved(String word) {
    return '\"$word\" removed';
  }

  @override
  String get undo => 'Undo';

  @override
  String get deleteAllPacks => 'Delete all My Words packs';

  @override
  String get deleteAllPacksConfirm =>
      'This permanently removes all your custom packs and their words. It can\'t be undone.';

  @override
  String get allPacksDeleted => 'All My Words packs deleted';

  @override
  String get packDeleted => 'Pack deleted';

  @override
  String get deletePack => 'Delete pack';

  @override
  String get gameRules => 'Game rules';

  @override
  String get gameRulesIntro =>
      'These rules apply to every round. Changes save instantly.';

  @override
  String get secRoundFlow => 'Round flow';

  @override
  String get secImposterRules => 'Imposter rules';

  @override
  String get secVoting => 'Voting & scoring';

  @override
  String get secFun => 'Fun extras';

  @override
  String get secFunDesc => 'Optional twists to spice up game night.';

  @override
  String get appPreferences => 'App preferences';

  @override
  String get appPreferencesDesc =>
      'Theme, language, sound, vibration, start-up screen and word data';

  @override
  String get startup => 'Start-up';

  @override
  String get askEveryLaunchDesc =>
      'On: each time you open Hushbug you first choose where words come from (Online Search, Offline Packs or My Words). Off: the app opens straight to Game setup with the source you used last.';

  @override
  String get soundDesc => 'Timer ticks, reveal and win/lose sounds';

  @override
  String get hapticsDesc =>
      'Short vibrations on reveal, votes and when time is up';

  @override
  String get reduceMotionDesc =>
      'Turns off confetti, card flips and other animations';

  @override
  String get dataSection => 'Word data';

  @override
  String get discussionTimerOffDesc =>
      'No timer: talk as long as you like, then tap \"Go to vote\".';

  @override
  String discussionTimerOnDesc(String time) {
    return 'Everyone gets $time to discuss before voting starts.';
  }

  @override
  String get clueRoundsDesc =>
      'How many times each player gives a one-word clue. Two rounds give more information and make bluffing harder.';

  @override
  String get speedRoundSettingDesc =>
      'Each clue must be given before a short countdown ends.';

  @override
  String get revealHoldDesc =>
      'Hold the card to see it, let go to hide it. Safest against peeking.';

  @override
  String get revealTapDesc =>
      'Tap once to show the card, tap again to hide it.';

  @override
  String get seatingFromStarterDesc =>
      'Clues go around the circle in seat order, starting from a random player.';

  @override
  String get seatingShuffledDesc =>
      'The clue order is completely shuffled every round.';

  @override
  String get hintLevelDesc =>
      'How helpful the imposter\'s hint is in Hint mode. Easy: two specific hints. Medium: one in-between hint. Hard: one vague, category-level hint.';

  @override
  String get avoidSameImposterDesc =>
      'Last round\'s imposter won\'t be picked again in the next round.';

  @override
  String get maybeNobodySettingDesc =>
      'Sometimes there is no imposter at all. Players must vote \"No imposter\" to win.';

  @override
  String get maybeNobodyChanceDesc => 'How often a round has no imposter.';

  @override
  String get lastChanceSettingDesc =>
      'A caught imposter gets one guess at the secret word. Guess right and the imposters steal the win.';

  @override
  String get voteSimpleDesc =>
      'Discuss out loud, then tap the player who got the most votes.';

  @override
  String get votePrivateDesc =>
      'Pass the phone around and everyone votes in secret.';

  @override
  String get tieRevoteDesc =>
      'On a tie, vote again between only the tied players.';

  @override
  String get tieImpostersDesc =>
      'A tie means nobody is caught, so the imposters win.';

  @override
  String get scoreboardDesc =>
      'Keep points across rounds: crew get +1 for a catch, imposters get +2 for escaping.';

  @override
  String get impostersKnowEachOther => 'Imposter teammates';

  @override
  String get impostersKnowEachOtherDesc =>
      'With 2 or more imposters, each imposter sees who their partners are, so they can cover for each other. (Not used in Fake Word mode.)';

  @override
  String get crewStarts => 'Crew always starts';

  @override
  String get crewStartsDesc =>
      'The first player to give a clue is never an imposter. Gentler for new players.';

  @override
  String get roundTwists => 'Round twists';

  @override
  String get roundTwistsDesc =>
      'Every round adds a random fun rule for clues, like whispering or acting it out.';

  @override
  String yourPartners(String names) {
    return 'Your partner: $names';
  }

  @override
  String get twistTitle => 'Round twist!';

  @override
  String get twist0 => 'One word only: no extra words, no gestures.';

  @override
  String get twist1 => 'Silent round: act your clue out, no talking!';

  @override
  String get twist2 => 'Whisper round: say your clue in a whisper.';

  @override
  String get twist3 =>
      'Sound effect round: make a sound instead of saying a word.';

  @override
  String get twist4 => 'Accent round: say your clue in your best funny accent.';

  @override
  String get twist5 => 'Slow motion: say your clue as slowly as possible.';

  @override
  String get twist6 => 'Question round: your clue must be a question.';

  @override
  String get twist7 =>
      'Opposite round: give a clue about what the word is NOT.';
}
