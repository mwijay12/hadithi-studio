import 'package:flutter/material.dart';

/// Rangi zote za Hadithi Studio — zimechochewa na Tanzania.
///
/// `abstract final class` inatumika kama "namespace" ili class hii isiweze
/// ku-instantiate au kurithiwa — ina constants tu.
abstract final class AppColors {
  // -------------------------------------------------------------------------
  // PRIMARY — Tanzania landscape
  // -------------------------------------------------------------------------

  /// Serengeti (Safari Green) — rangi kuu ya brand.
  static const Color safariGreen = Color(0xFF2D5016);

  /// Kilimanjaro (mountain sky blue).
  static const Color kilimanjaroBlue = Color(0xFF1B4F72);

  /// Bahari ya Zanzibar (ocean turquoise).
  static const Color zanzibarTurquoise = Color(0xFF17A2B8);

  // -------------------------------------------------------------------------
  // SECONDARY — culture & craft
  // -------------------------------------------------------------------------

  /// Kanga cloth orange.
  static const Color kangaOrange = Color(0xFFE67E22);

  /// Sunset ya Tanzania.
  static const Color sunsetGold = Color(0xFFF39C12);

  /// Viungo vya Zanzibar (spice red).
  static const Color spiceRed = Color(0xFFC0392B);

  /// Udongo wa Afrika (earth brown).
  static const Color earthBrown = Color(0xFF6D4C41);

  // -------------------------------------------------------------------------
  // NEUTRAL
  // -------------------------------------------------------------------------

  static const Color darkText = Color(0xFF1A1A2E);
  static const Color bodyText = Color(0xFF333333);
  static const Color mutedText = Color(0xFF666666);
  static const Color background = Color(0xFFFAFAF8);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE8E8E8);

  // -------------------------------------------------------------------------
  // KIDS — rangi za furaha kwa watoto
  // -------------------------------------------------------------------------

  static const Color playfulYellow = Color(0xFFFFD93D);
  static const Color brightGreen = Color(0xFF4CAF50);
  static const Color skyBlue = Color(0xFF42A5F5);
  static const Color coralPink = Color(0xFFFF6B6B);
  static const Color purpleFun = Color(0xFF9B59B6);

  // -------------------------------------------------------------------------
  // DARK MODE
  // -------------------------------------------------------------------------

  static const Color darkBackground = Color(0xFF12141A);
  static const Color darkSurface = Color(0xFF1C1F27);
  static const Color darkDivider = Color(0xFF2C3040);
  static const Color darkBodyText = Color(0xFFE6E6E6);
  static const Color darkMutedText = Color(0xFF9AA0AE);

  // -------------------------------------------------------------------------
  // SEMANTIC
  // -------------------------------------------------------------------------

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFED6C02);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF0288D1);

  /// Rangi ya highlight ya neno wakati TTS inasoma (karaoke effect).
  static const Color wordHighlight = Color(0xFFFFE082);

  /// Overlay ya mode ya usiku kwenye reader (hupunguza mwanga).
  static const Color nightModeOverlay = Color(0x1A000000);

  // -------------------------------------------------------------------------
  // READER — mandhari ya kusoma
  // -------------------------------------------------------------------------
  //
  // Kwa nini token **mpya** badala ya kutumia zilizopo: `divider` ni
  // `0xFFE8E8E8` — thamani ile ile inayohitajika kwa maandishi ya hali ya
  // usiku. Kuitumia hapa kungeunganisha "mstari mwembamba wa kutenganisha" na
  // "maandishi ya kusoma": siku moja mtu akibadilisha rangi ya mistari,
  // maandishi ya usiku yangebadilika kimakosa. Kwa hivyo kila kusudi lina
  // token yake.

  /// Mandhari ya kusoma mchana — karatasi ya zamani, **si** nyeupe tupu.
  ///
  /// Nyeupe kamili (`cardBackground`) huuma macho ya mtoto anayesoma kwa
  /// muda mrefu jioni.
  static const Color readerBackground = Color(0xFFFFF8F0);

  /// Mandhari ya kusoma usiku — anga la usiku la Tanzania.
  ///
  /// Thamani ni ile ile ya `darkText`, lakini kusudi ni tofauti kabisa
  /// (mandhari ya skrini, si rangi ya maandishi) — hivyo token tofauti.
  static const Color readerNightBackground = Color(0xFF1A1A2E);

  /// Sehemu iliyoinuka kwenye mandhari ya usiku (upau wa TTS, paneli).
  static const Color readerNightSurface = Color(0xFF23233A);

  /// Maandishi ya hadithi kwenye hali ya usiku.
  static const Color readerNightText = Color(0xFFE8E8E8);

  /// Maneno yaliyokwisha somwa (yaliyopita) kwenye hali ya usiku.
  ///
  /// Si meupe kamili: neno lililopita lisivutie macho kuliko neno
  /// linalosomwa sasa — kusudi la karaoke ni kumwonyesha mtoto **pa alipo**.
  static const Color readerNightPastText = Color(0xFFB9BFD4);

  /// Rangi za kadi za makundi — hupangwa kwa mzunguko.
  static const List<Color> categoryAccents = [
    safariGreen,
    kilimanjaroBlue,
    zanzibarTurquoise,
    kangaOrange,
    sunsetGold,
    spiceRed,
    earthBrown,
    purpleFun,
    brightGreen,
    skyBlue,
    coralPink,
    playfulYellow,
  ];

  /// Gradient ya splash screen (asubuhi ya Tanzania).
  static const List<Color> sunsetGradient = [
    safariGreen,
    kilimanjaroBlue,
    zanzibarTurquoise,
  ];

  /// Gradients za slides za onboarding.
  static const List<List<Color>> onboardingGradients = [
    [Color(0xFF1B4F72), Color(0xFF17A2B8)],
    [Color(0xFF2D5016), Color(0xFF4CAF50)],
    [Color(0xFFE67E22), Color(0xFFFFD93D)],
    [Color(0xFF6D4C41), Color(0xFFC0392B)],
    [Color(0xFF9B59B6), Color(0xFF42A5F5)],
  ];
}

/// Rangi za tanzu (tanzu = brand) zisizobadilika kwa theme.
///
/// Hizi hutumika pale ambapo rangi lazima ibaki sawa kwenye light na dark
/// mode — mfano nembo (logo) na background ya splash.
abstract final class BrandColors {
  static const Color logoPrimary = AppColors.safariGreen;
  static const Color logoAccent = AppColors.sunsetGold;
  static const Color splashBackground = Color(0xFF0E2A12);
  static const Color splashForeground = Color(0xFFF6F3E7);
}
