import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';
import '../services/reading_rewards_store.dart';

String rewardBadgeName(String id, {required bool sw}) => switch (id) {
  'explorer' => sw ? 'Mpelelezi Hodari' : 'Curious Explorer',
  'reviewer' => sw ? 'Mtoa Maoni' : 'Story Reviewer',
  'week' => sw ? 'Moto wa Wiki' : 'Week of Stories',
  _ => sw ? 'Tuzo mpya' : 'New achievement',
};

String _levelName(int level, bool sw) => sw
    ? const <String>['Chipukizi', 'Msafiri', 'Msimulizi', 'Gwiji wa Hadithi'][level]
    : const <String>['Seedling', 'Explorer', 'Storyteller', 'Story Master'][level];

/// Compact, optional progress view. Counts are local, not social comparisons.
class ReadingRewardsStrip extends StatefulWidget {
  const ReadingRewardsStrip({super.key});
  @override
  State<ReadingRewardsStrip> createState() => _ReadingRewardsStripState();
}

class _ReadingRewardsStripState extends State<ReadingRewardsStrip> {
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      await ReadingRewardsStore.instance.restore();
      if (mounted) setState(() { _loading = false; _failed = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _failed = true; });
    }
  }

  void _showRewards(BuildContext context) {
    showModalBottomSheet<void>(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * .8),
          child: ListenableBuilder(
            listenable: ReadingRewardsStore.instance,
            builder: (context, _) {
              final sw = context.isSwahili;
              final snapshot = ReadingRewardsStore.instance.snapshot;
              final explorer = snapshot.hotspots.length.clamp(0, 10);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Text(sw ? 'Nyota na tuzo zako' : 'Your stars and achievements',
                    style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('${snapshot.stars} ${sw ? 'Nyota' : 'stars'} • ${_levelName(snapshot.levelIndex, sw)}'),
                  if (snapshot.nextLevelAt != null)
                    Text(sw ? 'Ngazi inayofuata: ${snapshot.nextLevelAt} Nyota' : 'Next level: ${snapshot.nextLevelAt} stars'),
                  const SizedBox(height: 16),
                  for (final entry in <(String, String)>[
                    ('explorer', sw ? 'Gusa vitu $explorer/10' : 'Explore $explorer/10 spots'),
                    ('reviewer', sw ? 'Andika maoni ya kwanza kwenye kifaa' : 'Write your first review on this device'),
                    ('week', sw ? 'Fikisha siku 7 za mfululizo' : 'Reach a 7-day streak'),
                  ])
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(snapshot.unlocked.containsKey(entry.$1)
                          ? Icons.emoji_events_rounded : Icons.emoji_events_outlined),
                      title: Text(rewardBadgeName(entry.$1, sw: sw)),
                      subtitle: Text(entry.$2),
                      trailing: snapshot.unlocked.containsKey(entry.$1)
                          ? const Icon(Icons.check_circle_outline_rounded) : null,
                    ),
                  Text(sw ? 'Nyota ni za kifaa hiki: ukurasa mpya +5, kitu kipya +5, maoni ya kwanza kwa hadithi +15.'
                      : 'Stars stay on this device: new page +5, new spot +5, first review per story +15.',
                    style: Theme.of(context).textTheme.bodySmall),
                ]),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    if (_loading) return const SizedBox.shrink();
    if (_failed) return TextButton(onPressed: _load,
      child: Text(sw ? 'Jaribu kupakia tuzo tena' : 'Retry loading rewards'));
    return ListenableBuilder(
      listenable: ReadingRewardsStore.instance,
      builder: (context, _) {
        final snapshot = ReadingRewardsStore.instance.snapshot;
        return TextButton.icon(
          key: const ValueKey('open-rewards'),
          onPressed: () => _showRewards(context),
          icon: const Icon(Icons.stars_rounded),
          label: Text('${snapshot.stars} ${sw ? 'Nyota' : 'stars'} • ${_levelName(snapshot.levelIndex, sw)}'),
        );
      },
    );
  }
}
