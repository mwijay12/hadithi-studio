import '../entities/story.dart';

/// Rank stories that share a category or shelf. Shelves are the available
/// tag-like metadata; age alone does not make an unrelated story similar.
/// Completion is optional because the current reader does not record it yet.
List<Story> getSimilarStories(
  Story current,
  List<Story> stories, {
  Set<String>? completedIds,
  int? limit = 6,
}) {
  if (limit != null && limit <= 0) return <Story>[];
  final currentShelves = current.shelves.toSet();
  final seen = <String>{current.id};
  final candidates = <({Story story, int score})>[];
  for (final story in stories) {
    if (!seen.add(story.id)) continue;
    final sameCategory = story.category == current.category;
    final sharedShelves = story.shelves.toSet().intersection(currentShelves).length;
    if (!sameCategory && sharedShelves == 0) continue;
    final score = (sameCategory ? 3 : 0) + sharedShelves * 2 +
        (story.ageGroup == current.ageGroup ? 2 : 0) +
        (completedIds != null && !completedIds.contains(story.id) ? 1 : 0);
    candidates.add((story: story, score: score));
  }
  candidates.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    // The bundled catalog has placeholder ratings, not real review data.
    return a.story.id.compareTo(b.story.id);
  });
  final ranked = candidates.map((entry) => entry.story);
  return (limit == null ? ranked : ranked.take(limit)).toList(growable: false);
}
