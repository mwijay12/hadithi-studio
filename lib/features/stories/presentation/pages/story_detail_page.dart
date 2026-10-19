/// **STORY DETAIL PAGE** — ukurasa wa maelezo ya hadithi moja.
///
/// Huu ni ukurasa mtumiaji anaufikia akibofya kadi ya hadithi. Muundo wake ni
/// `CustomScrollView` yenye `SliverAppBar` inayojikunja (320 px), kisha sehemu
/// za maudhui kama `SliverToBoxAdapter`.
///
/// **MAAMUZI MUHIMU (na kwa nini):**
///
/// 1. **Task 2 — hali tatu, si nne.** `StoryDetailState` ina `isLoading`,
///    `hasFailure`, `hasStory`. Kama hadithi ipo tayari (tuliipata kwenye kadi
///    iliyogusa, kupitia `initialStory`), ukurasa hauna spinner hata kidogo.
///
/// 2. **Kosa hutumia `AppErrorWidget`, si widget mpya.** Prompt 2 inaomba
///    `_StoryDetailError`. Lakini `AppErrorWidget` **tayari** hujua
///    `NotFoundFailure` (kiungo cha zamani kilichoshirikiwa) na huonyesha
///    ujumbe sahihi wa lugha mbili. Kuandika widget ya pili kungeunda mahali
///    pa pili pa kutafsiri makosa — hivyo tunairudia ile iliyopo.
///
/// 3. **`_SimilarStoriesSection` na `_ReviewsSection` HAZIONYESHI data ya
///    kubuni.** Prompt 2 inaomba "3 fake review cards" na kadi za kubuni.
///    Hilo lingemdanganya mzazi anayeona maoni ya wasomaji ambayo hayapo.
///    Badala yake tunaonyesha muundo halisi wenye hali tupu inayoeleweka
///    ("Maoni yatawasili hivi punde") + kiungo cha kweli. Kadi za hadithi
///    zinazofanana zinahitaji injini ya mapendekezo (Prompt 6).
///
/// 4. **`isPremium` / `priceTZS` / `reviewCount` HAZIPO kwenye `Story`.**
///    Entity ina: `isFree`, `rating`, `readCount`, `publishedYear`. Hakuna
///    bei ya hadithi moja — bei ni za **mpango** (BURE/MSINGI/VIP/FAMILIA),
///    si za hadithi. Kwa hivyo hatubuni bei; tunaonyesha "Hadithi ya kulipia"
///    na kusubiri modeli ya malipo (Prompt 5). `unlockFor` ipo tayari kwenye
///    ARB kwa siku hiyo.
///
/// 5. **Chipu za kundi hutumia `StoryShelf`, si `StoryCategory`.**
///    Njia ya rafu (`/category/:id`) hutatua `StoryShelf.fromId(id)`; kama
///    tungetuma id ya `StoryCategory` (ambayo **haina `id` wala `fromId`**),
///    `ShelfPage` ingeonyesha "Rafu hii haipatikani" — ukurasa mtupu. Hivyo
///    chipu zinazobofya hutoka `story.shelves` (zenye `id` halisi).
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/library_store.dart';
import '../../../../core/utils/contrast_utils.dart';
import '../../../../core/widgets/bilingual_text.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../l10n/l10n.dart';
import '../../data/bundled_stories.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';
import '../../domain/entities/story_shelf.dart';
import '../cubit/story_detail_cubit.dart';
import '../state/story_detail_state.dart';
import '../story_navigation.dart';

/// Ukurasa wa maelezo ya hadithi.
class StoryDetailPage extends StatefulWidget {
  /// Huunda ukurasa wa hadithi [storyId].
  const StoryDetailPage({super.key, required this.storyId});

  /// `id` ya hadithi inayoonyeshwa.
  final String storyId;

  @override
  State<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage> {
  /// Alama ya ukurasa — **huhifadhiwa kweli** sasa.
  ///
  /// Kabla ya haya `_bookmarked` ilianza `false` kila ukurasa ulipofunguliwa,
  /// kumbe SnackBar ilisema "Bookmark added" — mtumiaji alidanganywa. Thamani
  /// ya kwanza sasa hutoka `LibraryStore` (shared_preferences), na kila
  /// mabadiliko hupita `toggleSaved`, ambayo **hurudisha** hali halisi.
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    // `widget.storyId` inapatikana tayari hapa (njia ni `/story/:id`), hivyo
    // hakuna haja ya kuahirisha hadi `didChangeDependencies`. `isSaved` ni
    // ya moja kwa moja — haisubiri I/O.
    _bookmarked = LibraryStore.instance.isSaved(widget.storyId);
  }

