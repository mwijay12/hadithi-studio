/// API INTERCEPTORS — safu zinazopita kila ombi la mtandao.
///
/// Kila interceptor inafanya kazi **moja**, ili kufuatilia kosa iwe rahisi:
///
/// | Interceptor              | Kazi                                              |
/// |--------------------------|---------------------------------------------------|
/// | [HeadersInterceptor]     | `Accept-Language`, `X-App-Version`, `X-Platform`, `X-Device-Id` |
/// | [AuthInterceptor]        | Kuweka `Bearer` token na kuhuisha (refresh) 401     |
/// | [RetryInterceptor]       | Kurudia ombi lililoshindwa kwa sababu ya muda        |
/// | [LoggingInterceptor]     | Kumbukumbu za requests (dev/staging pekee)          |
///
/// **Mpangilio ni muhimu.** Dio huendesha interceptors kwa mpangilio
/// waliyoongezwa, kwa hivyo `AuthInterceptor` **lazima** iwe kabla ya
/// `RetryInterceptor`: ombi lililorudiwa linahitaji kuwa na token mpya tayari.
///
/// **Kwa nini abstractions mbili ([RequestContext] na [AuthTokenProvider])
/// zipo hapa badala ya kutegemea `core/storage` moja kwa moja:** safu ya
/// `core/network` haipaswi kujua `FlutterSecureStorage` wala `SharedPreferences`
/// hutumika wapi. Kushikamana na mkataba (interface) hutuacha kubadilisha
/// hifadhi (mfano kuhamia Keychain tofauti) bila kugusa network layer, na
/// kunaturuhusu kuweka fakes kwenye tests.
library;

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../config/app_config.dart';
import '../../config/constants/api_constants.dart';
import '../../config/constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../utils/phone_utils.dart';
import 'api_exceptions.dart';

/// Context ya kifaa na lugha inayohitajika kwenye kila ombi.
abstract class RequestContext {
  /// Kitambulisho cha kifaa (UUID) — hutumwa kwa `X-Device-Id`.
  ///
  /// Huhitajika kwa: kuzuia matumizi mabaya ya OTP, usalama wa kikao, na
  /// analytics ya vifaa. **Haijaiwi na taarifa binafsi** — ni UUID tu.
  Future<String> deviceId();

  /// Code ya lugha inayotumika sasa (`sw` au `en`).
  ///
  /// Hutumwa kwa `Accept-Language` ili seva irudishe ujumbe na maudhui kwa
  /// lugha aliyochagua mtumiaji — muhimu kwa app yenye lugha mbili.
  String languageCode();
}

/// Mkataba wa token za uthibitisho.
abstract class AuthTokenProvider {
  /// Access token ya sasa, au `null` kama mtumiaji hajaingia.
  Future<String?> accessToken();

  /// Hujaribu kuhuisha access token kwa `refreshToken`.
  ///
  /// Hurudisha token mpya ikifanikiwa, au `null` kama refresh imeshindwa
  /// (refresh token yenyewe imeisha muda au imefutwa).
  Future<String?> refreshAccessToken();

  /// Huitwa wakati refresh imeshindwa — app inapaswa kuondoa kikao na
  /// kumwonyesha mtumiaji skrini ya kuingia.
  Future<void> onUnauthorized();
}

// ---------------------------------------------------------------------------
// Headers
// ---------------------------------------------------------------------------

/// Huongeza headers za kawaida kwenye kila ombi.
///
/// Hizi hazibadiliki kwa mtumiaji mmoja, lakini ni muhimu: bila `X-Platform`
/// na `X-App-Version` seva haiwezi kujua ni app ya toleo gani inaomba, na
/// hatuwezi kuzuia matoleo ya zamani yenye hitilafu zinazojulikana.
class HeadersInterceptor extends Interceptor {
  HeadersInterceptor(this._context);

  final RequestContext _context;

  /// Key ya `extra` inayozuia kuongezwa `Accept-Language` (mfano kwa ombi
  /// linalopakua faili tuli ambalo halina maudhui ya lugha).
  static const String skipLanguageExtraKey = 'skip_language_header';

  // TANBIHI: Dio hufafanua `onRequest` kama `void` (SI `Future<void>`).
  // Hivyo tunaandika `void ... async` — hii ni `async void`, na ndiyo njia
  // inayoshauriwa na Dio kwa interceptors zinazohitaji `await`.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers[ApiConstants.headerAccept] = ApiConstants.contentTypeJson;
    options.headers[ApiConstants.headerAppVersion] = AppConfig.buildNumber;
    options.headers[ApiConstants.headerPlatform] = AppConfig.platform;
    options.headers[ApiConstants.headerClient] = AppConfig.clientIdentifier;

