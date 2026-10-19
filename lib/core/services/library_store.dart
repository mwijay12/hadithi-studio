/// Hifadhi **ya kudumu** ya mambo ya mtumiaji: onboarding, waandishi
/// unaowafuata, hadithi ulizohifadhi, zilizopakuliwa, zilizotengenezwa, na
/// maendeleo ya kusoma.
///
/// ## Kwa nini faili moja, na si tano
///
/// Kabla ya faili hili, kila kitu kilikuwa **kwenye kumbukumbu pekee**
/// (`setState` ndani ya ukurasa). Matokeo yaliyokuwa yanaripotiwa:
///
/// * onboarding ilirudi kila kufungua app,
/// * "Fuata" ilibadilika kisha ikarudi,
/// * alama ya ukurasa ilisema "imehifadhiwa" kumbe ilipotea,
/// * "Pakua" haikufanya kitu,
/// * Rafu Yangu ilionyesha `45%` ya kubuni.
///
/// Sababu moja: **hakuna mahali pa kuandika**. Sasa pana mahali kimoja.
///
/// ## Kwa nini `shared_preferences`, sivyo `LocalStorage` (Hive)
///
/// `LocalStorage` yetu hutumia Hive, ambayo inahitaji faili za disk.
/// Kwenye preview ya web `di.init()` hurukwa kwa sababu `path_provider`
/// haipo — hivyo Hive **haipatikani** hapo. `shared_preferences` hufanya
/// kazi kwenye simu **na** kwenye kivinjari (`localStorage`), kwa hivyo
/// tabia moja inapimwa kila mahali.
///
/// ## Kwa nini `ChangeNotifier` ya kimataifa
///
/// [AppLocaleController] ilishaweka kiolezo hiki: `app.dart` hujengwa
/// **kabla** ya DI, hivyo huduma inayohitajika na splash/onboarding/shell
/// haiwezi kutegemea `get_it`. Singileni inafanya kila skrini ionee hali ile
/// ile, na `AnimatedBuilder`/`ListenableBuilder` kusikiliza mabadiliko.
///
/// ## Faili hili HAIWEZI kuangusha app
///
/// Kila mwito wa hifadhi umefungwa kwa `try/catch` na hurudisha thamani ya
/// akiba. Hifadhi ni **mapambo**: mtoto akiwa na simu yenye nafasi ndogo au
/// kivinjari kilichozima `localStorage`, kusoma lazima kuendelee.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hadithi iliyotengenezwa na mtumiaji ndani ya app.
///
/// ## Kwa nini model yake, sivyo [Story]
///
/// [Story] ina picha, rangi, hotspot na kurasa za `StoryPage` — vitu
/// vinavyohitaji mhariri kamili. Hadithi ya mtumiaji kwa sasa ni **maandishi
/// pekee**: kichwa na kurasa za maandishi. Kuilazimisha iwe [Story] ingehitaji
/// kubuni picha na rangi ambazo hazipo — yaani data ya uongo.
@immutable
class DraftStory {
  /// Huunda rasimu.
  const DraftStory({
    required this.id,
    required this.titleSw,
    required this.titleEn,
    required this.pagesSw,
    required this.pagesEn,
    required this.createdAt,
  });

  /// Hutengeneza kutoka JSON iliyohifadhiwa.
  ///
  /// Hurudisha `null` kama umbo halipo — kipengele kimoja kilichoharibika
  /// **kisiangushe** orodha yote.
  static DraftStory? fromJson(Map<String, dynamic> json) {
    final Object? id = json['id'];
    final Object? titleSw = json['titleSw'];
    if (id is! String || titleSw is! String || id.isEmpty) return null;

    List<String> readPages(Object? raw) {
      if (raw is! List) return <String>[];
      return raw.whereType<String>().toList(growable: false);
    }

    final Object? createdRaw = json['createdAtMs'];
    return DraftStory(
      id: id,
      titleSw: titleSw,
      titleEn: json['titleEn'] is String
          ? json['titleEn'] as String
          : titleSw,
      pagesSw: readPages(json['pagesSw']),
      pagesEn: readPages(json['pagesEn']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdRaw is int ? createdRaw : 0,
      ),
    );
  }

  /// Kitambulisho cha kipekee.
  final String id;

  /// Kichwa kwa Kiswahili.
  final String titleSw;

  /// Kichwa kwa Kiingereza.
  final String titleEn;

