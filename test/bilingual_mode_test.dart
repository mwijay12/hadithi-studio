/// Majaribio ya hali ya **"Lugha Zote"** (true bilingual mode).
///
/// Hoja ya mtumiaji ilikuwa: *"nikiselect lugha ya english story ninazo ziwe
/// kwenye english… naona imekuwa in swahili"* — na kisha: *"Lugha Zote
/// haionyeshi lugha mbili pamoja"*.
///
/// Sababu: `AppLanguage.bilingual` ina code ya ISO `'sw'`. Kwa hivyo
/// `l10n.localeName == 'sw'` ni kweli kwa **Kiswahili pekee NA Zote** — hazikuweza
/// kutofautishwa, na "Lugha Zote" ilionekana kama Kiswahili.
///
/// Majaribio haya hulinda hilo lisirudi.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/enums/app_enums.dart';
import 'package:hadithi_studio/core/widgets/bilingual_text.dart';
import 'package:hadithi_studio/l10n/app_locale_controller.dart';
import 'package:hadithi_studio/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hupanga widget ya [BilingualText] ndani ya `MaterialApp` yenye l10n.
Future<void> _pump(
  WidgetTester tester, {
  required Locale locale,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: BilingualText(swahili: 'Simba mdogo', english: 'Little lion'),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Rudi kwenye hali ya kawaida kabla ya kila jaribio.
    AppLocaleController.instance.use(AppLanguage.swahili);
  });

  group('AppLocaleController.isBilingual', () {
    test('Kiswahili pekee si lugha mbili', () {
      AppLocaleController.instance.use(AppLanguage.swahili);
      expect(AppLocaleController.instance.isBilingual, isFalse);
    });

    test('Kiingereza pekee si lugha mbili', () {
      AppLocaleController.instance.use(AppLanguage.english);
      expect(AppLocaleController.instance.isBilingual, isFalse);
    });

    test('Lugha Zote NI lugha mbili', () {
      AppLocaleController.instance.use(AppLanguage.bilingual);
      expect(AppLocaleController.instance.isBilingual, isTrue);
    });

    test(
      'Lugha Zote na Kiswahili zinashiriki ISO code `sw` — '
      'ndiyo maana getter ilikuwa muhimu',
      () {
        AppLocaleController.instance.use(AppLanguage.bilingual);
        final Locale bilingual = AppLocaleController.instance.locale;

        AppLocaleController.instance.use(AppLanguage.swahili);
        final Locale swahiliOnly = AppLocaleController.instance.locale;

        // Hazitofautishwi kwa locale pekee…
        expect(bilingual.languageCode, swahiliOnly.languageCode);
        // …lakini [isBilingual] huzitofautisha.
        expect(AppLocaleController.instance.isBilingual, isFalse);
      },
    );
  });

  group('BilingualText huonyesha', () {
    testWidgets('Kiingereza pekee → Kiingereza pekee', (WidgetTester tester) async {
      AppLocaleController.instance.use(AppLanguage.english);
      await _pump(tester, locale: const Locale('en'));

      expect(find.text('Little lion'), findsOneWidget);
      expect(find.text('Simba mdogo'), findsNothing);
    });

    testWidgets('Kiswahili pekee → Kiswahili pekee', (WidgetTester tester) async {
      AppLocaleController.instance.use(AppLanguage.swahili);
      await _pump(tester, locale: const Locale('sw'));

      expect(find.text('Simba mdogo'), findsOneWidget);
      expect(find.text('Little lion'), findsNothing);
    });

    testWidgets(
      'Lugha Zote → lugha ZOTE MBILI (hii ndiyo ilikuwa haifanyiki)',
      (WidgetTester tester) async {
        AppLocaleController.instance.use(AppLanguage.bilingual);
        await _pump(tester, locale: const Locale('sw'));

        expect(find.text('Simba mdogo'), findsOneWidget);
        expect(
          find.text('Little lion'),
          findsOneWidget,
          reason: 'Lugha Zote lazima ionyeshe Kiingereza pia',
        );
      },
    );

    testWidgets('mstari hutenganisha lugha mbili', (WidgetTester tester) async {
      AppLocaleController.instance.use(AppLanguage.bilingual);
      await _pump(tester, locale: const Locale('sw'));

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('lugha moja haina mstari wa kutenganisha', (WidgetTester tester) async {
      AppLocaleController.instance.use(AppLanguage.swahili);
      await _pump(tester, locale: const Locale('sw'));

      expect(find.byType(Divider), findsNothing);
    });
  });
}
