/// Ujenzi wa layout unaobadilika kulingana na ukubwa wa nafasi iliyopo.
///
/// ## Kwa nini faili hili lipo
///
/// Tanzania ina simu za aina nyingi: Tecno/Itel za 5.0" (360dp au chini) hadi
/// tablets za shule (900dp+). Kila skrini yetu lazima isomeke vizuri kwenye
/// zote — na hadithi ya watoto inasomeka vibaya sana kama mstari ni mrefu
/// kupita kiasi. Badala ya kila ukurasa kuandika `if (width < 360) ...`,
/// tunaweka vifaa vinne hapa:
///
/// 1. [AppDeviceType] — aina ya kifaa (simu ndogo → desktop).
/// 2. [AppDeviceInfo] — vipimo halisi vya kifaa hicho (`gridColumns`,
///    `contentPadding`, `maxContentWidth`).
/// 3. [AppResponsiveBuilder] — hutoa [AppDeviceInfo] kwa `builder` yako.
/// 4. [AppResponsiveValue] — huchagua thamani moja kwa kila aina ya kifaa.
///
/// ## Chanzo kimoja cha ukweli
///
/// Mipaka yote (360/600/900/1200) ipo kwenye `AppBreakpoints` pekee
/// (`config/theme/spacing.dart`). Faili hili **haliandiki** namba yoyote ya
/// kizingiti; linaita `AppBreakpoints`, kama `ContextX` inavyofanya. Hii
/// inazuia hitilafu iliyotokea awali: `AppBreakpoints` na `ContextX`
/// zilikuwa na mipaka inayotofautiana (600 dhidi ya 900 kwa "tablet") kwa
/// skrini ile ile.
///
/// ## `LayoutBuilder`, si `MediaQuery` — tofauti ni muhimu
///
/// [AppResponsiveBuilder] hupima **sanduku analopewa** (`LayoutBuilder`), si
/// dirisha la simu. Kwenye `Scaffold` ya kawaida vyote viwili ni sawa,
/// lakini kwenye `BottomSheet`, panel ya pembeni, au sehemu yenye padding
/// kubwa, upana halisi wa maudhui ni mdogo. Maamuzi ya layout (safu ngapi?
/// padding ipi?) yanahitaji upana wa sanduku.
///
/// Kwa upana wa **kifaa/dirisha** (mfano kuamua `NavigationRail` dhidi ya
/// `BottomNavigationBar`) tumia `context.isCompact`, `context.isTablet` au
/// `context.screenWidth` kutoka `core/extensions/context_extensions.dart`.
///
/// ## Matoleo (Flutter 3.2 baseline)
///
/// Hatutumii `MediaQuery.sizeOf`/`MediaQuery.paddingOf` — ziliongezwa baadaye
/// kabisa. Tunatumia `MediaQuery.of(context)`, na
/// `MediaQueryData.textScaleFactor` badala ya `TextScaler`, kama
/// `context_extensions.dart` inavyoeleza.
library;

import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';

// -----------------------------------------------------------------------------
// Mipaka ya maudhui (content width caps)
// -----------------------------------------------------------------------------
//
// Namba hizi ni "hesabu za muundo" (design numbers), si biashara: zinaamua
// urefu wa mstari wa maandishi. Kwa maandishi ya Kiswahili ya watoto, mstari
// mrefu kupita 80–90 herufi hufanya macho yaruke. Tunazipa majina hapa chini
// badala ya kuziacha kama namba tupu kwenye code.
//
// TANBIHI: kama widget nyingine ikihitaji kikomo cha upana, hizi zihamie
// `AppSpacing` — ili chanzo kimoja cha ukweli kama ilivyo kwa `AppBreakpoints`.

/// Kikomo cha upana kwa simu kubwa / tablet ndogo (mlalo).
const double _maxContentLargePhone = 640;

/// Kikomo cha upana kwa tablet — shule na madarasa.
const double _maxContentTablet = 720;