  /// Kurasa kwa Kiswahili (maandishi tupu hutolewa kabla ya kuhifadhi).
  final List<String> pagesSw;

  /// Kurasa kwa Kiingereza.
  final List<String> pagesEn;

  /// Wakati ilipotengenezwa.
  final DateTime createdAt;

  /// Idadi ya kurasa zenye maandishi.
  int get pageCount =>
      pagesSw.isEmpty ? pagesEn.length : pagesSw.length;

  /// Hubadilisha kuwa JSON ya kuhifadhi.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'titleSw': titleSw,
        'titleEn': titleEn,
        'pagesSw': pagesSw,
        'pagesEn': pagesEn,
        'createdAtMs': createdAt.millisecondsSinceEpoch,
      };
}

/// Hali ya mtumiaji inayodumu kwenye kifaa.
class LibraryStore extends ChangeNotifier {
  LibraryStore();

  /// Hali moja inayotumika app nzima.
  static final LibraryStore instance = LibraryStore();

  // ---------------------------------------------------------------------
  // Funguo za hifadhi — zote zina kiambishi `hadithi_` ili zisigongane na
  // funguo nyingine za `shared_preferences` kwenye kivinjari kimoja.
  // ---------------------------------------------------------------------

  /// `true` baada ya mtumiaji kumaliza onboarding.
  static const String onboardingKey = 'hadithi_onboarding_complete';

  /// Orodha ya `author` unaowafuata.
  static const String followedAuthorsKey = 'hadithi_followed_authors';

  /// Orodha ya `id` za hadithi zilizohifadhiwa (Rafu Yangu).
  static const String savedStoriesKey = 'hadithi_saved_stories';

  /// Orodha ya `id` za hadithi zilizopakuliwa kwa matumizi ya offline.
  static const String downloadedStoriesKey = 'hadithi_downloaded_stories';

  /// JSON ya hadithi zilizotengenezwa na mtumiaji.
  static const String draftsKey = 'hadithi_created_stories';

  /// Kiambishi cha ukurasa wa mwisho kwa kila hadithi.
  static const String progressPrefix = 'hadithi_reader_page_';

  /// Jina la mtoto (hiari). Huhifadhiwa kifaa pekee — hakuna akaunti.
  static const String childNameKey = 'hadithi_child_name';

  /// Kundi la umri la mtoto (hiari), kama `AgeGroup.name`.
  static const String childAgeKey = 'hadithi_child_age';

  bool _onboardingDone = false;
  Set<String> _followedAuthors = <String>{};
  Set<String> _savedStories = <String>{};
  Set<String> _downloadedStories = <String>{};
  List<DraftStory> _drafts = <DraftStory>[];
  final Map<String, int> _lastPage = <String, int>{};
  bool _restored = false;
  String _childName = '';
  String _childAge = '';

  /// Je, mtumiaji amemaliza onboarding?
  bool get onboardingDone => _onboardingDone;

  /// Jina la mtoto (`''` = hakuna). Huhifadhiwa kifaa pekee.
  String get childName => _childName;

  /// Kundi la umri la mtoto kama `AgeGroup.name` (`''` = hakuna).
  String get childAge => _childAge;

  /// Je, hifadhi imesomwa? Splash huitumia kuepuka "kuruka" kwa UI.
  bool get restored => _restored;

  /// Waandishi unaowafuata (nakala — isibadilike nje).
  Set<String> get followedAuthors => Set<String>.unmodifiable(_followedAuthors);

  /// Hadithi zilizohifadhiwa.
  Set<String> get savedStories => Set<String>.unmodifiable(_savedStories);

  /// Hadithi zilizopakuliwa.
  Set<String> get downloadedStories =>
      Set<String>.unmodifiable(_downloadedStories);

  /// Hadithi zilizotengenezwa, mpya kwanza.
  List<DraftStory> get drafts => List<DraftStory>.unmodifiable(_drafts);

  /// Ukurasa wa mwisho uliosomwa wa [storyId] (`null` = hakuna).
  int? lastPage(String storyId) => _lastPage[storyId];

  /// Je, [author] anafuatwa?
  bool isFollowing(String author) => _followedAuthors.contains(author);

  /// Je, [storyId] imehifadhiwa?
  bool isSaved(String storyId) => _savedStories.contains(storyId);

