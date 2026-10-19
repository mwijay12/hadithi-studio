/// AUDIO UTILS — TTS (kusoma kwa sauti), kasi na cache ya sauti.
///
/// Kwa nini faili hili lipo: Read-along TTS ndiyo kipengele cha msingi cha
/// Hadithi Studio (spec §4.1), na kina sheria nyingi ambazo zikikaa kwenye
/// widget zitasambaa: viwango vya kasi, muda wa kugeuza kurasa kiotomatiki,
/// ukubwa wa cache ya sauti, na — muhimu zaidi — **injini ipi inaweza
/// kuangazia maneno**.
///
/// **Kanuni ya kutokurudia:** `ttsSpeedPresets`, `defaultTtsSpeed`,
/// `autoPageTurnDelays`, `defaultAutoPageTurnDelay`, `audioCacheSizeMb` na
/// `maxSwahiliWordLength` hutoka [AppConstants]. Njia za sauti hutoka
/// [AssetConstants]. Faili hili ni mantiki (logic) pekee.
///
/// TANBIHI KWA `tts_engine` feature: faili hili halifanyi kazi ya mtandao.
/// Kuita Google Cloud TTS / Azure ni jukumu la `tts_remote_datasource.dart`;
/// hapa tunaweka **sheria** zinazoamua nini kinawezekana.
library;

import '../../config/constants/app_constants.dart';
import '../../config/constants/asset_constants.dart';

/// Injini inayotoa sauti.
///
/// Mpangilio huu unafuata spec §4.1: Google Cloud TTS (sw-TZ, WaveNet) ndiyo
/// ya msingi, Azure Cognitive Services ni ya akiba, na `flutter_tts` ya simu
/// hutumika bila mtandao.
enum TtsEngine {
  /// Sauti iliyohifadhiwa simuni — bila mtandao, **na** ina word timings.
  cached('Sauti iliyohifadhiwa', 'Cached audio'),

  /// Google Cloud TTS / Azure — inahitaji mtandao, lakini ina word timings.
  cloud('Mtandaoni', 'Online'),

  /// `flutter_tts` ya simu — kazi bila mtandao, lakini **haina** word timings.
  offline('Bila mtandao', 'Offline');

  const TtsEngine(this.labelSw, this.labelEn);

  /// Lebo kwa Kiswahili.
  final String labelSw;

  /// Lebo kwa Kiingereza.
  final String labelEn;
}

/// Hushughulikia kasi ya TTS, kugeuza kurasa na cache ya sauti.
abstract final class AppAudioUtils {
  // ---------------------------------------------------------------------------
  // Kasi ya kusoma
  // ---------------------------------------------------------------------------

  /// Viwango vyote vya kasi vinavyoruhusiwa (0.5 – 2.0).
  static const List<double> presets = AppConstants.ttsSpeedPresets;

  /// Kasi ya kawaida ya TTS.
  static const double defaultSpeed = AppConstants.defaultTtsSpeed;

  /// Kasi ya karibu zaidi kwenye orodha ya viwango vilivyoruhusiwa.
  ///
  /// Slider inaweza kurudisha thamani yoyote kati (`1.1`, `1.37`); API na
  /// injini zinakubali viwango vilivyoorodheshwa pekee. Hivyo kila thamani
  /// hupangwa kwa kiwango cha karibu zaidi: `1.1` → `1.0`, `1.35` → `1.5`.
  ///
  /// Kama thamani iko katikati kabisa (mfano `1.125` kati ya `1.0` na
  /// `1.25`), tunachagua kiwango cha **chini** — ni salama zaidi kwa mtoto
  /// anayejifunza kusoma.
  static double nearestPreset(double speed) {
    if (presets.isEmpty) return defaultSpeed;
    var nearest = presets.first;
    var smallestGap = (speed - nearest).abs();
    for (final preset in presets) {
      final gap = (speed - preset).abs();
      if (gap < smallestGap) {
        smallestGap = gap;
        nearest = preset;
      }
    }
    return nearest;
  }

  /// Nafasi (index) ya kiwango cha karibu zaidi kwenye [presets].
  static int presetIndex(double speed) => presets.indexOf(nearestPreset(speed));

  /// `true` kama [speed] ni kimoja cha viwango vilivyorodheshwa hasa.
  static bool isPreset(double speed) => presets.contains(speed);

  /// Kiwango cha kasi kinachofuata juu (kwa kitufe cha "+").
  static double fasterThan(double speed) {
    if (presets.isEmpty) return defaultSpeed;
    for (final preset in presets) {
      if (preset > speed + 0.001) return preset;
    }
    return presets.last;
  }

  /// Kiwango cha kasi kinachotangulia chini (kwa kitufe cha "−").
  static double slowerThan(double speed) {
    if (presets.isEmpty) return defaultSpeed;
    for (final preset in presets.reversed) {
      if (preset < speed - 0.001) return preset;
    }
    return presets.first;
  }

