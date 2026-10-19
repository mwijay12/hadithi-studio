import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';
import '../../l10n/l10n.dart';
import 'custom_button.dart';

/// Upau wa juu (top bar) wa Hadithi Studio.
///
/// Jina la faili linatoka kwenye mti wa spec (`custom_app_bar.dart`), lakini
/// jina la class linafuata kanuni ya mradi (`App*`) — kama
/// `custom_button.dart` ina `AppButton`.
///
/// ## Kwa nini widget hii ipo
///
/// `AppBar` ya Flutter inahitaji `title: Text(...)`, na kila ukurasa
/// ungejenga `Text(context.localised(swahili: …, english: …))` yake.
/// Kwenye skrini ~40 hilo linamaanisha: (1) baadhi ya kurasa zinasahau
/// Kiingereza (kanuni ya 4 inavunjika kimya kimya), na (2) kitufe cha kurudi
/// kinapotea kwenye kurasa zilizoundwa kwa `Scaffold` mpya, kwa hivyo
/// mtumiaji anakwama.
///
/// Widget hii inashughulikia mambo mawili pekee, lakini ya muhimu:
/// maandishi ya lugha mbili na kitufe cha kurudi chenye akili.
///
/// ## Kitufe cha kurudi "chenye akili"
///
/// `showBackButton` ni `true` kwa chaguo-msingi, lakini kitufe huonekana
/// **tu** kama `Navigator.of(context).canPop()` ni `true`. Kwa hivyo:
/// * Ukurasa wa tab (Nyumbani, Maktaba) — hakuna cha kurudi, hakuna kitufe.
/// * Ukurasa wa hadithi uliopushwa juu — kitufe kinaonekana.
///
/// Bila hii, kila ukurasa wa tab ungehitaji `showBackButton: false`, na
/// kusahau mara moja kungeonyesha kitufe cha kurudi kwenye skrini ya nyumbani
/// — kinachomfanya mtumiaji atoke kwenye app kwa bahati mbaya.
///
/// Matumizi:
/// ```dart
/// Scaffold(
///   appBar: AppTopBar(titleSw: 'Maktaba', titleEn: 'Library'),
///   body: const LibraryBody(),
/// )
/// ```
///
/// Kwa upau unaojificha wakati wa kusogeza (picha ya kundi juu), tumia
/// [AppSliverTopBar] badala yake.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.titleSw,
    this.titleEn,
    this.title,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBack,
    this.centerTitle = false,
    this.bottom,
    this.transparent = false,
    this.titleSpacing,
    this.toolbarHeight = AppSpacing.appBarHeight,
  }) : assert(
          title != null || (titleSw != null && titleEn != null),
          'Weka titleSw NA titleEn (kanuni ya 4), au widget ya title.',
        );

  /// Kichwa kwa Kiswahili.
  final String? titleSw;

  /// Kichwa kwa Kiingereza.
  final String? titleEn;

  /// Kichwa maalum — kwa kesi ambapo jina lina nembo au namba
  /// (mfano `Row(Text(jina), Chip('VIP'))`). Ukitumia hii, weka maandishi
  /// mwenyewe kwa lugha mbili.
  final Widget? title;

  /// Kitufe cha kushoto. `null` = kitufe cha kurudi (kama kuna cha kurudi).
  final Widget? leading;

  /// Vitufe vya kulia (mfano utafutaji, arifa, mipangilio).
  final List<Widget>? actions;

  /// `true` = onyesha kitufe cha kurudi **ikiwa** kuna cha kurudi.
  final bool showBackButton;

  /// Kitendo maalum cha kurudi (mfano kuuliza "Unataka kutoka?" kabla ya
  /// kutoka kwenye ukurasa wa kuhariri).
  final VoidCallback? onBack;

  /// Chaguo-msingi `false` — sawa na `appBarTheme` ya mradi.
  final bool centerTitle;

  /// Kitu cha ziada chini ya kichwa (mfano uwanja wa utafutaji au tab bar).
  ///
  /// Lazima kiwe [PreferredSizeWidget] ili `preferredSize` iwe sahihi —
  /// la sivyo `Scaffold` itahesabu urefu usio sahihi wa body.
  final PreferredSizeWidget? bottom;

  /// `true` = upau hauonekani (rangi inaonekana kupitia kwao).
  ///
  /// Hutumika juu ya picha ya kundi la hadithi. Kumbuka: `Scaffold` bado
  /// inahitaji `body` isiingie chini ya status bar — tumia
  /// `MediaQuery.of(context).padding.top` kwenye body.
  final bool transparent;

  /// Nafasi kati ya kitufe cha kushoto na kichwa. `null` = cha Flutter.
  final double? titleSpacing;

  /// Urefu wa sehemu ya kichwa, bila [bottom].
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title ?? Text(context.localised(swahili: titleSw!, english: titleEn!)),
      leading: resolveTopBarLeading(
        context,
        leading: leading,
        showBackButton: showBackButton,
        onBack: onBack,
      ),
      // Tunajenga `leading` wenyewe; `automaticallyImplyLeading` ingeongeza
      // kitufe cha Flutter bila `tooltip` ya Kiswahili.
      automaticallyImplyLeading: false,
      actions: actions,
      centerTitle: centerTitle,
      bottom: bottom,
      titleSpacing: titleSpacing,
      toolbarHeight: toolbarHeight,
      backgroundColor: transparent ? Colors.transparent : null,
      elevation: transparent ? 0 : null,
      scrolledUnderElevation: transparent ? 0 : null,
    );
  }
}

