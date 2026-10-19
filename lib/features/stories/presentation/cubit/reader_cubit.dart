/// Cubit ya **STORY READER** — moyo wa app.
///
/// Hii ni cubit yenye shughuli nyingi zaidi kwenye app, kwa sababu inaendesha
/// vitu vinne kwa wakati mmoja: kusogeza kurasa, kusoma kwa sauti, mwanga wa
/// neno, na mapendeleo. Hali yenyewe iko `state/reader_state.dart` — faili
/// hili lina *tabia* pekee.
///
/// ## Mwanga wa neno hauendeshwi na TTS (uamuzi muhimu)
///
/// Kuna njia mbili za kuendesha "karaoke":
///
/// * **A** — kusikiliza matukio ya `onboundary` kutoka injini ya sauti.
/// * **B** — kuendesha kipima-muda chetu chenye urefu wa neno.
///
/// Tumetumia **B**. Sababu ni ya kiufundi, si ya kupenda:
/// `flutter_tts_web.dart` haitoi matukio ya `onboundary` kabisa, na kwenye
/// Android injini nyingine (mfano za simu za bei nafuu) hazitoi pia. Kwa
/// njia A, mwanga ungefanya kazi kwenye simu zingine pekee — na mtumiaji
/// anayeangalia kwenye kivinjari asingeona kitu. Njia B inafanya kazi
/// **kila mahali**, ikiwa na sauti au bila, na ni ya kuamua (deterministic)
/// hivyo inaweza kupimwa.
///
/// Urefu wa neno unatokana na urefu wa maandishi — "simba" huchukua muda
/// mfupi kuliko "kilimanjaro" — na kasi inafuata [ReaderState.rateMultiplier]
/// na [ReaderState.voice].
///
/// ## Kikomo kinachojulikana
///
/// Urefu wa neno ni **makadirio**, si kipimo cha injini halisi. Tukipima
/// sauti halisi ya kifaa (kwa `onboundary` kwenye Android), tunaweza
/// kurekebisha `_msPerWord`. Hadi hapo, kasi ni ya kusoma-kwa-mtoto —
/// inayotosha kufuata kwa jicho.
library;

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/reading_progress_store.dart';
import '../../data/services/story_audio_player.dart';
import '../../../../core/services/speech_service.dart';
import '../../../../core/utils/text_utils.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';
import '../../domain/repositories/story_repository.dart';
import '../stories_dependencies.dart';
import '../state/reader_state.dart';

/// Cubit ya Reader.
class ReaderCubit extends Cubit<ReaderState> {
  /// [repository], [speech] na [progressStore] zipo kwa **majaribio**.
  ///
  /// Kwenye app halisi hakuna hata moja inayopitishwa: `resolveStoryRepository()`
  /// huchagua repository, `SpeechService()` hufunga injini ya jukwaa, na
  /// `ReadingProgressStore()` hutumia `SharedPreferences` ya kifaa.
  ReaderCubit({
    StoryRepository? repository,
    SpeechService? speech,
    ReadingProgressStore? progressStore,
    StoryAudioPlayer? audioPlayer,
  })  : _repository = repository ?? resolveStoryRepository(),
        _speech = speech ?? SpeechService(),
        _progress = progressStore ?? const ReadingProgressStore(),
        _audio = audioPlayer ?? StoryAudioPlayer(),
        super(const ReaderState());

  final StoryRepository _repository;
  final SpeechService _speech;

  /// Hucheza **audio iliyorekodiwa** ya kila ukurasa.
  ///
  /// Huanguka kimya kama ukurasa hauna faili — tazama `startReadAloud`.
  final StoryAudioPlayer _audio;

  /// Huhifadhi ukurasa wa mwisho na alama za kurasa kwa kifaa.
  ///
  /// Iko kando ya hali kwa makusudi: `ReaderState` haipaswi kuandika disk
  /// kwenye kila `emit` (tazama `reader_state.dart` na
  /// `reading_progress_store.dart`).
  final ReadingProgressStore _progress;

  /// Kipima-muda cha neno linalosomwa sasa.
  Timer? _karaokeTimer;

  /// Kipima-muda cha kuchelewa kabla ya kugeuza ukurasa wenyewe.
  Timer? _autoTurnTimer;

