import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hadithi_studio/config/routes/app_routes.dart';
import 'package:hadithi_studio/core/services/reading_activity_store.dart';
import 'package:hadithi_studio/core/services/reading_rewards_store.dart';
import 'package:hadithi_studio/core/services/parent_preferences.dart';
import 'package:hadithi_studio/core/services/reading_discovery.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:hadithi_studio/navigation/app_shell.dart';
import 'package:hadithi_studio/core/widgets/leo_mascot.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/story_artwork.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ReadingActivityStore.resetForTesting();
    ReadingRewardsStore.resetForTesting();
    ParentPreferences.resetForTesting();
  });

  GoRouter router() => GoRouter(initialLocation: '/home', routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeTabPage()),
        GoRoute(
          path: '/story/:id/read', name: AppRoutes.readerName,
          builder: (_, state) => Scaffold(body: Text(
            'reader:${state.pathParameters['id']}:${state.uri.queryParameters['auto'] ?? 'off'}',
          )),
        ),
        GoRoute(path: '/stories/all', name: AppRoutes.allStoriesName,
          builder: (_, __) => const Scaffold(body: Text('all stories route'))),
      ]);

  Future<void> openHome(WidgetTester tester, GoRouter router) async {
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
    ));
    await tester.pump();
  }

  testWidgets('Leo greets near top without a journey card on Home', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.pumpAndSettle();
    expect(find.text('Habari, rafiki!'), findsOneWidget);
    expect(find.text('Safari ya kusoma'), findsNothing);
    expect(find.byKey(const ValueKey('weekly-mini-goal')), findsNothing);
  });

  testWidgets('home game opens the actual short quiz', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-game')), 300,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-scroll')),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-game')));
    await tester.pumpAndSettle();
    expect(find.text('Babu alimfundisha Neema nini?'), findsOneWidget);
  });

  testWidgets('listen opens bundled story with autoplay', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-listen')), 300,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-scroll')),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-listen')));
    await tester.pumpAndSettle();
    expect(find.text('reader:${dailyStoryFor(DateTime.now(), StorySampleData.all)!.id}:1'), findsOneWidget);
  });

  testWidgets('music opens reader without claiming to start music', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-music')), 300,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-scroll')),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Fungua hadithi, kisha washa muziki kwenye mipangilio'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-music')));
    await tester.pumpAndSettle();
    expect(find.text('reader:${dailyStoryFor(DateTime.now(), StorySampleData.all)!.id}:off'), findsOneWidget);
  });

  testWidgets('all stories opens library listing', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-all-stories')), 300,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-scroll')),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-all-stories')));
    await tester.pumpAndSettle();
    expect(find.text('all stories route'), findsOneWidget);
  });
  testWidgets('Leo invitation opens all stories', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    expect(find.text('Habari, rafiki!'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-leo-stories')), 200,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-scroll')),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-leo-stories')));
    await tester.pumpAndSettle();
    expect(find.text('all stories route'), findsOneWidget);
  });

  testWidgets('Leo invitation fits a narrow screen with larger text', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final appRouter = router();
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: appRouter,
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true,
          textScaler: const TextScaler.linear(1.5),
        ),
        child: child!,
      ),
    ));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('home-leo-stories')), 200,
      scrollable: find.descendant(
        of: find.byKey(const ValueKey('home-scroll')),
        matching: find.byType(Scrollable),
      ).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Habari, rafiki!'), findsOneWidget);
    expect(tester.getTopLeft(find.text('Habari, rafiki!')).dy,
        lessThan(tester.getTopLeft(find.byType(LeoMascot)).dy));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byKey(const ValueKey('home-leo-stories')));
    await tester.pumpAndSettle();
    expect(find.text('all stories route'), findsOneWidget);
  });

  testWidgets('story artwork decodes for its actual rendered width', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 320, height: 200,
        child: StoryArtwork(title: 'Story', asset: 'assets/images/mascot/leo_wave.webp',
          accent: Colors.orange, height: 200),
      ))),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    final provider = image.image as ResizeImage;
    expect(provider.width, (320 * tester.view.devicePixelRatio).round().clamp(120, 2048));
  });

}