  // ---------------------------------------------------------------------------
  // Lebo za kasi (ramani ya viwango 6 → lebo 4)
  // ---------------------------------------------------------------------------

  /// Ufunguo wa ARB kwa lebo ya kasi.
  ///
  /// **KWA NINI VIWANGO SITA VINAPANGWA KWENYE LEBO NNE:**
  /// spec §4.1 inataja viwango vinne vya kasi ("Pole pole", "Kawaida",
  /// "Haraka", "Haraka sana") na `app_sw.arb` ina funguo nne hasa: `slow`,
  /// `normal`, `fast`, `veryFast`. Lakini `AppConstants.ttsSpeedPresets` ina
  /// thamani **sita**, kwa sababu `0.75` na `1.25` ni hatua laini
  /// zinazohitajika kwa mtoto anayeanza kusoma na kwa msomaji hodari.
  ///
  /// Ramani:
  ///
  /// | Kasi | Ufunguo wa ARB | Lebo        |
  /// |------|----------------|-------------|
  /// | 0.5  | `slow`         | Pole pole   |
  /// | 0.75 | `slow`         | Pole pole   |
  /// | 1.0  | `normal`       | Kawaida     |
  /// | 1.25 | `fast`         | Haraka      |
  /// | 1.5  | `fast`         | Haraka      |
  /// | 2.0  | `veryFast`     | Haraka sana |
  ///
  /// Ramani hii **haipotezi** kimoja cha presets: kila kimoja kinapata
  /// ufunguo. Ni **lebo** tu zinazorudiwa, na hilo ni sawa kwa mtumiaji —
  /// yeye husikia tofauti ya wazi kati ya 1.25 na 1.5 hata kama lebo ni ile
  /// ile.
  ///
  /// Tunalinganisha **thamani** (si index), ili kupanga upya `presets`
  /// kwenye [AppConstants] kusivunje ramani hii.
  static String speedLabelKey(double speed) {
    final preset = nearestPreset(speed);
    if (preset <= 0.75) return 'slow';
    if (preset <= 1.0) return 'normal';
    if (preset <= 1.5) return 'fast';
    return 'veryFast';
  }

  /// Lebo ya kasi kwa maandishi — fallback bila `BuildContext`.
  ///
  /// Kwenye widget, tumia `context.l10n` kupitia [speedLabelKey]
  /// (`slow` / `normal` / `fast` / `veryFast`). Hapa tunahitaji maandishi
  /// bila context kwa logs, notifications na tests.
  static String speedLabel(double speed, {bool swahili = true}) {
    switch (speedLabelKey(speed)) {
      case 'slow':
        return swahili ? 'Pole pole' : 'Slow';
      case 'normal':
        return swahili ? 'Kawaida' : 'Normal';
      case 'fast':
        return swahili ? 'Haraka' : 'Fast';
      default:
        return swahili ? 'Haraka sana' : 'Very fast';
    }
  }

  /// Maelezo ya kasi kwa `speed_selector.dart`.
  static String speedDescription(double speed, {bool swahili = true}) {
    switch (speedLabelKey(speed)) {
      case 'slow':
        return swahili ? 'Kwa wanaoanza kusoma' : 'For beginner readers';
      case 'normal':
        return swahili ? 'Kasi ya kawaida' : 'Normal reading speed';
      case 'fast':
        return swahili ? 'Kwa wasomaji hodari' : 'For confident readers';
      default:
        return swahili ? 'Kasi ya juu kabisa' : 'Fastest speed';
    }
  }

  /// Ufunguo wa ARB kwa lebo ya kasi **ya reader** (kizidishi `0.70`–`1.30`).
  ///
  /// **KWA NINI HII NI TOFAUTI NA [speedLabelKey]:** [speedLabelKey] hupokea
  /// kasi ya **injini ya TTS** (`0.5`–`2.0`, tazama [presets]). Reader yetu
  /// haitoi kasi ya injini moja kwa moja — inatoa `ReaderState.rateMultiplier`
  /// (`0.70`–`1.30`, hatua ya `0.10`) ambayo huzidishwa kwa `ReaderVoice.rate`
  /// kabla ya kufika kwenye injini. Kwa hivyo hatua **saba** za kizidishi
  /// hupangwa kwenye lebo **sita** za ARB — kila kimoja kinapata lebo, na
  /// `1.10`/`1.20` hushiriki "Haraka" kwa sababu ni karibu sana kwa sikio.
  ///
  /// | Kizidishi | Ufunguo         | Lebo          |
  /// |-----------|-----------------|---------------|
  /// | 0.70      | `slow`          | Pole pole     |
  /// | 0.80      | `speedGentle`   | Taratibu      |
  /// | 0.90      | `normal`        | Kawaida       |
  /// | 1.00      | `speedQuick`    | Haraka kidogo |
  /// | 1.10–1.20 | `fast`          | Haraka        |
  /// | 1.30      | `veryFast`      | Haraka sana   |
  ///
  /// Ramani ipo hapa (si kwenye widget) kwa sababu hii ni **sheria ya sauti**,
  /// na mahali pamoja pabaya ni mahali panapoharibu kidogo.
  static String readerSpeedLabelKey(double multiplier) {
    if (multiplier <= 0.75) return 'slow';
    if (multiplier <= 0.85) return 'speedGentle';
    if (multiplier <= 0.95) return 'normal';
    if (multiplier <= 1.05) return 'speedQuick';
    if (multiplier <= 1.20) return 'fast';
    return 'veryFast';
  }

