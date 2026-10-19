/// Njia (paths) za assets zote zilizoorodheshwa kwenye `pubspec.yaml`.
///
/// Kuweka paths hapa kunazuia makosa ya "asset not found" wakati wa
/// runtime — hasa kwa sababu APK lazima ibaki chini ya 30MB na
/// assets hupangwa kwa makini.
abstract final class AssetConstants {
  // ─────────────────────────────────────────────────────────────
  // Folders
  // ─────────────────────────────────────────────────────────────

  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _lottie = 'assets/lottie';
  static const String _rive = 'assets/rive';
  static const String _sounds = 'assets/sounds';
  static const String _fonts = 'assets/fonts';

  // ─────────────────────────────────────────────────────────────
  // Nembo (logo) & branding
  // ─────────────────────────────────────────────────────────────

  /// Nembo kuu ya Hadithi Studio (rangi).
  static const String logoFull = '$_images/logo_full.png';

  /// Nembo yenye rangi moja — kwa top bars.
  static const String logoMonochrome = '$_images/logo_mono.png';

  /// Icon ya app (kwa "about" page).
  static const String appIcon = '$_icons/app_icon.png';

  /// Muundo wa kanga (Tanzania) — hutumika kama background ya splash.
  static const String kangaPattern = '$_images/kanga_pattern.png';

  /// Muundo wa kitenge — hutumika kwenye onboarding na headers.
  static const String kitengePattern = '$_images/kitenge_pattern.png';

  /// Mstari wa Kilimanjaro (silhouette) kwa illustrations za mandhari.
  static const String kilimanjaroSilhouette =
      '$_images/kilimanjaro_silhouette.png';

  // ─────────────────────────────────────────────────────────────
  // Onboarding (slide 1–4) — spec §5.3
  // ─────────────────────────────────────────────────────────────

  /// Slide 1: "Soma Hadithi Zenye Uhai" — kitabu kinafunguka.
  static const String onboardingRead = '$_images/onboarding/onboarding_read.png';

  /// Slide 2: "Sikiliza kwa Sauti ya Kiswahili" — word highlighting.
  static const String onboardingListen =
      '$_images/onboarding/onboarding_listen.png';

  /// Slide 3: "Tengeneza Hadithi Yako" — AI inatengeneza picha.
  static const String onboardingCreate =
      '$_images/onboarding/onboarding_create.png';

  /// Slide 4: "Chagua Lugha Yako" — Kiswahili / English / Zote Mbili.
  static const String onboardingLanguage =
      '$_images/onboarding/onboarding_language.png';

  /// Picha za vichwa vya watoto (kwa age group selector).
  static const String kidsReading = '$_images/kids_reading.png';
  static const String kidsListening = '$_images/kids_listening.png';

  // ─────────────────────────────────────────────────────────────
  // Makundi (categories) — picha za chips
  // ─────────────────────────────────────────────────────────────

  static const String categoryHadithiZaKiswahili =
      '$_images/categories/cat_culture.png';
  static const String categoryHadithiZaKisasa =
      '$_images/categories/cat_safari.png';
  static const String categoryNgano = '$_images/categories/cat_culture.png';
  static const String categoryMethali = '$_images/categories/cat_morals_wisdom.png';
  static const String categoryHistoria = '$_images/categories/cat_culture.png';
  static const String categorySayansi = '$_images/categories/cat_science.png';
  static const String categoryMazingira = '$_images/categories/cat_safari.png';
  static const String categoryMaadili = '$_images/categories/cat_morals_wisdom.png';
  static const String categoryUjasiriamali =
      '$_images/categories/cat_culture.png';
  static const String categoryBurudani = '$_images/categories/cat_poems_songs.png';
  static const String categoryElimu = '$_images/categories/cat_science.png';
  static const String categoryDini = '$_images/categories/cat_morals_wisdom.png';
  static const String categoryMichezo = '$_images/categories/cat_safari.png';
  static const String categorySanaa = '$_images/categories/cat_poems_songs.png';
  /// **Kundi jipya la wanyama** (2026-10-18).
  static const String categoryWanyama =
      '$_images/categories/cat_animal_stories.png';

  // ─────────────────────────────────────────────────────────────
  // Beji (badges) za mafanikio — spec §4.5
  // ─────────────────────────────────────────────────────────────

  static const String badgeMsomajiWaKwanza =
      '$_images/badges/msomaji_wa_kwanza.png';
  static const String badgeMsomajiHodari =
      '$_images/badges/msomaji_hodari.png';
  static const String badgeMsomajiBingwa =
      '$_images/badges/msomaji_bingwa.png';
  static const String badgeMwandishi = '$_images/badges/mwandishi.png';
  static const String badgeMwandishiMaarufu =
      '$_images/badges/mwandishi_maarufu.png';
  static const String badgeStreakYaWiki = '$_images/badges/streak_ya_wiki.png';
  static const String badgeStreakYaMwezi = '$_images/badges/streak_ya_mwezi.png';
  static const String badgeMtaalamWaMethali =
      '$_images/badges/mtaalam_wa_methali.png';
  static const String badgeSafariKilimanjaro =
      '$_images/badges/safari_kilimanjaro.png';

