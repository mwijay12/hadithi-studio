import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/speech_service.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/features/stories/data/services/story_audio_player.dart';
import 'package:hadithi_studio/features/stories/presentation/cubit/reader_cubit.dart';
import 'package:hadithi_studio/features/stories/presentation/state/reader_state.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/tts_controls.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAudio extends StoryAudioPlayer {
  int plays = 0;
  int pauses = 0;
  int resumes = 0;
  double? speed;
  @override
  Stream<ProcessingState> get processingStateStream => const Stream.empty();
  @override
  Future<bool> playPage({required String storyId, required int pageIndex, double speed = 1.0}) async { plays++; return true; }
  @override
  Future<void> pause() async { pauses++; }
  @override
  Future<void> resume() async { resumes++; }
  @override
  Future<void> setSpeed(double speed) async { this.speed = speed; }
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

class UnavailableSpeech extends SpeechService {
  @override
  Future<bool> configure({required double rate, required double pitch, bool preferSwahili = true}) async => false;
  @override
  Future<void> stop() async {}
  @override
  Future<void> dispose() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('recorded Swahili remains playable after English TTS is unavailable', () async {
    final cubit = ReaderCubit(audioPlayer: FakeAudio(), speech: UnavailableSpeech());
    await cubit.loadStory(StorySampleData.all.first);
    cubit.setLanguage(false);
    await cubit.startReadAloud();
    expect(cubit.state.speechAvailable, isFalse);
    expect(cubit.state.isSpeaking, isFalse);
    expect(cubit.state.highlightStart, isNull);

    cubit.setLanguage(true);
    await cubit.startReadAloud();
    expect(cubit.state.speechAvailable, isTrue);
    expect(cubit.state.isSpeaking, isTrue);
    await cubit.close();
  });
  test('recording pauses, changes speed and resumes without restarting for voice', () async {
    final audio = FakeAudio();
    final cubit = ReaderCubit(audioPlayer: audio, speech: UnavailableSpeech());
    await cubit.loadStory(StorySampleData.all.first);
    await cubit.togglePause();
    expect(audio.plays, 1);
    await cubit.togglePause();
    expect(cubit.state.isPaused, isTrue);
    cubit.setRateMultiplier(1.2);
    cubit.setVoice(ReaderVoice.baba);
    expect(audio.plays, 1);
    expect(audio.speed, 1.2);
    expect(cubit.state.isPaused, isTrue);
    await cubit.togglePause();
    expect(audio.resumes, 1);
    expect(cubit.state.isPaused, isFalse);
    await cubit.close();
  });

  testWidgets('reader play pauses and speed sheet scrolls on small screens', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final audio = FakeAudio();
    final cubit = ReaderCubit(audioPlayer: audio, speech: UnavailableSpeech());
    addTearDown(cubit.close);
    await cubit.loadStory(StorySampleData.all.first);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(
        disableAnimations: true, textScaler: const TextScaler.linear(1.4)), child: child!),
      home: Scaffold(body: Center(child: BlocBuilder<ReaderCubit, ReaderState>(
        bloc: cubit, builder: (_, state) => TtsControls(state: state, cubit: cubit),
      ))),
    ));
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(audio.plays, 1);
    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pump();
    expect(audio.pauses, 1);
    expect(cubit.state.isPaused, isTrue);
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(audio.resumes, 1);
    await tester.tap(find.byIcon(Icons.speed_rounded));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(ListTile).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(ListTile).last);
    await tester.pumpAndSettle();
    expect(cubit.state.rateMultiplier, 1.3);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
