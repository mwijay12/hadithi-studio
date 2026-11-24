import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hadithi_studio/config/routes/app_routes.dart';
import 'package:hadithi_studio/core/services/library_store.dart';
import 'package:hadithi_studio/core/services/reading_progress_store.dart';
import 'package:hadithi_studio/core/services/reading_activity_store.dart';
import 'package:hadithi_studio/core/services/reading_rewards_store.dart';
import 'package:hadithi_studio/core/services/parent_preferences.dart';
import 'package:hadithi_studio/core/services/speech_service.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/features/stories/data/services/background_music_player.dart';
import 'package:hadithi_studio/features/stories/data/services/story_audio_player.dart';
import 'package:hadithi_studio/features/stories/presentation/cubit/reader_cubit.dart';
import 'package:hadithi_studio/features/stories/presentation/pages/story_reader_page.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:hadithi_studio/navigation/app_shell.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Audio extends StoryAudioPlayer {
  @override
  Stream<ProcessingState> get processingStateStream => const Stream.empty();
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}
class _Music extends BackgroundMusicPlayer {
  @override
  Future<void> dispose() async {}
}
class _Speech extends SpeechService {
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

class _MemoryActivity extends ReadingActivityStore {
  ActivitySnapshot current = const ActivitySnapshot();
  @override
  Future<bool> recordPage(String storyId, int index, {DateTime? now}) async {
    current = current.visit(now ?? DateTime.now(), storyId, index);
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const progress = ReadingProgressStore();
  final story = StorySampleData.all.first;
  setUp(() async {
    ReadingActivityStore.resetForTesting();
    ReadingRewardsStore.resetForTesting();
    ParentPreferences.resetForTesting();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await LibraryStore.instance.clearAll();
  });
  ReaderCubit reader() => ReaderCubit(audioPlayer: _Audio(), musicPlayer: _Music(), speech: _Speech());

  test('restores valid saved page and rejects obsolete indexes', () async {
    await progress.savePage(story.id, 2);
    final cubit = reader();
    await cubit.loadStory(story, resume: true);
    expect(cubit.state.pageIndex, 2);
    expect(cubit.state.isSpeaking, isFalse);
    await cubit.close();
    await progress.savePage(story.id, 999);
    final invalid = reader();
    await invalid.loadStory(story, resume: true);
    expect(invalid.state.pageIndex, 0);
    await invalid.close();
  });

  test('existing pages survive migration and timestamp order survives restart', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      '${LibraryStore.progressPrefix}old': 2,
      '${LibraryStore.progressPrefix}new': 1,
      '${LibraryStore.progressTimePrefix}new': 900,
    });
    final library = LibraryStore();
    await library.restore();
    expect(library.inProgressStoryIds, ['new', 'old']);
    expect(library.lastPage('old'), 2);
  });

  testWidgets('resume popup opens most recently visited page without autoplay', (tester) async {
    await progress.savePage(story.id, 2);
    final router = GoRouter(initialLocation: '/home', routes: <RouteBase>[
      GoRoute(path: '/home', builder: (_, __) => const HomeTabPage()),
      GoRoute(path: '/story/:id/read', name: AppRoutes.readerName,
        builder: (_, state) => Scaffold(body: Text('resume:${state.uri.queryParameters['resume']}:auto:${state.uri.queryParameters['auto'] ?? 'off'}'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router, locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
    ));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Tuendelee na hadithi?'), findsOneWidget);
    expect(find.text('Ukurasa 3 kati ya ${story.pageCount}'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('home-resume')));
    await tester.pumpAndSettle();
    expect(find.text('resume:1:auto:off'), findsOneWidget);
  });

  testWidgets('resume sheet remains usable on a small screen with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await progress.savePage(story.id, 2);
    final router = GoRouter(initialLocation: '/home', routes: <RouteBase>[
      GoRoute(path: '/home', builder: (_, __) => const HomeTabPage()),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router, locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: true, textScaler: const TextScaler.linear(1.6),
        ), child: child!,
      ),
    ));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Tuendelee na hadithi?'), findsOneWidget);
    await tester.ensureVisible(find.text('Labda baadaye'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Labda baadaye'));
    await tester.pumpAndSettle();
    expect(find.text('Tuendelee na hadithi?'), findsNothing);
  });

  testWidgets('reader attaches PageView at saved page without resume dialog', (tester) async {
    await progress.savePage(story.id, 2);
    final cubit = reader();
    await cubit.loadStory(story, resume: true);
    addTearDown(cubit.close);
    await tester.pumpWidget(BlocProvider.value(value: cubit, child: MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: StoryReaderPage(storyId: story.id, resume: true),
    )));
    await tester.pump();
    final view = tester.widget<PageView>(find.byType(PageView).first);
    expect(view.controller!.initialPage, 2);
    expect(cubit.state.pageIndex, 2);
    expect(find.byType(AlertDialog), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
  testWidgets('visible pages count once toward today’s goal', (tester) async {
    final activity = _MemoryActivity();
    final cubit = reader();
    await cubit.loadStory(story);
    addTearDown(cubit.close);
    await tester.pumpWidget(BlocProvider.value(value: cubit, child: MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: StoryReaderPage(storyId: story.id, resume: true, activityStore: activity),
    )));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    cubit.nextPage();
    await tester.pump();
    for (var i = 0; i < 10; i++) { await tester.pump(const Duration(milliseconds: 100)); }
    cubit.nextPage();
    await tester.pump();
    for (var i = 0; i < 10; i++) { await tester.pump(const Duration(milliseconds: 100)); }
    await tester.pump();
    await tester.pump();
    await tester.pump();
    expect(activity.current.pagesToday(DateTime.now()), 3);
    expect(activity.current.streak, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

}
