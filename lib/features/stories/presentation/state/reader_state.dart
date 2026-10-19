/// Hali ya **STORY READER** — ukurasa, sauti, mwanga wa neno na mapendeleo.
///
/// Hii ni hali yenye shughuli nyingi zaidi kwenye app, kwa sababu reader ni
/// kivuko kimoja cha vitu vinne vinavyoendeshwa kwa wakati mmoja:
///
/// 1. **Kusogeza kurasa** (`pageIndex`) — kwa mkono au kiotomatiki.
/// 2. **Kusoma kwa sauti** (`isSpeaking`, `isPaused`) — TTS.
/// 3. **Mwanga wa neno** (`highlightStart`/`highlightEnd`) — huonyesha neno
///    linalosomwa sasa. Haya ni **char index**, si index ya neno: ndivyo
///    `AppKaraokeText` inavyopokea (tazama `swahili_text_widget.dart`).
/// 4. **Mapendeleo** (`textScale`, `speechRate`, `voice`, `autoPageTurn`).
///
/// ## Kwa nini `highlightStart`/`highlightEnd` ni `int?`
///
/// `null` zote mbili = hakuna mwanga. Hilo hutokea mara mbili: wakati TTS
/// haisomi, na wakati mtumiaji amezima "Soma kwa Sauti" na kusoma kwa macho.
/// `AppKaraokeText` huthibitisha kuwa zote mbili zinatolewa pamoja, kwa hivyo
/// hali hii haiwezi kuweka moja pekee — ndiyo maana tunazibadilisha pamoja
/// kwenye [copyWith] kupitia [clearHighlight].
///
/// ## Mapendeleo HAYAHIFADHIWI hapa
///
/// Hali hii ni ya kikao (session). Kuhifadhi `textScale`/`voice` kwa kudumu
/// ni kazi ya `LocalStorage`, si ya `BlocState` — kuchanganya hizi mbili
/// kungefanya kila `emit` kuandika disk.
library;

import 'package:equatable/equatable.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/audio_utils.dart' show AppAudioUtils;
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';

/// Hatua ya mzigo wa reader.
enum ReaderStatus { initial, loading, success, failure }

/// Jinsi mtoto anavyotumia ukurasa huu.
///
/// Tofauti ni **kinachotokea ukurasa unapofunguka**, si tu lebo:
///
/// * [readAndListen] — maandishi yanaonekana, na sauti inaanza kwa mguso.
/// * [listenOnly] — sauti inaanza **yenyewe**; mtoto analala akisikiliza.
/// * [readOnly] — kitufe cha kucheza kinazimwa; hii ni kusoma kwa macho.
///
/// Lebo zinatoka ARB (`readAndListen`, `listenOnly`, `readOnly`) — hii ni
/// orodha tupu kwa makusudi, tofauti na `HotspotType` inayobeba `labelSw`
/// na `labelEn` ndani yake. Sababu: `HotspotType` ni **maudhui** ya hadithi,
/// wakati hali ya kusoma ni **mapendeleo ya UI** — kanuni ya 4 inataka
/// mapendeleo ya UI yote yapite ARB.
enum ReadingMode { readAndListen, listenOnly, readOnly }

/// Sauti za kusoma — hutafsiriwa kuwa kasi na sauti ya TTS.
///
/// Majina (`Mama`, `Baba`, `Mtoto`) hutoka ARB (`voiceMama`, `voiceBaba`,
/// `voiceMtoto`) — hayajaandikwa hapa, sawa na `StoryShelf`. Kwa Kiswahili
/// "Mama"/"Baba" ni sawa katika lugha zote mbili, lakini "Mtoto"/"Child"
/// hutofautiana, hivyo kanuni ya 4 inahitaji ARB hata hapa.
///
/// Thamani za [rate] na [pitch] ni za **mwanadamu**: sauti ya mtoto ni ya
/// juu na ya haraka zaidi; ya baba ni nzito na ya polepole. Hizi ni sehemu ya
/// sauti, si tafsiri — kwa hivyo ziko hapa, si ARB.
enum ReaderVoice {
  /// Sauti ya joto ya kati — chaguo la msingi.
  mama(rate: 0.45, pitch: 1.05),

