/// Majaribio ya utofautishaji wa **theme halisi** (light na dark).
///
/// ## Kosa lililopelekea jaribio hili
///
/// Ukurasa wa Mipangilio ulikuwa na `backgroundColor: AppColors.background`
/// (cream `#FAFAF8`) **iliyowekwa kwa mkono**, wakati `ListTile` huchukua
/// rangi ya maandishi **kutoka theme**. Kwenye dark mode, `ListTile` hutoa
/// `#E6E6E6` (karibu nyeupe) — yaani **maandishi yasiyoonekana juu ya
/// cream**. Mtumiaji aliripoti: *"white text zipo kwenye white background"*.
///
/// Jaribio hili hupima jozi halisi za `ColorScheme` kwa light NA dark, ili
/// kosa la aina hii linasimama **kabla** ya mtumiaji kuliona.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hadithi_studio/config/theme/app_theme.dart';
import 'package:hadithi_studio/config/theme/colors.dart';
import 'package:hadithi_studio/config/theme/dark_theme.dart';
import 'package:hadithi_studio/core/utils/contrast_utils.dart';

/// Hupima jozi muhimu za [scheme] na kuripoti kila inayoshindwa.
void _auditScheme(ColorScheme scheme, String label) {
  final List<(String, Color, Color, double)> pairs =
      <(String, Color, Color, double)>[
    ('onSurface / surface', scheme.onSurface, scheme.surface, 4.5),
    (
      'onSurfaceVariant / surface',
      scheme.onSurfaceVariant,
      scheme.surface,
      4.5,
    ),
    ('onPrimary / primary', scheme.onPrimary, scheme.primary, 4.5),
    ('onError / error', scheme.onError, scheme.error, 4.5),
    // Vipengele visivyo maandishi (ikoni, mipaka): 3:1.
    ('primary / surface', scheme.primary, scheme.surface, 3.0),
    // **Kitufe cha `Switch` kilicho ZIMWA** hutumia `outline` juu ya
    // `surfaceVariant`. Hii ilikuwa 1.05:1 kwenye light — hakionekani.
    // Ukaguzi wa macho uliipata; jaribio hili huizuia kurudi.
    ('outline / surfaceVariant', scheme.outline, scheme.surfaceVariant, 3.0),
  ];

  for (final (String name, Color fg, Color bg, double need) in pairs) {
    final double actual = ContrastUtils.ratio(fg, bg);
    expect(
      actual,
      greaterThanOrEqualTo(need),
      reason: '$label — $name ni ${actual.toStringAsFixed(2)}:1, '
          'inahitaji ${need.toStringAsFixed(1)}:1',
    );
  }
}

void main() {
  // **Kwa nini hii ni lazima:** `AppTheme.light` hujenga `AppTypography`,
  // ambayo hutumia `google_fonts`. `google_fonts` hupakua fonti kwa **HTTP**
  // wakati wa kujenga, hivyo kwenye majaribio (bila mtandao) inatupa
  // exception — na jaribio hili lilikuwa linashindwa kwa sababu hiyo, sivyo
  // kwa contrast.
  //
  // Kuzima runtime fetching hufanya google_fonts itumie fonti ya akiba.
  //
  // **Hii pia ni onyo la production:** kwenye simu ya Tanzania isiyo na
  // mtandao, typography hii huanguka kwenye fonti ya mfumo. Kuweka fonti
  // ndani ya app (kama `assets/fonts/`) ni kazi inayosubiri.
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('ColorScheme ya light hukidhi WCAG AA', () {
    test('jozi zote muhimu', () {
      // Scheme PEKEE — haiitaji typography/`google_fonts`.
      _auditScheme(AppTheme.lightScheme, 'LIGHT');
    });
  });

  group('ColorScheme ya dark hukidhi WCAG AA', () {
    test('jozi zote muhimu', () {
      _auditScheme(DarkTheme.darkScheme, 'DARK');
    });
  });

  group('kosa la awali — limeandikwa kwa namba', () {
    test('cream + maandishi ya dark theme ni MBAYA (ndiyo kosa lililokuwepo)', () {
      final double broken = ContrastUtils.ratio(
        AppColors.darkBodyText,
        AppColors.background,
      );
      // Hii inathibitisha hatari ilikuwa ya kweli, sivyo ya kudhaniwa.
      expect(
        broken,
        lessThan(ContrastUtils.aaNormalText),
        reason: 'kama hii inapita, mandhari ya cream + maandishi ya dark '
            'theme yangekuwa salama — lakini haipiti',
      );
    });

    test('mchanganyiko SAHIHI wa light unafaa', () {
      expect(
        ContrastUtils.ratio(AppColors.bodyText, AppColors.background),
        greaterThanOrEqualTo(ContrastUtils.aaNormalText),
      );
    });

    test('mchanganyiko SAHIHI wa dark unafaa', () {
      expect(
        ContrastUtils.ratio(AppColors.darkBodyText, AppColors.darkSurface),
        greaterThanOrEqualTo(ContrastUtils.aaNormalText),
      );
    });
  });

  group('modes ya usiku ya reader (kanuni #15)', () {
    test('maandishi ya usiku yanasomeka juu ya mandhari ya usiku', () {
      expect(
        ContrastUtils.ratio(
          AppColors.readerNightText,
          AppColors.readerNightBackground,
        ),
        greaterThanOrEqualTo(ContrastUtils.aaNormalText),
      );
    });

    test('maneno yaliyopita yanasomeka (hafifu lakini bado yanasomeka)', () {
      expect(
        ContrastUtils.ratio(
          AppColors.readerNightPastText,
          AppColors.readerNightBackground,
        ),
        greaterThanOrEqualTo(ContrastUtils.aaNormalText),
      );
    });

    test('neno linalosomwa: maandishi meusi juu ya njano', () {
      // Hiki ndicho kivutio kikubwa cha app — kama hakionekani, hakuna
      // maana. Spec inasema wazi: "NEVER put white text on gold".
      expect(
        ContrastUtils.ratio(AppColors.darkText, AppColors.playfulYellow),
        greaterThanOrEqualTo(ContrastUtils.aaNormalText),
      );
    });

    test('nyeupe juu ya njano ni MBAYA (kwa nini spec ilikataza)', () {
      final double broken = ContrastUtils.ratio(
        const Color(0xFFFFFFFF),
        AppColors.playfulYellow,
      );
      expect(broken, lessThan(ContrastUtils.aaNormalText));
    });
  });
}
