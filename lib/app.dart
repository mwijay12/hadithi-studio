/// Mizizi ya app ya Hadithi Studio.
///
/// Faili hili ni **daraja** pekee: hali ya juu (theme, lugha, router) na
/// `MaterialApp.router`. Hakuna biashara (business logic) hapa — hiyo
/// iko kwenye features.
///
/// **Kwa nini `StatefulWidget` na si `StatelessWidget`:** `GoRouter`
/// huhifadhi back-stack. Kuunda router ndani ya `build()` kungeunda
/// router mpya kila `rebuild` — hivyo historia ya urambazaji ingefutwa
/// kila theme au lugha inapobadilika. Tunaiunda mara moja kwenye
/// `initState`.
library;

import 'package:flutter/material.dart';
// `GoRouter` inatajwa hapa (ndani ya `GoRouterConfig`), hivyo import yake
// inahitajika hapa moja kwa moja — si kwa kutegemea `app_routes.dart`.
import 'package:go_router/go_router.dart';

import 'config/routes/app_routes.dart';
import 'config/theme/app_theme.dart';
import 'config/theme/dark_theme.dart';
import 'core/services/theme_controller.dart';
import 'core/utils/snackbar_service.dart';
import 'core/widgets/app_error_boundary.dart';
import 'l10n/app_locale_controller.dart';
import 'l10n/l10n.dart';

/// App nzima.
class HadithiStudioApp extends StatefulWidget {
  const HadithiStudioApp({
    super.key,
    this.initialLocation = AppRoutes.splash,
  });

  /// Pa router inaanzia.
  ///
  /// Kwa app halisi ni [AppRoutes.splash] (ambayo huamua pa kwenda).
  /// Kwenye preview ya web tunaweza kuanza moja kwa moja kwenye shell ili
  /// kuokoa muda wa kusubiri.
  final String initialLocation;

  @override
  State<HadithiStudioApp> createState() => _HadithiStudioAppState();
}

class _HadithiStudioAppState extends State<HadithiStudioApp> {
  late final GoRouterConfig _routerConfig;

  @override
  void initState() {
    super.initState();
    _routerConfig = GoRouterConfig(widget.initialLocation);
  }