    if (options.extra[skipLanguageExtraKey] != true) {
      options.headers[ApiConstants.headerAcceptLanguage] =
          _context.languageCode();
    }

    // `X-Device-Id` huhitaji storage, hivyo inaweza kushindwa (KeyStore
    // iliyoharibika). Kushindwa kwake **hakuachi** ombi lisiende — ombi
    // lenyewe linaweza kufanikiwa bila header hii.
    try {
      final deviceId = await _context.deviceId();
      if (deviceId.isNotEmpty) {
        options.headers[ApiConstants.headerDeviceId] = deviceId;
      }
    } on AppException {
      // Tunaendelea bila header — tazama maelezo hapo juu.
    }

    handler.next(options);
  }
}

// ---------------------------------------------------------------------------
// Auth
// ---------------------------------------------------------------------------

/// Huweka `Bearer` token na kuhuisha kiotomatiki ombi lililokataliwa (401).
///
/// **Kwa nini `QueuedInterceptorsWrapper` na si `Interceptor`:** Dio
/// huendesha `QueuedInterceptorsWrapper` kwa **foleni** — ombi la pili
/// halianza `onError` yake mpaka la kwanza limemaliza. Hii ni muhimu sana
/// hapa: tukiruhusu mahitaji mawili kuhuisha token kwa wakati mmoja, tungepata
/// refresh mbili zinazoshindana, na moja ingefuta nyingine kwenye seva
/// (refresh token rotation) — matokeo: mtumiaji anafukuzwa bila sababu.
class AuthInterceptor extends QueuedInterceptorsWrapper {
  AuthInterceptor({required Dio dio, required AuthTokenProvider tokenProvider})
      : _dio = dio,
        _tokenProvider = tokenProvider;

  final Dio _dio;
  final AuthTokenProvider _tokenProvider;

  /// Key ya `extra` ya kuweka alama kwamba ombi hili limesharudiwa mara moja.
  ///
  /// Bila hii, 401 kwenye ombi lililorudiwa ingeanzisha refresh nyingine,
  /// na hivyo mzunguko usioisha wa 401 → refresh → 401 → ...
  static const String _retriedExtraKey = 'auth_retried';

  /// Weka `true` kwenye `extra` kwa ombi lisilohitaji token (mfano `login`,
  /// `register`, `sendOtp`) — hivi ni vyema kwani token ya zamani
  /// inaweza kuharibu uthibitisho.
  static const String requiresAuthExtraKey = 'requires_auth';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Endpoints za umma (login, register, otp) hazipaswi kupewa token.
    if (options.extra[requiresAuthExtraKey] == false) {
      handler.next(options);
      return;
    }

