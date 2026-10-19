/// Nyongeza (extensions) za `Widget`.
///
/// Kwa nini faili hili lipo: widget za Flutter huzungwa mara kwa mara
/// (`Padding`, `Center`, `Visibility`, `GestureDetector`) na hii hufanya
/// mti wa widget kuwa mrefu na mgumu kusoma. Nyongeza hizi hupunguza
/// `Column(children: [...])` kuwa mistari rahisi inayosomeka.
///
/// Kumbuka: `Expanded`/`Flexible` zinahitaji `Flex` mzazi; `SliverToBoxAdapter`
/// inahitaji `CustomScrollView` mzazi. Majina yao yanaonya hilo.
library;

import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';

extension WidgetX on Widget {
  // ---------------------------------------------------------------------------
  // Padding
  // ---------------------------------------------------------------------------

  /// Kufunga widget kwa nafasi sawa pande zote nne.
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Kufunga widget kwa nafasi ya wima na mlalo tofauti.
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  /// Kufunga widget kwa nafasi ya kila upande tofauti.
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(
        padding: EdgeInsets.only(
          left: left,
          top: top,
          right: right,
          bottom: bottom,
        ),
        child: this,
      );

  /// Nafasi ya kawaida ya ukurasa — hutumika kwa skrini zote za app.
  ///
  /// Kwenye simu ndogo ([AppSpacing.sm]) tunapunguza ili maneno yasivunjike.
  Widget pagePadding({bool compact = false}) => paddingSymmetric(
        horizontal: compact ? AppSpacing.md : AppSpacing.lg,
        vertical: AppSpacing.md,
      );

  /// Kumweka widget katikati ya mzazi wake.
  Widget centered() => Center(child: this);

  /// Kumweka widget kwa nafasi ya juu-kushoto ya mzazi wake.
  Widget alignedTopLeft() => Align(alignment: Alignment.topLeft, child: this);

  // ---------------------------------------------------------------------------
  // Muonekano wa masharti (conditional display)
  // ---------------------------------------------------------------------------

  /// Kuonyesha widget kama [visible] ni `true`, la sivyo kitu tupu.
  ///
  /// Kwa default tunaweka `maintainState: false` (widget haitengenezwi kabisa)
  /// — hii ni muhimu kwa utendaji kwenye vifaa vya 2GB RAM, kwa sababu
  /// sehemu zisizoonekana hazitumii kumbukumbu. Kwa fomu tunatumia
  /// `maintainState: true` ili mtumiaji asipoteze maandishi aliyoandika.
  Widget withVisibility(bool visible, {bool maintainState = false}) =>
      Visibility(
        visible: visible,
        maintainState: maintainState,
        child: this,
      );

  /// Kuonyesha widget kama [condition] ni `true` — kifupi cha [withVisibility].
  Widget visibleWhen(bool condition, {bool maintainState = false}) =>
      withVisibility(condition, maintainState: maintainState);

  /// Kubadilisha widget kuwa `SizedBox.shrink()` kama [condition] ni `true`.
  ///
  /// Hii ni rahisi kwenye `children:` orodha ambapo mistari ya pili inadai
  /// `if (...) ...` kila wakati.
  Widget hiddenWhen(bool condition) =>
      condition ? const SizedBox.shrink() : this;

  // ---------------------------------------------------------------------------
  // Mguso (gestures)
  // ---------------------------------------------------------------------------

  /// Kufanya widget iitike kwa mguso — kwa eneo la mguso linalotosha.
  ///
  /// Tunatumia `InkWell` (si `GestureDetector`) ili mtumiaji aone mwanga
  /// (ripple) anapogusa. `minTouchTarget` ni 48dp — kiwango cha Google
  /// Accessibility, muhimu kwa vidole vidogo vya watoto.
  Widget onTap(VoidCallback? onTap, {bool withFeedback = true}) {
    if (onTap == null) return this;
    if (!withFeedback) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: this,
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.borderRadiusMd,
      child: this,
    );
  }

  /// Kufunga widget kwenye `Semantics` — muhimu kwa screen reader.
  ///
  /// Watoto wadogo wanatumia TalkBack; kila kitufe chetu kinapaswa kuwa na
  /// lebo ya Kiswahili, hivyo tunarahisisha kuiongeza.
  Widget semanticLabel(String label, {String? hint, bool button = false}) =>
      Semantics(
        label: label,
        hint: hint,
        button: button,
        child: this,
      );

  // ---------------------------------------------------------------------------
  // Muundo wa layout
  // ---------------------------------------------------------------------------

  /// Kufunga widget kwa `Expanded` — inahitaji mzazi `Row`/`Column`/`Flex`.
  Widget expanded({int flex = 1}) => Expanded(flex: flex, child: this);

  /// Kufunga widget kwa `Flexible` — inahitaji mzazi `Row`/`Column`/`Flex`.
  Widget flexible({int flex = 1, FlexFit fit = FlexFit.loose}) =>
      Flexible(flex: flex, fit: fit, child: this);

  /// Kubadilisha widget kuwa sliver — inahitaji mzazi `CustomScrollView`.
  Widget asSliver() => SliverToBoxAdapter(child: this);

  /// Kuweka kikomo cha upana (kwa tablet na desktop).
  ///
  /// Kwenye tablet ya 900dp, maandishi yanayotandaza upana wote husomeka
  /// vibaya; tunayazuia kwa 720dp kama ilivyo kawaida ya kusoma.
  Widget constrainWidth({double maxWidth = 720}) =>
      ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: this);

  /// Kuongeza nafasi ya juu kwa kutumia `SizedBox` badala ya `Padding`.
  Widget withTopSpacing(double value) =>
      paddingOnly(top: value);

  /// Kufunga widget kwa `Hero` kwa mpito kati ya kurasa za hadithi.
  Widget heroTag(Object tag) => Hero(tag: tag, child: this);
}