  /// Sauti nzito, ya polepole kidogo — nzuri kwa ngano za jioni.
  baba(rate: 0.42, pitch: 0.85),

  /// Sauti nyepesi na ya haraka — huwarudisha watoto wadogo.
  mtoto(rate: 0.50, pitch: 1.35);

  const ReaderVoice({required this.rate, required this.pitch});

  /// Kasi ya msingi ya TTS kwa sauti hii (`flutter_tts` `setSpeechRate`).
  ///
  /// Kumbuka: kiwango cha `flutter_tts` hutofautiana kwa jukwaa (Android
  /// huchukua ~0.0–1.0, web ~0.1–10). Thamani hizi ziko kwenye upande wa
  /// Android kwa kuwa ndio jukwaa la msingi la app; `SpeechService`
  /// huzipanga kwa jukwaa.
  final double rate;

  /// Kiwango cha sauti (`setPitch`).
  final double pitch;
}

/// Hali ya STORY READER.
class ReaderState extends Equatable {
  const ReaderState({
    this.status = ReaderStatus.initial,
    this.story,
    this.pageIndex = 0,
    this.highlightStart,
    this.highlightEnd,
    this.isSpeaking = false,
    this.isPaused = false,
    this.speechAvailable = true,
    this.textScale = defaultTextScale,
    this.rateMultiplier = defaultRateMultiplier,
    this.voice = ReaderVoice.mama,
    this.autoPageTurn = false,
    this.isNightMode = false,
    this.readingMode = ReadingMode.readAndListen,
    this.autoTurnDelay = defaultAutoTurnDelay,
    this.bookmarkedPages = const <int>{},
    this.failure,
  });

  /// Ukubwa wa maandishi — wastani.
  ///
  /// Kikomo cha chini ni 0.85 (si chini ya saizi ya kawaida: kusoma kwa
  /// mtoto huanza pale) na cha juu 1.60 (zaidi ya hapo aya moja haitoshi
  /// ukurasa, na kusogeza kunakuwa kazi).
  static const double minTextScale = 0.85;

  /// Kiwango cha juu cha ukubwa wa maandishi.
  static const double maxTextScale = 1.60;

  /// Ukubwa wa kawaida wa maandishi.
  static const double defaultTextScale = 1.0;

  /// Kiwango cha chini cha kasi ya sauti.
  static const double minRateMultiplier = 0.70;

  /// Kiwango cha juu cha kasi ya sauti.
  static const double maxRateMultiplier = 1.30;

  /// Kasi ya kawaida ya sauti.
  ///
  /// Si `1.0` kwa bahati: `flutter_tts` huanza kwa kasi ya kawaida ya jukwaa,
  /// ambayo kwa Kiswahili ni ya haraka mno kwa watoto. Tunaanza polepole
  /// kidogo ili mzazi asilazimike kupunguza mara ya kwanza.
  static const double defaultRateMultiplier = 0.90;

  /// Sekunde zinazoruhusiwa kati ya kurasa wakati wa kugeuza kiotomatiki.
  ///
  /// Hutoka [AppConstants] ili orodha isiwe mahali mawili: paneli ya
  /// mipangilio huchora kitufe kimoja kwa kila thamani, na `ReaderCubit`
  /// hupanga `Timer` kwa thamani iliyochaguliwa.
  static const List<int> autoTurnDelayOptions = AppConstants.autoPageTurnDelays;

  /// Sekunde za msingi kati ya kurasa (`2`).
  static const int defaultAutoTurnDelay = AppConstants.defaultAutoPageTurnDelay;