  /// Je, [storyId] imepakuliwa?
  bool isDownloaded(String storyId) => _downloadedStories.contains(storyId);

  /// Hadithi zenye maendeleo ya kusoma (zilizoanza, hazijamalizika).
  ///
  /// Hupangwa kwa **muda wa mwisho wa kuandika**: `Map` ya Dart huhifadhi
  /// mpangilio wa kuingizwa, na `saveLastPage` huweka ufunguo mpya mwisho.
  /// Hivyo hadithi ya karibuni zaidi inarudi mwisho — tunaigeuza ili ionekane
  /// kwanza kwenye "Endelea Kusoma".
  List<String> get inProgressStoryIds =>
      _lastPage.keys.toList(growable: false).reversed.toList(growable: false);

  // ---------------------------------------------------------------------
  // Kusoma
  // ---------------------------------------------------------------------

  /// Husoma hifadhi yote mara moja.
  ///
  /// Huitwa **kabla** ya `runApp` (tazama `main.dart`) ili splash ione
  /// ukweli mara moja, badala ya kuonyesha onboarding kisha kuiruka.
  Future<void> restore() async {
    if (_restored) return;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      _onboardingDone = prefs.getBool(onboardingKey) ?? false;
      _followedAuthors =
          (prefs.getStringList(followedAuthorsKey) ?? <String>[]).toSet();
      _savedStories =
          (prefs.getStringList(savedStoriesKey) ?? <String>[]).toSet();
      _downloadedStories =
          (prefs.getStringList(downloadedStoriesKey) ?? <String>[]).toSet();
      _childName = prefs.getString(childNameKey) ?? '';
      _childAge = prefs.getString(childAgeKey) ?? '';

      final List<String> rawDrafts = prefs.getStringList(draftsKey) ?? <String>[];
      final List<DraftStory> parsed = <DraftStory>[];
      for (final String raw in rawDrafts) {
        try {
          final Object? decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            final DraftStory? draft = DraftStory.fromJson(decoded);
            if (draft != null) parsed.add(draft);
          }
        } catch (error) {
          // Rasimu moja iliyoharibika haipaswi kufuta nyingine.
          debugPrint('LibraryStore: rasimu imerukwa — $error');
        }
      }
      parsed.sort(
        (DraftStory a, DraftStory b) => b.createdAt.compareTo(a.createdAt),
      );
      _drafts = parsed;

