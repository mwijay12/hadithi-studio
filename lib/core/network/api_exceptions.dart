/// API EXCEPTIONS — kutafsiri makosa ya Dio na majibu ya kosa ya seva kuwa
/// exceptions zetu zenyewe.
///
/// **Kwa nini faili hili lipo, na kwa nini si `core/errors/exceptions.dart`:**
/// faili la `core/errors/exceptions.dart` hufafanua **aina** za makosa
/// ([AppException], [ServerException], [AuthException] n.k.). Faili hili
/// halitengenezi aina mpya — linafanya kazi moja: kuchukua `DioException`
/// (au `Response` yenye status ya kosa) na **kuchagua aina sahihi** ya
/// exception yetu, pamoja na kusoma body ya kosa la seva.
///
/// Mtiririko kamili wa makosa kwenye project hii:
///
/// ```
/// Dio                    → DioException
/// ApiExceptionMapper     → AppException (faili hili)
/// datasource             → throw AppException
/// repository             → catch(e) → Left(ErrorHandler.map(e))
/// presentation (BLoC)    → Failure.message(swahili: ...)
/// ```
///
/// Kwa hivyo [ErrorHandler] **haitumii** faili hili; `DioException` haipiti
/// mbali na hapa. Hii inahakikisha kwamba ujumbe wa seva (mfano `fieldErrors`
/// za 422) haupotei kabla ya kufika kwenye repository.
library;

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../config/constants/api_constants.dart';
import '../errors/exceptions.dart';

/// Jibu la kosa la seva baada ya kusomwa (imefafanuliwa hapa chini).
class ApiErrorBody {
  const ApiErrorBody({
    this.message,
    this.code,
    this.fieldErrors,
    this.raw,
  });

  /// Ujumbe uliotumwa na seva (kwa logs — SI kwa UI moja kwa moja).
  final String? message;

  /// Code ya kosa la seva (mfano `PLAN_LIMIT`, `OTP_EXPIRED`).
  final String? code;

  /// Makosa ya kila sehemu (field) — hutumika kwenye fomu (422).
  final Map<String, String>? fieldErrors;

  /// Body ghafi (kwa debugging).
  final Object? raw;
}

/// Huchagua na huunda exception sahihi kwa kila kosa la mtandao.
///
/// Hapa ndipo mantiki ya "status code ipi ni kosa gani" inaishi, mahali pamoja.
/// Kila datasource inaita [fromDioException] badala ya kuandika `if (e.type == ...)`
/// yake yenyewe.
abstract final class ApiExceptionMapper {
  /// Key ya `Response.requestOptions.extra` inayohifadhi status code ya HTTP
  /// tuliyotumwa na seva (Dio huweka hii kwenye `message` pekee, ambayo ni
  /// ngumu kusoma kwa mashine).
  static const String statusCodeExtraKey = 'http_status_code';

  /// Hubadilisha `DioException` kuwa [AppException] sahihi.
  ///
  /// Hii ni njia kuu inayotumiwa na [ApiClient]. Kila tawi linaeleza kwa nini
  /// linaenda kwenye aina hiyo ya exception.
  static AppException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return TimeoutException(
          'Seva haikujibu kwa muda ulioruhusiwa (connectTimeout).',
          cause: error,
        );

      case DioExceptionType.sendTimeout:
        return TimeoutException(
          'Kutuma data kulichukua muda mrefu kuliko ilivyoruhusiwa.',
          cause: error,
        );

