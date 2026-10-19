/// Ukamataji wa makosa ya app nzima (global error handling).
///
/// **Kwa nini faili hili lipo:** Tanzania ina simu nyingi za bei nafuu na
/// mtandao usio imara. Kosa moja lisilokamatwa **hufunga app nzima** —
/// mtoto anaona skrini nyeupe na hajui la kufanya. Kanuni ya 7 ya mradi
/// ("app ifanye kazi bila mtandao kwa neema") inahitaji pia "app isianguke
/// kwa neema".
///
/// ## Uamuzi: hatutumii Crashlytics bado — na hatujaribu kufanya hivyo kwa uongo
///
/// Prompt 7 inaomba `FirebaseCrashlytics.instance.recordFlutterFatalError`.
/// `firebase_core` ipo kwenye pubspec, lakini **hakuna project ya Firebase
/// wala `firebase_options.dart`**. Kuita `Firebase.initializeApp()` bila
/// options **huangusha app kwenye web na Android** — yaani kuongeza
/// crash-reporting kungeongeza crash. Hivyo msimbo huu hukamata na kurekodi
/// **ndani ya app**, tayari kwa [onRecord] kuunganishwa na Crashlytics siku
/// ambapo project itakuwepo.
///
/// ## Kwa nini hifadhi ya "hivi karibuni" na si logi pekee
///
/// `debugPrint` hupotea kwenye release build. Kwa kuweka rekodi 20 za mwisho
/// kwenye kumbukumbu, skrini ya kurejesha (`CrashRecoveryScreen`) inaweza
/// kuonyesha **kosa halisi** lililotokea — msaada wa kweli kwa mtumiaji
/// anayeripoti tatizo, na kwa sisi tunapopokea ripoti hiyo.
library;

import 'dart:collection';
import 'dart:ui' show PlatformDispatcher;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Aina ya kosa — hutumika kuchagua ujumbe kwa mtumiaji.
///
/// Hii ni **aina yetu**, si `DioExceptionType`. Kwa kuitenganisha, UI
/// haihitaji kujua kuhusu Dio kabisa, na tunaweza kuipima kwa urahisi.
enum AppErrorKind {
  /// Mtandao ni polepole (timeout).
  slowNetwork,

  /// Hakuna mtandao kabisa.
  noNetwork,

  /// Kipindi cha kuingia kimeisha (401).
  sessionExpired,

  /// Kitu hakipo (404).
  notFound,

  /// Seva ina tatizo (5xx).
  serverError,

  /// Kosa jingine lolote.
  unexpected,
}

/// Rekodi moja ya kosa.
@immutable
class AppErrorRecord {
  /// Huunda rekodi.
  const AppErrorRecord({
    required this.error,
    required this.at,
    required this.kind,
    this.stackTrace,
    this.isFatal = false,
  });

  /// Kosa lenyewe.
  final Object error;

  /// Rukwama ya mwito.
  final StackTrace? stackTrace;

  /// Wakati lilipotokea.
  final DateTime at;

  /// Aina iliyoainishwa.
  final AppErrorKind kind;

  /// `true` = kosa lililoua fremu ya kuonyesha.
  final bool isFatal;

  /// Maelezo mafupi kwa kuonyesha.
  String get summary => error.toString();
}

/// Hukamata, huainisha na kuhifadhi makosa ya app.
abstract final class AppErrorHandler {
  /// Idadi ya juu ya rekodi zinazohifadhiwa.
  static const int maxRecords = 20;

  /// Rekodi za hivi karibuni (mpya mwisho).
  static final Queue<AppErrorRecord> _records = Queue<AppErrorRecord>();

  /// Huitwa kila kosa linapokamatwa — mahali pa kuunganisha Crashlytics.
  ///
  /// Kwa sasa ni `null`. Siku ambapo `firebase_options.dart` itakuwepo:
  /// ```dart
  /// AppErrorHandler.onRecord = (AppErrorRecord r) =>
  ///     FirebaseCrashlytics.instance.recordError(
  ///       r.error, r.stackTrace, fatal: r.isFatal,
  ///     );
  /// ```
  static void Function(AppErrorRecord record)? onRecord;

  /// Idadi ya makosa **yote** yaliyorekodiwa — kwa uchunguzi pekee.
  ///
  /// **TANBIHI: usisikilize hii kuonyesha skrini ya kosa.** `FlutterError`
  /// huwaka kwa mambo yasiyoua app pia — overflow ya pikseli, asset
  /// isiyopatikana, au kosa la fremu moja. Kubadilisha **skrini nzima** kwa
  /// kosa la kupamba hufanya app ionekane **imevunjika zaidi**, sivyo kidogo.
  /// Hilo lilitokea kwa kweli: skrini ya pili ya onboarding ilionyesha skrini
  /// ya kosa kwa sababu ya kosa lisilozuia kitu.
  static final ValueNotifier<int> errorCount = ValueNotifier<int>(0);