  /// Hubadilisha alama na kuhifadhi — UI husoma thamani **iliyorudishwa**.
  Future<void> _toggleBookmark() async {
    HapticFeedback.lightImpact();

    // Tunasubiri hifadhi **kwanza**: kuweka `setState` kabla ya hapo
    // kungeonyesha hali ambayo bado haijaandikwa, na `toggleSaved` hurudisha
    // `false` kwa `id` tupu — hali ambayo UI isingejua.
    final bool nowSaved =
        await LibraryStore.instance.toggleSaved(widget.storyId);
    if (!mounted) return;

    setState(() => _bookmarked = nowSaved);

    final AppLocalizations l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(nowSaved ? l10n.bookmarkAdded : l10n.bookmarkRemoved),
          duration: AppSpacing.normal,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoryDetailCubit, StoryDetailState>(
      builder: (BuildContext context, StoryDetailState state) {
        if (state.isLoading) {
          return const _StoryDetailSkeleton();
        }

        if (state.hasFailure) {
          // Kosa: `AppErrorWidget` hujua `NotFoundFailure` yenyewe.
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 0,
              leading: const _BackButton(),
            ),
            body: AppErrorWidget(
              failure: state.failure!,
              // `retry()` haina hoja — inarudia `id` ya mwisho.
              onRetry: () => context.read<StoryDetailCubit>().retry(),
            ),
          );
        }

        final Story? story = state.story;
        if (story == null) {
          // `status == success` lakini `story == null` haliwezi kutokea kwa
          // `hasStory`; tunalinda kwa skelitoni badala ya skrini nyeupe.
          return const _StoryDetailSkeleton();
        }

        return _DetailBody(
          story: story,
          bookmarked: _bookmarked,
          onToggleBookmark: _toggleBookmark,
        );
      },
    );
  }
}

