/// Kusoma kwa sauti (TTS) — kifuniko kimoja juu ya `flutter_tts`.
///
/// ## Kwa nini faili hili lipo
///
/// `flutter_tts` ni plugin ya jukwaa. Kuita moja kwa moja kutoka kwenye widget
/// kunaingiza `PlatformException` kwenye safu ya UI na — muhimu zaidi —
/// kunafanya skrini ishindwe kufunguka kwenye kifaa ambacho hakina injini ya
/// sauti (hali ya kawaida kwenye simu za bei nafuu za Tanzania). Kifuniko hiki
/// hukamata kila kosa na kuripoti `false` badala ya kutupa.
///
/// ## Tofauti ya kasi kati ya jukwaa (muhimu!)
///
/// Kasi ya `flutter_tts` **haitafsiriki sawa** kwenye majukwaa:
///
/// | Jukwaa | Kipimo cha `setSpeechRate` | 1.0 inamaanisha |
/// |---|---|---|
/// | Android | ~`0.0`–`1.0` | kasi ya kawaida |
/// | Web (`speechSynthesis`) | ~`0.1`–`10.0` | kasi ya kawaida |
///
/// `ReaderVoice.rate` imeandikwa kwa kipimo cha Android (ndilo jukwaa la
/// msingi). Bila kubadilisha kipimo, thamani ya `0.45` kwenye web ingesoma
/// nusu ya kasi ya kawaida — na mtoto angesubiri sana. [rateForPlatform]
/// hufanya ubadilishaji huo mahali pamoja.
///
/// ## Mwanga wa neno HAUENDESHWI na plugin hii
///
/// Web implementation ya `flutter_tts` **haitozi** matukio ya
/// `onboundary` (haipo kwenye `flutter_tts_web.dart`), na kwenye Android
/// hutolewa kwa hiari — injini nyingine hazitoi kabisa. Kwa hivyo mwanga wa
/// neno kwenye Reader hauendeshwi na plugin: `ReaderCubit` huuendesha kwa
/// kipima-muda chake. Hii inafanya "karaoke" ifanye kazi **kwenye kila
/// jukwaa**, ikiwa na sauti au bila. Hapa tumeacha njia ya kusikiliza
/// matukio ya mwanzo/mwisho pekee, kwa sababu hizo zinatolewa kwa kuaminika.
library;

// Hapa kuna `import` **kamili** ya foundation, si ile yenye `show kIsWeb`:
// kifungu cha `show` huficha kila kitu kingine — `debugPrint`,
// `debugPrintStack` na `visibleForTesting` — na faili hili linahitaji vyote.
// `VoidCallback` hutoka `dart:ui`.
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Kifuniko cha TTS kinachoshindwa kwa upole.
class SpeechService {
  /// Huunda kifuniko. [tts] ipo kwa majaribio pekee.
  SpeechService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  /// `true` kama `configure` ilifanikiwa na plugin inaonekana ipo.
  bool _configured = false;

  /// `true` kama jaribio la mwisho la kusoma lilishindwa.
  ///
  /// Hatujaribu tena mara kwa mara: kifaa ambacho hakina injini ya sauti
  /// hakipati moja katikati ya hadithi, na kujaribu kila ukurasa kungeleta
  /// ucheleweshaji usio na faida.
  bool _failed = false;

  /// `true` kama sauti inaweza kutumika sasa.
  bool get isAvailable => _configured && !_failed;

  /// Lugha ya TTS iliyowekwa, kwa taarifa.
  String? _language;

  /// Lugha ya TTS iliyowekwa (`null` = injini inatumia ya kawaida).
  String? get language => _language;

  /// Huandaa injini kwa [rate] (kipimo cha Android) na [pitch].
  ///
  /// Hurudisha `true` kama injini iko tayari kusoma. Hukamata kila kosa.
  Future<bool> configure({
    required double rate,
    required double pitch,
    bool preferSwahili = true,
  }) async {
    if (_failed) return false;
    try {
      await _tts.setSpeechRate(rateForPlatform(rate));
      await _tts.setPitch(pitch.clamp(0.0, 2.0));
      await _tts.setVolume(1.0);

      // Kiswahili kwanza; kama kifaa hakina sauti ya Kiswahili, injini
      // hutumia ya kawaida. HATUBADILISHI maandishi kuwa Kiingereza —
      // kusoma Kiswahili kwa sauti ya Kiingereza ni jambo la kuudhi, lakini
      // bado ni bora kuliko ukimya, na mtumiaji anaweza kuzima kusoma.
      if (preferSwahili) {
        for (final String code in const <String>['sw-TZ', 'sw-KE', 'sw']) {
          try {
            final dynamic available = await _tts.isLanguageAvailable(code);
            if (available == true) {
              await _tts.setLanguage(code);
              _language = code;
              break;
            }
          } catch (_) {
            // Injini hii haijui `isLanguageAvailable` — endelea kujaribu.
          }
        }
      }

      _configured = true;
      return true;
    } catch (error, stackTrace) {
      _failed = true;
      debugPrint('SpeechService.configure imeshindwa: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  /// Husoma [text]. Hurudisha `true` kama ombi lilitumwa.
  ///
  /// Haisubiri kusoma kumalizika (sisi huendesha mwanga wa neno wenyewe);
  /// matumizi ya kumalizika yanaripotiwa kwa [onDone].
  Future<bool> speak(
    String text, {
    VoidCallback? onDone,
    VoidCallback? onCancel,
  }) async {
    if (text.trim().isEmpty) return false;
    if (_failed) return false;

    try {
      if (!_configured) {
        // Kama `configure` haikuitwa, injini inasoma kwa mipangilio ya
        // kawaida — bora kuliko kutupa.
        _configured = true;
      }
      _tts.setCompletionHandler(() => onDone?.call());
      _tts.setCancelHandler(() => onCancel?.call());
      _tts.setErrorHandler((dynamic message) {
        _failed = true;
        debugPrint('SpeechService: injini ya sauti imeripoti kosa: $message');
        onCancel?.call();
      });
      await _tts.speak(text);
      return true;
    } catch (error) {
      _failed = true;
      debugPrint('SpeechService.speak imeshindwa: $error');
      onCancel?.call();
      return false;
    }
  }

  /// Husimamisha kusoma.
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Kitu kimekwisha simama — hakuna kitu cha kufanya.
    }
  }

  /// Husimamisha kwa muda (inaweza kuendelezwa kwa [resume]).
  Future<void> pause() async {
    try {
      await _tts.pause();
    } catch (_) {
      // Baadhi ya jukwaa hazitekelezi `pause` — `stop()` ni njia mbadala.
      await stop();
    }
  }

  /// Huendeleza kusoma baada ya [pause].
  Future<void> resume() async {
    try {
      await _tts.pause();
    } catch (_) {
      // Web hutumia `pause` kama geuza (toggle) — tazama `flutter_tts_web`.
    }
  }

  /// Huachilia rasilimali.
  Future<void> dispose() => stop();

  /// Hubadilisha kasi kutoka kipimo cha Android hadi cha jukwaa hili.
  ///
  /// Web inahitaji thamani kubwa mara mbili kwa kasi ile ile: `0.45` ya
  /// Android ≈ `0.9`–`1.0` ya `speechSynthesis`. Bila hii, sauti kwenye
  /// kivinjari ingekuwa ya polepole isivyo kawaida.
  @visibleForTesting
  static double rateForPlatform(double androidRate) {
    if (kIsWeb) return (androidRate * 2.0).clamp(0.1, 10.0);
    return androidRate.clamp(0.0, 1.0);
  }
}
