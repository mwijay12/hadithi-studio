import 'package:flutter/material.dart';

/// Vipimo (spacing), radii na durations — hutumika badala ya "magic numbers".
abstract final class AppSpacing {
  // Spacing scale
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  // Padding za kawaida
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets screenVertical =
      EdgeInsets.symmetric(vertical: lg, horizontal: xxl);
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets chip = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  // Radius
  static const double radiusXs = 6;
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusPill = 999;

  static const BorderRadius borderRadiusSm =
      BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd =
      BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg =
      BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusPill =
      BorderRadius.all(Radius.circular(radiusPill));

  // Vipimo vya widgets
  static const double buttonHeight = 52;
  static const double buttonHeightSmall = 40;
  static const double inputHeight = 56;
  static const double appBarHeight = 60;
  static const double bottomNavHeight = 68;
  static const double iconSm = 18;
  static const double iconMd = 24;
  static const double iconLg = 32;
  static const double iconXl = 48;
  static const double avatarSm = 32;
  static const double avatarMd = 48;
  static const double avatarLg = 72;

  // Touch target ndogo inayoruhusiwa (accessibility).
  static const double minTouchTarget = 48;

  // ---------------------------------------------------------------------------
  // READER — skrini ya kusoma haina `AppBar` ya kawaida; ina mipau inayoelea
  // juu ya mchoro. Vipimo vyake ni vikubwa kuliko vya UI ya kawaida kwa sababu
  // mtumiaji ni mtoto anayeshika simu kwa mkono mmoja.
  // ---------------------------------------------------------------------------

  /// Urefu wa upau wa juu (kufunga, jina, mipangilio, menyu).
  static const double readerTopBarHeight = 80;

  /// Urefu wa safu kuu ya upau wa sauti (cheza, rudi, mbele).
  ///
  /// Upau mzima ni mrefu kuliko hii: juu yake kuna kielekezi cha maendeleo na
  /// chini yake safu ya pili (kasi, sauti, alama).
  static const double ttsMainRowHeight = 80;

  /// Kipenyo cha kitufe kikuu cha cheza/simamisha.
  static const double playButtonSize = 56;

  /// Kipenyo cha ikoni ndani ya kitufe kikuu cha cheza.
  static const double playIconSize = 32;

  /// Upana wa paneli ya mipangilio kwenye skrini kubwa.
  static const double settingsPanelWidth = 300;

  /// Upana wa paneli ya mipangilio kwenye simu — asilimia ya skrini.
  static const double settingsPanelWidthRatio = 0.80;

  /// Radius ya juu ya safu ya maandishi / paneli inayopanda kutoka chini.
  static const double readerOverlayRadius = 20;

  /// Radius ya mandhari ya neno linalosomwa (highlight ya karaoke).
  static const double highlightRadius = 4;

  /// Urefu wa juu wa safu ya maandishi — asilimia ya skrini.
  ///
  /// Maandishi marefu yanasogezwa (scrollable); bila kikomo haya yangeifunika
  /// picha yote na mtoto asingeliona simba anayeongea.
  /// Urefu wa juu wa kifuniko cha maandishi, kwa uwiano wa urefu wa skrini.
  ///
  /// **Kwa nini 0.52, sivyo 0.40:** kifuniko hiki sasa kinatenga **148 px**
  /// chini kwa upau wa sauti na chips. Kwa 0.40 kwenye simu ya 780 px,
  /// kilichobaki kwa maandishi ni 132 px — mistari mitatu pekee, kisha
  /// maandishi huanza kuskroli. 0.52 hurejesha nafasi ya mistari 7–8 huku
  /// scrim yenye vituo vitatu ikiendelea kuacha picha ionekane juu.
  static const double textOverlayMaxHeightRatio = 0.52;

  // Animation durations
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTurn = Duration(milliseconds: 450);
  static const Duration splash = Duration(milliseconds: 2200);

  /// Muda kati ya kurasa wakati wa auto page turn kwenye read-along mode.
  ///
  /// Huu ni **chaguo la msingi** pekee; mtumiaji anaweza kuchagua 1/2/3/5
  /// sekunde kwenye paneli ya mipangilio, na thamani halisi hutoka
  /// `ReaderState.autoTurnDelay`. Token hii inabaki kama kumbukumbu ya
  /// chaguo la msingi (chanzo kimoja cha ukweli kwa "sekunde 2").
  static const Duration autoPageTurnDelay = Duration(seconds: 2);

  // ---------------------------------------------------------------------------
  // READER — durations
  // ---------------------------------------------------------------------------

  /// Muda wa kubadilisha ukurasa kwenye reader.
  ///
  /// Tofauti na [pageTurn] (450ms) ambayo hutumika kwenye mabadiliko ya jumla,
  /// hii ni ya reader pekee: 400ms ni ya haraka vya kutosha kuhisi "pap!" lakini
  /// ya polepole vya kutosha kwa mtoto kufuata mchoro unaobadilika.
  static const Duration readerPageTurn = Duration(milliseconds: 400);

  /// Muda wa paneli ya mipangilio kuingia na kutoka.
  static const Duration settingsPanel = Duration(milliseconds: 300);