  /// Idadi ya makosa **mabaya (fatal)** — haya ndiyo yanayoonyesha skrini ya
  /// kurejesha.
  ///
  /// `AppErrorBoundary` husikiliza hii. Fatal humaanisha: kosa la async
  /// lisilokamatwa (`PlatformDispatcher.onError`), ambapo hali ya app
  /// haijulikani na kuendelea kunaweza kuwa kudanganya. Kwa makosa ya fremu
  /// ambapo mti bado unafanya kazi, Flutter yenyewe huonyesha kosa la eneo
  /// hilo — sehemu nyingine za app zinaendelea kufanya kazi.
  static final ValueNotifier<int> fatalCount = ValueNotifier<int>(0);

  /// Rekodi zilizohifadhiwa (nakala huru — haiwezi kubadilishwa nje).
  static List<AppErrorRecord> get records =>
      List<AppErrorRecord>.unmodifiable(_records);

  /// Rekodi ya mwisho, kama ipo.
  static AppErrorRecord? get lastRecord =>
      _records.isEmpty ? null : _records.last;

  /// Hurekodi kosa.
  static void record(
    Object error,
    StackTrace? stackTrace, {
    bool isFatal = false,
  }) {
    final AppErrorRecord record = AppErrorRecord(
      error: error,
      stackTrace: stackTrace,
      at: DateTime.now(),
      kind: classify(error),
      isFatal: isFatal,
    );

    _records.addLast(record);
    // Kikomo cha kumbukumbu: simu za 2GB RAM hazipaswi kukumbuka kila kosa.
    while (_records.length > maxRecords) {
      _records.removeFirst();
    }

    // `debugPrint` hupotea kwenye release, lakini ni muhimu wakati wa
    // kuendeleza — hivyo tunarekodi kwa njia zote mbili.
    debugPrint('AppErrorHandler [${record.kind.name}] ${record.error}');
    if (stackTrace != null) debugPrint('$stackTrace');

    // Wanaosikiliza hawapaswi kuangusha app kwa kosa lao wenyewe.
    try {
      onRecord?.call(record);
      errorCount.value = errorCount.value + 1;
      // Ni makosa **mabaya** pekee yanayoonyesha skrini ya kurejesha.
      if (isFatal) fatalCount.value = fatalCount.value + 1;
    } catch (listenerError) {
      debugPrint('AppErrorHandler: msikilizaji ameshindwa — $listenerError');
    }
  }

  /// Huweka `FlutterError.onError` na `PlatformDispatcher.onError`.
  ///
  /// Huitwa **mara moja** kutoka `main.dart`, baada ya
  /// `WidgetsFlutterBinding.ensureInitialized()` (ambayo inahitajika kwa
  /// [PlatformDispatcher]).
  static void install() {
    // Makosa ya fremu ya kuonyesha (widget build, layout, paint).
    FlutterError.onError = (FlutterErrorDetails details) {
      record(details.exception, details.stack, isFatal: false);
      // Tunaendelea kuchapisha kwa console ya Flutter ili `flutter run`
      // ionyeshe kosa kwa ukamilifu wakati wa kuendeleza.
      FlutterError.presentError(details);
    };

    // Makosa ya async yasiyokamatwa (outside Flutter framework).
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      record(error, stack, isFatal: true);
      // `true` = tumeshughulikia; bila hii app ingeanguka.
      return true;
    };

    debugPrint('AppErrorHandler: imewekwa (records max: $maxRecords).');
  }

  /// Hufuta rekodi — baada ya mtumiaji kubofya "Anza Upya".
  static void clear() {
    _records.clear();
    errorCount.value = 0;
    fatalCount.value = 0;
  }

  /// Huainisha kosa ili UI ichague ujumbe unaofaa.
  static AppErrorKind classify(Object error) {
    if (error is! DioException) return AppErrorKind.unexpected;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      // Dio 5 ina `transformTimeout` (muda umeisha wakati wa kubadilisha
      // jibu). Ni timeout bado — kwa mtumiaji ni "mtandao ni polepole".
      case DioExceptionType.transformTimeout:
        return AppErrorKind.slowNetwork;

      case DioExceptionType.connectionError:
        return AppErrorKind.noNetwork;

      case DioExceptionType.badResponse:
        final int? status = error.response?.statusCode;
        if (status == 401 || status == 403) return AppErrorKind.sessionExpired;
        if (status == 404) return AppErrorKind.notFound;
        if (status != null && status >= 500) return AppErrorKind.serverError;
        return AppErrorKind.unexpected;

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return AppErrorKind.unexpected;
    }
  }
}
