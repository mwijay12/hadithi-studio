import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/services/reading_activity_store.dart';
import 'package:hadithi_studio/core/services/reading_discovery.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';

void main() {
  test('daily story rotates predictably by local calendar day, independent of list order', () {
    final all = StorySampleData.all;
    final day = DateTime(2026, 12, 31, 23, 59);
    final first = dailyStoryFor(day, all);
    expect(first, isNotNull);
    expect(dailyStoryFor(DateTime(2026, 12, 31, 0, 1), all.reversed)?.id, first!.id);
    expect(dailyStoryFor(DateTime(2027, 1, 1), all)?.id, isNot(first.id));
    expect(dailyStoryFor(day.add(Duration(days: all.length)), all)?.id, first.id);
    expect(dailyStoryFor(day, []), isNull);
    expect(dailyStoryFor(day, [first, first])?.id, first.id);
  });

  test('weekly mini-goal counts only active dates this week through today', () {
    const snapshot = ActivitySnapshot(activeDates: {
      '2026-12-27', // last Sunday
      '2026-12-28', '2026-12-29', '2026-12-30', '2026-12-31',
      '2027-01-01', // future Friday
    });
    expect(weeklyActiveDays(snapshot, DateTime(2026, 12, 30)), 3);
    expect(weeklyActiveDays(snapshot, DateTime(2027, 1, 1)), 5);
    expect(weeklyActiveDays(snapshot, DateTime(2027, 1, 4)), 0);
    expect(weeklyActiveDays(const ActivitySnapshot(), DateTime(2027, 1, 4)), 0);
  });
}
