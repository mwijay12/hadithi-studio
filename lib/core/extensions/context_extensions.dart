/// Nyongeza (extensions) za `BuildContext`.
///
/// Kwa nini faili hili lipo: kila widget yetu inahitaji lugha (l10n), rangi za
/// Tanzania, ukubwa wa skrini na ufikiaji wa `MediaQuery`. Badala ya kuandika
/// `MediaQuery.of(context).size.width < 600` kila mahali — au kuacha kosa la
/// `null` kwa sababu `Theme.of(context)` haina rangi — tunaweka njia moja hapa.
///
/// MUHIMU wa matoleo: tunatumia `MediaQuery.of(context)`, SI `MediaQuery.sizeOf`
/// wala `MediaQuery.paddingOf`, kwa sababu njia za kwanza ziliongezwa kwenye
/// Flutter ya baadaye. SDK constraint yetu ni `>=3.2.0`, hivyo hii ni njia
/// inayojenga kila mahali.
library;

import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';
import '../../l10n/app_locale_controller.dart';
import '../../l10n/l10n.dart';

extension ContextX on BuildContext {
  // ---------------------------------------------------------------------------
  // Lugha (localization)
  // ---------------------------------------------------------------------------

  // Kumbuka: `context.l10n` HAITANGAZWI hapa. Ilitangazwa kwenye
  // `extension L10nX` (lib/l10n/l10n.dart), ambayo faili hili linaiimport
  // hapo juu. Kutangaza `l10n` hapa pia kunasababisha kosa la
  // "ambiguous extension member" kwenye kila `.l10n` use site — kwa hivyo
  // tangazo moja tu, mahali pamoja. `isSwahili`/`isEnglish` hapa chini
  // zinatumia `L10nX.l10n` kupitia import hiyo.

  /// `true` kama lugha ya sasa ni Kiswahili.
  ///
  /// Hutumika kuchagua sauti ya TTS kwa default (Mama/Baba) bila kuuliza.
  bool get isSwahili => l10n.localeName == 'sw';

  /// `true` kama lugha ya sasa ni Kiingereza.
  bool get isEnglish => l10n.localeName == 'en';

  /// `true` = mtumiaji amechagua **"Lugha Zote"** (Kiswahili NA Kiingereza).
  ///
  /// **Kwa nini haiwezi kutokotolewa kutoka `l10n`:** `AppLanguage.bilingual`
  /// ina code `'sw'`, hivyo `l10n.localeName == 'sw'` ni kweli **kwa
  /// Kiswahili pekee na kwa Zote pia**. Hali halisi ipo kwenye
  /// [AppLocaleController]. Bila getter hii, "Lugha Zote" ilionekana kama
  /// Kiswahili tu.
  bool get isBilingual => AppLocaleController.instance.isBilingual;

  // ---------------------------------------------------------------------------
  // Mandhari (theme)
  // ---------------------------------------------------------------------------

  /// `ThemeData` ya sasa — halisi, si `null`.
  ThemeData get theme => Theme.of(this);

  /// Rangi za sasa (light au dark) — hizi hubadilika na mandhari.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Maandishi ya sasa (fonts, ukubwa) — Nunito/Poppins/Merriweather.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// `true` kama mandhari ya usiku (night mode) inatumika.
  ///
  /// Hii ni muhimu kwa Reader: usiku tunabadilisha ukurasa mzima kuwa
  /// kahawia nyeusi ili macho ya mtoto yasichoke.
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // Ukubwa wa skrini (responsive)
  // ---------------------------------------------------------------------------

  /// Ukubwa kamili wa skrini.
  ///
  /// Kumbuka: kwenye simu ndogo za Tanzania (Tecno/Itel 5.0"–5.5") upana
  /// huwa 360dp au chini, hivyo `isCompact` ni muhimu sana.
  Size get screenSize => MediaQuery.of(this).size;

  /// Upana wa skrini kwa dp.
  double get screenWidth => screenSize.width;

  /// Urefu wa skrini kwa dp.
  double get screenHeight => screenSize.height;

  /// `true` kama skrini ni ndogo sana (chini ya 360dp) — tunapunguza padding.
  ///
  /// Kanuni iko kwenye [AppBreakpoints.isCompactWidth] — hatuiandiki tena hapa,
  /// ili `AppBreakpoints.isCompact(context)` na kizingiti hiki visitofautiane.
  bool get isCompact => AppBreakpoints.isCompactWidth(screenWidth);

