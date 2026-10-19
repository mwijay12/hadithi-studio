/// Zana za kuchakata maandishi (text) ya Kiswahili.
///
/// Kwa nini faili hili lipo: Kiswahili kina sauti ambazo hufanya kazi kama
/// herufi moja lakini zimeandikwa kwa herufi mbili — `ny` (nyumba),
/// `ng'` (ng'ombe), `ch` (chakula), `sh` (shule). Kigawanyaji cha kawaida
/// (`text.split(' ')`) kinatosha kwa kuhesabu maneno, lakini injini yetu ya
/// **read-along TTS** inahitaji kuratibu *char indices* ili kuweka highlight
/// kwenye neno sahihi kwenye skrini. Hapa ndipo digraph hizi zinapothibitika.
///
/// Hatutumii `\b` ya RegExp peke yake kwa sababu `ng'` ina apostrophe —
/// `'` ni non-word character, hivyo `\b` ingegawanya `ng'ombe` vibaya.
library;

/// Neno moja ndani ya maandishi, pamoja na mahali lilipo.
///
/// `start` na `end` ni char indices (0-based, `end` haijumuishi) ambazo
/// zinalingana moja kwa moja na `charStartIndex` / `charEndIndex` za
/// `WordTiming` inayorudi kutoka API ya TTS.
class TextToken {
  const TextToken({
    required this.text,
    required this.start,
    required this.end,
    required this.isWord,
  });

  /// Maandishi halisi ya token (bila whitespace iliyomzunguka).
  final String text;

  /// Char index ya kwanza ya token kwenye maandishi ya awali.
  final int start;

  /// Char index ya mwisho (haijumuishi) kwenye maandishi ya awali.
  final int end;

  /// `true` kama token ni neno (ina herufi), `false` kama ni alama
  /// ya uakifishaji au nafasi tupu.
  final bool isWord;

  /// Urefu wa token kwa herufi.
  int get length => end - start;

  @override
  String toString() => 'TextToken("$text", $start..$end, word: $isWord)';

  @override
  bool operator ==(Object other) =>
      other is TextToken &&
      other.text == text &&
      other.start == start &&
      other.end == end &&
      other.isWord == isWord;

  @override
  int get hashCode => Object.hash(text, start, end, isWord);
}

/// Zana zote za maandishi ya Kiswahili ziko hapa chini kama static methods.
abstract final class SwahiliTextUtils {
  /// Digraph na trigraph za Kiswahili zinazotakiwa kutambuliwa.
  ///
  /// `ng'` ni ya kwanza kwa sababu ni ndefu zaidi — tukianza na `ny`
  /// tungegawanya `ng'` vibaya. Mpangilio ni muhimu.
  static const List<String> digraphs = <String>[
    "ng'",
    'ny',
    'ch',
    'sh',
    'gh',
    'dh',
    'th',
    'kw',
    'mw',
    'nd',
    'mb',
    'nj',
    'nz',
  ];

  /// Apostrophe mbili zinazotumika Kiswahili: `'` (U+0027) na `’` (U+2019).
  /// Baadhi ya keyboards za simu hutuma ya pili, hivyo tunazilinganisha.
  static const String amwaApostrophe = '\u2019';

  /// Herufi za Kiswahili ambazo ni "word characters" — hazijumuishi `'`
  /// kwa sababu `'` hutumika kama uakifishaji pia (`"Karibu!"`).
  static const String _lettersLower = 'abcdefghijklmnopqrstuvwxyz';
  static const String _lettersUpper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const String _digits = '0123456789';
  static const String _vowels = 'aeiou';

  // ---------------------------------------------------------------------------
  // Kugawanya maandishi (tokenizing)
  // ---------------------------------------------------------------------------

