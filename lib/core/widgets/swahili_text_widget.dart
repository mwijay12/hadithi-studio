import 'package:flutter/gestures.dart' show TapGestureRecognizer;
import 'package:flutter/material.dart';

import '../../config/theme/colors.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/typography.dart';
import '../extensions/context_extensions.dart';
import '../utils/text_utils.dart';

/// Maandishi ya hadithi yenye highlight ya neno linalosomwa (karaoke effect).
///
/// ## Kwa nini widget hii ipo
///
/// Read-along (kanuni #15: "Test TTS word highlighting thoroughly") inahitaji
/// neno linalosomwa **sasa** lionekane tofauti. Kuna njia mbili za kufanya
/// hilo, na zinatofautiana sana kwa utendaji:
///
/// 1. **Kuunda `TextSpan` moja kwa neno** (njia hii) — gharama ni kimoja tu
///    kwa kila neno linalobadilika.
/// 2. **Kutumia `TextPainter` na kupaka rangi kwenye mistari** — inahitaji
///    `TextPainter` mwenyewe, hivyo tunapoteza `Text` ya Flutter (accessibility,
///    text scaling, selection) na tunapata msimbo wa chini sana.
///
/// Njia ya 1 inashinda kwa sababu **highlight hubadilika kwa kasi ya maneno,
/// si kwa kasi ya frames**: TTS ya Google hutuma `WordTiming` kwa kila neno
/// (maneno 2–3 kwa sekunde), wala si kwa kila frame (60 kwa sekunde). Hivyo
/// kujenga spans upya mara 2–3 kwa sekunde kwenye Tecno ya 2GB RAM ni bei
/// ndogo sana — lakini ni bei **kubwa** kama tutaijenga kila frame.
///
/// ## Kuzuia kujenga spans kila frame
///
/// `PageView` (au `AnimatedBuilder` ya `AppPageTurn`) hujenga upya watoto wake
/// kila frame wakati wa kugeuza ukurasa. Kama tungejenga spans kwenye `build`
/// bila kuhifadhi, tungejenga mara 60 kwa sekunde wakati wa kugeuza — kwa
/// ukurasa mzima wa maneno 200 hiyo ni kazi isiyo na maana.
///
/// Kwa hiyo: tokens **huhifadhiwa** kwa urefu wa maisha ya widget, na spans
/// **huhifadhiwa** kwa `_spansCache` inayotumika tena wakati maandishi,
/// style na highlight hazijabadilika.
///
/// ## Kuratibu za char, si index za maneno
///
/// Tunapokea `highlightStart`/`highlightEnd` kama **char indices** (zile zile
/// za `WordTiming.charStartIndex` / `charEndIndex`) badala ya index ya neno,
/// kwa sababu injini ya TTS haigawanyi maneno kama sisi: inaweza kujumuisha
/// alama ya uakifishaji (`"nyasi,"`) au kugawanya kwa namna yetu isiyotabirika.
/// Kulinganisha kwa **kuingiliana** (overlap) kunavumilia hilo.
///
/// ## Matumizi
///
/// ```dart
/// AppKaraokeText(
///   text: page.textSw,
///   highlightStart: timing?.charStartIndex,
///   highlightEnd: timing?.charEndIndex,
/// )
/// ```
///
/// Ukiacha `highlightStart` na `highlightEnd` kuwa `null`, widget hii hutoa
/// maandishi ya hadithi ya kawaida — hivyo skrini moja inaweza kutumika kwa
/// kusoma **na** kusikiliza bila kubadilisha widget.
class AppKaraokeText extends StatefulWidget {
  const AppKaraokeText({
    super.key,
    required this.text,
    this.highlightStart,
    this.highlightEnd,
    this.highlightColor = AppColors.wordHighlight,
    this.onHighlightColor = AppColors.darkText,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.useStoryFont = true,
    this.compact = false,
    this.semanticsLabel,
    this.onWordTap,
    this.emphasisScale = 1.1,
    this.emphasisWeight = FontWeight.w700,
  })  : assert(
          (highlightStart == null) == (highlightEnd == null),
          'highlightStart na highlightEnd hutolewa wote wawili au wote '
          'hawatolewi — kuratibu moja pekee haina maana.',
        );

