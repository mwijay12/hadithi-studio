/// API CLIENT — mlango mmoja wa kutoka nje ya app kwenda kwenye backend.
///
/// **Kanuni:** hakuna `Dio`, `http` wala URL yoyote inayojengwa kwa mkono
/// kwenye feature code. Kila datasource hupitia hapa, kwa hivyo:
///
/// * Endpoints zinatoka [ApiConstants] na ndugu zake (hakuna typo za URL).
/// * Makosa **hutupwa** kama [AppException] (SI kurudishwa kama `null`),
///   na repository ndiyo inayobadilisha kuwa `Either<Failure, Success>`.
/// * Ukaguzi wa mtandao hufanyika **kabla** ya ombi, ili mtumiaji wa 2G
///   asisubiri sekunde 30 kwa ombi ambalo hatuwezi kutuma kabisa.
///
/// **Kwa nini hatutumii `Either` hapa:** [ApiClient] ni sehemu ya **data
/// layer**. Data layer hutupa exceptions; repository huzishika na kurudisha
/// `Left(Failure)` (kanuni ya 6). Kuchanganya `Either` kwenye client kungeifanya
/// repository isiwe na kazi ya maana, na tungekuwa na `Either` ndani ya `Either`.
library;

import 'package:dio/dio.dart';

import '../../config/app_config.dart';
import '../../config/constants/api_constants.dart';
import '../errors/exceptions.dart';
import 'api_exceptions.dart';
import 'api_interceptors.dart';
import 'network_info.dart';

/// Hujenga `Dio` iliyosanidiwa kwa Hadithi Studio.
///
/// Tunaweka hii hapa (na si kwenye DI) ili mpangilio wa interceptors uwe
/// karibu na maoni yanayoeleza **kwa nini** mpangilio huo ni muhimu.
abstract final class DioFactory {
  /// Huunda `Dio` pamoja na interceptors zote.
  ///
  /// [extraInterceptors] huongezwa **baada** ya zetu — hii ni muhimu kwa
  /// mfano `MockInterceptor` ya kujaribu UI kabla backend haijakamilika
  /// ([AppConfig.useMockData]).
  static Dio create({
    required NetworkInfo networkInfo,
    required RequestContext requestContext,
    required AuthTokenProvider tokenProvider,
    List<Interceptor> extraInterceptors = const <Interceptor>[],
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        contentType: ApiConstants.contentTypeJson,
        responseType: ResponseType.json,

        // 2xx pekee ni mafanikio. Hii inahakikisha 4xx/5xx huja kama
        // `DioException` (yenye `response`) — ndipo [ApiExceptionMapper]
        // inachukua ujumbe wa seva na `fieldErrors`.
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,

        // Muhimu sana: bila hii, `response.data` huwa `null` kwenye majibu ya
        // kosa, na tunapoteza `fieldErrors` za 422 (mfano "namba ya simu
        // imeshatumika") — hivyo fomu inashindwa kumwonyesha mtumiaji kosa
        // mahali penye kosa.
        receiveDataWhenStatusError: true,
      ),
    );

    dio.interceptors.addAll(<Interceptor>[
      // 1. Headers kwanza — kila ombi (hata lile la kuingia) linahitaji
      //    `Accept-Language` ili ujumbe wa kosa uwe kwa lugha ya mtumiaji.
      HeadersInterceptor(requestContext),

      // 2. Auth kabla ya Retry — ombi lililorudiwa linahitaji token mpya
      //    tayari limewekwa.
      AuthInterceptor(dio: dio, tokenProvider: tokenProvider),

      // 3. Retry baada ya Auth.
      RetryInterceptor(dio: dio),

      // 4. Logging mwisho — ionyeshe **matokeo ya mwisho**, si kila jaribio.
      LoggingInterceptor(),
    ]);

    if (extraInterceptors.isNotEmpty) {
      dio.interceptors.addAll(extraInterceptors);
    }

    return dio;
  }
}

/// Mlango mmoja wa maombi ya HTTP.
class ApiClient {
  ApiClient({required Dio dio, required NetworkInfo networkInfo})
      : _dio = dio,
        _networkInfo = networkInfo;

  final Dio _dio;
  final NetworkInfo _networkInfo;

  /// `Dio` ghafi — kwa hali maalum pekee (mfano `download` yenye progress
  /// ya faili, au `MultipartFile` ya jalada la hadithi).
  ///
  /// Usitumie hii kutuma requests za kawaida: ungepoteza ukaguzi wa mtandao
  /// na ubadilishaji wa makosa unaofanywa na [ApiClient].
  Dio get raw => _dio;

  // ---------------------------------------------------------------------------
  // GET
  // ---------------------------------------------------------------------------