  /// Maneno ya ukurasa wa sasa, kwa mpangilio.
  List<TextToken> _tokens = const <TextToken>[];

  /// Neno tunalosoma sasa (`_tokens` index).
  int _tokenIndex = 0;

  /// Lugha ya maandishi ya sasa.
  bool _swahili = true;

  /// Maandishi ya ukurasa wa sasa — huhifadhiwa ili kutokutafuta kila neno.
  String _pageText = '';

  /// `true` kama mtumiaji alikuwa anasoma kabla ya kugeuza ukurasa.
  bool _resumeAfterTurn = false;

  // =========================================================================
  // Kupakia
  // =========================================================================

  /// Hupakia hadithi **moja kwa moja** (tuna kitu tayari kutoka kadi).
  ///
  /// [autoPlay] ni `true` tunapoingia kwa "Sikiliza" badala ya "Soma Sasa".
  Future<void> loadStory(Story story, {bool autoPlay = false}) async {
    _resetPlayback();
    emit(state.copyWith(
      status: ReaderStatus.success,
      story: story,
      pageIndex: 0,
      clearHighlight: true,
      isSpeaking: false,
      isPaused: false,
      clearFailure: true,
    ),);
    _prepareTokens();
    // Alama za kurasa zilizohifadhiwa hurejeshwa chinichini; hazizuii
    // kuonyesha ukurasa (tazama `_restoreBookmarks`).
    unawaited(_restoreBookmarks());
    if (autoPlay) await startReadAloud();
  }

  /// Hupakia hadithi kwa [id] — hutumika kwenye kiungo kilichoshirikiwa.
  Future<void> loadById(String id, {bool autoPlay = false}) async {
    _resetPlayback();
    emit(state.copyWith(
      status: ReaderStatus.loading,
      clearHighlight: true,
      clearFailure: true,
    ),);

    final Either<Failure, Story> result = await _repository.getStoryById(id);
    if (isClosed) return;

    result.fold(
      (Failure failure) {
        emit(ReaderState(
          status: ReaderStatus.failure,
          failure: failure,
          speechAvailable: state.speechAvailable,
        ),);
      },
      (Story story) {
        emit(state.copyWith(
          status: ReaderStatus.success,
          story: story,
          pageIndex: 0,
          clearHighlight: true,
          clearFailure: true,
        ),);
        _prepareTokens();
        unawaited(_restoreBookmarks());
        if (autoPlay) startReadAloud();
      },
    );
  }

  /// Hubadilisha lugha ya maandishi.
  ///
  /// Ukurasa huita hii kila `build` (ni idempotent). Inabadilisha maneno
  /// na — kama tunasoma — kuanza upya kwenye ukurasa huu kwa lugha mpya.
  void setLanguage(bool swahili) {
    if (swahili == _swahili) return;
    _swahili = swahili;
    final bool wasSpeaking = state.isSpeaking;
    _resetPlayback();
    _prepareTokens();
    if (wasSpeaking) startReadAloud();
  }

  // =========================================================================
  // Kusogeza kurasa
  // =========================================================================

  /// Hugeuza ukurasa mmoja mbele.
  void nextPage() {
    if (state.isLastPage) return;
    _goTo(state.pageIndex + 1);
  }

  /// Hurudi ukurasa mmoja nyuma.
  void previousPage() {
    if (state.isFirstPage) return;
    _goTo(state.pageIndex - 1);
  }

  /// Huhama hadi ukurasa [index] (0-based).
  void goToPage(int index) {
    if (index < 0 || index >= state.totalPages || index == state.pageIndex) {
      return;
    }
    _goTo(index);
  }

  /// Huhamisha ukurasa kwa `PageView` — hutumika kwenye `onPageChanged`.
  ///
  /// Hii **haisimamishi kusoma**: `PageView` inaita `onPageChanged` pia wakati
  /// *sisi* tunabadilisha ukurasa, kwa hivyo kusimamisha sauti hapa
  /// kungezima "auto page turn" kila ukurasa unapogeuza.
  void onPageSettled(int index) {
    if (index == state.pageIndex) return;
    if (index < 0 || index >= state.totalPages) return;
    emit(state.copyWith(pageIndex: index, clearHighlight: true));
    _prepareTokens();
    unawaited(_persistProgress());

    // Audio iliyorekodiwa ikipiga, ibadilishe kwa ukurasa mpya badala ya
    // kuendelea na wa zamani. TTS inashughulikiwa na mstari wa chini.
    if (_audio.isPlaying && state.story != null) {
      unawaited(_audio.playPage(
        storyId: state.story!.id,
        pageIndex: index,
      ),);
    }
    if (state.autoPageTurn && state.isSpeaking) startReadAloud();
  }