  /// `true` kama kifaa ni tablet (900dp na juu).
  bool get isTablet => AppBreakpoints.isTabletWidth(screenWidth);

  /// `true` kama kifaa ni desktop/web (1200dp na juu).
  bool get isDesktop => AppBreakpoints.isDesktopWidth(screenWidth);

  /// Mwelekeo wa skrini (wima/sambamba) — Reader inatumia hii.
  Orientation get orientation => MediaQuery.of(this).orientation;

  /// Eneo lililo salama juu (notch/status bar).
  double get topInset => MediaQuery.of(this).padding.top;

  /// Eneo lililo salama chini (vitufe vya mfumo, `GestureBar`).
  ///
  /// Bottom navigation yetu ina urefu [AppSpacing.bottomNavHeight], lakini
  /// kwenye simu zenye gesture bar tunahitaji kuongeza [bottomInset] juu yake.
  double get bottomInset => MediaQuery.of(this).padding.bottom;

  /// Urefu wa bottom navigation ukiwa umeongeza eneo salama la chini.
  double get bottomNavTotalHeight =>
      AppSpacing.bottomNavHeight + bottomInset;

  /// Safu za grid (2 simu, 3 tablet wima, 4 tablet mlalo, 5 desktop/web).
  ///
  /// Kanuni iko kwenye [AppBreakpoints.gridColumnsFor] — chanzo kimoja.
  /// Ukurasa wa rafu na wa hadithi zote hutumia hii ili kadi zisibadilike
  /// ukubwa kwenye skrini ile ile.
  int get gridColumns => AppBreakpoints.gridColumnsFor(screenWidth);

  /// Kipimo cha font kilichowekwa na mtumiaji (kubwa) — tunapunguza layout.
  ///
  /// TUNATUMIA `MediaQueryData.textScaleFactor`, SI `textScaler.scale(...)`:
  /// `TextScaler` iliongezwa kwenye Flutter 3.16, wakati mradi huu umejikita
  /// kwenye Flutter 3.2 (ndiyo sababu `app_theme.dart` inatumia
  /// `FadeUpwardsPageTransitionsBuilder`). Kwenye toolchain ya 3.2–3.15
  /// `textScaler` haipo kabisa. Hii inarudisha `double`.
  ///
  /// Sehemu za kusoma (Reader) hutumia thamani hii kukata ukubwa wa herufi
  /// ili maandishi yasivunjike kwenye skrini ndogo za Tecno/Itel.
  double get textScaleFactor => MediaQuery.of(this).textScaleFactor;

  // ---------------------------------------------------------------------------
  // Vitendo (actions)
  // ---------------------------------------------------------------------------

  /// Kufunga keyboard inayofunguliwa na fomu.
  void hideKeyboard() => FocusScope.of(this).unfocus();

  /// Kuonyesha ujumbe mfupi (snack bar) kwa lugha ya sasa.
  ///
  /// Kama [isError] ni `true`, rangi ni `colorScheme.error` — hutumika kwa
  /// kosa la mtandao au malipo yaliyoshindwa.
  /// TANBIHI wa matoleo: tunatumia `scheme.onSurface`/`scheme.surface`, SI
  /// `scheme.inverseSurface`/`scheme.onInverseSurface`. Rangi za "inverse"
  /// ziliongezwa kwenye Flutter 3.3 pamoja na rangi zilizobaki za Material 3,
  /// wakati mradi huu umejikita kwenye Flutter 3.2. Rangi hizi zinalingana na
  /// `snackBarTheme` iliyowekwa kwenye `app_theme.dart`
  /// (`backgroundColor: scheme.onSurface`, maandishi `scheme.surface`).
  void showSnackBar(String message, {bool isError = false}) {
    final scheme = colorScheme;
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: textTheme.bodySmall?.copyWith(
              color: isError ? scheme.onError : scheme.surface,
            ),
          ),
          backgroundColor: isError ? scheme.error : scheme.onSurface,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  /// Kufunga snack bar ya sasa (mfano mtandao unapopatikana tena).
  void hideSnackBar() => ScaffoldMessenger.of(this).hideCurrentSnackBar();
}