  // ---------------------------------------------------------------------------
  // Kugeuza kurasa kiotomatiki
  // ---------------------------------------------------------------------------

  /// Chaguo za muda kati ya kurasa (sekunde): `1, 2, 3, 5`.
  static const List<int> autoPageTurnOptions = AppConstants.autoPageTurnDelays;

  /// Muda wa kawaida kati ya kurasa (sekunde).
  static const int defaultAutoPageTurnSeconds =
      AppConstants.defaultAutoPageTurnDelay;

  /// Kubana muda kwenye chaguo linaloruhusiwa.
  ///
  /// Chaguo halali ni `1, 2, 3, 5`. Thamani kama `4` haipitishwi kama ilivyo;
  /// huchaguliwa chaguo la karibu zaidi, ili slider ya reader isiruhusu muda
  /// ambao injini haitambui.
  ///
  /// Tumeandika `if` kwa mkono badala ya `.clamp(...)`: `num.clamp` hurudisha
  /// `num`, hivyo ingehitaji `.toInt()` na ingeruhusu kosa la aina
  /// lisiloonekana.
  static int clampAutoPageTurnSeconds(int seconds) {
    if (autoPageTurnOptions.isEmpty) return defaultAutoPageTurnSeconds;
    if (autoPageTurnOptions.contains(seconds)) return seconds;
    if (seconds <= autoPageTurnOptions.first) return autoPageTurnOptions.first;
    if (seconds >= autoPageTurnOptions.last) return autoPageTurnOptions.last;

    // Chaguo la karibu zaidi; kama kuna usawa, tunachagua la chini.
    var nearest = autoPageTurnOptions.first;
    var smallestGap = (seconds - nearest).abs();
    for (final option in autoPageTurnOptions) {
      final gap = (seconds - option).abs();
      if (gap < smallestGap) {
        smallestGap = gap;
        nearest = option;
      }
    }
    return nearest;
  }

  /// Muda kati ya kurasa kama `Duration`.
  ///
  /// UHUSIANO WA KUDUMU: `AppSpacing.autoPageTurnDelay`
  /// (config/theme/spacing.dart) ni `Duration(seconds: 2)`. Hiyo ni thamani
  /// ya **muonekano** (animation) na inalingana na
  /// [defaultAutoPageTurnSeconds] (2). Chanzo cha ukweli kwa chaguo za
  /// mtumiaji ni `AppConstants.autoPageTurnDelays`, na mabadiliko ya mtumiaji
  /// hupitishwa kwa Hive kupitia `StorageKeys`.
  static Duration autoPageTurnDuration(int seconds) =>
      Duration(seconds: clampAutoPageTurnSeconds(seconds));

  /// Lebo ya muda kwa UI: `sekunde 2` / `2 seconds`.
  ///
  /// Hatuandiki funguo mpya kwenye ARB kwa sababu `app_sw.arb` ina `minutes`
  /// ("dakika") pekee — hakuna ufunguo wa `seconds`. Kama tutaongeza, ni
  /// **lazima** iongezwe kwenye faili zote mbili (`app_sw.arb` na
  /// `app_en.arb`) kwa mpangilio ule ule, ili sheria ya usawa wa ARB isivunjike.
  static String autoPageTurnLabel(int seconds, {bool swahili = true}) {
    final value = clampAutoPageTurnSeconds(seconds);
    return swahili ? 'sekunde $value' : '$value seconds';
  }

  // ---------------------------------------------------------------------------
  // Cache ya sauti
  // ---------------------------------------------------------------------------

  /// Ukubwa wa juu wa cache ya sauti kwa MB.
  static int get cacheLimitMb => AppConstants.audioCacheSizeMb;

  /// Ukubwa wa juu wa cache ya sauti kwa baiti.
  static int get cacheLimitBytes => AppConstants.audioCacheSizeMb * 1024 * 1024;