  /// Huhamisha ukurasa kwa vitendo vya mtumiaji (kitufe).
  void _goTo(int index) {
    final bool wasSpeaking = state.isSpeaking;
    _stopKaraoke();
    emit(state.copyWith(
      pageIndex: index,
      clearHighlight: true,
      isPaused: false,
    ),);
    _prepareTokens();
    unawaited(_persistProgress());
    if (wasSpeaking) startReadAloud();
  }

  // =========================================================================
  // Kusoma kwa sauti
  // =========================================================================

  /// Huanza kusoma ukurasa huu kwa sauti (na mwanga wa neno).
  Future<void> startReadAloud() async {
    if (state.story == null || _pageText.trim().isEmpty) return;

    if (state.isPaused) {
      await _speech.resume();
      emit(state.copyWith(isPaused: false));
      return;
    }

    _stopAutoTurn();

    // ---------------------------------------------------------------
    // AUDIO ILIYOREKODIWA KWANZA, TTS KAMA AKIBA.
    // ---------------------------------------------------------------
    //
    // Audio hutoa sauti moja sawa kwa kila kifaa (Tecno, Samsung, iOS) na
    // haitumii data. Kama ukurasa hauna faili — hadithi mpya, au ukurasa
    // ambao haujarekodiwa — `playPage` hurudisha `false` na tunaendelea
    // kwenye TTS. Hivyo: hakuna kosa, hakuna ukurasa kimya.
    //
    // **TANBIHI:** kwa sasa mwanga wa neno HAUENDESHI wakati wa audio, kwa
    // sababu audio haitoi muda wa maneno. Kuuangazia kwa **kukisia** kungeonyesha
    // mwanga unaochelewa — mbaya kuliko kutokuwa nao. Timestamps
    // (`page_NN.json`, tazama `hasPageTimings`) ndizo zitakazowasha.
    if (await _audio.playPage(
      storyId: state.story!.id,
      pageIndex: state.pageIndex,
    )) {
      if (isClosed) return;
      _resumeAfterTurn = false;
      emit(state.copyWith(isSpeaking: true, isPaused: false));
      return;
    }

    final bool ready = await _speech.configure(
      rate: state.voice.rate * state.rateMultiplier,
      pitch: state.voice.pitch,
      preferSwahili: _swahili,
    );
    if (isClosed) return;

    _resumeAfterTurn = false;
    _tokenIndex = 0;
    emit(state.copyWith(
      isSpeaking: true,
      isPaused: false,
      speechAvailable: ready,
      clearHighlight: true,
    ),);

    if (ready) {
      // Tunaanza TTS **na** kipima-muda chetu. Kipima-muda ni chetu kwa
      // sababu matukio ya `onboundary` hayatolewi kwenye web (tazama doc
      // ya faili hili).
      await _speech.speak(
        _pageText,
        onDone: _onSpeechFinished,
        onCancel: _onSpeechCancelled,
      );
    } else {
      // Hakuna injini ya sauti: mwanga unaendelea kama "kusoma kwa macho".
      // Hatuonyeshi kosa — tunaonyesha tu hali ya ukweli kwenye UI.
      debugPrint(
        'ReaderCubit: injini ya sauti haipatikani — mwanga wa neno pekee.',
      );
    }
    _scheduleNextToken();
  }

  /// Husimamisha kusoma kabisa.
  Future<void> stopReadAloud() async {
    _resetPlayback();
    emit(state.copyWith(
      isSpeaking: false,
      isPaused: false,
      clearHighlight: true,
    ),);
    await _audio.stop();
    await _speech.stop();
  }

