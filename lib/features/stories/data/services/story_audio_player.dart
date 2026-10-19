/// **KICHEZA SAUTI YA HADITHI** — audio iliyorekodiwa, kwa kila ukurasa.
///
/// ## Kanuni inayotawala
///
/// **Audio iliyorekodiwa ni msingi; TTS ya simu ni akiba.**
///
/// Sababu: injini za simu hazina Kiswahili, hivyo husoma maandishi ya
/// Kiswahili kwa sauti ya Kiingereza — "inachekesha", kama mtumiaji
/// alivyosema. Audio iliyorekodiwa hutoa sauti moja **sawa kwa kila kifaa**
/// (Tecno, Samsung, iOS), haitumii data, na inafanya kazi bila mtandao.
///
/// ## Kwa nini huduma hii huchunguza faili zenyewe
///
/// Mtumiaji (au agent) anaweka faili kwenye `assets/audio/<story-id>/` na
/// **hakuna kitu kingine cha kufanya**. Huduma husoma `AssetManifest.json`
/// mara moja, kisha hujua ukurasa upi una sauti. Ukurasa usio na sauti
/// huangukia TTS **bila kosa** — hivyo hadithi mpya (au ukurasa ambao
/// haujarekodiwa) bado hufanya kazi.
///
/// ## Hii HAITOI timestamps za maneno
///
/// Audio hupeana sauti pekee. Uangazaji wa neno (kanuni #15) unahitaji
/// `assets/audio/<story-id>/page_NN.json` zilizozalishwa kwa **forced
/// alignment** (WhisperX / MFA / aTune). Huduma hii huonyesha kama faili
/// hizo zipo, lakini **haizizalishi** — kuzizalisha ni hatua ya studio.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:just_audio/just_audio.dart';

import '../bundled_stories.dart';

/// Hucheza sauti ya ukurasa wa hadithi.
class StoryAudioPlayer {
  /// Huunda kicheza.
  ///
  /// [player] ni kwa majaribio pekee — kawaida tunaunda yetu.
  StoryAudioPlayer({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  /// Faili zote za assets (zilizosomwa mara moja).
  Set<String>? _assets;

  /// `true` = kicheza kina sauti inayopiga sasa.
  bool get isPlaying => _player.playing;

  /// Muda wa faili inayopiga (`null` = haijulikani).
  Duration? get duration => _player.duration;

  /// Muda uliopita wa faili inayopiga.
  Duration get position => _player.position;

  /// Huhakikisha orodha ya assets imesomwa.
  Future<Set<String>> _ensureAssets() async {
    final Set<String>? cached = _assets;
    if (cached != null) return cached;

    try {
      // `AssetManifest.json` ni njia thabiti zaidi kwa Flutter 3.16 (API ya
      // `AssetManifest.loadFromAssetBundle` ilibadilika kwenye Matoleo ya
      // baadaye). Hii husoma faili moja lenye majina ya assets zote.
      final String raw = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> map =
          jsonDecode(raw) as Map<String, dynamic>;
      final Set<String> found = map.keys.toSet();
      _assets = found;
      return found;
    } catch (error) {
      // Hii hutokea kwenye majaribio ya widget bila `rootBundle` tayari, au
      // kwenye build isiyo na manifest. Hurudisha tupu — haitupi.
      debugPrint('StoryAudioPlayer: AssetManifest imeshindwa — $error');
      _assets = <String>{};
      return const <String>{};
    }
  }

  /// `true` = ukurasa huu una sauti iliyorekodiwa.
  Future<bool> hasPageAudio({
    required String storyId,
    required int pageIndex,
  }) async {
    final Set<String> assets = await _ensureAssets();
    return assets.contains(BundledStories.pageAudioAsset(storyId, pageIndex));
  }

  /// `true` = ukurasa huu una timestamps za maneno.
  ///
  /// Hutumika kuamua kama tunaweza kuangaza maneno kwa **muda wa kweli**
  /// badala ya kukisia.
  Future<bool> hasPageTimings({
    required String storyId,
    required int pageIndex,
  }) async {
    final Set<String> assets = await _ensureAssets();
    return assets.contains(BundledStories.pageTimingAsset(storyId, pageIndex));
  }

  /// Hucheza sauti ya ukurasa.
  ///
  /// Hurudisha `true` kama ilifanikiwa. **Haitupi** — ukurasa usio na sauti
  /// hurudisha `false`, na mwitaji huangukia TTS.
  Future<bool> playPage({
    required String storyId,
    required int pageIndex,
  }) async {
    final String asset = BundledStories.pageAudioAsset(storyId, pageIndex);
    try {
      if (!await hasPageAudio(storyId: storyId, pageIndex: pageIndex)) {
        return false;
      }
      await _player.setAsset(asset);
      // Sauti ya hadithi ya watoto: kasi ya kawaida, si 1.0 ya haraka.
      await _player.setSpeed(1.0);
      unawaited(_player.play());
      return true;
    } catch (error) {
      debugPrint('StoryAudioPlayer: kucheza kimeshindwa ($asset) — $error');
      return false;
    }
  }

  /// Husimamisha kwa muda.
  Future<void> pause() async {
    try {
      await _player.pause();
    } catch (error) {
      debugPrint('StoryAudioPlayer: kusimamisha kimeshindwa — $error');
    }
  }

  /// Huendelea kusoma.
  Future<void> resume() async {
    try {
      unawaited(_player.play());
    } catch (error) {
      debugPrint('StoryAudioPlayer: kuendelea kumeshindwa — $error');
    }
  }

  /// Husimamisha kabisa na kurudisha mwanzo.
  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('StoryAudioPlayer: kusimamisha kimeshindwa — $error');
    }
  }

  /// Huachilia rasilimali.
  ///
  /// **Lazima** iitwe: `AudioPlayer` hushikilia rasilimali za mfumo. Bila
  /// hii, kufungua hadithi 10 kunaacha kicheza 10 hai.
  Future<void> dispose() async {
    try {
      await _player.dispose();
    } catch (error) {
      debugPrint('StoryAudioPlayer: kuachilia kimeshindwa — $error');
    }
  }
}