  /// Maandishi kamili ya ukurasa (au aya) — Kiswahili au Kiingereza.
  final String text;

  /// Char index ya kwanza ya neno linalosomwa sasa (`WordTiming.charStartIndex`).
  ///
  /// `null` = hakuna highlight (maandishi ya kawaida ya kusoma).
  final int? highlightStart;

  /// Char index ya mwisho (haijumuishi) ya neno linalosomwa sasa.
  final int? highlightEnd;

  /// Rangi ya mandhari ya neno linalosomwa.
  ///
  /// Default ni [AppColors.wordHighlight] (amber ya dhahabu ya Zanzibar) —
  /// rangi ya **brand**, si ya `colorScheme`, kwa hiyo haibadiliki kwa
  /// mandhari ya usiku. Tazama [onHighlightColor].
  final Color highlightColor;

  /// Rangi ya maandishi **ndani** ya highlight.
  ///
  /// Hii ni `AppColors.darkText` kwa makusudi: mandhari ya highlight ni amber
  /// nyepesi **kwenye mandhari zote mbili**, hivyo maandishi yake lazima yawe
  /// meusi kila wakati. Kutumia `colorScheme.onSurface` ingefanya maandishi
  /// meupe juu ya amber nyepesi kwenye dark mode — hayasomeki.
  final Color onHighlightColor;

  /// Style ya maandishi. Acha `null` kupata font ya hadithi (Merriweather).
  final TextStyle? style;

  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  /// `true` (default) = tumia font ya hadithi; `false` = font ya UI (Nunito).
  final bool useStoryFont;

  /// `true` kwa skrini ndogo sana — hupunguza ukubwa wa maandishi.
  final bool compact;

  /// Lebo ya screen reader. Kama haipo, maandishi yenyewe yanasomwa.
  final String? semanticsLabel;

  /// Hutolewa neno lililoguswa (`null` = maneno hayagusiwi).
  ///
  /// Hutumika kwa "gusa neno ulisikie": kila neno hupata kichambuzi chake cha
  /// mguso, na kubonyeza kunaita mtumiaji wa widget hii — widget hii
  /// **haisemi** wenyewe, kwa sababu kusoma ni kazi ya `ReaderCubit`.
  final ValueChanged<TextToken>? onWordTap;

  /// Kizidishi cha saizi ya neno linalosomwa sasa (spec: `1.1`).
  ///
  /// Neno lenye mwanga hukua kidogo ili jicho la mtoto lilibaini bila kutegemea
  /// rangi pekee — muhimu kwa watoto wenye udhaifu wa kuona rangi.
  final double emphasisScale;

  /// Uzito wa neno linalosomwa sasa (spec: `w700`).
  final FontWeight emphasisWeight;

  @override
  State<AppKaraokeText> createState() => _AppKaraokeTextState();
}

class _AppKaraokeTextState extends State<AppKaraokeText> {
  /// Tokens zilizogawanywa — huhifadhiwa kwa maisha ya widget.
  ///
  /// Kugawanya maandishi ya maneno 200 kila rebuild ni kazi isiyo ya lazima;
  /// maandishi ya ukurasa hayabadiliki wakati wa kugeuza ukurasa.
  List<TextToken>? _tokens;

  /// Ufunguo wa cache ya spans — huhesabiwa kutoka kila kitu kinachobadilisha
  /// muonekano. Ni `Object.hash` moja, nafuu kuliko kujenga spans.
  int? _spansCacheKey;
  List<InlineSpan>? _spansCache;

  /// Kichambuzi cha mguso kimoja kwa kila token (`onWordTap` pekee).
  ///
  /// `TextSpan.recognizer` **haimiliki** kichambuzi: yeye huiacha hai na
  /// kuitumia. Kwa hivyo ni jukumu letu kuzifunga, na ni jukumu letu
  /// kuziweka hai wakati span zinatumika. Ndiyo maana hazizalishwi kwenye
  /// `build` — zile zilizotengenezwa mwisho ndizo zinazotumika hadi
  /// maandishi au callback ibadilike.
  final List<TapGestureRecognizer> _wordRecognizers =
      <TapGestureRecognizer>[];

