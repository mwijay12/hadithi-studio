/// CACHE MANAGER — faili za picha, sauti na hadithi zilizopakuliwa.
///
/// **Mgawanyo wa kazi kati ya faili tatu za `core/storage/`:**
///
/// | Faili                | Huhifadhi nini                        | Zinaishi wapi        |
/// |----------------------|---------------------------------------|----------------------|
/// | `local_storage.dart` | mipangilio na mapendeleo              | SharedPreferences + Hive |
/// | `secure_storage.dart`| tokens, PIN, device ID (siri)         | FlutterSecureStorage |
/// | `cache_manager.dart` | faili (picha, sauti, hadithi)         | filesystem           |
///
/// **Sababu ya kuwepo:** Tanzania ina data ya bei ghali na mtandao wa 2G/3G.
/// Mtumiaji anayepakua hadithi moja mara moja na kuisoma tena wiki tatu
/// baadaye **hapaswi** kulipa data tena. Bila cache ya faili, kila kusoma
/// kungekuwa upakuaji mpya.
///
/// **Kwa nini index ipo kwenye faili ya JSON na si kwenye Hive:** spec §6.3
/// inatoa Hive boxes kwa **maudhui** (hadithi, picha, sauti) — si kwa
/// metadata ya cache. Kuweka index ya cache kwenye box lile lile kungeunda
/// mgongano wa funguo na maudhui halisi. Faili ya `.index.json` kwenye folda
/// ya kila kategoria inaepusha hilo, na inafanya `reconcile()` kuwa rahisi:
/// hifadhi na index zinaishi mahali pamoja, hivyo kufuta folda kunafuta vyote.
library;

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../errors/exceptions.dart';
import '../utils/formatters.dart';
import '../utils/image_utils.dart';
import '../utils/audio_utils.dart';

// ---------------------------------------------------------------------------
// Kategoria
// ---------------------------------------------------------------------------

/// Makundi ya faili yanayohifadhiwa kwenye kifaa.
///
/// Majina haya ni ya **ndani** (folda kwenye disk), si maandishi ya UI: kwa
/// UI tumia keys za ARB. Kwa hivyo hakuna `labelSw`/`labelEn` hapa — majina
/// ya folda hayaonekani kwa mtumiaji kamwe.
enum CacheCategory {
  /// Picha za hadithi (illustrations).
  illustrations,

  /// Sauti ya TTS iliyotengenezwa tayari.
  audio,

  /// Maandishi ya hadithi yaliyopakuliwa (JSON).
  stories;

  /// Jina la folda kwenye disk.
  String get folderName => name;

  /// Ukubwa wa juu wa kategoria hii kwa baiti (`null` = hakuna kikomo).
  ///
  /// Hii **haitoi** namba mpya — inarithi kutoka `AppImageUtils` na
  /// `AppAudioUtils` ili kubadilisha 120MB/200MB kufanyike mahali pamoja
  /// (`AppConstants`). Kurudia namba hapa ingesababisha kikomo kimoja
  /// kubadilika na kingine kikosekana.
  ///
  /// `stories` haina kikomo: maandishi ni madogo sana (hadithi ya kurasa 20
  /// ni ~30 KB, sawa na picha **moja**). Kikomo cha hadithi ni **muda** —
  /// tazama `AppConstants.offlineCacheExpiryDays` (siku 60 bila kusomwa).
  int? get limitBytes => switch (this) {
        CacheCategory.illustrations => AppImageUtils.cacheLimitBytes,
        CacheCategory.audio => AppAudioUtils.cacheLimitBytes,
        CacheCategory.stories => null,
      };
}

// ---------------------------------------------------------------------------
// Thamani (value objects)
// ---------------------------------------------------------------------------

/// Faili moja iliyohifadhiwa kwenye cache.
class CachedEntry {
  const CachedEntry({
    required this.key,
    required this.fileName,
    required this.bytes,
    required this.savedAt,
    required this.lastAccess,
  });

  /// Ufunguo thabiti uliotolewa na mwitaji (mfano URL ya picha).
  final String key;

