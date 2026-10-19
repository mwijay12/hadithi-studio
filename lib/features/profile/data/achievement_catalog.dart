/// Catalog ya mafanikio (badges) + mantiki ya kuyafungua.
///
/// Badges **22** kutoka Prompt 6 (Task B2), katika makundi manne.
///
/// ## Kwa nini mantiki iko hapa, si kwenye cubit
///
/// "Je, mtumiaji amefungua badge hii?" ni **kanuni ya biashara**, si
/// mchakato wa UI. Kuiweka kwenye cubit kungeifanya isipimwe bila widget.
/// Kwa kuiweka hapa kama kazi tuli (static, bila `BuildContext`), tunaweza
/// kuipima moja kwa moja — na ndiyo tulivyofanya.
///
/// ## `unlockedAt` kwa uwazi
///
/// Tunaweza kuhesabu **kama** badge imefunguliwa, lakini **hatuwezi kujua
/// lini** bila hifadhi. Kwa hivyo [AchievementEvaluator.evaluate] huchukua
/// `unlockedDates` — ramani inayotolewa na hifadhi (mfano
/// `ReadingProgressStore`). Bila hiyo, `unlockedAt` ni `null` na UI
/// haionyeshi tarehe. **Hatubuni tarehe** — "15 Jan 2025" ya uongo ni mbaya
/// kuliko kuacha tupu.
library;

import '../../stories/domain/entities/story_shelf.dart';
import '../../../../core/enums/app_enums.dart';
import '../domain/entities/achievement.dart';
import '../domain/entities/reading_stats.dart';

