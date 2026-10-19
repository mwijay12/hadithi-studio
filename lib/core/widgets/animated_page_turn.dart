import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Kugeuza ukurasa kwa mtindo wa kitabu (page turn) kwa hadithi zenye picha.
///
/// ## Kwa nini widget hii ipo
///
/// `PageView` ya Flutter husogeza kurasa kwa mstari wa moja kwa moja (slide).
/// Kwa app ya hadithi hiyo inahisi kama orodha ya picha, si kitabu. Mtoto
/// anayeona ukurasa unapita kwa mstari anapoteza hisia ya "ukurasa
/// umepinduliwa" — na hisia hiyo ndiyo inayomfanya atake kuendelea kusoma.
///
/// ## Kwa nini si `Transform` kamili ya 90° (kitabu halisi)
///
/// Kugeuza ukurasa kwa 90° kunahitaji kuonyesha **upande wa nyuma** wa
/// ukurasa — safu ya picha ya tatu kwa kila ukurasa wakati wa kusogeza.
/// Kwenye Tecno/Itel ya 2GB RAM hiyo inasababisha `jank` inayoonekana, na
/// inavunja kabisa ukurasa mfupi (ukurasa wa maneno mawili ungeonekana kama
/// karatasi ya bure). Badala yake tunatumia mzunguko mdogo wa 3D (`maxAngle`)
/// pamoja na kupungua kwa ukubwa — hisia ni ile ile, gharama ni ndogo.
///
/// ## Vipimo vya utendaji
///
/// * **Matrix4 moja kwa kila ukurasa**, si `saveLayer`: hakuna `Opacity`
///   yenye thamani chini ya 1, kwa sababu hiyo inalazimisha Flutter kutunga
///   safu nzima ya ukurasa kila frame.
/// * **Kivuli hakiongezwi**: `BoxShadow` kwenye ukurasa unaosogea ni gharama
///   ya kuchora inayorudiwa kila frame.
///
/// ## Kusogeza kwa mikono
///
/// Widget hii **haisikilizi** kwa `onPageChanged`; hiyo ni kazi ya
/// [AppPageTurnView] (`PageView.onPageChanged`) au ya `PageController` yako.
/// Hii inaepusha kila ukurasa kuwa na `State` yake.
///
/// Matumizi (ndani ya `PageView.builder`):
/// ```dart
/// PageView.builder(
///   controller: controller,
///   itemCount: pages.length,
///   itemBuilder: (context, index) => AppPageTurn(
///     controller: controller,
///     index: index,
///     child: StoryPageView(page: pages[index]),
///   ),
/// )
/// ```
class AppPageTurn extends StatelessWidget {
  const AppPageTurn({
    super.key,
    required this.controller,
    required this.index,
    required this.child,
    this.maxAngle = 0.35,
    this.minScale = 0.92,
    this.perspective = 0.001,
  });

  /// `PageController` inayoendesha `PageView` ya mzazi.
  ///
  /// Inahitajika ili kujua mtumiaji amesogeza kiasi gani — `PageView` haitoi
  /// thamani hiyo kwa watoto wake.
  final PageController controller;

  /// Nafasi ya ukurasa huu kwenye `PageView`.
  final int index;

  final Widget child;

  /// Mzunguko wa juu kwa radiani (`0.35` ≈ 20°).
  ///
  /// Zaidi ya `0.5` (≈ 29°) ukurasa unaanza kuonekana "umepinda" badala ya
  /// "umegeuzwa", na kwenye skrini ndogo unapunguza nafasi ya maandishi.
  final double maxAngle;

  /// Ukubwa wa chini kabisa wakati ukurasa umesogea kikamilifu.
  ///
  /// Kwenye simu ndogo (360dp) usipunguze chini ya `0.9`: ukurasa unaopungua
  /// sana unafanya maandishi kuwa madogo kwa muda — mtoto anayesoma
  /// anaangalia herufi, si picha.
  final double minScale;

  /// Nguvu ya mtazamo wa 3D. `0` = mzunguko wa gorofa (bila kina).
  final double perspective;