  /// Tokens ambazo [_wordRecognizers] zinafungwa.
  List<TextToken>? _recognizerTokens;

  /// Callback ambayo [_wordRecognizers] zinaihimiza.
  ValueChanged<TextToken>? _recognizerCallback;

  @override
  void didUpdateWidget(covariant AppKaraokeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Tokens ni halali kwa maandishi yale yale pekee.
    if (oldWidget.text != widget.text) {
      _tokens = null;
      _spansCache = null;
      _spansCacheKey = null;
      // Token mpya = vitambuzi vipya; vya zamani vinahusu maneno yasiyopo.
      _disposeWordRecognizers();
    }
  }

  @override
  void dispose() {
    _disposeWordRecognizers();
    super.dispose();
  }

  /// Hufunga vitambuzi vya mguso na kusahau tokens zao.
  void _disposeWordRecognizers() {
    for (final TapGestureRecognizer recognizer in _wordRecognizers) {
      recognizer.dispose();
    }
    _wordRecognizers.clear();
    _recognizerTokens = null;
    _recognizerCallback = null;
  }

  /// Hurudisha kichambuzi kwa kila token (index kwa index), au `null`.
  ///
  /// Orodha inafuata mpangilio wa `tokens` ili `_spansFor` aitumie kwa index.
  /// Tokens za nafasi tupu hazipati kichambuzi kinachotumika, lakini nafasi
  /// yao huhifadhiwa ili index isisogee.
  List<TapGestureRecognizer>? _recognizersFor(List<TextToken> tokens) {
    final ValueChanged<TextToken>? callback = widget.onWordTap;
    if (callback == null) {
      if (_wordRecognizers.isNotEmpty) _disposeWordRecognizers();
      return null;
    }

    final List<TextToken>? bound = _recognizerTokens;
    if (identical(callback, _recognizerCallback) &&
        bound != null &&
        bound.length == tokens.length) {
      return _wordRecognizers;
    }

    _disposeWordRecognizers();
    for (final TextToken token in tokens) {
      _wordRecognizers.add(
        TapGestureRecognizer()
          // Neno hupitishwa kwa thamani: `token` ni ya mara hii ya kuzalisha
          // vitambuzi, na `TextToken` haina marejeleo yanayobadilika.
          ..onTap = () => callback(token),
      );
    }
    _recognizerTokens = tokens;
    _recognizerCallback = callback;
    return _wordRecognizers;
  }

  List<TextToken> _tokensFor() {
    final List<TextToken>? cached = _tokens;
    if (cached != null) return cached;
    final List<TextToken> fresh = SwahiliTextUtils.tokenize(widget.text);
    _tokens = fresh;
    return fresh;
  }

  /// `true` kama token inaingiliana na eneo la highlight.
  ///
  /// Kuingiliana (si usawa) ni makusudi: injini ya TTS mara nyingi
  /// hujumuisha alama ya uakifishaji kwenye neno (`"nyasi,"`), hivyo
  /// `charEndIndex` yake inaweza kuwa kubwa kuliko `token.end` yetu.
  bool _isHighlighted(TextToken token) {
    final int? start = widget.highlightStart;
    final int? end = widget.highlightEnd;
    if (start == null || end == null) return false;
    if (end <= start) return false;
    // Tokens za nafasi tupu hazipati highlight — nafasi iliyopakwa rangi
    // inaonekana kama bloku tupu katikati ya maneno mawili.
    if (!token.isWord) return false;
    return token.start < end && token.end > start;
  }

