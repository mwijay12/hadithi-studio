/// Takwimu za kusoma, streak, na daraja la msomaji.
///
/// ## Uamuzi: hesabu zinatoka kwenye ramani moja, si kwenye fields nyingi
///
/// Prompt 6 ilipendekeza `categoryBreakdown: Map<String, int>`. Tulichagua
/// ramani **zenye aina** (`Map<StoryShelf, int>`, `Map<StoryCategory, int>`)
/// badala ya `Map<String, int>`, kwa sababu:
///
/// * `'wanyama'` vs `'Wanyama'` vs `'animal'` ni hitilafu inayosubiri kutokea
///   kwenye `Map<String, int>`. Enum huzuia hilo wakati wa kukusanya msimbo.
/// * Badge kama "Safari ya Serengeti" (hadithi 10 za wanyama) hupata thamani
///   yake kutoka ramani hiyo — **hakuna field ya pili inayoweza kutofautiana
///   nayo**.
///
/// Vilevile: hatuna fields tofauti za `scienceStoriesRead`,
/// `animalStoriesRead`, n.k. Hesabu hizo **hukokotolewa** kutoka ramani.
/// Field mbili zinazosema kitu kimoja hukwama siku moja — moja husahau
/// kuongezwa.
library;

import '../../../stories/domain/entities/story_shelf.dart';
import '../../../../core/enums/app_enums.dart';

/// Shughuli ya kusoma ya siku moja.
class DailyReading {
  /// Huunda shughuli ya [date].
  const DailyReading({
    required this.date,
    this.pagesRead = 0,
    this.minutesRead = 0,
  });

  /// Siku.
  final DateTime date;

  /// Kurasa zilizosomwa siku hiyo.
  final int pagesRead;

  /// Dakika zilizotumika siku hiyo.
  final int minutesRead;

  /// `true` = mtumiaji alisoma siku hii (kwa hesabu ya streak).
  bool get hasRead => pagesRead > 0 || minutesRead > 0;
}

/// Mfululizo wa siku za kusoma.
class ReadingStreak {
  /// Huunda streak.
  const ReadingStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastReadDate,
    this.longestStreakDate,
    this.totalReadingDays = 0,
    this.isActiveToday = false,
  });

  /// Siku mfululizo hadi sasa.
  final int currentStreak;

  /// Rekodi ya juu kabisa.
  final int longestStreak;

  /// Tarehe ya kusoma ya mwisho.
  final DateTime? lastReadDate;

  /// Tarehe ambapo [longestStreak] iliisha — kwa "23 siku (Oktoba 2024)".
  final DateTime? longestStreakDate;

  /// Jumla ya siku za kusoma.
  final int totalReadingDays;

  /// `true` = mtumiaji amesoma **leo**.
  ///
  /// Hii haikokotolewi kutoka [lastReadDate] pekee kwa sababu "leo" hutegemea
  /// saa ya kifaa — hivyo inawekwa wazi na anayetoa data.
  final bool isActiveToday;

  /// `true` = streak ipo hai (amesoma leo, au mfululizo bado haujavunjika).
  bool get isAlive => isActiveToday || currentStreak > 0;

  /// Nakala mpya yenye mabadiliko.
  ReadingStreak copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastReadDate,
    int? totalReadingDays,
  }) {
    return ReadingStreak(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      longestStreakDate: longestStreakDate,
      totalReadingDays: totalReadingDays ?? this.totalReadingDays,
    );
  }
}

/// Daraja la msomaji — gamification ya "level" (Task B4).
///
/// **Kwa nini si `ReadingLevel`:** `ReadingLevel` **ipo tayari** kwenye
/// `core/enums/app_enums.dart` na inamaanisha kitu kingine kabisa — kiwango
/// cha **hadithi** (mtoto mdogo, darasa 1-2…). Kutumia jina lile kwa daraja
/// la mtumiaji kungechanganya vitu viwili tofauti kwenye msimbo mmoja.
enum ReaderRank {
  /// 0–5 hadithi.
  mwanafunzi(
    'Mwanafunzi',
    'Beginner',
    '🌱',
    0,
    6,
  ),

