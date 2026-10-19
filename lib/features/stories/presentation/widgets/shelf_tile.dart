/// Kadi ya **rafu** (kundi) na kazi moja ya kutafsiri lebo zake.
///
/// [storyShelfLabel] ni mahali **pamoja** panaposoma `context.l10n` kwa
/// rafu. Doc ya `story_shelf.dart` iliahidi kazi hii hapa, na sababu ni
/// kwamba `StoryShelf` ni entity ya domain: haiwezi kumiliki
/// `BuildContext` wala ARB. Kuiweka hapa kunamaanisha:
///
/// * Kadi ya Maktaba, kichwa cha ukurasa wa rafu na "Jaribu tena" wote
///   huonyesha jina lile lile.
/// * Kubadilisha jina la rafu (`catAnimalStories`) ni mabadiliko ya ARB
///   pekee — hakuna `switch` wa Dart unaohitaji kuangaliwa.
///
/// Bila kazi hii, kila skrini ingeandika `switch (shelf)` yake — na
/// rafu mpya ingesahaulika mahali fulani.
library;

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/story_shelf.dart';
import 'story_artwork.dart';

/// Jina la rafu kwa lugha iliyochaguliwa sasa.
///
/// Hii ni `switch` **kamili** (haijumuishi `default`) kwa makusudi: rafu
/// mpya ikiongezwa kwenye [StoryShelf], mkusanyaji atalalamika hapa.
/// `default` ingefanya rafu mpya kutumia jina la kwanza kimya kimya —
/// hitilafu inayogundulika tu na mtumiaji.
String storyShelfLabel(BuildContext context, StoryShelf shelf) {
  final dynamic l10n = context.l10n;
  switch (shelf) {
    case StoryShelf.animalStories:
      return l10n.catAnimalStories as String;
    case StoryShelf.moralsWisdom:
      return l10n.catMoralsWisdom as String;
    case StoryShelf.science:
      return l10n.catScience as String;
    case StoryShelf.culture:
      return l10n.catCulture as String;
    case StoryShelf.poemsSongs:
      return l10n.catPoemsSongs as String;
    case StoryShelf.safari:
      return l10n.catSafari as String;
  }
}

/// Kadi ya rafu kwenye Maktaba — picha, jina na idadi ya hadithi.
class ShelfTile extends StatelessWidget {
  /// Huunda kadi.
  const ShelfTile({
    super.key,
    required this.shelf,
    required this.onTap,
    this.storyCount,
  });

  /// Rafu inayoonyeshwa.
  final StoryShelf shelf;

  /// Hutekelezwa kadi inapoguswa.
  final VoidCallback onTap;

  /// Idadi ya hadithi kwenye rafu. `null` = bado haijulikani.
  ///
  /// `null` haionyeshi "0": wakati idadi haijapakiwa, kuandika "0 hadithi"
  /// ni uongo. Badala yake hatuonyeshi kitu.
  final int? storyCount;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    final String label = storyShelfLabel(context, shelf);

    return Semantics(
      button: true,
      label: storyCount == null ? label : '$label, $storyCount',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: StoryArtwork(
                  title: label,
                  asset: shelf.asset,
                  accent: shelf.accent,
                  height: double.infinity,
                ),
              ),
              if (storyCount != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.menu_book_rounded,
                      size: AppSpacing.iconSm,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xxs),
                    Text(
                      '$storyCount',
                      style: text.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
