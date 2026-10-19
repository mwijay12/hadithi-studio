/// SECURE STORAGE — siri za mtumiaji: tokens, PIN ya mzazi, device ID.
///
/// **Kwa nini faili hii pia ina `SecureAuthTokenProvider` na
/// `AppRequestContext`:** hifadhi salama ni kuhusu **utambulisho** — nani
/// ameingia (tokens) na kifaa hiki ni kipi (device ID). Vitegemezi viwili
/// vinavyohitaji utambulisho huo (`AuthTokenProvider` kwa safu ya mtandao, na
/// `RequestContext` kwa headers) vimewekwa hapa ili `core/network/` isilazimike
/// kujua `FlutterSecureStorage` ipo — tazama maelezo kwenye
/// `core/network/api_interceptors.dart`.
///
/// **Kanuni ya usalama:** hakuna siri inayoandikwa kwenye `SharedPreferences`
/// wala kwenye Hive. SharedPreferences ni XML ya wazi — root tu au backup ya
/// `adb` inaweza kuisoma. Tokens na PIN huhifadhiwa kwenye KeyStore (Android)
/// / Keychain (iOS) pekee.
library;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_config.dart';
import '../../config/constants/api_constants.dart';
import '../../config/constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../network/api_interceptors.dart';
import 'local_storage.dart';

// ---------------------------------------------------------------------------
// Thamani (value objects)
// ---------------------------------------------------------------------------

/// Jozi ya tokens zilizopatikana baada ya kuingia.
///
/// Huhifadhiwa kama thamani moja ili `saveTokens` isiweze kuacha access token
/// mpya na refresh token ya zamani (kitu kinachotokea kirahisi sana tunapoweka
/// funguo mbili tofauti kwenye sehemu mbili za code).
class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
  });

  /// Token ya kila ombi (`Authorization: Bearer ...`).
  final String accessToken;

  /// Token ya kuhuisha (refresh). Hufanya kazi mara moja tu kwenye seva
  /// (refresh token rotation).
  final String refreshToken;

  /// Muda ambao [accessToken] inaisha. Inaweza kuwa `null` kama seva
  /// haikutuma `expires_in` — wakati huo tunaamini 401 kama alama pekee.
  final DateTime? expiresAt;

  /// `true` kama kuna refresh token (yaani mtumiaji anaweza kuhuishwa).
  bool get hasRefreshToken => refreshToken.isNotEmpty;

  /// `true` kama access token imeisha muda kwa saa ya kifaa.
  ///
  /// TANBIHI: saa ya kifaa kwenye simu za bei nafuu huharibika mara nyingi
  /// (mtumiaji hubadilisha tarehe kwa mkono). Kwa hivyo jibu la `true` hapa
  /// linapaswa kutumika kama **kidokezo** cha kuhuisha mapema — si kama
  /// uthibitisho kwamba seva itakataa token. Seva ndiyo mamlaka ya mwisho.
  bool isExpired({DateTime? now}) {
    final expiry = expiresAt;
    if (expiry == null) return false;
    return !(now ?? DateTime.now()).isBefore(expiry);
  }

  /// Muda uliobaki kabla ya [accessToken] kuisha (hasi kama imeisha).
  Duration? timeToExpiry({DateTime? now}) {
    final expiry = expiresAt;
    if (expiry == null) return null;
    return expiry.difference(now ?? DateTime.now());
  }

  /// `true` kama token itaisha ndani ya [window].
  ///
  /// Hutumika kuhuisha kabla ya ombi (proactive refresh) ili mtumiaji
  /// asikute 401 katikati ya kusoma hadithi.
  bool expiresWithin(Duration window, {DateTime? now}) {
    final remaining = timeToExpiry(now: now);
    if (remaining == null) return false;
    return remaining <= window;
  }

  /// **Hakuna token inayoonekana hapa.** `toString` ya class hii inaweza
  /// kuishia kwenye log ya kosa (mfano `logger.e('$e')`) — kama tungeandika
  /// tokens, siri zingeandikwa kwenye crash log ya Sentry.
  @override
  String toString() => 'AuthTokens(accessToken: ***, refreshToken: ***, '
      'expiresAt: $expiresAt)';
}

/// Hali ya jaribio la PIN ya mzazi.
enum PinVerification {
  /// PIN ni sahihi.
  success,

  /// PIN si sahihi, lakini bado anaweza kujaribu tena.
  wrongPin,

  /// Majaribio mengi yameshindwa — PIN imefungwa kwa muda.
  lockedOut,