  /// 6–15 hadithi.
  msomaji(
    'Msomaji',
    'Reader',
    '📗',
    6,
    16,
  ),

  /// 16–30 hadithi.
  msomajiHodari(
    'Msomaji Hodari',
    'Skilled Reader',
    '📘',
    16,
    31,
  ),

  /// 31–75 hadithi.
  msomajiBingwa(
    'Msomaji Bingwa',
    'Champion Reader',
    '📕',
    31,
    76,
  ),

  /// 76+ hadithi.
  bingwaWaHadithi(
    'Bingwa wa Hadithi',
    'Story Champion',
    '👑',
    76,
    null,
  );

  const ReaderRank(
    this.nameSw,
    this.nameEn,
    this.emoji,
    this.minStories,
    this.nextThreshold,
  );

  /// Jina kwa Kiswahili.
  final String nameSw;

  /// Jina kwa Kiingereza.
  final String nameEn;

  /// Emoji ya daraja.
  final String emoji;

  /// Hadithi za chini kabisa za daraja hili.
  final int minStories;

  /// Hadithi zinazohitajika kwa daraja linalofuata (`null` = daraja la juu).
  final int? nextThreshold;

  /// Namba ya daraja (1–5) — kwa "Level 3".
  int get number => index + 1;

  /// Jina kwa lugha iliyochaguliwa sasa.
  String label({required bool swahili}) => swahili ? nameSw : nameEn;

  /// `true` = daraja la juu kabisa.
  bool get isMax => nextThreshold == null;

  /// Daraja linalofuata (`null` = tayari yupo juu).
  ReaderRank? get next {
    final int? threshold = nextThreshold;
    if (threshold == null) return null;
    return forStories(threshold);
  }

  /// Daraja la mtumiaji mwenye [stories] hadithi.
  static ReaderRank forStories(int stories) {
    // Tunapita kinyume (juu → chini) na kurudisha la kwanza linalolingana;
    // hivyo mipaka inaeleweka kwa mtazamo mmoja.
    for (final ReaderRank rank in ReaderRank.values.reversed) {
      if (stories >= rank.minStories) return rank;
    }
    return ReaderRank.mwanafunzi;
  }

  /// Maendeleo kuelekea daraja linalofuata — 0.0 hadi 1.0.
  ///
  /// Hurudisha `1.0` kwa daraja la juu (hakuna la kufikia).
  double progressFrom(int stories) {
    final int? threshold = nextThreshold;
    if (threshold == null) return 1.0;

    final int span = threshold - minStories;
    if (span <= 0) return 1.0;

    final int done = stories - minStories;
    if (done <= 0) return 0.0;
    if (done >= span) return 1.0;
    return done / span;
  }

  /// Hadithi zilizobaki kufikia daraja linalofuata (`0` kwa la juu).
  int storiesToNext(int stories) {
    final int? threshold = nextThreshold;
    if (threshold == null) return 0;
    final int remaining = threshold - stories;
    return remaining < 0 ? 0 : remaining;
  }
}

/// Takwimu kamili za kusoma za mtumiaji mmoja.
class ReadingStats {
  /// Huunda takwimu.
  const ReadingStats({
    this.totalStoriesRead = 0,
    this.totalPagesRead = 0,
    this.totalMinutesRead = 0,
    this.storiesReadThisWeek = 0,
    this.pagesReadThisWeek = 0,
    this.weeklyActivity = const <DailyReading>[],
    this.storiesByShelf = const <StoryShelf, int>{},
    this.storiesByCategory = const <StoryCategory, int>{},
    this.storiesCreated = 0,
    this.storyReadsReceived = 0,
    this.imagesCreated = 0,
    this.reviewsWritten = 0,
    this.sharesMade = 0,
    this.followsMade = 0,
    this.streak = const ReadingStreak(),
    this.totalPoints = 0,
  });

