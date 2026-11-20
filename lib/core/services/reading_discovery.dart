import '../../features/stories/domain/entities/story.dart';
import 'reading_activity_store.dart';

/// Deterministic offline rotation by local calendar day, sorted by stable ID.
/// It is an editorial suggestion, not a reading requirement.
Story? dailyStoryFor(DateTime now, Iterable<Story> stories) {
  final unique = <String, Story>{};
  for (final story in stories) {
    if (story.id.isNotEmpty && story.pages.isNotEmpty) unique.putIfAbsent(story.id, () => story);
  }
  final ids = unique.keys.toList()..sort();
  if (ids.isEmpty) return null;
  final dayNumber = activityDay(now).difference(DateTime.utc(2020)).inDays;
  return unique[ids[dayNumber % ids.length]];
}

/// Counts only active days in the current Monday–Sunday local calendar week,
/// up to today. An active day means three different story pages opened.
int weeklyActiveDays(ActivitySnapshot snapshot, DateTime now) {
  final today = activityDay(now);
  final monday = today.subtract(Duration(days: today.weekday - 1));
  return List<int>.generate(today.weekday, (index) => index)
      .where((index) => snapshot.activeDates.contains(
        activityDateKey(monday.add(Duration(days: index)))))
      .length;
}
