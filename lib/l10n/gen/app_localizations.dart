import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hushbug'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Find the faker. Keep the secret.'**
  String get tagline;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @changeSource.
  ///
  /// In en, this message translates to:
  /// **'Change source'**
  String get changeSource;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose word source'**
  String get chooseSource;

  /// No description provided for @badgeOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get badgeOnline;

  /// No description provided for @badgeOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get badgeOffline;

  /// No description provided for @sourceOnlineName.
  ///
  /// In en, this message translates to:
  /// **'Online Search'**
  String get sourceOnlineName;

  /// No description provided for @sourceOnlineDesc.
  ///
  /// In en, this message translates to:
  /// **'Fresh, familiar words searched live from Wikipedia, Wikidata, ConceptNet and Datamuse, then cached on your device.'**
  String get sourceOnlineDesc;

  /// No description provided for @sourceOfflineName.
  ///
  /// In en, this message translates to:
  /// **'Offline Packs'**
  String get sourceOfflineName;

  /// No description provided for @sourceOfflineDesc.
  ///
  /// In en, this message translates to:
  /// **'22 hand-made packs with over 3,000 words. Always available.'**
  String get sourceOfflineDesc;

  /// No description provided for @sourceMyWordsName.
  ///
  /// In en, this message translates to:
  /// **'My Words'**
  String get sourceMyWordsName;

  /// No description provided for @sourceMyWordsDesc.
  ///
  /// In en, this message translates to:
  /// **'Your own packs. Type, paste or import words.'**
  String get sourceMyWordsDesc;

  /// No description provided for @reasonNoInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get reasonNoInternet;

  /// No description provided for @reasonNoPacks.
  ///
  /// In en, this message translates to:
  /// **'Create a pack with at least one word first'**
  String get reasonNoPacks;

  /// No description provided for @askEveryLaunch.
  ///
  /// In en, this message translates to:
  /// **'Ask me every time the app opens'**
  String get askEveryLaunch;

  /// No description provided for @manageMyWords.
  ///
  /// In en, this message translates to:
  /// **'Manage my words'**
  String get manageMyWords;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @setup.
  ///
  /// In en, this message translates to:
  /// **'Game setup'**
  String get setup;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add player'**
  String get addPlayer;

  /// No description provided for @playerName.
  ///
  /// In en, this message translates to:
  /// **'Player name'**
  String get playerName;

  /// No description provided for @playerN.
  ///
  /// In en, this message translates to:
  /// **'Player {n}'**
  String playerN(int n);

  /// No description provided for @removePlayer.
  ///
  /// In en, this message translates to:
  /// **'Remove player'**
  String get removePlayer;

  /// No description provided for @imposters.
  ///
  /// In en, this message translates to:
  /// **'Imposters'**
  String get imposters;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @randomMix.
  ///
  /// In en, this message translates to:
  /// **'Random mix (all)'**
  String get randomMix;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @modeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get modeClassic;

  /// No description provided for @modeClassicDesc.
  ///
  /// In en, this message translates to:
  /// **'The imposter only sees IMPOSTER.'**
  String get modeClassicDesc;

  /// No description provided for @modeHint.
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get modeHint;

  /// No description provided for @modeHintDesc.
  ///
  /// In en, this message translates to:
  /// **'The imposter gets one hint about the word.'**
  String get modeHintDesc;

  /// No description provided for @modeFake.
  ///
  /// In en, this message translates to:
  /// **'Fake word'**
  String get modeFake;

  /// No description provided for @modeFakeDesc.
  ///
  /// In en, this message translates to:
  /// **'The imposter gets a similar word and doesn\'t know they\'re the imposter.'**
  String get modeFakeDesc;

  /// No description provided for @discussionTimer.
  ///
  /// In en, this message translates to:
  /// **'Discussion timer'**
  String get discussionTimer;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minutes(int n);

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{n} s'**
  String seconds(int n);

  /// No description provided for @clueRounds.
  ///
  /// In en, this message translates to:
  /// **'Clue rounds'**
  String get clueRounds;

  /// No description provided for @hintLevel.
  ///
  /// In en, this message translates to:
  /// **'Hint level'**
  String get hintLevel;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @speedRound.
  ///
  /// In en, this message translates to:
  /// **'Speed round'**
  String get speedRound;

  /// No description provided for @speedRoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Short timer for each clue'**
  String get speedRoundDesc;

  /// No description provided for @maybeNobody.
  ///
  /// In en, this message translates to:
  /// **'Maybe nobody'**
  String get maybeNobody;

  /// No description provided for @maybeNobodyDesc.
  ///
  /// In en, this message translates to:
  /// **'{p}% chance there is no imposter at all'**
  String maybeNobodyDesc(int p);

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get startGame;

  /// No description provided for @scoreboard.
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get scoreboard;

  /// No description provided for @resetScores.
  ///
  /// In en, this message translates to:
  /// **'Reset scores'**
  String get resetScores;

  /// No description provided for @sourceLabel.
  ///
  /// In en, this message translates to:
  /// **'Source: {name}'**
  String sourceLabel(String name);

  /// No description provided for @needThreePlayers.
  ///
  /// In en, this message translates to:
  /// **'You need at least 3 players.'**
  String get needThreePlayers;

  /// No description provided for @pickCategory.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one category.'**
  String get pickCategory;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @passTo.
  ///
  /// In en, this message translates to:
  /// **'Pass to {name}'**
  String passTo(String name);

  /// No description provided for @holdToReveal.
  ///
  /// In en, this message translates to:
  /// **'Hold to reveal'**
  String get holdToReveal;

  /// No description provided for @tapToReveal.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get tapToReveal;

  /// No description provided for @tapToHide.
  ///
  /// In en, this message translates to:
  /// **'Tap to hide'**
  String get tapToHide;

  /// No description provided for @releaseToHide.
  ///
  /// In en, this message translates to:
  /// **'Release to hide'**
  String get releaseToHide;

  /// No description provided for @yourWord.
  ///
  /// In en, this message translates to:
  /// **'Your secret word'**
  String get yourWord;

  /// No description provided for @imposterCard.
  ///
  /// In en, this message translates to:
  /// **'IMPOSTER'**
  String get imposterCard;

  /// No description provided for @yourHint.
  ///
  /// In en, this message translates to:
  /// **'Hint: {hint}'**
  String yourHint(String hint);

  /// No description provided for @blendIn.
  ///
  /// In en, this message translates to:
  /// **'Blend in. Don\'t get caught.'**
  String get blendIn;

  /// No description provided for @cardSeen.
  ///
  /// In en, this message translates to:
  /// **'Card seen — pass the device on'**
  String get cardSeen;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Make sure nobody else can see the screen.'**
  String get privacyNote;

  /// No description provided for @playerOfTotal.
  ///
  /// In en, this message translates to:
  /// **'Player {i} of {n}'**
  String playerOfTotal(int i, int n);

  /// No description provided for @clueTime.
  ///
  /// In en, this message translates to:
  /// **'Clue time'**
  String get clueTime;

  /// No description provided for @startingPlayer.
  ///
  /// In en, this message translates to:
  /// **'{name} starts!'**
  String startingPlayer(String name);

  /// No description provided for @picking.
  ///
  /// In en, this message translates to:
  /// **'Picking who starts…'**
  String get picking;

  /// No description provided for @turnOrder.
  ///
  /// In en, this message translates to:
  /// **'Turn order'**
  String get turnOrder;

  /// No description provided for @saysOneWord.
  ///
  /// In en, this message translates to:
  /// **'{name}, say ONE word'**
  String saysOneWord(String name);

  /// No description provided for @roundOf.
  ///
  /// In en, this message translates to:
  /// **'Round {r} of {total}'**
  String roundOf(int r, int total);

  /// No description provided for @skipToDiscussion.
  ///
  /// In en, this message translates to:
  /// **'Skip to discussion'**
  String get skipToDiscussion;

  /// No description provided for @discussion.
  ///
  /// In en, this message translates to:
  /// **'Discussion'**
  String get discussion;

  /// No description provided for @discussionPrompt.
  ///
  /// In en, this message translates to:
  /// **'Who sounded suspicious? Talk it out.'**
  String get discussionPrompt;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @timeUp.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get timeUp;

  /// No description provided for @goToVote.
  ///
  /// In en, this message translates to:
  /// **'Go to vote'**
  String get goToVote;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// No description provided for @whoIsImposter.
  ///
  /// In en, this message translates to:
  /// **'Who is the imposter?'**
  String get whoIsImposter;

  /// No description provided for @tapMostVoted.
  ///
  /// In en, this message translates to:
  /// **'Vote out loud, then tap the player with the most votes.'**
  String get tapMostVoted;

  /// No description provided for @itsATie.
  ///
  /// In en, this message translates to:
  /// **'It\'s a tie'**
  String get itsATie;

  /// No description provided for @selectTied.
  ///
  /// In en, this message translates to:
  /// **'Select the tied players'**
  String get selectTied;

  /// No description provided for @noImposter.
  ///
  /// In en, this message translates to:
  /// **'No imposter'**
  String get noImposter;

  /// No description provided for @castYourVote.
  ///
  /// In en, this message translates to:
  /// **'{name}, cast your secret vote'**
  String castYourVote(String name);

  /// No description provided for @passDeviceTo.
  ///
  /// In en, this message translates to:
  /// **'Pass the device to {name}'**
  String passDeviceTo(String name);

  /// No description provided for @imReady.
  ///
  /// In en, this message translates to:
  /// **'I\'m {name} — show the ballot'**
  String imReady(String name);

  /// No description provided for @revoteNotice.
  ///
  /// In en, this message translates to:
  /// **'Tie! Vote again between the tied players.'**
  String get revoteNotice;

  /// No description provided for @wasCrew.
  ///
  /// In en, this message translates to:
  /// **'{name} was crew!'**
  String wasCrew(String name);

  /// No description provided for @wasImposter.
  ///
  /// In en, this message translates to:
  /// **'{name} was an imposter!'**
  String wasImposter(String name);

  /// No description provided for @impostersLeft.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 imposter is still hiding.} other{{n} imposters are still hiding.}}'**
  String impostersLeft(int n);

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @lastChance.
  ///
  /// In en, this message translates to:
  /// **'Last chance!'**
  String get lastChance;

  /// No description provided for @lastChanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Imposter, guess the secret word to steal the win.'**
  String get lastChanceDesc;

  /// No description provided for @yourGuess.
  ///
  /// In en, this message translates to:
  /// **'Your guess'**
  String get yourGuess;

  /// No description provided for @submitGuess.
  ///
  /// In en, this message translates to:
  /// **'Submit guess'**
  String get submitGuess;

  /// No description provided for @countIt.
  ///
  /// In en, this message translates to:
  /// **'Close enough — count it'**
  String get countIt;

  /// No description provided for @giveUp.
  ///
  /// In en, this message translates to:
  /// **'Give up'**
  String get giveUp;

  /// No description provided for @crewWins.
  ///
  /// In en, this message translates to:
  /// **'Crew wins!'**
  String get crewWins;

  /// No description provided for @impostersWin.
  ///
  /// In en, this message translates to:
  /// **'Imposters win!'**
  String get impostersWin;

  /// No description provided for @nobodyWins.
  ///
  /// In en, this message translates to:
  /// **'Chaos wins!'**
  String get nobodyWins;

  /// No description provided for @theImposterWas.
  ///
  /// In en, this message translates to:
  /// **'The imposter was'**
  String get theImposterWas;

  /// No description provided for @theImpostersWere.
  ///
  /// In en, this message translates to:
  /// **'The imposters were'**
  String get theImpostersWere;

  /// No description provided for @nobodyWasImposter.
  ///
  /// In en, this message translates to:
  /// **'There was no imposter!'**
  String get nobodyWasImposter;

  /// No description provided for @secretWord.
  ///
  /// In en, this message translates to:
  /// **'Secret word'**
  String get secretWord;

  /// No description provided for @fakeWordWas.
  ///
  /// In en, this message translates to:
  /// **'Fake word'**
  String get fakeWordWas;

  /// No description provided for @hintWas.
  ///
  /// In en, this message translates to:
  /// **'Imposter\'s hint'**
  String get hintWas;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @changeSetup.
  ///
  /// In en, this message translates to:
  /// **'Change setup'**
  String get changeSetup;

  /// No description provided for @reasonCaught.
  ///
  /// In en, this message translates to:
  /// **'All imposters were caught.'**
  String get reasonCaught;

  /// No description provided for @reasonWrong.
  ///
  /// In en, this message translates to:
  /// **'The crew voted out an innocent player.'**
  String get reasonWrong;

  /// No description provided for @reasonOutnumber.
  ///
  /// In en, this message translates to:
  /// **'The imposters now match the crew in number.'**
  String get reasonOutnumber;

  /// No description provided for @reasonTie.
  ///
  /// In en, this message translates to:
  /// **'A tie let the imposters escape.'**
  String get reasonTie;

  /// No description provided for @reasonNoImposterRight.
  ///
  /// In en, this message translates to:
  /// **'You correctly spotted that nobody was the imposter.'**
  String get reasonNoImposterRight;

  /// No description provided for @reasonNoImposterMissed.
  ///
  /// In en, this message translates to:
  /// **'There was an imposter after all!'**
  String get reasonNoImposterMissed;

  /// No description provided for @reasonVotedNobody.
  ///
  /// In en, this message translates to:
  /// **'There was no imposter — you accused an innocent player.'**
  String get reasonVotedNobody;

  /// No description provided for @reasonSteal.
  ///
  /// In en, this message translates to:
  /// **'The imposter guessed the word!'**
  String get reasonSteal;

  /// No description provided for @guessWas.
  ///
  /// In en, this message translates to:
  /// **'Guess: {guess}'**
  String guessWas(String guess);

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'+{n}'**
  String points(int n);

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeAmoled.
  ///
  /// In en, this message translates to:
  /// **'AMOLED'**
  String get themeAmoled;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent colour'**
  String get accentColor;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// No description provided for @reduceMotion.
  ///
  /// In en, this message translates to:
  /// **'Reduce motion'**
  String get reduceMotion;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @haptics.
  ///
  /// In en, this message translates to:
  /// **'Haptics'**
  String get haptics;

  /// No description provided for @gameplay.
  ///
  /// In en, this message translates to:
  /// **'Gameplay'**
  String get gameplay;

  /// No description provided for @revealStyle.
  ///
  /// In en, this message translates to:
  /// **'Reveal style'**
  String get revealStyle;

  /// No description provided for @revealHold.
  ///
  /// In en, this message translates to:
  /// **'Hold to reveal'**
  String get revealHold;

  /// No description provided for @revealTap.
  ///
  /// In en, this message translates to:
  /// **'Tap to reveal'**
  String get revealTap;

  /// No description provided for @tieRule.
  ///
  /// In en, this message translates to:
  /// **'Tie rule'**
  String get tieRule;

  /// No description provided for @tieRevote.
  ///
  /// In en, this message translates to:
  /// **'Revote'**
  String get tieRevote;

  /// No description provided for @tieImposters.
  ///
  /// In en, this message translates to:
  /// **'Imposter wins'**
  String get tieImposters;

  /// No description provided for @voteStyle.
  ///
  /// In en, this message translates to:
  /// **'Voting'**
  String get voteStyle;

  /// No description provided for @voteSimple.
  ///
  /// In en, this message translates to:
  /// **'Simple (tap the most voted)'**
  String get voteSimple;

  /// No description provided for @votePrivate.
  ///
  /// In en, this message translates to:
  /// **'Private pass-around voting'**
  String get votePrivate;

  /// No description provided for @avoidSameImposter.
  ///
  /// In en, this message translates to:
  /// **'Avoid same imposter back-to-back'**
  String get avoidSameImposter;

  /// No description provided for @maybeNobodyChance.
  ///
  /// In en, this message translates to:
  /// **'\"Maybe nobody\" chance'**
  String get maybeNobodyChance;

  /// No description provided for @seating.
  ///
  /// In en, this message translates to:
  /// **'Turn order'**
  String get seating;

  /// No description provided for @seatingFromStarter.
  ///
  /// In en, this message translates to:
  /// **'Seating order from starter'**
  String get seatingFromStarter;

  /// No description provided for @seatingShuffled.
  ///
  /// In en, this message translates to:
  /// **'Fully shuffled'**
  String get seatingShuffled;

  /// No description provided for @lastChanceSetting.
  ///
  /// In en, this message translates to:
  /// **'Imposter gets a last chance to guess'**
  String get lastChanceSetting;

  /// No description provided for @scoreboardSetting.
  ///
  /// In en, this message translates to:
  /// **'Running scoreboard'**
  String get scoreboardSetting;

  /// No description provided for @wordSources.
  ///
  /// In en, this message translates to:
  /// **'Word sources'**
  String get wordSources;

  /// No description provided for @cachedWords.
  ///
  /// In en, this message translates to:
  /// **'{n} cached words'**
  String cachedWords(int n);

  /// No description provided for @packsInfo.
  ///
  /// In en, this message translates to:
  /// **'{packs} packs, {words} words'**
  String packsInfo(int packs, int words);

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared'**
  String get cacheCleared;

  /// No description provided for @refreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing in the background…'**
  String get refreshing;

  /// No description provided for @resetHistory.
  ///
  /// In en, this message translates to:
  /// **'Reset word history'**
  String get resetHistory;

  /// No description provided for @historyReset.
  ///
  /// In en, this message translates to:
  /// **'Word history reset'**
  String get historyReset;

  /// No description provided for @myWords.
  ///
  /// In en, this message translates to:
  /// **'My Words'**
  String get myWords;

  /// No description provided for @newPack.
  ///
  /// In en, this message translates to:
  /// **'New pack'**
  String get newPack;

  /// No description provided for @packName.
  ///
  /// In en, this message translates to:
  /// **'Pack name'**
  String get packName;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @addWord.
  ///
  /// In en, this message translates to:
  /// **'Add word'**
  String get addWord;

  /// No description provided for @editWord.
  ///
  /// In en, this message translates to:
  /// **'Edit word'**
  String get editWord;

  /// No description provided for @word.
  ///
  /// In en, this message translates to:
  /// **'Word'**
  String get word;

  /// No description provided for @bulkPaste.
  ///
  /// In en, this message translates to:
  /// **'Bulk paste'**
  String get bulkPaste;

  /// No description provided for @bulkPasteHint.
  ///
  /// In en, this message translates to:
  /// **'One word per line'**
  String get bulkPasteHint;

  /// No description provided for @importFile.
  ///
  /// In en, this message translates to:
  /// **'Import CSV / JSON'**
  String get importFile;

  /// No description provided for @exportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get exportJson;

  /// No description provided for @needsHints.
  ///
  /// In en, this message translates to:
  /// **'needs hints'**
  String get needsHints;

  /// No description provided for @hintsOptional.
  ///
  /// In en, this message translates to:
  /// **'Hints (optional, one per line)'**
  String get hintsOptional;

  /// No description provided for @fakesOptional.
  ///
  /// In en, this message translates to:
  /// **'Fake words (optional, one per line)'**
  String get fakesOptional;

  /// No description provided for @autoEnrich.
  ///
  /// In en, this message translates to:
  /// **'Find hints online'**
  String get autoEnrich;

  /// No description provided for @enriching.
  ///
  /// In en, this message translates to:
  /// **'Searching for hints…'**
  String get enriching;

  /// No description provided for @enrichFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t find good hints. You can type your own.'**
  String get enrichFailed;

  /// No description provided for @wordsCount.
  ///
  /// In en, this message translates to:
  /// **'{n, plural, =1{1 word} other{{n} words}}'**
  String wordsCount(int n);

  /// No description provided for @noPacksYet.
  ///
  /// In en, this message translates to:
  /// **'No packs yet. Create one or search a custom topic.'**
  String get noPacksYet;

  /// No description provided for @noWordsYet.
  ///
  /// In en, this message translates to:
  /// **'No words yet. Add some!'**
  String get noWordsYet;

  /// No description provided for @customTopic.
  ///
  /// In en, this message translates to:
  /// **'Custom topic'**
  String get customTopic;

  /// No description provided for @topicHint.
  ///
  /// In en, this message translates to:
  /// **'Type any topic, e.g. Dinosaurs'**
  String get topicHint;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @saveAsPack.
  ///
  /// In en, this message translates to:
  /// **'Save as pack'**
  String get saveAsPack;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No words found for this topic.'**
  String get noResults;

  /// No description provided for @imported.
  ///
  /// In en, this message translates to:
  /// **'Imported {n} words'**
  String imported(int n);

  /// No description provided for @exported.
  ///
  /// In en, this message translates to:
  /// **'Exported'**
  String get exported;

  /// No description provided for @deletePackConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this pack and all its words?'**
  String get deletePackConfirm;

  /// No description provided for @needsInternet.
  ///
  /// In en, this message translates to:
  /// **'Needs internet'**
  String get needsInternet;

  /// No description provided for @addedWords.
  ///
  /// In en, this message translates to:
  /// **'Added {n} words'**
  String addedWords(int n);

  /// No description provided for @removeWord.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeWord;

  /// No description provided for @addCustomWord.
  ///
  /// In en, this message translates to:
  /// **'Add a word'**
  String get addCustomWord;

  /// No description provided for @noticeCache.
  ///
  /// In en, this message translates to:
  /// **'Offline — using cached online words.'**
  String get noticeCache;

  /// No description provided for @noticePacks.
  ///
  /// In en, this message translates to:
  /// **'Online words unavailable — using Offline Packs.'**
  String get noticePacks;

  /// No description provided for @noticeNoWords.
  ///
  /// In en, this message translates to:
  /// **'No words available for these categories.'**
  String get noticeNoWords;

  /// No description provided for @noticeFakeFallback.
  ///
  /// In en, this message translates to:
  /// **'No fake word available — playing Hint mode this round.'**
  String get noticeFakeFallback;

  /// No description provided for @leaveGameTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave this game?'**
  String get leaveGameTitle;

  /// No description provided for @leaveGameBody.
  ///
  /// In en, this message translates to:
  /// **'The current round will be lost. Players and scores are kept.'**
  String get leaveGameBody;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @howTitle.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howTitle;

  /// No description provided for @how1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Set up'**
  String get how1Title;

  /// No description provided for @how1Body.
  ///
  /// In en, this message translates to:
  /// **'Add 3–20 players, pick categories and a mode. Everyone sits in a circle around one device.'**
  String get how1Body;

  /// No description provided for @how2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Secret cards'**
  String get how2Title;

  /// No description provided for @how2Body.
  ///
  /// In en, this message translates to:
  /// **'Pass the device around. Each player privately reveals their card: the crew sees the secret word, the imposter does not.'**
  String get how2Body;

  /// No description provided for @how3Title.
  ///
  /// In en, this message translates to:
  /// **'3. One-word clues'**
  String get how3Title;

  /// No description provided for @how3Body.
  ///
  /// In en, this message translates to:
  /// **'Starting with a random player, everyone says ONE word related to the secret word. Crew: prove you know it without giving it away. Imposter: bluff!'**
  String get how3Body;

  /// No description provided for @how4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Discuss and vote'**
  String get how4Title;

  /// No description provided for @how4Body.
  ///
  /// In en, this message translates to:
  /// **'Talk it over, then vote out the player you think is the imposter. With several imposters, keep voting until they are all caught — or they equal the crew.'**
  String get how4Body;

  /// No description provided for @how5Title.
  ///
  /// In en, this message translates to:
  /// **'5. Last chance'**
  String get how5Title;

  /// No description provided for @how5Body.
  ///
  /// In en, this message translates to:
  /// **'A caught imposter may guess the secret word to steal the win.'**
  String get how5Body;

  /// No description provided for @howModesTitle.
  ///
  /// In en, this message translates to:
  /// **'Modes'**
  String get howModesTitle;

  /// No description provided for @howModesBody.
  ///
  /// In en, this message translates to:
  /// **'Classic: the imposter sees only IMPOSTER. Hint: the imposter gets one clue. Fake word: the imposter gets a similar word and doesn\'t know it. Maybe nobody: sometimes there is no imposter — vote \"No imposter\" to win.'**
  String get howModesBody;

  /// No description provided for @howKeysTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyboard'**
  String get howKeysTitle;

  /// No description provided for @howKeysBody.
  ///
  /// In en, this message translates to:
  /// **'Space or Enter: next. Hold Space on a card to reveal it (hold mode). Esc: back.'**
  String get howKeysBody;

  /// No description provided for @aboutFree.
  ///
  /// In en, this message translates to:
  /// **'100% free. No ads, no accounts, no tracking, no purchases. Every mode and word source is unlocked.'**
  String get aboutFree;

  /// No description provided for @aboutCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits & data licences'**
  String get aboutCredits;

  /// No description provided for @creditWikipedia.
  ///
  /// In en, this message translates to:
  /// **'Wikipedia & Wikidata — text under CC BY-SA; Wikidata under CC0'**
  String get creditWikipedia;

  /// No description provided for @creditConceptNet.
  ///
  /// In en, this message translates to:
  /// **'ConceptNet — CC BY-SA 4.0'**
  String get creditConceptNet;

  /// No description provided for @creditDatamuse.
  ///
  /// In en, this message translates to:
  /// **'Datamuse API — free word-finding service'**
  String get creditDatamuse;

  /// No description provided for @creditPacks.
  ///
  /// In en, this message translates to:
  /// **'Offline Packs — original content written for Hushbug'**
  String get creditPacks;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {v}'**
  String version(String v);

  /// No description provided for @mascotLabel.
  ///
  /// In en, this message translates to:
  /// **'Hushbug, a beetle putting a finger to its lips'**
  String get mascotLabel;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @savedGroups.
  ///
  /// In en, this message translates to:
  /// **'Saved groups'**
  String get savedGroups;

  /// No description provided for @saveAsGroup.
  ///
  /// In en, this message translates to:
  /// **'Save these players as a group'**
  String get saveAsGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @groupNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. College friends'**
  String get groupNameHint;

  /// No description provided for @groupSaved.
  ///
  /// In en, this message translates to:
  /// **'Group \"{name}\" saved'**
  String groupSaved(String name);

  /// No description provided for @groupLoaded.
  ///
  /// In en, this message translates to:
  /// **'Loaded \"{name}\" ({n} players)'**
  String groupLoaded(String name, int n);

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No saved groups yet. Type your players\' names once, then save them as a group to reuse next time.'**
  String get noGroupsYet;

  /// No description provided for @editGroup.
  ///
  /// In en, this message translates to:
  /// **'Edit group'**
  String get editGroup;

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @deleteGroupConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete the group \"{name}\"? Your current player list stays as it is.'**
  String deleteGroupConfirm(String name);

  /// No description provided for @groupPlayers.
  ///
  /// In en, this message translates to:
  /// **'{n} players'**
  String groupPlayers(int n);

  /// No description provided for @groupExists.
  ///
  /// In en, this message translates to:
  /// **'A group called \"{name}\" already exists. Replace it?'**
  String groupExists(String name);

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @groupsHelp.
  ///
  /// In en, this message translates to:
  /// **'Tap a group to load its players. Use the pencil to rename it or add/remove players.'**
  String get groupsHelp;

  /// No description provided for @deleteAllWords.
  ///
  /// In en, this message translates to:
  /// **'Delete all words'**
  String get deleteAllWords;

  /// No description provided for @clearPackConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove every word from this pack? The pack itself stays.'**
  String get clearPackConfirm;

  /// No description provided for @wordRemoved.
  ///
  /// In en, this message translates to:
  /// **'\"{word}\" removed'**
  String wordRemoved(String word);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @deleteAllPacks.
  ///
  /// In en, this message translates to:
  /// **'Delete all My Words packs'**
  String get deleteAllPacks;

  /// No description provided for @deleteAllPacksConfirm.
  ///
  /// In en, this message translates to:
  /// **'This permanently removes all your custom packs and their words. It can\'t be undone.'**
  String get deleteAllPacksConfirm;

  /// No description provided for @allPacksDeleted.
  ///
  /// In en, this message translates to:
  /// **'All My Words packs deleted'**
  String get allPacksDeleted;

  /// No description provided for @packDeleted.
  ///
  /// In en, this message translates to:
  /// **'Pack deleted'**
  String get packDeleted;

  /// No description provided for @deletePack.
  ///
  /// In en, this message translates to:
  /// **'Delete pack'**
  String get deletePack;

  /// No description provided for @gameRules.
  ///
  /// In en, this message translates to:
  /// **'Game rules'**
  String get gameRules;

  /// No description provided for @gameRulesIntro.
  ///
  /// In en, this message translates to:
  /// **'These rules apply to every round. Changes save instantly.'**
  String get gameRulesIntro;

  /// No description provided for @secRoundFlow.
  ///
  /// In en, this message translates to:
  /// **'Round flow'**
  String get secRoundFlow;

  /// No description provided for @secImposterRules.
  ///
  /// In en, this message translates to:
  /// **'Imposter rules'**
  String get secImposterRules;

  /// No description provided for @secVoting.
  ///
  /// In en, this message translates to:
  /// **'Voting & scoring'**
  String get secVoting;

  /// No description provided for @secFun.
  ///
  /// In en, this message translates to:
  /// **'Fun extras'**
  String get secFun;

  /// No description provided for @secFunDesc.
  ///
  /// In en, this message translates to:
  /// **'Optional twists to spice up game night.'**
  String get secFunDesc;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @appPreferencesDesc.
  ///
  /// In en, this message translates to:
  /// **'Theme, language, sound, vibration, start-up screen and word data'**
  String get appPreferencesDesc;

  /// No description provided for @startup.
  ///
  /// In en, this message translates to:
  /// **'Start-up'**
  String get startup;

  /// No description provided for @askEveryLaunchDesc.
  ///
  /// In en, this message translates to:
  /// **'On: each time you open Hushbug you first choose where words come from (Online Search, Offline Packs or My Words). Off: the app opens straight to Game setup with the source you used last.'**
  String get askEveryLaunchDesc;

  /// No description provided for @soundDesc.
  ///
  /// In en, this message translates to:
  /// **'Timer ticks, reveal and win/lose sounds'**
  String get soundDesc;

  /// No description provided for @hapticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Short vibrations on reveal, votes and when time is up'**
  String get hapticsDesc;

  /// No description provided for @reduceMotionDesc.
  ///
  /// In en, this message translates to:
  /// **'Turns off confetti, card flips and other animations'**
  String get reduceMotionDesc;

  /// No description provided for @dataSection.
  ///
  /// In en, this message translates to:
  /// **'Word data'**
  String get dataSection;

  /// No description provided for @discussionTimerOffDesc.
  ///
  /// In en, this message translates to:
  /// **'No timer: talk as long as you like, then tap \"Go to vote\".'**
  String get discussionTimerOffDesc;

  /// No description provided for @discussionTimerOnDesc.
  ///
  /// In en, this message translates to:
  /// **'Everyone gets {time} to discuss before voting starts.'**
  String discussionTimerOnDesc(String time);

  /// No description provided for @clueRoundsDesc.
  ///
  /// In en, this message translates to:
  /// **'How many times each player gives a one-word clue. Two rounds give more information and make bluffing harder.'**
  String get clueRoundsDesc;

  /// No description provided for @speedRoundSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Each clue must be given before a short countdown ends.'**
  String get speedRoundSettingDesc;

  /// No description provided for @revealHoldDesc.
  ///
  /// In en, this message translates to:
  /// **'Hold the card to see it, let go to hide it. Safest against peeking.'**
  String get revealHoldDesc;

  /// No description provided for @revealTapDesc.
  ///
  /// In en, this message translates to:
  /// **'Tap once to show the card, tap again to hide it.'**
  String get revealTapDesc;

  /// No description provided for @seatingFromStarterDesc.
  ///
  /// In en, this message translates to:
  /// **'Clues go around the circle in seat order, starting from a random player.'**
  String get seatingFromStarterDesc;

  /// No description provided for @seatingShuffledDesc.
  ///
  /// In en, this message translates to:
  /// **'The clue order is completely shuffled every round.'**
  String get seatingShuffledDesc;

  /// No description provided for @hintLevelDesc.
  ///
  /// In en, this message translates to:
  /// **'How helpful the imposter\'s hint is in Hint mode. Easy: two specific hints. Medium: one in-between hint. Hard: one vague, category-level hint.'**
  String get hintLevelDesc;

  /// No description provided for @avoidSameImposterDesc.
  ///
  /// In en, this message translates to:
  /// **'Last round\'s imposter won\'t be picked again in the next round.'**
  String get avoidSameImposterDesc;

  /// No description provided for @maybeNobodySettingDesc.
  ///
  /// In en, this message translates to:
  /// **'Sometimes there is no imposter at all. Players must vote \"No imposter\" to win.'**
  String get maybeNobodySettingDesc;

  /// No description provided for @maybeNobodyChanceDesc.
  ///
  /// In en, this message translates to:
  /// **'How often a round has no imposter.'**
  String get maybeNobodyChanceDesc;

  /// No description provided for @lastChanceSettingDesc.
  ///
  /// In en, this message translates to:
  /// **'A caught imposter gets one guess at the secret word. Guess right and the imposters steal the win.'**
  String get lastChanceSettingDesc;

  /// No description provided for @voteSimpleDesc.
  ///
  /// In en, this message translates to:
  /// **'Discuss out loud, then tap the player who got the most votes.'**
  String get voteSimpleDesc;

  /// No description provided for @votePrivateDesc.
  ///
  /// In en, this message translates to:
  /// **'Pass the phone around and everyone votes in secret.'**
  String get votePrivateDesc;

  /// No description provided for @tieRevoteDesc.
  ///
  /// In en, this message translates to:
  /// **'On a tie, vote again between only the tied players.'**
  String get tieRevoteDesc;

  /// No description provided for @tieImpostersDesc.
  ///
  /// In en, this message translates to:
  /// **'A tie means nobody is caught, so the imposters win.'**
  String get tieImpostersDesc;

  /// No description provided for @scoreboardDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep points across rounds: crew get +1 for a catch, imposters get +2 for escaping.'**
  String get scoreboardDesc;

  /// No description provided for @impostersKnowEachOther.
  ///
  /// In en, this message translates to:
  /// **'Imposter teammates'**
  String get impostersKnowEachOther;

  /// No description provided for @impostersKnowEachOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'With 2 or more imposters, each imposter sees who their partners are, so they can cover for each other. (Not used in Fake Word mode.)'**
  String get impostersKnowEachOtherDesc;

  /// No description provided for @crewStarts.
  ///
  /// In en, this message translates to:
  /// **'Crew always starts'**
  String get crewStarts;

  /// No description provided for @crewStartsDesc.
  ///
  /// In en, this message translates to:
  /// **'The first player to give a clue is never an imposter. Gentler for new players.'**
  String get crewStartsDesc;

  /// No description provided for @roundTwists.
  ///
  /// In en, this message translates to:
  /// **'Round twists'**
  String get roundTwists;

  /// No description provided for @roundTwistsDesc.
  ///
  /// In en, this message translates to:
  /// **'Every round adds a random fun rule for clues, like whispering or acting it out.'**
  String get roundTwistsDesc;

  /// No description provided for @yourPartners.
  ///
  /// In en, this message translates to:
  /// **'Your partner: {names}'**
  String yourPartners(String names);

  /// No description provided for @twistTitle.
  ///
  /// In en, this message translates to:
  /// **'Round twist!'**
  String get twistTitle;

  /// No description provided for @twist0.
  ///
  /// In en, this message translates to:
  /// **'One word only: no extra words, no gestures.'**
  String get twist0;

  /// No description provided for @twist1.
  ///
  /// In en, this message translates to:
  /// **'Silent round: act your clue out, no talking!'**
  String get twist1;

  /// No description provided for @twist2.
  ///
  /// In en, this message translates to:
  /// **'Whisper round: say your clue in a whisper.'**
  String get twist2;

  /// No description provided for @twist3.
  ///
  /// In en, this message translates to:
  /// **'Sound effect round: make a sound instead of saying a word.'**
  String get twist3;

  /// No description provided for @twist4.
  ///
  /// In en, this message translates to:
  /// **'Accent round: say your clue in your best funny accent.'**
  String get twist4;

  /// No description provided for @twist5.
  ///
  /// In en, this message translates to:
  /// **'Slow motion: say your clue as slowly as possible.'**
  String get twist5;

  /// No description provided for @twist6.
  ///
  /// In en, this message translates to:
  /// **'Question round: your clue must be a question.'**
  String get twist6;

  /// No description provided for @twist7.
  ///
  /// In en, this message translates to:
  /// **'Opposite round: give a clue about what the word is NOT.'**
  String get twist7;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
