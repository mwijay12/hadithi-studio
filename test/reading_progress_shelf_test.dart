import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hadithi_studio/config/routes/app_routes.dart';
import 'package:hadithi_studio/core/services/library_store.dart';
import 'package:hadithi_studio/core/services/reading_progress_store.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:hadithi_studio/navigation/app_shell.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const progress = ReadingProgressStore();
  final library = LibraryStore.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await library.clearAll();
  });

  test('reader writes and clears update the live shelf', () async {
    var notifications = 0;
    void listener() => notifications++;
    library.addListener(listener);
    addTearDown(() => library.removeListener(listener));

    expect(await progress.savePage('safari-ya-simba', 2), isTrue);
    expect(library.lastPage('safari-ya-simba'), 2);
    expect(library.inProgressStoryIds, contains('safari-ya-simba'));
    expect(await progress.clearProgress('safari-ya-simba'), isTrue);
    expect(library.lastPage('safari-ya-simba'), isNull);
    expect(notifications, 2);
  });

  testWidgets('shelf opens reader without forcing playback from page one',
      (tester) async {
    await progress.savePage('safari-ya-simba', 2);
    final router = GoRouter(initialLocation: '/shelf', routes: <RouteBase>[
      GoRoute(path: '/shelf', builder: (_, __) => const BookshelfTabPage()),
      GoRoute(
        path: '/story/:id/read',
        name: AppRoutes.readerName,
        builder: (_, state) => Scaffold(
          body: Text('reader:${state.pathParameters['id']}:${state.uri.queryParameters['auto'] ?? 'off'}'),
        ),
      ),
    ]);
    addTearDown(router.dispose);
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
    await tester.tap(find.text('Safari ya Simba').first);
    await tester.pumpAndSettle();
    expect(find.text('reader:safari-ya-simba:off'), findsOneWidget);
  });
}
