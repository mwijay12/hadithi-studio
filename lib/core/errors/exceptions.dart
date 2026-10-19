/// EXCEPTIONS — makosa ya kiufundi yanayotupwa na **data layer**
/// (datasources) kabla ya kubadilishwa kuwa [Failure] kwenye repositories.
///
/// Kanuni: datasource `throw`s, repository `catch`es na kurudisha
/// `Left(Failure)`. Presentation layer haioni exceptions kabisa.
library;

/// Base ya exceptions zote za data layer.
class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  /// Maelezo ya kiufundi (kwa logs — SI kwa UI).
  final String message;

  /// Code ya kipekee kwa ajili ya logs/analytics.
  final String? code;

  /// Kosa la awali lililosababisha hili (kwa debugging).
  final Object? cause;

  @override
  String toString() =>
      '$runtimeType(code: $code): $message${cause == null ? '' : ' ← $cause'}';
}

/// Seva imerudisha kosa (4xx/5xx).
class ServerException extends AppException {
  const ServerException(
    super.message, {
    this.statusCode,
    super.code,
    super.cause,
  });

  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Kifaa hakina mtandao au muunganisho umekatika.
/// TANBIHI: `message` ni **positional** (si `[positional]`) — Dart hairuhusu
/// parameter ya hiari ya positional pamoja na ya named kwenye orodha moja
/// (`([a], {b})` ni kosa la compile). Kwa hivyo ujumbe hulazimika kutolewa,
/// na `code`/`cause` hubaki za hiari kama named.
class NetworkException extends AppException {
  const NetworkException(
    String message, {
    String? code = 'NETWORK',
    Object? cause,
  }) : super(message, code: code, cause: cause);
}

/// Ombi lilichukua muda mrefu kuliko ilivyoruhusiwa.
class TimeoutException extends AppException {
  const TimeoutException(
    String message, {
    String? code = 'TIMEOUT',
    Object? cause,
  }) : super(message, code: code, cause: cause);
}

/// Cache/Hive imeshindwa kusoma au kuandika.
class CacheException extends AppException {
  const CacheException(
    String message, {
    String? code = 'CACHE',
    Object? cause,
  }) : super(message, code: code, cause: cause);
}

/// Secure storage (fluter_secure_storage) imeshindwa.
///
/// Kumbuka: kwenye Android ya zamani KeyStore inaweza kuharibika baada ya
/// kubadilisha PIN ya kifaa — hii hutokea Tanzania kwa sababu watumiaji
/// hubadilisha PIN mara nyingi.
class SecureStorageException extends AppException {
  const SecureStorageException(
    String message, {
    String? code = 'SECURE_STORAGE',
    Object? cause,
  }) : super(message, code: code, cause: cause);
}

/// Kosa la uthibitisho (401/403).
class AuthException extends AppException {
  const AuthException(
    super.message, {
    super.code = 'AUTH',
    super.cause,
  });
}

/// Hauna ruhusa (403) — mfano kikomo cha plan au amri ya mzazi.
///
/// Hii ni tofauti muhimu na [AuthException] (401): 401 inamaanisha "hujatambulika,
/// ingia tena" (kwa hivyo `AuthInterceptor` hujaribu kuhuisha token), wakati 403
/// inamaanisha "tunakujua, lakini hii haikuruhusiwi" — kurudia ombi hakuta
/// kubadilisha chochote. Kwa kuchanganya hizi mbili, app ingejaribu kuhuisha
/// token kila mtumiaji wa BURE alipofikia kikomo cha hadithi 3 kwa mwezi.
class PermissionException extends AppException {
  const PermissionException(
    super.message, {
    super.code = 'PERMISSION_DENIED',
    super.cause,
  });
}

/// Malipo yameshindwa au yamesitishwa.
class PaymentException extends AppException {
  const PaymentException(
    super.message, {
    this.providerCode,
    super.code = 'PAYMENT',
    super.cause,
  });

  /// 'vodacom' | 'tigo' | 'airtel' | 'halotel' | 'card'
  final String? providerCode;
}

/// AI generation imeshindwa (timeout, rate limit, moderation).
class AiGenerationException extends AppException {
  const AiGenerationException(
    super.message, {
    super.code = 'AI',
    super.cause,
  });
}

/// TTS synthesis imeshindwa.
class TtsException extends AppException {
  const TtsException(
    super.message, {
    super.code = 'TTS',
    super.cause,
  });
}

/// Taarifa haipo (404).
class NotFoundException extends AppException {
  const NotFoundException(
    String message, {
    String? code = 'NOT_FOUND',
    Object? cause,
  }) : super(message, code: code, cause: cause);
}

/// Taarifa zilizotumwa haziko sahihi (422).
class ValidationException extends AppException {
  const ValidationException(
    super.message, {
    this.fieldErrors,
    super.code = 'VALIDATION',
    super.cause,
  });

  /// Ramani ya `fieldName → ujumbe` kutoka seva.
  final Map<String, String>? fieldErrors;
}
