/// Utegemezi wote wa app (dependency injection) kwa `get_it`.
///
/// `lib/main.dart` huita `di.init()` **kabla** ya `runApp`, kwa hivyo
/// kila kitu kinachohitajika wakati app inafunguka kinaandaliwa hapa.
///
/// **Mpangilio ni muhimu.** Kila kitu kinategemea kilichotangulia:
/// ```
/// LocalStorage ─┐
/// SecureStorage ┼─> AppRequestContext ─┐
///               └─> SecureAuthTokenProvider ─┴─> Dio ─> ApiClient
/// NetworkInfo ───────────────────────────┘
/// CacheManager (huru)
/// ```
/// `DioFactory.create` hudai `NetworkInfo`, `RequestContext` na
/// `AuthTokenProvider` — kwa hivyo hatuwezi kusajili `Dio` kwanza.
///
/// **Kwa nini `registerSingleton` na si `registerLazySingleton`:** hizi
/// zote zina `init()` ya `async` ambayo **lazima** ikamilike kabla ya
/// matumizi (Hive, `SharedPreferences`, `Hive.initFlutter`). Lazy
/// singleton ingeunda kitu kwenye matumizi ya kwanza — yaani app
/// ingeanza kufanya kazi bila hifadhi ikiwa `init()` ilichelewa.
/// Tunazisajili tayari-tayari.
///
/// **Kwa nini `CacheManager` haiangushi app:** `path_provider`
/// (`getApplicationSupportDirectory`) haitumiki kwenye web, na kwenye
/// Android kunaweza kushindwa kama folda ya app haipatikani. Cache ni
/// **nyongeza** — app inaweza kusoma kwa mtandao bila cache. Kwa hivyo
/// tunarekodi kosa na kuendelea. Hivyo hivyo kwa `NetworkInfo.start()`.
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

import '../../features/stories/data/repositories/story_repository_impl.dart';
import '../../features/stories/domain/repositories/story_repository.dart';
import '../network/api_client.dart';
import '../network/api_interceptors.dart';
import '../network/network_info.dart';
import '../storage/cache_manager.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

/// Sehemu ya kimataifa ya GetIt.
///
/// Tumia `di.sl<ApiClient>()` (au `di.sl<LocalStorage>()`) kupata
/// utegemezi. Usaunde `Dio` au `LocalStorageImpl` kwa mkono kwenye
/// widgets — ungevunja hali moja (single instance) na cache.
final GetIt sl = GetIt.instance;

/// Kirekodi cha DI — hutumika kabla `Logger` ya app iwepo.
final Logger _log = Logger();

