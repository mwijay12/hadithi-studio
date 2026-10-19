/// **HADITHI ZINAZOKUJA NA APP** — seti ya kuanza ya offline.
///
/// ## Kanuni kuu
///
/// Mzazi akishasakinisha Hadithi Studio, **mtoto afungue app na aanze
/// kusikiliza mara moja** — bila internet, bila akaunti, bila kudownload
/// kitu kingine. Hii ndiyo kanuni inayotawala faili hili.
///
/// ## Hadithi 3 zilizochaguliwa
///
/// | # | Hadithi | Kurasa | Kwa nini hii |
/// |---|---|---|---|
/// | 1 | Safari ya Simba | 6 | Wanyama — mvuto mpana zaidi kwa watoto |
/// | 2 | Mlima Kilimanjaro | 6 | Fahari ya kitaifa; picha yenye nguvu |
/// | 3 | Nyota za Usiku | 5 | Hadithi ya kulala — hutumika kila siku |
///
/// Jumla: **kurasa 17**.
///
/// ## Kwa nini tatu, na kwa nini hizi
///
/// Tatu hutoa **uchaguzi** bila kufanya app kuwa nzito. Zaidi ya tatu
/// huongeza megabytes kwenye sakinisho la mzazi — hatua ya kwanza kabisa ya
/// mtumiaji. Chini ya mbili, mtoto hana cha kuchagua.
///
/// ## ⚠️ Sauti bado haipo
///
/// Faili za sauti **hazijazalishwa**. Hivyo `assets/audio/` **HAIJAONGEZWA**
/// kwenye `pubspec.yaml` — kuiorodhesha bila faili ni onyo la build.
/// Audio ikifika: ongeza `- assets/audio/` kwenye pubspec, kisha tumia
/// [pageAudioAsset] na [pageTimingAsset] hapa chini.
library;

/// Hulka ya hadithi zinazoambatana na app.
abstract final class BundledStories {
  /// Vitambulisho vya hadithi 3 zinazokuja ndani ya app.
  ///
  /// Mpangilio ni wa kuonyesha: ndiyo mpangilio mtoto anaziona.
  static const List<String> ids = <String>[
    'safari-ya-simba',
    'mlima-kilimanjaro',
    'nyota-za-usiku',
  ];

  /// `true` = hadithi hii inapatikana **tangu sakinisho**, bila mtandao.
  static bool isBundled(String storyId) => ids.contains(storyId);

  /// Chanzo cha faili za sauti ndani ya app.
  static const String audioRoot = 'assets/audio';

  /// Kiendelezi cha sauti.
  ///
  /// **MP3 48 kbps mono** — maamuzi ya makusudi: sauti ya mtu (sivyo
  /// muziki) haina faida kubwa juu ya 48 kbps mono, na Tanzania ina
  /// simu zenye nafasi ndogo. Nyimbo pekee ndiyo inahitaji bitrate kubwa.
  static const String audioExtension = 'mp3';

  /// Bitrate inayolengwa kwa usimulizi (kbps).
  static const int narrationBitrateKbps = 48;

  /// Bitrate inayolengwa kwa muziki wa nyuma (kbps).
  static const int musicBitrateKbps = 64;

  /// Njia ya sauti ya ukurasa — `assets/audio/<story>/page_01.mp3`.
  ///
  /// **Kwa nini kwa kila ukurasa, sivyo kwa hadithi nzima:** mtoto
  /// anasimama kwenye ukurasa mmoja; kuhitaji faili yote kupakia kungefanya
  /// ukurasa wa kwanza usubiri, na kungevunja uangazaji wa neno ambao ni wa
  /// kila ukurasa.
  static String pageAudioAsset(String storyId, int pageIndex) =>
      '$audioRoot/$storyId/page_${_pad(pageIndex)}.$audioExtension';

  /// Njia ya timestamps za maneno — `assets/audio/<story>/page_01.json`.
  ///
  /// **Hii ni muhimu, sivyo ya kupamba.** Uangazaji wa neno (kanuni #15)
  /// unahitaji muda wa kila neno. Audio yenye usimulizi hupeana sauti pekee
  /// — timestamps huzalishwa kwa **forced alignment** (WhisperX / MFA).
  /// Bila faili hii, kubadilisha kutoka TTS ya simu kwenda audio iliyorekodiwa
  /// **kunavunja uangazaji wa neno**.
  static String pageTimingAsset(String storyId, int pageIndex) =>
      '$audioRoot/$storyId/page_${_pad(pageIndex)}.json';

  /// Kurasa za hadithi moja ya kuanza.
  static const Map<String, int> pageCounts = <String, int>{
    'safari-ya-simba': 6,
    'mlima-kilimanjaro': 6,
    'nyota-za-usiku': 5,
  };

  /// Kurasa zote za seti ya kuanza.
  static int get totalPages =>
      pageCounts.values.fold<int>(0, (int a, int b) => a + b);

  /// Bajeti ya juu kwa hadithi moja (sauti + picha + muziki).
  ///
  /// Hii ni **lengo la kupima**, sivyo kikomo cha msimbo. Tazama
  /// `docs/AUDIO-SCRIPT.md` kwa makisio yanayotokana na ukubwa halisi.
  static const int maxStoryBytes = 5 * 1024 * 1024;

  /// Bajeti ya juu kwa seti yote ya kuanza.
  static const int maxLaunchSetBytes = 15 * 1024 * 1024;

  static String _pad(int pageIndex) =>
      (pageIndex + 1).toString().padLeft(2, '0');
}
