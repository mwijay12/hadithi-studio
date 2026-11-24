import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/reading_rewards_store.dart';
import '../../../../core/widgets/reading_rewards_strip.dart';
import '../../data/services/local_review_store.dart';

const _tags = <String, (String, String)>{
  'great': ('Nzuri sana', 'Wonderful'),
  'educational': ('Inafundisha', 'Educational'),
  'kids': ('Watoto wameipenda', 'Children loved it'),
  'audio': ('Sauti safi', 'Clear audio'),
  'art': ('Picha nzuri', 'Beautiful pictures'),
};

class StoryReviewsSection extends StatefulWidget {
  const StoryReviewsSection({super.key, required this.storyId, this.store = const LocalReviewStore()});
  final String storyId;
  final LocalReviewStore store;

  @override
  State<StoryReviewsSection> createState() => _StoryReviewsSectionState();
}

class _StoryReviewsSectionState extends State<StoryReviewsSection> {
  LocalStoryReview? _review;
  bool _loading = true;
  bool _readFailed = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(StoryReviewsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.storyId != widget.storyId || oldWidget.store != widget.store) _load();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() { _loading = true; _readFailed = false; _review = null; });
    try {
      final review = await widget.store.read(widget.storyId);
      if (!mounted || request != _request) return;
      setState(() { _review = review; _loading = false; });
    } catch (_) {
      if (!mounted || request != _request) return;
      setState(() { _readFailed = true; _loading = false; });
    }
  }

  Future<void> _edit() async {
    final bool sw = context.isSwahili;
    final saved = await showModalBottomSheet<LocalStoryReview>(
      context: context, isScrollControlled: true, showDragHandle: true,
      builder: (_) => _ReviewEditor(storyId: widget.storyId, initial: _review, store: widget.store),
    );
    if (!mounted || saved == null || saved.storyId != widget.storyId) return;
    unawaited(ReadingRewardsStore.instance.reviewWritten(saved.storyId).then((result) {
      if (!mounted || !result.unlocked.contains('reviewer')) return;
      final name = rewardBadgeName('reviewer', sw: sw);
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
        content: Text(sw ? 'Tuzo mpya: $name!' : 'New achievement: $name!'),
      ));
    }));
    setState(() => _review = saved);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
      sw ? 'Maoni yamehifadhiwa kwenye kifaa hiki.' : 'Review saved on this device.',
    )));
  }

  Future<void> _delete() async {
    final sw = context.isSwahili;
    final storyId = widget.storyId;
    final confirmed = await showDialog<bool>(context: context, builder: (dialog) => AlertDialog(
      title: Text(sw ? 'Futa maoni yako?' : 'Delete your review?'),
      actions: <Widget>[
        TextButton(onPressed: () => Navigator.pop(dialog, false), child: Text(sw ? 'Acha' : 'Cancel')),
        FilledButton(onPressed: () => Navigator.pop(dialog, true), child: Text(sw ? 'Futa' : 'Delete')),
      ],
    ));
    if (confirmed != true || !mounted || widget.storyId != storyId) return;
    final ok = await widget.store.delete(storyId);
    if (!mounted || widget.storyId != storyId) return;
    if (ok) setState(() => _review = null);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok
        ? (sw ? 'Maoni yamefutwa.' : 'Review deleted.')
        : (sw ? 'Haikuwezekana kufuta. Jaribu tena.' : 'Could not delete. Try again.'))));
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text(sw ? 'Maoni ya Wasomaji' : 'Reader reviews',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: AppSpacing.sm),
        Text(sw ? 'Maoni yako yanabaki kwenye kifaa hiki; hayashirikiwi mtandaoni.'
            : 'Your review stays on this device; it is not shared online.',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        if (_loading) const Center(child: CircularProgressIndicator())
        else if (_readFailed) ...<Widget>[
          Text(sw ? 'Haikuwezekana kusoma maoni yako.' : 'Could not load your review.'),
          TextButton(onPressed: _load, child: Text(sw ? 'Jaribu tena' : 'Try again')),
        ] else ...<Widget>[
          if (_review != null) ...<Widget>[
            Text(sw ? 'Kwenye kifaa hiki: 1 maoni • ${_review!.rating}.0/5'
                : 'On this device: 1 review • ${_review!.rating}.0/5',
                style: Theme.of(context).textTheme.labelLarge),
            for (int star = 5; star >= 1; star--)
              Row(children: <Widget>[
                SizedBox(width: 28, child: Text('$star ★')),
                Expanded(child: LinearProgressIndicator(
                  value: _review!.rating == star ? 1 : 0,
                  minHeight: 5,
                )),
                const SizedBox(width: 8),
                Text(_review!.rating == star ? '1' : '0'),
              ]),
            const SizedBox(height: AppSpacing.sm),
            Card(
            color: colors.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                Text(sw ? 'Maoni yako • kifaa hiki' : 'Your review • this device',
                  style: Theme.of(context).textTheme.labelLarge),
                Text('★' * _review!.rating + '☆' * (5 - _review!.rating),
                  style: TextStyle(color: colors.primary, fontSize: 22)),
                Text(_review!.name.trim().isEmpty ? (sw ? 'Msomaji' : 'Reader') : _review!.name,
                  style: Theme.of(context).textTheme.titleSmall),
                if (_review!.tags.isNotEmpty) Wrap(spacing: 6, children: <Widget>[
                  for (final key in _review!.tags)
                    if (_tags.containsKey(key)) Chip(label: Text(sw ? _tags[key]!.$1 : _tags[key]!.$2)),
                ]),
                if (_review!.comment.trim().isNotEmpty) Text(_review!.comment),
                TextButton(onPressed: _delete, child: Text(sw ? 'Futa maoni' : 'Delete review')),
              ]),
            ),
          ),
          ],
          OutlinedButton.icon(
            key: const ValueKey('write-review'), onPressed: _edit,
            icon: const Icon(Icons.edit_rounded),
            label: Text(_review == null ? (sw ? 'Andika Maoni' : 'Write a review')
                : (sw ? 'Hariri Maoni' : 'Edit review')),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Card(
          color: colors.surfaceContainerLow,
          child: ListTile(
            leading: const Icon(Icons.lightbulb_outline_rounded),
            title: Text(sw ? 'Mfano wa maoni (demo)' : 'Example review (demo)'),
            subtitle: Text(sw ? '“Nilipenda picha za hadithi!” — mfano tu, si maoni ya msomaji halisi.'
                : '“I liked the story pictures!” — an example, not a real reader review.'),
          ),
        ),
      ]),
    );
  }
}

