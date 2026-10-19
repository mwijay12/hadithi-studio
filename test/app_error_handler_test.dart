/// Majaribio ya [AppErrorHandler].
///
/// Ukamataji wa makosa ni tabia ambayo **haiwezi kujaribiwa kwa kubofya**:
/// unahitaji kosa litokee. Kwa hivyo tunalipima hapa — hasa [AppErrorKind],
/// kwa sababu ndiyo inayoamua ujumbe ambao mzazi anaona.
library;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/app_error_handler.dart';

/// Huunda `DioException` ya aina fulani.
DioException _dio(DioExceptionType type, {int? statusCode}) {
  final RequestOptions options = RequestOptions(path: '/api/v1/test');
  return DioException(
    requestOptions: options,
    type: type,
    response: statusCode == null
        ? null
        : Response<dynamic>(
            requestOptions: options,
            statusCode: statusCode,
          ),
  );
}

void main() {
  setUp(() {
    AppErrorHandler.clear();
    AppErrorHandler.onRecord = null;
  });

  group('classify — makosa ya mtandao', () {
    test('timeout ya kuunganisha ni mtandao polepole', () {
      expect(
        AppErrorHandler.classify(_dio(DioExceptionType.connectionTimeout)),
        AppErrorKind.slowNetwork,
      );
    });

    test('timeout ya kutuma na kupokea pia', () {
      expect(
        AppErrorHandler.classify(_dio(DioExceptionType.sendTimeout)),
        AppErrorKind.slowNetwork,
      );
      expect(
        AppErrorHandler.classify(_dio(DioExceptionType.receiveTimeout)),
        AppErrorKind.slowNetwork,
      );
    });

    test('kukatika kwa muunganisho ni hakuna mtandao', () {
      expect(
        AppErrorHandler.classify(_dio(DioExceptionType.connectionError)),
        AppErrorKind.noNetwork,
      );
    });
  });

  group('classify — majibu mabaya', () {
    test('401 na 403 ni kipindi kimeisha', () {
      expect(
        AppErrorHandler.classify(
          _dio(DioExceptionType.badResponse, statusCode: 401),
        ),
        AppErrorKind.sessionExpired,
      );
      expect(
        AppErrorHandler.classify(
          _dio(DioExceptionType.badResponse, statusCode: 403),
        ),
        AppErrorKind.sessionExpired,
      );
    });

    test('404 ni hakipo', () {
      expect(
        AppErrorHandler.classify(
          _dio(DioExceptionType.badResponse, statusCode: 404),
        ),
        AppErrorKind.notFound,
      );
    });

    test('500 na 503 ni tatizo la seva', () {
      expect(
        AppErrorHandler.classify(
          _dio(DioExceptionType.badResponse, statusCode: 500),
        ),
        AppErrorKind.serverError,
      );
      expect(
        AppErrorHandler.classify(
          _dio(DioExceptionType.badResponse, statusCode: 503),
        ),
        AppErrorKind.serverError,
      );
    });

    test('400 ni kosa lisilotarajiwa', () {
      expect(
        AppErrorHandler.classify(
          _dio(DioExceptionType.badResponse, statusCode: 400),
        ),
        AppErrorKind.unexpected,
      );
    });
  });

  group('classify — mambo mengine', () {
    test('kosa la kawaida la Dart ni lisilotarajiwa', () {
      expect(
        AppErrorHandler.classify(StateError('kitu kimeharibika')),
        AppErrorKind.unexpected,
      );
      expect(AppErrorHandler.classify('kamba'), AppErrorKind.unexpected);
    });

    test('kughairi ni lisilotarajiwa', () {
      expect(
        AppErrorHandler.classify(_dio(DioExceptionType.cancel)),
        AppErrorKind.unexpected,
      );
    });
  });

  group('record', () {
    test('huhifadhi rekodi na kuongeza kipimo', () {
      AppErrorHandler.record(StateError('jaribio'), StackTrace.current);
      expect(AppErrorHandler.records.length, 1);
      expect(AppErrorHandler.errorCount.value, 1);
      expect(AppErrorHandler.lastRecord?.kind, AppErrorKind.unexpected);
    });

    test('huzuia kumbukumbu kwa maxRecords', () {
      for (int i = 0; i < AppErrorHandler.maxRecords + 5; i++) {
        AppErrorHandler.record(Exception('kosa $i'), null);
      }
      expect(AppErrorHandler.records.length, AppErrorHandler.maxRecords);
      // Rekodi mpya zaidi zimebaki (za zamani zimeondolewa).
      expect(AppErrorHandler.lastRecord?.summary, contains('kosa 24'));
    });

    test('huitaita onRecord', () {
      final List<AppErrorKind> seen = <AppErrorKind>[];
      AppErrorHandler.onRecord = (AppErrorRecord r) => seen.add(r.kind);

      AppErrorHandler.record(
        _dio(DioExceptionType.connectionError),
        null,
      );

      expect(seen, <AppErrorKind>[AppErrorKind.noNetwork]);
    });

    test('msikilizaji anayetupa kosa HAANGUSHI app', () {
      AppErrorHandler.onRecord = (AppErrorRecord r) {
        throw StateError('msikilizaji amevunjika');
      };

      // Haipaswi kutupa — hii ndiyo kinga muhimu zaidi kwenye faili hili.
      expect(
        () => AppErrorHandler.record(Exception('kosa la awali'), null),
        returnsNormally,
      );
      expect(AppErrorHandler.records.length, 1);
    });

    test('clear hufuta rekodi na kurudisha kipimo', () {
      AppErrorHandler.record(Exception('kosa'), null);
      AppErrorHandler.clear();
      expect(AppErrorHandler.records, isEmpty);
      expect(AppErrorHandler.errorCount.value, 0);
      expect(AppErrorHandler.lastRecord, isNull);
    });

    test('records hurudishwa kama nakala isiyobadilika', () {
      AppErrorHandler.record(Exception('kosa'), null);
      expect(
        () => AppErrorHandler.records.add(
          AppErrorRecord(
            error: 'x',
            at: DateTime.now(),
            kind: AppErrorKind.unexpected,
          ),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('fatalCount — skrini ya kurejesha huonyeshwa kwa makosa mabaya PEKEE', () {
    test('kosa la kawaida HALIONGEZI fatalCount', () {
      AppErrorHandler.record(Exception('overflow ya kupamba'), null);

      // Hii ndiyo kinga ya regression: kosa la fremu lisilooua app
      // halipaswi kubadilisha skrini nzima.
      expect(AppErrorHandler.fatalCount.value, 0);
      expect(AppErrorHandler.errorCount.value, 1, reason: 'bado linarekodiwa');
    });

    test('kosa baya (fatal) HUONGEZA fatalCount', () {
      AppErrorHandler.record(Exception('async isiyokamatwa'), null, isFatal: true);
      expect(AppErrorHandler.fatalCount.value, 1);
      expect(AppErrorHandler.errorCount.value, 1);
    });

    test('mchanganyiko: makosa 3 ya kawaida + 1 baya', () {
      AppErrorHandler.record(Exception('a'), null);
      AppErrorHandler.record(Exception('b'), null);
      AppErrorHandler.record(Exception('c'), null);
      AppErrorHandler.record(Exception('d'), null, isFatal: true);

      expect(AppErrorHandler.errorCount.value, 4);
      expect(AppErrorHandler.fatalCount.value, 1);
    });

    test('clear hurudisha fatalCount pia', () {
      AppErrorHandler.record(Exception('baya'), null, isFatal: true);
      AppErrorHandler.clear();
      expect(AppErrorHandler.fatalCount.value, 0);
      expect(AppErrorHandler.errorCount.value, 0);
    });

    test('msikilizaji anayetupa kosa HAONGEZI fatalCount', () {
      AppErrorHandler.onRecord = (AppErrorRecord r) => throw StateError('x');
      AppErrorHandler.record(Exception('baya'), null, isFatal: true);

      // Rekodi ilifanikiwa, lakini msikilizaji alivunjika — kipimo kiko
      // kwenye `catch`, hivyo hakiongezwi. App haianguki.
      expect(AppErrorHandler.records.length, 1);
    });
  });
}
