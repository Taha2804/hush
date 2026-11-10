// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Hushbug';

  @override
  String get tagline => 'नकली को पकड़ो। राज़ छुपाओ।';

  @override
  String get next => 'आगे';

  @override
  String get back => 'पीछे';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get delete => 'हटाएँ';

  @override
  String get ok => 'ठीक है';

  @override
  String get done => 'हो गया';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get howToPlay => 'कैसे खेलें';

  @override
  String get about => 'परिचय';

  @override
  String get changeSource => 'स्रोत बदलें';

  @override
  String get loading => 'लोड हो रहा है…';

  @override
  String get retry => 'फिर कोशिश करें';

  @override
  String get close => 'बंद करें';

  @override
  String get chooseSource => 'शब्द स्रोत चुनें';

  @override
  String get badgeOnline => 'ऑनलाइन';

  @override
  String get badgeOffline => 'ऑफ़लाइन';

  @override
  String get sourceOnlineName => 'ऑनलाइन खोज';

  @override
  String get sourceOnlineDesc =>
      'विकिपीडिया, विकिडेटा, ConceptNet और Datamuse से ताज़ा और जाने-पहचाने शब्द, जो आपके डिवाइस पर सहेजे जाते हैं।';

  @override
  String get sourceOfflineName => 'ऑफ़लाइन पैक';

  @override
  String get sourceOfflineDesc =>
      '22 हाथ से बने पैक, 3,000 से ज़्यादा शब्द। हमेशा उपलब्ध।';

  @override
  String get sourceMyWordsName => 'मेरे शब्द';

  @override
  String get sourceMyWordsDesc =>
      'आपके अपने पैक। शब्द लिखें, चिपकाएँ या इम्पोर्ट करें।';

  @override
  String get reasonNoInternet => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get reasonNoPacks => 'पहले कम से कम एक शब्द वाला पैक बनाएँ';

  @override
  String get askEveryLaunch => 'हर बार ऐप खुलने पर पूछें';

  @override
  String get manageMyWords => 'मेरे शब्द प्रबंधित करें';

  @override
  String get checking => 'जाँच हो रही है…';

  @override
  String get setup => 'गेम सेटअप';

  @override
  String get players => 'खिलाड़ी';

  @override
  String get addPlayer => 'खिलाड़ी जोड़ें';

  @override
  String get playerName => 'खिलाड़ी का नाम';

  @override
  String playerN(int n) {
    return 'खिलाड़ी $n';
  }

  @override
  String get removePlayer => 'खिलाड़ी हटाएँ';

  @override
  String get imposters => 'धोखेबाज़';

  @override
  String get categories => 'श्रेणियाँ';

  @override
  String get randomMix => 'रैंडम मिक्स (सभी)';

  @override
  String get mode => 'मोड';

  @override
  String get modeClassic => 'क्लासिक';

  @override
  String get modeClassicDesc => 'धोखेबाज़ को सिर्फ़ IMPOSTER दिखता है।';

  @override
  String get modeHint => 'संकेत';

  @override
  String get modeHintDesc => 'धोखेबाज़ को शब्द के बारे में एक संकेत मिलता है।';

  @override
  String get modeFake => 'नकली शब्द';

  @override
  String get modeFakeDesc =>
      'धोखेबाज़ को मिलता-जुलता शब्द मिलता है और उसे पता नहीं होता कि वह धोखेबाज़ है।';

  @override
  String get discussionTimer => 'चर्चा टाइमर';

  @override
  String get off => 'बंद';

  @override
  String minutes(int n) {
    return '$n मिनट';
  }

  @override
  String seconds(int n) {
    return '$n सेकंड';
  }

  @override
  String get clueRounds => 'संकेत राउंड';

  @override
  String get hintLevel => 'संकेत स्तर';

  @override
  String get easy => 'आसान';

  @override
  String get medium => 'मध्यम';

  @override
  String get hard => 'कठिन';

  @override
  String get speedRound => 'स्पीड राउंड';

  @override
  String get speedRoundDesc => 'हर संकेत के लिए छोटा टाइमर';

  @override
  String get maybeNobody => 'शायद कोई नहीं';

  @override
  String maybeNobodyDesc(int p) {
    return '$p% संभावना कि कोई धोखेबाज़ नहीं है';
  }

  @override
  String get startGame => 'गेम शुरू करें';

  @override
  String get scoreboard => 'स्कोरबोर्ड';

  @override
  String get resetScores => 'स्कोर रीसेट करें';

  @override
  String sourceLabel(String name) {
    return 'स्रोत: $name';
  }

  @override
  String get needThreePlayers => 'कम से कम 3 खिलाड़ी चाहिए।';

  @override
  String get pickCategory => 'कम से कम एक श्रेणी चुनें।';

  @override
  String get moreOptions => 'और विकल्प';

  @override
  String passTo(String name) {
    return '$name को दें';
  }

  @override
  String get holdToReveal => 'देखने के लिए दबाकर रखें';

  @override
  String get tapToReveal => 'देखने के लिए टैप करें';

  @override
  String get tapToHide => 'छुपाने के लिए टैप करें';

  @override
  String get releaseToHide => 'छुपाने के लिए छोड़ें';

  @override
  String get yourWord => 'आपका गुप्त शब्द';

  @override
  String get imposterCard => 'धोखेबाज़';

  @override
  String yourHint(String hint) {
    return 'संकेत: $hint';
  }

  @override
  String get blendIn => 'घुल-मिल जाओ। पकड़े मत जाना।';

  @override
  String get cardSeen => 'कार्ड देख लिया — डिवाइस आगे दें';

  @override
  String get privacyNote => 'ध्यान रखें कि कोई और स्क्रीन न देखे।';

  @override
  String playerOfTotal(int i, int n) {
    return 'खिलाड़ी $i / $n';
  }

  @override
  String get clueTime => 'संकेत का समय';

  @override
  String startingPlayer(String name) {
    return '$name शुरू करेंगे!';
  }

  @override
  String get picking => 'कौन शुरू करेगा, चुन रहे हैं…';

  @override
  String get turnOrder => 'बारी का क्रम';

  @override
  String saysOneWord(String name) {
    return '$name, सिर्फ़ एक शब्द बोलें';
  }

  @override
  String roundOf(int r, int total) {
    return 'राउंड $r / $total';
  }

  @override
  String get skipToDiscussion => 'सीधे चर्चा पर जाएँ';

  @override
  String get discussion => 'चर्चा';

  @override
  String get discussionPrompt => 'किसकी बात संदिग्ध लगी? चर्चा करें।';

  @override
  String get pause => 'रोकें';

  @override
  String get resume => 'जारी रखें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get timeUp => 'समय समाप्त!';

  @override
  String get goToVote => 'वोट पर जाएँ';

  @override
  String get vote => 'वोट';

  @override
  String get whoIsImposter => 'धोखेबाज़ कौन है?';

  @override
  String get tapMostVoted =>
      'बोलकर वोट करें, फिर सबसे ज़्यादा वोट वाले खिलाड़ी पर टैप करें।';

  @override
  String get itsATie => 'बराबरी है';

  @override
  String get selectTied => 'बराबरी वाले खिलाड़ी चुनें';

  @override
  String get noImposter => 'कोई धोखेबाज़ नहीं';

  @override
  String castYourVote(String name) {
    return '$name, अपना गुप्त वोट दें';
  }

  @override
  String passDeviceTo(String name) {
    return 'डिवाइस $name को दें';
  }

  @override
  String imReady(String name) {
    return 'मैं $name हूँ — मतपत्र दिखाएँ';
  }

  @override
  String get revoteNotice =>
      'बराबरी! बराबरी वाले खिलाड़ियों के बीच फिर से वोट करें।';

  @override
  String wasCrew(String name) {
    return '$name क्रू में थे!';
  }

  @override
  String wasImposter(String name) {
    return '$name धोखेबाज़ थे!';
  }

  @override
  String impostersLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n धोखेबाज़ अभी भी छुपे हैं।',
      one: '1 धोखेबाज़ अभी भी छुपा है।',
    );
    return '$_temp0';
  }

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get lastChance => 'आख़िरी मौका!';

  @override
  String get lastChanceDesc =>
      'धोखेबाज़, जीत छीनने के लिए गुप्त शब्द का अनुमान लगाओ।';

  @override
  String get yourGuess => 'आपका अनुमान';

  @override
  String get submitGuess => 'अनुमान भेजें';

  @override
  String get countIt => 'काफ़ी क़रीब — मान लें';

  @override
  String get giveUp => 'हार मानें';

  @override
  String get crewWins => 'क्रू जीता!';

  @override
  String get impostersWin => 'धोखेबाज़ जीते!';

  @override
  String get nobodyWins => 'अराजकता जीती!';

  @override
  String get theImposterWas => 'धोखेबाज़ था';

  @override
  String get theImpostersWere => 'धोखेबाज़ थे';

  @override
  String get nobodyWasImposter => 'कोई धोखेबाज़ नहीं था!';

  @override
  String get secretWord => 'गुप्त शब्द';

  @override
  String get fakeWordWas => 'नकली शब्द';

  @override
  String get hintWas => 'धोखेबाज़ का संकेत';

  @override
  String get playAgain => 'फिर से खेलें';

  @override
  String get changeSetup => 'सेटअप बदलें';

  @override
  String get reasonCaught => 'सभी धोखेबाज़ पकड़े गए।';

  @override
  String get reasonWrong => 'क्रू ने एक निर्दोष खिलाड़ी को बाहर कर दिया।';

  @override
  String get reasonOutnumber => 'धोखेबाज़ अब क्रू के बराबर हैं।';

  @override
  String get reasonTie => 'बराबरी के कारण धोखेबाज़ बच निकले।';

  @override
  String get reasonNoImposterRight =>
      'आपने सही पहचाना कि कोई धोखेबाज़ नहीं था।';

  @override
  String get reasonNoImposterMissed => 'असल में एक धोखेबाज़ था!';

  @override
  String get reasonVotedNobody =>
      'कोई धोखेबाज़ नहीं था — आपने एक निर्दोष पर आरोप लगाया।';

  @override
  String get reasonSteal => 'धोखेबाज़ ने शब्द का सही अनुमान लगाया!';

  @override
  String guessWas(String guess) {
    return 'अनुमान: $guess';
  }

  @override
  String points(int n) {
    return '+$n';
  }

  @override
  String get appearance => 'रूप-रंग';

  @override
  String get theme => 'थीम';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeLight => 'हल्की';

  @override
  String get themeDark => 'गहरी';

  @override
  String get themeAmoled => 'AMOLED';

  @override
  String get accentColor => 'मुख्य रंग';

  @override
  String get language => 'भाषा';

  @override
  String get textSize => 'अक्षर का आकार';

  @override
  String get reduceMotion => 'एनिमेशन कम करें';

  @override
  String get sound => 'ध्वनि';

  @override
  String get haptics => 'कंपन';

  @override
  String get gameplay => 'गेमप्ले';

  @override
  String get revealStyle => 'कार्ड दिखाने का तरीका';

  @override
  String get revealHold => 'दबाकर रखें';

  @override
  String get revealTap => 'टैप करें';

  @override
  String get tieRule => 'बराबरी का नियम';

  @override
  String get tieRevote => 'फिर से वोट';

  @override
  String get tieImposters => 'धोखेबाज़ जीतें';

  @override
  String get voteStyle => 'वोटिंग';

  @override
  String get voteSimple => 'सरल (सबसे ज़्यादा वोट वाले पर टैप)';

  @override
  String get votePrivate => 'गुप्त, डिवाइस घुमाकर वोटिंग';

  @override
  String get avoidSameImposter => 'लगातार वही धोखेबाज़ न बने';

  @override
  String get maybeNobodyChance => '\"शायद कोई नहीं\" की संभावना';

  @override
  String get seating => 'बारी का क्रम';

  @override
  String get seatingFromStarter => 'शुरू करने वाले से बैठने का क्रम';

  @override
  String get seatingShuffled => 'पूरी तरह फेंटा हुआ';

  @override
  String get lastChanceSetting => 'धोखेबाज़ को अनुमान का आख़िरी मौका';

  @override
  String get scoreboardSetting => 'लगातार स्कोरबोर्ड';

  @override
  String get wordSources => 'शब्द स्रोत';

  @override
  String cachedWords(int n) {
    return '$n सहेजे गए शब्द';
  }

  @override
  String packsInfo(int packs, int words) {
    return '$packs पैक, $words शब्द';
  }

  @override
  String get refresh => 'रीफ़्रेश';

  @override
  String get clearCache => 'कैश साफ़ करें';

  @override
  String get cacheCleared => 'कैश साफ़ हो गया';

  @override
  String get refreshing => 'पृष्ठभूमि में रीफ़्रेश हो रहा है…';

  @override
  String get resetHistory => 'शब्द इतिहास रीसेट करें';

  @override
  String get historyReset => 'शब्द इतिहास रीसेट हुआ';

  @override
  String get myWords => 'मेरे शब्द';

  @override
  String get newPack => 'नया पैक';

  @override
  String get packName => 'पैक का नाम';

  @override
  String get rename => 'नाम बदलें';

  @override
  String get addWord => 'शब्द जोड़ें';

  @override
  String get editWord => 'शब्द बदलें';

  @override
  String get word => 'शब्द';

  @override
  String get bulkPaste => 'एक साथ चिपकाएँ';

  @override
  String get bulkPasteHint => 'हर पंक्ति में एक शब्द';

  @override
  String get importFile => 'CSV / JSON इम्पोर्ट करें';

  @override
  String get exportJson => 'JSON एक्सपोर्ट करें';

  @override
  String get needsHints => 'संकेत चाहिए';

  @override
  String get hintsOptional => 'संकेत (वैकल्पिक, हर पंक्ति में एक)';

  @override
  String get fakesOptional => 'नकली शब्द (वैकल्पिक, हर पंक्ति में एक)';

  @override
  String get autoEnrich => 'ऑनलाइन संकेत खोजें';

  @override
  String get enriching => 'संकेत खोज रहे हैं…';

  @override
  String get enrichFailed => 'अच्छे संकेत नहीं मिले। आप खुद लिख सकते हैं।';

  @override
  String wordsCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n शब्द',
      one: '1 शब्द',
    );
    return '$_temp0';
  }

  @override
  String get noPacksYet => 'अभी कोई पैक नहीं। एक बनाएँ या कोई विषय खोजें।';

  @override
  String get noWordsYet => 'अभी कोई शब्द नहीं। कुछ जोड़ें!';

  @override
  String get customTopic => 'अपना विषय';

  @override
  String get topicHint => 'कोई भी विषय लिखें, जैसे डायनासोर';

  @override
  String get search => 'खोजें';

  @override
  String get saveAsPack => 'पैक के रूप में सहेजें';

  @override
  String get noResults => 'इस विषय के लिए कोई शब्द नहीं मिला।';

  @override
  String imported(int n) {
    return '$n शब्द इम्पोर्ट हुए';
  }

  @override
  String get exported => 'एक्सपोर्ट हो गया';

  @override
  String get deletePackConfirm => 'यह पैक और इसके सभी शब्द हटाएँ?';

  @override
  String get needsInternet => 'इंटरनेट चाहिए';

  @override
  String addedWords(int n) {
    return '$n शब्द जोड़े गए';
  }

  @override
  String get removeWord => 'हटाएँ';

  @override
  String get addCustomWord => 'एक शब्द जोड़ें';

  @override
  String get noticeCache => 'ऑफ़लाइन — सहेजे गए ऑनलाइन शब्दों का उपयोग।';

  @override
  String get noticePacks => 'ऑनलाइन शब्द उपलब्ध नहीं — ऑफ़लाइन पैक का उपयोग।';

  @override
  String get noticeNoWords => 'इन श्रेणियों के लिए कोई शब्द उपलब्ध नहीं।';

  @override
  String get noticeFakeFallback =>
      'नकली शब्द उपलब्ध नहीं — इस राउंड में संकेत मोड।';

  @override
  String get leaveGameTitle => 'यह गेम छोड़ें?';

  @override
  String get leaveGameBody =>
      'मौजूदा राउंड खो जाएगा। खिलाड़ी और स्कोर बने रहेंगे।';

  @override
  String get leave => 'छोड़ें';

  @override
  String get howTitle => 'कैसे खेलें';

  @override
  String get how1Title => '1. सेटअप';

  @override
  String get how1Body =>
      '3–20 खिलाड़ी जोड़ें, श्रेणियाँ और मोड चुनें। सब एक डिवाइस के चारों ओर गोल घेरे में बैठें।';

  @override
  String get how2Title => '2. गुप्त कार्ड';

  @override
  String get how2Body =>
      'डिवाइस घुमाएँ। हर खिलाड़ी अकेले में अपना कार्ड देखे: क्रू को गुप्त शब्द दिखता है, धोखेबाज़ को नहीं।';

  @override
  String get how3Title => '3. एक शब्द के संकेत';

  @override
  String get how3Body =>
      'किसी रैंडम खिलाड़ी से शुरू करके, हर कोई गुप्त शब्द से जुड़ा सिर्फ़ एक शब्द बोले। क्रू: बिना बताए साबित करो कि तुम जानते हो। धोखेबाज़: झाँसा दो!';

  @override
  String get how4Title => '4. चर्चा और वोट';

  @override
  String get how4Body =>
      'चर्चा करें, फिर जिस पर शक हो उसे बाहर करें। कई धोखेबाज़ हों तो तब तक वोट करें जब तक सब पकड़े न जाएँ — या वे क्रू के बराबर न हो जाएँ।';

  @override
  String get how5Title => '5. आख़िरी मौका';

  @override
  String get how5Body =>
      'पकड़ा गया धोखेबाज़ गुप्त शब्द का अनुमान लगाकर जीत छीन सकता है।';

  @override
  String get howModesTitle => 'मोड';

  @override
  String get howModesBody =>
      'क्लासिक: धोखेबाज़ को सिर्फ़ IMPOSTER दिखता है। संकेत: धोखेबाज़ को एक संकेत मिलता है। नकली शब्द: धोखेबाज़ को मिलता-जुलता शब्द मिलता है और उसे पता नहीं होता। शायद कोई नहीं: कभी-कभी कोई धोखेबाज़ नहीं होता — जीतने के लिए \"कोई धोखेबाज़ नहीं\" चुनें।';

  @override
  String get howKeysTitle => 'कीबोर्ड';

  @override
  String get howKeysBody =>
      'Space या Enter: आगे। कार्ड देखने के लिए Space दबाकर रखें (होल्ड मोड)। Esc: पीछे।';

  @override
  String get aboutFree =>
      '100% मुफ़्त। कोई विज्ञापन, अकाउंट, ट्रैकिंग या ख़रीदारी नहीं। हर मोड और स्रोत खुला है।';

  @override
  String get aboutCredits => 'श्रेय और डेटा लाइसेंस';

  @override
  String get creditWikipedia =>
      'विकिपीडिया और विकिडेटा — टेक्स्ट CC BY-SA के तहत; विकिडेटा CC0';

  @override
  String get creditConceptNet => 'ConceptNet — CC BY-SA 4.0';

  @override
  String get creditDatamuse => 'Datamuse API — मुफ़्त शब्द खोज सेवा';

  @override
  String get creditPacks => 'ऑफ़लाइन पैक — Hushbug के लिए लिखी गई मूल सामग्री';

  @override
  String version(String v) {
    return 'संस्करण $v';
  }

  @override
  String get mascotLabel => 'Hushbug, होंठों पर उँगली रखे एक भृंग';

  @override
  String get groups => 'ग्रुप';

  @override
  String get savedGroups => 'सेव किए गए ग्रुप';

  @override
  String get saveAsGroup => 'इन खिलाड़ियों को ग्रुप के रूप में सेव करें';

  @override
  String get groupName => 'ग्रुप का नाम';

  @override
  String get groupNameHint => 'जैसे: कॉलेज के दोस्त';

  @override
  String groupSaved(String name) {
    return 'ग्रुप \"$name\" सेव हो गया';
  }

  @override
  String groupLoaded(String name, int n) {
    return '\"$name\" लोड हुआ ($n खिलाड़ी)';
  }

  @override
  String get noGroupsYet =>
      'अभी कोई ग्रुप सेव नहीं है। खिलाड़ियों के नाम एक बार लिखें, फिर उन्हें ग्रुप के रूप में सेव करें ताकि अगली बार दोबारा न लिखना पड़े।';

  @override
  String get editGroup => 'ग्रुप बदलें';

  @override
  String get newGroup => 'नया ग्रुप';

  @override
  String deleteGroupConfirm(String name) {
    return 'ग्रुप \"$name\" हटाएँ? आपकी मौजूदा खिलाड़ी सूची वैसी ही रहेगी।';
  }

  @override
  String groupPlayers(int n) {
    return '$n खिलाड़ी';
  }

  @override
  String groupExists(String name) {
    return '\"$name\" नाम का ग्रुप पहले से है। उसे बदलें?';
  }

  @override
  String get replace => 'बदलें';

  @override
  String get groupsHelp =>
      'खिलाड़ी लोड करने के लिए ग्रुप पर टैप करें। नाम बदलने या खिलाड़ी जोड़ने/हटाने के लिए पेंसिल दबाएँ।';

  @override
  String get deleteAllWords => 'सारे शब्द हटाएँ';

  @override
  String get clearPackConfirm => 'इस पैक से सारे शब्द हटाएँ? पैक बना रहेगा।';

  @override
  String wordRemoved(String word) {
    return '\"$word\" हटाया गया';
  }

  @override
  String get undo => 'वापस लाएँ';

  @override
  String get deleteAllPacks => 'My Words के सारे पैक हटाएँ';

  @override
  String get deleteAllPacksConfirm =>
      'इससे आपके सारे पैक और उनके शब्द हमेशा के लिए हट जाएँगे। इसे वापस नहीं लाया जा सकता।';

  @override
  String get allPacksDeleted => 'My Words के सारे पैक हटा दिए गए';

  @override
  String get packDeleted => 'पैक हटाया गया';

  @override
  String get deletePack => 'पैक हटाएँ';

  @override
  String get gameRules => 'खेल के नियम';

  @override
  String get gameRulesIntro =>
      'ये नियम हर राउंड पर लागू होते हैं। बदलाव तुरंत सेव हो जाते हैं।';

  @override
  String get secRoundFlow => 'राउंड का क्रम';

  @override
  String get secImposterRules => 'इम्पोस्टर के नियम';

  @override
  String get secVoting => 'वोटिंग और स्कोर';

  @override
  String get secFun => 'मज़ेदार एक्स्ट्रा';

  @override
  String get secFunDesc => 'खेल को और मज़ेदार बनाने के लिए वैकल्पिक ट्विस्ट।';

  @override
  String get appPreferences => 'ऐप की पसंद';

  @override
  String get appPreferencesDesc =>
      'थीम, भाषा, आवाज़, वाइब्रेशन, शुरुआती स्क्रीन और शब्द डेटा';

  @override
  String get startup => 'ऐप खुलने पर';

  @override
  String get askEveryLaunchDesc =>
      'चालू: हर बार Hushbug खोलने पर पहले चुनें कि शब्द कहाँ से आएँ (ऑनलाइन, ऑफ़लाइन पैक या My Words)। बंद: ऐप सीधे गेम सेटअप पर खुलेगा और पिछली बार वाला स्रोत इस्तेमाल करेगा।';

  @override
  String get soundDesc => 'टाइमर की टिक-टिक, कार्ड खुलने और जीत/हार की आवाज़ें';

  @override
  String get hapticsDesc =>
      'कार्ड खुलने, वोट और समय खत्म होने पर हल्का वाइब्रेशन';

  @override
  String get reduceMotionDesc =>
      'कॉन्फ़ेटी, कार्ड पलटना और दूसरे एनिमेशन बंद करता है';

  @override
  String get dataSection => 'शब्द डेटा';

  @override
  String get discussionTimerOffDesc =>
      'कोई टाइमर नहीं: जितनी देर चाहें बात करें, फिर \"वोट पर जाएँ\" दबाएँ।';

  @override
  String discussionTimerOnDesc(String time) {
    return 'वोटिंग से पहले सबको चर्चा के लिए $time मिलेंगे।';
  }

  @override
  String get clueRoundsDesc =>
      'हर खिलाड़ी कितनी बार एक-शब्द का सुराग देगा। दो राउंड में ज़्यादा जानकारी मिलती है और झूठ बोलना मुश्किल होता है।';

  @override
  String get speedRoundSettingDesc =>
      'हर सुराग एक छोटे काउंटडाउन के खत्म होने से पहले देना होगा।';

  @override
  String get revealHoldDesc =>
      'कार्ड देखने के लिए दबाकर रखें, छोड़ते ही छिप जाएगा। झाँकने से सबसे सुरक्षित।';

  @override
  String get revealTapDesc =>
      'कार्ड दिखाने के लिए एक बार टैप करें, छिपाने के लिए फिर टैप करें।';

  @override
  String get seatingFromStarterDesc =>
      'सुराग बैठने के क्रम में घूमते हैं, किसी रैंडम खिलाड़ी से शुरू होकर।';

  @override
  String get seatingShuffledDesc =>
      'हर राउंड में सुराग देने का क्रम पूरी तरह मिलाया जाता है।';

  @override
  String get hintLevelDesc =>
      'हिंट मोड में इम्पोस्टर का हिंट कितना मददगार हो। आसान: दो साफ़ हिंट। मध्यम: एक बीच का हिंट। कठिन: एक धुँधला, श्रेणी-स्तर का हिंट।';

  @override
  String get avoidSameImposterDesc =>
      'पिछले राउंड का इम्पोस्टर अगले राउंड में दोबारा नहीं चुना जाएगा।';

  @override
  String get maybeNobodySettingDesc =>
      'कभी-कभी कोई इम्पोस्टर नहीं होता। जीतने के लिए खिलाड़ियों को \"कोई इम्पोस्टर नहीं\" वोट करना होगा।';

  @override
  String get maybeNobodyChanceDesc =>
      'कितनी बार राउंड में कोई इम्पोस्टर नहीं होगा।';

  @override
  String get lastChanceSettingDesc =>
      'पकड़े गए इम्पोस्टर को गुप्त शब्द का एक अंदाज़ा लगाने का मौका मिलता है। सही हुआ तो इम्पोस्टर जीत छीन लेते हैं।';

  @override
  String get voteSimpleDesc =>
      'ज़ोर से चर्चा करें, फिर सबसे ज़्यादा वोट पाने वाले खिलाड़ी पर टैप करें।';

  @override
  String get votePrivateDesc => 'फ़ोन घुमाएँ और हर कोई गुप्त रूप से वोट करे।';

  @override
  String get tieRevoteDesc =>
      'बराबरी होने पर सिर्फ़ बराबर वाले खिलाड़ियों के बीच फिर वोट होगा।';

  @override
  String get tieImpostersDesc =>
      'बराबरी का मतलब कोई नहीं पकड़ा गया, इसलिए इम्पोस्टर जीतते हैं।';

  @override
  String get scoreboardDesc =>
      'राउंड दर राउंड अंक रखें: पकड़ने पर क्रू को +1, बच निकलने पर इम्पोस्टर को +2।';

  @override
  String get impostersKnowEachOther => 'इम्पोस्टर साथी';

  @override
  String get impostersKnowEachOtherDesc =>
      '2 या ज़्यादा इम्पोस्टर होने पर हर इम्पोस्टर देख सकता है कि उसके साथी कौन हैं, ताकि वे एक-दूसरे को बचा सकें। (नकली शब्द मोड में लागू नहीं।)';

  @override
  String get crewStarts => 'हमेशा क्रू शुरू करे';

  @override
  String get crewStartsDesc =>
      'पहला सुराग देने वाला खिलाड़ी कभी इम्पोस्टर नहीं होगा। नए खिलाड़ियों के लिए आसान।';

  @override
  String get roundTwists => 'राउंड ट्विस्ट';

  @override
  String get roundTwistsDesc =>
      'हर राउंड में सुराग देने का एक मज़ेदार रैंडम नियम जुड़ता है, जैसे फुसफुसाना या एक्टिंग करना।';

  @override
  String yourPartners(String names) {
    return 'आपके साथी: $names';
  }

  @override
  String get twistTitle => 'राउंड ट्विस्ट!';

  @override
  String get twist0 => 'सिर्फ़ एक शब्द: न ज़्यादा शब्द, न इशारे।';

  @override
  String get twist1 => 'मौन राउंड: बिना बोले एक्टिंग करके सुराग दें!';

  @override
  String get twist2 => 'फुसफुसाहट राउंड: अपना सुराग फुसफुसाकर बोलें।';

  @override
  String get twist3 => 'आवाज़ राउंड: शब्द की जगह कोई आवाज़ निकालें।';

  @override
  String get twist4 => 'लहजा राउंड: अपना सुराग किसी मज़ेदार लहजे में बोलें।';

  @override
  String get twist5 => 'स्लो मोशन: अपना सुराग जितना हो सके धीरे बोलें।';

  @override
  String get twist6 => 'सवाल राउंड: आपका सुराग एक सवाल होना चाहिए।';

  @override
  String get twist7 => 'उल्टा राउंड: बताएँ कि वह शब्द क्या नहीं है।';
}