  List<InlineSpan> _spansFor(TextStyle base) {
    final List<TextToken> tokens = _tokensFor();

    // Vitambuzi huhuishwa **kabla** ya kuangalia cache: callback inaweza
    // kubadilika wakati maandishi hayajabadilika (mtumiaji anarudi kwenye
    // ukurasa), na hapo span zilizohifadhiwa zingebaki na kichambuzi cha
    // zamani.
    final List<TapGestureRecognizer>? recognizers = _recognizersFor(tokens);

    final int key = Object.hash(
      widget.text,
      base,
      widget.highlightStart,
      widget.highlightEnd,
      widget.highlightColor,
      widget.onHighlightColor,
      widget.emphasisScale,
      widget.emphasisWeight,
      recognizers != null,
      tokens.length,
    );
    if (_spansCacheKey == key) {
      final List<InlineSpan>? cached = _spansCache;
      if (cached != null) return cached;
    }

    // Ukubwa wa neno linalosomwa huhesabiwa **mara moja** kwa ukurasa, si
    // kwa kila neno: `copyWith` moja kwa kila ukurasa ni nafuu kuliko
    // kuiita mara mia moja.
    final double emphasisFontSize =
        (base.fontSize ?? AppTypography.defaultStoryTextSize) *
            widget.emphasisScale;

    final List<InlineSpan> spans = <InlineSpan>[];
    for (int i = 0; i < tokens.length; i++) {
      final TextToken token = tokens[i];
      // Nafasi tupu haigusiwi: mguso wake hauna maana, na `onWordTap` hupokea
      // maneno pekee.
      final TapGestureRecognizer? recognizer =
          (recognizers != null && token.isWord) ? recognizers[i] : null;

      if (_isHighlighted(token)) {
        spans.add(
          TextSpan(
            text: token.text,
            recognizer: recognizer,
            style: base.copyWith(
              // `backgroundColor` hupaka rangi nyuma ya herufi pekee (bila
              // padding), ambayo ndiyo sura sahihi ya karaoke.
              backgroundColor: widget.highlightColor,
              color: widget.onHighlightColor,
              // Neno linalosomwa hukua na kuwa zito: rangi pekee haitoshi
              // kwa mtoto anayeona rangi vibaya.
              fontWeight: widget.emphasisWeight,
              fontSize: emphasisFontSize,
            ),
          ),
        );
      } else {
        // `style: null` hurithi style ya mzazi — hivyo hatunakili style
        // mara mia moja kwa ukurasa mmoja.
        spans.add(TextSpan(text: token.text, recognizer: recognizer));
      }
    }

    _spansCacheKey = key;
    _spansCache = spans;
    return spans;
  }

  TextStyle _resolveBaseStyle(BuildContext context) {
    final TextStyle? explicit = widget.style;
    if (explicit != null) return explicit;

    final double fontSize = widget.compact
        ? AppTypography.sizeBody
        : AppTypography.defaultStoryTextSize;

    if (widget.useStoryFont) {
      return AppTypography.storyText(
        fontSize: fontSize,
        color: context.colorScheme.onSurface,
      );
    }
    return (context.textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontSize: fontSize,
      color: context.colorScheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle base = _resolveBaseStyle(context);
    final Widget text = Text.rich(
      TextSpan(style: base, children: _spansFor(base)),
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );

    final String? label = widget.semanticsLabel;
    if (label == null) return text;
    // `excludeSemantics: true` ni muhimu: bila hiyo, TalkBack ingesoma lebo
    // yetu **kisha** maandishi yote tena — mara mbili.
    return Semantics(label: label, excludeSemantics: true, child: text);
  }
}

/// Neno la Kiswahili lililogawanywa kwa **silabi**, kwa kufundisha kusoma.
///
/// ## Kwa nini hii ni tofauti na [AppKaraokeText]
///
/// Karaoke inaonyesha neno linalosomwa **sasa** — inahitaji muda kutoka TTS.
/// Widget hii haihitaji muda wowote: inaonyesha **muundo** wa neno. Hii ni
/// zana ya kufundisha (mbinu ya silabi inayotumika shule za msingi Tanzania:
/// `wa-na-kwe-nda`), na haihusiani na TTS.
///
/// **Kwa nini hatufanyi highlight ya silabi kwa TTS:** Google TTS ya
/// `sw-TZ` hurudisha `TimePoint` za **neno**, si za silabi. Kufanya highlight
/// ya silabi kwa wakati ambao hatuna ungekuwa ni kudhani — na kudhani
/// kwenye kufundisha kusoma ni kosa, si uzuri.
///
/// ## Matumizi
///
/// ```dart
/// AppSyllableText(word: 'wanakwenda', highlightColor: AppColors.kangaOrange)
/// // → wa · na · kwe · nda
/// ```
class AppSyllableText extends StatelessWidget {
  const AppSyllableText({
    super.key,
    required this.word,
    this.style,
    this.separator = '·',
    this.showSeparators = true,
    this.highlightColor,
    this.textAlign = TextAlign.start,
    this.semanticsLabel,
  });

