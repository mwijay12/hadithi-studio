import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../../domain/services/similar_stories.dart';
import '../stories_dependencies.dart';
import '../story_navigation.dart';
import 'story_card.dart';

/// Recommendations use the same repository as the rest of the library.
class SimilarStoriesSection extends StatefulWidget {
  const SimilarStoriesSection({super.key, required this.story, this.repository});

  final Story story;
  /// Injectable for tests; normally resolved from the app's repository.
  final StoryRepository? repository;

  @override
  State<SimilarStoriesSection> createState() => _SimilarStoriesSectionState();
}

class _SimilarStoriesSectionState extends State<SimilarStoriesSection> {
  late Future<Either<Failure, List<Story>>> _stories;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(SimilarStoriesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository) _load();
  }

  void _load() {
    _stories = (widget.repository ?? resolveStoryRepository()).getAllStories();
  }

  void _showAll(List<Story> stories) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(sheetContext.l10n.similarStories,
                    style: Theme.of(sheetContext).textTheme.titleLarge),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: stories.length,
                  itemBuilder: (_, index) {
                    final story = stories[index];
                    final sw = context.isSwahili;
                    return ListTile(
                      key: ValueKey('similar-all-${story.id}'),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(story.coverAsset, width: 52, height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.menu_book_rounded)),
                      ),
                      title: Text(story.title(swahili: sw)),
                      subtitle: Text('${story.ageLabel(swahili: sw)} • ${story.readingMinutes} ${sw ? 'dak' : 'min'}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(sheetContext).pop();
                        openStory(context, story);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: FutureBuilder<Either<Failure, List<Story>>>(
        future: _stories,
        builder: (context, snapshot) {
          Widget content;
          List<Story> ranked = <Story>[];
          if (!snapshot.hasData && !snapshot.hasError) {
            content = const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data!.isLeft()) {
            content = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(sw ? 'Hatukuweza kupata mapendekezo.' : 'Could not load recommendations.'),
                TextButton(
                  onPressed: () => setState(_load),
                  child: Text(sw ? 'Jaribu tena' : 'Try again'),
                ),
              ],
            );
          } else {
            final all = snapshot.data!.getOrElse(() => <Story>[]);
            ranked = getSimilarStories(widget.story, all, limit: null);
            if (ranked.isEmpty) {
              content = Text(sw ? 'Hakuna hadithi zinazofanana kwa sasa.' : 'No similar stories yet.');
            } else {
              content = SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (final story in ranked.take(6))
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: SizedBox(
                          width: 155,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              StoryCard(key: ValueKey('similar-${story.id}'), story: story, height: 150),
                              const SizedBox(height: AppSpacing.xs),
                              Text(story.ageLabel(swahili: sw), style: Theme.of(context).textTheme.labelMedium),
                              Text('${story.readingMinutes} ${sw ? 'dakika' : 'min'} • ★ ${story.rating.toStringAsFixed(1)}',
                                  style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                Expanded(child: Text(context.l10n.similarStories,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                if (ranked.isNotEmpty)
                  TextButton(
                    key: const ValueKey('similar-view-all'),
                    onPressed: () => _showAll(ranked),
                    child: Text(context.l10n.viewAll),
                  ),
              ]),
              const SizedBox(height: AppSpacing.sm),
              content,
            ],
          );
        },
      ),
    );
  }
}
