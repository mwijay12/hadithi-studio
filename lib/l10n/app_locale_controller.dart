/// Kidhibiti cha lugha cha app nzima (runtime language switching).
///
/// **Kwa nini faili hili lipo:** `MaterialApp.router` iliyokuwa na
/// `localeResolutionCallback` pekee **haiwezi** kubadilisha lugha wakati
/// mtumiaji anagusa "Kiswahili" kwenye onboarding. `localeResolutionCallback`
/// huitwa mara moja tu, kutokana na lugha ya kifaa/browser — si chaguo la
/// mtumiaji. Bila `locale:` ya moja kwa moja kwenye `MaterialApp`, chaguo la
/// mtumiaji halina athari yoyote.
///
/// Suluhisho: `ChangeNotifier` moja ya kimataifa. `app.dart` inaisikiliza na
/// kupitisha `locale` kwenye `MaterialApp.router`; skrini yoyote inayotaka
/// kubadilisha lugha inaita [use].
///
/// **Kwa nini `static instance` na si DI:** tunaingiza hii kwenye `lib/app.dart`
/// ambayo hujengwa **kabla** ya DI container (`main.dart`). Pia preview ya web
/// (`main_web_preview.dart`) inaruka DI kabisa kwa sababu `CacheManager`
/// hutumia `dart:io`. Singileni hapa inahakikisha `app.dart` na skrini za
/// mwanzo (splash, onboarding) zinapata kidhibiti bila kutegemea DI.
///
/// **HIFADHI (imeongezwa):** awali kidhibiti hiki kilikuwa **kwenye kumbukumbu
/// pekee**. Matokeo: mtumiaji alichagua Kiingereza, kisha ukurasa ukapakiwa
/// upya (kitu cha kawaida sana kwenye web) — Dart VM inaanza upya, kidhibiti
/// kinarudi kwenye `AppLanguage.swahili`, na **hadithi zote zinarudi
/// Kiswahili**. Sasa chaguo huhifadhiwa kwa `shared_preferences` na
/// hurejeshwa kwa [restore] kabla ya `runApp`.
library;

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/enums/app_enums.dart';

/// Hushikilia lugha ya sasa ya app na kuwajulisha wasikilizaji wanapobadilika.
class AppLocaleController extends ChangeNotifier {
  AppLocaleController({
    AppLanguage initial = AppLanguage.swahili,
  })  : _language = initial,
        _locale = initial.locale;

  /// Kidhibiti kimoja kinachotumika kwenye app nzima.
  static final AppLocaleController instance = AppLocaleController();

  /// Ufunguo wa hifadhi.
  ///
  /// Tunahifadhi **`AppLanguage.name`** (`'swahili'`/`'english'`/`'bilingual'`)
  /// na **si** `code` ya ISO. Sababu: [AppLanguage.bilingual] ina code ile ile
  /// `'sw'` kama [AppLanguage.swahili] — kwa hivyo `fromCode('sw')` haiwezi
  /// kutofautisha "Lugha Zote" na "Kiswahili", na chaguo hilo lingepotea.
  static const String prefsKey = 'hadithi_app_language';

  AppLanguage _language;
  Locale? _locale;

  /// Lugha ya sasa kama [AppLanguage].
  ///
  /// Hii ni muhimu kwa `bilingual`: [AppLanguage.bilingual] na
  /// [AppLanguage.swahili] zina code ile ile (`'sw'`), kwa hivyo `locale`
  /// pekee haiwezi kutofautisha kati yao. Sehemu inayohitaji kujua kama
  /// mtumiaji alichagua lugha zote mbili (mfano Reader) inasoma hapa.
  AppLanguage get language => _language;

  /// `true` = mtumiaji amechagua **"Lugha Zote"** (Kiswahili NA Kiingereza).
  ///
  /// **Kwa nini getter hii ilikuwa muhimu:** `AppLanguage.bilingual` ina code
  /// ya ISO `'sw'` kwa makusudi — ili UI yote (vitufe, menu) ijipange
  /// Kiswahili. Lakini matokeo yake ni kwamba `l10n.localeName == 'sw'` ni
  /// **kweli kwa "Kiswahili pekee" NA "Zote"** — hivyo msimbo haukuweza
  /// kuzitofautisha, na "Lugha Zote" ilionekana kama Kiswahili tu.
  ///
  /// Hali halisi ya chaguo ipo hapa, si kwenye `localeName`. Kila kitu
  /// kinachotaka kuonyesha lugha mbili kingepima **hii**.
  bool get isBilingual => _language == AppLanguage.bilingual;

  /// Locale inayopitishwa kwa `MaterialApp`.
  ///
  /// Huanza na Kiswahili kwa makusudi: app hii ni ya Tanzania kwanza,
  /// na `AppLocalizationsSetup.fallbackLocale` pia ni `'sw'`. Bila hivi,
  /// mtumiaji wa Tanzania mwenye browser ya Kiingereza angeanza na
  /// Kiingereza bila kuchagua.
  ///
  /// TANBIHI: hii ni **default** pekee. Kama mtumiaji alishachagua lugha,
  /// [restore] huirudisha kabla `runApp` — hivyo chaguo lake hushinda.
  Locale get locale => _locale ?? _language.locale;

  /// Husoma chaguo lililohifadhiwa na kulifanya la sasa.
  ///
  /// Huitwa **kabla ya `runApp`** ili UI ya kwanza iwe tayari kwa lugha
  /// sahihi — bila hivi, mtumiaji anaona Kiswahili kwa sekunde moja kisha
  /// kinabadilika (mtetemo wa maandishi).
  ///
  /// Haitui (throw) kamwe: kama hifadhi haipatikani, tunaendelea na default.
  Future<void> restore() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? stored = prefs.getString(prefsKey);
      if (stored == null) return;
      final AppLanguage? saved = _byName(stored);
      if (saved == null) return;
      _apply(saved);
    } catch (error) {
      // Hifadhi ni mapambo, si sharti — app inafanya kazi bila yake.
      debugPrint('AppLocaleController: kurejesha lugha kimeshindwa — $error');
    }
  }

  /// Hubadilisha lugha ya app, huhifadhi, na kuwajulisha wasikilizaji.
  void use(AppLanguage language) {
    if (_language == language && _locale == language.locale) {
      return;
    }
    _apply(language);
    // Huhifadhi kwa chinichini — UI haisubiri disk.
    unawaited(_persist(language));
  }

  /// Hubadilisha lugha moja kwa moja kutoka `Locale` (mfano tunaposoma
  /// chaguo lililohifadhiwa kwenye `LocalStorage`).
  void useLocale(Locale locale) =>
      use(AppLanguage.fromCode(locale.languageCode));

  void _apply(AppLanguage language) {
    _language = language;
    _locale = language.locale;
    notifyListeners();
  }

  Future<void> _persist(AppLanguage language) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefsKey, language.name);
    } catch (error) {
      debugPrint('AppLocaleController: kuhifadhi lugha kimeshindwa — $error');
    }
  }

  /// Hutafuta [AppLanguage] kwa `name` yake — hutofautisha `bilingual`.
  static AppLanguage? _byName(String name) {
    for (final AppLanguage language in AppLanguage.values) {
      if (language.name == name) return language;
    }
    return null;
  }
}
