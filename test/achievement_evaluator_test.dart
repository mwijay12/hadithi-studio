/// Majaribio ya catalog ya mafanikio, daraja la msomaji, na mantiki ya
/// kufungua badges.
///
/// Hii ni gamification — kitu kinachowafanya watoto warudi kila siku. Kama
/// mantiki ni mbovu (badge inafunguka mapema, au haifunguki kamwe), motisha
/// inaharibika bila mtu yeyote kuona kosa. Kwa hivyo inapimwa hapa.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/enums/app_enums.dart';
import 'package:hadithi_studio/features/profile/data/achievement_catalog.dart';
import 'package:hadithi_studio/features/profile/domain/entities/achievement.dart';
import 'package:hadithi_studio/features/profile/domain/entities/reading_stats.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story_shelf.dart';

void main() {
  group('AchievementCatalog', () {
    test('ina mafanikio 22', () {
      expect(AchievementCatalog.total, 22);
    });

    test('ids zote ni za kipekee', () {
      final Set<String> ids =
          AchievementCatalog.all.map((Achievement a) => a.id).toSet();
      expect(ids.length, AchievementCatalog.total);
    });

    test('kila badge ina majina na maelezo ya lugha mbili', () {
      for (final Achievement a in AchievementCatalog.all) {
        expect(a.nameSw, isNotEmpty, reason: '${a.id} haina nameSw');
        expect(a.nameEn, isNotEmpty, reason: '${a.id} haina nameEn');
        expect(a.descriptionSw, isNotEmpty, reason: '${a.id} haina descSw');
        expect(a.descriptionEn, isNotEmpty, reason: '${a.id} haina descEn');
        expect(a.emoji, isNotEmpty, reason: '${a.id} haina emoji');
      }
    });

    test('kila target ni zaidi ya sifuri', () {
      for (final Achievement a in AchievementCatalog.all) {
        expect(a.target, greaterThan(0), reason: '${a.id} target si sahihi');
      }
    });

    test('mgawanyo wa makundi ni 10/5/4/3', () {
      expect(AchievementCatalog.byCategory(AchievementCategory.reading).length, 10);
      expect(AchievementCatalog.byCategory(AchievementCategory.streak).length, 5);
      expect(AchievementCatalog.byCategory(AchievementCategory.creating).length, 4);
      expect(AchievementCatalog.byCategory(AchievementCategory.social).length, 3);
    });

    test('mafanikio maalum ni yale ya tier special', () {
      final List<Achievement> special = AchievementCatalog.special;
      expect(special.length, 1);
      expect(special.first.id, 'streak_ya_miezi_3');
      expect(special.first.tier, BadgeTier.special);
    });
  });

  group('ReaderRank — mipaka ya daraja', () {
    void expectRank(int stories, ReaderRank expected) {
      expect(
        ReaderRank.forStories(stories),
        expected,
        reason: '$stories hadithi zinapaswa kuwa ${expected.name}',
      );
    }

    test('mipaka yote ni sahihi', () {
      expectRank(0, ReaderRank.mwanafunzi);
      expectRank(5, ReaderRank.mwanafunzi);
      expectRank(6, ReaderRank.msomaji);
      expectRank(15, ReaderRank.msomaji);
      expectRank(16, ReaderRank.msomajiHodari);
      expectRank(30, ReaderRank.msomajiHodari);
      expectRank(31, ReaderRank.msomajiBingwa);
      expectRank(75, ReaderRank.msomajiBingwa);
      expectRank(76, ReaderRank.bingwaWaHadithi);
      expectRank(1000, ReaderRank.bingwaWaHadithi);
    });

    test('namba za daraja ni 1 hadi 5', () {
      expect(ReaderRank.mwanafunzi.number, 1);
      expect(ReaderRank.bingwaWaHadithi.number, 5);
    });

    test('daraja la juu halina linalofuata', () {
      expect(ReaderRank.bingwaWaHadithi.isMax, isTrue);
      expect(ReaderRank.bingwaWaHadithi.next, isNull);
      expect(ReaderRank.mwanafunzi.next, ReaderRank.msomaji);
    });

    test('maendeleo kati ya madaraja', () {
      // Daraja 3: 16–30, linalofuata linaanza 31. Hadithi 24 → (24-16)/15.
      final double progress = ReaderRank.msomajiHodari.progressFrom(24);
      expect(progress, closeTo(8 / 15, 0.001));
      expect(ReaderRank.msomajiHodari.storiesToNext(24), 7);
    });

    test('maendeleo hukaa kati ya 0 na 1', () {
      expect(ReaderRank.mwanafunzi.progressFrom(0), 0.0);
      expect(ReaderRank.mwanafunzi.progressFrom(100), 1.0);
      expect(ReaderRank.bingwaWaHadithi.progressFrom(10), 1.0);
    });
  });

  group('AchievementEvaluator.evaluate', () {
    test('mtumiaji mpya hajafungua kitu', () {
      final List<Achievement> result =
          AchievementEvaluator.evaluate(ReadingStats.empty);
      expect(AchievementEvaluator.unlockedCount(result), 0);
    });

    test('hadithi 1 hufungua "Msomaji wa Kwanza" pekee', () {
      final List<Achievement> result = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 1),
      );
      final List<String> unlocked = result
          .where((Achievement a) => a.isUnlocked)
          .map((Achievement a) => a.id)
          .toList();

      expect(unlocked, <String>['msomaji_wa_kwanza']);
    });

    test('hadithi 10 hufungua Msomaji wa Kwanza na Msomaji Hodari', () {
      final List<Achievement> result = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 10),
      );
      final Set<String> unlocked = result
          .where((Achievement a) => a.isUnlocked)
          .map((Achievement a) => a.id)
          .toSet();

      expect(unlocked.contains('msomaji_wa_kwanza'), isTrue);
      expect(unlocked.contains('msomaji_hodari'), isTrue);
      expect(unlocked.contains('msomaji_bingwa'), isFalse);
    });

    test('maendeleo huhesabiwa kwa asilimia sahihi', () {
      final List<Achievement> result = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 3),
      );
      final Achievement hodari = result
          .firstWhere((Achievement a) => a.id == 'msomaji_hodari');

      expect(hodari.isUnlocked, isFalse);
      expect(hodari.currentValue, 3);
      expect(hodari.progress, 30); // 3/10
    });

    test('maendeleo hayazidi 100', () {
      final List<Achievement> result = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 500),
      );
      for (final Achievement a in result) {
        expect(a.progress, lessThanOrEqualTo(100));
        expect(a.progress, greaterThanOrEqualTo(0));
      }
    });

    test('hesabu za kundi na rafu hutoka kwenye ramani', () {
      final List<Achievement> result = AchievementEvaluator.evaluate(
        const ReadingStats(
          storiesByShelf: <StoryShelf, int>{StoryShelf.science: 7},
          storiesByCategory: <StoryCategory, int>{StoryCategory.ngano: 4},
        ),
      );

      final Achievement sayansi = result
          .firstWhere((Achievement a) => a.id == 'mchunguzi_wa_sayansi');
      final Achievement ngano =
          result.firstWhere((Achievement a) => a.id == 'mtaalam_wa_ngano');

      expect(sayansi.isUnlocked, isTrue); // 7 >= 5
      expect(sayansi.currentValue, 7);
      expect(ngano.isUnlocked, isFalse); // 4 < 10
      expect(ngano.currentValue, 4);
      expect(ngano.progress, 40);
    });

    test('streak hufungua badge za streak', () {
      final List<Achievement> result = AchievementEvaluator.evaluate(
        const ReadingStats(streak: ReadingStreak(currentStreak: 8)),
      );
      final Set<String> unlocked = result
          .where((Achievement a) => a.isUnlocked)
          .map((Achievement a) => a.id)
          .toSet();

      expect(unlocked.contains('streak_siku_3'), isTrue);
      expect(unlocked.contains('streak_ya_wiki'), isTrue); // 8 >= 7
      expect(unlocked.contains('streak_ya_wiki_2'), isFalse); // 8 < 14
    });

    test('tarehe ya kufungua hutungwa KAMWE bila hifadhi', () {
      final List<Achievement> result = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 50),
      );
      for (final Achievement a in result.where((Achievement x) => x.isUnlocked)) {
        expect(a.unlockedAt, isNull);
      }
    });

    test('tarehe hutoka kwenye hifadhi ikiwepo', () {
      final DateTime earned = DateTime(2026, 1, 15);
      final List<Achievement> result = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 50),
        unlockedDates: <String, DateTime>{'msomaji_bingwa': earned},
      );
      final Achievement bingwa =
          result.firstWhere((Achievement a) => a.id == 'msomaji_bingwa');
      expect(bingwa.unlockedAt, earned);
    });
  });

  group('AchievementEvaluator.newlyUnlocked', () {
    test('hupata badge iliyofunguliwa sasa hivi', () {
      final List<Achievement> before = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 9),
      );
      final List<Achievement> after = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 10),
      );

      final List<Achievement> fresh =
          AchievementEvaluator.newlyUnlocked(before, after);

      expect(fresh.length, 1);
      expect(fresh.first.id, 'msomaji_hodari');
    });

    test('haonyeshi badge zilizofunguliwa zamani', () {
      final List<Achievement> before = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 10),
      );
      final List<Achievement> after = AchievementEvaluator.evaluate(
        const ReadingStats(totalStoriesRead: 11),
      );

      expect(AchievementEvaluator.newlyUnlocked(before, after), isEmpty);
    });

    test('hupata badge nyingi kwa mpigo mmoja', () {
      final List<Achievement> before = AchievementEvaluator.evaluate(
        ReadingStats.empty,
      );
      final List<Achievement> after = AchievementEvaluator.evaluate(
        const ReadingStats(
          totalStoriesRead: 1,
          streak: ReadingStreak(currentStreak: 3),
        ),
      );

      final List<Achievement> fresh =
          AchievementEvaluator.newlyUnlocked(before, after);
      final Set<String> ids =
          fresh.map((Achievement a) => a.id).toSet();

      expect(ids, containsAll(<String>['msomaji_wa_kwanza', 'streak_siku_3']));
      expect(fresh.length, 2);
    });
  });
}