  /// Neno moja la Kiswahili (bila nafasi).
  final String word;

  /// Style ya kila silabi. Acha `null` kupata `textTheme.titleLarge`.
  final TextStyle? style;

  /// Alama kati ya silabi. Default ni `·` — kitone cha kati kinasomeka
  /// kama nafasi ndogo, wakati hyphen (`-`) inaonekana kama sehemu ya neno
  /// na inachanganya wanaoanza kusoma.
  final String separator;

  /// `false` kuonyesha silabi bila alama kati yao (kwa mazoezi ya kusoma
  /// kwa ufasaha baada ya mtoto kujua kugawanya).
  final bool showSeparators;

  /// Rangi ya mandhari ya kila silabi. `null` = hakuna mandhari (silabi tupu).
  final Color? highlightColor;

  final TextAlign textAlign;

  /// Lebo ya screen reader. Default ni neno lenyewe **kamili** — screen reader
  /// isisome `"wa na kwe nda"` kama maneno manne.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final TextStyle base = style ??
        (context.textTheme.titleLarge ?? const TextStyle()).copyWith(
          color: context.colorScheme.onSurface,
        );
    final List<String> syllables = splitSwahiliSyllables(word);
    final Color? tint = highlightColor;

    return Semantics(
      label: semanticsLabel ?? word,
      // Bila `excludeSemantics`, TalkBack ingesoma neno kamili **na** kila
      // silabi yake (`"wanakwenda, wa, na, kwe, nda"`).
      excludeSemantics: true,
      child: Wrap(
        alignment: _wrapAlignment,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: <Widget>[
          for (int i = 0; i < syllables.length; i++) ...<Widget>[
            if (i > 0 && showSeparators)
              Text(
                separator,
                style: base.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
              ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: tint == null
                  ? null
                  : BoxDecoration(
                      // `withOpacity(0.35)` badala ya rangi kamili: silabi
                      // zisizosomwa sasa zionekane, lakini mandhari
                      // isivute macho kuliko maandishi yenyewe.
                      color: tint.withValues(alpha: 0.35),
                      borderRadius: AppSpacing.borderRadiusSm,
                    ),
              child: Text(syllables[i], style: base),
            ),
          ],
        ],
      ),
    );
  }

  WrapAlignment get _wrapAlignment {
    switch (textAlign) {
      case TextAlign.center:
        return WrapAlignment.center;
      case TextAlign.end:
      case TextAlign.right:
        return WrapAlignment.end;
      case TextAlign.justify:
        return WrapAlignment.spaceBetween;
      default:
        return WrapAlignment.start;
    }
  }
}

// -----------------------------------------------------------------------------
// Kugawanya neno kwa silabi
// -----------------------------------------------------------------------------

/// Herufi ndogo zinazotumika kama vowel za Kiswahili.
const String _kSwahiliVowels = 'aeiou';

bool _isSwahiliVowel(String char) => _kSwahiliVowels.contains(char);

bool _isAsciiLetter(String char) {
  final int unit = char.codeUnitAt(0);
  return (unit >= 0x61 && unit <= 0x7A) || (unit >= 0x41 && unit <= 0x5A);
}

