import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/features/stories/data/services/background_music_player.dart';
import 'package:hadithi_studio/features/stories/presentation/cubit/reader_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeMusic extends BackgroundMusicPlayer {
  int starts = 0;
  int stops = 0;
  bool disposed = false;
  bool canStart = true;
  double? volume;
  @override
  Future<bool> start(double value) async {
    starts++;
    volume = value;
    return canStart;
  }
  @override
  Future<void> stop() async { stops++; }
  @override
  Future<void> setVolume(double value) async { volume = value; }
  @override
  Future<void> dispose() async { disposed = true; }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('music starts off and volume is independent and bounded', () async {
    final music = FakeMusic();
    final reader = ReaderCubit(musicPlayer: music);
    expect(reader.state.musicEnabled, isFalse);
    await reader.setMusicEnabled(true);
    expect(reader.state.musicEnabled, isTrue);
    expect(music.starts, 1);
    reader.setMusicVolume(2);
    expect(reader.state.musicVolume, 0.5);
    expect(music.volume, 0.5);
    await reader.setMusicEnabled(false);
    expect(reader.state.musicEnabled, isFalse);
    expect(music.stops, 1);
    await reader.close();
    expect(music.disposed, isTrue);
  });

  test('failed music start is not reported as enabled', () async {
    final music = FakeMusic()..canStart = false;
    final reader = ReaderCubit(musicPlayer: music);
    await reader.setMusicEnabled(true);
    expect(reader.state.musicEnabled, isFalse);
    expect(reader.state.musicBusy, isFalse);
    await reader.close();
  });
}