  /// Jina la faili ndani ya folda ya kategoria (bila path).
  final String fileName;

  /// Ukubwa kwa baiti.
  final int bytes;

  /// Wakati faili iliandikwa.
  final DateTime savedAt;

  /// Wakati faili ilisomwa mara ya mwisho.
  ///
  /// Hili — na **si** [savedAt] — ndilo linaloamua kama faili imeisha muda:
  /// `AppConstants.offlineCacheExpiryDays` inasema "kama haijasomwa", na
  /// kufuta faili ambayo mtoto anaisoma kila siku ingekuwa kosa (tungetumia
  /// data ya familia tena kwa kitu ambacho tayari tulikuwa nacho).
  final DateTime lastAccess;

  /// `true` kama faili haijasomwa kwa siku [AppImageUtils.expiryDays].
  bool get isExpired => AppImageUtils.isExpired(lastAccess);

  /// Huhamisha [lastAccess] bila kuandika disk (disk huandikwa na mwitaji).
  CachedEntry touched([DateTime? at]) => CachedEntry(
        key: key,
        fileName: fileName,
        bytes: bytes,
        savedAt: savedAt,
        lastAccess: at ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'path': fileName,
        'bytes': bytes,
        'savedAt': savedAt.toIso8601String(),
        'lastAccess': lastAccess.toIso8601String(),
      };

  /// Husoma entry kwa uvumilivu.
  ///
  /// Index inaweza kuharibika (kifaa kimezimwa katikati ya kuandika). Kama
  /// `bytes` haipo, tunairudisha `0` badala ya kurusha — `reconcile()` itaipima
  /// upya kutoka kwenye faili yenyewe.
  static CachedEntry? fromJson(String key, Object? json) {
    if (json is! Map) return null;
    final fileName = json['path'];
    if (fileName is! String || fileName.isEmpty) return null;

    final savedAt = _parseDate(json['savedAt']) ?? DateTime.now();

    return CachedEntry(
      key: key,
      fileName: fileName,
      bytes: (json['bytes'] as num?)?.toInt() ?? 0,
      savedAt: savedAt,
      lastAccess: _parseDate(json['lastAccess']) ?? savedAt,
    );
  }

  static DateTime? _parseDate(Object? raw) =>
      raw is String ? DateTime.tryParse(raw) : null;

  @override
  String toString() => 'CachedEntry($key → $fileName, $bytes B)';
}

/// Takwimu za cache ya kategoria moja — hutumika kwenye skrini ya mipangilio.
class CacheStats {
  const CacheStats({
    required this.bytes,
    required this.fileCount,
    this.limitBytes,
  });

  final int bytes;
  final int fileCount;

  /// Kikomo (`null` = hakuna).
  final int? limitBytes;

  /// Sehemu ya kikomo iliyotumika (0.0–1.0), au `null` kama hakuna kikomo.
  double? get usedFraction {
    final limit = limitBytes;
    if (limit == null || limit <= 0) return null;
    final fraction = bytes / limit;
    // Tunakata kwa 1.0 kwa UI: "145%" haiongeza taarifa kwa mtumiaji.
    return fraction > 1 ? 1.0 : fraction;
  }

  /// Ukubwa uliotumika kama maandishi ("42.1 MB").
  String get formattedUsed => Formatters.fileSize(bytes);

  /// Kikomo kama maandishi ("120 MB"), au `null` kama hakuna.
  String? get formattedLimit {
    final limit = limitBytes;
    return limit == null ? null : Formatters.fileSize(limit);
  }

  /// Maandishi tayari kwa UI: "42.1 MB / 120 MB".
  String usageLabel() {
    final limit = limitBytes;
    if (limit == null) return formattedUsed;
    return Formatters.storageUsage(
      usedMb: bytes ~/ (1024 * 1024),
      totalMb: limit ~/ (1024 * 1024),
    );
  }
}

// ---------------------------------------------------------------------------
// Mkataba
// ---------------------------------------------------------------------------

/// Mkataba wa cache ya faili (ili tuweze kuweka fake kwenye tests).
abstract class CacheManager {
  /// Huandaa folda na kusoma index.
  Future<void> init();

