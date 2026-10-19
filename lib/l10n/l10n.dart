import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/enums/app_enums.dart';
import 'generated/app_localizations.dart';

/// Tunasafirisha class iliyotengenezwa ili sehemu nyingine za app zisiandike
/// `package:hadithi_studio/l10n/generated/app_localizations.dart` kila mara.
export 'generated/app_localizations.dart';

/// L10N — kiingilio kimoja cha tafsiri (kanuni ya 4: Kiswahili **na**
/// Kiingereza kwenye kila kitu kinachoonekana kwa mtumiaji).
///
/// **MUHIMU:** `lib/l10n/generated/` haijaandikwa kwa mkono. Inazalishwa na
/// `flutter pub get` (kutokana na `generate: true` iliyo kwenye pubspec.yaml)
/// au kwa amri `flutter gen-l10n`, ikisoma `l10n.yaml`, `app_sw.arb` na
/// `app_en.arb`. Kwa hivyo kila funguo iliyotumika hapa chini LAZIMA iwepo
/// kwenye ARB files zote mbili, vinginevyo generation itashindwa.
///
/// Faili hii ni ganda nyembamba (wrapper) lenye faida tatu:
///
/// 1. **Import moja.** `import '.../l10n/l10n.dart';` inatosha kwa
///    `AppLocalizations` pamoja na `context.l10n`.
/// 2. **Hakuna `!`.** `l10n.yaml` ina `nullable-getter: false`, kwa hivyo
///    `AppLocalizations.of(context)` inarudisha `AppLocalizations` (si
///    `AppLocalizations?`). Kwa hivyo `context.l10n` haihitaji `!` — na
///    ingeharibu ikiwa tutaongeza `!` kwa sababu tayari haiwezi kuwa null.
/// 3. **Mipangilio ya MaterialApp pamoja.** [AppLocalizationsSetup] ina
///    `supportedLocales` na `localizationsDelegates`, ili `app.dart` isiwe
///    na orodha ndefu ya delegates.
///
/// Kumbuka: bendera za lugha (`context.isSwahili`, `context.isEnglish`) ziko
/// kwenye `core/extensions/context_extensions.dart` — hazirudiwi hapa ili
/// kuepuka mgongano wa extension members kwa `BuildContext`.
extension L10nX on BuildContext {
  /// Tafsiri za lugha iliyochaguliwa sasa.
  ///
  /// Mfano: `context.l10n.home` → "Nyumbani" (sw) au "Home" (en).
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Huchagua kati ya maandishi mawili kutokana na lugha ya sasa.
  ///
  /// Hii ni kwa ajili ya maandishi **yanayobadilika** (mfano jina la mtumiaji)
  /// ambayo hayawezi kuwa funguo tuli kwenye ARB. Kwa maandishi ya UI ya kawaida
  /// tumia `context.l10n.<key>` ili watafsiri waweze kuyabadilisha.
  ///
  /// Mfano:
  /// ```dart
  /// Text(context.localised(
  ///   swahili: 'Habari $jina!',
  ///   english: 'Hello $jina!',
  /// ))
  /// ```
  String localised({required String swahili, required String english}) =>
      AppLocalizations.of(this).localeName == _swahiliCode ? swahili : english;

  /// Aina ya lugha inayotumika sasa kama [AppLanguage].
  AppLanguage get appLanguage =>
      AppLanguage.fromCode(AppLocalizations.of(this).localeName);

  static const String _swahiliCode = 'sw';
}

/// Mipangilio ya localization kwa `MaterialApp.router`.
///
/// `supportedLocales` inatoka kwenye [AppLanguage.supportedLocales] ili
/// kuwe na chanzo kimoja cha ukweli (single source of truth) — okoa kumbuka
/// kwamba [AppLanguage.bilingual] inatumia code `'sw'`, hivyo haiongezi locale
/// ya tatu.
abstract final class AppLocalizationsSetup {
  const AppLocalizationsSetup._();

  /// Lugha zinazotumika: Kiswahili (msingi) kisha Kiingereza.
  ///
  /// Ni `final`, SI `const`: [AppLanguage.supportedLocales] ni **getter**, na
  /// wito wa getter si constant expression — `static const` ingesababisha kosa
  /// la compile ("Const variables must be initialized with a constant value").
  /// Hivyo tunaendelea kutumia chanzo kimoja cha ukweli bila kunakili orodha.
  static final List<Locale> supportedLocales = AppLanguage.supportedLocales;

  /// Kama mtumiaji hana lugha tunayotumia, tumia Kiswahili — lugha ya msingi
  /// ya app (tazama `AppConstants.defaultLanguageCode`).
  static const Locale fallbackLocale = Locale('sw');

  /// Delegate zote muhimu. Kwa Kiswahili hakuna GlobalMaterialLocalizations
  /// rasmi, lakini kutumia delegate za Kiingereza ni salama: maandishi yetu
  /// yote yanatoka kwetu, delegates hizi zinahudia widgets za Flutter pekee
  /// (mfano "Cancel"/"OK" kwenye date picker).
  static List<LocalizationsDelegate<dynamic>> get localizationsDelegates =>
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];
}