  /// Ombi la `GET` linalorudisha body iliyodecode.
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) =>
      _send(
        path: path,
        method: 'GET',
        query: query,
        requiresAuth: requiresAuth,
        cancelToken: cancelToken,
        receiveTimeout: receiveTimeout,
      );

  /// `GET` inayohakikisha jibu ni JSON object.
  ///
  /// Hii hulinda repositories: kama seva irudishe HTML (proxy error) au
  /// orodha, tunapata [ServerException] yenye maelezo, badala ya
  /// `type 'String' is not a subtype of type 'Map<String, dynamic>'` ambayo
  /// ni vigumu kuelewa kwenye logs.
  Future<Map<String, dynamic>> getMap(
    String path, {
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    final data = await get(
      path,
      query: query,
      requiresAuth: requiresAuth,
      cancelToken: cancelToken,
      receiveTimeout: receiveTimeout,
    );
    return _asMap(data, path);
  }

  /// `GET` inayohakikisha jibu ni JSON array.
  Future<List<dynamic>> getList(
    String path, {
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
  }) async {
    final data = await get(
      path,
      query: query,
      requiresAuth: requiresAuth,
      cancelToken: cancelToken,
      receiveTimeout: receiveTimeout,
    );
    return _asList(data, path);
  }

  /// `GET` ya ukurasa mmoja wa orodha (pagination).
  ///
  /// [page] huanza na 1 (si 0) kwa sababu API yetu inafuata mkataba wa
  /// kawaida wa REST, na `page=0` ingerudisha orodha tupu bila maelezo.
  Future<List<dynamic>> getPaginated(
    String path, {
    required int page,
    int pageSize = ApiConstants.defaultPageSize,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    CancelToken? cancelToken,
  }) =>
      getList(
        path,
        query: <String, dynamic>{
          ...?query,
          'page': page < 1 ? 1 : page,
          'limit': pageSize,
        },
        requiresAuth: requiresAuth,
        cancelToken: cancelToken,
      );

  // ---------------------------------------------------------------------------
  // POST / PUT / PATCH / DELETE
  // ---------------------------------------------------------------------------

  /// Ombi la `POST`.
  ///
  /// [idempotent] **lazima** ibaki `false` kwa malipo. Tazama
  /// `RetryInterceptor` — kurudia ombi la M-Pesa kunaweza kumtoza mtumiaji
  /// mara mbili.
  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    bool idempotent = false,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) =>
      _send(
        path: path,
        method: 'POST',
        body: body,
        query: query,
        requiresAuth: requiresAuth,
        idempotent: idempotent,
        cancelToken: cancelToken,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
      );

  /// `POST` inayohakikisha jibu ni JSON object.
  Future<Map<String, dynamic>> postMap(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    bool idempotent = false,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    final data = await post(
      path,
      body: body,
      query: query,
      requiresAuth: requiresAuth,
      idempotent: idempotent,
      cancelToken: cancelToken,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
    );
    return _asMap(data, path);
  }

  /// Ombi la `PUT` (badilisha kitu kizima).
  Future<dynamic> put(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    bool idempotent = false,
    CancelToken? cancelToken,
  }) =>
      _send(
        path: path,
        method: 'PUT',
        body: body,
        query: query,
        requiresAuth: requiresAuth,
        idempotent: idempotent,
        cancelToken: cancelToken,
      );

  /// Ombi la `PATCH` (badilisha sehemu ya kitu).
  ///
  /// Hii ndiyo inayotumika kuhifadhi maendeleo ya usomaji na alama za kurasa
  /// (bookmarks), kwa sababu tunabadilisha sehemu moja ya rekodi.
  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    bool idempotent = true,
    CancelToken? cancelToken,
  }) =>
      _send(
        path: path,
        method: 'PATCH',
        body: body,
        query: query,
        requiresAuth: requiresAuth,
        idempotent: idempotent,
        cancelToken: cancelToken,
      );

  /// Ombi la `DELETE`.
  Future<dynamic> delete(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    bool idempotent = true,
    CancelToken? cancelToken,
  }) =>
      _send(
        path: path,
        method: 'DELETE',
        body: body,
        query: query,
        requiresAuth: requiresAuth,
        idempotent: idempotent,
        cancelToken: cancelToken,
      );

  // ---------------------------------------------------------------------------
  // Upload / Download
  // ---------------------------------------------------------------------------

  /// Hupakia faili (mfano jalada la hadithi au picha ya mtumiaji).
  ///
  /// Kumbuka: `sendTimeout` ni mrefu ([ApiConstants.uploadTimeout]) kwa
  /// sababu kupakia picha ya 2 MB kwenye 3G ya Tanzania kunaweza kuchukua
  /// dakika kadhaa. Bila hii, mtumiaji angeona "kosa la mtandao" wakati
  /// pakua lilikuwa linaendelea vizuri.
  Future<Map<String, dynamic>> uploadFile(
    String path, {
    required List<int> bytes,
    required String fileName,
    String fieldName = 'file',
    Map<String, dynamic>? fields,
    bool requiresAuth = true,
    CancelToken? cancelToken,
  }) async {
    await _ensureConnected();

    final formData = FormData.fromMap(<String, dynamic>{
      ...?fields,
      fieldName: MultipartFile.fromBytes(bytes, filename: fileName),
    });

    try {
      final response = await _dio.post<dynamic>(
        path,
        data: formData,
        cancelToken: cancelToken,
        options: Options(
          extra: <String, dynamic>{
            AuthInterceptor.requiresAuthExtraKey: requiresAuth,
            // Uploads hazirudiwi kiotomatiki — jalada la hadithi linaweza
            // kukatika katikati, na kurudia kungetumia bundle mara mbili.
            RetryInterceptor.idempotentExtraKey: false,
          },
          sendTimeout: ApiConstants.uploadTimeout,
          receiveTimeout: ApiConstants.uploadTimeout,
        ),
      );
      return _asMap(response.data, path);
    } on DioException catch (error) {
      throw ApiExceptionMapper.fromDioException(error);
    }
  }

  /// Hupakua faili hadi kwenye kumbukumbu ya kifaa (offline reading).
  ///
  /// Hurudisha `Response` kamili ili mwitaji aweze kuona `statusCode` na
  /// headers (mfano `content-length` kwa maonyesho ya maendeleo).
  Future<Response<dynamic>> download(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    await _ensureConnected();

    try {
      return await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw ApiExceptionMapper.fromDioException(error);
    }
  }

  // ---------------------------------------------------------------------------
  // Kiini
  // ---------------------------------------------------------------------------

  /// Kiini cha maombi yote — hapa tu ndipo `_dio` inaitwa.
  Future<dynamic> _send({
    required String path,
    required String method,
    Object? body,
    Map<String, dynamic>? query,
    bool requiresAuth = true,
    bool idempotent = false,
    CancelToken? cancelToken,
    Duration? receiveTimeout,
    Duration? sendTimeout,
  }) async {
    await _ensureConnected();

    try {
      final response = await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: query,
        cancelToken: cancelToken,
        options: Options(
          method: method,
          extra: <String, dynamic>{
            AuthInterceptor.requiresAuthExtraKey: requiresAuth,
            RetryInterceptor.idempotentExtraKey: idempotent,
          },
          receiveTimeout: receiveTimeout,
          sendTimeout: sendTimeout,
        ),
      );
      return response.data;
    } on DioException catch (error) {
      // Tunaacha `raw` hapa kama `AppException` — repository ndiyo
      // inayobadilisha kuwa `Failure` kwa `ErrorHandler.map`.
      throw ApiExceptionMapper.fromDioException(error);
    }
  }

  /// Hukagua mtandao kabla ya kutuma ombi.
  ///
  /// **Kwa nini tunafanya hivi:** ombi lililotumwa bila mtandao hukaa hadi
  /// `connectTimeout` (sekunde 30) kisha kushindwa. Kwenye app ya Tanzania,
  /// hiyo ni betri ya bure na kusubiri kusiko na maana. Kukagua mapema
  /// hurudisha kosa mara moja, na UI inaweza kuonyesha "unaweza kusoma
  /// hadithi zilizopakuliwa" papo hapo.
  ///
  /// TANBIHI: `connectivity_plus` inaweza kusema "wifi" wakati hakuna
  /// internet (captive portal ya hoteli). Kwa hivyo ukaguzi huu unazuia
  /// **offline ya uhakika** pekee; kama plugin inasema tuko online, ombi
  /// huenda kama kawaida na kosa la kweli linatoka kwenye ombi lenyewe.
  Future<void> _ensureConnected() async {
    if (AppConfig.useMockData) return;

    final quality = await _networkInfo.checkQuality();
    if (quality == ConnectionQuality.offline) {
      throw const NetworkException(
        'Hakuna muunganisho wa mtandao kwa sasa.',
      );
    }
  }

  /// Huhakikisha jibu ni JSON object.
  Map<String, dynamic> _asMap(dynamic data, String path) {
    // Dio 5 hurudisha `Map<String, dynamic>` kwa JSON object — hii ni
    // ukaguzi wa kubadilisha tu kama seva ilirudisha `Map<dynamic, dynamic>`.
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map((key, value) => MapEntry('$key', value));
    }
    throw ServerException(
      'Seva ilirudisha umbo lisilo sahihi kwa $path '
      '(ilikuwa ${data.runtimeType}, tulitarajia JSON object).',
      code: 'BAD_RESPONSE_SHAPE',
    );
  }

  /// Huhakikisha jibu ni JSON array.
  List<dynamic> _asList(dynamic data, String path) {
    if (data is List) return data;

    // Baadhi ya endpoints hurudisha `{"data": [...]}` — tunavuta orodha
    // kutoka humo ili repositories zisirudie mantiki hii kila mahali.
    if (data is Map) {
      final inner = data['data'] ?? data['items'] ?? data['results'];
      if (inner is List) return inner;
    }

    throw ServerException(
      'Seva ilirudisha umbo lisilo sahihi kwa $path '
      '(ilikuwa ${data.runtimeType}, tulitarajia JSON array).',
      code: 'BAD_RESPONSE_SHAPE',
    );
  }
}