/// Orodha ya mafanikio yote ya app.
abstract final class AchievementCatalog {
  /// Mafanikio yote — 22.
  static const List<Achievement> all = <Achievement>[
    // -----------------------------------------------------------------------
    // Kusoma (10)
    // -----------------------------------------------------------------------
    Achievement(
      id: 'msomaji_wa_kwanza',
      nameSw: 'Msomaji wa Kwanza',
      nameEn: 'First Reader',
      descriptionSw: 'Umefungua ukurasa wako wa kwanza.',
      descriptionEn: 'You opened your very first page.',
      emoji: '📖',
      category: AchievementCategory.reading,
      tier: BadgeTier.bronze,
      metric: AchievementMetric.storiesRead,
      target: 1,
    ),
    Achievement(
      id: 'msomaji_hodari',
      nameSw: 'Msomaji Hodari',
      nameEn: 'Skilled Reader',
      descriptionSw: 'Hadithi 10 zimekamilika.',
      descriptionEn: 'Ten stories completed.',
      emoji: '📚',
      category: AchievementCategory.reading,
      tier: BadgeTier.silver,
      metric: AchievementMetric.storiesRead,
      target: 10,
    ),
    Achievement(
      id: 'msomaji_bingwa',
      nameSw: 'Msomaji Bingwa',
      nameEn: 'Champion Reader',
      descriptionSw: 'Hadithi 50 — wewe ni bingwa!',
      descriptionEn: 'Fifty stories — you are a champion!',
      emoji: '🏆',
      category: AchievementCategory.reading,
      tier: BadgeTier.gold,
      metric: AchievementMetric.storiesRead,
      target: 50,
    ),
    Achievement(
      id: 'bingwa_wa_hadithi',
      nameSw: 'Bingwa wa Hadithi',
      nameEn: 'Story Champion',
      descriptionSw: 'Hadithi 100 zimekamilika.',
      descriptionEn: 'One hundred stories completed.',
      emoji: '👑',
      category: AchievementCategory.reading,
      tier: BadgeTier.gold,
      metric: AchievementMetric.storiesRead,
      target: 100,
    ),
    Achievement(
      id: 'mtaalam_wa_ngano',
      nameSw: 'Mtaalam wa Ngano',
      nameEn: 'Folk Tale Expert',
      descriptionSw: 'Ngano 10 za Kiswahili.',
      descriptionEn: 'Ten Swahili folk tales.',
      emoji: '📜',
      category: AchievementCategory.reading,
      tier: BadgeTier.silver,
      metric: AchievementMetric.folkTalesRead,
      target: 10,
    ),
    Achievement(
      id: 'msomaji_wa_kiswahili',
      nameSw: 'Msomaji wa Kiswahili',
      nameEn: 'Swahili Reader',
      descriptionSw: 'Hadithi 20 za Kiswahili.',
      descriptionEn: 'Twenty Swahili stories.',
      emoji: '🇹🇿',
      category: AchievementCategory.reading,
      tier: BadgeTier.silver,
      metric: AchievementMetric.swahiliStoriesRead,
      target: 20,
    ),
    Achievement(
      id: 'mchunguzi_wa_sayansi',
      nameSw: 'Mchunguzi wa Sayansi',
      nameEn: 'Science Explorer',
      descriptionSw: 'Hadithi 5 za sayansi.',
      descriptionEn: 'Five science stories.',
      emoji: '🔬',
      category: AchievementCategory.reading,
      tier: BadgeTier.bronze,
      metric: AchievementMetric.scienceStoriesRead,
      target: 5,
    ),
    Achievement(
      id: 'mpenzi_wa_mazingira',
      nameSw: 'Mpenzi wa Mazingira',
      nameEn: 'Nature Lover',
      descriptionSw: 'Hadithi 5 za mazingira.',
      descriptionEn: 'Five environment stories.',
      emoji: '🌿',
      category: AchievementCategory.reading,
      tier: BadgeTier.bronze,
      metric: AchievementMetric.environmentStoriesRead,
      target: 5,
    ),
    Achievement(
      id: 'safari_ya_serengeti',
      nameSw: 'Safari ya Serengeti',
      nameEn: 'Serengeti Safari',
      descriptionSw: 'Hadithi 10 za wanyama.',
      descriptionEn: 'Ten animal stories.',
      emoji: '🦁',
      category: AchievementCategory.reading,
      tier: BadgeTier.silver,
      metric: AchievementMetric.animalStoriesRead,
      target: 10,
    ),
    Achievement(
      id: 'mlima_kilimanjaro',
      nameSw: 'Mlima Kilimanjaro',
      nameEn: 'Mount Kilimanjaro',
      descriptionSw: 'Kurasa 100 zimesomwa.',
      descriptionEn: 'One hundred pages read.',
      emoji: '🏔️',
      category: AchievementCategory.reading,
      tier: BadgeTier.gold,
      metric: AchievementMetric.pagesRead,
      target: 100,
    ),

    // -----------------------------------------------------------------------
    // Streak (5)
    // -----------------------------------------------------------------------
    Achievement(
      id: 'streak_siku_3',
      nameSw: 'Streak ya Siku 3',
      nameEn: '3-Day Streak',
      descriptionSw: 'Ulisoma siku 3 mfululizo.',
      descriptionEn: 'You read three days in a row.',
      emoji: '🔥',
      category: AchievementCategory.streak,
      tier: BadgeTier.bronze,
      metric: AchievementMetric.currentStreak,
      target: 3,
    ),
    Achievement(
      id: 'streak_ya_wiki',
      nameSw: 'Streak ya Wiki',
      nameEn: 'Week Streak',
      descriptionSw: 'Ulisoma siku 7 mfululizo.',
      descriptionEn: 'You read seven days in a row.',
      emoji: '🔥🔥',
      category: AchievementCategory.streak,
      tier: BadgeTier.silver,
      metric: AchievementMetric.currentStreak,
      target: 7,
    ),
    Achievement(
      id: 'streak_ya_wiki_2',
      nameSw: 'Streak ya Wiki 2',
      nameEn: 'Two-Week Streak',
      descriptionSw: 'Ulisoma siku 14 mfululizo.',
      descriptionEn: 'You read fourteen days in a row.',
      emoji: '🔥🔥🔥',
      category: AchievementCategory.streak,
      tier: BadgeTier.silver,
      metric: AchievementMetric.currentStreak,
      target: 14,
    ),
    Achievement(
      id: 'streak_ya_mwezi',
      nameSw: 'Streak ya Mwezi',
      nameEn: 'Month Streak',
      descriptionSw: 'Ulisoma siku 30 mfululizo.',
      descriptionEn: 'You read thirty days in a row.',
      emoji: '🌟',
      category: AchievementCategory.streak,
      tier: BadgeTier.gold,
      metric: AchievementMetric.currentStreak,
      target: 30,
    ),
    Achievement(
      id: 'streak_ya_miezi_3',
      nameSw: 'Streak ya Miezi 3',
      nameEn: 'Three-Month Streak',
      descriptionSw: 'Ulisoma siku 90 mfululizo. Nadra kabisa!',
      descriptionEn: 'Ninety days in a row. Extraordinarily rare!',
      emoji: '💎',
      category: AchievementCategory.streak,
      tier: BadgeTier.special,
      metric: AchievementMetric.currentStreak,
      target: 90,
    ),

    // -----------------------------------------------------------------------
    // Kuandika (4)
    // -----------------------------------------------------------------------
    Achievement(
      id: 'mwandishi_mpya',
      nameSw: 'Mwandishi Mpya',
      nameEn: 'New Author',
      descriptionSw: 'Umeandika hadithi yako ya kwanza.',
      descriptionEn: 'You wrote your first story.',
      emoji: '✏️',
      category: AchievementCategory.creating,
      tier: BadgeTier.bronze,
      metric: AchievementMetric.storiesCreated,
      target: 1,
    ),
    Achievement(
      id: 'mwandishi_hodari',
      nameSw: 'Mwandishi Hodari',
      nameEn: 'Skilled Author',
      descriptionSw: 'Hadithi 5 zimeandikwa.',
      descriptionEn: 'Five stories written.',
      emoji: '🖊️',
      category: AchievementCategory.creating,
      tier: BadgeTier.silver,
      metric: AchievementMetric.storiesCreated,
      target: 5,
    ),
    Achievement(
      id: 'mwandishi_maarufu',
      nameSw: 'Mwandishi Maarufu',
      nameEn: 'Famous Author',
      descriptionSw: 'Hadithi zako zimesomwa mara 100.',
      descriptionEn: 'Your stories have been read 100 times.',
      emoji: '⭐',
      category: AchievementCategory.creating,
      tier: BadgeTier.gold,
      metric: AchievementMetric.storyReadsReceived,
      target: 100,
    ),
    Achievement(
      id: 'mchoraji_wa_picha',
      nameSw: 'Mchoraji wa Picha',
      nameEn: 'Illustrator',
      descriptionSw: 'Picha 10 zilizozalishwa kwa AI.',
      descriptionEn: 'Ten AI-generated illustrations.',
      emoji: '🎨',
      category: AchievementCategory.creating,
      tier: BadgeTier.silver,
      metric: AchievementMetric.imagesCreated,
      target: 10,
    ),

    // -----------------------------------------------------------------------
    // Jamii (3)
    // -----------------------------------------------------------------------
    Achievement(
      id: 'mtoaji_maoni',
      nameSw: 'Mtoaji Maoni',
      nameEn: 'Reviewer',
      descriptionSw: 'Maoni 5 yameandikwa.',
      descriptionEn: 'Five reviews written.',
      emoji: '💬',
      category: AchievementCategory.social,
      tier: BadgeTier.bronze,
      metric: AchievementMetric.reviewsWritten,
      target: 5,
    ),
    Achievement(
      id: 'mshiriki',
      nameSw: 'Mshiriki',
      nameEn: 'Sharer',
      descriptionSw: 'Umeshiriki hadithi mara 3.',
      descriptionEn: 'You shared stories three times.',
      emoji: '🤝',
      category: AchievementCategory.social,
      tier: BadgeTier.bronze,
      metric: AchievementMetric.sharesMade,
      target: 3,
    ),
    Achievement(
      id: 'mfuasi',
      nameSw: 'Mfuasi',
      nameEn: 'Follower',
      descriptionSw: 'Unawafuata waandishi 5.',
      descriptionEn: 'You follow five authors.',
      emoji: '👥',
      category: AchievementCategory.social,
      tier: BadgeTier.silver,
      metric: AchievementMetric.followsMade,
      target: 5,
    ),
  ];