  /// Husimamisha au kuendeleza kusoma.
  Future<void> togglePause() async {
    if (!state.isSpeaking) return startReadAloud();

    if (state.isPaused) {
      await _speech.resume();
      emit(state.copyWith(isPaused: false));
      _scheduleNextToken();
    } else {
      _stopKaraoke();
      await _speech.pause();
      emit(state.copyWith(isPaused: true));
    }
  }

  /// Husimamisha au kuanza kusoma.
  Future<void> toggleReadAloud() async {
    if (state.isSpeaking) return stopReadAloud();
    return startReadAloud();
  }

  /// Huachilia sauti ya sasa (bila kubadilisha mapendeleo).
  Future<void> stopSpeakingOnly() async {
    await _audio.stop();
    return _speech.stop();
  }

  /// Husoma **neno moja** — hutumika kwa kugusa neno (`tapToHear`).
  ///
  /// Hii kwa makusudi **HAIBADILIKI** `isSpeaking` wala `highlightStart`/
  /// `highlightEnd`: kugusa neno ni maoni ya haraka (malezi ya msamiati),
  /// si "kusoma ukurasa". Kubadilisha `isSpeaking` kungefanya kitufe cha
  /// kucheza kionekane kimesimama wakati mtoto hajawahi kuanza kusoma.
  ///
  /// Pia **haisimamishi** karaoke inayoendelea kwa kubadilisha `_tokenIndex` —
  /// kama mtoto anasikiliza ukurasa na kugusa neno moja, karaoke inaendelea
  /// kwenye nafasi yake. Sauti ya neno hilo inachukua nafasi ya sauti kwa
  /// sekunde chache, kisha `onPageReadFinished`/kipima-muda huendelea.
  ///
  /// Hufanya kitu **bila sauti** (au wakati `speechAvailable` ni `false`) —
  /// halogwi wala kuonyesha kosa, kwa sababu kugusa neno si ombi la lazima.
  Future<void> speakWord(String word) async {
    final String clean = word.trim();
    if (clean.isEmpty || !state.speechAvailable) return;

    final bool ready = await _speech.configure(
      rate: state.voice.rate * state.rateMultiplier,
      pitch: state.voice.pitch,
      preferSwahili: _swahili,
    );
    if (isClosed || !ready) return;

    await _speech.speak(clean);
  }

  // =========================================================================
  // Mapendeleo
  // =========================================================================

  /// Huongeza ukubwa wa maandishi kwa hatua.
  void increaseTextScale() =>
      setTextScale(state.textScale + _textScaleStep);

  /// Hupunguza ukubwa wa maandishi kwa hatua.
  void decreaseTextScale() =>
      setTextScale(state.textScale - _textScaleStep);

  /// Huweka ukubwa wa maandishi (huzuia ndani ya vikomo).
  void setTextScale(double value) {
    final double clamped = value.clamp(
      ReaderState.minTextScale,
      ReaderState.maxTextScale,
    );
    if (clamped == state.textScale) return;
    emit(state.copyWith(textScale: clamped));
  }

  /// Hurudisha ukubwa wa maandishi kwenye kawaida.
  void resetTextScale() => setTextScale(ReaderState.defaultTextScale);

  /// Huongeza kasi ya sauti kwa hatua.
  void increaseRate() =>
      setRateMultiplier(state.rateMultiplier + _rateStep);

  /// Hupunguza kasi ya sauti kwa hatua.
  void decreaseRate() =>
      setRateMultiplier(state.rateMultiplier - _rateStep);

  /// Huweka kizidishi cha kasi (huzuia ndani ya vikomo).
  ///
  /// Inabadilisha urefu wa neno la karaoke mara moja, na — kama tunasoma —
  /// inaanza upya ili sauti na mwanga vilingane.
  void setRateMultiplier(double value) {
    final double clamped = value.clamp(
      ReaderState.minRateMultiplier,
      ReaderState.maxRateMultiplier,
    );
    if (clamped == state.rateMultiplier) return;
    final bool wasSpeaking = state.isSpeaking;
    _stopKaraoke();
    emit(state.copyWith(rateMultiplier: clamped));
    if (wasSpeaking) startReadAloud();
  }

