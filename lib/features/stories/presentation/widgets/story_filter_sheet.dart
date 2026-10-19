/// Karatasi ya vichujio (filter bottom sheet) ya ukurasa wa hadithi zote.
///
/// ## Muundo
///
/// Hushikwa na [showStoryFilterSheet], ambayo hurudisha [StoryFilter] mpya
/// au `null` kama mtumiaji alifunga karatasi bila kugusa "Tumia Vichujio".
/// Kurudisha kitu (si `null`) ni muhimu: mtumiaji anayegusa kichujo kisha
/// kufunga karatasi **hakusudii** kuacha kichujo kifanye kazi — hivyo
/// tunatofautisha "acha" (`null`) na "tumia" (kitu).
///
/// ## Kwa nini hakuna sehemu ya "Lugha"
///
/// Spec inataka sehemu nne: Umri, Kiwango, **Lugha** na Bei. Sehemu ya
/// lugha haipo kwa makusudi: [Story] haina sehemu ya lugha, kwa sababu kila
/// hadithi yetu ina `titleSw` **na** `titleEn` kwa wakati mmoja (kanuni ya
/// 4). Kichujo cha lugha hakingetenganisha hadithi hata moja — kungekuwa
/// kitufe kinachogusika kisichobadilisha kitu, ambacho ni kibaya zaidi kwa
/// mtumiaji kuliko kitufe kisichokuwepo.
///
/// Vivyo hivyo, bei ina thamani mbili pekee (`isFree`): "Bure" na "VIP".
/// Bendi za "TZS 500-2000" hazijajengwa kwa sababu [Story] haina `priceTZS`.
library;

import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../l10n/l10n.dart';
import '../story_query.dart';
import 'story_chip.dart';

/// Hufungua karatasi ya vichujio na kurudisha kichujo kilichochaguliwa.
///
/// `null` = mtumiaji alifunga bila kutumia; mwitaji anatunza kichujo cha
/// zamani.
Future<StoryFilter?> showStoryFilterSheet(
  BuildContext context,
  StoryFilter current,
) {
  return showModalBottomSheet<StoryFilter>(
    context: context,
    // Tunahitaji `true` ili karatasi ipate urefu wa skrini: kwenye simu
    // ndogo vichujo vyote haviingii, na bila hii sehemu ya chini ingekatwa.
    isScrollControlled: true,
    backgroundColor: AppColors.cardBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) => _StoryFilterSheet(initial: current),
  );
}

/// Karatasi yenyewe — inashikilia **nakala ya kazi** ya kichujo.
///
/// Kugusa kichujo hakubadilishi orodha mara moja: mtumiaji anaweza kuchagua
/// vichujo vitatu kisha kugusa "Tumia Vichujio" mara moja. Hiyo inazuia
/// orodha kubadilika chini ya karatasi kwa kila mguso (jambo linalochanganya
/// na kufanya gridi ijengwe upya bila sababu).
class _StoryFilterSheet extends StatefulWidget {
  const _StoryFilterSheet({required this.initial});

  /// Kichujo cha sasa — ndiyo mwanzo wa nakala ya kazi.
  final StoryFilter initial;

  @override
  State<_StoryFilterSheet> createState() => _StoryFilterSheetState();
}

class _StoryFilterSheetState extends State<_StoryFilterSheet> {
  late StoryFilter _draft = widget.initial;

  /// Huongeza au huondoa kundi la umri (multi-select).
  void _toggleAgeGroup(AgeGroup group) {
    final Set<AgeGroup> next = Set<AgeGroup>.of(_draft.ageGroups);
    // `Set.remove` hurudisha `true` kama kitu kilikuwepo — hivyo mstari mmoja
    // hushughulikia kuongeza **na** kuondoa.
    if (!next.remove(group)) next.add(group);
    setState(() => _draft = _draft.copyWith(ageGroups: next));
  }

  /// Huchagua au huondoa kiwango cha kusoma (single-select).
  void _selectLevel(ReadingLevel level) {
    final bool alreadySelected = _draft.readingLevel == level;
    setState(() {
      _draft = _draft.copyWith(
        readingLevel: level,
        clearReadingLevel: alreadySelected,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return SafeArea(
      top: false,
      child: ConstrainedBox(
        // Kikomo cha 85% ya skrini: vichujo vyote vinaonekana, na sehemu ya
        // gridi nyuma inabaki kuonekana kidogo (mtumiaji hakosi mahali alipo).
        constraints: BoxConstraints(
          maxHeight: context.screenHeight * 0.85,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const _DragHandle(),
              _header(context, l10n),
              _sectionTitle(context, l10n.ageGroup),
              _chipWrap(context, <Widget>[
                for (final AgeGroup group in AgeGroup.values)
                  StoryChoiceChip(
                    label: context.isSwahili ? group.labelSw : group.labelEn,
                    selected: _draft.ageGroups.contains(group),
                    onSelected: (bool _) => _toggleAgeGroup(group),
                  ),
              ]),
              _sectionTitle(context, l10n.readingLevel),
              _chipWrap(context, <Widget>[
                for (final ReadingLevel level in ReadingLevel.values)
                  StoryChoiceChip(
                    label: context.isSwahili ? level.labelSw : level.labelEn,
                    selected: _draft.readingLevel == level,
                    onSelected: (bool _) => _selectLevel(level),
                  ),
              ]),
              _sectionTitle(context, l10n.price),
              _chipWrap(context, <Widget>[
                for (final StoryPriceFilter price in StoryPriceFilter.values)
                  StoryChoiceChip(
                    label: storyPriceLabel(context, price),
                    selected: _draft.price == price,
                    onSelected: (bool _) => setState(
                      () => _draft = _draft.copyWith(price: price),
                    ),
                  ),
              ]),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: AppButton(
                  labelSw: l10n.applyFilters,
                  labelEn: l10n.applyFilters,
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.of(context).pop(_draft),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Kichwa: "Vichujio" + "Futa Yote".
  Widget _header(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              l10n.filters,
              style: context.textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppButton(
            labelSw: l10n.clearAll,
            labelEn: l10n.clearAll,
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
            expand: false,
            icon: Icons.clear_all,
            // Kurudisha `none` badala ya kufunga karatasi: mtumiaji anayegusa
            // "Futa Yote" mara nyingi hutaka kuchagua kichujo kipya mara moja.
            onPressed: () => setState(() => _draft = StoryFilter.none),
          ),
        ],
      ),
    );
  }

  /// Kichwa cha sehemu — Earth Brown, w700.
  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: context.textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  /// Kundi la vichujo linalovunja mstari kiotomatiki.
  Widget _chipWrap(BuildContext context, List<Widget> chips) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xxs,
        children: chips,
      ),
    );
  }
}

/// Kishikio cha kuvuta — alama inayojulikana ya karatasi ya chini.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(
          top: AppSpacing.md,
          bottom: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
      ),
    );
  }
}