  /// Muda ambao "bubble" ya mazungumzo hubaki kabla ya kujificha.
  static const Duration speechBubble = Duration(seconds: 4);

  /// Mzunguko mmoja wa mdundo (pulse) wa alama ya kugusa.
  static const Duration hotspotPulse = Duration(seconds: 2);

  /// Muda ambao ikoni ya spika huonekana baada ya kugusa neno.
  static const Duration wordTapFeedback = Duration(milliseconds: 1200);
}

/// Breakpoints kwa responsive layout (simu ndogo → tablet).
///
/// Hii ni **chanzo kimoja cha ukweli** kwa mipaka ya ukubwa wa skrini.
/// `ContextX` (`core/extensions/context_extensions.dart`) huita kanuni zilizo
/// hapa chini — kwa hivyo hakuna mahali pengine panapoweza kupotosha kizingiti.
/// Awali `AppBreakpoints` na `ContextX` zilikuwa na mipaka inayotofautiana
/// (600 dhidi ya 900 kwa "tablet", safu 2/3/4/6 dhidi ya 2/3/4) — hilo
/// lilisababisha layout tofauti kwa skrini ile ile.
///
/// **MUHIMU wa matoleo:** tunatumia `MediaQuery.of(context)`, SI
/// `MediaQuery.sizeOf(context)` wala `MediaQuery.paddingOf(context)`.
/// `sizeOf` na `paddingOf` ziliongezwa baada ya Flutter 3.2, wakati mradi huu
/// umejikita kwenye Flutter 3.2 (tazama ufafanuzi kamili kwenye
/// `context_extensions.dart`). Kutumia `sizeOf` hapa kunavunja build kwenye
/// toolchain ya msingi yetu.
abstract final class AppBreakpoints {
  static const double smallPhone = 360;
  static const double phone = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  // ---------------------------------------------------------------------------
  // Kanuni safi (pure) — huchukua **upana**, si `BuildContext`
  // ---------------------------------------------------------------------------
  //
  // Hizi zinaweza kuitwa kutoka `initState`, `LayoutBuilder` au test bila
  // `BuildContext`. Kila kitu kingine kwenye class hii kinajengwa juu yao,
  // ili kizingiti kiwe mahali pamoja.

  /// Simu ndogo sana (Tecno/Itel za 5.0") — tunapunguza padding.
  static bool isCompactWidth(double width) => width < smallPhone;

  /// Simu kubwa, au tablet ndogo kwenye mkao wa mlalo (600dp na juu).
  ///
  /// TANBIHI: hii **si** kizingiti cha tablet — kwa hilo tumia
  /// [isTabletWidth]. Ipo kwa maamuzi ya layout pekee (mfano kubadilisha
  /// `BottomNavigationBar` kuwa `NavigationRail`).
  static bool isWideWidth(double width) => width >= phone;

  /// Kifaa cha tablet (900dp na juu).
  static bool isTabletWidth(double width) => width >= tablet;

  /// Desktop / web (1200dp na juu).
  static bool isDesktopWidth(double width) => width >= desktop;

  /// Idadi ya safu (columns) kwenye grid kulingana na upana.
  ///
  /// 2 kwenye simu, 3 kwenye tablet wima, 4 kwenye tablet mlalo, 5 kwenye
  /// desktop/web. Kadi za hadithi zinahitaji upana wa kutosha kwa kifuniko
  /// pamoja na jina; safu 6 zingeunda kadi nyembamba zisizosomeka kwenye
  /// Tecno ya 5.5" / 2GB RAM (hapo tunabaki 2).
  ///
  /// **Kwa nini hatua ya 5 ipo hapa na si kwenye ukurasa:** gridi ya hadithi
  /// inaonekana Maktaba, rafu na utafutaji. Kila ukurasa kuhesabu safu zake
  /// kungezalisha idadi tofauti kwa upana ule ule — hitilafu ile ile
  /// iliyorekodiwa juu ya faili hili. Kwa hivyo hatua ya desktop ilipanuliwa
  /// **hapa**, mahali pamoja, na `ContextX.gridColumns` inaifuata.
  static int gridColumnsFor(double width) {
    if (isDesktopWidth(width)) return 5;
    if (isTabletWidth(width)) return 4;
    if (isWideWidth(width)) return 3;
    return 2;
  }

  // ---------------------------------------------------------------------------
  // Vifuniko vya `BuildContext` (convenience — hutumia kanuni zilizo juu)
  // ---------------------------------------------------------------------------

  /// Simu ndogo sana (chini ya 360dp).
  static bool isCompact(BuildContext context) =>
      isCompactWidth(MediaQuery.of(context).size.width);

  /// Kifaa cha tablet (900dp na juu).
  static bool isTablet(BuildContext context) =>
      isTabletWidth(MediaQuery.of(context).size.width);

  /// Desktop / web (1200dp na juu).
  static bool isDesktop(BuildContext context) =>
      isDesktopWidth(MediaQuery.of(context).size.width);

  /// Idadi ya safu kwenye grid kulingana na upana wa skrini.
  static int gridColumns(BuildContext context) =>
      gridColumnsFor(MediaQuery.of(context).size.width);
}