  /// Takwimu tupu — mwanzo wa mtumiaji mpya.
  static const ReadingStats empty = ReadingStats();

  /// Jumla ya hadithi zilizosomwa.
  final int totalStoriesRead;

  /// Jumla ya kurasa.
  final int totalPagesRead;

  /// Jumla ya dakika.
  final int totalMinutesRead;

  /// Hadithi zilizosomwa wiki hii.
  final int storiesReadThisWeek;

  /// Kurasa zilizosomwa wiki hii.
  final int pagesReadThisWeek;

  /// Shughuli za siku 7 (Jumatatu → Jumapili).
  final List<DailyReading> weeklyActivity;

  /// Hadithi kwa rafu.
  final Map<StoryShelf, int> storiesByShelf;

  /// Hadithi kwa kundi.
  final Map<StoryCategory, int> storiesByCategory;

  /// Hadithi zilizoandikwa na mtumiaji.
  final int storiesCreated;

  /// Wasomaji waliofika hadithi za mtumiaji.
  final int storyReadsReceived;

  /// Picha zilizozalishwa kwa AI.
  final int imagesCreated;

  /// Maoni yaliyoandikwa.
  final int reviewsWritten;

  /// Kushiriki.
  final int sharesMade;

  /// Wafuasi.
  final int followsMade;

  /// Streak.
  final ReadingStreak streak;

  /// Pointi za jumla (leaderboard).
  final int totalPoints;

  /// Daraja la sasa la msomaji.
  ReaderRank get rank => ReaderRank.forStories(totalStoriesRead);

  /// Idadi ya hadithi za rafu fulani.
  int storiesInShelf(StoryShelf shelf) => storiesByShelf[shelf] ?? 0;

  /// Idadi ya hadithi za kundi fulani.
  int storiesInCategory(StoryCategory category) =>
      storiesByCategory[category] ?? 0;

  /// Jumla ya kurasa za wiki — hutumika kwenye "Kurasa 142 wiki hii".
  int get weeklyPagesFromActivity => weeklyActivity.fold<int>(
        0,
        (int total, DailyReading day) => total + day.pagesRead,
      );

  /// Nakala mpya yenye mabadiliko.
  ReadingStats copyWith({
    int? totalStoriesRead,
    int? totalPagesRead,
    int? totalMinutesRead,
    int? storiesReadThisWeek,
    int? pagesReadThisWeek,
    List<DailyReading>? weeklyActivity,
    Map<StoryShelf, int>? storiesByShelf,
    Map<StoryCategory, int>? storiesByCategory,
    int? storiesCreated,
    int? storyReadsReceived,
    int? imagesCreated,
    int? reviewsWritten,
    int? sharesMade,
    int? followsMade,
    ReadingStreak? streak,
    int? totalPoints,
  }) {
    return ReadingStats(
      totalStoriesRead: totalStoriesRead ?? this.totalStoriesRead,
      totalPagesRead: totalPagesRead ?? this.totalPagesRead,
      totalMinutesRead: totalMinutesRead ?? this.totalMinutesRead,
      storiesReadThisWeek: storiesReadThisWeek ?? this.storiesReadThisWeek,
      pagesReadThisWeek: pagesReadThisWeek ?? this.pagesReadThisWeek,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      storiesByShelf: storiesByShelf ?? this.storiesByShelf,
      storiesByCategory: storiesByCategory ?? this.storiesByCategory,
      storiesCreated: storiesCreated ?? this.storiesCreated,
      storyReadsReceived: storyReadsReceived ?? this.storyReadsReceived,
      imagesCreated: imagesCreated ?? this.imagesCreated,
      reviewsWritten: reviewsWritten ?? this.reviewsWritten,
      sharesMade: sharesMade ?? this.sharesMade,
      followsMade: followsMade ?? this.followsMade,
      streak: streak ?? this.streak,
      totalPoints: totalPoints ?? this.totalPoints,
    );
  }
}