      // Maendeleo: funguo zina kiambishi + id. Tunapitia funguo zote kwa
      // sababu `shared_preferences` haitoi "funguo zinazoanza na…".
      for (final String key in prefs.getKeys()) {
        if (!key.startsWith(progressPrefix)) continue;
        final int? page = prefs.getInt(key);
        if (page == null || page < 0) continue;
        _lastPage[key.substring(progressPrefix.length)] = page;
      }
    } catch (error) {
      // Hifadhi haipatikani: tunaendelea na hali ya akiba. Hakuna
      // `throw` — app lazima ifunguke.
      debugPrint('LibraryStore: kusoma hifadhi kimeshindwa — $error');
    } finally {
      _restored = true;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------
  // Kuandika
  // ---------------------------------------------------------------------

  /// Huhifadhi kuwa onboarding imemalizika.
  Future<void> completeOnboarding() async {
    if (_onboardingDone) return;
    _onboardingDone = true;
    notifyListeners();
    await _setBool(onboardingKey, true);
  }

  /// Hubadilisha hali ya "fuata" kwa [author] na kuhifadhi.
  ///
  /// Hurudisha hali mpya ili UI isibuni thamani yake.
  Future<bool> toggleFollow(String author) async {
    if (author.isEmpty) return false;
    final bool nowFollowing = !_followedAuthors.contains(author);
    if (nowFollowing) {
      _followedAuthors.add(author);
    } else {
      _followedAuthors.remove(author);
    }
    notifyListeners();
    await _setStringList(followedAuthorsKey, _followedAuthors);
    return nowFollowing;
  }

  /// Hubadilisha alama ya [storyId] na kuhifadhi.
  Future<bool> toggleSaved(String storyId) async {
    if (storyId.isEmpty) return false;
    final bool nowSaved = !_savedStories.contains(storyId);
    if (nowSaved) {
      _savedStories.add(storyId);
    } else {
      _savedStories.remove(storyId);
    }
    notifyListeners();
    await _setStringList(savedStoriesKey, _savedStories);
    return nowSaved;
  }

  /// Huweka [storyId] kama imepakuliwa (au kuiondoa).
  Future<void> setDownloaded(String storyId, {required bool downloaded}) async {
    if (storyId.isEmpty) return;
    final int before = _downloadedStories.length;
    if (downloaded) {
      _downloadedStories.add(storyId);
    } else {
      _downloadedStories.remove(storyId);
    }
    if (before == _downloadedStories.length) return;
    notifyListeners();
    await _setStringList(downloadedStoriesKey, _downloadedStories);
  }

  /// Huhifadhi jina na kundi la umri la mtoto.
  ///
  /// `null` humaanisha "usibadilishe" — hivyo mwitaji anaweza kubadilisha
  /// kimoja pekee bila kufuta kingine.
  Future<void> saveChild({String? name, String? age}) async {
    if (name != null) _childName = name.trim();
    if (age != null) _childAge = age;
    notifyListeners();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(childNameKey, _childName);
      await prefs.setString(childAgeKey, _childAge);
    } catch (error) {
      debugPrint('LibraryStore: kuhifadhi mtoto kimeshindwa — $error');
    }
  }

  /// Huhifadhi ukurasa unaosomwa sasa wa [storyId].
  ///
  /// Huitwa kila ukurasa unapogeuza. Haithiri UI kwa `notifyListeners`
  /// kwa sababu Rafu Yangu pekee inahitaji thamani hii — na haiko hai
  /// wakati reader imefunguliwa. Kuarifu kila ukurasa kungejenga upya
  /// widget zote za nyuma bure.
  Future<void> saveLastPage(String storyId, int pageIndex) async {
    if (storyId.isEmpty || pageIndex < 0) return;
    _lastPage[storyId] = pageIndex;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('$progressPrefix$storyId', pageIndex);
    } catch (error) {
      debugPrint('LibraryStore: kuhifadhi maendeleo kimeshindwa — $error');
    }
  }

  /// Huhifadhi rasimu mpya.
  ///
  /// Hurudisha `true` kama imehifadhiwa. Orodha huhifadhiwa **yote** kwa
  /// sababu `setStringList` huchukua nafasi ya orodha iliyopo.
  Future<bool> addDraft(DraftStory draft) async {
    _drafts = <DraftStory>[draft, ..._drafts];
    notifyListeners();
    return _persistDrafts();
  }

  /// Hufuta rasimu kwa `id`.
  Future<bool> removeDraft(String id) async {
    final int before = _drafts.length;
    _drafts = _drafts.where((DraftStory d) => d.id != id).toList();
    if (_drafts.length == before) return false;
    notifyListeners();
    return _persistDrafts();
  }

  Future<bool> _persistDrafts() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setStringList(
        draftsKey,
        _drafts
            .map((DraftStory d) => jsonEncode(d.toJson()))
            .toList(growable: false),
      );
    } catch (error) {
      debugPrint('LibraryStore: kuhifadhi rasimu kimeshindwa — $error');
      return false;
    }
  }

  Future<void> _setBool(String key, bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (error) {
      debugPrint('LibraryStore: kuandika "$key" kimeshindwa — $error');
    }
  }

  Future<void> _setStringList(String key, Set<String> values) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> sorted = values.toList()..sort();
      await prefs.setStringList(key, sorted);
    } catch (error) {
      debugPrint('LibraryStore: kuandika "$key" kimeshindwa — $error');
    }
  }

  /// Hufuta kila kitu — kwa "Safisha data" kwenye Settings.
  Future<void> clearAll() async {
    _onboardingDone = false;
    _followedAuthors = <String>{};
    _savedStories = <String>{};
    _downloadedStories = <String>{};
    _drafts = <DraftStory>[];
    _lastPage.clear();
    _childName = '';
    _childAge = '';
    notifyListeners();
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      for (final String key in <String>[
        onboardingKey,
        followedAuthorsKey,
        savedStoriesKey,
        downloadedStoriesKey,
        draftsKey,
        childNameKey,
        childAgeKey,
      ]) {
        await prefs.remove(key);
      }
      for (final String key in prefs.getKeys().toList()) {
        if (key.startsWith(progressPrefix)) await prefs.remove(key);
      }
    } catch (error) {
      debugPrint('LibraryStore: kufuta data kimeshindwa — $error');
    }
  }
}
