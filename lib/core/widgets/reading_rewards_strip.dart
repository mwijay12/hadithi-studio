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
    if (ReadingRewardsStore.instance.isLoaded) {
      _loading = false;
    } else {
      _load();
    }
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
                  Text('${snapshot.stars} ${sw ? 'Nyota' : 'stars'} • ${_levelName(snapshot.levelIndex, sw)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (snapshot.nextLevelAt != null) ...<Widget>[
                    Text(sw ? 'Nyota ${snapshot.stars}/${snapshot.nextLevelAt} hadi ngazi inayofuata'
                        : '${snapshot.stars}/${snapshot.nextLevelAt} stars towards the next level'),
                    const SizedBox(height: 8),
                    Semantics(
                      label: sw ? 'Maendeleo ya ngazi' : 'Level progress',
                      value: sw ? 'Nyota ${snapshot.stars} kati ya ${snapshot.nextLevelAt}'
                          : '${snapshot.stars} of ${snapshot.nextLevelAt} stars',
                      child: ExcludeSemantics(child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LinearProgressIndicator(
                          key: const ValueKey('rewards-level-progress'),
                          minHeight: 10, value: snapshot.levelProgress),
                      )),
                    ),
                  ] else Text(sw ? 'Umefikia ngazi ya juu!' : 'You reached the top level!'),
                  const SizedBox(height: 8),
                  Text(sw ? 'Soma kwa mwendo wako; kila hatua ni ya thamani.'
                      : 'Read at your own pace; every step matters.',
                    style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 16),
                  for (final entry in <(String, String)>[
                    ('explorer', sw ? 'Gusa vitu $explorer/10' : 'Explore $explorer/10 spots'),
                    ('reviewer', sw ? 'Andika maoni ya kwanza kwenye kifaa' : 'Write your first review on this device'),
                    ('week', sw ? 'Fikisha siku 7 za mfululizo' : 'Reach a 7-day streak'),
                  ])
                    _RewardBadge(
                      name: rewardBadgeName(entry.$1, sw: sw),
                      description: entry.$2,
                      earned: snapshot.unlocked.containsKey(entry.$1),
                      sw: sw,
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

/// Badge status is written in words as well as shown by an icon.
class _RewardBadge extends StatelessWidget {
  const _RewardBadge({required this.name, required this.description,
    required this.earned, required this.sw});
  final String name;
  final String description;
  final bool earned;
  final bool sw;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final status = earned ? (sw ? 'Umeipata' : 'Earned')
        : (sw ? 'Bado haijapatikana' : 'Not earned yet');
    return Card(
      color: earned ? colors.primaryContainer : colors.surfaceContainerHighest,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          ExcludeSemantics(child: Icon(earned ? Icons.emoji_events_rounded : Icons.emoji_events_outlined,
              color: earned ? colors.onPrimaryContainer : colors.onSurfaceVariant)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(status, style: Theme.of(context).textTheme.labelMedium),
            Text(description, style: Theme.of(context).textTheme.bodySmall),
          ])),
        ]),
      ),
    );
  }
}
