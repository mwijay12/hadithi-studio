import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Leo poses have transparent space around all four edges', () async {
    for (final pose in ['curious', 'happy', 'reading', 'wave', 'listening']) {
      final data = await rootBundle.load('assets/images/mascot/leo_$pose.webp');
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      final image = frame.image;
      final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
      int alpha(int x, int y) => bytes[(y * image.width + x) * 4 + 3];
      for (var x = 0; x < image.width; x++) {
        expect(alpha(x, 0), 0, reason: '$pose touches top edge');
        expect(alpha(x, image.height - 1), 0, reason: '$pose touches bottom edge');
      }
      for (var y = 0; y < image.height; y++) {
        expect(alpha(0, y), 0, reason: '$pose touches left edge');
        expect(alpha(image.width - 1, y), 0, reason: '$pose touches right edge');
      }
      image.dispose();
      codec.dispose();
    }
  });
}