class _ReviewEditor extends StatefulWidget {
  const _ReviewEditor({required this.storyId, required this.initial, required this.store});
  final String storyId;
  final LocalStoryReview? initial;
  final LocalReviewStore store;
  @override
  State<_ReviewEditor> createState() => _ReviewEditorState();
}

class _ReviewEditorState extends State<_ReviewEditor> {
  late final TextEditingController _name = TextEditingController(text: widget.initial?.name ?? '');
  late final TextEditingController _comment = TextEditingController(text: widget.initial?.comment ?? '');
  late int _rating = widget.initial?.rating ?? 0;
  late final Set<String> _selected = {...?widget.initial?.tags};
  bool _saving = false;
  bool _failed = false;

  @override
  void dispose() { _name.dispose(); _comment.dispose(); super.dispose(); }

  Future<void> _save() async {
    if (_rating == 0 || _saving) return;
    setState(() { _saving = true; _failed = false; });
    final review = LocalStoryReview(storyId: widget.storyId, rating: _rating,
      name: _name.text.trim(), comment: _comment.text.trim(),
      tags: _selected.toList(), updatedAt: DateTime.now());
    final ok = await widget.store.save(review);
    if (!mounted) return;
    if (ok) Navigator.of(context).pop(review);
    else setState(() { _saving = false; _failed = true; });
  }

  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Text(sw ? 'Maoni yako' : 'Your review', style: Theme.of(context).textTheme.titleLarge),
            Text(sw ? 'Chagua nyota. Usijumuishe taarifa binafsi za mtoto.'
                : 'Choose a rating. Please do not include a child’s personal information.'),
            Wrap(children: <Widget>[
              for (int i = 1; i <= 5; i++)
                IconButton(
                  key: ValueKey('review-star-$i'),
                  tooltip: sw ? 'Nyota $i' : '$i stars',
                  onPressed: _saving ? null : () { HapticFeedback.lightImpact(); setState(() => _rating = i); },
                  icon: Icon(i <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: colors.primary),
                ),
            ]),
            Wrap(spacing: 6, children: <Widget>[
              for (final entry in _tags.entries)
                FilterChip(label: Text(sw ? entry.value.$1 : entry.value.$2),
                  selected: _selected.contains(entry.key),
                  onSelected: _saving ? null : (selected) => setState(() {
                    if (selected) { _selected.add(entry.key); } else { _selected.remove(entry.key); }
                  })),
            ]),
            TextField(controller: _name, maxLength: 40, enabled: !_saving,
              decoration: InputDecoration(labelText: sw ? 'Jina la kuonyesha (hiari)' : 'Display name (optional)')),
            TextField(controller: _comment, maxLength: 500, maxLines: 3, enabled: !_saving,
              decoration: InputDecoration(labelText: sw ? 'Ulipenda nini? (hiari)' : 'What did you like? (optional)')),
            if (_failed) Text(sw ? 'Haikuwezekana kuhifadhi. Jaribu tena.' : 'Could not save. Try again.',
              style: TextStyle(color: colors.error)),
            const SizedBox(height: AppSpacing.sm),
            FilledButton(key: const ValueKey('save-review'), onPressed: _rating == 0 || _saving ? null : _save,
              child: Text(sw ? 'Hifadhi kwenye kifaa' : 'Save on device')),
          ]),
        ),
      ),
    );
  }
}
