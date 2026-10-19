/// Constants za app nzima: jina, bei, mipaka ya biashara na funguo za storage.
///
/// Namba zote za biashara (bei za TZS, mgawanyo wa mapato, mipaka ya
/// usajili) ziko hapa ili kubadilisha sera iwe mahali kimoja tu.
abstract final class AppConstants {
  // ─────────────────────────────────────────────────────────────
  // Identity
  // ─────────────────────────────────────────────────────────────

  static const String appName = 'Hadithi Studio';
  static const String taglineSw = 'Soma. Sikiliza. Ishi Hadithi.';
  static const String taglineEn = 'Read. Listen. Live the Story.';
  static const String companyName = 'Hadithi Studio Tanzania';

  /// Toleo la app linavyoonekana kwa mtumiaji (pia hutoka pubspec kwa
  /// package_info wakati wa runtime — hii ni fallback).
  static const String appVersion = '0.1.0';

  // ─────────────────────────────────────────────────────────────
  // Mawasiliano & kisheria (support, sheria)
  // ─────────────────────────────────────────────────────────────

  static const String supportEmail = 'msaada@hadithistudio.co.tz';
  static const String supportPhone = '+255700000000';
  static const String whatsappSupport = '+255700000000';
  static const String privacyPolicyPath = '/privacy';
  static const String termsOfServicePath = '/terms';
  static const String helpCenterPath = '/help';

  // ─────────────────────────────────────────────────────────────
  // Tanzania: nchi, lugha, sarafu
  // ─────────────────────────────────────────────────────────────

  /// Msimbo wa nchi wa Tanzania.
  static const String countryIsoCode = 'TZ';

  /// Namba ya kimataifa ya Tanzania (+255).
  static const String dialCode = '+255';

  /// Msimbo wa nchi bila `+`: `255`.
  static const String countryCallingCode = '255';

  /// Sarafu (Tanzanian Shilling).
  static const String currencyCode = 'TZS';
  static const String currencySymbol = 'TZS';

  /// Lugha ya msingi na ya pili.
  static const String defaultLanguageCode = 'sw';
  static const String fallbackLanguageCode = 'en';

  /// Mkoa wa msingi kwa leaderboard ("kitaifa").
  static const String defaultRegion = 'Tanzania';

  // ─────────────────────────────────────────────────────────────
  // Hadithi: mipaka ya uundaji
  // ─────────────────────────────────────────────────────────────

  /// Kurasa za chini kabisa kwa hadithi mpya (spec §4.3 Step 2).
  static const int minStoryPages = 5;

  /// Kurasa nyingi kabisa kwa hadithi mpya.
  static const int maxStoryPages = 30;

  /// Kurasa za kawaida kwa hadithi mpya.
  static const int defaultStoryPages = 10;

  /// Herufi nyingi kabisa kwa jina la hadithi.
  static const int maxStoryTitleLength = 80;

  /// Herufi nyingi kabisa kwa maelezo (synopsis).
  static const int maxSynopsisLength = 500;

  /// Herufi nyingi kabisa kwa ukurasa mmoja wa hadithi.
  static const int maxPageTextLength = 1200;

  /// Tagi nyingi kabisa kwa hadithi moja.
  static const int maxStoryTags = 8;

  /// Maneno kwa dakika — hutumika kukadiria muda wa kusoma.
  /// Kiswahili husomwa kwa kasi ya wastani ya maneno 130 kwa dakika.
  static const int wordsPerMinute = 130;

  // ─────────────────────────────────────────────────────────────
  // Bei (TZS) — spec §4.4
  // ─────────────────────────────────────────────────────────────

  /// BURE — bure kabisa.
  static const int priceBureTZS = 0;

  /// MSINGI — TZS 5,000 kwa mwezi.
  static const int priceMsingiTZS = 5000;

  /// VIP — TZS 12,000 kwa mwezi.
  static const int priceVipTZS = 12000;

  /// FAMILIA — TZS 18,000 kwa mwezi.
  static const int priceFamiliaTZS = 18000;

  /// Punguzo la malipo ya robo mwaka (3 months) — 10%.
  static const double quarterlyDiscount = 0.10;

  /// Punguzo la malipo ya mwaka mzima (12 months) — 20%.
  static const double yearlyDiscount = 0.20;

  /// Hadithi za bure kwa mwezi kwenye kifurushi cha BURE.
  static const int freeStoriesPerMonth = 3;

  /// Hadithi kwa mwezi kwenye kifurushi cha MSINGI.
  static const int msingiStoriesPerMonth = 15;

  /// Hadithi zinazoruhusiwa kuundwa kwa mwezi kwenye MSINGI.
  static const int msingiStoriesToCreatePerMonth = 2;

