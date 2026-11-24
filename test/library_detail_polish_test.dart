import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hadithi_studio/config/routes/app_routes.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/features/stories/presentation/cubit/story_detail_cubit.dart';
import 'package:hadithi_studio/features/stories/presentation/pages/story_detail_page.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/story_grid_view.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:hadithi_studio/navigation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('Library offers a direct link to all stories', (tester) async {
    final router = GoRouter(routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, __) => const LibraryTabPage()),
      GoRoute(path: '/stories/all', name: AppRoutes.allStoriesName,
        builder: (_, __) => const Scaffold(body: Text('all stories'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router, locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
    ));
    await tester.tap(find.byKey(const ValueKey('library-all-stories')));
    await tester.pumpAndSettle();
    expect(find.text('all stories'), findsOneWidget);
  });

  testWidgets('catalog cards do not present sample ratings as real', (tester) async {
    final story = StorySampleData.all.first;
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      home: Scaffold(body: SizedBox(width: 150, height: 240, child: StoryGridTile(story: story))),
    ));
    expect(find.text(story.rating.toStringAsFixed(1)), findsNothing);
    expect(find.text(story.author), findsOneWidget);
  });

  testWidgets('story detail handles larger text without fabricated aggregate metrics', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final story = StorySampleData.all.first;
    final cubit = StoryDetailCubit(initialStory: story);
    addTearDown(cubit.close);
    await tester.pumpWidget(BlocProvider.value(value: cubit, child: MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(
        disableAnimations: true, textScaler: const TextScaler.linear(1.5)), child: child!),
      home: StoryDetailPage(storyId: story.id),
    )));
    await tester.pump();
    expect(find.text(story.rating.toStringAsFixed(1)), findsNothing);
    await tester.scrollUntilVisible(find.byKey(const ValueKey('detail-read')), 200,
      scrollable: find.byType(Scrollable).first);
    await tester.pump();
    expect(find.byKey(const ValueKey('detail-read')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