  /// Kugawanya maandishi kuwa tokens, kila moja ikijua mahali ilipo.
  ///
  /// Whitespace inaachwa nje ya tokens lakini indices zinabaki sahihi,
  /// hivyo `text.substring(token.start, token.end) == token.text` daima.
  ///
  /// Mfano:
  /// ```dart
  /// final tokens = SwahiliTextUtils.tokenize('Ng\'ombe anakula nyasi, Juma!');
  /// // → ['Ng\'ombe', 'anakula', 'nyasi', 'Juma'] kama word tokens
  /// ```
  static List<TextToken> tokenize(String text) {
    final tokens = <TextToken>[];
    if (text.isEmpty) return tokens;

    var index = 0;
    while (index < text.length) {
      final char = text[index];

      if (_isWhitespace(char)) {
        final start = index;
        while (index < text.length && _isWhitespace(text[index])) {
          index++;
        }
        tokens.add(TextToken(
          text: text.substring(start, index),
          start: start,
          end: index,
          isWord: false,
        ));
        continue;
      }

      if (_isWordChar(char)) {
        final start = index;
        index++;
        while (index < text.length && _isWordChar(text[index])) {
          // Ruhusu apostrophe KATIKATI ya neno (ng'ombe) lakini si mwishoni.
          if (_isApostrophe(text[index]) && index + 1 < text.length && _isWordChar(text[index + 1])) {
            index++;
            continue;
          }
          index++;
        }
        tokens.add(TextToken(
          text: text.substring(start, index),
          start: start,
          end: index,
          isWord: true,
        ));
        continue;
      }

      // Uakifishaji: kundi la alama mfululizo (mfano "...", "?!")
      final start = index;
      while (index < text.length && !_isWhitespace(text[index]) && !_isWordChar(text[index])) {
        index++;
      }
      // Apostrophe peke yake si token ya uakifishaji — irukwe kama herufi ya neno.
      tokens.add(TextToken(
        text: text.substring(start, index),
        start: start,
        end: index,
        isWord: false,
      ));
    }
    return tokens;
  }

  /// Maneno pekee (bila uakifishaji na nafasi tupu), kwa mpangilio.
  ///
  /// Hii ni orodha ile ile ambayo injini ya TTS inatarajia kupokea kutoka
  /// `WordTiming`, hivyo ni sehemu muhimu ya kulinganisha highlight.
  static List<TextToken> wordTokens(String text) =>
      tokenize(text).where((t) => t.isWord).toList(growable: false);

  /// Maneno kama `List<String>` — rahisi kwa kuhesabu au kulinganisha.
  static List<String> words(String text) =>
      wordTokens(text).map((t) => t.text).toList(growable: false);

  /// Idadi ya maneno kwenye maandishi.
  static int wordCount(String text) => wordTokens(text).length;

  // ---------------------------------------------------------------------------
  // Digraph / sauti
  // ---------------------------------------------------------------------------

  /// Digraph inayoanza kwenye `index` (kama ipo), kwa herufi ndogo.
  ///
  /// Inatumika kwa makadirio ya silabi na kwa kubainisha nafasi sahihi za
  /// kusimamisha neno kwa kuweka hyphen (mfano `nya-nya`).
  ///
  /// Rudisha `null` kama hakuna digraph inayoanza hapo.
  static String? digraphAt(String text, int index) {
    if (index < 0 || index >= text.length) return null;
    final lower = text.toLowerCase();
    for (final digraph in digraphs) {
      if (lower.startsWith(digraph, index)) return digraph;
    }
    return null;
  }

  /// Makadirio ya idadi ya silabi kwenye neno.
  ///
  /// Kiswahili ni lugha ya silabi-wazi: karibu kila silabi inaishia kwa
  /// vowel. Hivyo kuhesabu vowels (huku tukiruka vowels zinazofuatana)
  /// kunatoa makadirio mazuri ya haraka bila kamusi.
  static int countSyllables(String word) {
    if (word.isEmpty) return 0;
    var count = 0;
    var index = 0;
    final lower = word.toLowerCase();
    while (index < lower.length) {
      final char = lower[index];
      if (_vowels.contains(char)) {
        count++;
        index++;
        // Ruka vowels zinazofuatana ("Kila" ina silabi 2: Ki-la).
        while (index < lower.length && _vowels.contains(lower[index])) {
          index++;
        }
        continue;
      }
      index++;
    }
    return count == 0 ? 1 : count;
  }

  // ---------------------------------------------------------------------------
  // Kusafisha na kutafuta (normalise / search)
  // ---------------------------------------------------------------------------

