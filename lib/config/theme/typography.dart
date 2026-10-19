import 'package:flutter/material.dart';

/// Typography ya Hadithi Studio.
///
/// Font zote ziko **ndani ya app** (`assets/fonts/`), zimefungwa kwenye
/// `pubspec.yaml`. Hakuna `google_fonts` tena — kwa hivyo app inaonyesha
/// maandishi sahihi **bila mtandao**, tangu sekunde ya kwanza. Hii ni
/// muhimu kwa Tanzania ambapo data ni ghali na mtandao si wa kuaminika.
///
/// Fonts:
/// - Nunito          → maandishi ya jumla (nzuri kwa Kiswahili + watoto)
/// - Poppins         → UI elements
/// - Merriweather    → maandishi ya hadithi (serif, rahisi kusoma)
/// - Baloo 2         → vichwa vya habari (playful)
abstract final class AppTypography {
  static const String bodyFontFamily = 'Nunito';
  static const String uiFontFamily = 'Poppins';
  static const String storyFontFamily = 'Merriweather';
  static const String displayFontFamily = 'Baloo2';

  // Vipimo — kutoka spec.
  static const double sizeDisplay = 32;
  static const double sizeH1 = 28;
  static const double sizeH2 = 24;
  static const double sizeH3 = 20;
  static const double sizeBodyLarge = 18;
  static const double sizeBody = 16;
  static const double sizeBodySmall = 14;
  static const double sizeCaption = 12;

  /// Maandishi ya hadithi yanaweza kubadilishwa na msomaji (accessibility).
  static const double minStoryTextSize = 16;
  static const double maxStoryTextSize = 28;
  static const double defaultStoryTextSize = 18;

  /// TextTheme kamili ya UI.
  static TextTheme textTheme({
    required Color bodyColor,
    required Color mutedColor,
  }) {
    final TextStyle heading = TextStyle(color: bodyColor);
    return TextTheme(
      // displayLarge  → Display 32sp
      displayLarge: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: sizeDisplay,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: heading.color,
      ),
      // displayMedium → H1 28sp
      displayMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: sizeH1,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: heading.color,
      ),
      // displaySmall  → H2 24sp
      displaySmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: sizeH2,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: heading.color,
      ),
      // headlineSmall → H3 20sp
      headlineSmall: TextStyle(
        fontFamily: uiFontFamily,
        fontSize: sizeH3,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: heading.color,
      ),
      // titleLarge → AppBar, sheet headers
      titleLarge: TextStyle(
        fontFamily: uiFontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: heading.color,
      ),
      titleMedium: TextStyle(
        fontFamily: uiFontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: heading.color,
      ),
      // bodyLarge → 18sp
      bodyLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: sizeBodyLarge,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: bodyColor,
      ),
      // bodyMedium → 16sp (body default)
      bodyMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: sizeBody,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: bodyColor,
      ),
      // bodySmall → 14sp
      bodySmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: sizeBodySmall,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: sizeBody,
        fontWeight: FontWeight.w700,
        color: heading.color,
      ),
      // labelSmall → caption 12sp
      labelSmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: sizeCaption,
        fontWeight: FontWeight.w500,
        color: mutedColor,
      ),
    );
  }

  /// Maandishi ya hadithi — serif, line-height kubwa kwa urahisi wa kusoma.
  ///
  /// Kiswahili kina maneno marefu (mfano "wanakwenda"); kwa hivyo tunatumia
  /// `height: 1.8` na `letterSpacing` ndogo ili macho yasichoke.
  static TextStyle storyText({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.8,
    bool isBilingual = false,
  }) {
    return TextStyle(
      fontFamily: storyFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: 0.1,
      color: color,
      decoration: isBilingual ? TextDecoration.none : null,
    );
  }

  /// Kichwa cha habari cha kirafiki (Kiswahili display).
  static TextStyle swahiliDisplay({
    required double fontSize,
    Color? color,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return TextStyle(
      fontFamily: displayFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
