import 'package:flutter/material.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/reading_activity_store.dart';
import '../../../../core/services/reading_discovery.dart';
import '../../../../core/widgets/reading_rewards_strip.dart';

/// A gentle local calendar: pages opened, not minutes read or stories completed.
class ReadingJourneyCard extends StatefulWidget {
  const ReadingJourneyCard({required this.now});
  final DateTime now;

  @override
  State<ReadingJourneyCard> createState() => _ReadingJourneyCardState();
}

class _ReadingJourneyCardState extends State<ReadingJourneyCard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ReadingActivityStore.instance.restore().catchError((Object error) {
      debugPrint('Reading activity could not be loaded: $error');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    final colors = Theme.of(context).colorScheme;
    final now = widget.now;
    final today = activityDay(now);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final labels = sw
        ? const <String>['Jtt', 'Jnn', 'Jtn', 'Alh', 'Ijm', 'Jms', 'Jpl']
        : const <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return ListenableBuilder(
      listenable: ReadingActivityStore.instance,
      builder: (context, _) {
        final activity = ReadingActivityStore.instance.snapshot;
        final count = activity.pagesToday(now).clamp(0, 3);
        final streak = activity.visibleStreak(now);
        return Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
          child: Card(
            color: colors.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(sw ? 'Safari ya kusoma' : 'Reading journey',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onSecondaryContainer, fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.xs),
                Text(sw ? 'Leo: kurasa $count/3 zimefunguliwa'
                    : 'Today: $count/3 pages opened',
                  style: TextStyle(color: colors.onSecondaryContainer)),
                const SizedBox(height: AppSpacing.sm),
                Row(children: <Widget>[
                  for (int i = 0; i < 7; i++)
                    Expanded(child: Column(children: <Widget>[
                      Text(labels[i], style: Theme.of(context).textTheme.labelSmall?.copyWith(color: colors.onSecondaryContainer)),
                      const SizedBox(height: 4),
                      Icon(activity.activeDates.contains(activityDateKey(monday.add(Duration(days: i))))
                          ? Icons.star_rounded : Icons.star_border_rounded,
                        color: colors.onSecondaryContainer, size: 22),
                    ])),
                ]),
                const SizedBox(height: AppSpacing.sm),
                Text(streak > 0
                    ? (sw ? 'Siku $streak mfululizo • Kinga ${activity.freezes}' : '$streak-day streak • ${activity.freezes} freezes')
                    : (sw ? 'Kila ukurasa ni mwanzo mzuri!' : 'Every page is a lovely start!'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSecondaryContainer)),
                Text(sw ? 'Nyota huwaka ukifungua kurasa 3 tofauti kwa siku.'
                    : 'A star lights up when you open 3 different pages in a day.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSecondaryContainer)),
                const SizedBox(height: AppSpacing.md),
                _WeeklyMiniGoal(activity: activity, now: now),
                const ReadingRewardsStrip(),
              ]),
            ),
          ),
        );
      },
    );
  }
}

/// A gentle three-day goal; no penalties or new data collection.
class _WeeklyMiniGoal extends StatelessWidget {
  const _WeeklyMiniGoal({required this.activity, required this.now});
  final ActivitySnapshot activity;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    final days = weeklyActiveDays(activity, now);
    final progress = days.clamp(0, 3);
    final color = Theme.of(context).colorScheme.onSecondaryContainer;
    return Column(key: const ValueKey('weekly-mini-goal'),
      crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(sw ? 'Lengo la wiki: siku $progress/3' : 'Weekly goal: $progress/3 days',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Semantics(label: sw ? 'Lengo la wiki: siku $progress kati ya 3' : 'Weekly goal: $progress of 3 days',
          child: LinearProgressIndicator(value: progress / 3)),
        const SizedBox(height: 6),
        Text(progress >= 3
            ? (sw ? 'Hongera! Umetimiza lengo la wiki.' : 'Hooray! You reached your weekly goal.')
            : (sw ? 'Siku moja ni kurasa 3 tofauti zilizofunguliwa. Polepole ni sawa!' :
                'One day means 3 different pages opened. Go at your own pace!'),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color)),
      ]);
  }
}