  /// Kusafisha maandishi kuwa umbo la kawaida: lowercase, apostrophe moja,
  /// nafasi moja kati ya maneno, na bila nafasi mwanzoni/mwishoni.
  static String normalise(String text) {
    return text
        .replaceAll(amwaApostrophe, "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .toLowerCase();
  }

  /// Umbo la kutafuta: kama [normalise], lakini digraph zinakunjwa kuwa
  /// herufi moja ili mtumiaji anayeandika `nyumba` na `numba` apate matokeo
  /// sawa — muhimu sana kwenye simu ndogo za Tanzania ambako watu hupenda
  /// kuandika kwa kifupi.
  static String foldForSearch(String text) {
    var folded = normalise(text);
    for (final digraph in digraphs) {
      folded = folded.replaceAll(digraph, digraph[0]);
    }
    // Herufi zinazorudiwa ("saaana" / "nyyumba") zikunjwe.
    //
    // TUNATUMIA `replaceAllMapped`, SI `replaceAll`: `String.replaceAll`
    // haiingizi capture groups — `r'$1'` ingeandikwa kihalisi kama herufi
    // `$` na `1`. `replaceAllMapped` hutupea `Match`, ambapo `m[1]` ndiyo
    // herufi halisi iliyorudiwa.
    folded = folded.replaceAllMapped(
      RegExp(r'(.)\1+'),
      (match) => match[1]!,
    );
    return folded;
  }

  /// Kusafisha maneno ya hoja (query) ya utafutaji.
  /// Rudisha `null` kama hoja ni tupu baada ya kusafisha.
  static String? normaliseQuery(String? query) {
    if (query == null) return null;
    final cleaned = normalise(query);
    return cleaned.isEmpty ? null : cleaned;
  }

  /// `true` kama [haystack] ina [needle], bila kuheshimu ukubwa wa herufi
  /// na digitraph. Hutumika kwa utafutaji wa ndani (local search) kwenye
  /// orodha zilizopakiwa kwenye kumbukumbu.
  static bool matches(String haystack, String needle) {
    if (needle.trim().isEmpty) return true;
    return foldForSearch(haystack).contains(foldForSearch(needle));
  }

  // ---------------------------------------------------------------------------
  // Muhtasari / muda wa kusoma
  // ---------------------------------------------------------------------------

  /// Kukata maandishi bila kuvunja neno.
  ///
  /// Hutumika kwenye `synopsis` ya hadithi kwenye kadi ndogo.
  static String truncate(String text, int maxChars, {String ellipsis = '…'}) {
    if (maxChars <= 0) return '';
    if (text.length <= maxChars) return text;
    final cut = text.substring(0, maxChars);
    final lastSpace = cut.lastIndexOf(' ');
    final base = lastSpace > maxChars * 0.6 ? cut.substring(0, lastSpace) : cut;
    return '${base.trimRight()}$ellipsis';
  }

  /// Herufi za mwanzo za jina (avatars, "Baraka M." → "BM").
  static String initials(String name, {int max = 2}) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(max)
        .toList(growable: false);
    if (parts.isEmpty) return '';
    return parts.map((p) => p[0].toUpperCase()).join();
  }

  /// Makadirio ya sekunde za kusoma kwa [wordsPerMinute] (`AppConstants.wordsPerMinute`).
  ///
  /// Kiswahili ni lugha yenye maneno marefu kwa wastani, hivyo kasi ya
  /// kusoma hupungua kwa watoto — tunatumia thamani ya msingi inayopitishwa
  /// na mwitaji badala ya kuweka namba hapa.
  static int estimateReadingSeconds(String text, int wordsPerMinute) {
    if (wordsPerMinute <= 0) return 0;
    return ((wordCount(text) / wordsPerMinute) * 60).round();
  }

  // ---------------------------------------------------------------------------
  // Masking (usiri)
  // ---------------------------------------------------------------------------

  /// Kuficha nambari ya simu kwa kuonyesha nusu ya mwisho pekee.
  ///
  /// Sheria ya usalama (spec §11): hatuandiki nambari kamili kwenye logs au
  /// kwenye skrini za umma.
  static String maskPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) return '****';
    return '****${digits.substring(digits.length - 4)}';
  }

  /// Kuficha barua pepe: `neema@example.com` → `n••••@example.com`.
  static String maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) return '•••';
    return '${email[0]}••••${email.substring(at)}';
  }

  // ---------------------------------------------------------------------------
  // Helpers za ndani
  // ---------------------------------------------------------------------------

  static bool _isWhitespace(String char) =>
      char == ' ' || char == '\n' || char == '\r' || char == '\t' || char == '\u00A0';

  static bool _isApostrophe(String char) => char == "'" || char == amwaApostrophe;

  static bool _isWordChar(String char) {
    if (_lettersLower.contains(char) ||
        _lettersUpper.contains(char) ||
        _digits.contains(char)) {
      return true;
    }
    final code = char.codeUnitAt(0);
    if (code <= 0x7F) return false;
    // Sehemu za surrogate (emoji halisi) hazijumuishwi — zinatengwa kama
    // uakifishaji badala ya kuunganishwa na neno.
    if (code >= 0xD800 && code <= 0xDFFF) return false;
    // Alama za uakifishaji wa jumla, mishale, na alama mbalimbali.
    if (code >= 0x2000 && code <= 0x2BFF) return false;
    // Emoji na pictographs.
    if (code >= 0xFE00 && code <= 0xFE0F) return false; // variation selectors
    // Herufi za Kiswahili zenye diacritics (mara chache) pamoja na herufi
    // za majina ya kigeni ("Ng'oma", "Shayo") zinabaki kuwa word chars.
    return true;
  }
}
