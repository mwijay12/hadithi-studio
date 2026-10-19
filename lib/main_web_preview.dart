/// Entrypoint ya **preview ya web** — si entrypoint ya app halisi.
///
/// **Kwa nini faili hili lipo:**
///
/// 1. App halisi inafuata `lib/main.dart`, ambayo huanzisha DI. DI huchukua
///    `LocalStorage` (Hive), `CacheManager` (`path_provider`) na
///    `SecureStorage` (`flutter_secure_storage`). `CacheManager` ina
///    `import 'dart:io'` — na `dart:io` **haipo** kwenye web. Kwa hivyo
///    kujenga web kutoka `main.dart` kunashindwa kukusanya (compile).
///
/// 2. Vilevile `lib/core/widgets/cached_image.dart` ina `dart:io`, na
///    `custom_button.dart` / `error_widget.dart` / `empty_state_widget.dart`
///    zote zinaitumia. Skrini za preview hapa zinaepuka mnyororo huo —
///    zinatia rangi na typography halisi lakini zinatumia widgets za
///    Material pekee.
///
/// **Matokeo:** preview hii inaonyesha **muundo halisi** (rangi za Tanzania,
/// typography, nafasi, Kiswahili halisi kutoka ARB) — si app kamili yenye
/// data. Hifadhi, malipo na AI hazipo bado.
///
/// Amri ya kujenga:
/// `flutter build web -t lib/main_web_preview.dart --release`
///
/// TODO: faili hili linaweza kufutwa pindi web itakuwa lengo rasmi la
/// bidhaa (itahitaji conditional imports `if (dart.library.html)` kwenye
/// `cache_manager.dart` na `cached_image.dart`).
library;

import 'package:flutter/material.dart';

import 'app.dart';
import 'config/routes/app_routes.dart';
import 'core/services/app_error_handler.dart';
import 'l10n/app_locale_controller.dart';

Future<void> main() async {
  // `WidgetsFlutterBinding` inahitajika kwa `runApp` kwenye web, na
  // inatupa uwezo wa kubadilisha `SystemChrome` hapa baadaye. Vilevile
  // inahitajika kabla ya `SharedPreferences` (inatumia plugin channel).
  WidgetsFlutterBinding.ensureInitialized();

  // Ukamataji wa makosa — kwanza kabisa.
  AppErrorHandler.install();

  // Rejesha lugha aliyochagua mtumiaji KABLA ya `runApp`.
  //
  // Hili ni muhimu zaidi kwenye web kuliko kwenye simu: kila "refresh"
  // huendesha Dart VM upya, na `AppLocaleController` ilianza upya na
  // Kiswahili — ndiyo maana mtumiaji alichagua Kiingereza lakini
  // hadithi zilirudi Kiswahili.
  await AppLocaleController.instance.restore();

  // Tunaanza kwenye splash ili mtiririko kamili uonekane: splash →
  // onboarding → shell yenye tabu tano. Badilisha hadi
  // `AppRoutes.home` ili kuruka moja kwa moja kwenye tabu.
  runApp(const HadithiStudioApp(initialLocation: AppRoutes.splash));
}
