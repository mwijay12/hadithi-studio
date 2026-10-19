import 'package:equatable/equatable.dart';

/// FAILURES — makosa yanayotumika kwenye domain layer.
///
/// Kanuni ya 6 ya project inasema: kila network call irudishe
/// `Either<Failure, Success>`. Kwa hivyo kila kitu kinachoweza kushindwa
/// kinawakilishwa na class inayorithi [Failure] — HATUTUMII exceptions
/// moja kwa moja kwenye presentation layer.
///
/// Kila failure ina jina kwa **Kiswahili na Kiingereza** ili UI iweze
/// kuonyesha ujumbe sahihi (kanuni ya 4) bila kutafsiri kwa mkono.
abstract class Failure extends Equatable {
  const Failure({
    required this.messageSw,
    required this.messageEn,
    this.code,
  });

  /// Ujumbe kwa Kiswahili — lugha ya msingi ya app.
  final String messageSw;

  /// Ujumbe kwa Kiingereza.
  final String messageEn;

  /// Code ya kiufundi (mfano 'AUTH_401') kwa logs na analytics.
  final String? code;

  /// Hurudisha ujumbe kulingana na lugha iliyochaguliwa.
  String message({required bool swahili}) => swahili ? messageSw : messageEn;

  @override
  List<Object?> get props => [messageSw, messageEn, code];
}

/// Kosa la mtandao — hakuna internet, timeout, DNS failure n.k.
///
/// Tanzania ina mtandao wa 2G/3G usioaminika, kwa hivyo failure hii
/// inatarajiwa mara nyingi na kila screen inapaswa kushughulikia kwa
/// upole (offline-first — kanuni ya 7).
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.messageSw = 'Hakuna mtandao. Angalia muunganisho wako.',
    super.messageEn = 'No internet connection. Check your network.',
    super.code = 'NETWORK_ERROR',
  });

  /// Kama kifaa kiko offline kabisa (haitofautiani na timeout).
  const NetworkFailure.offline({
    super.messageSw =
        'Uko nje ya mtandao. Unaweza kusoma hadithi zilizopakuliwa.',
    super.messageEn =
        'You are offline. You can still read downloaded stories.',
    super.code = 'OFFLINE',
  });
}

/// Kosa la seva (5xx) au jibu lisilotarajiwa.
class ServerFailure extends Failure {
  const ServerFailure({
    this.statusCode,
    super.messageSw = 'Seva ina tatizo. Tafadhali jaribu tena baadaye.',
    super.messageEn = 'Server error. Please try again later.',
    super.code = 'SERVER_ERROR',
  });

  final int? statusCode;

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Timeout — ombi lilichukua muda mrefu kuliko ilivyoruhusiwa.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.messageSw = 'Ombi lilichukua muda mrefu. Jaribu tena.',
    super.messageEn = 'The request timed out. Please try again.',
    super.code = 'TIMEOUT',
  });
}

/// Kosa la cache / Hive (kusoma au kuandika kushindwa).
class CacheFailure extends Failure {
  const CacheFailure({
    super.messageSw = 'Imeshindwa kusoma kumbukumbu ya kifaa.',
    super.messageEn = 'Could not read local storage.',
    super.code = 'CACHE_ERROR',
  });
}

/// Kosa la uthibitisho — token imeisha muda au si sahihi.
class AuthFailure extends Failure {
  const AuthFailure({
    super.messageSw = 'Kikao chako kimeisha. Tafadhali ingia tena.',
    super.messageEn = 'Your session expired. Please log in again.',
    super.code = 'AUTH_ERROR',
  });

  /// Nambari ya simu au OTP si sahihi.
  const AuthFailure.invalidCredentials({
    super.messageSw = 'Nambari ya simu au neno la siri si sahihi.',
    super.messageEn = 'Incorrect phone number or password.',
    super.code = 'AUTH_INVALID_CREDENTIALS',
  });

  /// OTP imeisha muda wake (dakika 10 kulingana na AppConstants).
  const AuthFailure.otpExpired({
    super.messageSw = 'Namba ya uthibitisho imeisha muda. Omba nyingine.',
    super.messageEn = 'Verification code expired. Request a new one.',
    super.code = 'AUTH_OTP_EXPIRED',
  });

  /// Nambari ya simu imekwisha sajiliwa.
  const AuthFailure.phoneAlreadyRegistered({
    super.messageSw = 'Nambari hii ya simu imesajiliwa. Ingia badala yake.',
    super.messageEn = 'This phone number is already registered. Log in instead.',
    super.code = 'AUTH_PHONE_TAKEN',
  });
}

/// Uthibitisho wa taarifa ulioshindwa (form validation).
class ValidationFailure extends Failure {
  const ValidationFailure({
    required String fieldSw,
    required String fieldEn,
    required String reasonSw,
    required String reasonEn,
    super.code = 'VALIDATION_ERROR',
  })  : _fieldSw = fieldSw,
        _fieldEn = fieldEn,
        _reasonSw = reasonSw,
        _reasonEn = reasonEn,
        super(
          messageSw: '$fieldSw: $reasonSw',
          messageEn: '$fieldEn: $reasonEn',
        );

