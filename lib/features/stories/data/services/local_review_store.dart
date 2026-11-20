import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One private, editable review per story on this device. Not synced.
class LocalStoryReview {
  const LocalStoryReview({
    required this.storyId,
    required this.rating,
    required this.name,
    required this.comment,
    required this.tags,
    required this.updatedAt,
  });

  final String storyId;
  final int rating;
  final String name;
  final String comment;
  /// Stable tag keys, not translated display strings.
  final List<String> tags;
  final DateTime updatedAt;

  Map<String, Object> toJson() => <String, Object>{
    'version': 1, 'storyId': storyId, 'rating': rating, 'name': name,
    'comment': comment, 'tags': tags, 'updatedAt': updatedAt.toIso8601String(),
  };

  static LocalStoryReview? fromJson(Object? value, String expectedId) {
    if (value is! Map<String, dynamic> || value['version'] != 1 ||
        value['storyId'] != expectedId || value['rating'] is! int ||
        (value['rating'] as int) < 1 || (value['rating'] as int) > 5 ||
        value['name'] is! String || value['comment'] is! String ||
        value['tags'] is! List || value['updatedAt'] is! String) return null;
    final date = DateTime.tryParse(value['updatedAt'] as String);
    if (date == null) return null;
    return LocalStoryReview(
      storyId: expectedId, rating: value['rating'] as int,
      name: value['name'] as String, comment: value['comment'] as String,
      tags: (value['tags'] as List).whereType<String>().toList(), updatedAt: date,
    );
  }
}

class LocalReviewStore {
  const LocalReviewStore();
  static const String keyPrefix = 'hadithi_local_review_';

  Future<LocalStoryReview?> read(String storyId) async {
    if (storyId.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$keyPrefix$storyId');
    if (raw == null) return null;
    try {
      return LocalStoryReview.fromJson(jsonDecode(raw), storyId);
    } on FormatException {
      return null;
    }
  }

  Future<bool> save(LocalStoryReview review) async {
    if (review.storyId.isEmpty || review.rating < 1 || review.rating > 5 ||
        review.name.length > 40 || review.comment.length > 500) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('$keyPrefix${review.storyId}', jsonEncode(review.toJson()));
    } catch (_) {
      return false;
    }
  }

  Future<bool> delete(String storyId) async {
    if (storyId.isEmpty) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('$keyPrefix$storyId');
    } catch (_) {
      return false;
    }
  }
}
