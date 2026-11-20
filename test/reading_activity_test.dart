import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/reading_activity_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

ActivitySnapshot completeDay(ActivitySnapshot state, DateTime day) {
  for (var i = 0; i < 3; i++) {
    state = state.visit(day, 'story', i);
  }
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('three distinct opened pages qualify once per local calendar day', () {
    final day = DateTime(2026, 12, 1, 23, 59);
    var state = const ActivitySnapshot().visit(day, 'story', 0);
    state = state.visit(day, 'story', 0);
    expect(state.pagesToday(day), 1);
    state = state.visit(day, 'story', 1).visit(day, 'other', 0);
    expect(state.streak, 1);
    expect(state.activeDates, {'2026-12-01'});
    state = state.visit(day, 'story', 2);
    expect(state.streak, 1);
    expect(state.pagesToday(DateTime(2026, 12, 2)), 0);
  });

  test('earns freeze after seven days, uses it once for a missed day', () {
    var state = const ActivitySnapshot();
    for (int i = 0; i < 7; i++) {
      state = completeDay(state, DateTime(2026, 1, 1 + i));
    }
    expect(state.streak, 7);
    expect(state.freezes, 1);
    expect(state.visibleStreak(DateTime(2026, 1, 9)), 7);
    state = completeDay(state, DateTime(2026, 1, 9));
    expect(state.streak, 8);
    expect(state.freezes, 0);
    expect(state.activeDates.contains('2026-01-08'), isFalse);
    state = completeDay(state, DateTime(2026, 1, 11));
    expect(state.streak, 1);
    expect(state.longest, 8);
  });

  test('long gaps and backwards clocks cannot create streaks', () {
    var state = completeDay(const ActivitySnapshot(), DateTime(2026, 3, 28, 23));
    state = completeDay(state, DateTime(2026, 3, 29, 1));
    expect(state.streak, 2);
    expect(state.visibleStreak(DateTime(2026, 4, 4)), 0);
    final unchanged = state.visit(DateTime(2026, 3, 27), 'another', 1);
    expect(identical(unchanged, state), isTrue);
    state = completeDay(state, DateTime(2026, 4, 4));
    expect(state.streak, 1);
  });

  test('freeze rewards capped at two', () {
    var state = const ActivitySnapshot();
    for (int i = 0; i < 21; i++) {
      state = completeDay(state, DateTime(2026, 1, 1 + i));
    }
    expect(state.streak, 21);
    expect(state.freezes, 2);
  });

  test('serializes page writes, reloads, and clears saved activity', () async {
    final store = ReadingActivityStore();
    final now = DateTime(2026, 1, 2);
    await Future.wait(<Future<bool>>[
      store.recordPage('a', 0, now: now),
      store.recordPage('a', 1, now: now),
      store.recordPage('a', 2, now: now),
    ]);
    expect(store.snapshot.streak, 1);
    final reopened = ReadingActivityStore();
    await reopened.restore();
    expect(reopened.snapshot.pagesToday(now), 3);
    expect(reopened.snapshot.streak, 1);
    expect(await reopened.clear(), isTrue);
    final cleared = ReadingActivityStore();
    await cleared.restore();
    expect(cleared.snapshot.streak, 0);
  });
}
