/// Uhifadhi wa **maendeleo ya kusoma** na **alama za kurasa** kwa kifaa.
///
/// ## Kwa nini huduma yake, si ndani ya `ReaderCubit`
///
/// Hifadhi ni **kando ya hali** (side effect): kuandika disk si sehemu ya
/// "hali ya reader", na `ReaderState` haipaswi kuwa na `LocalStorage` ndani
/// yake (tazama maelezo ya `reader_state.dart` — kila `emit` ingeandika disk).
/// Kwa hivyo ujuzi wa "wapi tunahifadhi" umewekwa hapa, mahali pamoja, na
/// cubit huiita kwa hatua chache zilizo wazi:
///
/// * ukurasa umebadilika → `savePage`
/// * mtoto anatoka kwenye reader → `savePage` (mwito wa mwisho)
/// * mtoto anafungua hadithi → `savedPage` (kuuliza "endelea kutoka ukurasa…?")
/// * alama ya ukurasa → `saveBookmarks`
///
/// ## `shared_preferences`, si `LocalStorage` (Hive)
///
/// Hii ni **kwa makusudi**: `shared_preferences` inafanya kazi kwenye simu
/// **na** kwenye kivinjari (inatumia `localStorage`). `LocalStorage` yetu
/// (Hive) inahitaji faili za disk — hazipo kwenye preview ya web, ambapo
/// `di.init()` hurukwa. Kutumia Hive hapa kungefanya preview isifanye kazi.
///
/// ## Faili hili haliwezi kuangusha app
///
/// Kila mwito umefungwa kwa `try/catch` na hurudisha thamani ya `null`/`false`
/// akishindwa. Sababu: hifadhi ni **mapambo**, si sharti — mtoto akiwa na
/// simu yenye nafasi ndogo, kusoma hadithi lazima kuendelee. Hivyo hakuna
/// `throw`, hakuna `Failure`, na hakuna UI inayoonyesha kosa la hifadhi.
library;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

/// Huhifadhi na kusoma maendeleo ya kusoma kwa kila hadithi.
class ReadingProgressStore {
  /// Huruhusu sindano ya toleo la jaribio (in-memory) kwenye tests.
  ///
  /// Toleo la msingi ni tupu: kila mwito hutumia `SharedPreferences` halisi.
  const ReadingProgressStore();

  /// Kiambishi cha ufunguo wa ukurasa wa mwisho uliosomwa.
  ///
  /// Kila hadithi ina ufunguo wake — ndiyo maana tunaweka `storyId` ndani ya
  /// ufunguo, si orodha moja ya `Map` (orodha moja ingehitaji kusoma-andika
  /// yote kila ukurasa unapogeuza).
  static const String progressPrefix = 'hadithi_reader_page_';

  /// Kiambishi cha ufunguo wa alama za kurasa.
  static const String bookmarksPrefix = 'hadithi_reader_bookmarks_';

  /// Ukurasa wa mwisho uliosomwa wa hadithi [storyId] (`null` = hakuna).
  ///
  /// Hurudisha `null` ikiwa hakuna kumbukumbu au kama hifadhi haipatikani —
  /// katika hali zote mbili UI **haionyeshi** kidokezo cha "endelea kusoma",
  /// kwa sababu haina ukurasa wa kweli wa kuendelea.
  Future<int?> savedPage(String storyId) async {
    if (storyId.isEmpty) return null;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getInt('$progressPrefix$storyId');
    } catch (error) {
      debugPrint('ReadingProgressStore: kusoma maendeleo kimeshindwa — $error');
      return null;
    }
  }

  /// Huhifadhi ukurasa unaosomwa sasa.
  ///
  /// Hurudisha `true` kama imefanikiwa — kwa majaribio na kwa kumbukumbu;
  /// UI haiitaji matokeo, kwa hivyo wito kawaida hupuuzwa (`unawaited`).
  Future<bool> savePage(String storyId, int pageIndex) async {
    if (storyId.isEmpty || pageIndex < 0) return false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setInt('$progressPrefix$storyId', pageIndex);
    } catch (error) {
      debugPrint('ReadingProgressStore: kuhifadhi maendeleo kimeshindwa — $error');
      return false;
    }
  }

  /// Alama za kurasa za hadithi [storyId] (seti tupu = hakuna alama).
  Future<Set<int>> bookmarks(String storyId) async {
    if (storyId.isEmpty) return <int>{};
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // `List<String>` ni aina pekee ya orodha inayohifadhiwa na
      // `shared_preferences` bila mabadiliko; kurasa ni `int`, kwa hivyo
      // tunazibadilisha kuwa maandishi na kurudi.
      final List<String>? raw = prefs.getStringList('$bookmarksPrefix$storyId');
      if (raw == null) return <int>{};
      return raw
          .map(int.tryParse)
          .whereType<int>()
          .where((int page) => page >= 0)
          .toSet();
    } catch (error) {
      debugPrint('ReadingProgressStore: kusoma alama kimeshindwa — $error');
      return <int>{};
    }
  }

  /// Huhifadhi alama za kurasa, zikichukua nafasi ya zile za awali.
  Future<bool> saveBookmarks(String storyId, Set<int> pages) async {
    if (storyId.isEmpty) return false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // `Set` haina mpangilio; tunapanga kwanza ili kila kuhifadhi
      // kutengeneze orodha ile ile kwa kurasa zile zile.
      final List<int> sorted = pages.toList()..sort();
      return await prefs.setStringList(
        '$bookmarksPrefix$storyId',
        sorted.map((int page) => page.toString()).toList(),
      );
    } catch (error) {
      debugPrint('ReadingProgressStore: kuhifadhi alama kimeshindwa — $error');
      return false;
    }
  }

  /// Hufuta maendeleo ya hadithi moja (mfano "Anza Upya").
  Future<bool> clearProgress(String storyId) async {
    if (storyId.isEmpty) return false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove('$progressPrefix$storyId');
    } catch (error) {
      debugPrint('ReadingProgressStore: kufuta maendeleo kimeshindwa — $error');
      return false;
    }
  }
}
