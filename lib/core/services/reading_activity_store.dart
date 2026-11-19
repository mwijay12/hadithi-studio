import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A local calendar date expressed in UTC solely to do calendar arithmetic.
/// Values originate in the device's local timezone, never from UTC clock time.
DateTime activityDay(DateTime local) => DateTime.utc(local.year, local.month, local.day);
String activityDateKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';

class ActivitySnapshot {
  const ActivitySnapshot({
    this.day = '', this.pageKeys = const <String>{}, this.activeDates = const <String>{},
    this.lastActive = '', this.streak = 0, this.longest = 0, this.freezes = 0,
  });
  final String day;
  final Set<String> pageKeys;
  final Set<String> activeDates;
  final String lastActive;
  final int streak;
  final int longest;
  final int freezes;

  DateTime? get lastActiveDay {
    final parts = lastActive.split('-');
    if (parts.length != 3) return null;
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;
    return DateTime.utc(year, month, day);
  }

  /// Don't present a stale streak as current after it can no longer be saved.
  int visibleStreak(DateTime now) {
    final last = lastActiveDay;
    if (last == null) return 0;
    final gap = activityDay(now).difference(last).inDays;
    if (gap < 0) return 0; // Device clock moved backwards.
    return gap <= 1 || (gap == 2 && freezes > 0) ? streak : 0;
  }

  int pagesToday(DateTime now) => day == activityDateKey(activityDay(now)) ? pageKeys.length : 0;

  /// Count distinct pages opened. This is not a measure of time or reading comprehension.
  ActivitySnapshot visit(DateTime now, String storyId, int pageIndex) {
    if (storyId.isEmpty || pageIndex < 0) return this;
    final today = activityDay(now);
    final key = activityDateKey(today);
    final last = lastActiveDay;
    // Avoid corrupting streaks if the device clock has been set backwards.
    if ((last != null && today.isBefore(last)) || (day.isNotEmpty && key.compareTo(day) < 0)) return this;
    final pages = day == key ? Set<String>.of(pageKeys) : <String>{};
    // JSON encoding of a pair avoids collisions between arbitrary IDs.
    if (!pages.add(jsonEncode(<Object>[storyId, pageIndex]))) return this;
    var nextStreak = streak;
    var nextLongest = longest;
    var nextFreezes = freezes;
    var nextLast = lastActive;
    final dates = Set<String>.of(activeDates);
    if (pages.length >= 3 && lastActive != key) {
      final gap = last == null ? 0 : today.difference(last).inDays;
      if (last != null && gap == 1) {
        nextStreak++;
      } else if (last != null && gap == 2 && nextFreezes > 0) {
        nextFreezes--;
        nextStreak++;
      } else {
        nextStreak = 1;
      }
      if (nextStreak > nextLongest) nextLongest = nextStreak;
      if (nextStreak % 7 == 0 && nextFreezes < 2) nextFreezes++;
      nextLast = key;
      dates.add(key);
      // Bound stored history while retaining more than the weekly strip needs.
      final cutoff = activityDateKey(today.subtract(const Duration(days: 400)));
      dates.removeWhere((date) => date.compareTo(cutoff) < 0);
    }
    return ActivitySnapshot(day: key, pageKeys: pages, activeDates: dates,
      lastActive: nextLast, streak: nextStreak, longest: nextLongest, freezes: nextFreezes);
  }

  Map<String, Object> toJson() => <String, Object>{
    'version': 1, 'day': day, 'pages': pageKeys.toList(), 'activeDates': activeDates.toList(),
    'lastActive': lastActive, 'streak': streak, 'longest': longest, 'freezes': freezes,
  };

  static ActivitySnapshot fromJson(Object? value) {
    if (value is! Map<String, dynamic> || value['version'] != 1) return const ActivitySnapshot();
    int number(String name, int max) {
      final raw = value[name];
      return raw is int && raw >= 0 && raw <= max ? raw : 0;
    }
    String date(String name) {
      final raw = value[name];
      return raw is String && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw) && DateTime.tryParse(raw) != null ? raw : '';
    }
    Set<String> strings(String name) => value[name] is List
        ? (value[name] as List).whereType<String>().toSet() : <String>{};
    return ActivitySnapshot(day: date('day'), pageKeys: strings('pages'),
      activeDates: strings('activeDates'), lastActive: date('lastActive'),
      streak: number('streak', 100000), longest: number('longest', 100000), freezes: number('freezes', 2));
  }
}

/// Serializes read/write/clear operations so rapid page turns cannot overwrite
/// one another. This is a single-device prototype, not server synchronization.
class ReadingActivityStore extends ChangeNotifier {
  ReadingActivityStore();
  static ReadingActivityStore instance = ReadingActivityStore();

  /// Isolates the singleton between widget tests using different fake clocks.
  @visibleForTesting
  static void resetForTesting() => instance = ReadingActivityStore();
  static const String storageKey = 'hadithi_reading_activity_v1';
  ActivitySnapshot _snapshot = const ActivitySnapshot();
  ActivitySnapshot get snapshot => _snapshot;
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
      try { _snapshot = ActivitySnapshot.fromJson(jsonDecode(raw)); }
      on FormatException { _snapshot = const ActivitySnapshot(); }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> restore() => _enqueue(_load);

  Future<bool> recordPage(String storyId, int index, {DateTime? now}) async {
    var success = false;
    try {
      await _enqueue(() async {
        await _load();
        final next = _snapshot.visit(now ?? DateTime.now(), storyId, index);
        if (identical(next, _snapshot)) { success = true; return; }
        final prefs = await SharedPreferences.getInstance();
        if (!await prefs.setString(storageKey, jsonEncode(next.toJson()))) return;
        _snapshot = next;
        notifyListeners();
        success = true;
      });
    } catch (error) {
      debugPrint('ReadingActivityStore: save failed: $error');
    }
    return success;
  }

  Future<bool> clear() async {
    var success = false;
    try {
      await _enqueue(() async {
        final prefs = await SharedPreferences.getInstance();
        success = await prefs.remove(storageKey);
        if (success) {
          _snapshot = const ActivitySnapshot();
          _loaded = true;
          notifyListeners();
        }
      });
    } catch (error) {
      debugPrint('ReadingActivityStore: clear failed: $error');
    }
    return success;
  }
}
