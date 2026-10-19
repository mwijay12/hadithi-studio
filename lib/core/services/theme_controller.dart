/// Kidhibiti cha **muonekano** (light / dark / system) cha app nzima.
///
/// ## Kwa nini faili hili lipo
///
/// Awali `MaterialApp.router` ilikuwa na `themeMode: ThemeMode.system`
/// **iliyowekwa moja kwa moja**. Matokeo: mtumiaji hakuwa na njia yoyote ya
/// kubadilisha muonekano. Simu ikiwa kwenye dark mode, app inafuata — na
/// kwa kuwa kurasa nyingi zilikuwa na rangi za light-mode zilizowekwa kwa
/// mkono, matokeo yalikuwa maandishi yasiyoonekana.
///
/// Mtumiaji aliyeripoti alisema wazi: *"iweze kuwa ina place ya kubadilisha
/// simu kutoka light"*. Faili hili hutoa chaguo hilo — na kwa kuwa
/// **huhifadhiwa**, halirudi kwenye default kila kufungua app.
///
/// ## Kwa nini `ChangeNotifier` ya kimataifa
///
/// Ni kiolezo kile kile cha [AppLocaleController]: `app.dart` hujengwa
/// kabla ya DI, na skrini za mwanzo (splash, onboarding) hazina `get_it`.
/// Singileni inafanya `app.dart` isikilize mabadiliko bila DI.
///
/// ## Nuru ni default, sivyo `system`
///
/// Toleo hili lina kurasa ambazo bado hazijabadilishwa kikamilifu kuwa
/// theme-aware. `system` ingempa mtumiaji wa dark-mode mandhari nusu
/// iliyobadilishwa — jambo ambalo ni kubaya kuliko chaguo la wazi. Kwa hivyo
/// tunaanza **nuru** (muonekano uliopimwa kikamilifu), na mtumiaji anayeitaka
/// giza anaichagua mwenyewe kwenye Settings.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Chaguo la muonekano.
enum AppThemeMode {
  /// Hufuata mipangilio ya simu.
  system,

  /// Nuru — muonekano wa default.
  light,

  /// Giza.
  dark;

  /// Jina kwa Kiswahili (kwa UI).
  String get labelSw {
    switch (this) {
      case AppThemeMode.system:
        return 'Mfumo';
      case AppThemeMode.light:
        return 'Nuru';
      case AppThemeMode.dark:
        return 'Giza';
    }
  }

  /// Jina kwa Kiingereza (kwa UI).
  String get labelEn {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }

  /// Nembo ya chaguo.
  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
    }
  }

  /// Thamani ya `ThemeMode` ya Flutter.
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Hutafuta kutoka [name] (kwa kusoma hifadhi).
  ///
  /// Hurudisha [light] kama thamani haijulikani — default salama.
  static AppThemeMode fromName(String? name) {
    for (final AppThemeMode mode in AppThemeMode.values) {
      if (mode.name == name) return mode;
    }
    return AppThemeMode.light;
  }
}

/// Hushikilia muonekano wa sasa na kuwajulisha wasikilizaji.
class ThemeController extends ChangeNotifier {
  ThemeController({AppThemeMode initial = AppThemeMode.light})
      : _mode = initial;

  /// Kidhibiti kimoja kinachotumika app nzima.
  static final ThemeController instance = ThemeController();

  /// Ufunguo wa hifadhi.
  static const String prefsKey = 'hadithi_theme_mode';

  AppThemeMode _mode;

  /// Muonekano uliochaguliwa.
  AppThemeMode get selection => _mode;

  /// Thamani inayopewa `MaterialApp.themeMode`.
  ThemeMode get themeMode => _mode.themeMode;

  /// Husoma chaguo lililohifadhiwa.
  ///
  /// Huitwa **kabla** ya `runApp` (`main.dart`) ili app ianze na muonekano
  /// sahihi badala ya kubadilika mbele ya macho ya mtumiaji.
  Future<void> restore() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _mode = AppThemeMode.fromName(prefs.getString(prefsKey));
    } catch (error) {
      // Hifadhi haipatikani: tunabaki kwenye default. Hakuna `throw` —
      // muonekano si sababu ya kuzuia app kufunguka.
      debugPrint('ThemeController: kusoma muonekano kimeshindwa — $error');
    }
    notifyListeners();
  }

  /// Hubadilisha muonekano na kuhifadhi papo hapo.
  ///
  /// UI hubadilika **kwanza** (notifyListeners), kisha tunaandika — kwa
  /// hivyo mguso unaonekana kuwa wa haraka hata kama disk ni ya pole.
  Future<void> use(AppThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, mode.name);
    } catch (error) {
      debugPrint('ThemeController: kuhifadhi muonekano kimeshindwa — $error');
    }
  }
}