    try {
      final token = await _tokenProvider.accessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[ApiConstants.headerAuthorization] =
            '${ApiConstants.bearerPrefix}$token';
      }
    } on AppException {
      // Kama kusoma token kumeshindwa (KeyStore iliyoharibika), tunaendelea
      // bila token: ombi litaenda, na kama endpoint inahitaji uthibitisho
      // tutapata 401 — ambayo hushughulikiwa hapa chini.
    }

    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldTryRefresh(err)) {
      handler.next(err);
      return;
    }

    final refreshed = await _refreshSafely();

    if (refreshed == null) {
      // Refresh imeshindwa — kikao kimeisha. Tunamwambia app iondoe kikao,
      // lakini tunarudisha kosa la awali ili UI ionyeshe kosa la 401
      // (AuthFailure: "Kikao chako kimeisha. Tafadhali ingia tena.").
      await _notifyUnauthorized();
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    options.extra[_retriedExtraKey] = true;
    options.headers[ApiConstants.headerAuthorization] =
        '${ApiConstants.bearerPrefix}$refreshed';

    try {
      // `_dio.fetch` hupitisha ombi **tena** kwenye interceptors zote —
      // hivyo token mpya inatumika, na kama litashindwa tena hatutarudia
      // (kwa sababu `_retriedExtraKey` imewekwa).
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Huamua kama 401 hii inastahili kujaribu kuhuisha token.
  bool _shouldTryRefresh(DioException err) {
    if (!ApiExceptionMapper.isUnauthorized(err)) return false;

    final options = err.requestOptions;

    // Ombi hili limesharudiwa — usirudie refresh tena.
    if (options.extra[_retriedExtraKey] == true) return false;

    // Ombi la umma lilipata 401 (mfano password mbovu): hakuna token ya
    // kuhuisha, na kurudia hakutasaidia.
    if (options.extra[requiresAuthExtraKey] == false) return false;

    // 401 kutoka kwenye refresh yenyewe haiwezi kuhuishwa.
    if (options.path.contains('/auth/refresh-token')) return false;

    return true;
  }

  /// Huhuisha token bila kuruhusu kosa lolote kupenya.
  ///
  /// Hii ni `try/catch` ya jumla kwa makusudi: kama `SecureStorage` ina
  /// tatizo, ni bora kurudisha `null` (na kumwonyesha mtumiaji skrini ya
  /// kuingia) kuliko kuangusha app nzima kutokana na kosa la kuhuisha token.
  Future<String?> _refreshSafely() async {
    try {
      return await _tokenProvider.refreshAccessToken();
    } on AppException {
      return null;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Huarifu app kwamba kikao kimeisha — bila kuangusha ombi lenyewe.
  Future<void> _notifyUnauthorized() async {
    try {
      await _tokenProvider.onUnauthorized();
    } catch (_) {
      // Kama hata kufuta kikao kimeshindwa, hatuna la kufanya hapa.
      // Mtumiaji ataona kosa la 401 na anaweza kuingia tena kwa mkono.
    }
  }
}

// ---------------------------------------------------------------------------
// Retry
// ---------------------------------------------------------------------------

/// Hurudia ombi lililoshindwa kwa sababu ya muda (mtandao wa Tanzania).
///
/// **Kanuni ya usalama ya kwanza: kurudia ombi la malipo kunaweza kutoza
/// mtumiaji mara mbili.** STK push ya M-Pesa iliyorudiwa inaweza kutuma
/// maombi mawili ya malipo kwenye simu ya mtumiaji, na mawili yanaweza
/// kukubaliwa. Kwa hivyo:
///
/// * `GET` na `HEAD` zinarudiwa **bila** ruhusa ya ziada — hazibadilishi kitu.
/// * `POST`/`PUT`/`PATCH`/`DELETE` zinarudiwa **tu** kama `extra[idempotent]`
///   imewekwa `true` kwa mkono na mwandishi wa datasource — hiyo ni ahadi
///   kwamba kurudia hakuna madhara (mfano `POST /tts/synthesize` ambayo
///   inazalisha faili jipya badala ya kubadilisha salio la mtu).
/// * Requests za malipo **haziweki** alama hiyo, kamwe.
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required Dio dio}) : _dio = dio;

  final Dio _dio;

  /// Alama inayowekwa kwenye `extra` kwa ombi linaloruhusiwa kurudiwa.
  static const String idempotentExtraKey = 'idempotent';

  /// Idadi ya majaribio yaliyofanyika kwa ombi hili.
  static const String _attemptExtraKey = 'retry_attempt';

  /// Method zinazorudiwa bila ruhusa ya ziada.
  static const List<String> _safeMethods = <String>['GET', 'HEAD'];

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_canRetry(err)) {
      handler.next(err);
      return;
    }

    final options = err.requestOptions;
    final attempt = (options.extra[_attemptExtraKey] as int?) ?? 0;
    options.extra[_attemptExtraKey] = attempt + 1;

    // Exponential backoff: 2s, 4s, 8s (`AppConstants.baseRetryDelay` = 2s).
    // Kwa nini backoff na si kurudia mara moja: kwenye mtandao wa 2G ombi
    // lililoshindwa kwa timeout halitafanikiwa sekunde moja baadaye —
    // kusubiri kunatoa nafasi kwa mtandao kupata nguvu tena, na
    // kunapunguza mzigo kwa seva iliyo na shida.
    final delay = AppConstants.baseRetryDelay * (1 << attempt);

    try {
      await Future<void>.delayed(delay);
    } catch (_) {
      handler.next(err);
      return;
    }

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Huamua kama ombi hili linaweza kurudiwa.
  bool _canRetry(DioException err) {
    if (!ApiExceptionMapper.isRetryableType(err)) return false;

    final options = err.requestOptions;

    // Mtumiaji amesitisha — usirudie ombi aliloacha.
    if (CancelToken.isCancel(err)) return false;

    final method = options.method.toUpperCase();
    if (_safeMethods.contains(method)) {
      return _hasAttemptsLeft(options);
    }

    // Method zinazobadilisha data: zinahitaji idhini ya wazi.
    if (options.extra[idempotentExtraKey] != true) return false;

    return _hasAttemptsLeft(options);
  }

  bool _hasAttemptsLeft(RequestOptions options) {
    final attempt = (options.extra[_attemptExtraKey] as int?) ?? 0;
    return attempt < ApiConstants.maxRetries;
  }
}

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------

