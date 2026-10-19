/// Vichujo vinavyogusika (chips) vya kurasa za hadithi.
///
/// ## Kwa nini widget moja, mitindo miwili
///
/// Spec inataka vichujo viwili tofauti kwa **muonekano**: "vidonge" vya
/// kundi (36dp, kijani cha Safari) na "chips" za kichujo (32dp, rangi ya
/// Kanga Orange). Ni vitu viwili tofauti kwa jicho, lakini **tabia ni ile
/// ile**: kisanduku, mpaka, maandishi, mguso na hali ya kuchaguliwa.
/// Kuviandika mara mbili kungezalisha tofauti za kimya (mpaka mmoja 1dp na
/// mwingine 1.5dp, radius 16 dhidi ya 18) ambazo hazikusudiwi.
///
/// ## Kwa nini eneo la kugusa ni kubwa kuliko kisanduku
///
/// Kisanduku ni 32dp/36dp kwa muonekano, lakini **eneo la kugusa** ni 48dp
/// ([AppSpacing.minTouchTarget]). Tofauti hiyo hutolewa kwa `Padding` ya
/// wima pekee — kwa hivyo upana haubadiliki. Hii ni muhimu kwa watoto wa
/// miaka 3-5, ambao kidole chao hukosa kitufe cha 32dp mara kwa mara.
library;

import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Muonekano wa kichujo.
enum StoryChipStyle {
  /// Kichujo cha kichwa cha gridi — 32dp, Kanga Orange 20% inapochaguliwa.
  filter,

  /// Kidonge cha kundi — 36dp, Safari Green inapochaguliwa.
  category,
}

/// Kichujo kimoja kinachogusika.
class StoryChoiceChip extends StatelessWidget {
  /// Huunda kichujo.
  const StoryChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.style = StoryChipStyle.filter,
    this.leading,
  });

  /// Maandishi ya kichujo (tayari kwa lugha ya sasa).
  final String label;

  /// Kitu kidogo kabla ya maandishi (mfano picha ya rafu kwenye kidonge).
  ///
  /// Ni `null` kwa chips nyingi: kichujo cha kawaida ni maandishi pekee.
  /// Vidonge vya makundi hupitisha picha ya rafu hapa ili mtoto wa miaka
  /// 3-8 atambue kundi kwa **jicho** kabla ya kusoma jina.
  final Widget? leading;

  /// `true` = kichujo kinatumika sasa.
  final bool selected;

  /// Hutekelezwa kwa hali **mpya** mtumiaji anapogusa.
  ///
  /// Tunapitisha hali mpya (`!selected`) badala ya kutupa `onTap` tupu ili
  /// kila ukurasa usiandike `onTap: () => setState(() => _x = !_x)` yake.
  final ValueChanged<bool> onSelected;

  /// Muonekano — tazama [StoryChipStyle].
  final StoryChipStyle style;

  @override
  Widget build(BuildContext context) {
    final bool isPill = style == StoryChipStyle.category;

    final double boxHeight = isPill ? 36 : 32;
    final BorderRadius radius = BorderRadius.circular(isPill ? 18 : 16);

    // Rangi: kijani cha Safari kwa vidonge, Kanga Orange 20% kwa chips.
    final Color background = selected
        ? (isPill
            ? AppColors.safariGreen
            : AppColors.kangaOrange.withOpacity(0.20))
        : (isPill ? AppColors.cardBackground : Colors.transparent);
    final Color border = selected
        ? (isPill ? AppColors.safariGreen : AppColors.kangaOrange)
        : AppColors.divider;
    final Color foreground =
        selected ? (isPill ? Colors.white : AppColors.kangaOrange) : Theme.of(context).colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Padding(
        // Eneo la kugusa 48dp: tunasegemeza `Padding` ya wima pekee, kwa
        // hivyo upana unabaki wa kisanduku (Row/`SingleChildScrollView`
        // haipati upana usio na kikomo).
        padding: EdgeInsets.symmetric(
          vertical: (AppSpacing.minTouchTarget - boxHeight) / 2,
        ),
        child: Material(
          color: background,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: () => onSelected(!selected),
            child: Container(
              height: boxHeight,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                borderRadius: radius,
                border: Border.all(color: border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (leading != null) ...<Widget>[
                    leading!,
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.labelMedium?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mstari wa vichujo unaosogea kwa mlalo.
///
/// Hutumia `SingleChildScrollView` + `Row` (si `ListView`) kwa sababu idadi
/// ya vichujo ni ndogo na inajulikana; `Row` huchukua urefu wa mtoto mrefu
/// pekee, kwa hivyo hakuna `SizedBox` ya urefu inayohitajika na hakuna
/// upana usio na kikomo.
class StoryChipRow extends StatelessWidget {
  /// Huunda mstari wa [children].
  const StoryChipRow({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
  });

  /// Vichujo kwa mpangilio.
  final List<Widget> children;

  /// Nafasi ya kando ya mstari.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: <Widget>[
          for (int i = 0; i < children.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            children[i],
          ],
        ],
      ),
    );
  }
}