/// Kikomo cha upana kwa desktop/web (chanzo cha mradi, dashibodi).
const double _maxContentDesktop = 840;

/// Urefu wa chini wa skrini unaotosha kuonyesha ukurasa wa hadithi pamoja na
/// vitufe vyake. Chini ya hapo (simu kwenye mkao wa mlalo) tunapunguza
/// picha na kuweka vitufe kando, si chini.
const double _minHeightForFullPage = 640;

/// Nyongeza ya font iliyoanza kuvunja layout (mtumiaji ameweka "kubwa sana").
const double _largeTextScale = 1.3;

/// Aina ya kifaa kulingana na upana wa nafasi iliyopo.
///
/// Mgawanyo huu unafuata `AppBreakpoints` **kikamilifu** na kwa mpangilio:
/// kila upana unaingia kwenye kundi moja tu, bila mwanya. [largePhone]
/// (600–899dp) ipo kwa sababu kizingiti cha `AppBreakpoints.isWideWidth`
/// (600dp) ni cha **maamuzi ya layout** (mfano kubadilisha bottom navigation
/// kuwa navigation rail), wakati kizingiti cha tablet (900dp) ni cha ukubwa
/// wa kifaa. Kuchanganya hivyo viwili ndiko kulikoleta hitilafu ya awali.
enum AppDeviceType {
  /// Simu ndogo sana (chini ya 360dp) — Tecno/Itel za 5.0". Tunapunguza
  /// padding na kutumia font ndogo.
  compactPhone,

  /// Simu ya kawaida (360dp – 599dp) — aina nyingi za simu Tanzania.
  phone,

  /// Simu kubwa, au tablet ndogo kwenye mkao wa mlalo (600dp – 899dp).
  largePhone,

  /// Tablet (900dp – 1199dp) — shule, madarasa, dashibodi ya mwalimu.
  tablet,

  /// Desktop / web (1200dp na juu).
  desktop;

  /// Aina ya kifaa kwa upana fulani.
  ///
  /// Hii ndiyo mahali **pekee** panapogeuza upana kuwa [AppDeviceType];
  /// kanuni zote zinatoka `AppBreakpoints`.
  static AppDeviceType typeForWidth(double width) {
    if (AppBreakpoints.isDesktopWidth(width)) return AppDeviceType.desktop;
    if (AppBreakpoints.isTabletWidth(width)) return AppDeviceType.tablet;
    if (AppBreakpoints.isWideWidth(width)) return AppDeviceType.largePhone;
    if (AppBreakpoints.isCompactWidth(width)) return AppDeviceType.compactPhone;
    return AppDeviceType.phone;
  }

  /// `true` kwa simu ndogo sana (chini ya 360dp).
  bool get isCompactPhone => this == AppDeviceType.compactPhone;

  /// `true` kwa simu ya kawaida (360dp – 599dp).
  bool get isPhone => this == AppDeviceType.phone;

  /// `true` kwa simu kubwa / tablet ndogo (600dp – 899dp).
  bool get isLargePhone => this == AppDeviceType.largePhone;

  /// `true` kwa tablet (900dp – 1199dp).
  bool get isTablet => this == AppDeviceType.tablet;

  /// `true` kwa desktop / web (1200dp na juu).
  bool get isDesktop => this == AppDeviceType.desktop;

  /// `true` kwa kifaa chochote cha mkononi — [compactPhone], [phone] au
  /// [largePhone], yaani chochote chini ya kizingiti cha tablet (900dp).
  ///
  /// Hutumika kuamua kama tunatumia `BottomNavigationBar` (mkononi) au
  /// `NavigationRail` (tablet/desktop). Kumbuka: enum `index` hufuata
  /// mpangilio wa kutangaza juu, kwa hivyo mabadiliko ya mpangilio hubadilisha
  /// maana ya getter hii — ndiyo sababu ipo hapa karibu na tangazo.
  bool get isHandset => index <= AppDeviceType.largePhone.index;