  // ─────────────────────────────────────────────────────────────
  // Uuzaji wa hadithi na mapato ya waandishi — spec §4.4
  // ─────────────────────────────────────────────────────────────

  /// Bei ya chini kabisa ya hadithi inayouzwa.
  static const int minStoryPriceTZS = 500;

  /// Bei ya juu kabisa ya hadithi inayouzwa.
  static const int maxStoryPriceTZS = 5000;

  /// Mwandishi hupata 70% ya mapato.
  static const double creatorRevenueShare = 0.70;

  /// Jukwaa hupata 30% ya mapato.
  static const double platformRevenueShare = 0.30;

  /// Kiasi cha chini kabisa cha kutoa mapato kwa M-Pesa.
  static const int minPayoutTZS = 10000;

  /// Siku za malipo ya waandishi kila mwezi (mwisho wa mwezi).
  static const int payoutDayOfMonth = 28;

  // ─────────────────────────────────────────────────────────────
  // Njia za malipo
  // ─────────────────────────────────────────────────────────────

  /// Namba ya chini kabisa ya simu kwa Tanzania (baada ya +255).
  static const int phoneNationalLength = 9;

  /// Namba kamili ikiwa na msimbo wa nchi: +255XXXXXXXXX (12 herufi).
  static const int phoneInternationalLength = 13;

  /// Muda ambao OTP inaendelea kuwa halali (dakika 10).
  static const Duration otpValidity = Duration(minutes: 10);

  /// Urefu wa OTP.
  static const int otpLength = 6;

  /// Urefu wa chini kabisa wa neno la siri (password).
  ///
  /// Sheria ya usalama (spec §11): neno la siri fupi huvunjwa kwa urahisi,
  /// hivyo herufi 8 ndio kikomo cha chini kinachokubalika.
  static const int minPasswordLength = 8;

  /// Urefu wa juu kabisa wa neno la siri.
  ///
  /// bcrypt hukata kimya kimya baada ya baiti 72 — kuweka kikomo hapa
  /// kunazuia mtumiaji kuandika neno refu ambalo halingelindwa kikamilifu.
  static const int maxPasswordLength = 72;

  // ─────────────────────────────────────────────────────────────
  // Watoto & udhibiti wa mzazi
  // ─────────────────────────────────────────────────────────────

  /// Watoto wengi kabisa kwenye akaunti (FAMILIA — spec §4.4).
  static const int maxChildProfiles = 5;

  /// Umri wa chini kabisa wa mtoto anayeweza kuwa na wasifu.
  static const int minChildAge = 3;

  /// Umri wa juu kabisa wa mtoto anayeweza kuwa na wasifu.
  static const int maxChildAge = 15;

  /// Umri wa chini kabisa wa mtumiaji kujiunga peke yake.
  static const int minSelfSignupAge = 13;

  /// Urefu wa PIN ya udhibiti wa mzazi.
  static const int pinLength = 4;

  /// Muda wa skrini wa chini kabisa unaoweza kuwekwa (dakika).
  static const int minScreenTimeMinutes = 15;

  /// Muda wa skrini wa juu kabisa unaowezea kuwekwa (dakika).
  static const int maxScreenTimeMinutes = 240;

  /// Muda wa skrini wa kawaida (dakika).
  static const int defaultScreenTimeMinutes = 60;

  // ─────────────────────────────────────────────────────────────
  // Nje ya mtandao (offline) — spec §6.3
  // ─────────────────────────────────────────────────────────────

  /// Hadithi zinazoweza kupakuliwa kwenye VIP.
  static const int offlineStoriesVip = 50;

  /// Hadithi zinazoweza kupakuliwa kwenye FAMILIA.
  static const int offlineStoriesFamilia = 100;

  /// Ukubwa wa juu wa cache ya picha (MB).
  static const int imageCacheSizeMb = 120;

  /// Ukubwa wa juu wa cache ya sauti (MB).
  static const int audioCacheSizeMb = 200;

  /// Cache ya hadithi hufutwa baada ya siku hizi kama haijasomwa.
  static const int offlineCacheExpiryDays = 60;

  // ─────────────────────────────────────────────────────────────
  // Kusoma (reader) — spec §4.1
  // ─────────────────────────────────────────────────────────────

  /// Kasi za TTS: "Pole pole" hadi "Haraka sana".
  static const List<double> ttsSpeedPresets = <double>[
    0.5, // Pole pole sana
    0.75, // Pole pole
    1.0, // Kawaida
    1.25, // Haraka kidogo
    1.5, // Haraka
    2.0, // Haraka sana
  ];

  /// Kasi ya kawaida ya TTS.
  static const double defaultTtsSpeed = 1.0;