/// Kugawanya neno la Kiswahili kwa silabi (`'wanakwenda'` → `wa-na-kwe-nda`).
///
/// Hii ni **kanuni ya kufundisha kusoma**, si kamusi ya matamshi. Kanuni:
///
/// 1. **Silabi-wazi:** Kiswahili ni lugha ya silabi-wazi, hivyo silabi
///    hufungwa mara tu baada ya vowel (`cha-ku-la`).
/// 2. **Digraph hazigawanywi:** `ny`, `ng'`, `ch`, `sh`, `nd`, `mb` na
///    nyingine (tazama [SwahiliTextUtils.digraphs]) ni herufi **moja** kwa
///    kusoma, hivyo `nyanya` → `nya-nya`, wala si `n-ya-n-ya`.
/// 3. **Nasal ya mwanzo ni silabi yake:** `m`/`n` inapoanza neno mbele ya
///    konsonanti, huwa silabi kamili — `mtoto` → `m-to-to`, `nchi` → `n-chi`.
///    Hii haitumiki kwa digraph zenye nasal mwanzoni: `mbuzi` → `mbu-zi`
///    (si `m-bu-zi`), kwa sababu `mb` ni sauti moja.
/// 4. **Nasal ya kati ni coda:** vowel ikifuatiwa na nasal **bare** mbele ya
///    konsonanti, nasal hiyo hufunga silabi — `asante` → `a-san-te`,
///    `benki` → `ben-ki`. Hapa `n` si silabi yake, ni mwisho wa silabi.
///
/// **Upungufu unaojulikana:** mfuatano wa vowel (`buibui`, `saa`) hugawanywa
/// kama silabi tofauti kila moja (`bu-i-bu-i`, `sa-a`). Kiswahili cha
/// kawaida hakina diphthong, hivyo hii ni sahihi kwa kanuni ya silabi-wazi,
/// ingawa matamshi ya haraka yanaweza kusikika kama silabi moja. Ni makadirio
/// ya kufundisha, na hayapaswi kutumika kwa alama za matamshi.
///
/// Hutolewa kama public kwa ajili ya `@visibleForTesting`-style kupimwa moja
/// kwa moja; widget hutumia matokeo yake.
List<String> splitSwahiliSyllables(String word) {
  final String trimmed = word.trim();
  if (trimmed.isEmpty) return const <String>[];

  final String lower = trimmed.toLowerCase();
  final List<String> syllables = <String>[];
  final StringBuffer current = StringBuffer();
  int index = 0;

  // `digraphAt` hurudisha herufi ndogo, hivyo tunatumia **urefu** wake pekee
  // na kukata kutoka `trimmed` (ili herufi kubwa zibaki kama zilivyo).
  bool isBareNasalAt(int i) {
    if (i < 0 || i >= lower.length) return false;
    final String char = lower[i];
    if (char != 'm' && char != 'n') return false;
    // Kama herufi hii inaanza digraph (`mb`, `nd`, `ny`, `ng'`), basi
    // haiko peke yake — ni sehemu ya sauti moja.
    return SwahiliTextUtils.digraphAt(lower, i) == null;
  }

  bool isConsonantAt(int i) {
    if (i < 0 || i >= lower.length) return false;
    return !_isSwahiliVowel(lower[i]);
  }

  void closeSyllable() {
    if (current.isEmpty) return;
    syllables.add(current.toString());
    current.clear();
  }

  while (index < lower.length) {
    final String char = lower[index];

    // 1. Vowel — humaliza silabi.
    if (_isSwahiliVowel(char)) {
      current.write(trimmed[index]);
      index++;
      // 4. Coda ya nasal: `a-san-te`, `ben-ki`.
      if (isBareNasalAt(index) && isConsonantAt(index + 1)) {
        current.write(trimmed[index]);
        index++;
      }
      closeSyllable();
      continue;
    }

    // Alama isiyo herufi (hyphen, apostrophe ya bure) — funga na itoe kama
    // kipengele chake, ili `"mwaka-mwaka"` isionekane kama silabi moja.
    // TANBIHI: apostrophe ya `ng'` haiwezi kufika hapa kwa sababu kanuni ya
    // digraph hapa chini huichukua ikiwa sehemu ya `ng'`.
    if (!_isAsciiLetter(char)) {
      closeSyllable();
      syllables.add(trimmed[index]);
      index++;
      continue;
    }

    // 3. Nasal ya mwanzo: `m-to-to`, `n-chi`, `n-ne`.
    if (isBareNasalAt(index) && isConsonantAt(index + 1)) {
      current.write(trimmed[index]);
      closeSyllable();
      index++;
      continue;
    }

    // 2. Digraph haigawanywi; vinginevyo konsonanti moja.
    final String? digraph = SwahiliTextUtils.digraphAt(lower, index);
    final int length = digraph?.length ?? 1;
    current.write(trimmed.substring(index, index + length));
    index += length;
  }

  closeSyllable();
  return syllables;
}
