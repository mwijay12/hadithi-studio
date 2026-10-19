/// NETWORK INFO — kujua kama kifaa kiko mtandaoni, na kwa njia ipi.
///
/// **Kwa nini faili hili lipo:** Tanzania ina 2G/3G sehemu kubwa ya muda, na
/// `Either<Failure, Success>` pekee haitoshi kwa app ya offline-first. Kabla ya
/// kutuma ombi lolote, tunahitaji kujua:
///
/// 1. Je, kuna muunganisho kabisa? (bila hii, ombi hukaa sekunde 30 kisha
///    kushindwa — betri na bundle ya mtumiaji zinapotea bure)
/// 2. Je, tuko kwenye Wi-Fi? (`AppImageUtils.qualityFor` huchagua ubora wa
///    picha: Wi-Fi → high, data ya simu → medium)
/// 3. Je, kuna nafuu ya kutumia sauti ya cloud? (`AppAudioUtils.engineFor`
///    hupendelea sauti iliyohifadhiwa au engine ya offline)
///
/// **TANBIHI MUHIMU kuhusu kile `connectivity_plus` inaweza na hawezi:**
/// package hii huripoti **aina ya muunganisho** (wifi, mobile, ethernet, none),
/// SI kasi yake. Simu inayosema `mobile` inaweza kuwa 2G (10 KB/s) au 4G
/// (2 MB/s) — hatuwezi kutofautisha kutoka hapa. Kwa hivyo [isSlowConnection]
/// ni **kadirio la kihafidhina**: `mobile` inachukuliwa kuwa ya polepole.
/// Ni bora kudhani polepole (na kuonyesha spinner) kuliko kudhani haraka na
/// kumwacha mtumiaji akisubiri bila maelezo.
///
/// **TANBIHI YA PILI:** `none` haimaanishi "hakuna internet" kwa uhakika —
/// Wi-Fi ya hoteli yenye captive portal huripoti `wifi` wakati kwa kweli
/// hakuna internet. Kwa hivyo [isConnected] ni **kidokezo cha kuamua mapema**,
/// si uhakika. Ukweli wa mwisho daima ni ombi lenyewe: `DioException` yenye
/// `connectionError` ndiyo uthibitisho kwamba hakuna mtandao.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Aina ya muunganisho iliyorahisishwa kwa mahitaji ya Hadithi Studio.
///
/// Tunapunguza `ConnectivityResult` za plugin (bluetooth, vpn, other ...)
/// kuwa tatu tu — kwa sababu app haitofautishi matumizi yake kwa bluetooth
/// au VPN, na kuongeza matawi yasiyotumika ni code ya bure ya kudumisha.
enum ConnectionQuality {
  /// Hakuna muunganisho wowote.
  offline('Hakuna mtandao', 'Offline'),

  /// Muunganisho wa data ya simu (2G/3G/4G) — tunaudhani wa polepole.
  mobile('Data ya simu', 'Mobile data'),

  /// Wi-Fi au ethernet — tunaudhani wa haraka na wa nafuu kwa mtumiaji.
  wifi('Wi-Fi', 'Wi-Fi');

  const ConnectionQuality(this.labelSw, this.labelEn);

  final String labelSw;
  final String labelEn;

  /// `true` kama kuna muunganisho wowote.
  bool get isOnline => this != ConnectionQuality.offline;

  /// `true` kama data inaweza kutumika kwa uhuru zaidi (picha kubwa, TTS ya cloud).
  bool get isUnmetered => this == ConnectionQuality.wifi;
}

/// Mkataba wa kukagua hali ya mtandao.
///
/// Ni `abstract class` (SI class halisi) ili widgets na BLoCs zitegemee
/// mkataba huu pekee — hivyo kwenye tests tunaweza kuweka `FakeNetworkInfo`
/// inayorudisha `offline` bila kuendesha plugin yoyote.
abstract class NetworkInfo {
  /// Hali ya muunganisho kwa sasa.
  ///
  /// Inaita plugin kila mara — hivyo kwenye widget ya `build()` tumia
  /// [cachedQuality] badala yake.
  Future<ConnectionQuality> checkQuality();

  /// Hali ya mwisho iliyosomwa — **bila** kuita plugin.
  ///
  /// Huwekwa na [checkQuality] na na mkondo wa [onQualityChanged].
  ConnectionQuality get cachedQuality;

  /// Mkondo wa mabadiliko ya muunganisho (offline ↔ online).
  ///
  /// Hutumika na `ReaderBloc` kumwonyesha mtumiaji "umerudi mtandaoni" na
  /// kuanza kusawazisha maendeleo ya usomaji (offline queue).
  Stream<ConnectionQuality> get onQualityChanged;

  /// Kifaa kiko mtandaoni kwa sasa?
  Future<bool> get isConnected;

  /// Tuko kwenye Wi-Fi/ethernet (bila kutumia bundle ya mtumiaji)?
  Future<bool> get isOnWifi;

  /// Muunganisho unaonekana wa polepole (2G/3G)?
  Future<bool> get isSlowConnection;
}

