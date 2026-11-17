import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/speech_service.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/features/stories/data/services/story_audio_player.dart';
import 'package:hadithi_studio/features/stories/presentation/cubit/reader_cubit.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAudio extends StoryAudioPlayer {
  @override
  Stream<ProcessingState> get processingStateStream => const Stream.empty();
  @override
  Future<bool> playPage({required String storyId, required int pageIndex, double speed = 1.0}) async => true;
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
}
