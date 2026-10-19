/// Majaribio ya [ContrastUtils] — WCAG AA kwa rangi halisi za Hadithi Studio.
///
/// Haya si majaribio ya kubuni ya namba: hupima rangi **ambazo app inatumia
/// kwa kweli** (rangi za rafu kutoka `StoryShelf`, na Sunset Gold). Kama mtu
/// abadilishe rangi ya rafu baadaye kuwa angavu kupita kiasi, jaribio hili
/// **litasimama** — ndiyo lengo lake.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/config/theme/colors.dart';
import 'package:hadithi_studio/core/utils/contrast_utils.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story_shelf.dart';

/// Kituo cha rangi (0–255) — `Color.red` imepitwa na wakati.
int _red(Color color) => (color.r * 255.0).round().clamp(0, 255);

/// Kituo cha rangi (0–255) — `Color.green` imepitwa na wakati.
int _green(Color color) => (color.g * 255.0).round().clamp(0, 255);

void main() {
  group('ratio', () {
    test('nyeusi juu ya nyeupe ni 21:1', () {
      expect(
        ContrastUtils.ratio(const Color(0xFF000000), const Color(0xFFFFFFFF)),
        closeTo(21.0, 0.01),
      );
    });

    test('rangi ile ile ni 1:1', () {
      expect(
        ContrastUtils.ratio(AppColors.safariGreen, AppColors.safariGreen),
        closeTo(1.0, 0.001),
      );
    });

    test('mpangilio hauna maana', () {
      expect(
        ContrastUtils.ratio(AppColors.safariGreen, AppColors.background),
        closeTo(
          ContrastUtils.ratio(AppColors.background, AppColors.safariGreen),
          0.001,
        ),
      );
    });
  });

  group('blend', () {
    test('alpha 1 hurudisha rangi yenyewe', () {
      final Color blended = ContrastUtils.blend(
        AppColors.safariGreen.withValues(alpha: 1.0),
        AppColors.background,
      );
      expect(blended, AppColors.safariGreen);
    });

    test('tint husogea kuelekea mandhari', () {
      final Color tint = ContrastUtils.blend(
        AppColors.spiceRed.withValues(alpha: 0.12),
        AppColors.background,
      );
      // Tint ni nyepesi kuliko rangi kamili, lakini bado ina hue ya spiceRed.
      expect(_red(tint), greaterThan(_red(AppColors.spiceRed)));
      expect(_red(tint), greaterThan(_green(tint)));
    });
  });

  group('readableInk hufikia WCAG AA kwa rangi zote za rafu', () {
    for (final StoryShelf shelf in StoryShelf.values) {
      test('${shelf.name} — maandishi yanasomeka juu ya tint yake', () {
        final Color tint = ContrastUtils.blend(
          shelf.accent.withValues(alpha: 0.12),
          AppColors.background,
        );
        final Color ink = ContrastUtils.readableInk(shelf.accent, tint);

        final double actual = ContrastUtils.ratio(ink, tint);
        expect(
          actual,
          greaterThanOrEqualTo(ContrastUtils.aaNormalText),
          reason:
              '${shelf.name}: ink juu ya tint ni ${actual.toStringAsFixed(2)}:1 '
              '— inahitaji ${ContrastUtils.aaNormalText}:1',
        );
      });
    }

    test('sunsetGold maandishi ya "Hadithi ya kulipia" yanasomeka', () {
      final Color ink = ContrastUtils.readableInk(
        AppColors.sunsetGold,
        AppColors.background,
      );
      expect(
        ContrastUtils.ratio(ink, AppColors.background),
        greaterThanOrEqualTo(ContrastUtils.aaNormalText),
      );
    });

    test('sunsetGold nyota hufikia 3:1 (kipengele cha maana)', () {
      final Color ink = ContrastUtils.readableInk(
        AppColors.sunsetGold,
        AppColors.background,
        target: ContrastUtils.nonText,
      );
      expect(
        ContrastUtils.ratio(ink, AppColors.background),
        greaterThanOrEqualTo(ContrastUtils.nonText),
      );
    });

    test('rangi inayofikia kiwango tayari haibadilishwi', () {
      // safariGreen juu ya cream ni 8.85:1 — hivyo inabaki kama ilivyo.
      expect(
        ContrastUtils.readableInk(AppColors.safariGreen, AppColors.background),
        AppColors.safariGreen,
      );
    });
  });

  group('jozi za msingi za app (kumbukumbu ya WCAG)', () {
    // Hizi ni jozi zinazotumika kwenye ukurasa wa maelezo. Kama jozi yoyote
    // itashuka chini ya kiwango baadaye, jaribio hili litasimama.
    final Map<String, (Color, Color, double)> pairs =
        <String, (Color, Color, double)>{
      'whiteText on safariGreen (Read Now)': (
        const Color(0xFFFFFFFF),
        AppColors.safariGreen,
        ContrastUtils.aaNormalText,
      ),
      'bodyText on background': (
        AppColors.bodyText,
        AppColors.background,
        ContrastUtils.aaNormalText,
      ),
      'mutedText on background': (
        AppColors.mutedText,
        AppColors.background,
        ContrastUtils.aaNormalText,
      ),
      'darkText on cardBackground': (
        AppColors.darkText,
        AppColors.cardBackground,
        ContrastUtils.aaNormalText,
      ),
    };

    pairs.forEach((String name, (Color, Color, double) pair) {
      test(name, () {
        final double actual = ContrastUtils.ratio(pair.$1, pair.$2);
        expect(
          actual,
          greaterThanOrEqualTo(pair.$3),
          reason: '$name ni ${actual.toStringAsFixed(2)}:1',
        );
      });
    });
  });
}