  /// PIN ya mzazi haijawekwa bado.
  notSet;

  /// `true` kama mtumiaji anaweza kuendelea.
  bool get isSuccess => this == PinVerification.success;
}

/// Matokeo ya [SecureStorage.verifyParentalPin].
///
/// Huhifadhi **jinsi** ukaguzi ulivyoshindwa, na si `bool` tu — screen ya
/// udhibiti wa mzazi inahitaji kujua kama imebaki majaribio mangapi
/// (`attemptsRemaining`) au asubiri muda gani (`lockedFor`) ili kuonyesha
/// ujumbe unaofaa badala ya "PIN si sahihi" isiyosaidia.
class PinCheckResult {
  const PinCheckResult._(
    this.status, {
    this.attemptsRemaining,
    this.lockedFor,
  });

  /// PIN ni sahihi.
  const PinCheckResult.success() : this._(PinVerification.success);

  /// PIN si sahihi — [attemptsRemaining] ni majaribio yaliyobaki.
  const PinCheckResult.wrongPin({required int attemptsRemaining})
      : this._(
          PinVerification.wrongPin,
          attemptsRemaining: attemptsRemaining,
        );

  /// PIN imefungwa kwa muda — [lockedFor] ni muda uliobaki.
  const PinCheckResult.lockedOut({required Duration lockedFor})
      : this._(PinVerification.lockedOut, lockedFor: lockedFor);

  /// PIN haijawekwa bado.
  const PinCheckResult.notSet() : this._(PinVerification.notSet);

  final PinVerification status;

  /// Majaribio yaliyobaki kabla ya kufungwa (`null` kama PIN si sahihi tu).
  final int? attemptsRemaining;

  /// Muda uliobaki wa kufungwa (`null` kama haijafungwa).
  final Duration? lockedFor;

  /// `true` kama mtumiaji anaweza kuendelea.
  bool get isSuccess => status.isSuccess;

  @override
  String toString() => 'PinCheckResult($status, '
      'attemptsRemaining: $attemptsRemaining, lockedFor: $lockedFor)';
}

// ---------------------------------------------------------------------------
// Mkataba
// ---------------------------------------------------------------------------

/// Mkataba wa hifadhi salama (ili tuweze kuweka fake kwenye tests).
abstract class SecureStorage {
  // ── Tokens ───────────────────────────────────────────────────
  /// Huhifadhi tokens zote mbili kwa wakati mmoja.
  Future<void> saveTokens(AuthTokens tokens);

  /// Tokens zilizohifadhiwa, au `null` kama mtumiaji hajaingia.
  Future<AuthTokens?> readTokens();

  /// Access token pekee (hutumika kwenye kila ombi).
  Future<String?> accessToken();

  /// `true` kama kuna kikao kinachoweza kutumika.
  Future<bool> hasSession();

  /// Kufuta tokens (kutoka kwenye akaunti, au kikao kimeisha).
  Future<void> clearTokens();

  // ── PIN ya mzazi ─────────────────────────────────────────────
  /// `true` kama PIN ya mzazi imewekwa.
  Future<bool> hasParentalPin();

  /// Huhifadhi PIN ya mzazi (baada ya kuithibitisha mara mbili kwenye UI).
  Future<void> setParentalPin(String pin);

  /// Hukagua PIN, ikijumuisha kikomo cha majaribio.
  Future<PinCheckResult> verifyParentalPin(String pin);

  /// Muda uliobaki wa kufungwa kwa PIN, au `null` kama haijafungwa.
  Future<Duration?> parentalPinLockRemaining();

  /// Kufuta PIN (mfano mzazi amesahau — baada ya uthibitisho wa namba ya simu).
  Future<void> clearParentalPin();

  // ── Kifaa ────────────────────────────────────────────────────
  /// Kitambulisho cha kifaa (UUID v4) — hutengenezwa mara moja na huhifadhiwa.
  Future<String> deviceId();

  /// Kufuta kila kitu kwenye hifadhi salama.
  Future<void> clearAll();
}

// ---------------------------------------------------------------------------
// Utekelezaji
// ---------------------------------------------------------------------------

/// Chaguo za Android kwa `flutter_secure_storage`.
///
/// `encryptedSharedPreferences: true` hutumia `EncryptedSharedPreferences` ya
/// AndroidX badala ya SharedPreferences ya kawaida inayofungwa kwa RSA pekee.
/// Hii ni muhimu kwa Tanzania: kwenye simu nyingi za Android 6–9, watumiaji
/// huruhusu backup, na SharedPreferences ya wazi inaweza kuvuja kwenye faili ya
/// backup. Kwenye `flutter_secure_storage` v10 chaguo hili ni la kawaida
/// (kwa hivyo linatoweka), lakini kwa v9 (toleo la project hii) linahitajika.
const AndroidOptions _androidOptions =
    AndroidOptions(encryptedSharedPreferences: true);