  /// Hubadilisha sauti (Mama/Baba/Mtoto).
  ///
  /// Sauti ni ya mwanadamu, si tafsiri: inabadilisha `rate`/`pitch` pekee,
  /// ambazo ni sehemu ya sauti. Lebo zinatoka ARB.
  void setVoice(ReaderVoice voice) {
    if (voice == state.voice) return;
    final bool wasSpeaking = state.isSpeaking;
    _stopKaraoke();
    emit(state.copyWith(voice: voice));
    if (wasSpeaking) startReadAloud();
  }

  /// Hugeuza "geuza ukurasa wenyewe".
  void toggleAutoPageTurn() {
    final bool next = !state.autoPageTurn;
    emit(state.copyWith(autoPageTurn: next));
    if (!next) _stopAutoTurn();
  }

  /// Hugeuza alama ya ukurasa huu.
  void toggleBookmark() {
    final Set<int> pages = <int>{...state.bookmarkedPages};
    if (!pages.remove(state.pageIndex)) {
      pages.add(state.pageIndex);
    }
    emit(state.copyWith(bookmarkedPages: pages));
    unawaited(_persistBookmarks(pages));
  }

  // =========================================================================
  // Mwonekano wa kusoma (usiku, hali ya kusoma, muda wa kugeuza)
  // =========================================================================

  /// Hugeuza hali ya usiku (mandhari nyeusi).
  ///
  /// Hii ni mapendeleo ya **muonekano** pekee: haigusi kusoma wala
  /// kusogeza kurasa, kwa hivyo hatusimamishi sauti inayoendelea.
  void toggleNightMode() {
    emit(state.copyWith(isNightMode: !state.isNightMode));
  }

  /// Hubadilisha jinsi ukurasa unavyotumika ([ReadingMode]).
  ///
  /// Athari kwa sauti ni **sehemu ya maana ya hali hii**, si mapambo:
  ///
  /// * [ReadingMode.listenOnly] huanza kusoma **yenyewe** — mtoto anayelala
  ///   hawezi kugusa kitufe, kwa hivyo kusubiri mguso kungeivunja ahadi.
  /// * [ReadingMode.readOnly] husimamisha sauti: kitufe cha kucheza
  ///   kinazimwa, na sauti inayoendelea wakati kitufe kimezimwa ingepingana
  ///   na hali inayoonyeshwa.
  ///
  /// Kati ya hizo mbili hatufanyi kitu: kubaki kwenye [readAndListen]
  /// hakuondoi kusoma kulikoanza.
  void setReadingMode(ReadingMode mode) {
    if (mode == state.readingMode) return;
    emit(state.copyWith(readingMode: mode));

    if (mode == ReadingMode.listenOnly) {
      if (!state.isSpeaking) unawaited(startReadAloud());
      return;
    }
    if (mode == ReadingMode.readOnly && state.isSpeaking) {
      unawaited(stopReadAloud());
    }
  }

  /// Hubadilisha sekunde kati ya kurasa (`1`, `2`, `3`, `5`).
  ///
  /// Thamani isiyo halali (mfano `4`) hubanwa na [ReaderState]: `4` inakuwa
  /// `3`. Kipima-muda kilichopangwa kwa muda wa zamani husimamishwa, kwa
  /// sababu hakuna maana ya kusubiri muda ambao mtumiaji ameubadilisha.
  void setAutoTurnDelay(int seconds) {
    final int clamped = ReaderState.clampAutoTurnDelay(seconds);
    if (clamped == state.autoTurnDelay) return;
    _stopAutoTurn();
    emit(state.copyWith(autoTurnDelay: clamped));
  }

  // =========================================================================
  // Hifadhi ya maendeleo (ukurasa wa mwisho na alama)
  // =========================================================================

  /// Ukurasa wa mwisho uliosomwa wa hadithi hii, au `null`.
  ///
  /// Ukurasa unaita hii mara moja baada ya hadithi kupakiwa ili kuuliza
  /// \"endelea kutoka ukurasa 8?\". Hifadhi ikishindwa, hurudisha `null` —
  /// na hapo UI haionyeshi swali kabisa (tazama `reading_progress_store.dart`).
  Future<int?> savedPage() => _progress.savedPage(_storyId);