  /// Ukubwa wa chini na juu wa maandishi ya hadithi (sp).
  static const double minStoryFontSize = 16;
  static const double maxStoryFontSize = 28;

  /// Ukubwa wa maandishi ya hadithi kwa kawaida (sp).
  static const double defaultStoryFontSize = 18;

  /// Muda kati ya kurasa wakati wa kusoma kwa sauti (sekunde).
  static const List<int> autoPageTurnDelays = <int>[1, 2, 3, 5];

  /// Muda wa kawaida kati ya kurasa.
  static const int defaultAutoPageTurnDelay = 2;

  /// Urefu wa juu wa neno la Kiswahili — kwa utafutaji wa neno
  /// lililoguswa (tap-to-hear), "ng'ombe" na "nyumbani" huzingatiwa.
  static const int maxSwahiliWordLength = 30;

  // ─────────────────────────────────────────────────────────────
  // Gamification
  // ─────────────────────────────────────────────────────────────

  /// Malengo ya mfululizo (streak) — "Streak ya Wiki" = 7, "ya Mwezi" = 30.
  static const int weeklyStreakGoal = 7;
  static const int monthlyStreakGoal = 30;

  /// Pointi kwa kusoma hadithi moja hadi mwisho.
  static const int pointsPerCompletedStory = 10;

  /// Pointi kwa kuchapisha hadithi moja.
  static const int pointsPerPublishedStory = 100;

  // ─────────────────────────────────────────────────────────────
  // Library & pagination
  // ─────────────────────────────────────────────────────────────

  /// Idadi ya items kwa ukurasa kwenye maktaba (spec §6.4).
  static const int libraryPageSize = 20;

  /// Idadi ya hadithi kwenye "Continue Reading" kwenye home.
  static const int continueReadingLimit = 10;

  /// Idadi ya hadithi kwenye carousel ya "Featured".
  static const int featuredLimit = 8;

  // ─────────────────────────────────────────────────────────────
  // Udhibiti wa mzazi (parental controls) — spec §4.5
  // ─────────────────────────────────────────────────────────────

  /// Urefu wa PIN ya mzazi (tarakimu 4).
  static const int parentalPinLength = 4;

  /// Majaribio ya juu ya PIN kabla ya kufungwa kwa muda.
  ///
  /// PIN ya tarakimu 4 ina mchanganyiko 10,000 tu — bila kikomo, mtoto
  /// anaweza kuijaribu yote kwa dakika chache. Kikomo hiki kinatosha kwa
  /// mzazi halisi (anajua PIN yake) lakini kinazuia utafutaji wa nguvu.
  static const int parentalPinMaxAttempts = 5;

  /// Muda ambao PIN hufungwa baada ya [parentalPinMaxAttempts] kushindwa.
  ///
  /// Dakika 5 inatosha kumvunja moyo mtoto aliyejaribu, lakini ni fupi
  /// kiasi kwamba mzazi asiyekumbuka PIN yake hatasubiri kwa hasira.
  static const Duration parentalPinLockoutDuration = Duration(minutes: 5);

  // ─────────────────────────────────────────────────────────────
  // Animation & timing
  // ─────────────────────────────────────────────────────────────

  /// Muda ambao splash inaonyeshwa kabla ya kuamua pa kwenda.
  static const Duration splashMinimumDuration = Duration(milliseconds: 2200);

  /// Muda wa kuchelewesha kabla ya kuonyesha utafutaji (search debounce).
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Muda wa auto-save ya rasimu (spec §4.3 — draft auto-save).
  static const Duration draftAutoSaveInterval = Duration(seconds: 20);

  /// Muda ambao ujumbe (snackbar) hukaa kwenye skrini.
  static const Duration snackBarDuration = Duration(seconds: 3);

  /// Muda wa kusubiri majaribio ya mtandao (retry) — exponential backoff
  /// huanza na hii.
  static const Duration baseRetryDelay = Duration(seconds: 2);
}

/// Funguo zote za local storage (SharedPreferences / Hive).
///
/// Kuweka funguo hapa kunazuia "typo" na kurahisisha kuhamisha data
/// kwenye matoleo mapya ya app.
abstract final class StorageKeys {
  // ── Mipangilio ya app ────────────────────────────────────────
  static const String onboardingComplete = 'onboarding_complete';
  static const String selectedLanguage = 'selected_language';
  static const String isBilingualMode = 'is_bilingual_mode';
  static const String themeMode = 'theme_mode';
  static const String firstLaunchDate = 'first_launch_date';
  static const String lastActiveDate = 'last_active_date';
  static const String appOpenCount = 'app_open_count';

