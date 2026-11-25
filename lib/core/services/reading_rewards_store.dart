import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The ledger records each page, hotspot, and reviewed story at most once.
/// Completion and listening rewards are deliberately absent until measured.
class RewardsSnapshot {
  const RewardsSnapshot({
    this.pages = const <String>{}, this.hotspots = const <String>{},
    this.reviews = const <String>{}, this.unlocked = const <String, String>{},
  });
  final Set<String> pages;
  final Set<String> hotspots;
  final Set<String> reviews;
  final Map<String, String> unlocked;
  int get stars => 5 * (pages.length + hotspots.length) + 15 * reviews.length;
  int get levelIndex => stars < 100 ? 0 : stars < 300 ? 1 : stars < 700 ? 2 : 3;
  int? get nextLevelAt => const <int?>[100, 300, 700, null][levelIndex];
  /// Progress through the current level, not a percentage of all-time stars.
  double get levelProgress {
    final next = nextLevelAt;
    if (next == null) return 1;
    final start = const <int>[0, 100, 300, 700][levelIndex];
    return ((stars - start) / (next - start)).clamp(0.0, 1.0);
  }

  Map<String, Object> toJson() => <String, Object>{
    'version': 1, 'pages': pages.toList(), 'hotspots': hotspots.toList(),
    'reviews': reviews.toList(), 'unlocked': unlocked,
  };

  static RewardsSnapshot fromJson(Object? value) {
    if (value is! Map<String, dynamic> || value['version'] != 1) return const RewardsSnapshot();
    Set<String> strings(String key) => value[key] is List
        ? (value[key] as List).whereType<String>().toSet() : <String>{};
    final raw = value['unlocked'];
    final unlocked = <String, String>{};
    if (raw is Map) {
      for (final entry in raw.entries) {
        if (entry.key is String && entry.value is String && DateTime.tryParse(entry.value as String) != null) {
          unlocked[entry.key as String] = entry.value as String;
        }
      }
    }
    return RewardsSnapshot(pages: strings('pages'), hotspots: strings('hotspots'),
      reviews: strings('reviews'), unlocked: unlocked);
  }
}

class RewardResult {
  const RewardResult({required this.saved, this.starsEarned = 0, this.unlocked = const <String>[]});
  final bool saved;
  final int starsEarned;
  final List<String> unlocked;
}

class ReadingRewardsStore extends ChangeNotifier {
  ReadingRewardsStore();
  static ReadingRewardsStore instance = ReadingRewardsStore();
  @visibleForTesting
  static void resetForTesting() => instance = ReadingRewardsStore();
  static const String storageKey = 'hadithi_reading_rewards_v1';
  RewardsSnapshot _snapshot = const RewardsSnapshot();
  RewardsSnapshot get snapshot => _snapshot;
  bool _loaded = false;
  Future<void> _pending = Future<void>.value();

  Future<void> _enqueue(Future<void> Function() work) {
    final next = _pending.then((_) => work());
    _pending = next.catchError((Object _) {});
    return next;
  }

  Future<void> _load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw != null) {
      try { _snapshot = RewardsSnapshot.fromJson(jsonDecode(raw)); }
      on FormatException { _snapshot = const RewardsSnapshot(); }
    }
    _loaded = true;
    notifyListeners();
  }

  bool get isLoaded => _loaded;
  Future<void> restore() => _enqueue(_load);

  Future<RewardResult> pageOpened(String storyId, int page) =>
      _add('page', storyId, page: page);
  Future<RewardResult> hotspotDiscovered(String storyId, int page, int hotspot) =>
      _add('hotspot', storyId, page: page, hotspot: hotspot);
  Future<RewardResult> reviewWritten(String storyId) => _add('review', storyId);
  Future<RewardResult> streakReached(int streak) => _add('streak', '', streak: streak);

  Future<RewardResult> _add(String kind, String storyId, {int? page, int? hotspot, int? streak}) async {
    if (kind != 'streak' && storyId.isEmpty ||
        (page != null && page < 0) || (hotspot != null && hotspot < 0)) {
      return const RewardResult(saved: false);
    }
    var result = const RewardResult(saved: false);
    try {
      await _enqueue(() async {
        await _load();
        final pages = Set<String>.of(_snapshot.pages);
        final hotspots = Set<String>.of(_snapshot.hotspots);
        final reviews = Set<String>.of(_snapshot.reviews);
        final unlocked = Map<String, String>.of(_snapshot.unlocked);
        var stars = 0;
        if (kind == 'page' && pages.add(jsonEncode([storyId, page]))) stars = 5;
        if (kind == 'hotspot' && hotspots.add(jsonEncode([storyId, page, hotspot]))) stars = 5;
        if (kind == 'review' && reviews.add(storyId)) stars = 15;
        final added = <String>[];
        void unlock(String id, bool achieved) {
          if (achieved && !unlocked.containsKey(id)) {
            unlocked[id] = DateTime.now().toUtc().toIso8601String();
            added.add(id);
          }
        }
        unlock('explorer', hotspots.length >= 10);
        unlock('reviewer', reviews.isNotEmpty);
        unlock('week', (streak ?? 0) >= 7);
        if (stars == 0 && added.isEmpty) {
          result = const RewardResult(saved: true);
          return;
        }
        final next = RewardsSnapshot(pages: pages, hotspots: hotspots, reviews: reviews, unlocked: unlocked);
        final prefs = await SharedPreferences.getInstance();
        if (!await prefs.setString(storageKey, jsonEncode(next.toJson()))) return;
        _snapshot = next;
        notifyListeners();
        result = RewardResult(saved: true, starsEarned: stars, unlocked: added);
      });
    } catch (error) {
      debugPrint('ReadingRewardsStore: save failed: $error');
    }
    return result;
  }

  Future<bool> clear() async {
    var success = false;
    try {
      await _enqueue(() async {
        final prefs = await SharedPreferences.getInstance();
        success = await prefs.remove(storageKey);
        if (success) { _snapshot = const RewardsSnapshot(); _loaded = true; notifyListeners(); }
      });
    } catch (error) {
      debugPrint('ReadingRewardsStore: clear failed: $error');
    }
    return success;
  }
}
