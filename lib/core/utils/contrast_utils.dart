/// Uwiano wa utofautishaji wa rangi (WCAG 2.1 contrast ratio).
///
/// **Kwa nini faili hili lipo:** Tanzania ina jua kali na watoto husoma nje
/// kwenye simu za bei nafuu (Tecno/Itel) zenye skrini hafifu. Rangi ambazo
/// "zinaonekana vizuri" kwenye kioo cha kifaa cha maendeleo **hazisomeki**
/// kwenye skrini hiyo. Kanuni ya mradi ilitupa jukumu la **kupima**, si
/// kuamua kwa macho.
///
/// ## Tatizo lililopimwa
///
/// Chipu za vibonge kwenye ukurasa wa maelezo zilikuwa zikitumia **rangi ya
/// chapa kama rangi ya maandishi juu ya tint yake ya 12%**. Hii ni kati ya
/// mifumo inayoshindwa zaidi kwa WCAG:
///
/// ```
/// brightGreen (#4CAF50) juu ya tint yake  →  2.39:1   ✗ (inahitaji 4.5)
/// skyBlue     (#42A5F5) juu ya tint yake  →  2.28:1   ✗
/// sunsetGold  (#F39C12) juu ya cream      →  2.10:1   ✗
/// ```
///
/// Rangi iliyo angavu haiwezi kusomeka juu ya toleo lake lenye rangi hafifu.
///
/// ## Suluhisho
///
/// [readableInk] hupunguza mwangaza wa rangi **hadi kufikia kiwango**, kisha
/// hurudisha toleo hilo. Kwa hivyo:
///
/// * Rangi ya chapa inabaki kwenye **mandhari** (tint) na **mpaka** — hivyo
///   utambulisho wa rangi unabaki kwa macho.
/// * Maandishi na ikoni hutumia **toleo lililozidishwa giza** la rangi hiyo
///   hiyo — hue ile ile, lakini inasomeka.
///
/// Hii ni bora kuliko kuandika hex nyingine kwa mkono: rangi mpya ya chapa
/// inayongezwa baadaye **hupata toleo linalosomeka moja kwa moja**, bila
/// mtu kusahau kupima.
///
/// Oh! na hapa ni muhimu: [blend] hukusanya rangi yenye uwazi juu ya mandhari
/// — bila hiyo, kupima `brand.withOpacity(0.12)` juu ya cream hakuwezekani.
library;

import 'dart:math' as math;
import 'dart:ui' show Color;

/// Zana za kupima na kurekebisha utofautishaji wa rangi.
abstract final class ContrastUtils {
  /// Kiwango cha WCAG AA kwa **maandishi ya kawaida**.
  static const double aaNormalText = 4.5;

  /// Kiwango cha WCAG AA kwa **maandishi makubwa** (18pt+ au 14pt bold+).
  static const double aaLargeText = 3.0;

  /// Kiwango cha **vipengele visivyo maandishi** (ikoni, mipaka, grafu).
  static const double nonText = 3.0;

  /// Hugeuza kikundi cha rangi (0–255) kuwa mwangaza wa mstari.
  static double _linearise(int channel) {
    final double c = channel / 255.0;
    if (c <= 0.03928) return c / 12.92;
    return math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  /// Mwangaza husiana (relative luminance) wa [color] — 0.0 (nyeusi) hadi 1.0.
  ///
  /// Hupuuza alpha: tumia [blend] kwanza kama rangi ina uwazi.
  static double relativeLuminance(Color color) {
    return 0.2126 * _linearise(color.red) +
        0.7152 * _linearise(color.green) +
        0.0722 * _linearise(color.blue);
  }

  /// Uwiano wa utofautishaji kati ya rangi mbili — 1.0 hadi 21.0.
  ///
  /// Mpangilio hauna maana: `ratio(a, b) == ratio(b, a)`.
  static double ratio(Color a, Color b) {
    final double la = relativeLuminance(a);
    final double lb = relativeLuminance(b);
    final double lighter = math.max(la, lb);
    final double darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Huchanganya [foreground] yenye uwazi juu ya [background] isiyo na uwazi.
  ///
  /// Muhimu kwa kupima rangi za tint: `brand.withOpacity(0.12)` **si** rangi
  /// halisi inayoonekana — ile inayoonekana ni mchanganyiko.
  static Color blend(Color foreground, Color background) {
    final double a = foreground.opacity;
    if (a >= 1.0) return foreground;

    int mix(int f, int b) => (f * a + b * (1 - a)).round();

    return Color.fromARGB(
      255,
      mix(foreground.red, background.red),
      mix(foreground.green, background.green),
      mix(foreground.blue, background.blue),
    );
  }

  /// Hurudisha toleo la [brand] linalosomeka juu ya [background].
  ///
  /// Hupunguza mwangaza hatua kwa hatua na kurudisha **toleo la kwanza
  /// linalofikia [target]** — hivyo tunabaki karibu na rangi ya chapa
  /// iwezekanavyo badala ya kuruka moja kwa moja kwenye nyeusi.
  ///
  /// Kama hata nyeusi haifikii [target] (background ni nyeusi kabisa),
  /// hurudisha nyeusi — haitupi, kwa sababu rangi ya kushindwa haipaswi
  /// kuvunja ukurasa.
  static Color readableInk(
    Color brand,
    Color background, {
    double target = aaNormalText,
    int steps = 60,
  }) {
    // Nyepesi kwanza: kama rangi yenyewe inafikia kiwango, usiibadilishe.
    if (ratio(brand, background) >= target) return brand;

    for (int i = 1; i <= steps; i++) {
      final double factor = 1.0 - (i / steps) * 0.92;
      final Color candidate = Color.fromARGB(
        255,
        (brand.red * factor).round(),
        (brand.green * factor).round(),
        (brand.blue * factor).round(),
      );
      if (ratio(candidate, background) >= target) return candidate;
    }

    return const Color(0xFF000000);
  }
}