  /// `true` kama tuna nafasi ya kutosha kwa layout ya panel mbili (orodha
  /// kushoto, maudhui kulia) — Reader inatumia hii kwenye tablet.
  bool get supportsTwoPane => index >= AppDeviceType.largePhone.index;
}

/// Vipimo vilivyopimwa vya kifaa/nafasi moja.
///
/// Hii ni class `const`-constructible na fields zote ni `final`, kwa hivyo
/// ni salama kuisambaza kwenye widgets bila kuogopa mabadiliko ya ghafla.
class AppDeviceInfo {
  const AppDeviceInfo({
    required this.width,
    required this.height,
    required this.orientation,
    required this.deviceType,
    required this.textScaleFactor,
  });

  /// Hupima [size] na kujaza kila kitu kingine.
  ///
  /// [textScaleFactor] inapaswa kutoka
  /// `MediaQuery.of(context).textScaleFactor` (Flutter 3.2: `TextScaler` haipo).
  factory AppDeviceInfo.fromSize(Size size, {double textScaleFactor = 1.0}) {
    return AppDeviceInfo(
      width: size.width,
      height: size.height,
      orientation: size.width > size.height
          ? Orientation.landscape
          : Orientation.portrait,
      deviceType: AppDeviceType.typeForWidth(size.width),
      textScaleFactor: textScaleFactor,
    );
  }

  /// Upana wa nafasi iliyopo (dp).
  final double width;

  /// Urefu wa nafasi iliyopo (dp).
  final double height;

  /// Mwelekeo — Reader hubadilisha layout kwa huu (ukurasa mmoja dhidi ya
  /// kurasa mbili kwa pamoja).
  final Orientation orientation;

  /// Aina ya kifaa kwa [width].
  final AppDeviceType deviceType;

  /// Kipimo cha font kilichowekwa na mtumiaji.
  final double textScaleFactor;

  /// `true` kama nafasi ni pana kuliko ilivyo refu.
  bool get isLandscape => orientation == Orientation.landscape;

  /// `true` kama nafasi ni refu kuliko ilivyo pana.
  bool get isPortrait => orientation == Orientation.portrait;

  /// `true` kama kuna nafasi ya kutosha kwa ukurasa kamili wa hadithi.
  ///
  /// Simu kwenye mkao wa mlalo haina nafasi ya kutosha kwa picha **na**
  /// vitufe chini yake; hapo tunapunguza picha na kuweka vitufe kando.
  bool get hasRoomForFullPage => height >= _minHeightForFullPage;

  /// `true` kama mtumiaji ameweka font kubwa kiasi cha kuvunja layout.
  ///
  /// Hii ni hali ya kweli kwa wazee wanaosoma pamoja na wajukuu, na ni
  /// mahitaji ya ufikiaji (accessibility) — hatuipuuzi.
  bool get hasLargeText => textScaleFactor > _largeTextScale;

  /// Safu za grid (kadi za hadithi) — 2 kwenye simu, 3 kwenye tablet,
  /// 4 kwenye desktop.
  ///
  /// Kanuni ipo `AppBreakpoints.gridColumnsFor` pekee.
  int get gridColumns => AppBreakpoints.gridColumnsFor(width);

