/// Gridi ya kadi za hadithi — safu zinazobadilika, kadi yenye metadata, na
/// shimmer inayolingana kabisa na gridi halisi.
///
/// ## Kwa nini faili la pekee
///
/// Ukurasa wa rafu (`/category/:id`) na ukurasa wa hadithi zote
/// (`/stories/all`) huonyesha **kitu kile kile**: gridi ya kadi, kadi ya
/// shimmer wakati inapakia, na nafasi sawa. Bila faili hili kila ukurasa
/// ungeandika `GridView.builder` yake — na `crossAxisCount` ya mmoja
/// ingesahaulika siku moja, kwa hivyo kadi zingeonekana kubwa kwenye rafu na
/// ndogo kwenye utafutaji.
///
/// ## `physics` ya `AlwaysScrollableScrollPhysics`
///
/// Maktaba yetu ni ndogo (hadithi 6 kwa sasa). Kadi chache kwenye skrini
/// kubwa **hazijazi** eneo la kuona, na `GridView` isiyosogea
/// haijibu `RefreshIndicator`: mtumiaji anavuta chini na hakuna kinachotokea.
/// `AlwaysScrollableScrollPhysics` hufanya gridi ijibu mguso kila wakati.
library;

import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../domain/entities/story.dart';
import 'story_card.dart';

/// Kadi moja ndani ya gridi: kifuniko, mwandishi na rating.
///
/// Kifuniko kinatumia [StoryCard] **kile kile** kinachotumika Nyumbani na
/// Maktaba, kwa hivyo kichwa na mguso ni sawa kila mahali. Chini yake
/// tunaongeza mistari miwili ambayo kadi ya picha pekee haiwezi kuonyesha:
/// mwandishi na rating — mzazi anayechagua hadithi ya jioni hutaka kujua
/// nani aliandika na wengine waliipenda kiasi gani.
class StoryGridTile extends StatelessWidget {
  /// Huunda kadi ya [story].
  const StoryGridTile({super.key, required this.story});

  /// Hadithi inayoonyeshwa.
  final Story story;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = context.textTheme;
    final TextStyle? metaStyle = text.labelSmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // `Expanded` (si urefu maalum) ili kifuniko kitumie nafasi yote
        // iliyobaki — kadi zote kwenye safu moja ziwe na kimo kimoja,
        // hata kama jina la mmoja linavunja mistari miwili na mwingine mmoja.
        Expanded(child: StoryCard(story: story, height: double.infinity)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          story.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: metaStyle,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Row(
          children: <Widget>[
            const Icon(
              Icons.star_rounded,
              size: 14,
              color: AppColors.sunsetGold,
            ),
            const SizedBox(width: AppSpacing.xxs),
            Text(story.rating.toStringAsFixed(1), style: metaStyle),
          ],
        ),
      ],
    );
  }
}

/// Gridi ya kadi za hadithi — safu 2/3/4/5 kulingana na upana wa skrini.
class StoryGridView extends StatelessWidget {
  /// Huunda gridi ya [stories].
  const StoryGridView({
    super.key,
    required this.stories,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.xxl,
    ),
    this.childAspectRatio = 0.65,
  });

  /// Hadithi za kuonyesha, kwa mpangilio.
  final List<Story> stories;

  /// Nafasi ya kando na chini ya gridi.
  final EdgeInsets padding;

  /// Uwiano wa kadi (upana ÷ urefu). `0.65` = kadi ndefu kama ya kitabu.
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: const AlwaysScrollableScrollPhysics(),
      // Idadi ya safu inatoka `AppBreakpoints` — chanzo kimoja cha ukweli
      // (`ContextX.gridColumns`). Hapa hatusemi "2 kwa simu" wala "5 kwa
      // desktop": ukubwa wa skrini unaamuliwa mahali pamoja.
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.gridColumns,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.lg,
      ),
      itemCount: stories.length,
      itemBuilder: (BuildContext context, int index) =>
          StoryGridTile(story: stories[index]),
    );
  }
}

/// Gridi ya shimmer — onyesho la **umbo** la kile kinachokuja.
///
/// Ni muhimu kwamba unafanana na [StoryGridView]: kama shimmer ina kadi
/// nne na gridi halisi ina sita, kuna "kuruka" kunakoonekana mtumiaji data
/// inapofika. Kwa hivyo tunatumia `crossAxisCount` ile ile na umbo
/// linalolingana (kifuniko + mistari miwili).
class StoryGridShimmer extends StatelessWidget {
  /// Huunda shimmer ya kadi [count].
  const StoryGridShimmer({
    super.key,
    this.count = 6,
    this.padding = const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.lg,
      AppSpacing.xxl,
    ),
    this.childAspectRatio = 0.65,
  });

  /// Idadi ya kadi za kubuniwa.
  final int count;

  /// Nafasi ya kando na chini.
  final EdgeInsets padding;

  /// Uwiano wa kadi — lazima ulingane na [StoryGridView].
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: context.gridColumns,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.lg,
      ),
      itemCount: count,
      itemBuilder: (BuildContext context, int index) => const _ShimmerTile(),
    );
  }
}

/// Kadi moja ya shimmer yenye umbo la [StoryGridTile].
///
/// Hatutumii `AppShimmerCard` ya jumla hapa: ile ina `AspectRatio(3/4)` na
/// mistari yake, kwa hivyo kwenye kadi ndefu ya 0.65 inaweza kuzidi urefu wa
/// seli na kusababisha "overflow". Hapa kifuniko ni `Expanded`, kwa hivyo
/// kinabana kwenye nafasi iliyopo — hakuna overflow kwenye skrini yoyote.
class _ShimmerTile extends StatelessWidget {
  const _ShimmerTile();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Expanded(
          child: AppShimmerBox(borderRadius: AppSpacing.borderRadiusMd),
        ),
        const SizedBox(height: AppSpacing.xs),
        const AppShimmerBox(height: 12, borderRadius: AppSpacing.borderRadiusSm),
        const SizedBox(height: AppSpacing.xxs),
        const SizedBox(
          width: 56,
          child: AppShimmerBox(
            height: 12,
            borderRadius: AppSpacing.borderRadiusSm,
          ),
        ),
      ],
    );
  }
}