  /// Path ya faili iliyohifadhiwa, au `null` kama haipo au imeisha muda.
  Future<String?> fileFor(CacheCategory category, String key);

  /// `true` kama faili ipo na haijaisha muda.
  Future<bool> contains(CacheCategory category, String key);

  /// Huhifadhi faili. Hurudisha path kamili.
  Future<String> save(
    CacheCategory category,
    String key,
    List<int> bytes, {
    required String fileName,
  });

  /// Huhifadhi picha kwa URL yake.
  Future<String> saveImage({required String url, required List<int> bytes});

  /// Huhifadhi sauti ya TTS kwa ufunguo wake.
  Future<String> saveAudio({required String key, required List<int> bytes});

  /// Huweka alama ya kusomwa (LRU) — huzuia faili inayosomwa kila siku
  /// kufutwa kama "haijasomwa".
  Future<void> touch(CacheCategory category, String key);

  /// Ukubwa wa kategoria kwa baiti.
  Future<int> bytesFor(CacheCategory category);

  /// Takwimu za kategoria (ukubwa, idadi, kikomo).
  Future<CacheStats> statsFor(CacheCategory category);

  /// Hufuta faili zilizopitwa na muda (siku `AppImageUtils.expiryDays`).
  /// Hurudisha idadi iliyofutwa.
  Future<int> removeWhereExpired({CacheCategory? category});

  /// Hufuta faili za zamani mpaka kategoria irudi chini ya kikomo chake.
  Future<void> evictIfNeeded(CacheCategory category);

  /// Hufuta kategoria yote.
  Future<void> clearCategory(CacheCategory category);

  /// Hufuta cache yote (mipangilio → "futa cache").
  Future<void> clearAll();

  /// Huandika index kwenye disk kama kuna mabadiliko yanayosubiri.
  Future<void> flush();
}

// ---------------------------------------------------------------------------
// Utekelezaji
// ---------------------------------------------------------------------------

/// Utekelezaji wa [CacheManager] kwa filesystem.
class CacheManagerImpl implements CacheManager {
  CacheManagerImpl({Future<Directory> Function()? rootProvider})
      : _rootProvider = rootProvider ?? getApplicationSupportDirectory;

  /// Hutoa folda ya msingi ya app.
  ///
  /// **Kwa nini `getApplicationSupportDirectory` na si
  /// `getTemporaryDirectory`:** Android huruhusiwa kufuta folda ya temp
  /// **wakati wowote** kifaa kinapokosa nafasi. Kwa app hii hilo lingemaanisha
  /// hadithi zilizopakuliwa zinatoweka kimya kimya — familia inasoma bila
  /// mtandao kisha kupata skrini tupu. Folda ya support (`filesDir`) ni ya
  /// app na haifutwi na mfumo. Inaruhusu pia mtumiaji kuifuta mwenyewe kupitia
  /// "Futa cache" — udhibiti uko kwa mtumiaji, si kwa Android.
  final Future<Directory> Function() _rootProvider;

  /// Folda yetu ndani ya folda ya app.
  static const String _rootFolder = 'hadithi_cache';

  /// Jina la faili ya index.
  static const String _indexFileName = '.index.json';

  /// Toleo la muundo wa index — kama tutabadilisha muundo, index ya zamani
  /// inapuuzwa badala ya kusomwa kimakosa.
  static const int _indexVersion = 1;

  /// Muda wa chini kati ya kuandika index.
  ///
  /// `touch()` huitwa kila ukurasa wa hadithi unaposomwa. Kuandika faili ya
  /// index kila ukurasa kungeongeza I/O isiyo na maana kwenye simu za 2GB RAM.
  /// Kwa kuandika mara moja kwa sekunde 5, tunaokoa I/O na kupoteza si zaidi
  /// ya sekunde 5 za usahihi wa `lastAccess` — jambo lisilo na athari, kwani
  /// kikomo ni siku 60.
  static const Duration _indexWriteThrottle = Duration(seconds: 5);

