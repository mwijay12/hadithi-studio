/// LOCAL STORAGE — mipangilio ya mtumiaji (SharedPreferences) na hifadhi ya
/// data (Hive).
///
/// **Mgawanyo wa kazi kati ya faili tatu za `core/storage/`:**
///
/// | Faili                | Huhifadhi nini                              | Zinaishi wapi      |
/// |----------------------|---------------------------------------------|--------------------|
/// | `local_storage.dart` | mipangilio na mapendeleo (funguo rahisi)    | SharedPreferences + Hive |
/// | `secure_storage.dart`| tokens, PIN, device ID (siri)               | FlutterSecureStorage |
/// | `cache_manager.dart` | faili (picha, sauti, hadithi) + ukubwa wake | filesystem         |
///
/// **Kanuni:** `StorageKeys` na `HiveBoxes` (kwenye `app_constants.dart`)
/// ndizo chanzo kimoja cha majina ya funguo. Hakuna string ya "onboarding_complete"
/// inayoandikwa mahali pengine popote kwenye project — hii ndiyo inayozuia
/// "typo" zinazoharibu data kimya kimya.
library;

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants/app_constants.dart';
import '../enums/app_enums.dart';
import '../errors/exceptions.dart';

/// Mkataba wa hifadhi ya mipangilio (ili tuweze kuweka fake kwenye tests).
abstract class LocalStorage {
  /// Huandaa hifadhi (Hive + SharedPreferences).
  Future<void> init();

  // ── Msingi ───────────────────────────────────────────────────
  Future<void> setString(String key, String value);
  String? getString(String key);
  Future<void> setBool(String key, {required bool value});
  bool? getBool(String key);
  Future<void> setInt(String key, int value);
  int? getInt(String key);
  Future<void> setDouble(String key, double value);
  double? getDouble(String key);
  Future<void> setStringList(String key, List<String> value);
  List<String>? getStringList(String key);
  Future<void> remove(String key);
  bool contains(String key);

  // ── Maisha ya app ────────────────────────────────────────────
  bool get hasCompletedOnboarding;
  Future<void> completeOnboarding();
  AppLanguage get language;
  Future<void> setLanguage(AppLanguage language);
  AgeGroup? get ageGroup;
  Future<void> setAgeGroup(AgeGroup value);
  ReadingLevel? get readingLevel;
  Future<void> setReadingLevel(ReadingLevel value);
  List<String> get interests;
  Future<void> setInterests(List<String> slugs);

  // ── Mipangilio ya kusoma ─────────────────────────────────────
  double get ttsSpeed;
  Future<void> setTtsSpeed(double speed);
  bool get autoPageTurn;
  Future<void> setAutoPageTurn({required bool value});
  int get autoPageTurnDelaySeconds;
  Future<void> setAutoPageTurnDelaySeconds(int seconds);
  double get storyFontSize;
  Future<void> setStoryFontSize(double size);
  bool get lowDataMode;
  Future<void> setLowDataMode({required bool value});
  bool get nightMode;
  Future<void> setNightMode({required bool value});

  // ── Vifurushi ────────────────────────────────────────────────
  PlanTier get planTier;
  Future<void> setPlanTier(PlanTier tier);
  DateTime? get planExpiresAt;
  Future<void> setPlanExpiresAt(DateTime? value);

  // ── Hive boxes ───────────────────────────────────────────────
  /// Hufungua box kwa **muda tu** inapohitajika kwanza.
  Future<Box<dynamic>> openBox(String name);
  Future<void> closeBoxes();

  // ── Kusafisha ────────────────────────────────────────────────
  /// Kufuta data ya mtumiaji (kutoka kwenye akaunti) — **bila** kufuta
  /// kumbukumbu za kifaa.
  Future<void> clearUserData();

  /// Kufuta kila kitu (kufuta akaunti au "anza upya" ya faragha).
  Future<void> clearAll();
}