  /// Beji ya "locked" — huonyeshwa kwa mafanikio ambayo hayajafikiwa.
  static const String badgeLocked = '$_images/badges/locked.png';

  // ─────────────────────────────────────────────────────────────
  // Icons za makundi kwa default UI
  // ─────────────────────────────────────────────────────────────

  static const String iconHome = '$_icons/home.png';
  static const String iconLibrary = '$_icons/library.png';
  static const String iconCreate = '$_icons/create.png';
  static const String iconBookshelf = '$_icons/bookshelf.png';
  static const String iconProfile = '$_icons/profile.png';
  static const String iconMicrophone = '$_icons/microphone.png';
  static const String iconOffline = '$_icons/offline.png';
  static const String iconEmptyState = '$_icons/empty_state.png';
  static const String iconErrorState = '$_icons/error_state.png';

  // ─────────────────────────────────────────────────────────────
  // Lottie (animations)
  // ─────────────────────────────────────────────────────────────

  /// Animation ya nembo kwenye splash (kitabu kinafunguka).
  static const String lottieLogoAnimated = '$_lottie/logo_animated.json';

  /// Animation ya "loading" yenye motif za Tanzania.
  static const String lottieLoading = '$_lottie/loading_tanzania.json';

  /// Animation ya AI inapotengeneza hadithi/picha.
  static const String lottieAiGenerating = '$_lottie/ai_generating.json';

  /// Animation ya mafanikio (achievement unlocked).
  static const String lottieAchievement = '$_lottie/achievement.json';

  /// Animation ya malipo yamefanikiwa (M-Pesa).
  static const String lottiePaymentSuccess = '$_lottie/payment_success.json';

  /// Animation ya "hakuna mtandao".
  static const String lottieNoInternet = '$_lottie/no_internet.json';

  // ─────────────────────────────────────────────────────────────
  // Rive (interactive animations)
  // ─────────────────────────────────────────────────────────────

  /// Mhusika (character) anayeweza kuguswa kwenye hadithi.
  static const String riveTappableCharacter = '$_rive/tappable_character.riv';

  /// Mascot wa Hadithi Studio (kwa onboarding na empty states).
  static const String riveMascot = '$_rive/mascot.riv';

  /// Uhuishaji wa kugeuza ukurasa (page turn).
  static const String rivePageTurn = '$_rive/page_turn.riv';

  // ─────────────────────────────────────────────────────────────
  // Sauti (sound effects) — spec §4.2
  // ─────────────────────────────────────────────────────────────

  /// Sauti za mazingira.
  static const String soundForest = '$_sounds/forest.mp3';
  static const String soundOcean = '$_sounds/ocean.mp3';
  static const String soundCity = '$_sounds/city.mp3';
  static const String soundVillage = '$_sounds/village.mp3';

  /// Sauti za vitendo.
  static const String soundPageTurn = '$_sounds/page_turn.mp3';
  static const String soundSuccess = '$_sounds/success.mp3';
  static const String soundError = '$_sounds/error.mp3';
  static const String soundTap = '$_sounds/tap.mp3';
  static const String soundSparkle = '$_sounds/sparkle.mp3';

  /// Sauti za wanyama (kwa hadithi za wanyama).
  static const String soundLion = '$_sounds/lion.mp3';
  static const String soundElephant = '$_sounds/elephant.mp3';
  static const String soundBird = '$_sounds/bird.mp3';
  static const String soundGoat = '$_sounds/goat.mp3';
  static const String soundRooster = '$_sounds/rooster.mp3';

  // ─────────────────────────────────────────────────────────────
  // Fonts (bundled — offline)
  // ─────────────────────────────────────────────────────────────

  /// Njia za fonts zilizopangwa. Kwa sasa `pubspec.yaml` ina `fonts:`
  /// iliyofungwa (commented) na tunatumia `google_fonts`. Kwa production
  /// (offline-first!), pakua .ttf hapa na uwashe `fonts:` kwenye pubspec,
  /// kisha uondoe GoogleFonts kwenye `typography.dart`.
  static const String fontsDirectory = _fonts;
  static const String fontNunitoRegular = '$_fonts/Nunito-Regular.ttf';
  static const String fontNunitoBold = '$_fonts/Nunito-Bold.ttf';
  static const String fontMerriweatherRegular =
      '$_fonts/Merriweather-Regular.ttf';
  static const String fontBaloo2Regular = '$_fonts/Baloo2-Regular.ttf';
}
