import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import 'exceptions.dart';
import 'failures.dart';

/// ERROR HANDLER — kubadilisha exceptions za data layer kuwa [Failure]
/// zinazoeleweka kwenye domain/presentation layer.
///
/// Mahali pamoja pa kubadilisha makosa, ili kila repository isirudie
/// `try/catch` ndefu (DRY). Repositories huita:
///
/// ```dart
/// try {
///   final remote = await datasource.getStories();
///   return Right(remote.map((m) => m.toEntity()).toList());
/// } catch (e, s) {
///   return Left(ErrorHandler.map(e, stackTrace: s));
/// }
/// ```
abstract final class ErrorHandler {
  static final Logger _logger = Logger();

  /// Hubadilisha kosa lolote kuwa [Failure].
  ///
  /// Hushughulikia: DioException (network + HTTP), SocketException,
  /// TimeoutException, exceptions zetu za data layer, na kila kitu
  /// kingine (fallback = [UnknownFailure]).
  static Failure map(Object error, {StackTrace? stackTrace}) {
    // 1) Exceptions zetu wenyewe.
    if (error is AppException) return _fromAppException(error);

    // 2) Makosa ya Dio (HTTP client).
    if (error is DioException) return _fromDioException(error);

    // 3) Makosa ya socket (kifaa hakina mtandao).
    if (error is SocketException) {
      _log(error, stackTrace);
      return const NetworkFailure();
    }

    // 4) Timeout ya Dart (ndani ya dart:async).
    if (error is TimeoutException) {
      _log(error, stackTrace);
      return const TimeoutFailure();
    }

    // 5) FormatException — mara nyingi JSON mbovu kutoka seva.
    if (error is FormatException) {
      _log(error, stackTrace);
      return const ServerFailure(
        messageSw: 'Seva imerudisha jibu lisilo sahihi.',
        messageEn: 'The server returned an invalid response.',
        code: 'BAD_RESPONSE',
      );
    }

    // 6) Fallback.
    _log(error, stackTrace);
    return const UnknownFailure();
  }

  static Failure _fromAppException(AppException e) {
    if (e is NetworkException) return const NetworkFailure();
    if (e is TimeoutException) return const TimeoutFailure();
    if (e is CacheException) return const CacheFailure();
    if (e is SecureStorageException) {
      return const CacheFailure(
        messageSw: 'Imeshindwa kufikia kumbukumbu salama ya kifaa.',
        messageEn: 'Could not access secure storage on this device.',
        code: 'SECURE_STORAGE',
      );
    }
    if (e is AuthException) return const AuthFailure();
    if (e is PermissionException) return const PermissionFailure();
    if (e is PaymentException) {
      return PaymentFailure(
        messageSw: 'Malipo hayakufanikiwa. Tafadhali jaribu tena.',
        messageEn: 'Payment failed. Please try again.',
        code: e.code,
      );
    }
    if (e is AiGenerationException) return const AiGenerationFailure();
    if (e is TtsException) return const TtsFailure();
    if (e is NotFoundException) return const NotFoundFailure();
    if (e is ValidationException) {
      // `Failure` ni abstract — haipatii ujumbe wake yenyewe. `ValidationFailure`
      // ndiyo aina inayowakilisha kosa la uhalali, na hujenga ujumbe wake kwa
      // muundo "Sehemu: sababu" kutoka sehemu na sababu.
      return ValidationFailure(
        fieldSw: 'Taarifa',
        fieldEn: 'Information',
        reasonSw: 'ulizoweka haziko sahihi',
        reasonEn: 'you entered is invalid',
        code: e.code,
      );
    }
    if (e is ServerException) {
      return ServerFailure(statusCode: e.statusCode, code: e.code);
    }
    return const UnknownFailure();
  }

  static Failure _fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      // `transformTimeout` ni timeout ya kusindika jibu (dio 5.x). Ni aina ya
      // muda ulioisha — humfufua mtumiaji kwa "jaribu tena", si kwa "mtandao
      // haupo" (ambayo ingemfanya aangalie SIM kwa bure).
      case DioExceptionType.transformTimeout:
        return const TimeoutFailure();
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        // 'unknown' mara nyingi ni SocketException iliyofungwa ndani.
        if (e.error is SocketException) return const NetworkFailure();
        return const NetworkFailure();
      case DioExceptionType.cancel:
        return const NetworkFailure(
          messageSw: 'Ombi lilisitishwa.',
          messageEn: 'The request was cancelled.',
          code: 'REQUEST_CANCELLED',
        );
      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          messageSw: 'Muunganisho salama haukuweza kuthibitishwa.',
          messageEn: 'Could not verify the secure connection.',
          code: 'BAD_CERTIFICATE',
        );
      case DioExceptionType.badResponse:
        return _fromStatusCode(e.response?.statusCode);
    }
  }

  /// Hubadilisha HTTP status code kuwa [Failure] maalum.
  static Failure _fromStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
      case 422:
        return const ValidationFailure(
          fieldSw: 'Taarifa',
          fieldEn: 'Input',
          reasonSw: 'haziko sahihi',
          reasonEn: 'is invalid',
          code: 'BAD_REQUEST',
        );
      case 401:
        return const AuthFailure();
      case 403:
        return const PermissionFailure();
      case 404:
        return const NotFoundFailure();
      case 429:
        return const AiGenerationFailure(
          messageSw: 'Maombi ni mengi mno. Subiri kidogo kisha ujaribu tena.',
          messageEn: 'Too many requests. Wait a moment and try again.',
          code: 'RATE_LIMITED',
        );
      case 500:
      case 502:
      case 503:
        return ServerFailure(statusCode: statusCode);
      default:
        return ServerFailure(statusCode: statusCode);
    }
  }

  /// Huandika kosa kwenye logs — **bila taarifa nyeti** (kanuni ya 11:
  /// nambari za simu na tokens hazipaswi kuonekana kwenye logs).
  static void _log(Object error, StackTrace? stackTrace) {
    if (error is AppException) {
      _logger.e(
        'Kosa la data layer [${error.code ?? 'n/a'}]',
        error: error.message,
        stackTrace: stackTrace,
      );
      return;
    }
    _logger.e('Kosa lisilotarajiwa', error: error, stackTrace: stackTrace);
  }
}