/// Huanzisha utegemezi wote.
///
/// Huitwa **mara moja** kutoka `main.dart`. Inarudi haraka kama
/// imeanza tayari (hii huzuia kuanzisha Hive/SharedPreferences mara
/// mbili kwenye "hot restart" au kwenye majaribio).
Future<void> init() async {
  if (sl.isRegistered<ApiClient>()) {
    _log.i('DI: imeanzishwa tayari — naruka.');
    return;
  }

  // -------------------------------------------------------------------------
  // 1. Hifadhi (storage)
  // -------------------------------------------------------------------------

  // `LocalStorageImpl()` — constructor haina hoja. `init()` yake
  // hufungua Hive na SharedPreferences.
  final LocalStorageImpl localStorage = LocalStorageImpl();
  await localStorage.init();
  sl.registerSingleton<LocalStorage>(localStorage);
  _log.i('DI: LocalStorage iko tayari.');

  // `SecureStorageImpl()` — constructor haina hoja.
  sl.registerSingleton<SecureStorage>(SecureStorageImpl());
  _log.i('DI: SecureStorage iko tayari.');

  // Cache ni ya hiari — tazama doc ya faili hili.
  try {
    final CacheManagerImpl cacheManager = CacheManagerImpl();
    await cacheManager.init();
    sl.registerSingleton<CacheManager>(cacheManager);
    _log.i('DI: CacheManager iko tayari.');
  } catch (error, stackTrace) {
    _log.w(
      'DI: CacheManager haikuweza kuanzishwa — app itaendelea bila cache.',
      error: error,
      stackTrace: stackTrace,
    );
  }

  // -------------------------------------------------------------------------
  // 2. Mtandao
  // -------------------------------------------------------------------------

  final NetworkInfoImpl networkInfo = NetworkInfoImpl();
  sl.registerSingleton<NetworkInfo>(networkInfo);
  // `start()` ni `void` na ni idempotent (ina `if (_subscription != null)
  // return;`) — kwa hivyo `await` haihitajiki na kuita mara mbili ni salama.
  try {
    networkInfo.start();
  } catch (error, stackTrace) {
    _log.w(
      'DI: NetworkInfo.start() imeshindwa — hali ya mtandao haitafuatiliwa.',
      error: error,
      stackTrace: stackTrace,
    );
  }
  _log.i('DI: NetworkInfo iko tayari.');

  // -------------------------------------------------------------------------
  // 3. Muktadha wa ombi + token
  // -------------------------------------------------------------------------

  final SecureStorage secureStorage = sl<SecureStorage>();
  final LocalStorage storage = sl<LocalStorage>();

  sl.registerSingleton<RequestContext>(
    AppRequestContext(
      secureStorage: secureStorage,
      localStorage: storage,
    ),
  );

  sl.registerSingleton<AuthTokenProvider>(
    SecureAuthTokenProvider(storage: secureStorage),
  );
  _log.i('DI: RequestContext na AuthTokenProvider ziko tayari.');

  // -------------------------------------------------------------------------
  // 4. HTTP
  // -------------------------------------------------------------------------

  final Dio dio = DioFactory.create(
    networkInfo: sl<NetworkInfo>(),
    requestContext: sl<RequestContext>(),
    tokenProvider: sl<AuthTokenProvider>(),
  );
  sl.registerSingleton<Dio>(dio);

  sl.registerSingleton<ApiClient>(
    ApiClient(dio: dio, networkInfo: sl<NetworkInfo>()),
  );

  // -------------------------------------------------------------------------
  // 5. Repository
  // -------------------------------------------------------------------------
  //
  // **Kwa nini `StoryRepository` pekee, na si cubits.**
  //
  // Prompt 5 (Part A) inaomba tusajili datasources, repository, na cubits.
  // Muundo halisi wa mradi huu unatofautiana, na kufuata ombi kihalisi
  // kungeandika msimbo ambao **haukamiliki**:
  //
  // * **Hakuna datasource.** `lib/features/stories/data/datasources/` ina
  //   `story_sample_data.dart` pekee. Hakuna `StoryRemoteDatasource` wala
  //   `StoryLocalDatasource`, na `StoryRepositoryImpl` huchukua
  //   `{List<Story>? stories}` — si datasources. Kusajili madarasa
  //   yasiyokuwepo ni kosa la kukusanya.
  //
  // * **Cubits hazichukui repository kwa nafasi.** Kila cubit ina
  //   `{StoryRepository? repository}` (jina, si nafasi) na huangukia
  //   `resolveStoryRepository()`. Hivyo `StoryDetailCubit(getIt<…>())`
  //   hangeshindwa kukusanywa — lakini **pia haingetumika**: kurasa
  //   huziunda ndani ya `BlocProvider(create:)` kwenye `app_routes.dart`.
  //   Kusajili factory isiyotumika ni msimbo mfu.
  //
  // Kwa hivyo tunasajili kitu **kimoja** ambacho kwa kweli kinakosekana:
  // `StoryRepository`. Hii inafanya `resolveStoryRepository()`
  // (`presentation/stories_dependencies.dart`) kurudisha instance ya DI
  // kwenye app kamili badala ya kuunda mpya kila wakati — hivyo hadithi
  // zinasomwa mara moja na hifadhi moja inatumika.
  //
  // Preview ya web (`main_web_preview.dart`) hairudii DI kwa makusudi; hapo
  // `resolveStoryRepository()` huendelea kurudisha implement ya ndani.
  sl.registerLazySingleton<StoryRepository>(
    // `lazy` ni sahihi hapa (tofauti na hifadhi): constructor haina `init()`
    // ya async, hivyo kuunda kwenye matumizi ya kwanza hakuna hatari.
    () => StoryRepositoryImpl(),
  );

  _log.i('DI: StoryRepository iko tayari. DI imekamilika.');
}

/// Hufuta usajili wote — kwa **majaribio** pekee.
///
/// Kwenye app halisi hii haipaswi kuitwa: kufuta DI katikati ya kikao
/// kungeacha widgets zikiwa na marejeleo ya vitu vilivyofutwa.
@visibleForTesting
Future<void> reset() async {
  await sl.reset();
}