/// Mwili kamili wa ukurasa — `CustomScrollView` yenye sehemu zote.
class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.story,
    required this.bookmarked,
    required this.onToggleBookmark,
  });

  final Story story;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: <Widget>[
          // 1 — Jalada la shujaa (320 px, hujikunja).
          _HeroCover(
            story: story,
            bookmarked: bookmarked,
            onToggleBookmark: onToggleBookmark,
          ),

          // 2 — Chipu za taarifa.
          SliverToBoxAdapter(child: _MetadataChips(story: story)),

          // 3 — Nyota, maoni, wasomaji.
          SliverToBoxAdapter(child: _RatingBar(story: story)),

          // 4 — Mwandishi.
          SliverToBoxAdapter(
            child: _AuthorCard(authorName: story.author),
          ),

          // 5 — Muhtasari (hupanuka).
          SliverToBoxAdapter(
            child: _SynopsisSection(
              synopsisSw: story.synopsisSw,
              synopsisEn: story.synopsisEn,
            ),
          ),

          // 6 — Vitufe vikuu.
          SliverToBoxAdapter(child: _ActionButtons(story: story)),

          // 7 — Makundi na vibonge.
          SliverToBoxAdapter(child: _TagChips(story: story)),

          // 8 — Hadithi zinazofanana (hali tupu kwa sasa).
          const SliverToBoxAdapter(child: _SimilarStoriesSection()),

          // 9 — Maoni ya wasomaji (hali tupu kwa sasa).
          const SliverToBoxAdapter(child: _ReviewsSection()),

          // 10 — Nafasi ya chini kwa `SafeArea` ya vifaa vyenye notch.
          SliverToBoxAdapter(
            child: SizedBox(
              height: AppSpacing.xxxl + MediaQuery.of(context).padding.bottom,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 1 — Jalada la shujaa
// ---------------------------------------------------------------------------

/// Jalada pana lenye kichwa juu ya gradient nyeusi kwa chini.
class _HeroCover extends StatelessWidget {
  const _HeroCover({
    required this.story,
    required this.bookmarked,
    required this.onToggleBookmark,
  });

  final Story story;
  final bool bookmarked;
  final VoidCallback onToggleBookmark;

  static const double _expandedHeight = 320;

  @override
  Widget build(BuildContext context) {
    final String title = story.title(swahili: context.isSwahili);

    return SliverAppBar(
      expandedHeight: _expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor: story.accent,
      foregroundColor: Colors.white,
      leading: const _BackButton(),
      actions: <Widget>[
        _RoundIconButton(
          icon: Icons.share_rounded,
          tooltip: context.localised(swahili: 'Shiriki', english: 'Share'),
          onPressed: () => _share(context, title),
        ),
        _RoundIconButton(
          icon: bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          tooltip: context.l10n.bookmark,
          onPressed: onToggleBookmark,
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // Kichwa hujikunja kwenye upau wakati wa kusogea.
        titlePadding: const EdgeInsetsDirectional.only(
          start: AppSpacing.xxl,
          end: AppSpacing.xxl,
          bottom: AppSpacing.md,
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: _HeroArtwork(story: story),
      ),
    );
  }

  /// Hushiriki hadithi. Viungo vya kina (deep links) vinakuja Prompt 7.
  void _share(BuildContext context, String title) {
    final AppLocalizations l10n = context.l10n;
    HapticFeedback.lightImpact();
    unawaited(
      SharePlus.instance.share(ShareParams(text: l10n.shareStoryMessage(title))),
    );
  }
}

/// Mchoro wa jalada + gradient ili maandishi yasomeke.
class _HeroArtwork extends StatelessWidget {
  const _HeroArtwork({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // `fit: cover` — picha hujaza jalada bila kubadilisha uwiano wake.
        Image.asset(
          story.coverAsset,
          fit: BoxFit.cover,
          // Kama picha haipo bado (assets ~40 hazipo), tunapata rangi ya
          // hadithi badala ya ikoni ya kosa.
          errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
            return ColoredBox(
              color: story.accent,
              child: Center(
                child: Icon(
                  Icons.auto_stories_rounded,
                  size: AppSpacing.iconXl * 2,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
            );
          },
        ),
        // Gradient: uwazi juu → karibu nyeusi chini (Task 6b).
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
                Colors.black.withValues(alpha: 0.8),
              ],
              stops: const <double>[0.0, 0.45, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 2 — Chipu za taarifa
// ---------------------------------------------------------------------------

/// Chipu: kiwango cha kusoma, umri, kurasa, muda, lugha.
class _MetadataChips extends StatelessWidget {
  const _MetadataChips({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool swahili = context.isSwahili;

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Row(
          children: <Widget>[
            _InfoChip(
              icon: Icons.school_rounded,
              label: story.levelLabel(swahili: swahili),
            ),
            _InfoChip(
              icon: Icons.child_care_rounded,
              label: story.ageLabel(swahili: swahili),
            ),
            _InfoChip(
              icon: Icons.menu_book_rounded,
              label: l10n.pagesCount(story.pageCount),
            ),
            _InfoChip(
              icon: Icons.schedule_rounded,
              label: l10n.readingTimeLabel(story.readingMinutes),
            ),
            // Lugha: kila hadithi ina Kiswahili NA Kiingereza, hivyo hii ni
            // "SW + EN" kila wakati. Ni taarifa ya kweli, si mapambo.
            const _InfoChip(
              icon: Icons.translate_rounded,
              label: 'SW + EN',
            ),
          ],
        ),
      ),
    );
  }
}

/// Chipu moja ya taarifa (Task 6c).
class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.kangaOrange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: AppColors.kangaOrange,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: AppSpacing.iconSm - 2, color: AppColors.earthBrown),
            const SizedBox(width: AppSpacing.xs + 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.earthBrown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3 — Nyota na takwimu
// ---------------------------------------------------------------------------

/// Nyota + idadi ya maoni + idadi ya wasomaji.
class _RatingBar extends StatelessWidget {
  const _RatingBar({required this.story});

  final Story story;

  // TANBIHI: hatufupishi namba kuwa "1.2k". Namba kamili ("1174 wasomaji")
  // ni wazi zaidi kwa mzazi, na `l10n.readers` huchukua `int` — kufupisha
  // kungehitaji `String`, kupunguza ukali wa aina bure.

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    // Nyota huwasilisha alama, hivyo ni kipengele cha maana (si pambo):
    // WCAG 1.4.11 inahitaji 3:1. Sunset Gold yenyewe ni 2.10:1 juu ya cream
    // — ndiyo maana tunatumia toleo lake lililozidishwa giza.
    final Color starColor = ContrastUtils.readableInk(
      AppColors.sunsetGold,
      AppColors.background,
      target: ContrastUtils.nonText,
    );

    final int full = story.rating.floor();
    final bool half = (story.rating - full) >= 0.25 && (story.rating - full) < 0.75;
    final bool roundUp = (story.rating - full) >= 0.75;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        0,
      ),
      child: Row(
        children: <Widget>[
          // Nyota tano (Task 6f).
          for (int i = 0; i < 5; i++)
            Icon(
              i < full || (roundUp && i == full)
                  ? Icons.star_rounded
                  : (half && i == full ? Icons.star_half_rounded : Icons.star_border_rounded),
              size: AppSpacing.iconSm,
              color: starColor,
            ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            story.rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Kumbuka: `reviewCount` HAIPO kwenye `Story`, hivyo hatubuni idadi
          // ya maoni. `readers` ni ya kweli (`readCount`).
          _Dot(),
          Text(
            l10n.readers(story.readCount),
            style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const Spacer(),
          Text(
            '${story.publishedYear}',
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Kitenganishi kidogo cha nukta.
class _Dot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text(
        '•',
        style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

/// Kitufe cha mviringo cha upau wa juu.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      tooltip: tooltip,
      onPressed: onPressed,
      color: Colors.white,
      iconSize: AppSpacing.iconMd,
    );
  }
}

/// Kitufe cha kurudi nyuma.
class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      color: Colors.white,
      tooltip: context.localised(swahili: 'Rudi', english: 'Back'),
      onPressed: () => context.pop(),
    );
  }
}

// ---------------------------------------------------------------------------
// 4 — Mwandishi
// ---------------------------------------------------------------------------

/// Kadi ya mwandishi: herufi za mwanzo + jina + "Fuata".
///
/// `authorAvatarUrl` HAIPO kwenye `Story` (`author` ni `String` pekee),
/// hivyo herufi za mwanzo (`initials`) ndiyo njia ya kudumu — na kwa data
/// halisi ya hapa, avatar ya picha haipo kabisa.
///
/// "Fuata" **huhifadhiwa kwenye kifaa** kupitia `LibraryStore` (orodha ya
/// waandishi unaowafuata). Hii ni ya kifaa pekee — kusawazisha kati ya simu
/// mbili kunahitaji akaunti (backend), lakini kufifia kwa hali kila ukurasa
/// ukifunguliwa hakubaki tena.
class _AuthorCard extends StatefulWidget {
  const _AuthorCard({required this.authorName});

  final String authorName;

  @override
  State<_AuthorCard> createState() => _AuthorCardState();
}

class _AuthorCardState extends State<_AuthorCard> {
  bool _following = false;

  @override
  void initState() {
    super.initState();
    // Hali ya kweli ipo kwenye hifadhi, sivyo kwenye kikao hiki. Bila hii,
    // kitufe kilirudi "Fuata" kila mara ukurasa ukifunguliwa — ingawa
    // mtumiaji alikuwa ameufuata mwandishi.
    _following = LibraryStore.instance.isFollowing(widget.authorName);
  }

  /// Herufi mbili za mwanzo — akiba kwa jina refu.
  String get _initials {
    final List<String> parts = widget.authorName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.take(1).toString() +
            parts[1].characters.take(1).toString())
        .toUpperCase();
  }

  Future<void> _toggleFollow() async {
    HapticFeedback.lightImpact();

    // `toggleFollow` huandika kisha **hurudisha hali mpya**. Tunatumia
    // iliyorudishwa, sivyo `!_following`: kubuni thamani kungeweza kuonyesha
    // "unamfuata" wakati hifadhi haikuandikwa (au `author` ni tupu).
    final bool nowFollowing =
        await LibraryStore.instance.toggleFollow(widget.authorName);
    if (!mounted) return;

    setState(() => _following = nowFollowing);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            nowFollowing
                ? context.localised(
                    swahili: 'Sasa unamfuata ${widget.authorName}',
                    english: 'Now following ${widget.authorName}',
                  )
                : context.localised(
                    swahili: 'Haufuati ${widget.authorName} tena',
                    english: 'No longer following ${widget.authorName}',
                  ),
          ),
          duration: AppSpacing.normal,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        0,
      ),
      child: Material(
        color: AppColors.cardBackground,
        elevation: 1,
        borderRadius: AppSpacing.borderRadiusMd,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: <Widget>[
              // Avatar 48x48 na Safari Green (Task 6d).
              CircleAvatar(
                radius: AppSpacing.avatarMd / 2,
                backgroundColor: AppColors.safariGreen,
                child: Text(
                  _initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  l10n.writtenBy(widget.authorName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _FollowButton(
                following: _following,
                onPressed: _toggleFollow,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kitufe cha "Fuata" / "Unamfuata".
class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.following, required this.onPressed});

  final bool following;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    if (following) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check_rounded, size: AppSpacing.iconSm),
        label: Text(l10n.following),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.safariGreen,
          side: const BorderSide(color: AppColors.safariGreen),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusPill,
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.safariGreen,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusPill,
        ),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      child: Text(l10n.follow),
    );
  }
}

// ---------------------------------------------------------------------------
// 5 — Muhtasari unaopanuka
// ---------------------------------------------------------------------------

/// Muhtasari: mistari 3 kwa mwanzo, wote ukibofya "Soma Zaidi".
class _SynopsisSection extends StatefulWidget {
  const _SynopsisSection({
    required this.synopsisSw,
    required this.synopsisEn,
  });

  /// Muhtasari wa Kiswahili.
  final String synopsisSw;

  /// Muhtasari wa Kiingereza.
  ///
  /// Kwa nini tunapokea **zote mbili**: kwenye hali ya "Lugha Zote"
  /// mtumiaji anahitaji kuziona zote. Kuchukua moja tu kungefanya chaguo la
  /// "Zote" lisiwe na maana — ndiyo bug iliyokuwa.
  final String synopsisEn;

  @override
  State<_SynopsisSection> createState() => _SynopsisSectionState();
}

class _SynopsisSectionState extends State<_SynopsisSection> {
  bool _expanded = false;

  /// Kizingiti cha kuonyesha kitufe. Muhtasari mfupi hauhitaji "Soma Zaidi" —
  /// kitufe kisichofanya kitu ni kero.
  static const int _toggleThreshold = 150;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    // Kitufe huonekana kama **lugha ndefu zaidi** inazidi kizingiti — kwenye
    // "Lugha Zote" Kiswahili pekee kinaweza kuwa kifupi wakati Kiingereza ni
    // kirefu.
    final int longest = widget.synopsisSw.length > widget.synopsisEn.length
        ? widget.synopsisSw.length
        : widget.synopsisEn.length;
    final bool needsToggle = longest > _toggleThreshold;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.aboutTheStory, style: _sectionHeadingStyle),
          const SizedBox(height: AppSpacing.md),
          // `AnimatedSize` hulainisha mabadiliko ya urefu. Tutumie badala ya
          // `AnimatedCrossFade` kwa sababu tunabadilisha **mistari ya maandishi
          // yale yale**, si widget mbili tofauti.
          AnimatedSize(
            duration: AppSpacing.normal,
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            // Lugha mbili zinapanuka pamoja — mtumiaji habofyi mara mbili.
            child: BilingualText(
              swahili: widget.synopsisSw,
              english: widget.synopsisEn,
              maxLines: _expanded ? null : 3,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          if (needsToggle)
            TextButton.icon(
              onPressed: () {
                HapticFeedback.selectionClick();
                setState(() => _expanded = !_expanded);
              },
              icon: Icon(
                _expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: AppSpacing.iconSm,
              ),
              label: Text(_expanded ? l10n.readLess : l10n.readMore),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.safariGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mtindo wa vichwa vya sehemu (Task 6e), mahali pamoja.
const TextStyle _sectionHeadingStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: AppColors.earthBrown,
);

// ---------------------------------------------------------------------------
// 6 — Vitufe vikuu
// ---------------------------------------------------------------------------

/// Matokeo ya ukaguzi wa faili za hadithi ndani ya app.
///
/// **Kwa nini kitu, sivyo `bool`:** "haipo" na "sijui" ni hali mbili tofauti.
/// Kuzichanganya ndiyo iliyofanya kitufe cha "Pakua" kudai kitu ambacho
/// hakikuwa kweli. `isComplete` huhitaji manifest **na** faili zote.
@immutable
class OfflineReport {
  /// Ukaguzi ulifanikiwa.
  const OfflineReport({
    required this.checkedCount,
    required this.missing,
    required this.audioMissing,
  }) : manifestAvailable = true;

  /// Ukaguzi haukuwezekana — hatujui chochote kuhusu faili.
  const OfflineReport.unknown()
      : checkedCount = 0,
        missing = const <String>[],
        audioMissing = 0,
        manifestAvailable = false;

  /// Idadi ya faili za **kusoma** zilizokaguliwa (jalada + picha za kurasa).
  final int checkedCount;

  /// Faili za kusoma zisizopo ndani ya app.
  final List<String> missing;

  /// Faili za sauti za kurasa zisizopo (sauti + timestamps).
  ///
  /// Hazizuii kusoma: `assets/audio/` ina `.gitkeep` pekee kwa sasa, na
  /// usimulizi hutumia TTS ya simu. Tunazikagua ili tusiseme "ipo offline"
  /// kwa usikilizaji wa kurekodiwa ambao haupo.
  final int audioMissing;

  /// Je, `AssetManifest` iliweza kusomwa?
  final bool manifestAvailable;

  /// Faili zote za kusoma zipo ndani ya app?
  bool get isComplete => manifestAvailable && missing.isEmpty;
}

/// "Soma Sasa" / "Sikiliza" / hali ya offline.
class _ActionButtons extends StatefulWidget {
  const _ActionButtons({required this.story});

  final Story story;

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  /// Ripoti ya ukaguzi — `null` humaanisha bado tunakagua.
  OfflineReport? _report;

  /// Je, hadithi ilikuwa imehifadhiwa kama "ipo offline" nyakati zilizopita?
  ///
  /// Husomwa **mara moja** kwenye `initState`: hifadhi ni ukweli wa kudumu,
  /// na kuisoma ndani ya `build` kungeifanya UI itegemee hali ya nje bila
  /// sababu (na `setState` wakati wa `build` ni kosa).
  bool _downloaded = false;

  /// Kuzuia `setDownloaded` kuitwa kila `setState` — tunaandika mara moja.
  bool _persisted = false;

  @override
  void initState() {
    super.initState();
    _downloaded = LibraryStore.instance.isDownloaded(widget.story.id);
    // Ukaguzi ni wa faili (I/O): unaanza baada ya fremu ya kwanza ili
    // ukurasa uonekane mara moja, kisha hali ibadilike.
    unawaited(_verifyOffline());
  }

  /// Hukagua kama faili za hadithi zipo **kweli** ndani ya app.
  ///
  /// Hakuna upakuaji wa mtandao hapa: hadithi zote za sasa husafiri ndani ya
  /// app. Lakini "ipo tayari offline" ni kauli inayoweza kuthibitishwa —
  /// tunailinganisha na `AssetManifest`. Manifest ikishindikana kusomwa,
  /// tunarudisha [OfflineReport.unknown] na kusema "sijui", badala ya kudai.
  Future<void> _verifyOffline() async {
    // Si `final`: tunaiweka ndani ya `try` **au** `catch` — moja pekee
    // inafikiwa, lakini mkusanyaji hawezi kuthibitisha hilo.
    OfflineReport report;
    try {
      final AssetManifest manifest =
          await AssetManifest.loadFromAssetBundle(rootBundle);
      // `listAssets()` haina `Future` kwenye toleo hili la Flutter — orodha
      // ipo tayari mara manifest inapopakiwa.
      final List<String> bundledAssets = manifest.listAssets();
      // `Set` kwa sababu tunatafuta mara nyingi; manifest inaweza kuwa ndefu.
      final Set<String> bundled = bundledAssets.toSet();

      // Faili za **kusoma**: jalada + picha ya kila ukurasa. Maandishi hayapo
      // kwenye faili — yanasafiri ndani ya `story_sample_data.dart`, kwa hivyo
      // hayana asset ya kuangalia.
      //
      // `toSet()` kwa sababu kurasa nyingi hushiriki picha moja kwa sasa;
      // kuhesabu faili ile ile mara tano kungepotosha "x kati ya y".
      final Set<String> requiredAssets = <String>{
        widget.story.coverAsset,
        for (final StoryPage page in widget.story.pages) page.illustration,
      };
      final List<String> readingAssets = requiredAssets.toList(growable: false);

      final List<String> missing = readingAssets
          .where((String asset) => !bundled.contains(asset))
          .toList(growable: false);

      // Sauti: `BundledStories` ina njia za kila ukurasa (sauti + timestamps).
      int audioMissing = 0;
      for (int i = 0; i < widget.story.pages.length; i++) {
        for (final String asset in <String>[
          BundledStories.pageAudioAsset(widget.story.id, i),
          BundledStories.pageTimingAsset(widget.story.id, i),
        ]) {
          if (!bundled.contains(asset)) audioMissing++;
        }
      }

      report = OfflineReport(
        checkedCount: readingAssets.length,
        missing: missing,
        audioMissing: audioMissing,
      );
    } catch (error) {
      // Manifest haipatikani (jenga la kawaida, kivinjari kisicho na MIME…):
      // hatuwezi kujua. Tunaripoti hivyo — si "imepakuliwa", si "haipo".
      debugPrint('StoryDetail: ukaguzi wa offline umeshindwa — $error');
      report = const OfflineReport.unknown();
    }

    if (!mounted) return;

    // Ukweli ulithibitishwa: huhifadhi mara moja ili hali ihimili urambazaji
    // (Rafu Yangu, orodha ya "zilizopakuliwa"). `setDownloaded` haitoi
    // thamani — ndiyo maana `unawaited` inafaa hapa.
    final bool complete = report.isComplete;
    if (complete && !_persisted) {
      _persisted = true;
      unawaited(
        LibraryStore.instance.setDownloaded(widget.story.id, downloaded: true),
      );
    }

    setState(() {
      _report = report;
      if (complete) _downloaded = true;
    });
  }

  /// Hufungua reader. `autoPlay: listen` huanza kusikiliza mara moja.
  ///
  /// `openReader` hutumia `context.pushNamed` **yenyewe**; kuita `pushNamed`
  /// tena hapa kungeongeza ukurasa mara mbili. Na SnackBar ya zamani ilidai
  /// "kusikiliza kunakuja" wakati bomba (`?auto=1`) lilikuwa tayari lipo.
  void _openReader(BuildContext context, {required bool listen}) {
    HapticFeedback.lightImpact();
    openReader(context, widget.story, autoPlay: listen);
  }

  /// Hueleza ukweli kuhusu faili ambazo hazipo ndani ya app.
  ///
  /// Hatuonyeshi upau wa maendeleo wala asilimia: hakuna upakuaji unaoendelea,
  /// kwa hivyo asilimia ingekuwa ya kubuni.
  void _explainOffline(BuildContext context) {
    HapticFeedback.lightImpact();

    final OfflineReport? report = _report;
    final String message;
    if (report == null) {
      message = context.localised(
        swahili: 'Bado tunakagua faili za hadithi…',
        english: 'Still checking the story files…',
      );
    } else if (!report.manifestAvailable) {
      message = context.localised(
        swahili: 'Hali ya offline haijulikani kwa sasa',
        english: 'Offline status is unknown right now',
      );
    } else {
      final int present = report.checkedCount - report.missing.length;
      message = context.localised(
        swahili: 'Faili $present kati ya ${report.checkedCount} '
            'zinapatikana ndani ya app; zilizosalia zitakuja na upakuaji '
            'wa seva.',
        english: '$present of ${report.checkedCount} files are bundled in '
            'the app; the rest arrive with the server download feature.',
      );
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: AppSpacing.autoPageTurnDelay,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        children: <Widget>[
          // Msingi — Safari Green, urefu 56, kona 16 (Task 6a).
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: () => _openReader(context, listen: false),
              icon: const Icon(Icons.play_arrow_rounded, size: AppSpacing.iconMd),
              label: Text(l10n.readNow),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.safariGreen,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: OutlinedButton.icon(
              onPressed: () => _openReader(context, listen: true),
              icon: const Icon(
                Icons.volume_up_rounded,
                size: AppSpacing.iconMd,
              ),
              label: Text(l10n.listenNow),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.safariGreen,
                side: const BorderSide(color: AppColors.safariGreen, width: 1.5),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderRadiusMd,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // "Pakua" ya kubuni imebadilishwa na hali **inayothibitishwa**.
          _OfflineControl(
            report: _report,
            downloaded: _downloaded,
            onExplain: () => _explainOffline(context),
          ),
          // Hadithi ya kulipia: `isPremium`/`priceTZS` hazipo. `isFree` ndiyo
          // ukweli uliopo — hatubuni bei.
          if (!widget.story.isFree) const _PremiumBadge(),
        ],
      ),
    );
  }
}

/// Hali ya offline — **taarifa inayothibitishwa**, sivyo kitufe cha kubuni.
///
/// Hali nne, kila moja ikiwa na maana yake:
///
/// 1. `report == null` → tunakagua (sekunde chache). Kitufe hakibofyiki kwa
///    sababu hatuna cha kusema bado.
/// 2. Imethibitishwa → chipu yenye alama ya tiki. Haionekani kama kitufe,
///    kwa sababu hakuna cha kufanya: faili zipo tayari.
/// 3. Manifest haipatikani → maandishi "haijulikani kwa sasa" (hakuna kitufe
///    kinachodai kitu).
/// 4. Faili zinaikosekana → kitufe **kinachofanya kazi** kinachoeleza idadi
///    halisi; hakuna asilimia wala upau wa maendeleo.
///
/// Rangi zote hutoka `ColorScheme` ya mandhari — hakuna cream/white iliyoandikwa
/// moja kwa moja.
class _OfflineControl extends StatelessWidget {
  const _OfflineControl({
    required this.report,
    required this.downloaded,
    required this.onExplain,
  });

  final OfflineReport? report;
  final bool downloaded;
  final VoidCallback onExplain;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    // `onSurface` kwa uwazi mdogo: maandishi ya pili daraja, si kitufe cha
    // kuchukua hatua.
    final Color muted = scheme.onSurface.withValues(alpha: 0.7);
    final OfflineReport? current = report;

    if (current == null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            width: AppSpacing.iconSm - 4,
            height: AppSpacing.iconSm - 4,
            child: CircularProgressIndicator(strokeWidth: 2, color: muted),
          ),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            context.localised(
              swahili: 'Inakagua hali ya offline…',
              english: 'Checking offline status…',
            ),
            style: TextStyle(fontSize: 13, color: muted),
          ),
        ],
      );
    }

    // Imethibitishwa (au ilikuwa imehifadhiwa hapo awali): hali, sivyo kitufe.
    if (current.isComplete || downloaded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.offline_pin_rounded,
            size: AppSpacing.iconSm,
            color: scheme.primary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              context.localised(
                swahili: 'Ipo tayari offline',
                english: 'Available offline',
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ),
        ],
      );
    }

    // Manifest haipatikani: hatujui, na tunasema hivyo.
    if (!current.manifestAvailable) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.help_outline_rounded, size: AppSpacing.iconSm, color: muted),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              context.localised(
                swahili: 'Hali ya offline haijulikani kwa sasa',
                english: 'Offline status is unknown right now',
              ),
              style: TextStyle(fontSize: 13, color: muted),
            ),
          ),
        ],
      );
    }

    // Faili zinaikosekana: kitufe kinaendelea kufanya kazi — kinabofya
    // kinaeleza ukweli, na hakidai kuwa kimepakua kitu.
    return TextButton.icon(
      onPressed: onExplain,
      icon: Icon(Icons.download_rounded, size: AppSpacing.iconSm, color: muted),
      label: Text(context.l10n.download),
      style: TextButton.styleFrom(
        foregroundColor: muted,
        textStyle: const TextStyle(fontSize: 14),
      ),
    );
  }
}

