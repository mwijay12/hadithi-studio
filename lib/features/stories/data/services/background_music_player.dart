import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// A separate, quiet player so changing music volume never changes narration.
class BackgroundMusicPlayer {
  BackgroundMusicPlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  static const asset = 'assets/audio/music/utulivu.wav';
  final AudioPlayer _player;

  Future<bool> start(double volume) async {
    try {
      await _player.setAsset(asset);
      await _player.setLoopMode(LoopMode.one);
      await _player.setVolume(volume.clamp(0.0, 1.0));
      unawaited(_player.play().catchError((Object error) {
        debugPrint('Background music playback failed: $error');
      }));
      return true;
    } catch (error) {
      debugPrint('Background music could not start: $error');
      return false;
    }
  }

  Future<void> stop() async {
    try { await _player.stop(); } catch (error) { debugPrint('Music stop failed: $error'); }
  }

  Future<void> setVolume(double volume) async {
    try { await _player.setVolume(volume.clamp(0.0, 1.0)); } catch (error) { debugPrint('Music volume failed: $error'); }
  }

  Future<void> dispose() => _player.dispose();
}
