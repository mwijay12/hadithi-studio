/// Mafanikio (badges) — sehemu ya gamification ya Hadithi Studio.
///
/// ## Uamuzi wa muundo: kimoja au viwili?
///
/// Prompt 6 inaomba class moja `Achievement` yenye **majina** (nameSw,
/// nameEn, iconAsset…), **kiwango** (target) na **hali** (isUnlocked,
/// progress, unlockedAt). Kuchanganya viwili kunahatarisha: catalog ya
/// badges ni **data isiyobadilika**, wakati hali ni **kwa mtumiaji mmoja**.
///
/// Tulichagua class moja (kama spec) **lakini** [Achievement.copyWith] ndiyo
/// njia pekee ya kubadilisha hali. Catalog hutoa nakala za "haijafunguliwa",
/// na [AchievementEvaluator] hurudisha nakala mpya zilizojazwa. Hivyo badges
/// tuli (const) zinabaki salama — hakuna mahali panapobadilisha catalog kwa
/// bahati mbaya.
///
/// ## Kwa nini `metric` na si `requirement` ya maandishi
///
/// Badge yenyewe **haitoi** jibu la kama mtumiaji ameifungua; inasema
/// **kitu gani kupima** ([metric]) na **kiwango gani** ([target]). Mantiki
/// ya kupima iko mahali pamoja ([AchievementEvaluator]) — hivyo kubadilisha
/// kanuni ya badge hauhitaji kubadilisha UI, na tunaweza kuipima.
library;

/// Kundi la mafanikio — hutumika kwenye tabo za ukurasa.
enum AchievementCategory {
  /// Kusoma hadithi.
  reading,

  /// Kuandika hadithi.
  creating,

  /// Mfululizo wa siku.
  streak,

  /// Jamii — maoni, kushiriki, kufuata.
  social;

  /// Jina kwa Kiswahili (kwa tabo).
  ///
  /// Haya ni maneno mafupi ya UI; hayahitaji ARB kwa sababu yanahusiana
  /// moja-kwa-moja na enum hii (kama `HotspotType`).
  String get labelSw => switch (this) {
        AchievementCategory.reading => 'Kusoma',
        AchievementCategory.creating => 'Kuandika',
        AchievementCategory.streak => 'Streak',
        AchievementCategory.social => 'Jamii',
      };

  /// Jina kwa Kiingereza.
  String get labelEn => switch (this) {
        AchievementCategory.reading => 'Reading',
        AchievementCategory.creating => 'Creating',
        AchievementCategory.streak => 'Streak',
        AchievementCategory.social => 'Social',
      };

  /// Jina kwa lugha iliyochaguliwa sasa.
  String label({required bool swahili}) => swahili ? labelSw : labelEn;
}

/// Daraja la medali — hutumika kwa gradient ya metali (Task H3).
enum BadgeTier {
  /// Shaba — mafanikio ya kwanza.
  bronze,

  /// Fedha — mafanikio ya kati.
  silver,

  /// Dhahabu — mafanikio makubwa.
  gold,

  /// Maalum — nadra; hupata mng'ao (Task B1).
  special,
}

/// Kitu kinachopimwa kwa badge.
///
/// Kila thamani inahesabiwa kutoka [ReadingStats] na
/// [AchievementEvaluator]. Kuongeza badge mpya kwa kitu kipya kinachopimwa
/// kunahitaji tu kuongeza thamani hapa na tawi moja kwenye switch ya
/// mfululizo — hakuna UI inayobadilika.
enum AchievementMetric {
  /// Hadithi zilizosomwa kwa jumla.
  storiesRead,

  /// Ngano za Kiswahili.
  folkTalesRead,

  /// Hadithi za Kiswahili.
  swahiliStoriesRead,

  /// Hadithi za sayansi.
  scienceStoriesRead,

  /// Hadithi za mazingira.
  environmentStoriesRead,

  /// Hadithi za wanyama.
  animalStoriesRead,

  /// Kurasa zilizosomwa.
  pagesRead,

  /// Siku mfululizo (streak ya sasa).
  currentStreak,

  /// Hadithi zilizoandikwa na mtumiaji.
  storiesCreated,

  /// Wasomaji wa hadithi zilizoandikwa na mtumiaji.
  storyReadsReceived,

  /// Picha zilizozalishwa kwa AI.
  imagesCreated,

  /// Maoni yaliyoandikwa.
  reviewsWritten,

  /// Kushiriki.
  sharesMade,

  /// Wafuasi.
  followsMade,
}

/// Mafanikio moja — maelezo pamoja na hali ya mtumiaji.
class Achievement {
  /// Huunda mafanikio.
  const Achievement({
    required this.id,
    required this.nameSw,
    required this.nameEn,
    required this.descriptionSw,
    required this.descriptionEn,
    required this.emoji,
    required this.category,
    required this.tier,
    required this.metric,
    required this.target,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0,
    this.currentValue = 0,
  });

  /// Kitambulisho cha kudumu (kwa hifadhi na API).
  final String id;

  /// Jina kwa Kiswahili.
  final String nameSw;

  /// Jina kwa Kiingereza.
  final String nameEn;

  /// Maelezo mafupi kwa Kiswahili.
  final String descriptionSw;

  /// Maelezo mafupi kwa Kiingereza.
  final String descriptionEn;

  /// Emoji ya badge.
  ///
  /// **Kwa nini emoji, si `iconAsset`:** Prompt 6 inaomba `iconAsset`, lakini
  /// `assets/images/badges/` **haipo** — na mradi una ~40 njia za assets
  /// ambazo pia hazipo. Emoji **hupangwa na mfumo** na hazishindwi
  /// kupakia. Picha za medali zinaweza kuja baadaye; wakati huo `emoji`
  /// inabaki kama akiba.
  final String emoji;

  /// Kundi la mafanikio.
  final AchievementCategory category;

  /// Daraja la medali.
  final BadgeTier tier;

  /// Kitu kinachopimwa.
  final AchievementMetric metric;

  /// Kiwango cha kufungua.
  final int target;

  /// `true` = mtumiaji ameifungua.
  final bool isUnlocked;

  /// Tarehe ya kufungua (`null` = haijafunguliwa).
  final DateTime? unlockedAt;

  /// Maendeleo 0–100 (kwa upau wa maendeleo).
  final int progress;

  /// Thamani ya sasa ya [metric] — kwa maandishi "24/50 hadithi".
  final int currentValue;

  /// Jina kwa lugha iliyochaguliwa sasa.
  String name({required bool swahili}) => swahili ? nameSw : nameEn;

  /// Maelezo kwa lugha iliyochaguliwa sasa.
  String description({required bool swahili}) =>
      swahili ? descriptionSw : descriptionEn;

  /// Nakala mpya yenye hali iliyobadilika.
  Achievement copyWith({
    bool? isUnlocked,
    DateTime? unlockedAt,
    int? progress,
    int? currentValue,
  }) {
    return Achievement(
      id: id,
      nameSw: nameSw,
      nameEn: nameEn,
      descriptionSw: descriptionSw,
      descriptionEn: descriptionEn,
      emoji: emoji,
      category: category,
      tier: tier,
      metric: metric,
      target: target,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}