  @override
  void dispose() {
    _routerConfig.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `AnimatedBuilder` (inayofanya kazi na `Listenable` yoyote) inasikiliza
    // kidhibiti cha lugha. Mtumiaji anapogusa "Kiswahili"/"Kiingereza"
    // kwenye onboarding, `AppLocaleController` inajulisha, hapa
    // inajengwa upya, na `locale:` mpya inaingia `MaterialApp` — tafsiri
    // zote zinabadilika papo hapo.
    //
    // TANBIHI: router HAIJENGWI upya hapa. `_routerConfig` ilipangwa mara
    // moja kwenye `initState`, kwa hivyo back-stack haifutwi kila
    // lugha inapobadilika.
    return AnimatedBuilder(
      // **Controllers mbili:** lugha NA muonekano. `Listenable.merge` hufanya
      // `MaterialApp` ijengwe upya mabadiliko ya mojawapo yoyote — hivyo
      // kubadilisha lugha au kubadilisha light/dark kunaathari papo hapo.
      animation: Listenable.merge(<Listenable>[
        AppLocaleController.instance,
        ThemeController.instance,
      ]),
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          title: 'Hadithi Studio',
          debugShowCheckedModeBanner: false,

          // Funguo ya kimataifa ya ujumbe. Inahitajika ili kuonyesha kosa
          // kutoka **nje ya** mti wa widget — kwenye interceptor ya mtandao
          // au kwenye `catch` ya async, mahali ambapo hakuna `BuildContext`.
          scaffoldMessengerKey: appMessengerKey,

          // -----------------------------------------------------------------
          // Theme — mwanga na giza
          // -----------------------------------------------------------------
          theme: AppTheme.light,
          darkTheme: DarkTheme.dark,
          // **Chaguo la mtumiaji, sivyo la mfumo pekee:** `ThemeController`
          // huhifadhi Nuru / Giza / Mfumo. Awali ilikuwa `ThemeMode.system`
          // iliyowekwa moja kwa moja — mtumiaji hakuwa na njia ya kubadilisha.
          themeMode: ThemeController.instance.themeMode,

          // -----------------------------------------------------------------
          // Lugha — Kiswahili na Kiingereza
          // -----------------------------------------------------------------
          // `locale:` HII ndiyo inayofanya chaguo la mtumiaji lifanye kazi.
          // Bila yake, Flutter inaamua lugha mara moja kutoka kifaa/browser
          // (`localeResolutionCallback`) na kugusa chipu ya "Kiswahili"
          // hakuna athari yoyote — hiyo ndiyo ilikuwa hitilafu.
          locale: AppLocaleController.instance.locale,
          localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
          supportedLocales: AppLocalizationsSetup.supportedLocales,
          localeResolutionCallback: (
            Locale? locale,
            Iterable<Locale> supported,
          ) {
            // Hutumika mara moja tu, kabla mtumiaji kuchagua. Kama lugha ya
            // simu/browser ni Kiswahili, tunaanza Kiswahili. Vinginevyo
            // tunaangalia Kiingereza. Kama siyo mojawapo, tunatumia fallback
            // (Kiswahili) — app hii ni ya Tanzania kwanza.
            if (locale == null) return AppLocalizationsSetup.fallbackLocale;
            if (locale.languageCode == 'sw') return const Locale('sw');
            if (locale.languageCode == 'en') return const Locale('en');
            return AppLocalizationsSetup.fallbackLocale;
          },

          // -----------------------------------------------------------------
          // Router
          // -----------------------------------------------------------------
          routerConfig: _routerConfig.router,

          // -----------------------------------------------------------------
          // Ukaguzi wa ukubwa wa maandishi
          // -----------------------------------------------------------------
          // Mtumiaji anaweza kuweka "font size" kubwa sana kwenye Android.
          // Bila kikomo, kadi na vitufe vyetu hufurika (overflow) na UI
          // huvunjika. Tunapunguza tu nyongeza kubwa — hatupunguzi maandishi
          // ya mtumiaji chini ya 1.0.
          //
          // TANBIHI: `textScaleFactor` ni API ya Flutter 3.16 na inaonyesha
          // deprecation kwenye matoleo mapya (`TextScaler`). Kwa baseline ya
          // project hii (Dart 3.2 / Flutter 3.16) ni sahihi.
          builder: (BuildContext context, Widget? child) {
            final MediaQueryData media = MediaQuery.of(context);
            final double clamped = media.textScaleFactor.clamp(1.0, 1.3);
            return MediaQuery(
              data: media.copyWith(textScaleFactor: clamped),
              // Ukuta wa makosa huzungukwa HAPA — ndani ya `MaterialApp`
              // (skrini ya kurejesha inahitaji `Theme`, `Directionality` na
              // l10n). Vilevile: `MaterialApp` hairuhusu `builder` mbili, hivyo
              // hii ni mahali pamoja pekee panapofaa.
              child: AppErrorBoundary(
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}

/// Kifuniko chepesi kinachomiliki `GoRouter` ili kusafisha vizuri.
///
/// `GoRouter` ina `dispose()` ambayo inafuta `ChangeNotifier` zake. Kuiacha
/// bila kufutwa ni uvujaji wa kumbukumbu — muhimu kwenye simu za 2GB RAM
/// ambapo app inafunguliwa na kufungwa mara nyingi.
class GoRouterConfig {
  GoRouterConfig(this.initialLocation);

  final String initialLocation;

  late final GoRouter router =
      AppRouter.router(initialLocation: initialLocation);

  void dispose() {
    router.dispose();
  }
}
