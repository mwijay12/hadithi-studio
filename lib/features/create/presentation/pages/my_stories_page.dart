/// **HADITHI ZANGU** — rasimu zilizohifadhiwa kwenye kifaa.
///
/// ## Chanzo cha ukweli ni `LibraryStore`
///
/// Ukurasa huu **hahifadhi** nakala yake ya orodha. Kila kitu hutoka
/// `LibraryStore.instance.drafts` kwa `ListenableBuilder`: hivyo ukifuta
/// rasimu hapa, ukurasa wa "Tengeneza" na mahali pengine pa kutumia hifadhi
/// hiyo huona badiliko **papo hapo**. Nakala ya ndani ingeanza kuacha
/// kuaminika siku ya kwanza.
///
/// ## Hakuna "publish" wala "share"
///
/// Rasimu hii ni ya kifaa pekee. Hakuna seva, hakuna maktaba ya umma.
/// Kwa hivyo hakuna kitufe cha kuchapisha — kitufe kisichofanya kitu ni
/// uongo kwa mtoto anayegusa.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/library_store.dart';
import '../../../../core/widgets/leo_mascot.dart';
import 'draft_preview_page.dart';

/// Orodha ya rasimu, mpya kwanza.
class MyStoriesPage extends StatelessWidget {
  /// Huunda ukurasa.
  const MyStoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double side = context.isCompact ? AppSpacing.lg : AppSpacing.xxl;

    return Scaffold(
      // Rangi hutoka theme — `ListTile` ndani yake huchukua maandishi yake
      // kutoka theme pia, hivyo mandhari ya usiku haipatii maandishi meupe
      // juu ya mandhari nyeupe.
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        title: Text(
          context.isSwahili ? 'Hadithi Zangu' : 'My Stories',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: LibraryStore.instance,
        builder: (BuildContext context, Widget? child) {
          // Hifadhi hupanga mpya kwanza, lakini tunathibitisha hapa pia:
          // `drafts` ni nakala isiyobadilika, hivyo tunapanga nakala yetu.
          final List<DraftStory> drafts = LibraryStore.instance.drafts.toList()
            ..sort(
              (DraftStory a, DraftStory b) =>
                  b.createdAt.compareTo(a.createdAt),
            );

          if (drafts.isEmpty) return const _EmptyStories();

          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              side,
              AppSpacing.lg,
              side,
              AppSpacing.xxxl,
            ),
            itemCount: drafts.length,
            itemBuilder: (BuildContext context, int index) {
              return _DraftTile(draft: drafts[index]);
            },
          );
        },
      ),
    );
  }
}

/// Rasimu moja kwenye orodha.
class _DraftTile extends StatelessWidget {
  const _DraftTile({required this.draft});

  final DraftStory draft;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // `DateFormat.yMMMd()` hufuata lugha ya kifaa (`17 Okt 2026` / `Oct 17, 2026`).
    final String date = DateFormat.yMMMd().format(draft.createdAt);
    final String pageLabel = context.isSwahili
        ? 'kurasa ${draft.pageCount}'
        : draft.pageCount == 1
            ? '1 page'
            : '${draft.pageCount} pages';

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      // `ListTile` hupata rangi zake kutoka theme; `Material` hapa ni
      // kwa mwitikio wa kugusa (ink) juu ya mandhari ya theme.
      child: ListTile(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (BuildContext context) => DraftPreviewPage(draft: draft),
          ),
        ),
        leading: Icon(Icons.auto_stories_rounded, color: scheme.primary),
        title: Text(
          draft.titleSw,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
        subtitle: Text(
          '$pageLabel · $date',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        trailing: IconButton(
          onPressed: () => _confirmDelete(context, draft),
          icon: const Icon(Icons.delete_outline_rounded),
          color: scheme.error,
          tooltip: context.isSwahili ? 'Futa rasimu' : 'Delete draft',
        ),
      ),
    );
  }
}

/// Hali tupu — si kosa, ni mwanzo.
class _EmptyStories extends StatelessWidget {
  const _EmptyStories();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const LeoMascot(pose: LeoPose.curious, height: 140),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.isSwahili ? 'Hakuna hadithi bado' : 'No stories yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              context.isSwahili
                  ? 'Rasimu zako zitaonekana hapa baada ya kuhifadhi.'
                  : 'Your drafts will appear here after you save one.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              // Ukurasa huu hufunguliwa **juu** ya "Tengeneza"; kurudi ni
              // `pop`, sivyo kufungua nakala ya pili ya ukurasa huo.
              onPressed: () {
                final NavigatorState navigator = Navigator.of(context);
                if (navigator.canPop()) navigator.pop();
              },
              icon: const Icon(Icons.edit_rounded),
              label: Text(
                context.isSwahili ? 'Anza Kuandika' : 'Start Writing',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Huuliza uthibitisho kabla ya kufuta — kufuta hakurudishwi.
Future<void> _confirmDelete(BuildContext context, DraftStory draft) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text(context.isSwahili ? 'Futa hadithi?' : 'Delete story?'),
        content: Text(
          context.isSwahili
              ? '"${draft.titleSw}" itafutwa kabisa kwenye kifaa hiki. '
                  'Hakuna njia ya kuirudisha.'
              : '"${draft.titleSw}" will be permanently deleted from this '
                  'device. There is no way to restore it.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.isSwahili ? 'Ghairi' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.isSwahili ? 'Futa' : 'Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

  final bool removed = await LibraryStore.instance.removeDraft(draft.id);
  if (!context.mounted) return;

  context.showSnackBar(
    removed
        ? (context.isSwahili ? 'Rasimu imefutwa.' : 'Draft deleted.')
        : (context.isSwahili
            ? 'Rasimu haikuweza kufutwa kwenye kifaa.'
            : 'The draft could not be deleted on the device.'),
    isError: !removed,
  );
}
