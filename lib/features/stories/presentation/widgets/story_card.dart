/// Kadi ya hadithi tayari-kugusa, na gridi ya kadi hizo.
///
/// [StoryArtwork] hujua jinsi ya **kuchora** kadi; [StoryCard] hujua **ni
/// hadithi gani** na **inakwenda wapi**. Kutenganisha hivi kunamaanisha
/// Nyumbani, Maktaba, rafu, utafutaji na Rafu Yangu zote hupata tabia ile ile
/// ya mguso bila kuandika `onTap` mara tano.
library;

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/story.dart';
import '../story_navigation.dart';
import 'story_artwork.dart';

/// Kadi moja ya hadithi — picha, kichwa na mguso.
class StoryCard extends StatelessWidget {
  /// Huunda kadi ya [story].
  const StoryCard({
    super.key,
    required this.story,
    this.height = 170,
    this.badge,
    this.titleStyle,
  });

  /// Hadithi inayoonyeshwa.
  final Story story;

  /// Urefu wa kadi. Ndani ya gridi tumia `double.infinity`.
  final double height;

  /// Lebo ndogo juu ya kichwa (mfano "Hadithi ya Leo").
  final String? badge;

  /// Ukubwa maalum wa kichwa (kadi kuu hutumia kubwa).
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final String title = story.title(swahili: context.isSwahili);

    return StoryArtwork(
      title: title,
      asset: story.coverAsset,
      accent: story.accent,
      height: height,
      badge: badge,
      titleStyle: titleStyle,
      // Lebo ya screen reader inaongeza kile ambacho kichwa pekee
      // hakikisemi: kuwa kadi hii **inafungua** hadithi.
      semanticLabel: '$title — ${story.categoryLabel(swahili: context.isSwahili)}',
      onTap: () => openStory(context, story),
    );
  }
}

/// Gridi ya kadi za hadithi — safu mbili.
///
/// Safu mbili ni uamuzi wa makusudi: kwenye simu ya inchi 5, safu tatu
/// hufanya kadi kuwa ndogo kiasi kwamba picha haisemi kitu — na kwa mtoto
/// wa miaka 3-8, picha ndiyo njia ya kuchagua hadithi.
class StoryGrid extends StatelessWidget {
  /// Huunda gridi ya [stories].
  const StoryGrid({
    super.key,
    required this.stories,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    this.bottomPadding = AppSpacing.xxl,
  });

  /// Hadithi za kuonyesha, kwa mpangilio.
  final List<Story> stories;

  /// Nafasi ya kando na juu ya gridi.
  final EdgeInsets padding;

  /// Nafasi ya chini — inatosha ili kadi ya mwisho isifichwe na nav ya chini.
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: padding.copyWith(bottom: bottomPadding),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.78,
      children: <Widget>[
        for (final Story story in stories)
          StoryCard(story: story, height: double.infinity),
      ],
    );
  }
}
