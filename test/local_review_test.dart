import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/library_store.dart';
import 'package:hadithi_studio/features/stories/data/services/local_review_store.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/story_reviews_section.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const store = LocalReviewStore();
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  LocalStoryReview make(String id, int rating) => LocalStoryReview(
    storyId: id, rating: rating, name: 'Msomaji', comment: 'Nzuri!',
    tags: const ['art'], updatedAt: DateTime(2026, 1, 1),
  );

  test('save, edit, isolate stories and delete', () async {
    expect(await store.save(make('simba', 5)), isTrue);
    expect((await const LocalReviewStore().read('simba'))!.rating, 5);
    expect(await store.read('other'), isNull);
    expect(await store.save(make('simba', 3)), isTrue);
    expect((await store.read('simba'))!.rating, 3);
    expect(await store.save(make('bad', 0)), isFalse);
    expect(await store.delete('simba'), isTrue);
    expect(await store.read('simba'), isNull);
  });

  test('invalid JSON does not crash and clear library removes reviews', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${LocalReviewStore.keyPrefix}broken', '{bad');
    expect(await store.read('broken'), isNull);
    await store.save(make('simba', 5));
    expect(await LibraryStore().clearAll(), isTrue);
    expect(await store.read('simba'), isNull);
    expect(await store.read('broken'), isNull);
  });

  testWidgets('user can save, reopen, edit and delete local review', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      home: const Scaffold(body: SingleChildScrollView(
        child: StoryReviewsSection(storyId: 'simba'),
      )),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Mfano wa maoni (demo)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('write-review')));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(find.byKey(const ValueKey('save-review'))).onPressed, isNull);
    await tester.tap(find.byKey(const ValueKey('review-star-4')));
    await tester.enterText(find.byType(TextField).last, 'Hadithi nzuri');
    await tester.ensureVisible(find.byKey(const ValueKey('save-review')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-review')));
    await tester.pumpAndSettle();
    expect((await store.read('simba'))!.rating, 4);
    expect(find.text('Hadithi nzuri'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('write-review')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('write-review')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('review-star-5')));
    await tester.ensureVisible(find.byKey(const ValueKey('save-review')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('save-review')));
    await tester.pumpAndSettle();
    expect((await store.read('simba'))!.rating, 5);
    await tester.ensureVisible(find.text('Futa maoni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Futa maoni'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Futa').last);
    await tester.pumpAndSettle();
    expect(await store.read('simba'), isNull);
  });
}
