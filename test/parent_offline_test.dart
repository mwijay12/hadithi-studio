import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/library_store.dart';
import 'package:hadithi_studio/core/services/parent_preferences.dart';
import 'package:hadithi_studio/features/settings/presentation/widgets/offline_overview.dart';
import 'package:hadithi_studio/features/settings/presentation/widgets/parent_goal_setting.dart';
import 'package:hadithi_studio/features/stories/data/bundled_stories.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ParentPreferences.resetForTesting();
  });

  test('parent display preference persists and is not erased with library', () async {
    final prefs = ParentPreferences.instance;
    await prefs.restore();
    expect(prefs.showGoals, isTrue);
    expect(await prefs.setShowGoals(false), isTrue);
    expect(await LibraryStore.instance.clearAll(), isTrue);
    final restarted = ParentPreferences();
    await restarted.restore();
    expect(restarted.showGoals, isFalse);
    expect(await restarted.setShowGoals(true), isTrue);
    expect(restarted.showGoals, isTrue);
  });

  test('offline report distinguishes missing image and Swahili recording', () {
    final story = StorySampleData.all.first;
    final images = <String>{story.coverAsset, for (final page in story.pages) page.illustration};
    final audio = <String>{for (int i = 0; i < story.pages.length; i++) BundledStories.pageAudioAsset(story.id, i)};
    final complete = inspectBundledStories([story], {...images, ...audio}).single;
    expect(complete.readingReady, isTrue);
    expect(complete.swAudioReady, isTrue);
    final missing = inspectBundledStories([story], {...images}..remove(story.coverAsset)).single;
    expect(missing.readingReady, isFalse);
    expect(missing.missingAudio, story.pages.length);
    expect(inspectBundledStories([], {}).isEmpty, isTrue);
  });

  testWidgets('parent preference switch displays and updates saved value', (tester) async {
    await tester.runAsync(() => ParentPreferences.instance.restore());
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      home: const Scaffold(body: ParentGoalSetting()),
    ));
    await tester.pump();
    expect(tester.widget<SwitchListTile>(find.byKey(const ValueKey('parent-show-goals'))).value, isTrue);
    await tester.runAsync(() => ParentPreferences.instance.setShowGoals(false));
    await tester.pump();
    expect(tester.widget<SwitchListTile>(find.byKey(const ValueKey('parent-show-goals'))).value, isFalse);
    expect(find.textContaining('Activity is still saved'), findsOneWidget);
  });
}
