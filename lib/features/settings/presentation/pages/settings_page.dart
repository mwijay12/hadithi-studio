/// **MIPANGILIO** — ukurasa mmoja wa mipangilio ya app.
///
/// ## Kwa nini ukurasa huu uliundwa
///
/// Chaguo la lugha lilikuwa lipo mahali pabaya: kwenye **onboarding** (ambapo
/// mtumiaji hajui app bado) na kwenye **kichwa cha Maktaba** kama vichujio
/// vitatu — ambapo mtumiaji alidhani ni kuchagua lugha, kumbe ni kuchuja
/// hadithi. Matokeo: mtu hacahuo la kubadilisha lugha **baadaye**.
///
/// Sasa:
/// * **Onboarding** ina chaguo **mawili** pekee (Kiswahili / Kiingereza).
/// * **Maktaba** haina chipu za lugha — ina kiungo cha "Badilisha" kinachofungua
///   ukurasa huu.
/// * Chaguo halisi la lugha kipo **hapa**, mahali panapotafutwa.
///
/// ## "Lugha Zote" imeondolewa kwenye UI
///
/// Mtumiaji aliomba hivyo: mtu achague **lugha moja** waziwazi. Hivyo
/// `AppLanguage.bilingual` **haiwezi kuchaguliwa** kwenye UI tena.
/// `BilingualText` na uonyeshaji wa lugha mbili (ukurasa wa maelezo, reader)
/// **zinabaki kwenye msimbo** kwa sababu zinapimwa na zinaweza kurudishwa —
/// lakini **hazifikiki** kwa sasa. Hii ni hali ya kujua, sivyo kosa.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/library_store.dart';
import '../../../../core/services/theme_controller.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/leo_mascot.dart';
import '../../../../l10n/app_locale_controller.dart';
import '../../../../l10n/l10n.dart';

/// Toleo la app.
///
/// Hutoka kwenye build (`--dart-define=APP_VERSION=1.0.0+1`). Kwa default ni
/// `dev` — **hatubuni namba ya toleo** ambayo haipo.
const String _appVersion =
    String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0-dev');

/// Jina la lugha kwa lugha inayotumika sasa kwenye UI.
///
/// `AppLanguage` haina `label(...)` — ina `labelSw` na `labelEn` pekee.
/// Tunachagua kwa mkono hapa, mahali pamoja.
String _languageLabel(AppLanguage language, {required bool swahili}) =>
    swahili ? language.labelSw : language.labelEn;

/// Ukurasa wa mipangilio.
class SettingsPage extends StatelessWidget {
  /// Huunda ukurasa.
  const SettingsPage({super.key});