/// Huandika kumbukumbu za requests — **dev na staging pekee**.
///
/// **Kanuni ya usalama (spec §11):** logs za production zinaweza kusomwa na
/// mtu mwingine (crash reports, `adb logcat`). Nambari ya simu ya mtumiaji
/// ni taarifa binafsi ya Tanzania inayotumika kwa malipo, hivyo:
///
/// * Logging **imezimwa kabisa** kwenye production ([AppConfig.enableLogging]).
/// * `Authorization` header **haionyeshwi kamwe** — tunachapisha `Bearer ***`.
/// * Nambari za simu zinazopatikana kwenye path au body hufichwa kwa
///   `+255 *** *** 678` (tarakimu nne za mwisho pekee, kama UI inavyofanya).
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({Logger? logger}) : _logger = logger ?? Logger();

  final Logger _logger;

  /// Muda ombi lilipoanza — huhifadhiwa kwenye `extra`.
  static const String _startedAtExtraKey = 'request_started_at';

  /// Usemi wa kutafuta nambari za simu za Tanzania (pamoja na `00255`).
  ///
  /// Unashika: `0712345678`, `255712345678`, `+255712345678`, `00255712345678`.
  static final RegExp _phonePattern =
      RegExp(r'(\+?2550?|0)\d{9}');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(options);
      return;
    }

    options.extra[_startedAtExtraKey] = DateTime.now().millisecondsSinceEpoch;
    _logger.d(
      '→ ${options.method} ${_redact(options.uri.toString())} '
      '| headers: ${_redactHeaders(options.headers)}',
    );

    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (!_enabled) {
      handler.next(response);
      return;
    }

    _logger.i(
      '← ${response.statusCode} ${response.requestOptions.method} '
      '${_redact(response.requestOptions.uri.toString())} '
      '(${_elapsed(response.requestOptions)} ms)',
    );

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!_enabled) {
      handler.next(err);
      return;
    }

    // Kosa la mtandao linarajiwa kwa **aina** pekee, si kwa body —
    // body ya kosa inaweza kuwa na taarifa binafsi.
    final serverCode =
        ApiExceptionMapper.parseErrorBody(err.response?.data)?.code ?? '-';
    _logger.w(
      '✗ ${err.type.name} '
      '${err.response?.statusCode ?? '-'} '
      '[${_redact(serverCode)}] '
      '${_redact(err.requestOptions.uri.toString())} '
      '(${_elapsed(err.requestOptions)} ms)',
    );

    handler.next(err);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Logging huendeshwa kwenye dev/staging pekee.
  bool get _enabled =>
      AppConfig.enableLogging && AppConfig.env.verboseNetworkLogs;

  /// Muda uliopita tangu ombi lianze (ms).
  int _elapsed(RequestOptions options) {
    final startedAt = options.extra[_startedAtExtraKey];
    if (startedAt is! int) return 0;
    return DateTime.now().millisecondsSinceEpoch - startedAt;
  }

  /// Huficha nambari za simu kwenye maandishi.
  String _redact(String input) => input.replaceAllMapped(
        _phonePattern,
        (match) => TanzaniaPhoneUtils.mask(match.group(0) ?? ''),
      );

  /// Huficha headers nyeti kabla ya kuandika.
  ///
  /// Tunarudisha `Map` mpya (badala ya kuandika `options.headers`) ili
  /// tusibadilishe ombi halisi kwa bahati mbaya.
  Map<String, dynamic> _redactHeaders(Map<String, dynamic> headers) {
    final safe = <String, dynamic>{};
    headers.forEach((key, value) {
      final lower = key.toLowerCase();
      if (lower == ApiConstants.headerAuthorization.toLowerCase()) {
        safe[key] = '***';
      } else if (lower == ApiConstants.headerContentType.toLowerCase()) {
        safe[key] = value;
      } else {
        safe[key] = _redact('$value');
      }
    });
    return safe;
  }
}
