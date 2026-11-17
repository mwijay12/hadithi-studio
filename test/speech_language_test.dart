import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter_tts');
  final languages = <String>[];
  var available = true;

  setUp(() {
    languages.clear();
    available = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'isLanguageAvailable') return available;
      if (call.method == 'setLanguage') languages.add(call.arguments as String);
      return 1;
    });
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('switches voice language when story language changes', () async {
    final speech = SpeechService();
    expect(await speech.configure(rate: 0.5, pitch: 1, preferSwahili: true), isTrue);
    expect(await speech.configure(rate: 0.5, pitch: 1, preferSwahili: false), isTrue);
    expect(languages, ['sw-TZ', 'en-US']);
  });

  test('does not use the previous language when requested voice is missing', () async {
    final speech = SpeechService();
    expect(await speech.configure(rate: 0.5, pitch: 1), isTrue);
    available = false;
    expect(await speech.configure(rate: 0.5, pitch: 1, preferSwahili: false), isFalse);
    expect(speech.language, isNull);
    expect(speech.isAvailable, isFalse);
  });
}