  /// Ukubwa wa chini wa maandishi ya hadithi kwa **sp** (`16`).
  ///
  /// Tofauti na [minTextScale] (kizidishi), hii ni saizi halisi ya herufi —
  /// ndiyo inayoonekana kwenye slider ya mipangilio. [textScale] ni njia ya
  /// ndani; mtumiaji huzungumza kwa sp.
  static const double minStoryFontSize = AppConstants.minStoryFontSize;

  /// Ukubwa wa juu wa maandishi ya hadithi kwa **sp** (`28`).
  static const double maxStoryFontSize = AppConstants.maxStoryFontSize;

  /// Ukubwa wa kawaida wa maandishi ya hadithi kwa **sp** (`18`).
  static const double defaultStoryFontSize = AppConstants.defaultStoryFontSize;

  /// Sekunde za chini kabisa zinazoruhusiwa (`1`).
  static int get minAutoTurnDelay => AppConstants.autoPageTurnDelays.first;

  /// Sekunde za juu kabisa zinazoruhusiwa (`5`).
  static int get maxAutoTurnDelay => AppConstants.autoPageTurnDelays.last;

  /// Hatua ya sasa.
  final ReaderStatus status;

  /// Hadithi inayosomwa.
  final Story? story;

  /// Ukurasa unaoonyeshwa sasa (0-based).
  final int pageIndex;

  /// Char index ya mwanzo ya neno linalosomwa (`null` = hakuna mwanga).
  final int? highlightStart;

  /// Char index ya mwisho (haijumuishi) ya neno linalosomwa.
  final int? highlightEnd;

  /// `true` = TTS inasoma sasa.
  final bool isSpeaking;

  /// `true` = TTS imesimamishwa kwa muda (inaweza kuendelezwa).
  final bool isPaused;

  /// `true` = kifaa hiki kina injini ya sauti inayofanya kazi.
  ///
  /// Kwenye simu nyingi za bei nafuu (na kwenye vivinjari vingi vya kompyuta)
  /// injini ya Kiswahili haipo, na `flutter_tts` hushindwa kusoma. Hali hii
  /// huruhusu UI kusema ukweli: mwanga wa neno (karaoke) unaendelea, lakini
  /// **hakuna sauti** — badala ya kuonyesha "inaSoma" wakati wa ukimya.
  ///
  /// Hii ni tofauti na [isSpeaking]: [isSpeaking] ni "mtumiaji ameanza
  /// kusoma", [speechAvailable] ni "kifaa kinaweza kutoa sauti".
  final bool speechAvailable;

  /// Kizidishi cha ukubwa wa maandishi.
  final double textScale;

  /// Kizidishi cha kasi ya sauti.
  final double rateMultiplier;

  /// Sauti iliyochaguliwa.
  final ReaderVoice voice;

  /// `true` = geuza ukurasa wenyewe TTS inapomaliza ukurasa.
  final bool autoPageTurn;

  /// `true` = hali ya usiku (mandhari nyeusi) imewashwa.
  ///
  /// Hii ni mapendeleo ya **muonekano**, si ya maudhui: inabadilisha rangi ya
  /// mandhari nyuma ya maandishi na rangi ya maandishi yenyewe. Kwa hivyo
  /// haihifadhiwi hapa kwa kudumu — `LocalStorage` ndiyo inayoshughulikia
  /// kuhifadhi mapendeleo (tazama kichwa cha faili hili).
  final bool isNightMode;

  /// Jinsi mtoto anavyotumia ukurasa huu ([ReadingMode]).
  ///
  /// Unatawala **kinachotokea ukurasa unapofunguka**: [readAndListen]
  /// huacha maandishi yote mawili na kuanza sauti kwa mguso, [listenOnly]
  /// huanza sauti yenyewe, na [readOnly] huzima kitufe cha kucheza kabisa.
  final ReadingMode readingMode;