  /// Huhifadhi ukurasa wa sasa mara moja (mwito wa mwisho wakati wa kutoka).
  ///
  /// Kawaida hatuhitaji hii — kila mabadiliko ya ukurasa huhifadhi yenyewe.
  /// Ipo kwa kisa kimoja: mtoto anafunga reader kabla ya kugeuza ukurasa.
  Future<void> saveProgressNow() => _persistProgress();

  /// Hufuta maendeleo ya hadithi hii (\"Anza Upya\").
  ///
  /// Haigusi alama za kurasa: kusoma upya hadithi si sababu ya kuzifuta, na
  /// mtoto anayetaka kuanza mwanzo hajafuta alama zake kwa makusudi.
  Future<void> startOver() async {
    final String id = _storyId;
    if (id.isEmpty) return;
    await _progress.clearProgress(id);
  }

  /// `id` ya hadithi inayosomwa (`''` kama hakuna).
  ///
  /// Hifadhi hutumia hii kama ufunguo; `''` huzuia kuandika ufunguo tupu,
  /// ndiyo maana `ReadingProgressStore` hukataa `storyId.isEmpty`.
  String get _storyId => state.story?.id ?? '';

  /// Hurejesha alama za kurasa zilizohifadhiwa kwa hadithi hii.
  ///
  /// Huachwa bila kusubiriwa kwenye `loadStory`/`loadById` — alama ni
  /// mapambo, na kufanya hadithi isionekane hadi disk isomwe kungechelewesha
  /// kufungua ukurasa kwa bure.
  Future<void> _restoreBookmarks() async {
    final String id = _storyId;
    if (id.isEmpty) return;
    final Set<int> saved = await _progress.bookmarks(id);
    if (isClosed || saved.isEmpty) return;
    // Tunaunganisha na hali ya sasa badala ya kuichukua nafasi yake: mtoto
    // anaweza kuwa ameweka alama mpya kabla disk isomwe.
    emit(state.copyWith(bookmarkedPages: <int>{...saved, ...state.bookmarkedPages}));
  }

  /// Huhifadhi ukurasa wa sasa. Haitoi kosa — hifadhi si sharti.
  Future<void> _persistProgress() async {
    final String id = _storyId;
    if (id.isEmpty) return;
    await _progress.savePage(id, state.pageIndex);
  }

  /// Huhifadhi alama za kurasa. Haitoi kosa — hifadhi si sharti.
  Future<void> _persistBookmarks(Set<int> pages) async {
    final String id = _storyId;
    if (id.isEmpty) return;
    await _progress.saveBookmarks(id, pages);
  }

  // =========================================================================
  // Karaoke (mwanga wa neno)
  // =========================================================================

  /// Hatua ya ukubwa wa maandishi kwa kila mguso.
  static const double _textScaleStep = 0.10;

  /// Hatua ya kasi kwa kila mguso.
  static const double _rateStep = 0.10;

  /// Urefu wa neno wa kawaida wa Kiswahili (`simba`, `mama`, `maji`).
  static const double _averageWordLength = 6.0;

  /// Hupata maneno ya ukurasa wa sasa.
  void _prepareTokens() {
    final StoryPage? page = state.currentPage;
    if (page == null) {
      _tokens = const <TextToken>[];
      _pageText = '';
      return;
    }
    _pageText = page.text(swahili: _swahili);
    // Maneno pekee — alama za uakifishaji hazipati mwanga wao.
    _tokens = SwahiliTextUtils.wordTokens(_pageText);
    _tokenIndex = 0;
  }

  /// Hupanga neno linalofuata.
  ///
  /// Kila neno lina urefu wake, kwa hivyo kipima-muda ni kimoja kwa wakati
  /// — si `Timer.periodic` yenye kasi moja.
  void _scheduleNextToken() {
    _karaokeTimer?.cancel();
    if (!state.isSpeaking || state.isPaused) return;

    if (_tokenIndex >= _tokens.length) {
      _onPageReadFinished();
      return;
    }

    final TextToken token = _tokens[_tokenIndex];
    emit(state.copyWith(
      highlightStart: token.start,
      highlightEnd: token.end,
    ),);

    _karaokeTimer = Timer(_durationForToken(token), () {
      _tokenIndex += 1;
      _scheduleNextToken();
    });
  }