  /// Mafanikio ya kundi fulani.
  static List<Achievement> byCategory(AchievementCategory category) => all
      .where((Achievement a) => a.category == category)
      .toList(growable: false);

  /// Mafanikio maalum (nadra) — kwa sehemu ya juu ya ukurasa (Task B1).
  static List<Achievement> get special => all
      .where((Achievement a) => a.tier == BadgeTier.special)
      .toList(growable: false);

  /// Jumla ya mafanikio.
  static int get total => all.length;
}

/// Hukokotoa hali ya mafanikio kutoka takwimu.
abstract final class AchievementEvaluator {
  /// Hurudisha mafanikio yote, yenye hali ya [stats] iliyojazwa.
  ///
  /// [unlockedDates] hutoka kwenye hifadhi (`id` → tarehe). Bila hiyo,
  /// `unlockedAt` ni `null` — **hatubuni tarehe**.
  static List<Achievement> evaluate(
    ReadingStats stats, {
    Map<String, DateTime> unlockedDates = const <String, DateTime>{},
  }) {
    return AchievementCatalog.all.map((Achievement achievement) {
      final int value = valueFor(achievement.metric, stats);
      final bool unlocked = value >= achievement.target;

      return achievement.copyWith(
        isUnlocked: unlocked,
        currentValue: value,
        progress: unlocked ? 100 : _percent(value, achievement.target),
        unlockedAt: unlocked ? unlockedDates[achievement.id] : null,
      );
    }).toList(growable: false);
  }