  /// Sekunde kati ya kurasa wakati wa `autoPageTurn` (`1`, `2`, `3` au `5`).
  ///
  /// Hii ni thamani **ya mtumiaji** — chanzo cha ukweli kwa chaguo halali ni
  /// [autoTurnDelayOptions]; tumia [autoTurnDuration] kupata `Duration`
  /// iliyokwisha kubanwa, usiunde `Duration(seconds: ...)` moja kwa moja.
  final int autoTurnDelay;

  /// Kurasa zenye alama (0-based indices).
  final Set<int> bookmarkedPages;

  /// Kosa lililotokea.
  final Failure? failure;

  /// Ukurasa unaoonyeshwa sasa, kama kitu.
  StoryPage? get currentPage {
    final Story? story = this.story;
    if (story == null || pageIndex >= story.pages.length) return null;
    return story.pages[pageIndex];
  }

  /// Idadi ya kurasa.
  int get totalPages => story?.pages.length ?? 0;

  /// `true` = mzigo unaendelea.
  bool get isLoading => status == ReaderStatus.loading;

  /// `true` = kosa la kweli.
  bool get hasFailure => status == ReaderStatus.failure;

  /// `true` = reader iko tayari kuonyeshwa.
  bool get isReady => status == ReaderStatus.success && currentPage != null;

  /// `true` = ukurasa wa kwanza.
  bool get isFirstPage => pageIndex <= 0;

  /// `true` = ukurasa wa mwisho.
  bool get isLastPage => pageIndex >= totalPages - 1;

  /// Maendeleo ya kusoma, `0.0`–`1.0`.
  ///
  /// Kwa hadithi ya ukurasa mmoja hurudisha `1.0`, si `0.0` —
  /// `pageIndex / (total - 1)` ingegawanya kwa sifuri.
  double get progress {
    if (totalPages <= 1) return totalPages == 0 ? 0.0 : 1.0;
    return (pageIndex / (totalPages - 1)).clamp(0.0, 1.0);
  }

  /// `true` = ukurasa huu una alama.
  bool get isCurrentPageBookmarked => bookmarkedPages.contains(pageIndex);

  /// `true` = mwanga unaonyeshwa sasa.
  bool get hasHighlight => highlightStart != null && highlightEnd != null;

  /// Ukubwa wa maandishi ya hadithi kwa **sp** unaotumika sasa.
  ///
  /// Hii ni saizi halisi inayopitishwa kwa `AppTypography.storyText`. Inatokana
  /// na [textScale] (kizidishi cha ndani) kilichozidishwa kwa
  /// [defaultStoryFontSize], kisha kubanwa kati ya [minStoryFontSize] na
  /// [maxStoryFontSize].
  ///
  /// **Kwa nini kizidishi na si sp moja kwa moja?** `increaseTextScale` na
  /// `decreaseTextScale` zilikuwepo kabla ya Prompt 4 na zina hatua ya 10%
  /// (`_textScaleStep`). Kubadilisha hali iwe sp moja kwa moja kungeharibu
  /// wito wote uliopo. Kwa hivyo: UI huzungumza **sp** (slider 16–28), hali
  /// huhifadhi **kizidishi**, na hapa ndipo tafsiri ipo — mahali pamoja.
  double get storyFontSize =>
      (defaultStoryFontSize * textScale).clamp(minStoryFontSize, maxStoryFontSize);

  /// Hubadilisha saizi ya herufi (sp) kuwa kizidishi cha hali.
  ///
  /// Slider ya mipangilio hutoa `16`–`28`; hali inahitaji kizidishi. Tafsiri
  /// hii ipo hapa ili UI isijue kuhusu uhusiano kati ya hizo mbili — ikibadilika
  /// siku moja, mahali pamoja pabaya zaidi.
  static double textScaleForFontSize(double fontSize) =>
      fontSize / defaultStoryFontSize;