      // `transformTimeout` (dio 5.x) ni timeout ya kusindika jibu — aina ile
      // ile ya kosa kwa mtumiaji: muda ulioisha, jaribu tena.
      case DioExceptionType.transformTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Kupokea jibu kulichukua muda mrefu kuliko ilivyoruhusiwa.',
          cause: error,
        );

      case DioExceptionType.connectionError:
        // Kifaa kiko offline, DNS imeshindwa, au data bundle imeisha —
        // yote haya ni "hakuna mtandao" kwa mtumiaji wa Tanzania.
        return NetworkException(
          'Imeshindwa kuunganisha na seva. Angalia muunganisho wako.',
          cause: error,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'Cheti cha TLS hakikuweza kuthibitishwa.',
          code: 'BAD_CERTIFICATE',
          cause: error,
        );

      case DioExceptionType.cancel:
        // Mtumiaji ameacha kusoma au amefunga ukurasa — SI kosa la kweli,
        // lakini bado ni `AppException` ili repositories zisilazimike
        // kutofautisha `null` na kosa.
        return NetworkException(
          'Ombi lilisitishwa kabla ya kukamilika.',
          code: 'REQUEST_CANCELLED',
          cause: error,
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        if (response == null) {
          return ServerException(
            'Seva imerudisha kosa bila maelezo.',
            cause: error,
          );
        }
        return fromResponse(response, cause: error);

      case DioExceptionType.unknown:
        // 'unknown' mara nyingi hufunika `SocketException` iliyofungwa
        // ndani ya Dio (`error.error`).
        if (error.message?.contains('SocketException') ?? false) {
          return NetworkException(
            'Muunganisho wa mtandao umekatika.',
            cause: error,
          );
        }
        return ServerException(
          error.message ?? 'Kosa lisilojulikana la mtandao.',
          cause: error,
        );
    }
  }

  /// Hubadilisha `Response` yenye status ya kosa kuwa [AppException] sahihi.
  ///
  /// Status code huamua aina ya exception, na body ya seva hutoa ujumbe,
  /// `code` na makosa ya kila sehemu (field).
  static AppException fromResponse(
    Response<dynamic> response, {
    Object? cause,
  }) {
    final status = response.statusCode;
    final body = parseErrorBody(response.data);

    // Ujumbe wa seva unachukua kipaumbele: seva inajua tatizo halisi zaidi
    // kuliko ujumbe wa jumla wa app (mfano "Salio lako halitoshi").
    final message = body?.message;

    switch (status) {
      case ApiConstants.statusBadRequest:
      case ApiConstants.statusUnprocessableEntity:
        return ValidationException(
          message ?? 'Taarifa zilizotumwa haziko sahihi.',
          fieldErrors: body?.fieldErrors,
          code: body?.code,
          cause: cause,
        );

      case ApiConstants.statusUnauthorized:
        return AuthException(
          message ?? 'Kikao kimeisha muda wake.',
          code: body?.code ?? 'AUTH_401',
          cause: cause,
        );

      case ApiConstants.statusForbidden:
        return PermissionException(
          message ?? 'Hauna ruhusa ya kufanya hivi.',
          code: body?.code ?? 'PERMISSION_DENIED',
          cause: cause,
        );

      case ApiConstants.statusNotFound:
        return NotFoundException(
          message ?? 'Taarifa iliyoombwa haipo.',
          code: body?.code,
          cause: cause,
        );

      case ApiConstants.statusConflict:
        return ServerException(
          message ?? 'Taarifa imekwisha kuwepo.',
          statusCode: status,
          code: body?.code ?? 'CONFLICT',
          cause: cause,
        );

      case ApiConstants.statusTooManyRequests:
        // TANBIHI: 429 hutokea kwa AI generation zaidi ya kila siku, lakini
        // pia kwa jumla ya requests. Hatuirudishi `AiGenerationException`
        // hapa kwa sababu faili hili halijui feature iliyoomba — repository
        // ya creator ndiyo inayoweza kuibadilisha kuwa
        // `AiGenerationFailure.rateLimited` kwa ujumbe maalum.
        return ServerException(
          message ?? 'Maombi ni mengi mno kwa sasa. Subiri kidogo.',
          statusCode: status,
          code: body?.code ?? 'RATE_LIMITED',
          cause: cause,
        );

      case ApiConstants.statusInternalServerError:
      case ApiConstants.statusBadGateway:
      case ApiConstants.statusServiceUnavailable:
        return ServerException(
          message ?? 'Seva ina tatizo la muda. Tafadhali jaribu tena.',
          statusCode: status,
          code: body?.code,
          cause: cause,
        );

      default:
        return ServerException(
          message ?? 'Kosa la seva (${status ?? 'n/a'}).',
          statusCode: status,
          code: body?.code,
          cause: cause,
        );
    }
  }

  /// Husoma body ya kosa la seva bila kutupa kosa jingine.
  ///
  /// Seva haitumii kila wakati JSON: kwenye 502/504 ya proxy ya Cloudflare
  /// body huwa **HTML**, na kwenye 413 huwa tupu. Kwa hivyo kila hatua
  /// inalindwa — kosa la kusoma body yenyewe lisifunike kosa la msingi.
  static ApiErrorBody? parseErrorBody(Object? data) {
    if (data == null) return null;

    var decoded = data;

    // Kama Dio haikupata `Content-Type: application/json`, body inabaki
    // kama `String` — tunaijaribu kwa mkono.
    if (decoded is String) {
      final trimmed = decoded.trim();
      if (trimmed.isEmpty || !trimmed.startsWith('{')) return null;
      try {
        decoded = jsonDecode(trimmed);
      } on FormatException {
        return null;
      }
    }

    if (decoded is! Map) return null;

    final map = decoded.map((key, value) => MapEntry('$key', value));

    return ApiErrorBody(
      message: _firstString(map, const ['message', 'messageSw', 'error']),
      code: _firstString(map, const ['code', 'errorCode', 'error_code']),
      fieldErrors: _parseFieldErrors(map['errors'] ?? map['fieldErrors']),
      raw: data,
    );
  }

  /// Kama ombi linaweza kurudiwa (retry) bila hatari.
  ///
  /// Hii haijibu "je, ni salama kurudia ombi hili?" — hilo ni jukumu la
  /// `RetryInterceptor` (linalojua method ya ombi). Hapa tunajibu "je,
  /// kosa hili linaweza kuponywa kwa kurudia?".
  static bool isRetryableType(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        // 5xx na 429 ni za muda. 4xx nyingine haziponywi kwa kurudia —
        // ombi hilo hilo litarudi kosa hilo hilo.
        return status == ApiConstants.statusTooManyRequests ||
            status == ApiConstants.statusInternalServerError ||
            status == ApiConstants.statusBadGateway ||
            status == ApiConstants.statusServiceUnavailable;

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  /// Kama kosa ni "token imeisha muda" — hivyo tunaweza kujaribu kuihuisha.
  static bool isUnauthorized(DioException error) =>
      error.response?.statusCode == ApiConstants.statusUnauthorized;

  // ---------------------------------------------------------------------------
  // Helpers za ndani
  // ---------------------------------------------------------------------------

  /// Hurudisha string ya kwanza isiyo tupu kati ya funguo zilizoorodheshwa.
  static String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  /// Husoma `errors` kuwa ramani ya `field → ujumbe mmoja`.
  ///
  /// Seva zinatuma makosa ya fomu kwa miundo miwili: `{"phone": ["kosa"]}`
  /// (Laravel/Express-validator) na `{"phone": "kosa"}`. Fomu yetu ina nafasi
  /// ya mstari mmoja kwa kila sehemu, hivyo tunachukua kosa la **kwanza**
  /// na kurudisha mengine kwenye ujumbe wa jumla? Hapana — tunachukua la
  /// kwanza tu, kwa sababu mstari wa chini ya sehemu hauwezi kuonyesha mawili
  /// vizuri, na kosa la kwanza ndilo la muhimu zaidi kwa mtumiaji.
  static Map<String, String>? _parseFieldErrors(Object? raw) {
    if (raw is! Map) return null;

    final result = <String, String>{};
    raw.forEach((key, value) {
      final field = '$key';
      if (value is String && value.trim().isNotEmpty) {
        result[field] = value.trim();
        return;
      }
      if (value is List && value.isNotEmpty) {
        final first = value.first;
        if (first is String && first.trim().isNotEmpty) {
          result[field] = first.trim();
        }
      }
    });

    return result.isEmpty ? null : result;
  }
}