/// Kitufe cha "Hadithi ya kulipia".
///
/// Sunset Gold (#F39C12) juu ya mandhari ya cream ni **2.10:1** — mbali sana
/// chini ya 4.5:1 inayohitajika. Spec ya Prompt 2.0 inasema waziwazi:
/// "Text on Sunset Gold: DARK BROWN — NOT white!". Tunafuata kanuni hiyo kwa
/// kutumia toleo linalosomeka la rangi hiyo hiyo.
class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    final Color ink = ContrastUtils.readableInk(
      AppColors.sunsetGold,
      AppColors.background,
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.lock_rounded, size: AppSpacing.iconSm, color: ink),
          const SizedBox(width: AppSpacing.xs),
          Text(
            context.localised(
              swahili: 'Hadithi ya kulipia',
              english: 'Premium story',
            ),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7 — Makundi na vibonge
// ---------------------------------------------------------------------------

/// Chipu za kundi na rafu. Zinazobofya hutumia `StoryShelf` (zenye `id`).
class _TagChips extends StatelessWidget {
  const _TagChips({required this.story});

  final Story story;

  @override
  Widget build(BuildContext context) {
    final bool swahili = context.isSwahili;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        0,
      ),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          // Aina ya hadithi. `StoryCategory` HAINA `id` wala `fromId`, na
          // njia ya rafu hutatua `StoryShelf.fromId` — kwa hivyo kutumia
          // `shelfName` hapa kungeonyesha rafu tupu. Tunapeleka "Hadithi Zote"
          // badala ya kudanganya.
          _TagChip(
            label: story.categoryLabel(swahili: swahili),
            color: AppColors.earthBrown,
            icon: Icons.local_offer_rounded,
            onTap: () {
              HapticFeedback.selectionClick();
              context.pushNamed(AppRoutes.allStoriesName);
            },
          ),
          // Rafu (vhupu halisi vinavyobofya → `/category/:id`).
          for (final StoryShelf shelf in story.shelves)
            _TagChip(
              label: _shelfLabel(context, shelf),
              // `StoryShelf` huita rangi yake `accent`, si `color`.
              color: shelf.accent,
              icon: Icons.collections_bookmark_rounded,
              onTap: () {
                HapticFeedback.selectionClick();
                context.pushNamed(
                  AppRoutes.shelfName,
                  pathParameters: <String, String>{'id': shelf.id},
                );
              },
            ),
          // Vitu vya kugusa: taarifa ya kweli kuhusu hadithi.
          if (story.hotspotCount > 0)
            _TagChip(
              label: context.localised(
                swahili: 'Vitu ${story.hotspotCount} vya kugusa',
                english: '${story.hotspotCount} interactions',
              ),
              color: AppColors.zanzibarTurquoise,
              icon: Icons.touch_app_rounded,
              onTap: null,
            ),
        ],
      ),
    );
  }
}