  final Map<CacheCategory, Map<String, CachedEntry>> _index =
      <CacheCategory, Map<String, CachedEntry>>{};

  final Map<CacheCategory, DateTime> _lastIndexWrite =
      <CacheCategory, DateTime>{};

  Directory? _root;
  bool _initialised = false;

  // -------------------------------------------------------------------------
  // Maisha ya app
  // -------------------------------------------------------------------------

  @override
  Future<void> init() async {
    if (_initialised) return;

    try {
      final base = await _rootProvider();
      _root = Directory('${base.path}/$_rootFolder');

      for (final category in CacheCategory.values) {
        final dir = Directory(_dirPathFor(category));
        if (!await dir.exists()) {
          // `recursive: true` huzalisha pia `_root` kama haipo — hivyo
          // hatuhitaji `create` ya pekee kwa folda ya juu.
          await dir.create(recursive: true);
        }

        _index[category] = await _readIndex(category);
        await _reconcile(category);
        // Baada ya reconcile, index inaweza kubadilika — tunaiandika ili
        // kuanza kwa app ijayo kusiwe na kazi ile ile ya kusafisha.
        await _writeIndex(category);
      }

      _initialised = true;
    } catch (error) {
      throw CacheException(
        'Imeshindwa kuandaa hifadhi ya faili.',
        code: 'CACHE_INIT_FAILED',
        cause: error,
      );
    }
  }

  /// Huhakikisha [init] ilifanyika.
  ///
  /// Kosa la wazi hapa linasaidia sana wakati wa kuendeleza app: bila hii,
  /// kila method ingeanguka na `Null check operator used on a null value`
  /// kwenye `_root!` — kosa lisilosema kitu cha maana.
  void _ensureReady() {
    if (!_initialised || _root == null) {
      throw const CacheException(
        'CacheManager haijaandaliwa. Ita `init()` kwenye DI kabla ya matumizi.',
        code: 'CACHE_NOT_READY',
      );
    }
  }

  /// Hupima upya index dhidi ya disk.
  ///
  /// Kazi mbili:
  /// 1. **Kufuta entries ambazo faili zao hazipo** — Android inaweza kufuta
  ///    data ya app ("Clear data") au mtumiaji anaweza kusafisha kwa
  ///    "Clear cache". Bila hatua hii, index ingeonyesha 90 MB wakati
  ///    faili hazipo kabisa, na mtumiaji asingeweza kupakua zaidi.
  /// 2. **Kuongeza faili zilizopo kwenye disk bila entry** — hii hufunika
  ///    index iliyoharibika au kupotea. Tunazipa ufunguo wa **jina la faili**
  ///    (hatuwezi kurudi kutoka hash kwenda URL ya asili), hivyo
  ///    `contains(url)` hazitazipata — lakini zinabaki **zinazoonekana** kwa
  ///    `bytesFor`, `clearAll` na `evictIfNeeded`. Bila hii, faili za yatima
  ///    (orphan) zingeendelea kula 120 MB bila mtu kuziona.
  Future<void> _reconcile(CacheCategory category) async {
    final dir = Directory(_dirPathFor(category));
    final entries = _index[category]!;

    final onDisk = <String, File>{};
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = _fileNameOf(entity.path);
      if (name == _indexFileName) continue;
      onDisk[name] = entity;
    }

    // 1. Ondoa entries ambazo faili zao hazipo.
    entries.removeWhere((_, entry) => !onDisk.containsKey(entry.fileName));

