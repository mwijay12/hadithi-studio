import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/story_completion_store.dart';
import '../../../../core/widgets/leo_mascot.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../../domain/services/similar_stories.dart';
import '../stories_dependencies.dart';

/// Only shown after the reader explicitly taps "I finished" on the last page.
class StoryCompletionDialog extends StatefulWidget {
  const StoryCompletionDialog({super.key, required this.story, required this.store,
    required this.onStartOver, required this.onOpenStory, this.repository});
  final Story story;
  final StoryCompletionStore store;
  final Future<void> Function() onStartOver;
  final void Function(Story) onOpenStory;
  final StoryRepository? repository;

  @override
  State<StoryCompletionDialog> createState() => _StoryCompletionDialogState();
}

class _StoryCompletionDialogState extends State<StoryCompletionDialog> {
  bool? _saved;
  late Future<Either<Failure, List<Story>>> _stories;

  @override
  void initState() {
    super.initState();
    _stories = (widget.repository ?? resolveStoryRepository()).getAllStories();
    _save();
  }

  Future<void> _save() async {
    if (mounted) setState(() => _saved = null);
    final ok = await widget.store.complete(widget.story.id);
    if (mounted) setState(() => _saved = ok);
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    return AlertDialog(
      title: Text(sw ? 'Hongera!' : 'Well done!', textAlign: TextAlign.center),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            const LeoMascot(pose: LeoPose.celebrate, height: 105),
            const SizedBox(height: 8),
            Text(widget.story.title(swahili: sw), textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (_saved == null) Text(sw ? 'Tunahifadhi...' : 'Saving...')
            else if (_saved == false) ...<Widget>[
              Text(sw ? 'Haikuwezekana kuhifadhi. Jaribu tena.' : 'Could not save. Please try again.'),
              TextButton(onPressed: _save, child: Text(sw ? 'Jaribu tena' : 'Try again')),
            ] else Text(sw ? 'Umeweka hadithi hii kuwa imekamilika kwenye kifaa hiki.'
                : 'You marked this story complete on this device.'),
            const SizedBox(height: 16),
            FutureBuilder<Either<Failure, List<Story>>>(
              future: _stories,
              builder: (context, result) {
                if (!result.hasData && !result.hasError) return const CircularProgressIndicator();
                if (result.hasError || result.data!.isLeft()) {
                  return Text(sw ? 'Mapendekezo hayapatikani sasa.' : 'Recommendations are unavailable right now.');
                }
                final ranked = getSimilarStories(widget.story,
                  result.data!.getOrElse(() => <Story>[]), completedIds: widget.store.completedIds, limit: 1);
                if (ranked.isEmpty) {
                  return Text(sw ? 'Hakuna hadithi inayofanana kwa sasa.' : 'No similar story available yet.');
                }
                final next = ranked.first;
                return Column(children: <Widget>[
                  Text(sw ? 'Huenda ukaipenda pia' : 'You might also enjoy',
                    style: Theme.of(context).textTheme.titleSmall),
                  ListTile(
                    key: const ValueKey('completion-next-story'),
                    leading: ClipRRect(borderRadius: BorderRadius.circular(8),
                      child: Image.asset(next.coverAsset, width: 50, height: 50, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.menu_book_rounded))),
                    title: Text(next.title(swahili: sw)),
                    subtitle: Text(next.ageLabel(swahili: sw)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      // Push detail from the reader's context after closing the dialog.
                      Navigator.of(context).pop();
                      widget.onOpenStory(next);
                    },
                  ),
                ]);
              },
            ),
          ]),
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: () { Navigator.of(context).pop(); widget.onStartOver(); },
          child: Text(sw ? 'Soma tena' : 'Read again')),
        FilledButton(onPressed: () => Navigator.of(context).pop(),
          child: Text(sw ? 'Funga' : 'Close')),
      ],
    );
  }
}