  /// Urefu wa muda kwa neno moja.
  ///
  /// Huhesabiwa kutoka:
  ///
  /// * **Urefu wa neno** — `kilimanjaro` huchukua muda zaidi ya `na`.
  /// * **Kasi ya kawaida** — [AppConstants.wordsPerMinute] (maneno 130/dakika).
  /// * **Mapendeleo** — [ReaderState.rateMultiplier] na [ReaderState.voice].
  ///
  /// Sauti za `mtoto` huzidisha kasi kwa ~1.11, `baba` hupunguza kwa ~0.93 —
  /// sawa na `voice.rate / ReaderVoice.mama.rate`.
  Duration _durationForToken(TextToken token) {
    final double lengthFactor =
        (token.text.length / _averageWordLength).clamp(0.55, 2.20);
    final double voiceFactor = state.voice.rate / ReaderVoice.mama.rate;
    final double effectiveWpm =
        (AppConstants.wordsPerMinute * state.rateMultiplier * voiceFactor)
            .clamp(30.0, 400.0);
    final double msPerWord = 60000.0 / effectiveWpm;
    final int ms = (msPerWord * lengthFactor).round().clamp(140, 3000);
    return Duration(milliseconds: ms);
  }

  /// Ukurasa umemalizika kusomwa.
  void _onPageReadFinished() {
    _karaokeTimer?.cancel();
    emit(state.copyWith(isSpeaking: false, isPaused: false, clearHighlight: true));

    if (!state.autoPageTurn || state.isLastPage) {
      _resumeAfterTurn = false;
      return;
    }

    // Kusubiri kidogo kabla ya kugeuza: mtoto anahitaji muda wa kuona
    // ukurasa umemalizika kabla wa mwingine hauonekani.
    // Muda hutoka hali, si `AppSpacing.autoPageTurnDelay`: token ile ni
    // chaguo la msingi (sekunde 2) pekee, wakati hapa mtumiaji anaweza kuwa
    // amechagua 1, 3 au 5 kwenye paneli ya mipangilio.
    _resumeAfterTurn = true;
    _autoTurnTimer = Timer(state.autoTurnDuration, () {
      if (isClosed || !state.autoPageTurn) return;
      if (state.isLastPage) return;
      final bool resume = _resumeAfterTurn;
      _resumeAfterTurn = false;
      _goTo(state.pageIndex + 1);
      if (resume) startReadAloud();
    });
  }

  /// Injini ya sauti ilikwisha — hii haiathiri karaoke yetu.
  ///
  /// Tunaiacha kwa makusudi: kipima-muda chetu ndicho kinachoendesha mwanga,
  /// kwa hivyo hapa hatufanyi kitu. Tukiifuta hapa, mwanga ungekatika
  /// kwenye majukwaa yanayotoa `onDone` mapema.
  void _onSpeechFinished() {}

  /// Injini ya sauti ilikatika — humaanisha kosa la jukwaa.
  void _onSpeechCancelled() {
    if (isClosed) return;
    if (!state.speechAvailable) return;
    // Kusimamisha ni jambo la kawaida mtumiaji anapogusa "Acha" — hivyo
    // hatubadilishi `isSpeaking`; tunarekodi tu kuwa sauti haipatikani
    // kama TTS haijawahi kufanya kazi.
  }

  // =========================================================================
  // Usafi
  // =========================================================================

  /// Husimamisha kipima-muda cha neno na kusafisha hali ya kuendelea.
  void _stopKaraoke() {
    _karaokeTimer?.cancel();
    _karaokeTimer = null;
  }

  /// Husimamisha kipima-muda cha kugeuza ukurasa.
  void _stopAutoTurn() {
    _autoTurnTimer?.cancel();
    _autoTurnTimer = null;
    _resumeAfterTurn = false;
  }

  /// Husimamisha kila kitu kinachoendelea.
  void _resetPlayback() {
    _stopKaraoke();
    _stopAutoTurn();
    _tokenIndex = 0;
  }

  @override
  Future<void> close() async {
    await _audio.dispose();
    // Hifadhi ya mwisho: mtoto anaweza kufunga reader bila kugeuza ukurasa,
    // na hapo ndipo `saveProgressNow` pekee inayoweza kuokoa mahali alipo.
    await _persistProgress();
    _resetPlayback();
    await _speech.dispose();
    return super.close();
  }
}