    // 2. Ongeza faili ambazo index haizijui.
    for (final pair in onDisk.entries) {
      if (entries.values.any((entry) => entry.fileName == pair.key)) continue;

      final modified = await _lastModified(pair.value);
      entries['__file__${pair.key}'] = CachedEntry(
        key: '__file__${pair.key}',
        fileName: pair.key,
        bytes: await pair.value.length(),
        savedAt: modified,
        lastAccess: modified,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Kusoma
  // -------------------------------------------------------------------------

  @override
  Future<String?> fileFor(CacheCategory category, String key) async {
    _ensureReady();

    final entry = _index[category]?[key];
    if (entry == null) return null;

    // Kufuta kwa muda ni jambo la kawaida (siku 60), hivyo tunafuta papo hapo
    // badala ya kuiacha ikaliwe nafasi.
    if (entry.isExpired) {
      await _deleteEntry(category, entry);
      return null;
    }

    final path = '${_dirPathFor(category)}/${entry.fileName}';

    if (!await File(path).exists()) {
      // Faili ilifutwa nje ya app (mfano "Clear cache" ya mfumo). Tunasafisha
      // index ili tusikute kosa hili kila mara baadaye.
      _index[category]!.remove(key);
      await _writeIndex(category);
      return null;
    }

    return path;
  }

  @override
  Future<bool> contains(CacheCategory category, String key) async =>
      await fileFor(category, key) != null;

  // -------------------------------------------------------------------------
  // Kuandika
  // -------------------------------------------------------------------------

  @override
  Future<String> save(
    CacheCategory category,
    String key,
    List<int> bytes, {
    required String fileName,
  }) async {
    _ensureReady();

    final dirPath = _dirPathFor(category);
    final target = File('$dirPath/$fileName');
    final temp = File('$dirPath/$fileName.tmp');

    try {
      // **Kuandika kwa hatua mbili (atomic).** Kama process itauawa katikati
      // ya upakuaji (Android hufanya hivi kwenye simu zenye RAM ndogo),
      // faila ya `.tmp` inabaki na faila halisi HAIJAGUSWA. Bila hii, faila
      // ya nusu ingeonekana kama picha kamili — mtoto angeona picha ya
      // vibaka (glitch) na `contains()` ingesema "ipo" milele.
      await temp.writeAsBytes(bytes, flush: true);
      await temp.rename(target.path);
    } catch (error) {
      // Safisha faila ya .tmp ili isijae nafasi.
      try {
        if (await temp.exists()) await temp.delete();
      } catch (_) {
        // Kushindwa kusafisha hakuongezi taarifa kwa mtumiaji.
      }
      throw CacheException(
        'Imeshindwa kuhifadhi faili ya "${category.folderName}".',
        code: 'CACHE_WRITE_FAILED',
        cause: error,
      );
    }

    final now = DateTime.now();
    _index[category]![key] = CachedEntry(
      key: key,
      fileName: fileName,
      bytes: bytes.length,
      savedAt: now,
      lastAccess: now,
    );

    await _writeIndex(category, force: true);
    await evictIfNeeded(category);

    return target.path;
  }

  @override
  Future<String> saveImage({
    required String url,
    required List<int> bytes,
  }) =>
      save(
        CacheCategory.illustrations,
        url,
        bytes,
        // Inarithi jina la faili kutoka `AppImageUtils` — ufunguo wa FNV-1a.
        // Tunatumia helper hiyo hiyo hapa ili `cached_network_image` (ambayo
        // huhesabu jina la faili mwenyewe) na cache yetu zitumie jina lile
        // lile, badala ya kupakua na kuhifadhi picha ile mara mbili.
        fileName: AppImageUtils.cacheFileNameFor(url),
      );

  @override
  Future<String> saveAudio({
    required String key,
    required List<int> bytes,
  }) =>
      save(
        CacheCategory.audio,
        key,
        bytes,
        // Hapa tunatumia `cacheKeyFor` kwa **ufunguo usio URL** (mfano
        // "story_12/p3/voice_mama"). Hii ni makusudi: sababu ile ile
        // inayotumika kwa URL inatumika hapa — `String.hashCode` ya Dart
        // haijahakikishwa kubaki ile ile kwenye builds tofauti, na ufunguo
        // ukibadilika sauti zote zilizohifadhiwa zinakuwa za bure.
        fileName: '${AppImageUtils.cacheKeyFor(key)}.mp3',
      );

  @override
  Future<void> touch(CacheCategory category, String key) async {
    _ensureReady();

    final entry = _index[category]?[key];
    if (entry == null) return;

    _index[category]![key] = entry.touched();

    // Kuandika index kwa kila ukurasa kungeongeza I/O kwenye kila page turn.
    final last = _lastIndexWrite[category];
    if (last != null && DateTime.now().difference(last) < _indexWriteThrottle) {
      return;
    }
    await _writeIndex(category, force: true);
  }

  // -------------------------------------------------------------------------
  // Takwimu
  // -------------------------------------------------------------------------

  @override
  Future<int> bytesFor(CacheCategory category) async {
    _ensureReady();
    final entries = _index[category];
    if (entries == null) return 0;

    var total = 0;
    for (final entry in entries.values) {
      total += entry.bytes;
    }
    return total;
  }

  @override
  Future<CacheStats> statsFor(CacheCategory category) async {
    _ensureReady();
    final entries = _index[category] ?? const <String, CachedEntry>{};

    var total = 0;
    for (final entry in entries.values) {
      total += entry.bytes;
    }

    return CacheStats(
      bytes: total,
      fileCount: entries.length,
      limitBytes: category.limitBytes,
    );
  }

  // -------------------------------------------------------------------------
  // Kusafisha
  // -------------------------------------------------------------------------

  @override
  Future<int> removeWhereExpired({CacheCategory? category}) async {
    _ensureReady();

    final categories =
        category == null ? CacheCategory.values : <CacheCategory>[category];
    var removed = 0;

    for (final target in categories) {
      final entries = _index[target];
      if (entries == null) continue;

      // Tunakusanya kwanza: kufuta ndani ya `removeWhere` kungebadilisha
      // map wakati tunapita ndani yake.
      final expired = entries.values.where((e) => e.isExpired).toList();
      for (final entry in expired) {
        await _deleteEntry(target, entry);
        removed++;
      }

      if (expired.isNotEmpty) await _writeIndex(target, force: true);
    }

    return removed;
  }

  @override
  Future<void> evictIfNeeded(CacheCategory category) async {
    _ensureReady();

    final limit = category.limitBytes;
    if (limit == null) return;

    final entries = _index[category];
    if (entries == null || entries.isEmpty) return;

    var total = 0;
    for (final entry in entries.values) {
      total += entry.bytes;
    }
    if (total <= limit) return;

    // LRU: tunafuta yaliyosomwa zamani zaidi kwanza.
    //
    // TANBIHI: hii hufuta faili bila kujua kama mtu anaifungua kwa sasa.
    // Kwa hivyo mwitaji anapaswa kuita `evictIfNeeded` **baada ya** upakuaji
    // kumalizika, si wakati hadithi inasomwa. Kwenye vitendo vya kusoma,
    // `save` tayari inaita hii baada ya kuandika — hivyo hakuna haja ya
    // kuiita kwa mkono.
    final ordered = entries.values.toList()
      ..sort((a, b) => a.lastAccess.compareTo(b.lastAccess));

    var remaining = total;
    var evicted = 0;

    for (final entry in ordered) {
      if (remaining <= limit) break;
      await _deleteEntry(category, entry);
      remaining -= entry.bytes;
      evicted++;
    }

    if (evicted > 0) await _writeIndex(category, force: true);
  }

  @override
  Future<void> clearCategory(CacheCategory category) async {
    _ensureReady();

    try {
      final dir = Directory(_dirPathFor(category));
      if (await dir.exists()) await dir.delete(recursive: true);
      await dir.create(recursive: true);
    } catch (error) {
      throw CacheException(
        'Imeshindwa kufuta cache ya "${category.folderName}".',
        code: 'CACHE_CLEAR_FAILED',
        cause: error,
      );
    }

    _index[category] = <String, CachedEntry>{};
    _lastIndexWrite.remove(category);
    await _writeIndex(category, force: true);
  }

  @override
  Future<void> clearAll() async {
    for (final category in CacheCategory.values) {
      await clearCategory(category);
    }
  }

  @override
  Future<void> flush() async {
    if (!_initialised) return;
    for (final category in CacheCategory.values) {
      await _writeIndex(category, force: true);
    }
  }

  // -------------------------------------------------------------------------
  // Helper za ndani
  // -------------------------------------------------------------------------

  /// Path kamili ya folda ya kategoria.
  ///
  /// **Kwa nini tunatengeneza path kwa `'$a/$b'` na si `package:path`:** 
  /// `path` haipo kwenye `pubspec.yaml` ya project hii (inakuja kama
  /// dependency ya `path_provider`). Kuitumia moja kwa moja kungejenga
  /// kutegemea kifurushi ambacho hakijatangazwa. Android na iOS zote ni
  /// POSIX, hivyo `/` ni kitenganishi sahihi — na app hii haiui Windows.
  String _dirPathFor(CacheCategory category) =>
      '${_root!.path}/${category.folderName}';

  String _indexPathFor(CacheCategory category) =>
      '${_dirPathFor(category)}/$_indexFileName';

  /// Hutoa jina la faili kutoka path.
  ///
  /// Hatumii `File.uri.pathSegments.last` kwa sababu hiyo hufanya uri-decoding
  /// kwenye jina la faili — jina letu ni hex halisi, lakini kutenda hivi
  /// kungeweka mtego kama jina litabadilika.
  String _fileNameOf(String path) {
    final index = path.lastIndexOf('/');
    return index < 0 ? path : path.substring(index + 1);
  }

  /// Huhifadhi entry moja kwenye Hive cache index.
  Future<void> _writeIndex(CacheCategory category, {bool force = false}) async {
    if (!force) {
      final last = _lastIndexWrite[category];
      if (last != null &&
          DateTime.now().difference(last) < _indexWriteThrottle) {
        return;
      }
    }

    final entries = _index[category] ?? const <String, CachedEntry>{};
    final payload = <String, dynamic>{
      'version': _indexVersion,
      'entries': <String, dynamic>{
        for (final entry in entries.entries) entry.key: entry.value.toJson(),
      },
    };

    try {
      // Index ni metadata ya cache — kushindwa kuandika kwake **hakupaswi**
      // kuvunja upakuaji ambao umefanikiwa tayari. Ndiyo sababu hatukurushi
      // kosa hapa: `reconcile()` itaijenga upya kwenye kuanza kwa app ijayo.
      await File(_indexPathFor(category)).writeAsString(
        jsonEncode(payload),
        flush: true,
      );
      _lastIndexWrite[category] = DateTime.now();
    } catch (_) {
      // Tazama maelezo hapo juu.
    }
  }

  /// Husoma index kwa uvumilivu.
  Future<Map<String, CachedEntry>> _readIndex(CacheCategory category) async {
    final file = File(_indexPathFor(category));
    if (!await file.exists()) return <String, CachedEntry>{};

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return <String, CachedEntry>{};
      if (decoded['version'] != _indexVersion) {
        // Muundo wa toleo lingine — `reconcile()` itajenga upya kutoka disk.
        return <String, CachedEntry>{};
      }

      final raw = decoded['entries'];
      if (raw is! Map) return <String, CachedEntry>{};

      final result = <String, CachedEntry>{};
      for (final entry in raw.entries) {
        final key = entry.key;
        if (key is! String) continue;
        final parsed = CachedEntry.fromJson(key, entry.value);
        if (parsed != null) result[key] = parsed;
      }
      return result;
    } catch (_) {
      // Index iliyoharibika si kosa la mtumiaji — tunaanza upya.
      return <String, CachedEntry>{};
    }
  }

  /// Hufuta faili ya entry na kuiondoa kwenye index.
  Future<void> _deleteEntry(CacheCategory category, CachedEntry entry) async {
    _index[category]?.remove(entry.key);
    try {
      final file = File('${_dirPathFor(category)}/${entry.fileName}');
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Faili ambayo haiwezi kufutwa (mfano inatumika sasa) hubaki, lakini
      // haitakuwa kwenye index — hivyo haitakuwa "inayoonekana". Hii ni bora
      // kuliko kurusha kosa katikati ya kusoma hadithi.
    }
  }

  Future<DateTime> _lastModified(File file) async {
    try {
      return await file.lastModified();
    } catch (_) {
      return DateTime.now();
    }
  }
}