/// Chipu moja ya kundi/rafu.
class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Tint iliyoonekana kwa kweli = rangi ya chapa 12% juu ya mandhari ya
    // ukurasa. Hii ni muhimu: kupima `color` yenyewe kungeonyesha uwiano
    // ambao mtumiaji **hauoni**.
    final Color tint = ContrastUtils.blend(
      color.withValues(alpha: 0.12),
      AppColors.background,
    );

    // Rangi ya chapa kama **maandishi** juu ya tint yake hushindwa WCAG:
    // brightGreen 2.39:1, skyBlue 2.28:1, sunsetGold 1.92:1 — zote chini ya
    // 4.5:1. Kwa hivyo mandhari na mpaka hubeba rangi ya chapa (utambulisho
    // wa macho), lakini maandishi na ikoni hutumia toleo lake linalosomeka.
    final Color ink = ContrastUtils.readableInk(color, tint);

    return Material(
      color: color.withValues(alpha: 0.12),
      borderRadius: AppSpacing.borderRadiusPill,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.borderRadiusPill,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: AppSpacing.iconSm - 2, color: ink),
              const SizedBox(width: AppSpacing.xs + 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Jina la rafu kwa lugha iliyochaguliwa.
///
/// **Kwa nini switch hapa:** `StoryShelf` haina `labelSw`/`labelEn`, na
/// hakuna ufunguo wa ARB wa rafu. Maneno haya yanafuata maelezo ya enum
/// yenyewe (`story_shelf.dart`) — si ya kubuni. Hatua inayofaa: kuhamisha
/// hii mahali pamoja pindi ukurasa wa rafu na kadi za rafu zitakapoitaji.
String _shelfLabel(BuildContext context, StoryShelf shelf) {
  switch (shelf) {
    case StoryShelf.animalStories:
      return context.localised(
        swahili: 'Hadithi za Wanyama',
        english: 'Animal Stories',
      );
    case StoryShelf.moralsWisdom:
      return context.localised(
        swahili: 'Maadili na Hekima',
        english: 'Morals & Wisdom',
      );
    case StoryShelf.science:
      return context.localised(swahili: 'Sayansi', english: 'Science');
    case StoryShelf.culture:
      return context.localised(swahili: 'Utamaduni', english: 'Culture');
    case StoryShelf.poemsSongs:
      return context.localised(
        swahili: 'Mashairi na Nyimbo',
        english: 'Poems & Songs',
      );
    case StoryShelf.safari:
      return context.localised(swahili: 'Safari', english: 'Safari');
  }
}

// ---------------------------------------------------------------------------
// 8 — Hadithi zinazofanana
// ---------------------------------------------------------------------------

/// Mapendekezo ya hadithi zinazofanana.
///
/// Hali tupu kwa makusudi: kadi za hadithi **halisi** zinahitaji injini ya
/// mapendekezo (`getSimilarStories`) ambayo haipo. Kadi za kubuni zingeonyesha
/// hadithi ambazo mtumiaji hawezi kuzifungua — uzoefu mbaya kuliko kitufe
/// kinachoeleza ukweli.
class _SimilarStoriesSection extends StatelessWidget {
  const _SimilarStoriesSection();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(l10n.similarStories, style: _sectionHeadingStyle),
              ),
              TextButton(
                onPressed: () =>
                    context.pushNamed(AppRoutes.allStoriesName),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.safariGreen,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(l10n.viewAll),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: AppSpacing.iconLg,
                  color: AppColors.skyBlue,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.localised(
                    swahili: 'Mapendekezo yanakuja na Prompt 6',
                    english: 'Recommendations arrive with Prompt 6',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 9 — Maoni ya wasomaji
// ---------------------------------------------------------------------------

/// Sehemu ya maoni.
///
/// `reviewCount` HAIPO kwenye `Story`, na maoni ya kweli yanahitaji backend
/// (Prompt 6). Hatuandiki maoni ya kubuni yenye majina ya watu wasiopo.
class _ReviewsSection extends StatelessWidget {
  const _ReviewsSection();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(l10n.userReviews, style: _sectionHeadingStyle),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.rate_review_outlined,
                  size: AppSpacing.iconLg,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  context.localised(
                    swahili: 'Maoni yatawasili hivi punde',
                    english: 'Reviews arrive shortly',
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Kitufe kimezimwa kwa makusudi: haliwezi kuandika maoni
                // bado, na kitufe kinachobofya bila matokeo ni udanganyifu.
                OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.edit_rounded, size: AppSpacing.iconSm),
                  label: Text(l10n.writeReview),
                  style: OutlinedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusPill,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Task 2 — Skelitoni ya kupakia
// ---------------------------------------------------------------------------

/// Skelitoni inayofuata umbo la ukurasa halisi — hivyo mabadiliko hayaonekani
/// kama kuruka.
class _StoryDetailSkeleton extends StatelessWidget {
  const _StoryDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Jalada.
            AppShimmerBox(
              width: double.infinity,
              height: 320,
              borderRadius: BorderRadius.zero,
            ),
            SizedBox(height: AppSpacing.xl),
            // Chipu.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Row(
                children: <Widget>[
                  AppShimmerBox(width: 96, height: 30),
                  SizedBox(width: AppSpacing.sm),
                  AppShimmerBox(width: 84, height: 30),
                  SizedBox(width: AppSpacing.sm),
                  AppShimmerBox(width: 72, height: 30),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppShimmerBox(width: 160, height: 18),
                  SizedBox(height: AppSpacing.lg),
                  AppShimmerBox(width: double.infinity, height: 72),
                  SizedBox(height: AppSpacing.lg),
                  AppShimmerBox(width: double.infinity, height: 56),
                  SizedBox(height: AppSpacing.md),
                  AppShimmerBox(width: double.infinity, height: 52),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