  /// Muda kati ya kurasa kama `Duration`, uliokwisha kubanwa kwenye chaguo
  /// halali (`1`, `2`, `3`, `5`).
  ///
  /// Tunabanwa hapa badala ya kwenye `copyWith` ili hali isiweze kamwe
  /// kubeba muda ambao injini haitambui — hata kama thamani ilikuja kutoka
  /// kwenye storage ya zamani.
  Duration get autoTurnDuration => AppAudioUtils.autoPageTurnDuration(autoTurnDelay);

  /// `true` = maandishi yanaonekana ([ReadingMode.readAndListen] au
  /// [ReadingMode.readOnly]).
  ///
  /// [ReadingMode.listenOnly] huficha safu ya maandishi ili mtoto aliyelala
  /// asiwe na maneno yanayomwanga — picha pekee inabaki.
  bool get showsStoryText => readingMode != ReadingMode.listenOnly;

  /// `true` = kitufe cha kucheza kinaruhusiwa ([ReadingMode.readAndListen] au
  /// [ReadingMode.listenOnly]).
  bool get allowsAudio => readingMode != ReadingMode.readOnly;

  /// Kubana sekunde kwenye chaguo linaloruhusiwa.
  ///
  /// `4` haipitishwi kama ilivyo — inarudi `3`. Kanuni hii ipo hapa (si kwenye
  /// UI) kwa sababu hali ndiyo inayohifadhi thamani, na thamani isiyo halali
  /// ikifika kwenye `Timer` ingetoa tabia isiyotabirika.
  ///
  /// Mantiki yenyewe iko [AppAudioUtils.clampAutoPageTurnSeconds] — hatuirudii
  /// hapa, ili orodha ya chaguo isiwe na nafasi mbili za kukua tofauti.
  static int clampAutoTurnDelay(int seconds) =>
      AppAudioUtils.clampAutoPageTurnSeconds(seconds);

  /// Nakala mpya yenye mabadiliko.
  ///
  /// `clearHighlight` ipo kwa sababu `highlightStart: null` haiwezi
  /// kutofautishwa na "acha kama ilivyo": bila alama hii, kusimamisha TTS
  /// kungeacha neno la mwisho likiwa limeangaziwa milele.
  ReaderState copyWith({
    ReaderStatus? status,
    Story? story,
    int? pageIndex,
    int? highlightStart,
    int? highlightEnd,
    bool clearHighlight = false,
    bool? isSpeaking,
    bool? isPaused,
    bool? speechAvailable,
    double? textScale,
    double? rateMultiplier,
    ReaderVoice? voice,
    bool? autoPageTurn,
    bool? isNightMode,
    ReadingMode? readingMode,
    int? autoTurnDelay,
    Set<int>? bookmarkedPages,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return ReaderState(
      status: status ?? this.status,
      story: story ?? this.story,
      pageIndex: pageIndex ?? this.pageIndex,
      highlightStart: clearHighlight ? null : (highlightStart ?? this.highlightStart),
      highlightEnd: clearHighlight ? null : (highlightEnd ?? this.highlightEnd),
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isPaused: isPaused ?? this.isPaused,
      speechAvailable: speechAvailable ?? this.speechAvailable,
      textScale: textScale ?? this.textScale,
      rateMultiplier: rateMultiplier ?? this.rateMultiplier,
      voice: voice ?? this.voice,
      autoPageTurn: autoPageTurn ?? this.autoPageTurn,
      isNightMode: isNightMode ?? this.isNightMode,
      readingMode: readingMode ?? this.readingMode,
      autoTurnDelay: autoTurnDelay == null
          ? this.autoTurnDelay
          : clampAutoTurnDelay(autoTurnDelay),
      bookmarkedPages: bookmarkedPages ?? this.bookmarkedPages,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[
        status,
        story,
        pageIndex,
        highlightStart,
        highlightEnd,
        isSpeaking,
        isPaused,
        speechAvailable,
        textScale,
        rateMultiplier,
        voice,
        autoPageTurn,
        isNightMode,
        readingMode,
        autoTurnDelay,
        bookmarkedPages,
        failure,
      ];
}
