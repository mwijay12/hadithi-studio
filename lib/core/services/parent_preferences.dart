import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Optional presentation preference; not a PIN or a child-proof restriction.
class ParentPreferences extends ChangeNotifier {
  ParentPreferences();
  static ParentPreferences instance = ParentPreferences();
  @visibleForTesting
  static void resetForTesting() => instance = ParentPreferences();
  static const String goalsKey = 'hadithi_parent_show_goals_v1';
  bool _showGoals = true;
  bool _loaded = false;
  bool get showGoals => _showGoals;
  bool get isLoaded => _loaded;
  Future<void> _pending = Future<void>.value();

  Future<void> _enqueue(Future<void> Function() work) {
    final next = _pending.then((_) => work());
    _pending = next.catchError((Object _) {});
    return next;
  }

  Future<void> _load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    _showGoals = prefs.getBool(goalsKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> restore() => _enqueue(_load);
  Future<bool> setShowGoals(bool value) async {
    bool success = false;
    try {
      await _enqueue(() async {
        await _load();
        final prefs = await SharedPreferences.getInstance();
        if (!await prefs.setBool(goalsKey, value)) return;
        _showGoals = value;
        success = true;
        notifyListeners();
      });
    } catch (error) { debugPrint('ParentPreferences: save failed: $error'); }
    return success;
  }
}
