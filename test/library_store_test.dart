/// Majaribio ya [LibraryStore] — hifadhi ya kudumu (C7, C8, C10, na C9).
///
/// ## Kwa nini majaribio haya ni muhimu hasa
///
/// Kila kitu kilichokuwa kimevunjika hapo awali kilikuwa **kwenye kumbukumbu
/// pekee**, na hakuna jaribio lililoweza kuona tofauti: UI ilionyesha
/// "imehifadhiwa" na jiwe lilikuwa limeanguka kimya. Majaribio haya
/// huthibitisha kitu kimoja tu: **baada ya kuandika, mfano mpya husoma
/// thamani ile ile**. Ndiyo maana ya "kudumu".
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/library_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    // Hifadhi ya kumbukumbu — kila jaribio linaanza na karatasi tupu.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('C10 — onboarding hairdi kila kufungua', () {
    test('haijamalizika kabla ya kuandika', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      expect(store.onboardingDone, isFalse);
    });

    test('inadumu baada ya kuandika na kusoma kwa mfano MPYA', () async {
      final LibraryStore first = LibraryStore();
      await first.restore();
      await first.completeOnboarding();
      expect(first.onboardingDone, isTrue);

      // Mfano mpya = app imefunguliwa upya.
      final LibraryStore second = LibraryStore();
      await second.restore();
      expect(
        second.onboardingDone,
        isTrue,
        reason: 'onboarding ilirudi — ndiyo C10',
      );
    });
  });

  group('C7 — "Fuata" inahifadhiwa', () {
    test('toggleFollow inarudisha hali mpya na inadumu', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();

      final bool now = await store.toggleFollow('Neema Mushi');
      expect(now, isTrue);
      expect(store.isFollowing('Neema Mushi'), isTrue);

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.isFollowing('Neema Mushi'), isTrue);
      expect(reopened.followedAuthors, <String>{'Neema Mushi'});
    });

    test('kufuata mara ya pili hufuta', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.toggleFollow('Neema Mushi');
      final bool now = await store.toggleFollow('Neema Mushi');
      expect(now, isFalse);

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.isFollowing('Neema Mushi'), isFalse);
    });

    test('jina tupu halirekodiwi', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      expect(await store.toggleFollow(''), isFalse);
      expect(store.followedAuthors, isEmpty);
    });
  });

  group('C8 — alama ya hadithi inadumu', () {
    test('toggleSaved inadumu', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();

      final bool saved = await store.toggleSaved('safari-ya-simba');
      expect(saved, isTrue);

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.isSaved('safari-ya-simba'), isTrue);
    });

    test('kuondoa alama kunadumu', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.toggleSaved('safari-ya-simba');
      final bool now = await store.toggleSaved('safari-ya-simba');
      expect(now, isFalse);

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.isSaved('safari-ya-simba'), isFalse);
    });
  });

  group('C9 — maendeleo halisi ya kusoma', () {
    test('ukurasa wa mwisho unadumu', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.saveLastPage('safari-ya-simba', 3);

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.lastPage('safari-ya-simba'), 3);
    });

    test('hadithi isiyoanzwa haina maendeleo (sivyo 0)', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      // `null` na `0` ni vitu tofauti: `null` = haijaanza, `0` = ukurasa wa
      // kwanza umesomwa. Kuchanganya hivi ndiko kungezalisha "45%" ya uongo.
      expect(store.lastPage('haijaonwa'), isNull);
    });

    test('inProgressStoryIds hupanga ya karibuni kwanza', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.saveLastPage('a', 1);
      await store.saveLastPage('b', 2);

      expect(store.inProgressStoryIds, <String>['b', 'a']);
    });

    test('ukurasa hasi hauhifadhiwi', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.saveLastPage('a', -1);
      expect(store.lastPage('a'), isNull);
    });
  });

  group('rasimu za mtoto', () {
    test('addDraft inadumu na mpya inakuja kwanza', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();

      final DraftStory older = DraftStory(
        id: 'draft-1',
        titleSw: 'Simba Mdogo',
        titleEn: 'Little Lion',
        pagesSw: const <String>['Ukurasa wa kwanza.'],
        pagesEn: const <String>[],
        createdAt: DateTime(2026, 1, 1),
      );
      final DraftStory newer = DraftStory(
        id: 'draft-2',
        titleSw: 'Tembo',
        titleEn: 'Elephant',
        pagesSw: const <String>['Tembo mkubwa.', 'Tembo mdogo.'],
        pagesEn: const <String>[],
        createdAt: DateTime(2026, 2, 1),
      );

      expect(await store.addDraft(older), isTrue);
      expect(await store.addDraft(newer), isTrue);
      expect(store.drafts.first.id, 'draft-2');

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.drafts.map((DraftStory d) => d.id), <String>[
        'draft-2',
        'draft-1',
      ]);
      expect(reopened.drafts.first.pageCount, 2);
    });

    test('removeDraft inadumu', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.addDraft(
        DraftStory(
          id: 'draft-1',
          titleSw: 'Hadithi',
          titleEn: 'Story',
          pagesSw: const <String>['Moja.'],
          pagesEn: const <String>[],
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      expect(await store.removeDraft('draft-1'), isTrue);
      expect(store.drafts, isEmpty);

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.drafts, isEmpty);
    });

    test('rasimu iliyoharibika hairudishi kosa', () async {
      // JSON mbovu kwenye hifadhi haipaswi kuzuia app kufunguka.
      SharedPreferences.setMockInitialValues(<String, Object>{
        LibraryStore.draftsKey: <String>['{si json', '{"id":""}'],
      });
      final LibraryStore store = LibraryStore();
      await store.restore();
      expect(store.drafts, isEmpty);
    });

    test('DraftStory.fromJson hukataa data isiyo kamili', () {
      expect(DraftStory.fromJson(<String, dynamic>{}), isNull);
      expect(
        DraftStory.fromJson(<String, dynamic>{'id': '', 'titleSw': 'x'}),
        isNull,
      );
      expect(
        DraftStory.fromJson(<String, dynamic>{'id': 'a', 'titleSw': 'Jina'})
            ?.titleEn,
        'Jina',
        reason: 'titleEn hutoka titleSw kama haipo',
      );
    });
  });

  group('wasifu wa mtoto', () {
    test('jina na umri vinadumu', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.saveChild(name: '  Amina  ', age: 'age5to7');

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.childName, 'Amina', reason: 'nafasi hukatwa');
      expect(reopened.childAge, 'age5to7');
    });

    test('null haifuti thamani iliyopo', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.saveChild(name: 'Amina', age: 'age5to7');
      await store.saveChild(name: 'Amina');
      expect(store.childAge, 'age5to7');
    });
  });

  group('kunasa kuingizwa (idempotency)', () {
    test('restore mara mbili haisomi upya', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.completeOnboarding();
      // `restore` ya pili kwenye mfano ule ule haipaswi kufuta hali.
      await store.restore();
      expect(store.onboardingDone, isTrue);
      expect(store.restored, isTrue);
    });
  });

  group('clearAll', () {
    test('hufuta kila kitu', () async {
      final LibraryStore store = LibraryStore();
      await store.restore();
      await store.completeOnboarding();
      await store.toggleFollow('Mtu');
      await store.toggleSaved('safari-ya-simba');
      await store.saveLastPage('safari-ya-simba', 2);
      await store.saveChild(name: 'Amina', age: 'age5to7');

      await store.clearAll();

      final LibraryStore reopened = LibraryStore();
      await reopened.restore();
      expect(reopened.onboardingDone, isFalse);
      expect(reopened.followedAuthors, isEmpty);
      expect(reopened.savedStories, isEmpty);
      expect(reopened.lastPage('safari-ya-simba'), isNull);
      expect(reopened.childName, isEmpty);
      expect(reopened.childAge, isEmpty);
    });
  });
}