  @override
  Widget build(BuildContext context) {
    // Accessibility: mtumiaji aliyeweka "reduce motion" kwenye simu — na
    // hilo ni la kawaida kwa watu wenye `vestibular disorders` — hapaswi
    // kuona mzunguko wa 3D. Tunatoa ukurasa tuli bila mzunguko.
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        // `controller.page` ni `null` kabla ya layout ya kwanza; tunatumia
        // `initialPage` badala ya kuruka kwenye kosa la `!` kwenye `null`.
        final double current = controller.hasClients
            ? (controller.page ?? controller.initialPage.toDouble())
            : controller.initialPage.toDouble();

        // `clamp` kwa ±1: ukurasa wa mbali hauhitaji mzunguko mkubwa kuliko
        // ule wa ukurasa unaofuata — zaidi ya hapo ni gharama bure.
        final double delta = (current - index).clamp(-1.0, 1.0);
        final double t = delta.abs();

        if (reduceMotion || t == 0) return child!;

        final double angle = delta * maxAngle;
        final double scale = 1 - (t * (1 - minScale));

        var transform = Matrix4.identity();
        if (perspective != 0) {
          // `setEntry(3, 2, …)` inaongeza kina cha mtazamo; bila hii,
          // mzunguko unaonekana kama kubana (squash) badala ya kugeuza.
          transform = transform..setEntry(3, 2, perspective);
        }

        return Transform(
          alignment: Alignment.centerLeft,
          transform: transform
            ..rotateY(angle)
            ..scale(math.max(scale, 0.1)),
          child: child,
        );
      },
      // `child` hupitishwa nje ya builder ili picha na maandishi ya ukurasa
      // **yasijengwe upya** kila frame wakati wa kusogeza.
      child: child,
    );
  }
}

/// `PageView` iliyoandaliwa kwa kugeuza kurasa kwa mtindo wa kitabu.
///
/// Inaunganisha [AppPageTurn] kwenye kila ukurasa, ili kila ukurasa wa
/// hadithi usirudie wito.
///
/// `onPageChanged` hutolewa nje kwa makusudi: sauti ya kugeuza ukurasa,
/// kuhifadhi maendeleo ya kusoma na kuanzisha TTS ni kazi ya
/// `story_reader` — si ya widget ya jumla. (Widget hii haijui `AudioService`
/// wala `StoryCubit`.)
class AppPageTurnView extends StatelessWidget {
  const AppPageTurnView({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    this.onPageChanged,
    this.maxAngle = 0.35,
    this.minScale = 0.92,
    this.physics = const PageScrollPhysics(),
    this.allowImplicitScrolling = true,
  });

  final PageController controller;
  final int itemCount;

  /// Hujenga ukurasa wa [index]. **Usiweke** [AppPageTurn] hapa — widget hii
  /// inaifunga yenyewe.
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// Huitwa ukurasa mpya ukiwa umeimarika (baada ya kuacha kusogeza).
  final ValueChanged<int>? onPageChanged;

  final double maxAngle;
  final double minScale;
  final ScrollPhysics physics;

  /// `true` = kurasa zilizo jirani hujengwa mapema.
  ///
  /// Hii inasaidia sana kwenye Tanzania: mtoto anaposogeza, ukurasa unaofuata
  /// tayari una picha yake, kwa hivyo hakuna sekunde ya skrini nyeupe akiwa
  /// kwenye 2G/3G. Gharama: kumbukumbu ya kurasa mbili badala ya moja.
  final bool allowImplicitScrolling;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: itemCount,
      onPageChanged: onPageChanged,
      physics: physics,
      allowImplicitScrolling: allowImplicitScrolling,
      itemBuilder: (BuildContext context, int index) => AppPageTurn(
        controller: controller,
        index: index,
        maxAngle: maxAngle,
        minScale: minScale,
        child: itemBuilder(context, index),
      ),
    );
  }
}

// Kumbuka: hakuna `const Duration` hapa.
//
// Muda wa kugeuza ukurasa unamilikiwa na [AppSpacing.pageTurn] (`450ms`)
// peke yake. Kuongeza alias ya pili (k.m. `kPageTurnDuration`) kungeunda
// vyanzo viwili vya ukweli vinavyoweza kutofautiana baadaye — tatizo
// lilelile lililogundulika kwenye [AppSpacing.splash] vs
// `AppConstants.splashMinimumDuration`.
//
// `AppPageTurn` yenyewe **haimiliki** muda huo: mzunguko wake unafuatilia
// `controller.value`, kwa hiyo muda huja kutoka mahali `animateToPage`
// inaitwa. Njia ya kusoma inapaswa kupitisha [AppSpacing.pageTurn]:
//
// ```dart
// _controller.animateToPage(
//   next,
//   duration: AppSpacing.pageTurn,
//   curve: Curves.easeInOut,
// );
// ```