/// Utekelezaji wa [LocalStorage] kwa SharedPreferences + Hive.
class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl();

  SharedPreferences? _prefs;

  /// Huhifadhi boxes zilizofunguliwa ili tusifungue mara mbili.
  ///
  /// Hive yenyewe huhifadhi boxes zilizofunguliwa, lakini kuweka ramani hapa
  /// hurahisisha [closeBoxes] na huzuia kuita `openBox` kwa wakati mmoja
  /// mara mbili wakati wa kufunguka kwa app.
  final Map<String, Box<dynamic>> _openBoxes = <String, Box<dynamic>>{};

  SharedPreferences get _p {
    final prefs = _prefs;
    if (prefs == null) {
      throw const CacheException(
        'LocalStorage haijaandaliwa. Ita `init()` kwenye DI kabla ya matumizi.',
        code: 'STORAGE_NOT_READY',
      );
    }
    return prefs;
  }

  @override
  Future<void> init() async {
    try {
      // Hive.initFlutter() huamua path sahihi kwa Android (files dir) na iOS
      // (Library dir) — bila hii Hive ingejaribu kuandika kwenye path ya sasa
      // ambayo haipo kwenye simu.
      await Hive.initFlutter();

      _prefs = await SharedPreferences.getInstance();

      // Funguo za ufunguzi wa kwanza — hizi lazima ziwepo kabla ya UI
      // yoyote, hivyo tunaandika `firstLaunchDate` mara moja tu na
      // haiwi overwritten kamwe baadaye.
      if (_p.getString(StorageKeys.firstLaunchDate) == null) {
        await _p.setString(
          StorageKeys.firstLaunchDate,
          DateTime.now().toIso8601String(),
        );
      }
      await _p.setString(
        StorageKeys.lastActiveDate,
        DateTime.now().toIso8601String(),
      );
      await _p.setInt(
        StorageKeys.appOpenCount,
        (_p.getInt(StorageKeys.appOpenCount) ?? 0) + 1,
      );
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException(
        'Imeshindwa kuandaa hifadhi ya kifaa.',
        cause: error,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Msingi
  // ---------------------------------------------------------------------------

  @override
  Future<void> setString(String key, String value) =>
      _write(() => _p.setString(key, value), key);

  @override
  String? getString(String key) => _p.getString(key);

  @override
  Future<void> setBool(String key, {required bool value}) =>
      _write(() => _p.setBool(key, value), key);

  @override
  bool? getBool(String key) => _p.getBool(key);

  @override
  Future<void> setInt(String key, int value) =>
      _write(() => _p.setInt(key, value), key);

  @override
  int? getInt(String key) => _p.getInt(key);

  @override
  Future<void> setDouble(String key, double value) =>
      _write(() => _p.setDouble(key, value), key);

  @override
  double? getDouble(String key) => _p.getDouble(key);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _write(() => _p.setStringList(key, value), key);

  @override
  List<String>? getStringList(String key) => _p.getStringList(key);

  @override
  Future<void> remove(String key) =>
      _write(() => _p.remove(key), key);

  @override
  bool contains(String key) => _p.containsKey(key);

  // ---------------------------------------------------------------------------
  // Maisha ya app
  // ---------------------------------------------------------------------------

  @override
  bool get hasCompletedOnboarding =>
      _p.getBool(StorageKeys.onboardingComplete) ?? false;

  @override
  Future<void> completeOnboarding() =>
      setBool(StorageKeys.onboardingComplete, value: true);

  @override
  AppLanguage get language =>
      AppLanguage.fromCode(_p.getString(StorageKeys.selectedLanguage));

  @override
  Future<void> setLanguage(AppLanguage value) =>
      setString(StorageKeys.selectedLanguage, value.code);

  @override
  AgeGroup? get ageGroup {
    final stored = _p.getString(StorageKeys.userAgeGroup);
    if (stored == null) return null;
    // Enum iliyohifadhiwa kwa jina lake (`miaka_6_8`) — kama jina
    // limebadilika kwenye toleo jipya, tunarudisha `null` badala ya kuanguka,
    // na mtumiaji anaulizwa tena (badala ya kupata kosa kwenye skrini ya
    // mipangilio).
    for (final group in AgeGroup.values) {
      if (group.name == stored) return group;
    }
    return null;
  }

  @override
  Future<void> setAgeGroup(AgeGroup value) =>
      setString(StorageKeys.userAgeGroup, value.name);

  @override
  ReadingLevel? get readingLevel {
    final stored = _p.getString(StorageKeys.userReadingLevel);
    if (stored == null) return null;
    for (final level in ReadingLevel.values) {
      if (level.name == stored) return level;
    }
    return null;
  }

  @override
  Future<void> setReadingLevel(ReadingLevel value) =>
      setString(StorageKeys.userReadingLevel, value.name);

  @override
  List<String> get interests => _p.getStringList(StorageKeys.userInterests) ?? const <String>[];

  @override
  Future<void> setInterests(List<String> slugs) =>
      setStringList(StorageKeys.userInterests, slugs);

  // ---------------------------------------------------------------------------
  // Mipangilio ya kusoma
  // ---------------------------------------------------------------------------

  @override
  double get ttsSpeed =>
      _p.getDouble(StorageKeys.ttsSpeed) ?? AppConstants.defaultTtsSpeed;

  @override
  Future<void> setTtsSpeed(double speed) => setDouble(StorageKeys.ttsSpeed, speed);

  @override
  bool get autoPageTurn => _p.getBool(StorageKeys.autoPageTurn) ?? false;

  @override
  Future<void> setAutoPageTurn({required bool value}) =>
      setBool(StorageKeys.autoPageTurn, value: value);

  @override
  int get autoPageTurnDelaySeconds =>
      _p.getInt(StorageKeys.autoPageTurnDelay) ??
      AppConstants.defaultAutoPageTurnDelay;

  @override
  Future<void> setAutoPageTurnDelaySeconds(int seconds) =>
      setInt(StorageKeys.autoPageTurnDelay, seconds);

  @override
  double get storyFontSize =>
      _p.getDouble(StorageKeys.storyFontSize) ?? AppConstants.defaultStoryFontSize;

  @override
  Future<void> setStoryFontSize(double size) =>
      setDouble(StorageKeys.storyFontSize, size);

  @override
  bool get lowDataMode => _p.getBool(StorageKeys.lowDataMode) ?? false;

  @override
  Future<void> setLowDataMode({required bool value}) =>
      setBool(StorageKeys.lowDataMode, value: value);

  @override
  bool get nightMode => _p.getBool(StorageKeys.nightMode) ?? false;

  @override
  Future<void> setNightMode({required bool value}) =>
      setBool(StorageKeys.nightMode, value: value);

  // ---------------------------------------------------------------------------
  // Vifurushi
  // ---------------------------------------------------------------------------

  @override
  PlanTier get planTier {
    final stored = _p.getString(StorageKeys.activePlanTier);
    if (stored == null) return PlanTier.bure;
    for (final tier in PlanTier.values) {
      if (tier.name == stored) return tier;
    }
    // Tier isiyojulikana inamaanisha app ya zamani ilihifadhi jina ambalo
    // hatulifahamu. Kurudi kwenye `bure` ni salama: mtumiaji anaona kikomo
    // cha bure, na anaweza kupandisha daraja — hapati huduma bila kulipa.
    return PlanTier.bure;
  }

  @override
  Future<void> setPlanTier(PlanTier tier) =>
      setString(StorageKeys.activePlanTier, tier.name);

  @override
  DateTime? get planExpiresAt {
    final stored = _p.getString(StorageKeys.activePlanExpiresAt);
    if (stored == null) return null;
    return DateTime.tryParse(stored);
  }

  @override
  Future<void> setPlanExpiresAt(DateTime? value) {
    if (value == null) return remove(StorageKeys.activePlanExpiresAt);
    return setString(StorageKeys.activePlanExpiresAt, value.toIso8601String());
  }

  // ---------------------------------------------------------------------------
  // Hive boxes
  // ---------------------------------------------------------------------------

  /// Hufungua box — mara ya kwanza tu.
  ///
  /// **Kwa nini tunafungua box "kwa muda tu" (lazily) na si zote kwenye
  /// `init()`:** kufungua boxes 9 za Hive wakati app inafunguka huongeza
  /// muda wa kuanza kwenye simu za 2GB RAM (Tecno/Itel). Mtumiaji wa kwanza
  /// wa app hii hahitaji `drafts_box` (ya waandishi) wala `sync_queue_box` —
  /// hivyo tunafungua pale tu inapohitajika. Hii inafanya skrini ya kwanza
  /// ifunguke haraka kwa kila mtu.
  @override
  Future<Box<dynamic>> openBox(String name) async {
    final existing = _openBoxes[name];
    if (existing != null && existing.isOpen) return existing;

    try {
      // TANBIHI: boxes hufunguliwa kama `Box<dynamic>` kwa sababu type
      // adapters za Hive (`hive_generator` → `*.g.dart`) bado hazijazalishwa
      // kwenye project hii. Hivyo tunaweka `Map<String, dynamic>` na
      // primitives, ambazo Hive huzihifadhi bila adapter. Pindi adapters
      // zitakapozalishwa, `openBox<StoryModel>(HiveBoxes.stories)` inaweza
      // kutumika badala yake — bila kubadilisha wito wa `openBox` wenyewe.
      final box = await Hive.openBox<dynamic>(name);
      _openBoxes[name] = box;
      return box;
    } catch (error) {
      throw CacheException(
        'Imeshindwa kufungua hifadhi "$name".',
        code: 'HIVE_OPEN_FAILED',
        cause: error,
      );
    }
  }

  @override
  Future<void> closeBoxes() async {
    try {
      await Hive.close();
      _openBoxes.clear();
    } catch (error) {
      throw CacheException(
        'Imeshindwa kufunga hifadhi za ndani.',
        cause: error,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Kusafisha
  // ---------------------------------------------------------------------------

  /// Funguo zinazohifadhi **utambulisho wa kifaa**, si data ya mtumiaji.
  ///
  /// Hizi hazifutwa kwenye `clearUserData()` (kutoka kwenye akaunti) kwa
  /// sababu ni mali ya kifaa: `firstLaunchDate` inatumika kupima ukuaji wa
  /// watumiaji wapya, na `appOpenCount` inatumika kuamua lini kuomba
  /// tathmini (rating) kwenye Play Store. Kufuta hizi kila mtumiaji
  /// anapotoka kungeharibu takwimu za app nzima.
  static const List<String> _installationKeys = <String>[
    StorageKeys.firstLaunchDate,
    StorageKeys.appOpenCount,
  ];

  @override
  Future<void> clearUserData() async {
    try {
      final keys = _p.getKeys().difference(_installationKeys.toSet());
      for (final key in keys) {
        await _p.remove(key);
      }
    } catch (error) {
      throw CacheException(
        'Imeshindwa kufuta data ya mtumiaji.',
        cause: error,
      );
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await _p.clear();
      for (final name in HiveBoxes.all) {
        if (Hive.isBoxOpen(name)) {
          await Hive.box<dynamic>(name).clear();
        } else {
          await Hive.deleteBoxFromDisk(name);
        }
      }
    } catch (error) {
      throw CacheException(
        'Imeshindwa kufuta data yote ya app.',
        cause: error,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Helper ya ndani
  // ---------------------------------------------------------------------------

  /// Huendesha `SharedPreferences` setter na kubadilisha kosa lake kuwa
  /// [CacheException].
  ///
  /// `SharedPreferences` setters hurudisha `false` (na hazitupi exception)
  /// kama kuandika kumeshindwa — kama vile kifaa kimejaa kumbukumbu.
  /// Kushindwa huku ni **kimya**, na bila ukaguzi huu mtumiaji angeona
  /// mipangilio "imehifadhiwa" wakati haijahifadhiwa.
  Future<void> _write(
    Future<bool> Function() action,
    String key,
  ) async {
    try {
      final ok = await action();
      if (!ok) {
        throw CacheException(
          'Imeshindwa kuhifadhi "$key" kwenye kifaa.',
          code: 'PREFS_WRITE_FAILED',
        );
      }
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException(
        'Imeshindwa kuhifadhi "$key" kwenye kifaa.',
        code: 'PREFS_WRITE_FAILED',
        cause: error,
      );
    }
  }
}