  /// Padding ya pembeni kwa maudhui ya ukurasa.
  ///
  /// Simu ndogo hupata padding ndogo (`lg` = 16) ili maandishi yasibane;
  /// skrini kubwa hupata zaidi ili mstari usiwe mrefu.
  EdgeInsets get contentPadding {
    switch (deviceType) {
      case AppDeviceType.compactPhone:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
      case AppDeviceType.phone:
        return AppSpacing.screen;
      case AppDeviceType.largePhone:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl);
      case AppDeviceType.tablet:
      case AppDeviceType.desktop:
        return const EdgeInsets.symmetric(horizontal: AppSpacing.huge);
    }
  }

  /// Kikomo cha upana wa maudhui, au `double.infinity` kama hakuna kikomo.
  ///
  /// Simu hazipati kikomo (upana wenyewe ni mdogo); skrini kubwa zinapata
  /// kikomo ili mstari wa hadithi usiwe mrefu. Tumia pamoja na
  /// [AppMaxContentWidth].
  double get maxContentWidth {
    switch (deviceType) {
      case AppDeviceType.compactPhone:
      case AppDeviceType.phone:
        return double.infinity;
      case AppDeviceType.largePhone:
        return _maxContentLargePhone;
      case AppDeviceType.tablet:
        return _maxContentTablet;
      case AppDeviceType.desktop:
        return _maxContentDesktop;
    }
  }

  @override
  String toString() {
    return 'AppDeviceInfo($deviceType, ${width.toStringAsFixed(0)}x'
        '${height.toStringAsFixed(0)}, $orientation, textScale: '
        '$textScaleFactor)';
  }
}

/// Kazi inayojenga widget kutokana na [AppDeviceInfo].
typedef AppResponsiveWidgetBuilder = Widget Function(
  BuildContext context,
  AppDeviceInfo info,
);

/// Hupima nafasi iliyopo na kuiwasilisha kwa `builder` kama [AppDeviceInfo].
///
/// Matumizi:
/// ```dart
/// AppResponsiveBuilder(
///   builder: (context, info) {
///     final columns = info.gridColumns;
///     final padding = info.contentPadding;
///     return GridView.builder(
///       padding: padding,
///       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
///         crossAxisCount: columns,
///         childAspectRatio: 0.68,
///       ),
///       itemCount: stories.length,
///       itemBuilder: (context, i) => StoryCard(story: stories[i]),
///     );
///   },
/// )
/// ```
///
/// TAZAMA tofauti iliyoelezwa juu ya faili: hii hupima **sanduku**, si
/// dirisha.
class AppResponsiveBuilder extends StatelessWidget {
  const AppResponsiveBuilder({
    super.key,
    required this.builder,
    this.fallbackSize,
  });

  /// Hujenga widget kwa vipimo vilivyopimwa.
  final AppResponsiveWidgetBuilder builder;

  /// Vipimo vya kutumia kama nafasi haina kikomo (mfano ndani ya `Column`
  /// yenye urefu usio na kikomo, au `ListView` ya mlalo).
  ///
  /// Bila hii tunarudi kwenye ukubwa wa dirisha (`MediaQuery`) — chaguo salama
  /// kuliko kupasua kwa `double.infinity`.
  final Size? fallbackSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // `MediaQuery.of`, si `MediaQuery.sizeOf` — Flutter 3.2 baseline.
        final media = MediaQuery.of(context);
        final fallback = fallbackSize ?? media.size;

        // `maxWidth`/`maxHeight` zinaweza kuwa `infinity` (mfano ndani ya
        // `SingleChildScrollView` kwa urefu, au `Row` kwa upana). Kwenye hali
        // hiyo hatuwezi kupima — tunatumia ukubwa wa dirisha.
        final size = Size(
          constraints.hasBoundedWidth ? constraints.maxWidth : fallback.width,
          constraints.hasBoundedHeight
              ? constraints.maxHeight
              : fallback.height,
        );

        return builder(
          context,
          AppDeviceInfo.fromSize(
            size,
            textScaleFactor: media.textScaler.scale(1.0),
          ),
        );
      },
    );
  }
}

