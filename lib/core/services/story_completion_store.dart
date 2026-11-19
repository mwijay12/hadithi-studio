import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stories explicitly marked finished by the reader, not inferred from visits.
class StoryCompletionStore extends ChangeNotifier {
  StoryCompletionStore();
  static StoryCompletionStore instance = StoryCompletionStore();
  @visibleForTesting
  static void resetForTesting() => instance = StoryCompletionStore();
  static const storageKey = 'hadithi_story_completions_v1';
  Map<String, String> _completed = <String, String>{};
  Set<String> get completedIds => Set<String>.unmodifiable(_completed.keys);
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
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map && decoded['version'] == 1 && decoded['stories'] is Map) {
          final stories = decoded['stories'] as Map;
          for (final entry in stories.entries) {
            if (entry.key is String && (entry.key as String).isNotEmpty &&
                entry.value is String && DateTime.tryParse(entry.value as String) != null) {
              _completed[entry.key as String] = entry.value as String;
            }
          }
        }
      } on FormatException { /* Start with an empty ledger. */ }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> restore() => _enqueue(_load);
  Future<bool> complete(String storyId) async {
    if (storyId.isEmpty) return false;
    var success = false;
    try {
      await _enqueue(() async {
        await _load();
        if (_completed.containsKey(storyId)) { success = true; return; }
        final next = <String, String>{..._completed, storyId: DateTime.now().toUtc().toIso8601String()};
        final prefs = await SharedPreferences.getInstance();
        if (!await prefs.setString(storageKey, jsonEncode({'version': 1, 'stories': next}))) return;
        _completed = next;
        success = true;
        notifyListeners();
      });
    } catch (error) { debugPrint('StoryCompletionStore: save failed: $error'); }
    return success;
  }

  Future<bool> clear() async {
    var success = false;
    try {
      await _enqueue(() async {
        final prefs = await SharedPreferences.getInstance();
        success = await prefs.remove(storageKey);
        if (success) { _completed = <String, String>{}; _loaded = true; notifyListeners(); }
      });
    } catch (error) { debugPrint('StoryCompletionStore: clear failed: $error'); }
    return success;
  }
}