  // ── Mtumiaji ─────────────────────────────────────────────────
  static const String userId = 'user_id';
  static const String userName = 'user_name';
  static const String userAvatarUrl = 'user_avatar_url';
  static const String userAgeGroup = 'user_age_group';
  static const String userReadingLevel = 'user_reading_level';
  static const String userInterests = 'user_interests';

  // ── Usalama (FlutterSecureStorage) ───────────────────────────
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiry = 'token_expiry';
  static const String parentalPin = 'parental_pin';

  /// Idadi ya majaribio ya PIN yaliyoshindwa mfululizo.
  ///
  /// PIN ya mzazi ni tarakimu 4 tu (10,000 mchanganyiko) — mtoto anaweza
  /// kuijaribu yote kwa dakika chache. Kwa hivyo tunahesabu majaribio
  /// yaliyoshindwa na kufunga kwa muda (tazama `SecureStorage`).
  static const String parentalPinAttempts = 'parental_pin_attempts';

  /// Muda ambao PIN imefungwa baada ya majaribio mengi kushindwa (ISO-8601).
  static const String parentalPinLockedUntil = 'parental_pin_locked_until';

  static const String deviceId = 'device_id';

  // ── Kusoma ───────────────────────────────────────────────────
  static const String readingProgressPrefix = 'reading_progress_';
  static const String bookmarksPrefix = 'bookmarks_';
  static const String favoritesPrefix = 'favorites_';
  static const String readingStreak = 'reading_streak';
  static const String lastReadingDate = 'last_reading_date';
  static const String totalReadingMinutes = 'total_reading_minutes';
  static const String storiesCompletedCount = 'stories_completed_count';

  // ── Mipangilio ya kusoma ─────────────────────────────────────
  static const String storyFontSize = 'story_font_size';
  static const String ttsSpeed = 'tts_speed';
  static const String ttsVoice = 'tts_voice';
  static const String autoPageTurn = 'auto_page_turn';
  static const String autoPageTurnDelay = 'auto_page_turn_delay';
  static const String nightMode = 'night_mode';
  static const String lowDataMode = 'low_data_mode';

  // ── Vifurushi & malipo ───────────────────────────────────────
  static const String activePlanTier = 'active_plan_tier';
  static const String activePlanExpiresAt = 'active_plan_expires_at';
  static const String lastPaymentProvider = 'last_payment_provider';
  static const String cachedPhoneNumber = 'cached_phone_number';

  // ── Watoto ───────────────────────────────────────────────────
  static const String childProfiles = 'child_profiles';
  static const String activeChildId = 'active_child_id';
  static const String screenTimeUsedToday = 'screen_time_used_today';
  static const String screenTimeDate = 'screen_time_date';

  // ── Offline / sync ───────────────────────────────────────────
  static const String downloadedStories = 'downloaded_stories';
  static const String pendingSyncActions = 'pending_sync_actions';
  static const String lastSyncAt = 'last_sync_at';
}

/// Majina ya Hive boxes (local database) — spec §6.3.
abstract final class HiveBoxes {
  /// Hadithi zilizopakuliwa (maandishi + metadata).
  static const String stories = 'stories_box';

  /// Kurasa za hadithi zilizohifadhiwa kwa offline.
  static const String storyPages = 'story_pages_box';

  /// Picha (illustrations) zilizohifadhiwa — path za local.
  static const String illustrations = 'illustrations_box';

  /// Sauti ya TTS iliyotengenezwa tayari (pre-cached).
  static const String audio = 'audio_box';

  /// Maendeleo ya usomaji (reading progress).
  static const String readingProgress = 'reading_progress_box';

  /// Alama za kurasa (bookmarks).
  static const String bookmarks = 'bookmarks_box';

  /// Rasimu za hadithi (creator drafts).
  static const String drafts = 'drafts_box';

  /// Arifa zilizohifadhiwa (notifications) — hifadhi ya ndani ya arifa.
  static const String notifications = 'notifications_box';

  /// Matukio yanayosubiri kusawazishwa (offline queue).
  static const String syncQueue = 'sync_queue_box';

  /// Boxes **zote** — kwa `clearAll()` (kufuta akaunti).
  ///
  /// Orodha hii ipo hapa (na si kwenye `local_storage.dart`) ili kuongeza box
  /// mpya kusiwe kazi ya kukumbuka mahali panne: kila box mpya inaongezwa hapa
  /// mara moja, na `clearAll()` huipata yenyewe. Bila hii, box mpya ingeachwa
  /// na data ya mtumiaji iliyofutwa — jambo baya kwa faragha (spec §11).
  static const List<String> all = <String>[
    stories,
    storyPages,
    illustrations,
    audio,
    readingProgress,
    bookmarks,
    drafts,
    notifications,
    syncQueue,
  ];
}