  /// Lugha zinazochaguliwa kwenye UI: **mbili pekee**.
  ///
  /// `AppLanguage.bilingual` haipo kwa makusudi — tazama doc ya faili hili.
  static const List<AppLanguage> selectableLanguages = <AppLanguage>[
    AppLanguage.swahili,
    AppLanguage.english,
  ];

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    // `AppLocaleController` ni `ChangeNotifier`; `AnimatedBuilder`
    // hujenga upya sehemu ya lugha mara tu chaguo linabadilika.
    return AnimatedBuilder(
      animation: AppLocaleController.instance,
      builder: (BuildContext context, Widget? _) {
        return Scaffold(
          // **KOSA LILILOKUWA:** mandhari hii ilikuwa imewekwa kwa mkono
          // (`AppColors.background` = cream #FAFAF8) wakati `ListTile`
          // huchukua rangi ya maandishi KUTOKA theme. Kwenye dark mode,
          // `ListTile` hutoa #E6E6E6 (karibu nyeupe) -> **maandishi
          // yasiyoonekana juu ya cream**.
          //
          // Sasa tunatumia theme pekee: light mode inatoa cream ile ile
          // (hakuna mabadiliko ya kuonekana), na dark mode inatoa mandhari
          // nyeusi na maandishi yanayosomeka.
          // **Kwa nini tunaunganisha rangi:** AppBar ilichukua rangi ya
          // `appBarTheme` (cream #FAFAF8) wakati ukurasa ulikuwa mweupe
          // (#FFFFFF) — mstari wa rangi mbili ulionekana kama kosa.
          // Sasa zote mbili zinatumia rangi ile ile ya AppBar.
          backgroundColor: _surfaceOf(context),
          appBar: AppBar(
            backgroundColor: _surfaceOf(context),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(l10n.settings),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
              tooltip: context.isSwahili ? 'Rudi' : 'Back',
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
            children: <Widget>[
              // Leo anasoma — mipangilio ni mahali pa kutafakari, sivyo
              // shangwe. `reading` inafaa zaidi ya `celebrate`.
              const Center(
                child: LeoMascot(pose: LeoPose.reading, height: 150),
              ),

              // -------------------------------------------------------------
              // Muonekano — Nuru / Giza / Mfumo
              // -------------------------------------------------------------
              // **Kwa nini sehemu hii ipo:** mtumiaji aliripoti kwamba
              // hakukuwa na mahali pa kubadilisha muonekano; app ilifuata
              // simu pekee (`ThemeMode.system`). Sehemu hii inatoa chaguo
              // halisi, na `ThemeController` hulihifadhi.
              _SectionTitle(
                title: context.isSwahili ? 'Muonekano' : 'Appearance',
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  context.isSwahili
                      ? 'Chagua rangi za app. Chaguo lako huhifadhiwa.'
                      : 'Choose the app colours. Your choice is saved.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final AppThemeMode mode in AppThemeMode.values)
                ListTile(
                  onTap: () => ThemeController.instance.use(mode),
                  leading: Icon(mode.icon),
                  title: Text(context.isSwahili ? mode.labelSw : mode.labelEn),
                  trailing: ThemeController.instance.selection == mode
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),

              // -------------------------------------------------------------
              // Lugha
              // -------------------------------------------------------------
              _SectionTitle(title: l10n.appLanguage),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  l10n.chooseLanguageSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final AppLanguage language in selectableLanguages)
                _LanguageTile(
                  language: language,
                  selected:
                      AppLocaleController.instance.language == language,
                  onSelected: () {
                    AppLocaleController.instance.use(language);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n.languageChanged(
                              _languageLabel(
                                language,
                                swahili: language == AppLanguage.swahili,
                              ),
                            ),
                          ),
                          duration: AppSpacing.normal,
                        ),
                      );
                  },
                ),

              // -------------------------------------------------------------
              // Bado haipatikani — kwa uaminifu
              // -------------------------------------------------------------
              // -------------------------------------------------------------
              // Sera na arifa — zinazofanya kazi
              // -------------------------------------------------------------
              _SectionTitle(
                title: context.isSwahili ? 'Faragha na Arifa' : 'Privacy & Alerts',
              ),
              ListTile(
                onTap: () => context.pushNamed(AppRoutes.notificationSettingsName),
                leading: const Icon(Icons.notifications_active_rounded),
                title: Text(
                  context.isSwahili ? 'Mipangilio ya Arifa' : 'Notification Settings',
                ),
                subtitle: Text(
                  context.isSwahili
                      ? 'Chagua arifa unazotaka (zitafanya kazi baada ya backend)'
                      : 'Choose which alerts you want (active once the backend exists)',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),
              ListTile(
                onTap: () => context.pushNamed(AppRoutes.privacyPolicyName),
                leading: const Icon(Icons.privacy_tip_rounded),
                title: Text(
                  context.isSwahili ? 'Sera ya Faragha' : 'Privacy Policy',
                ),
                subtitle: Text(
                  context.isSwahili
                      ? 'Jinsi tunavyotunza taarifa zako'
                      : 'How we handle your information',
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
              ),

              // -------------------------------------------------------------
              // Bado haipatikani — kwa uaminifu
              // -------------------------------------------------------------
              _SectionTitle(title: l10n.notAvailableYet),
              for (final String label in <String>[
                context.isSwahili ? 'Hali ya Data Ndogo' : 'Low Data Mode',
                context.isSwahili ? 'Udhibiti wa Mzazi' : 'Parental Controls',
              ])
                ListTile(
                  enabled: false,
                  leading: Icon(
                    Icons.lock_outline_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(label),
                  subtitle: Text(
                    l10n.notAvailableYet,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  context.isSwahili
                      ? 'Vipengele hivi vinahitaji backend. Hazijaachwa kwa '
                          'makusudi — zinaonyeshwa kama zilivyo, ili '
                          'usidhani zinafanya kazi.'
                      : 'These features need a backend. They are shown as '
                          'they are so you do not assume they work.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // -------------------------------------------------------------
              // Kuhusu
              // -------------------------------------------------------------
              // -------------------------------------------------------------
              // Data yako — inafuta kila kitu kwenye kifaa
              // -------------------------------------------------------------
              // **Kwa nini sehemu hii ni lazima:** sera ya faragha inasema
              // mtumiaji anaweza kufuta data yake kwa "Safisha data" kwenye
              // Mipangilio. Kama kitufe hicho hakipo, sera inasema uongo.
              // Hivyo tunaweka kitendo halisi hapa.
              _SectionTitle(
                title: context.isSwahili ? 'Data yako' : 'Your data',
              ),
              ListTile(
                onTap: () => _confirmClearData(context),
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  context.isSwahili
                      ? 'Safisha data yote'
                      : 'Clear all data',
                ),
                subtitle: Text(
                  context.isSwahili
                      ? 'Maendeleo, alama, rasimu, jina la mtoto na '
                          'mapendeleo yatafutwa kabisa'
                      : 'Progress, bookmarks, drafts, child name and '
                          'preferences will be erased',
                ),
              ),

              _SectionTitle(title: l10n.aboutApp),
              ListTile(
                leading: Icon(
                  Icons.menu_book_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: const Text('Hadithi Studio'),
                subtitle: Text('${l10n.version} $_appVersion'),
              ),
              ListTile(
                leading: Icon(
                  Icons.public_rounded,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                title: Text(
                  context.isSwahili
                      ? 'Imetengenezwa Tanzania 🇹🇿'
                      : 'Made in Tanzania 🇹🇿',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Kichwa cha sehemu.
/// Huuliza uthibitisho kabla ya kufuta data yote.
///
/// **Kwa nini uthibitisho:** kitendo hiki hakiwezi kutenduliwa — hakuna
/// server na hakuna nakala. Kufuta kwa bahati moja kungeondoa hadithi za
/// mtoto zote.
Future<void> _confirmClearData(BuildContext context) async {
  final bool sw = context.isSwahili;
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => AlertDialog(
      title: Text(sw ? 'Safisha data yote?' : 'Clear all data?'),
      content: Text(
        sw
            ? 'Maendeleo ya kusoma, alama, rasimu, jina la mtoto na '
                'mapendeleo yatafutwa. Hili haliwezi kutenduliwa.'
            : 'Reading progress, bookmarks, drafts, child name and '
                'preferences will be erased. This cannot be undone.',
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(sw ? 'Acha' : 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(sw ? 'Futa' : 'Erase'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;
  await LibraryStore.instance.clearAll();
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(sw ? 'Data yote imefutwa.' : 'All data has been erased.'),
      ),
    );
}

/// Rangi ya uso inayotumika kwa ukurasa **na** AppBar yake.
///
/// Hutumia rangi ya `appBarTheme` kama ipo (ndiyo inayoonekana juu), na
/// `colorScheme.surface` kama haipo. Bila kuunganisha hizi, AppBar na
/// maudhui huwa na nyeupe mbili tofauti.
Color _surfaceOf(BuildContext context) {
  final ThemeData theme = Theme.of(context);
  return theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title,
        // Rangi hutoka theme — earthBrown juu ya mandhari nyeusi ni hafifu.
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

/// Chaguo moja la lugha.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onSelected,
  });

  final AppLanguage language;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final bool swahiliUi =
        AppLocaleController.instance.language == AppLanguage.swahili;

    return ListTile(
      onTap: onSelected,
      leading: Icon(
        selected
            ? Icons.radio_button_checked_rounded
            : Icons.radio_button_unchecked_rounded,
        // **Kosa lililogunduliwa kwa ukaguzi wa macho:** `AppColors
        // .safariGreen` (#2D5016) juu ya mandhari ya giza (#24272F) ni
        // **1.6:1** — alama ya lugha iliyochaguliwa haikuonekana kabisa.
        // `primary` ya theme inatoa rangi sahihi kwa kila mode.
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      title: Text(
        _languageLabel(language, swahili: swahiliUi),
        style: TextStyle(
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      // Jina la lugha **yenyewe** kwa lugha hiyo (Kiswahili / English) —
      // hivyo mtumiaji anayeona "English" haitaji kujua Kiswahili kuisoma.
      // Tunaonyesha jina, **sivyo** code ya ISO (`sw`/`en`) ambayo si ya
      // kumwambia mtumiaji kitu.
      subtitle: Text(
        _languageLabel(language, swahili: language == AppLanguage.swahili),
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
