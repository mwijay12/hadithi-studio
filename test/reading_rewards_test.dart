import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/library_store.dart';
import 'package:hadithi_studio/core/services/reading_activity_store.dart';
import 'package:hadithi_studio/core/services/reading_rewards_store.dart';
import 'package:hadithi_studio/core/widgets/reading_rewards_strip.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ReadingActivityStore.resetForTesting();
    ReadingRewardsStore.resetForTesting();
  });

  test('awards only once per page, spot and story review; survives restart', () async {
    final store = ReadingRewardsStore();
    final results = await Future.wait(<Future<RewardResult>>[
      store.pageOpened('simba', 0), store.pageOpened('simba', 0),
      store.hotspotDiscovered('simba', 0, 0), store.hotspotDiscovered('simba', 0, 0),
      store.reviewWritten('simba'), store.reviewWritten('simba'),
    ]);
    expect(results.where((r) => r.starsEarned > 0).length, 3);
    expect(store.snapshot.stars, 25);
    expect(store.snapshot.unlocked.keys, contains('reviewer'));
    final reopened = ReadingRewardsStore();
    await reopened.restore();
    expect(reopened.snapshot.stars, 25);
    expect((await reopened.reviewWritten('simba')).starsEarned, 0);
    expect((await reopened.pageOpened('', 0)).saved, isFalse);
  });

  test('explorer and streak badges unlock once, rewards reset with library', () async {
    final store = ReadingRewardsStore.instance;
    for (int i = 0; i < 10; i++) {
      final result = await store.hotspotDiscovered('story', 0, i);
      if (i == 9) expect(result.unlocked, contains('explorer'));
    }
    expect((await store.streakReached(6)).unlocked, isEmpty);
    expect((await store.streakReached(7)).unlocked, ['week']);
    expect((await store.streakReached(8)).unlocked, isEmpty);
    expect(store.snapshot.stars, 50);
    expect(await LibraryStore().clearAll(), isTrue);
    expect(store.snapshot.stars, 0);
    expect(store.snapshot.unlocked, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(ReadingRewardsStore.storageKey), isNull);
  });

  test('seven qualifying activity days award week badge', () async {
    final activity = ReadingActivityStore();
    for (int day = 1; day <= 7; day++) {
      for (int page = 0; page < 3; page++) {
        expect(await activity.recordPage('story', page, now: DateTime(2026, 1, day)), isTrue);
      }
    }
    // restore queues behind the badge event.
    await ReadingRewardsStore.instance.restore();
    expect(ReadingRewardsStore.instance.snapshot.unlocked, contains('week'));
  });

  test('level boundaries and invalid storage', () async {
    RewardsSnapshot sample(int n) => RewardsSnapshot(pages: {for (int i = 0; i < n; i++) '$i'});
    expect(sample(19).levelIndex, 0);
    expect(sample(20).levelIndex, 1);
    expect(sample(60).levelIndex, 2);
    expect(sample(140).levelIndex, 3);
    expect(sample(140).nextLevelAt, isNull);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ReadingRewardsStore.storageKey, '{bad');
    final store = ReadingRewardsStore();
    await store.restore();
    expect(store.snapshot.stars, 0);
    await prefs.setString(ReadingRewardsStore.storageKey, jsonEncode({'version': 99}));
    final newer = ReadingRewardsStore();
    await newer.restore();
    expect(newer.snapshot.stars, 0);
  });

  testWidgets('local rewards open badge sheet', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      ReadingRewardsStore.storageKey: jsonEncode(
        const RewardsSnapshot(pages: <String>{'page-0'}).toJson()),
    });
    await tester.runAsync(() => ReadingRewardsStore.instance.restore());
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      home: const Scaffold(body: ReadingRewardsStrip()),
    ));
    await tester.pumpAndSettle();
    expect(find.text('5 Nyota • Chipukizi'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('open-rewards')));
    await tester.pumpAndSettle();
    expect(find.text('Nyota na tuzo zako'), findsOneWidget);
    expect(find.text('Mpelelezi Hodari'), findsOneWidget);
  });
}
