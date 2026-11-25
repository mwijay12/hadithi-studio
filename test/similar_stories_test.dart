import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hadithi_studio/config/routes/app_routes.dart';
import 'package:hadithi_studio/core/enums/app_enums.dart';
import 'package:hadithi_studio/features/stories/data/repositories/story_repository_impl.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story_page.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story_shelf.dart';
import 'package:hadithi_studio/features/stories/domain/services/similar_stories.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/similar_stories_section.dart';
import 'package:hadithi_studio/l10n/l10n.dart';

Story story(String id, {StoryCategory category = StoryCategory.ngano,
    AgeGroup age = AgeGroup.miaka_3_5, List<StoryShelf> shelves = const [],
    double rating = 4.5}) => Story(
  id: id, titleSw: id, titleEn: id, synopsisSw: '', synopsisEn: '', author: '',
  category: category, ageGroup: age, readingLevel: ReadingLevel.mtoto_mdogo,
  coverAsset: '', accent: Colors.green, shelves: shelves,
  pages: const <StoryPage>[], rating: rating,
);

void main() {
  final current = story('current', shelves: [StoryShelf.animalStories]);

  test('ranks category, shared shelves, age and optional completion bonus', () {
    final high = story('high', shelves: [StoryShelf.animalStories, StoryShelf.animalStories], rating: 4);
    final sameCategory = story('category', rating: 5);
    final shelf = story('shelf', category: StoryCategory.maadili,
        shelves: [StoryShelf.animalStories], rating: 5);
    final unrelated = story('unrelated', category: StoryCategory.maadili);
    final result = getSimilarStories(current, [current, shelf, high, high, unrelated, sameCategory],
        completedIds: {'high'});
    expect(result.map((s) => s.id), ['high', 'category', 'shelf']);
    expect(getSimilarStories(current, [current, unrelated]), isEmpty);
    expect(getSimilarStories(current, [high, sameCategory], limit: 1).single.id, 'high');
    expect(getSimilarStories(current, [high], limit: 0), isEmpty);
  });

  test('ties use stable id rather than placeholder ratings; completion bonus changes rank', () {
    final a = story('a', rating: 4);
    final b = story('b', rating: 5);
    final c = story('c', rating: 5);
    expect(getSimilarStories(current, [c, a, b]).map((s) => s.id), ['a', 'b', 'c']);
    expect(getSimilarStories(current, [b, a], completedIds: {'b'}).first.id, 'a');
  });

  testWidgets('similar cards and view all open only related stories', (tester) async {
    final related = story('related', shelves: [StoryShelf.animalStories]);
    final unrelated = story('unrelated', category: StoryCategory.maadili);
    final repository = StoryRepositoryImpl(stories: [current, related, unrelated]);
    final router = GoRouter(initialLocation: '/', routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, __) => Scaffold(body: SingleChildScrollView(
        child: SimilarStoriesSection(story: current, repository: repository),
      ))),
      GoRoute(path: '/story/:id', name: AppRoutes.storyDetailName,
        builder: (_, state) => Scaffold(body: Text('detail:${state.pathParameters['id']}'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('similar-related')), findsOneWidget);
    expect(find.byKey(const ValueKey('similar-current')), findsNothing);
    expect(find.byKey(const ValueKey('similar-unrelated')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('similar-view-all')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('similar-all-related')), findsOneWidget);
    expect(find.byKey(const ValueKey('similar-all-unrelated')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('similar-all-related')));
    await tester.pumpAndSettle();
    expect(find.text('detail:related'), findsOneWidget);
  });

  testWidgets('empty recommendations do not show view all', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      home: Scaffold(body: SimilarStoriesSection(
        story: current, repository: StoryRepositoryImpl(stories: [current]),
      )),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Hakuna hadithi zinazofanana kwa sasa.'), findsOneWidget);
    expect(find.byKey(const ValueKey('similar-view-all')), findsNothing);
  });
}
