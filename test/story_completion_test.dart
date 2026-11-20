import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/errors/failures.dart';
import 'package:hadithi_studio/core/services/library_store.dart';
import 'package:hadithi_studio/core/services/story_completion_store.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story.dart';
import 'package:hadithi_studio/features/stories/domain/repositories/story_repository.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/story_completion_dialog.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRepository implements StoryRepository {
  FakeRepository(this.stories);
  final List<Story> stories;
  @override
  Future<Either<Failure, List<Story>>> getAllStories() async => Right(stories);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    StoryCompletionStore.resetForTesting();
  });

  test('completion is explicit, idempotent and survives restart', () async {
    final store = StoryCompletionStore();
    await store.restore();
    expect(store.completedIds, isEmpty);
    expect(await store.complete(''), isFalse);
    final results = await Future.wait([store.complete('one'), store.complete('one'), store.complete('two')]);
    expect(results, everyElement(isTrue));
    final prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString(StoryCompletionStore.storageKey)!) as Map;
    expect((saved['stories'] as Map).length, 2);
    final restored = StoryCompletionStore();
    await restored.restore();
    expect(restored.completedIds, {'one', 'two'});
  });

  test('invalid data is safe; clear library removes completion', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(StoryCompletionStore.storageKey, 'not json');
    final store = StoryCompletionStore.instance;
    await store.restore();
    expect(store.completedIds, isEmpty);
    expect(await store.complete('one'), isTrue);
    expect(await LibraryStore.instance.clearAll(), isTrue);
    expect(store.completedIds, isEmpty);
    expect(prefs.getString(StoryCompletionStore.storageKey), isNull);
  });

  testWidgets('celebration shows saved status and safely handles no similar stories', (tester) async {
    final story = StorySampleData.all.first;
    final store = StoryCompletionStore.instance;
    await tester.runAsync(() => store.restore());
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(body: StoryCompletionDialog(story: story, store: store,
        repository: FakeRepository([story]), onStartOver: () async {}, onOpenStory: (_) {})),
    ));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('Well done!'), findsOneWidget);
    expect(find.text('No similar story available yet.'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
  });
}