  /// Mafanikio yaliyofunguliwa **sasa hivi** — kwa overlay ya Task B3.
  ///
  /// [previous] na [current] ni matokeo ya [evaluate] kabla na baada ya
  /// kusoma. Hii ndiyo inayoamua overlay ipi ionyeshwe.
  static List<Achievement> newlyUnlocked(
    List<Achievement> previous,
    List<Achievement> current,
  ) {
    final Set<String> alreadyUnlocked = previous
        .where((Achievement a) => a.isUnlocked)
        .map((Achievement a) => a.id)
        .toSet();

    return current
        .where((Achievement a) => a.isUnlocked && !alreadyUnlocked.contains(a.id))
        .toList(growable: false);
  }

  /// Idadi ya mafanikio yaliyofunguliwa.
  static int unlockedCount(List<Achievement> achievements) =>
      achievements.where((Achievement a) => a.isUnlocked).length;

  /// Thamani ya sasa ya [metric] kutoka [stats].
  ///
  /// Hapa ndipo mahali **pamoja** panapohusisha metric na data: kuongeza
  /// badge mpya kunahitaji tawi moja hapa, na compiler **itailalamikia**
  /// thamani yoyote ya enum isiyoshughulikiwa.
  static int valueFor(AchievementMetric metric, ReadingStats stats) {
    switch (metric) {
      case AchievementMetric.storiesRead:
        return stats.totalStoriesRead;
      case AchievementMetric.folkTalesRead:
        return stats.storiesInCategory(StoryCategory.ngano);
      case AchievementMetric.swahiliStoriesRead:
        return stats.storiesInCategory(StoryCategory.hadithi_za_kiswahili);
      case AchievementMetric.scienceStoriesRead:
        return stats.storiesInShelf(StoryShelf.science);
      case AchievementMetric.environmentStoriesRead:
        return stats.storiesInCategory(StoryCategory.mazingira);
      case AchievementMetric.animalStoriesRead:
        return stats.storiesInShelf(StoryShelf.animalStories);
      case AchievementMetric.pagesRead:
        return stats.totalPagesRead;
      case AchievementMetric.currentStreak:
        return stats.streak.currentStreak;
      case AchievementMetric.storiesCreated:
        return stats.storiesCreated;
      case AchievementMetric.storyReadsReceived:
        return stats.storyReadsReceived;
      case AchievementMetric.imagesCreated:
        return stats.imagesCreated;
      case AchievementMetric.reviewsWritten:
        return stats.reviewsWritten;
      case AchievementMetric.sharesMade:
        return stats.sharesMade;
      case AchievementMetric.followsMade:
        return stats.followsMade;
    }
  }

  /// Asilimia 0–100, ikilindwa dhidi ya kugawanya kwa sifuri.
  static int _percent(int value, int target) {
    if (target <= 0) return 100;
    final int percent = ((value / target) * 100).round();
    if (percent < 0) return 0;
    if (percent > 100) return 100;
    return percent;
  }
}
