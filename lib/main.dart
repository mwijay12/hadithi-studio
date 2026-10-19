import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/services/app_error_handler.dart';
import 'core/services/library_store.dart';
import 'core/services/theme_controller.dart';
import 'l10n/app_locale_controller.dart';

/// Entry point ya Hadithi Studio.
///
/// Kila kitu kizito (storage, DI, Firebase) hufanyika kabla ya `runApp`
/// ili UI ianze na data tayari — muhimu kwa splash screen yenye haraka.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // App inalenga simu. Tablet inaruhusiwa kwa portrait na landscape.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  final logger = Logger(printer: PrettyPrinter(methodCount: 0));

  try {
    await di.init();
    logger.i('Hadithi Studio: DI imeanzishwa.');
  } catch (error, stackTrace) {
    // App haiwezi kufanya kazi bila DI — lakini tunarekodi kabla ya kurusha.
    logger.e('Imeshindwa kuanzisha DI', error: error, stackTrace: stackTrace);
    rethrow;
  }

  // Weka ukamataji wa makosa **kwanza**, kabla ya kazi nyingine yoyote.
  // Kosa la async au la fremu linalotokea wakati wa kuanzisha (mfano wakati
  // wa `di.init()`) litarekodiwa badala ya kufunga app kimya.
  AppErrorHandler.install();

  // Rejesha lugha aliyochagua mtumiaji KABLA ya `runApp`. Bila hii, UI
  // huanza Kiswahili (default) kisha inabadilika — na kwenye web kila
  // kupakia upya kulirudisha Kiswahili.
  await AppLocaleController.instance.restore();

  // Rejesha hifadhi ya mtumiaji (onboarding, fuata, alama, rasimu) KABLA ya
  // `runApp`. Bila hii, splash ingeamua "mtumiaji ni mpya" kabla hifadhi
  // kusomwa, na onboarding ilikuwa ikirudi kila kufungua app (C10).
  await LibraryStore.instance.restore();

  // Muonekano (Nuru/Giza/Mfumo) — kabla ya `runApp`, ili app ianze na rangi
  // sahihi badala ya kubadilika mbele ya macho.
  await ThemeController.instance.restore();

  runApp(const HadithiStudioApp());
}