  final String _fieldSw;
  final String _fieldEn;
  final String _reasonSw;
  final String _reasonEn;

  String get fieldSw => _fieldSw;
  String get fieldEn => _fieldEn;

  /// Sababu pekee, bila jina la sehemu mbele.
  ///
  /// `message` ina jina la sehemu (`'Nambari ya simu: iwe tarakimu 9'`) kwa
  /// sababu inaweza kuonekana **mbali** na sehemu — mfano kwenye snackbar au
  /// kwenye orodha ya makosa juu ya form. Lakini kwenye
  /// `TextFormField.errorText`, label ya sehemu tayari inaonekana juu ya
  /// sehemu hiyo, kwa hivyo kurudia jina ni kelele kwa mtumiaji.
  String get reasonSw => _reasonSw;
  String get reasonEn => _reasonEn;

  @override
  List<Object?> get props => [...super.props, _fieldSw, _reasonSw];
}

/// Kosa la malipo (M-Pesa, Tigo Pesa, Airtel Money, Halopesa, kadi).
class PaymentFailure extends Failure {
  const PaymentFailure({
    super.messageSw = 'Malipo hayakufanikiwa. Tafadhali jaribu tena.',
    super.messageEn = 'Payment failed. Please try again.',
    super.code = 'PAYMENT_ERROR',
  });

  /// Mtumiaji amesitisha malipo kwenye simu yake.
  const PaymentFailure.cancelled({
    super.messageSw =
        'Umesitisha malipo. Hakuna kiasi kilichokatwa kwenye akaunti yako.',
    super.messageEn = 'Payment cancelled. No amount was deducted.',
    super.code = 'PAYMENT_CANCELLED',
  });

  /// Salio halitoshi.
  const PaymentFailure.insufficientFunds({
    super.messageSw = 'Salio halitoshi. Weka fedha kisha ujaribu tena.',
    super.messageEn = 'Insufficient balance. Top up and try again.',
    super.code = 'PAYMENT_INSUFFICIENT_FUNDS',
  });

  /// Mtandao wa malipo haupatikani kwa muda.
  const PaymentFailure.providerUnavailable({
    super.messageSw = 'Huduma ya malipo haipatikani kwa sasa. Jaribu tena.',
    super.messageEn = 'Payment provider is unavailable. Try again shortly.',
    super.code = 'PAYMENT_PROVIDER_DOWN',
  });
}

/// Kosa la AI (kutengeneza maandishi au picha).
class AiGenerationFailure extends Failure {
  const AiGenerationFailure({
    super.messageSw = 'AI imeshindwa kutengeneza maudhui. Jaribu tena.',
    super.messageEn = 'AI could not generate content. Please try again.',
    super.code = 'AI_ERROR',
  });

  /// Mtumiaji amepitiliza kikomo cha generation kwa sasa.
  const AiGenerationFailure.rateLimited({
    super.messageSw =
        'Umepitiliza kikomo cha kutengeneza kwa sasa. Subiri dakika chache.',
    super.messageEn =
        'You have reached the generation limit. Wait a few minutes.',
    super.code = 'AI_RATE_LIMITED',
  });

  /// Maudhui yaliyotengenezwa yamekataliwa na moderation.
  const AiGenerationFailure.contentBlocked({
    super.messageSw = 'Maudhui haya hayawezi kutengenezwa. Badilisha ombi.',
    super.messageEn = 'This content cannot be generated. Change your prompt.',
    super.code = 'AI_CONTENT_BLOCKED',
  });
}

/// Kosa la TTS (kutoa sauti).
class TtsFailure extends Failure {
  const TtsFailure({
    super.messageSw = 'Sauti haipatikani kwa sasa. Unaweza kusoma mwenyewe.',
    super.messageEn = 'Voice is unavailable right now. You can read instead.',
    super.code = 'TTS_ERROR',
  });
}

/// Taarifa iliyoombwa haipo (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.messageSw = 'Hatukupata kile ulichokuwa unatafuta.',
    super.messageEn = 'We could not find what you were looking for.',
    super.code = 'NOT_FOUND',
  });
}

/// Mtumiaji hana ruhusa (401/403) — mfano kikomo cha plan.
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.messageSw = 'Hauna ruhusa ya kufanya hivi kwa sasa.',
    super.messageEn = 'You do not have permission to do this right now.',
    super.code = 'PERMISSION_DENIED',
  });

  /// Kikomo cha plan (mfano BURE ina hadithi 3 kwa mwezi).
  const PermissionFailure.planLimitReached({
    super.messageSw =
        'Umefikia kikomo cha plan yako. Pandisha daraja kuendelea.',
    super.messageEn = 'You have reached your plan limit. Upgrade to continue.',
    super.code = 'PLAN_LIMIT',
  });
}

/// Kosa lisilojulikana — fallback ya mwisho.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.messageSw = 'Hitilafu isiyotarajiwa imetokea. Jaribu tena.',
    super.messageEn = 'An unexpected error occurred. Please try again.',
    super.code = 'UNKNOWN',
  });
}
