import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/animation/leo_wave_timing.dart';

void main() {
  test('wave starts and settles at rest, without repeating', () {
    expect(LeoWaveTiming.angleAt(Duration.zero), 0);
    expect(LeoWaveTiming.angleAt(LeoWaveTiming.delay), 0);
    expect(LeoWaveTiming.angleAt(LeoWaveTiming.delay + LeoWaveTiming.duration), 0);
    expect(LeoWaveTiming.angleAt(const Duration(minutes: 1)), 0);
  });

  test('wave is bounded, moves both ways, and has no hard jumps', () {
    var minimum = 0.0;
    var maximum = 0.0;
    var previous = 0.0;
    for (var ms = 0; ms <= 2300; ms += 5) {
      final angle = LeoWaveTiming.angleAt(Duration(milliseconds: ms));
      if (angle < minimum) minimum = angle;
      if (angle > maximum) maximum = angle;
      expect(angle.abs(), lessThanOrEqualTo(LeoWaveTiming.maxRadians));
      expect((angle - previous).abs(), lessThan(0.01));
      previous = angle;
    }
    expect(minimum, lessThan(-0.03));
    expect(maximum, greaterThan(0.03));
  });
}