  /// Bitrate ya kawaida ya sauti ya Kiswahili (kbps).
  ///
  /// Google Cloud TTS hurudisha MP3 ya mono ~48 kbps kwa sauti ya kuzungumza.
  /// Hii inatosha kwa hadithi, na kubaki chini ni muhimu: sauti ni kubwa
  /// kuliko maandishi, na kwenye simu ya 2GB RAM / 16GB storage kila MB
  /// inahesabiwa.
  static const int defaultSpeechBitrateKbps = 48;

  /// Makadirio ya ukubwa wa sauti kwa sekunde [seconds].
  ///
  /// Hutumika **kabla** ya kupakua, ili mtumiaji wa bundle ndogo aamue
  /// mwenyewe: "hadithi hii itatumia ~1.4 MB". Kuonyesha kiasi, tumia
  /// `Formatters.fileSize`.
  ///
  /// Fomula: `seconds x kbps x 1000 / 8` (bits → baiti).
  static int estimatedSpeechBytes(
    int seconds, {
    int bitrateKbps = defaultSpeechBitrateKbps,
  }) {
    if (seconds <= 0) return 0;
    final bits = seconds * bitrateKbps * 1000;
    return (bits / 8).round();
  }

  // ---------------------------------------------------------------------------
  // Injini na kuangazia maneno
  // ---------------------------------------------------------------------------

  /// Injini itakayotumika kwa hali ya sasa.
  ///
  /// Kipaumbele: sauti iliyohifadhiwa → cloud → `flutter_tts` ya simu.
  ///
  /// Kwa nini iliyohifadhiwa inatangulia: haitumii bundle, inafanya kazi bila
  /// mtandao, **na** ina word timings — hivyo kuangazia maneno kunabaki
  /// kamilifu shambani, kijijini au kwenye basi bila mtandao.
  static TtsEngine engineFor({
    required bool hasCachedAudio,
    required bool isOnline,
  }) {
    if (hasCachedAudio) return TtsEngine.cached;
    return isOnline ? TtsEngine.cloud : TtsEngine.offline;
  }

  /// `true` kama injini inaweza kurudisha word timings.
  ///
  /// Hii ni tofauti iliyoandikwa kwenye spec §4.4: kifurushi cha BURE
  /// kinapata TTS **bila** kuangazia maneno, na `flutter_tts` ya simu (bila
  /// mtandao) haitoi timings za maneno kabisa. Hivyo `word_highlighter.dart`
  /// hupunguza kuangazia badala ya kudhani timings zipo na kuonyesha maneno
  /// yasiyolingana na sauti.
  static bool supportsWordHighlighting(TtsEngine engine) =>
      engine != TtsEngine.offline;

  /// Lebo ya injini kwa UI.
  static String engineLabel(TtsEngine engine, {bool swahili = true}) =>
      swahili ? engine.labelSw : engine.labelEn;

  // ---------------------------------------------------------------------------
  // Maneno na sauti za ukurasa
  // ---------------------------------------------------------------------------

  /// Urefu wa juu wa neno la Kiswahili kwa "gusa neno usikie".
  ///
  /// Tumia hii kwenye hit-test ya `word_highlighter.dart` ili `ng'ombe` na
  /// `nyumbani` vizuiliwe kupita kikomo — digraph za Kiswahili na apostrofi
  /// (`ng'`) hufanya urefu wa neno usiwe dhahiri.
  static int get maxWordLength => AppConstants.maxSwahiliWordLength;

  /// Sauti ya kugeuza ukurasa (asset ya ndani — kazi bila mtandao).
  ///
  /// Sauti nyingine zote (mazingira, wanyama, matendo) ziko kwenye
  /// [AssetConstants] moja kwa moja; hii imo hapa kwa sababu reader
  /// huitumia kila ukurasa unaogeuzwa.
  static String get pageTurnSound => AssetConstants.soundPageTurn;

  /// Funguo za ARB zilizopo kwa sauti za Kiswahili.
  ///
  /// Hizi tatu zipo kwenye ARB sasa: `ttsVoice` ("Sauti"), `voiceMama`
  /// ("Mama"), `voiceBaba` ("Baba"), `voiceMtoto` ("Mtoto").
  ///
  /// TANBIHI — KAZI ILIYOB AKI: spec §4.1 inataja sauti za Kiingereza
  /// (English Female / English Male) pia, lakini `app_sw.arb` na `app_en.arb`
  /// **hazina** funguo za hizo bado. Zikiongezwa, ni lazima ziongezwe kwenye
  /// faili zote mbili kwa mpangilio ule ule (sheria ya usawa wa ARB), na
  /// ramani ya `voice id` → ufunguo iwe kwenye feature ya `tts_engine`
  /// (`voice_picker.dart`), si hapa.
  static const List<String> swahiliVoiceKeys = <String>[
    'voiceMama',
    'voiceBaba',
    'voiceMtoto',
  ];
}
