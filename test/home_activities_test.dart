import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hadithi_studio/config/routes/app_routes.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:hadithi_studio/navigation/app_shell.dart';

void main() {
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

  testWidgets('home game opens the actual short quiz', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.ensureVisible(find.byKey(const ValueKey('home-game')));
    await tester.tap(find.byKey(const ValueKey('home-game')));
    await tester.pumpAndSettle();
    expect(find.text('Babu alimfundisha Neema nini?'), findsOneWidget);
  });

  testWidgets('listen opens bundled story with autoplay', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.ensureVisible(find.byKey(const ValueKey('home-listen')));
    await tester.tap(find.byKey(const ValueKey('home-listen')));
    await tester.pumpAndSettle();
    expect(find.text('reader:safari-ya-simba:1'), findsOneWidget);
  });

  testWidgets('music opens reader without claiming to start music', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.ensureVisible(find.byKey(const ValueKey('home-music')));
    expect(find.text('Fungua hadithi, kisha washa muziki kwenye mipangilio'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-music')));
    await tester.pumpAndSettle();
    expect(find.text('reader:safari-ya-simba:off'), findsOneWidget);
  });

  testWidgets('all stories opens library listing', (tester) async {
    final appRouter = router();
    await openHome(tester, appRouter);
    await tester.ensureVisible(find.byKey(const ValueKey('home-all-stories')));
    await tester.tap(find.byKey(const ValueKey('home-all-stories')));
    await tester.pumpAndSettle();
    expect(find.text('all stories route'), findsOneWidget);
  });
}