/// Upau wa juu unaojificha/jinasa wakati wa kusogeza (`SliverAppBar`).
///
/// Hutumika kwa kurasa za kundi la hadithi na ukurasa wa nyumbani, ambapo
/// picha kubwa inaonekana kwanza kisha inapungua hadi kichwa kidogo
/// kinachobaki juu.
///
/// **Kwa nini ni class tofauti, si `bool sliver`:** `SliverAppBar` na `AppBar`
/// hutumika mahali tofauti kabisa (`CustomScrollView.slivers` na
/// `Scaffold.appBar`). Kuunganisha kwa bendera bunde kungeacha uwezekano wa
/// kutumia kitu kibaya mahali — na kosa hilo halionekani hadi runtime.
///
/// Matumizi:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     AppSliverTopBar(
///       titleSw: 'Ngano',
///       titleEn: 'Folk tales',
///       expandedHeight: 220,
///       flexibleSpace: Image.asset(AssetConstants.categoryNgano, fit: BoxFit.cover),
///     ),
///     const SliverList(...),
///   ],
/// )
/// ```
class AppSliverTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppSliverTopBar({
    super.key,
    this.titleSw,
    this.titleEn,
    this.title,
    this.leading,
    this.actions,
    this.showBackButton = true,
    this.onBack,
    this.flexibleSpace,
    this.expandedHeight,
    this.pinned = true,
    this.floating = false,
    this.bottom,
    this.centerTitle = false,
    this.toolbarHeight = AppSpacing.appBarHeight,
  }) : assert(
          title != null || (titleSw != null && titleEn != null),
          'Weka titleSw NA titleEn (kanuni ya 4), au widget ya title.',
        );

  final String? titleSw;
  final String? titleEn;
  final Widget? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  /// Background inayojifunua kichwa kinapopanuka (picha au muundo wa kanga).
  final Widget? flexibleSpace;

  /// Urefu kamili kichwa kikiwa kimepanuka.
  ///
  /// `null` = urefu wa kawaida (`kToolbarHeight` + bottom). Kwa picha, weka
  /// `220`–`280`: zaidi ya hapo mtumiaji wa simu ndogo anapoteza nafasi ya
  /// maudhui bila faida.
  final double? expandedHeight;

  final bool pinned;
  final bool floating;
  final PreferredSizeWidget? bottom;
  final bool centerTitle;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
        toolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: title ?? Text(context.localised(swahili: titleSw!, english: titleEn!)),
      leading: resolveTopBarLeading(
        context,
        leading: leading,
        showBackButton: showBackButton,
        onBack: onBack,
      ),
      automaticallyImplyLeading: false,
      actions: actions,
      centerTitle: centerTitle,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      toolbarHeight: toolbarHeight,
    );
  }
}

/// Hutengeneza `leading` ya upau wa juu: maalum, kitufe cha kurudi, au hakuna.
///
/// Ni function ya ngazi ya juu (si method ya class) kwa sababu [AppTopBar] na
/// [AppSliverTopBar] zote zinahitaji — kuiweka kwenye class moja kungefanya
/// nyingine itegemee class hiyo bila sababu.
///
/// `tooltip` ni muhimu, si mapambo: kwenye upau unaoonekana tu kama mishale
/// miwili, mtumiaji asiyeona hana namna ya kujua kitufe ni kipi.
@visibleForTesting
Widget? resolveTopBarLeading(
  BuildContext context, {
  required Widget? leading,
  required bool showBackButton,
  required VoidCallback? onBack,
}) {
  if (leading != null) return leading;
  if (!showBackButton) return null;

  // `canPop` inaangalia Navigator ya sasa (pamoja na navigator ya ndani ya
  // tab kwenye `StatefulShellRoute`). Kwenye ukurasa wa tab haina cha kurudi,
  // kwa hivyo hakuna kitufe — ndiyo tabia tunayotaka.
  if (!Navigator.of(context).canPop()) return null;

  return AppIconButton(
    icon: Icons.arrow_back_rounded,
    // `context.l10n.back` tayari imetafsiriwa kwa lugha ya sasa; tunapitisha
    // kitu kimoja kwa `tooltipSw` na `tooltipEn` kwa sababu chanzo ni ARB.
    tooltipSw: context.l10n.back,
    tooltipEn: context.l10n.back,
    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
  );
}