/// Utekelezaji halisi unaotumia `connectivity_plus`.
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  /// Hali ya mwisho iliyosomwa, ili widget isilazimike kusubiri plugin.
  ///
  /// Tunaanza na [ConnectionQuality.wifi] — **si** `offline`. Sababu: wakati
  /// app inafunguka, hatujasoma hali halisi bado. Kudhani `offline` kungeonyesha
  /// "Hakuna mtandao" kwa sekunde ya kwanza kila mtumiaji, jambo ambalo ni
  /// la uongo na la kumtia hofu. Kudhani Wi-Fi ni kudhani kwa upande wa
  /// matumaini, lakini kunaonyesha UI ya kawaida (spinners) badala ya onyo.
  ConnectionQuality _cached = ConnectionQuality.wifi;

  /// `connectivity_plus` 6.x+ hutoa **orodha** ya aina za muunganisho kwa
  /// kila tukio (kifaa kinaweza kuwa kwenye Wi-Fi **na** data ya simu kwa
  /// wakati mmoja). Tunaituma orodha hiyo moja kwa moja kwa [_fromResults].
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Broadcast controller — kwa sababu sources zetu ni nyingi (ReaderBloc,
  /// PaymentBloc, CacheManager) na zote zinahitaji kusikiliza kwa wakati mmoja.
  final StreamController<ConnectionQuality> _qualityController =
      StreamController<ConnectionQuality>.broadcast();

  /// Huanza kufuatilia mabadiliko ya muunganisho.
  ///
  /// Huitwa mara moja kwenye DI (`di.init()`), si kwenye kila widget.
  void start() {
    if (_subscription != null) return;

    // Soma hali ya kwanza mara moja, ili `cachedQuality` iwe sahihi.
    // Hii ni `async` lakini haiwi `await`ed — `start()` haipaswi kuchelewesha
    // kufunguka kwa app.
    _refresh();

    _subscription = _connectivity.onConnectivityChanged.listen(
      _emitFromResults,
      onError: (Object error, StackTrace stackTrace) {
        // Plugin ikishindwa (hutokea kwenye Android ya zamani), tunabaki na
        // hali ya mwisho tunayoijua badala ya kuangusha app.
        _emit(_cached);
      },
    );
  }

  /// Husimamisha kufuatilia na kufunga mkondo.
  ///
  /// Huitwa kwenye `dispose()` ya DI au kwenye tests.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _qualityController.close();
  }

  @override
  Future<ConnectionQuality> checkQuality() async {
    final List<ConnectivityResult> results =
        await _connectivity.checkConnectivity();
    final quality = _fromResults(results);
    _emit(quality);
    return quality;
  }

  @override
  ConnectionQuality get cachedQuality => _cached;

  @override
  Stream<ConnectionQuality> get onQualityChanged => _qualityController.stream;

  @override
  Future<bool> get isConnected async =>
      (await checkQuality()).isOnline;

  @override
  Future<bool> get isOnWifi async => (await checkQuality()).isUnmetered;

  @override
  Future<bool> get isSlowConnection async {
    final quality = await checkQuality();
    // Tahadhari: WiFi ya mkoa mwingine pia inaweza kuwa ya polepole, lakini
    // hatuna njia ya kuipima kutoka hapa — tunategemea aina ya muunganisho.
    return quality == ConnectionQuality.mobile;
  }

  // ---------------------------------------------------------------------------
  // Helpers za ndani
  // ---------------------------------------------------------------------------

  /// Husoma hali ya kwanza kwa nyuma (background).
  void _refresh() {
    _connectivity.checkConnectivity().then(
          _emitFromResults,
          onError: (Object error) => _emit(_cached),
        );
  }

  /// Hupokea orodha ya aina za muunganisho na kutoa [ConnectionQuality].
  void _emitFromResults(List<ConnectivityResult> results) {
    _emit(_fromResults(results));
  }

  /// Hubadilisha orodha ya `ConnectivityResult` kuwa [ConnectionQuality] moja.
  ///
  /// **Kwa nini tunachukua Wi-Fi kwanza:** kifaa kinaweza kuwa kwenye Wi-Fi
  /// **na** data ya simu kwa wakati mmoja. Kutanguliza Wi-Fi ni sahihi kwa
  /// mtumiaji wa Tanzania kwa sababu Wi-Fi (mahali pa kazi, shule, hoteli)
  /// kwa kawaida haitumii bundle yake ya data.
  ///
  /// `vpn` na `bluetooth` zinatupiliwa mbali kimakusudi: VPN ni njia ya
  /// kusafirisha data, si aina yenyewe (mtumiaji kwenye VPN bado ana Wi-Fi
  /// au data ya simu), na bluetooth haitoi internet kwa app hii.
  ConnectionQuality _fromResults(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      // `none` pamoja na matokeo mengine = hakuna njia ya kutoka.
      // (Plugin hurudisha `[none]` pekee kwa kawaida, lakini tunalinda.)
      final hasRealLink = results.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet ||
            result == ConnectivityResult.mobile,
      );
      if (!hasRealLink) return ConnectionQuality.offline;
    }

    if (results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet)) {
      return ConnectionQuality.wifi;
    }

    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectionQuality.mobile;
    }

    return ConnectionQuality.offline;
  }

  /// Huweka hali mpya na kuisambaza — **bila kurudia** hali ile ile.
  ///
  /// Kurudia kungeamsha `ReaderBloc` bure kila plugin iliporudisha thamani
  /// ile ile (hutokea mara nyingi kwenye Android).
  void _emit(ConnectionQuality quality) {
    if (_cached == quality) return;
    _cached = quality;
    if (!_qualityController.isClosed) {
      _qualityController.add(quality);
    }
  }
}