/// Huchagua thamani moja kwa kila [AppDeviceType].
///
/// Ni `const`-constructible, kwa hivyo inaweza kutumika kwenye fields za
/// widget za `const`:
///
/// ```dart
/// static const _columns = AppResponsiveValue<int>(
///   compactPhone: 2,
///   tablet: 3,
///   desktop: 4,
/// );
/// // baadaye:
/// final columns = _columns.resolve(info.deviceType);
/// ```
///
/// ## Kanuni ya kurudi nyuma (fallback)
///
/// Skrini ndogo **hailazimiki** kupewa thamani ya kila kundi. Thamani
/// isiyotolewa inarudi kwenye kundi lililo ndogo kuliko yenyewe:
/// `desktop → tablet → largePhone → phone → compactPhone`. Hivyo
/// [compactPhone] ndiyo ya lazima (ndiyo msingi), na `tablet`/`desktop` ni
/// nyongeza tu. Hii inaepusha `null` kwenye use sites na hufanya muundo
/// usomeke kama "simu ni msingi, kubwa ni nyongeza" — jinsi tunavyofikiri
/// kuhusu soko letu.
class AppResponsiveValue<T> {
  const AppResponsiveValue({
    required this.compactPhone,
    this.phone,
    this.largePhone,
    this.tablet,
    this.desktop,
  });

  /// Thamani ya msingi — inatumika kwa kila kundi lisilo na thamani yake.
  final T compactPhone;

  /// Thamani ya simu ya kawaida (360dp – 599dp).
  final T? phone;

  /// Thamani ya simu kubwa / tablet ndogo (600dp – 899dp).
  final T? largePhone;

  /// Thamani ya tablet (900dp – 1199dp).
  final T? tablet;

  /// Thamani ya desktop / web (1200dp na juu).
  final T? desktop;

  /// Thamani ya [type], ikirudi nyuma kwa kanuni iliyoelezwa juu ya class.
  T resolve(AppDeviceType type) {
    switch (type) {
      case AppDeviceType.compactPhone:
        return compactPhone;
      case AppDeviceType.phone:
        return phone ?? compactPhone;
      case AppDeviceType.largePhone:
        return largePhone ?? phone ?? compactPhone;
      case AppDeviceType.tablet:
        return tablet ?? largePhone ?? phone ?? compactPhone;
      case AppDeviceType.desktop:
        return desktop ?? tablet ?? largePhone ?? phone ?? compactPhone;
    }
  }
}

/// Huzuia maudhui kuwa mapana kupita kiasi kwa kuyaweka katikati.
///
/// Kwenye simu hii haifanyi kitu (upana wa skrini tayari ni mdogo). Kwenye
/// tablet na desktop inaepusha mstari wa hadithi kuwa mrefu kupita kiasi —
/// jambo linaloharibu usomaji wa watoto.
///
/// Matumizi (Reader na ukurasa wa hadithi):
/// ```dart
/// Scaffold(
///   body: AppMaxContentWidth(
///     child: SingleChildScrollView(child: storyBody),
///   ),
/// )
/// ```
class AppMaxContentWidth extends StatelessWidget {
  const AppMaxContentWidth({
    super.key,
    required this.child,
    this.maxWidth,
    this.alignment = Alignment.topCenter,
  });

  /// Maudhui yanayozuiliwa upana.
  final Widget child;

  /// Kikomo cha upana. Bila hii, kikomo hutokana na aina ya kifaa
  /// ([AppDeviceInfo.maxContentWidth]).
  final double? maxWidth;

  /// Mahali pa kuweka maudhui (kawaida juu-katikati).
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final fixed = maxWidth;
    if (fixed != null) return _cap(fixed);

    // Kikomo hutegemea upana, kwa hivyo tunahitaji kipimo — lakini
    // `AppResponsiveBuilder` hutuia `AppDeviceInfo`, kwa hivyo hatupimi mara
    // mbili kwa njia tofauti.
    return AppResponsiveBuilder(
      builder: (context, info) {
        final cap = info.maxContentWidth;
        // `double.infinity` hapa haimaanishi "bila kikomo" kwenye
        // `BoxConstraints` (inamaanisha "pana kadri inavyowezekana"), kwa
        // hivyo tunaruka kuifunga kabisa kwenye simu.
        if (!cap.isFinite) return child;
        return _cap(cap);
      },
    );
  }

  Widget _cap(double cap) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: cap),
        child: child,
      ),
    );
  }
}
