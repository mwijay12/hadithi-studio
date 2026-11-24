import 'dart:math' as math;

/// Timing for a future *separately rigged* greeting arm.
///
/// Zero before the greeting, two gentle oscillations with a soft envelope,
/// then zero again. Does not animate the flattened mascot image; the rig must
/// supply a correctly aligned arm and a clean shoulder before this is used.
abstract final class LeoWaveTiming {
  static const Duration delay = Duration(milliseconds: 400);
  static const Duration duration = Duration(milliseconds: 1800);
  static const double maxRadians = 0.08;

  static double angleAt(Duration elapsed) {
    final int active = elapsed.inMicroseconds - delay.inMicroseconds;
    if (active <= 0 || active >= duration.inMicroseconds) return 0;
    final double t = active / duration.inMicroseconds;
    return maxRadians * math.sin(math.pi * t) * math.sin(4 * math.pi * t);
  }
}