/// Chaguo za iOS/macOS.
///
/// `first_unlock_this_device` inamaanisha: token inasomwa baada ya mtumiaji
/// kufungua simu mara ya kwanza (kwa hivyo arifa za push zinazofika kabla ya
/// kufungua zinaweza kuthibitishwa), na **haisawazishwi** kwenye iCloud wala
/// kwenye vifaa vingine vya mtumiaji — tokens ni za kifaa hiki tu.
const IOSOptions _iosOptions = IOSOptions(
  accessibility: KeychainAccessibility.first_unlock_this_device,
);

/// Utekelezaji wa [SecureStorage] kwa `flutter_secure_storage`.
class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: _androidOptions,
              iOptions: _iosOptions,
            );

  final FlutterSecureStorage _storage;

  /// Kumbukumbu ya device ID kwa kikao hiki.
  ///
  /// `HeadersInterceptor` huita `deviceId()` kwenye **kila** ombi. Kusoma
  /// KeyStore kila ombi ni polepole kwenye simu za bei nafuu (10–40 ms), na
  /// ni kazi isiyo na maana kwani device ID haibadiliki kamwe. Kwa hivyo
  /// tunaisoma mara moja na kuihifadhi kwenye memory.
  String? _cachedDeviceId;

  // -------------------------------------------------------------------------
  // Tokens
  // -------------------------------------------------------------------------

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await _write(StorageKeys.accessToken, tokens.accessToken);
    await _write(StorageKeys.refreshToken, tokens.refreshToken);

    final expiry = tokens.expiresAt;
    if (expiry == null) {
      // Seva haikutuma muda wa kuisha — tunaondoa thamani ya zamani ili
      // `isExpired` isisome muda wa token iliyotangulia (hii ingefanya app
      // ihuisha mapema kila wakati bila sababu).
      await _delete(StorageKeys.tokenExpiry);
    } else {
      await _write(StorageKeys.tokenExpiry, expiry.toIso8601String());
    }
  }

  @override
  Future<AuthTokens?> readTokens() async {
    final access = await _read(StorageKeys.accessToken);
    if (access == null || access.isEmpty) return null;

    return AuthTokens(
      accessToken: access,
      refreshToken: await _read(StorageKeys.refreshToken) ?? '',
      expiresAt: await _readTokenExpiry(),
    );
  }

  @override
  Future<String?> accessToken() => _read(StorageKeys.accessToken);

  @override
  Future<bool> hasSession() async {
    final token = await _read(StorageKeys.accessToken);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearTokens() async {
    await _delete(StorageKeys.accessToken);
    await _delete(StorageKeys.refreshToken);
    await _delete(StorageKeys.tokenExpiry);
  }

  /// Husoma `tokenExpiry` kwa uvumilivu.
  ///
  /// `DateTime.tryParse` hurudisha `null` kama thamani iliyohifadhiwa
  /// imeharibika — kwa hivyo kosa la kuandika hakuangushi app.
  Future<DateTime?> _readTokenExpiry() async {
    final raw = await _read(StorageKeys.tokenExpiry);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  // -------------------------------------------------------------------------
  // PIN ya mzazi
  // -------------------------------------------------------------------------

  @override
  Future<bool> hasParentalPin() async {
    final pin = await _read(StorageKeys.parentalPin);
    return pin != null && pin.isNotEmpty;
  }

  /// Huhifadhi PIN mpya.
  ///
  /// **Kwa nini PIN haihifadhiwi kama hash:** hashing sahihi inahitaji
  /// `package:crypto` au `bcrypt`, ambayo **haipo** kwenye `pubspec.yaml` ya
  /// project hii. Kwa sasa tunategemea usimbaji fiche wa OS (KeyStore /
  /// Keychain) — ambayo ni bora kuliko kuandika "hash" ya mkono
  /// (mfano `pin.hashCode`) inayoonekana kama usalama lakini haistahimili
  /// shambulizi lolote la haraka. Angalia TODO kwenye `_verifyPinValue`.
  ///
  /// Ukaguzi wa urefu/sifa hufanywa hapa kama **ulindi wa mwisho** kwenye
  /// ukingo wa hifadhi: `Validators` inamiliki ukaguzi wa form (na ujumbe wa
  /// Kiswahili/English kwa mtumiaji), lakini `SecureStorage` haipaswi
  /// kuruhusu PIN ya tarakimu 2 kuingia hata kama UI ilikosea.
  @override
  Future<void> setParentalPin(String pin) async {
    if (pin.length != AppConstants.parentalPinLength ||
        int.tryParse(pin) == null) {
      throw ValidationException(
        'PIN ya mzazi lazima iwe tarakimu '
        '${AppConstants.parentalPinLength}.',
        code: 'PARENTAL_PIN_FORMAT',
      );
    }

    await _write(StorageKeys.parentalPin, pin);
    // PIN mpya huanza na rekodi safi ya majaribio — bila hii, mzazi
    // angebadilisha PIN yake na kubaki amefungwa kwa sababu ya majaribio ya
    // mtoto kwenye PIN ya zamani.
    await _delete(StorageKeys.parentalPinAttempts);
    await _delete(StorageKeys.parentalPinLockedUntil);
  }

  @override
  Future<PinCheckResult> verifyParentalPin(String pin) async {
    final stored = await _read(StorageKeys.parentalPin);
    if (stored == null || stored.isEmpty) return const PinCheckResult.notSet();

    // 1. Kama imefungwa, hakuna jaribio linalokubaliwa — hata PIN sahihi.
    //    (Bila hii, mtoto angeweza kuendelea kujaribu na mapengo ya kufungwa
    //    yasingekuwa na maana.)
    final remainingLock = await parentalPinLockRemaining();
    if (remainingLock != null) {
      return PinCheckResult.lockedOut(lockedFor: remainingLock);
    }

    // 2. Ukaguzi wa PIN yenyewe.
    if (_verifyPinValue(stored, pin)) {
      await _delete(StorageKeys.parentalPinAttempts);
      await _delete(StorageKeys.parentalPinLockedUntil);
      return const PinCheckResult.success();
    }

    // 3. Kosa — hesabu na uamue kama imefikia kikomo.
    final attempts = (await _readInt(StorageKeys.parentalPinAttempts)) + 1;

    if (attempts >= AppConstants.parentalPinMaxAttempts) {
      final lockedUntil =
          DateTime.now().add(AppConstants.parentalPinLockoutDuration);
      await _write(
        StorageKeys.parentalPinLockedUntil,
        lockedUntil.toIso8601String(),
      );
      // Tunaweka rekodi ya majaribio kama yalivyofikia kikomo ili
      // `parentalPinLockRemaining` iseme "majaribio yameisha" (na si "bado
      // una majaribio") pindi kufungwa kumalizika bila PIN kupulizwa.
      await _writeInt(StorageKeys.parentalPinAttempts, attempts);
      return PinCheckResult.lockedOut(
        lockedFor: AppConstants.parentalPinLockoutDuration,
      );
    }

    await _writeInt(StorageKeys.parentalPinAttempts, attempts);
    return PinCheckResult.wrongPin(
      attemptsRemaining: AppConstants.parentalPinMaxAttempts - attempts,
    );
  }

  /// Hulinganisha PIN.
  ///
  /// TODO(usalama): weka `package:crypto` kisha hifadhi
  /// `sha256(salt + pin)` pamoja na `salt` ya nasibu, na hulinganishe hash —
  /// si PIN yenyewe. Hii inaongeza ulinzi ikiwa hifadhi salama ya OS
  /// itavuja. Hadi hapo, usimbaji fiche wa KeyStore/Keychain ndiyo ulinzi.
  bool _verifyPinValue(String stored, String candidate) {
    // Ulinganisho wa urefu wa kwanza — huzuia `==` kuona "12" na "1200"
    // kama sawa kimakosa kwenye baadhi ya mifumo iliyoharibika.
    if (stored.length != candidate.length) return false;
    return stored == candidate;
  }

  @override
  Future<Duration?> parentalPinLockRemaining() async {
    final raw = await _read(StorageKeys.parentalPinLockedUntil);
    if (raw == null || raw.isEmpty) return null;

    final until = DateTime.tryParse(raw);
    if (until == null) return null;

    final remaining = until.difference(DateTime.now());
    if (remaining.isNegative || remaining == Duration.zero) {
      // Kufungwa kumemalizika — tunasafisha sasa hivi ili kufungwa kusijaeanza
      // tena bila sababu, na ili majaribio yaanze upya kutoka sifuri.
      await _delete(StorageKeys.parentalPinLockedUntil);
      await _delete(StorageKeys.parentalPinAttempts);
      return null;
    }
    return remaining;
  }

  @override
  Future<void> clearParentalPin() async {
    await _delete(StorageKeys.parentalPin);
    await _delete(StorageKeys.parentalPinAttempts);
    await _delete(StorageKeys.parentalPinLockedUntil);
  }

  // -------------------------------------------------------------------------
  // Kifaa
  // -------------------------------------------------------------------------

  @override
  Future<String> deviceId() async {
    final cached = _cachedDeviceId;
    if (cached != null) return cached;

    final existing = await _read(StorageKeys.deviceId);
    if (existing != null && existing.isNotEmpty) {
      _cachedDeviceId = existing;
      return existing;
    }

    final generated = const Uuid().v4();
    _cachedDeviceId = generated;

    try {
      await _write(StorageKeys.deviceId, generated);
    } on SecureStorageException {
      // Kushindwa kuhifadhi device ID **hakuachi** app kufanya kazi: ombi
      // linaweza kwenda bila header ya `X-Device-Id`. Kwa hivyo tunairudisha
      // kwa kikao hiki (itakuwa tofauti baada ya kufungua app tena, jambo
      // ambalo ni kubwa kuliko kuvunja kila ombi).
    }

    return generated;
  }

  // -------------------------------------------------------------------------
  // Kusafisha
  // -------------------------------------------------------------------------

  @override
  Future<void> clearAll() async {
    _cachedDeviceId = null;
    try {
      await _storage.deleteAll();
    } catch (error) {
      if (_isKeystoreCorruption(error)) {
        // Hifadhi yenyewe imeharibika — "kufuta" ndiyo tiba. Tazama
        // `_recoverFromCorruption`.
        await _recoverFromCorruption();
        return;
      }
      throw SecureStorageException(
        'Imeshindwa kufuta hifadhi salama.',
        code: 'SECURE_WIPE_FAILED',
        cause: error,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Msingi — read / write / delete
  // -------------------------------------------------------------------------

  Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (error) {
      if (_isKeystoreCorruption(error)) {
        // Kwenye Android, KeyStore inaweza kuharibika baada ya mtumiaji
        // kubadilisha PIN/lock screen ya kifaa — maandishi yaliyofichwa
        // hayafunguki tena **kamwe**. Tukirusha kosa hapa, mtumiaji
        // angekwama kwenye skrini ya kosa kila anapofungua app, bila njia ya
        // kutoka. Kwa hivyo tunatupa siri zisizosomwa (mtumiaji anaingia
        // tena) — hasara ni login moja, si app iliyovunjika.
        await _recoverFromCorruption();
        return null;
      }
      throw SecureStorageException(
        'Imeshindwa kusoma "$key" kwenye hifadhi salama.',
        code: 'SECURE_READ_FAILED',
        cause: error,
      );
    }
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (error) {
      if (_isKeystoreCorruption(error)) {
        // Jaribio moja baada ya kusafisha: kwenye Android, kufuta
        // EncryptedSharedPreferences husababisha KeyStore kuundwa upya, na
        // kuandika mara ya pili hufanikiwa. Bila jaribio hili, mtumiaji
        // angeingia tena kisha apate kosa tena kwenye kuandika token.
        await _recoverFromCorruption();
        try {
          await _storage.write(key: key, value: value);
          return;
        } catch (retryError) {
          throw SecureStorageException(
            'Imeshindwa kuhifadhi "$key" kwenye hifadhi salama.',
            code: 'SECURE_WRITE_FAILED',
            cause: retryError,
          );
        }
      }
      throw SecureStorageException(
        'Imeshindwa kuhifadhi "$key" kwenye hifadhi salama.',
        code: 'SECURE_WRITE_FAILED',
        cause: error,
      );
    }
  }

  Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (error) {
      if (_isKeystoreCorruption(error)) {
        // Kufuta kitu ambacho hakisomwi: kusafisha hifadhi yote kunatimiza
        // lengo lile lile, kwa hivyo hatuna sababu ya kurusha kosa.
        await _recoverFromCorruption();
        return;
      }
      throw SecureStorageException(
        'Imeshindwa kufuta "$key" kwenye hifadhi salama.',
        code: 'SECURE_DELETE_FAILED',
        cause: error,
      );
    }
  }

  /// Husoma `int` iliyohifadhiwa kama string (secure storage huhifadhi string
  /// pekee).
  Future<int> _readInt(String key) async {
    final raw = await _read(key);
    if (raw == null || raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  Future<void> _writeInt(String key, int value) =>
      _write(key, value.toString());

  /// Hutambua kosa la KeyStore iliyoharibika.
  ///
  /// **Kwa nini hatusafishi hifadhi kwa kila kosa:** kusafisha hifadhi
  /// kunafuta tokens — yaani kumfukuza mtumiaji. Kama tutafanya hivyo kwa
  /// kosa la muda (mfano kifaa kiko chini ya shinikizo la kumbukumbu), app
  /// ingemfukuza mtumiaji bila sababu. Kwa hivyo tunatambua **dalili za
  /// kuharibika** pekee (ufunguzi ulioshindwa), na kosa lolote lingine
  /// linarushwa juu ili UI iweze kuonyesha "jaribu tena".
  ///
  /// Dalili zinazotambulika (kutoka `flutter_secure_storage` / AndroidX):
  /// `BadPaddingException`, `InvalidKeyException`, `AEADBadTagException`,
  /// na `KeyStoreException`. Vilevile `PlatformException` yenye code hizi.
  bool _isKeystoreCorruption(Object error) {
    if (error is! PlatformException) return false;

    final haystack = '${error.code} ${error.message ?? ''}'.toLowerCase();
    return haystack.contains('badpadding') ||
        haystack.contains('bad padding') ||
        haystack.contains('aeadbad') ||
        haystack.contains('invalidkey') ||
        haystack.contains('invalid key') ||
        haystack.contains('keystore') ||
        haystack.contains('key store');
  }

  /// Husafisha hifadhi salama baada ya kuharibika.
  ///
  /// Huvumilia kushindwa: `deleteAll` yenyewe inaweza kurusha kosa lile lile
  /// kwenye KeyStore iliyoharibika kabisa. Kutupa kosa hapa kungezuia
  /// `_read` kurudisha `null`, na mtumiaji angekwama — kwa hivyo tunasonga
  /// mbele (hifadhi ipo tayari katika hali isiyoweza kusomwa).
  Future<void> _recoverFromCorruption() async {
    _cachedDeviceId = null;
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Tazama maelezo hapo juu — kushindwa hakubadilishi kitu.
    }
  }
}

// ---------------------------------------------------------------------------
// AuthTokenProvider — utekelezaji halisi
// ---------------------------------------------------------------------------

/// Hutekeleza [AuthTokenProvider] kwa kutumia [SecureStorage].
///
/// **Kwa nini faili hii ina `Dio` yake yenyewe:** kuhuisha token kunahitaji
/// ombi la HTTP, lakini `Dio` kuu linahitaji [AuthTokenProvider] ili
/// liundwe (`DioFactory.create`). Kudai `Dio` kuu hapa kungeunda mzunguko
/// usioweza kutengana. Kwa hivyo tunatumia Dio **nyepesi** isiyo na
/// interceptors zozote: `AuthInterceptor` haipo, kwa hivyo 401 kwenye refresh
/// haiwezi kuanzisha refresh nyingine (mzunguko usioisha).
///
/// Pili, ombi la refresh haliwezi kuingia kwenye `RetryInterceptor` — kurudia
/// refresh kwa mkono baada ya muda kunaweza kutumia refresh token iliyotumika
/// tayari (rotation), jambo ambalo hufuta kikao kizima.
class SecureAuthTokenProvider implements AuthTokenProvider {
  SecureAuthTokenProvider({
    required SecureStorage storage,
    Dio? refreshClient,
    Future<void> Function()? onSessionExpired,
  })  : _storage = storage,
        _onSessionExpired = onSessionExpired,
        _refreshClient = refreshClient ?? _buildRefreshClient();

  /// Huunda Dio nyepesi ya refresh ikiwa hakuna iliyotolewa.
  ///
  /// **Kwa nini ni static method na si cascade ndani ya initializer list:**
  /// kwenye Dart, cascade (`..`) ina kiwango cha chini kuliko `??`, hivyo
  /// `client ?? Dio(...)..options.headers.addAll(...)` ingeweza
  /// kufasiriwa kama `(client ?? Dio(...))..options...` — yaani **kubadilisha
  /// Dio ya mwito** (pamoja na headers zake) wakati mtumiaji alipitisha yake.
  /// Kutenganisha kwenye method yake kunafanya hili lisitokee kamwe.
  static Dio _buildRefreshClient() {
    return Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        contentType: ApiConstants.contentTypeJson,
        responseType: ResponseType.json,
        // Tunataka 4xx kurusha `DioException` ili tuweze kutofautisha
        // "refresh token imekataliwa" (kikao kimeisha) na "mtandao umekatika"
        // (kikao bado kipo) — tazama `_performRefresh`.
        validateStatus: (status) =>
            status != null && status >= 200 && status < 300,
      ),
    )..options.headers.addAll(<String, dynamic>{
        ApiConstants.headerAccept: ApiConstants.contentTypeJson,
        ApiConstants.headerAppVersion: AppConfig.buildNumber,
        ApiConstants.headerPlatform: AppConfig.platform,
        ApiConstants.headerClient: AppConfig.clientIdentifier,
      });
  }

  final SecureStorage _storage;
  final Dio _refreshClient;
  final Future<void> Function()? _onSessionExpired;

  /// Refresh inayoendelea — huzuia refresh mbili kwa wakati mmoja.
  Future<String?>? _refreshInFlight;

  @override
  Future<String?> accessToken() {
    // Usomaji mtupu — **hauhuishi** token hata kama imeisha muda.
    //
    // **Kwa nini:** kuhuisha hapa kungesababisha njia ya pili ya refresh
    // ambayo `AuthInterceptor` (QueuedInterceptorsWrapper) haijui. Refresh
    // mbili zinazoshindana kwa refresh token inayobadilika kila matumizi
    // (=rotation) hufuta moja nyingine, na mtumiaji anafukuzwa bila sababu.
    // Kuhuisha ni jukumu la `AuthInterceptor` (baada ya 401) — au la
    // `refreshAccessToken()` inayoitwa kwa makusudi (mfano kwenye splash,
    // kwa kutumia `AuthTokens.expiresWithin`).
    return _storage.accessToken();
  }

  /// Huhuisha access token.
  ///
  /// Hurudisha token mpya ikifanikiwa, au `null` kama refresh haikuwezekana.
  ///
  /// **Tofauti muhimu:** `null` haimaanishi kikao kimeisha. Kama refresh
  /// ilishindwa kwa sababu ya **mtandao**, kikao kinabaki (mtumiaji aliye
  /// kwenye basi anapitia mahali pasipo mtandao mara kwa mara — kumfukuza
  /// kila mara kungekuwa kosa kubwa). Kikao hufutwa **tu** pale seva
  /// inapokataa refresh token yenyewe (400/401/403).
  @override
  Future<String?> refreshAccessToken() async {
    // Ulinzi wa ziada (belt-and-braces): foleni ya `QueuedInterceptorsWrapper`
    // inazuia refresh mbili kutoka kwenye `AuthInterceptor`, lakini njia hii
    // inaweza kuitwa pia moja kwa moja (mfano `SplashCubit`). Kwa kushiriki
    // `Future` moja, wito wote hupata jibu lile lile badala ya refresh mbili.
    final inFlight = _refreshInFlight;
    if (inFlight != null) return inFlight;

    final future = _performRefresh();
    _refreshInFlight = future;
    try {
      return await future;
    } finally {
      _refreshInFlight = null;
    }
  }

  @override
  Future<void> onUnauthorized() async {
    await _storage.clearTokens();
    await _notifySessionExpired();
  }

  /// Hufanya ombi la refresh.
  Future<String?> _performRefresh() async {
    final AuthTokens? stored;
    try {
      stored = await _storage.readTokens();
    } on SecureStorageException {
      return null;
    }

    final refresh = stored?.refreshToken;
    if (refresh == null || refresh.isEmpty) {
      // Hakuna refresh token — kikao hakiwezi kuhuishwa.
      await _invalidateSession();
      return null;
    }

    final Response<Map<String, dynamic>> response;
    try {
      response = await _refreshClient.post<Map<String, dynamic>>(
        AuthEndpoints.refreshToken,
        data: <String, dynamic>{'refresh_token': refresh},
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      if (status != null && _isRejection(status)) {
        // Seva ilikataa refresh token — kikao kweli kimeisha.
        await _invalidateSession();
        return null;
      }
      // Mtandao/timeout/5xx — kikao **kinabaki**. Tunarudisha `null` ili ombi
      // la sasa lishindwe kwa upole, lakini mtumiaji hafungwi nje.
      return null;
    } catch (_) {
      // Kosa lisilotarajiwa (mfano URL isiyo sahihi kwenye build ya dev).
      // Kikao kinabaki — tunashindwa kwa upole.
      return null;
    }

    final body = response.data;
    if (body == null) return null;

    final payload = _unwrap(body);
    final access =
        _string(payload, <String>['access_token', 'accessToken', 'token']);
    if (access == null || access.isEmpty) return null;

    // Seva inaweza au isibadilishe refresh token. Kama haikutuma mpya,
    // tunaendelea na ile ile — kuandika `''` hapa kungeharibu kikao.
    final rotated =
        _string(payload, <String>['refresh_token', 'refreshToken']) ?? refresh;

    try {
      await _storage.saveTokens(
        AuthTokens(
          accessToken: access,
          refreshToken: rotated,
          expiresAt: _expiresAt(payload),
        ),
      );
    } on SecureStorageException {
      // Tumeshapata token, lakini hatukuweza kuhifadhi. Tunairudisha bado —
      // ombi la sasa linaweza kufanikiwa; la baadaye litahuisha tena.
      return access;
    }

    return access;
  }

  /// `true` kama status inamaanisha refresh token ilikataliwa kabisa.
  ///
  /// 400 pia inahesabiwa: baadhi ya seva hurudisha 400 kwa body yenye
  /// `grant_type`/`refresh_token` isiyo sahihi badala ya 401.
  bool _isRejection(int status) =>
      status == ApiConstants.statusBadRequest ||
      status == ApiConstants.statusUnauthorized ||
      status == ApiConstants.statusForbidden;

  /// Hufuta tokens na kumjulisha msikilizaji.
  Future<void> _invalidateSession() async {
    try {
      await _storage.clearTokens();
    } on SecureStorageException {
      // Tunaendelea — lengo ni kumfukuza mtumiaji, na hilo linawezekana hata
      // kama kufuta kumeshindwa kwenye disk.
    }
    await _notifySessionExpired();
  }

  /// Humwita msikilizaji (mfano router → skrini ya kuingia).
  ///
  /// Kushindwa kwake huzuiwa: msikilizaji anayetupa kosa asivunje ombi la
  /// mtandao lililokuwa linaendelea. Hii inafuata kanuni ile ile iliyowekwa
  /// kwenye `AuthInterceptor._notifyUnauthorized`.
  Future<void> _notifySessionExpired() async {
    try {
      await _onSessionExpired?.call();
    } catch (_) {
      // Tazama maelezo hapo juu.
    }
  }

  /// Husoma muda wa kuisha kutoka jibu.
  ///
  /// Seva hutuma aidha `expires_in` (sekunde, namba) au `expires_at`
  /// (ISO-8601). Tunavumilia zote mbili — na pia `expires_in` iliyotumwa kama
  /// string, kitu kinachotokea kwenye backend zilizojengwa kwa PHP.
  DateTime? _expiresAt(Map<String, dynamic> payload) {
    final absolute = _string(payload, <String>['expires_at', 'expiresAt']);
    if (absolute != null) return DateTime.tryParse(absolute);

    final raw = payload['expires_in'] ?? payload['expiresIn'];
    final seconds = raw is int ? raw : (raw is String ? int.tryParse(raw) : null);
    if (seconds == null || seconds <= 0) return null;

    return DateTime.now().add(Duration(seconds: seconds));
  }

  /// Huvua envelope: `{"data": {...}}` → `{...}`.
  Map<String, dynamic> _unwrap(Map<String, dynamic> body) {
    final nested = body['data'];
    if (nested is Map) return Map<String, dynamic>.from(nested);
    return body;
  }

  /// Hurudisha string ya kwanza isiyo tupu kati ya [keys].
  String? _string(Map<String, dynamic> body, List<String> keys) {
    for (final key in keys) {
      final value = body[key];
      if (value is String && value.isNotEmpty) return value;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// RequestContext — utekelezaji halisi
// ---------------------------------------------------------------------------

/// Hutekeleza [RequestContext] kwa kuunganisha vyanzo viwili:
///
/// | Kinachohitajika | Chanzo            | Kwa nini hapo                  |
/// |-----------------|-------------------|--------------------------------|
/// | `deviceId()`    | [SecureStorage]   | UUID ya kifaa ni siri ya kifaa |
/// | `languageCode()`| [LocalStorage]    | Lugha ni mipangilio ya mtumiaji|
///
/// Vyanzo hivi viwili vimewekwa pamoja hapa kwa sababu `HeadersInterceptor`
/// inahitaji **vyote kwa ombi moja** — kutenganisha kungeunda class mbili
/// zinazoitwa pamoja kila wakati.
class AppRequestContext implements RequestContext {
  AppRequestContext({
    required SecureStorage secureStorage,
    required LocalStorage localStorage,
  })  : _secureStorage = secureStorage,
        _localStorage = localStorage;

  final SecureStorage _secureStorage;
  final LocalStorage _localStorage;

  @override
  Future<String> deviceId() => _secureStorage.deviceId();

  @override
  String languageCode() => _localStorage.language.code;
}
