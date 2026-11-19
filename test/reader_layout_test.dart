import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/speech_service.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/features/stories/data/services/story_audio_player.dart';
import 'package:hadithi_studio/features/stories/presentation/cubit/reader_cubit.dart';
import 'package:hadithi_studio/features/stories/presentation/pages/story_reader_page.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/reader_illustration.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
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

class _Speech extends SpeechService {
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('reader fills backdrop, preserves illustration and exposes scroll hint', (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final reader = ReaderCubit(audioPlayer: _Audio(), speech: _Speech());
    await reader.loadStory(StorySampleData.all.first);
    await tester.pumpWidget(BlocProvider.value(
      value: reader,
      child: MaterialApp(
        locale: const Locale('sw'),
        localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
        supportedLocales: AppLocalizationsSetup.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const StoryReaderPage(storyId: 'safari-ya-simba'),
      ),
    ));
    await tester.pump();
    expect(find.byType(ImageFiltered), findsWidgets);
    expect(find.byType(ReaderIllustration), findsWidgets);
    expect(find.byTooltip('Telezesha kuona vidhibiti zaidi'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await reader.close();
  });
}
