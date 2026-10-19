/// Ukurasa wa **rafu moja** — gridi ya hadithi za kundi moja (`/category/:id`).
///
/// ## Kwa nini rafu, si hadithi
///
/// Kwenye Maktaba, kadi sita za juu ni **makundi** (Wanyama, Maadili,
/// Sayansi…), si hadithi. Kugusa kadi ya kundi hufungua ukurasa huu — orodha
/// ya hadithi zote za kundi hilo. Kuchanganya hizi mbili (kufungua hadithi
/// moja kutoka kadi ya kundi) kunamfanya mtumiaji adhani maktaba ina hadithi
/// moja pekee.
///
/// ## Cubit inatoka kwenye router, si hapa
///
/// Njia ya `/category/:id` (`app_routes.dart`) tayari inafunga ukurasa huu
/// ndani ya `BlocProvider<StoryListCubit>` na kuita `loadShelf(shelf)` kwa
/// `id` inayojulikana. Ukurasa **hauungi cubit mwingine**: kuunda wa pili
/// kungetuma ombi la pili la mtandao na kuzalisha hali mbili zinazopingana.
/// Kazi yetu hapa ni kuonyesha kile cubit alichotoa, na kuongeza mpangilio
/// (sort) na vichujio (filter) vya **kumbukumbu** juu yake.
///
/// ## Kwa nini vichujio viko kwenye kumbukumbu
///
/// `StoryListCubit` haina `sortBy` wala `filterByShelf`: inaleta hadithi
/// zote za rafu kwa ombi moja (maktaba yetu ni fupi). Kwa hivyo vichujio
/// hufanyika kwa [applyStoryQuery] juu ya orodha iliyo tayari — kugusa
/// kichujo ni **papo hapo**, hakuna mzunguko wa mtandao. Sababu kamili iko
/// kwenye doc ya `story_query.dart`.
///
/// ## `StoryShelf.fromId` inaweza kurudisha `null`
///
/// `id` hutoka kwenye URL; inaweza kuwa ya uongo (kiungo kilichoshirikiwa
/// kimeharibika). Kwa hivyo hali tupu inaonekana **kabla** ya `BlocBuilder` —
/// hatuweki rafu ya akiba, kwa sababu kuonyesha hadithi za kundi lingine
/// kwa kiungo kibovu ni udanganyifu.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_shelf.dart';
import '../cubit/story_list_cubit.dart';
import '../state/story_list_state.dart';
import '../story_query.dart';
import '../widgets/shelf_tile.dart';
import '../widgets/story_chip.dart';
import '../widgets/story_grid_view.dart';

/// Orodha ya hadithi za rafu moja, ikiwa na vichujio na mpangilio.
class ShelfPage extends StatefulWidget {
  /// Huunda ukurasa wa rafu [categoryId].
  const ShelfPage({super.key, required this.categoryId});

  /// `id` ya rafu — inafanana na `StoryShelf.id` (`'safari'`, `'science'`…).
  final String categoryId;

  @override
  State<ShelfPage> createState() => _ShelfPageState();
}

class _ShelfPageState extends State<ShelfPage> {
  /// Mpangilio wa sasa. `curated` = mkusanyaji wa maktaba (chanzo-msingi).
  StorySort _sort = StorySort.curated;

  /// Kichujo cha bei cha sasa. `any` = bila kuchuja.
  ///
  /// Ni bei pekee inayochujika kwa kweli: [Story] haina `priceTZS`, wala
  /// lugha, wala kikundi cha umri kinachotofautiana na kile kilichopo. Umri
  /// na kiwango cha kusoma vinachujika kwenye ukurasa wa hadithi **zote**
  /// (karatasi ya vichujio), si hapa — hapa mtumiaji amekwisha chagua kundi
  /// moja kwa kugusa kadi yake.
  StoryPriceFilter _price = StoryPriceFilter.any;

  /// `true` = uwanja wa utafutaji unaonekana chini ya upau wa juu.
  bool _searchOpen = false;

  /// Maandishi ya utafutaji wa sasa.
  String _query = '';

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Hufungua/kufunga uwanja wa utafutaji, ukifuta hoja iliyobaki.
  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  /// Huchagua kichujo cha haraka (chips za kichwa cha gridi).
  ///
  /// Kugusa kichujo kilichochaguliwa tayari **hukiondoa** (kurudi "Zote") —
  /// ndiyo tabia inayotarajiwa kwa chip; "Zote" yenyewe hairudiwi.
  void _applyQuick(_ShelfQuickFilter quick) {
    setState(() {
      if (quick != _ShelfQuickFilter.all && _isQuickSelected(quick)) {
        _sort = StorySort.curated;
        _price = StoryPriceFilter.any;
      } else {
        _sort = quick.sort;
        _price = quick.price;
      }
    });
  }

  /// Hufuta vichujio vyote na utafutaji — "Futa Vichujio".
  void _resetAll() {
    setState(() {
      _sort = StorySort.curated;
      _price = StoryPriceFilter.any;
      _query = '';
      _searchController.clear();
    });
  }

  /// `true` kama [quick] inafafanua hali ya sasa ya kichujio.
  ///
  /// Chip za mpangilio zinahitaji bei kuwa `any` pia: "Mpya" haimaanishi
  /// "Mpya na Bure"; mtumiaji anayechagua "Mpya" kisha "Bure" anaona vichujo
  /// viwili vikiwa vimechaguliwa — na hilo ni kweli.
  bool _isQuickSelected(_ShelfQuickFilter quick) {
    switch (quick) {
      case _ShelfQuickFilter.all:
        return _sort == StorySort.curated && _price == StoryPriceFilter.any;
      case _ShelfQuickFilter.newest:
        return _sort == StorySort.newest && _price == StoryPriceFilter.any;
      case _ShelfQuickFilter.popular:
        return _sort == StorySort.popular && _price == StoryPriceFilter.any;
      case _ShelfQuickFilter.free:
        return _price == StoryPriceFilter.free;
      case _ShelfQuickFilter.premium:
        return _price == StoryPriceFilter.premium;
    }
  }

  /// Lebo ya chip kwa lugha ya sasa.
  String _quickLabel(AppLocalizations l10n, _ShelfQuickFilter quick) {
    switch (quick) {
      case _ShelfQuickFilter.all:
        return l10n.all;
      case _ShelfQuickFilter.newest:
        return l10n.newLabel;
      case _ShelfQuickFilter.popular:
        return l10n.popular;
      case _ShelfQuickFilter.free:
        return l10n.free;
      case _ShelfQuickFilter.premium:
        return l10n.premium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final StoryShelf? shelf = StoryShelf.fromId(widget.categoryId);

    // `storyShelfLabel` inatafsiri kwa lugha ya sasa; tunapitisha kitu kimoja
    // kwa `titleSw` na `titleEn` (chanzo ni l10n, tazama doc ya `AppTopBar`).
    final String title =
        shelf == null ? l10n.library : storyShelfLabel(context, shelf);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppTopBar(
        titleSw: title,
        titleEn: title,
        // Rafu isiyojulikana haina cha kutafuta wala cha kupanga — vitufe
        // vitakuwa vya uongo.
        actions: shelf == null ? null : _actions(context, l10n),
      ),
      body: shelf == null
          ? const _ShelfNotFound()
          : _body(context, l10n, shelf),
    );
  }

  /// Vitufe vya upau wa juu: utafutaji na mpangilio.
  List<Widget> _actions(BuildContext context, AppLocalizations l10n) {
    return <Widget>[
      AppIconButton(
        icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
        tooltipSw: l10n.searchHint,
        tooltipEn: l10n.searchHint,
        onPressed: _toggleSearch,
      ),
      PopupMenuButton<StorySort>(
        tooltip: l10n.sortBy,
        icon: const Icon(Icons.sort_rounded, color: AppColors.earthBrown),
        onSelected: (StorySort sort) => setState(() => _sort = sort),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<StorySort>>[
          for (final StorySort sort in StorySort.values)
            CheckedPopupMenuItem<StorySort>(
              value: sort,
              checked: _sort == sort,
              child: Text(storySortLabel(context, sort)),
            ),
        ],
      ),
    ];
  }

  /// Mwili wa ukurasa: utafutaji, bango, chips, kikokotoo na gridi.
  Widget _body(BuildContext context, AppLocalizations l10n, StoryShelf shelf) {
    return Column(
      children: <Widget>[
        if (_searchOpen) _searchField(context, l10n),
        _ShelfBanner(shelf: shelf),
        StoryChipRow(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            0,
          ),
          children: <Widget>[
            for (final _ShelfQuickFilter quick in _ShelfQuickFilter.values)
              StoryChoiceChip(
                label: _quickLabel(l10n, quick),
                selected: _isQuickSelected(quick),
                onSelected: (bool _) => _applyQuick(quick),
              ),
          ],
        ),
        Expanded(
          child: BlocBuilder<StoryListCubit, StoryListState>(
            builder: (BuildContext context, StoryListState state) {
              // Uchujaji na mpangilio hufanyika hapa, kwenye kumbukumbu, juu
              // ya orodha ambayo cubit tayari ameileta (tazama doc ya faili).
              final List<Story> filtered = applyStoryQuery(
                state.stories,
                sort: _sort,
                filter: StoryFilter(price: _price),
                query: _query,
                swahili: context.isSwahili,
              );

              // Kikokotoo hukaa pale tu data imefika **na** kuna cha kuhesabu.
              // Wakati wa kupakia au kwa kosa, "Hadithi 0 zinapatikana" ni
              // uongo unaochanganya kosa na orodha tupu.
              final bool showCount =
                  state.status == StoryListStatus.success &&
                      filtered.isNotEmpty;

              return Column(
                children: <Widget>[
                  if (showCount) _resultCount(context, l10n, filtered.length),
                  Expanded(
                    child: RefreshIndicator(
                      // `retry()` huchagua ombi sahihi yenyewe: kosa la
                      // utafutaji, rafu, au maktaba yote (tazama cubit).
                      onRefresh: () => context.read<StoryListCubit>().retry(),
                      child: _results(context, l10n, state, filtered),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Uwanja wa utafutaji unaojitokeza kwa kugusa aikoni ya utafutaji.
  ///
  /// Uchujaji ni wa **ndani ya rafu hii**: hakuna ombi la mtandao, kwa hivyo
  /// hakuna `Timer` wa debounce hapa. `cubit.search()` ingeacha rafu na
  /// kurudisha matokeo ya maktaba yote — jambo ambalo hutatanisha mtumiaji
  /// aliyefikia kundi hili kwa kugusa kadi yake.
  Widget _searchField(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        textInputAction: TextInputAction.search,
        onChanged: (String value) => setState(() => _query = value),
        decoration: InputDecoration(
          hintText: l10n.searchHint,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.safariGreen,
          ),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  tooltip: l10n.cancel,
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
        ),
      ),
    );
  }

  /// "Hadithi 24 zinapatikana" — huonyesha idadi **baada ya** vichujio.
  Widget _resultCount(BuildContext context, AppLocalizations l10n, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.auto_stories_rounded,
            size: AppSpacing.iconSm,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              l10n.storiesFound(count),
              style: context.textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Huchagua kitu cha kuonyesha kulingana na hali ya cubit.
  ///
  /// Mpangilio wa ukaguzi ni wa makusudi: **kosa kwanza**, kisha kupakia,
  /// kisha tupu. Kosa linalojificha nyuma ya shimmer hungundulika tu baada ya
  /// shimmer kukaa sekunde nyingi — wakati ambapo mtumiaji tayari ameacha.
  Widget _results(
    BuildContext context,
    AppLocalizations l10n,
    StoryListState state,
    List<Story> filtered,
  ) {
    if (state.hasFailure) {
      return AppErrorWidget(
        failure: state.failure!,
        onRetry: () => context.read<StoryListCubit>().retry(),
      );
    }

    if (state.isLoading && state.stories.isEmpty) {
      return const StoryGridShimmer();
    }

    // Rafu haipo tupu kwa sababu ya kichujo — haina hadithi kabisa bado.
    if (state.stories.isEmpty) {
      return const _ShelfEmpty();
    }

    if (filtered.isEmpty) {
      return _NoMatches(onClear: _resetAll);
    }

    // TODO: Implement pagination in Prompt 5.
    // Cubit haiko `loadMore()`: `getStoriesByShelf` hurudisha hadithi zote
    // za rafu kwa ombi moja. Hadi Prompt 5, orodha yote huonyeshwa mara moja.
    return StoryGridView(stories: filtered);
  }
}

/// Vichujo vya haraka vya kichwa cha gridi — kila kimoja huchagua
/// mpangilio **na** bei kwa wakati mmoja.
///
/// Hii ni enum ya faragha kwa sababu ni muundo wa **ukurasa huu** pekee:
/// ukurasa wa hadithi zote huchagua mpangilio na bei kwa vidhibiti
/// vinavyojitegemea (`story_query.StorySort` + `StoryFilter`).
///
/// Spec ya Prompt 3 ilitaka "Zote / Mpya / Maarufu / Bure / VIP" kama chips
/// moja; Task 3 ilitaka chips 32dp zenye Kanga Orange 20% na Task 1 ilitaka
/// Safari Green. Tumetumia **Kanga Orange** (Task 8c) kwa sababu hizi ni
/// filter chips, na zile za kundi (Safari Green, 36dp) ni vidonge vya
/// makundi kwenye ukurasa wa hadithi zote.
enum _ShelfQuickFilter {
  /// "Zote" — mpangilio wa mkusanyaji, bila kuchuja bei.
  all(StorySort.curated, StoryPriceFilter.any),

  /// "Mpya" — mwaka wa kuchapishwa, mpya kwanza.
  newest(StorySort.newest, StoryPriceFilter.any),

  /// "Maarufu" — `readCount` kubwa kwanza.
  popular(StorySort.popular, StoryPriceFilter.any),

  /// "Bure" — `isFree` pekee.
  free(StorySort.curated, StoryPriceFilter.free),

  /// "VIP" — zinazohitaji plan ya kulipia.
  premium(StorySort.curated, StoryPriceFilter.premium);

  const _ShelfQuickFilter(this.sort, this.price);

  /// Mpangilio unaotumika kichujo hiki kinapochaguliwa.
  final StorySort sort;

  /// Bei inayotumika kichujo hiki kinapochaguliwa.
  final StoryPriceFilter price;
}

/// Bango la rafu — picha, rangi ya rafu na jina juu yake.
///
/// ## Kwa nini si [StoryArtwork] (tunayoitumia Maktaba)
///
/// `StoryArtwork` inapakia picha kwa `cacheWidth` iliyowekwa kwa kadi ya
/// 140dp. Bango hili lina upana wa **skrini yote**; kutumia `StoryArtwork`
/// kungepakia picha ya 280px kisha kuisambaza kwenye 1200px — picha
/// inayovimba na kutia ukungu. Pia bango linahitaji tint ya `shelf.accent`
/// na kichwa kikubwa, ambavyo `StoryArtwork` haina.
class _ShelfBanner extends StatelessWidget {
  const _ShelfBanner({required this.shelf});

  /// Rafu inayoonyeshwa.
  final StoryShelf shelf;

  /// Urefu wa bango — urefu ulioainishwa kwenye spec ya Prompt 3.
  static const double height = 120;

  @override
  Widget build(BuildContext context) {
    // Upana halisi wa bango = upana wa skrini. `cacheWidth` hupunguza picha
    // inayopakiwa kwa upana huo (×density), kwa hivyo skrini kubwa haipakii
    // picha kubwa kuliko inahitaji.
    final double screenWidth = context.screenWidth;
    final double ratio = MediaQuery.of(context).devicePixelRatio;
    final int cacheWidth = (screenWidth * ratio).round().clamp(120, 2048);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Image.asset(
                shelf.asset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.medium,
                excludeFromSemantics: true,
                cacheWidth: cacheWidth,
                // Picha haipo (au imeharibika) — rangi ya rafu inachukua
                // nafasi yake badala ya kutupa kisanduku cheupe.
                errorBuilder: (_, __, ___) => DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: <Color>[shelf.accent, shelf.accent.withOpacity(0.65)],
                    ),
                  ),
                ),
              ),
              // Tint ya accent: inaunganisha bango na rangi ya rafu kwenye
              // Maktaba, na inaimarisha tofauti ya maandishi meupe.
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: <Color>[
                      shelf.accent.withOpacity(0.55),
                      shelf.accent.withOpacity(0.05),
                    ],
                  ),
                ),
              ),
              // Scrim nyeusi kuelekea chini: cheupe juu ya picha nyepesi
              // hakisomeki. Hii ni njia ile ile tuliyotumia kwenye
              // `StoryArtwork` (tazama doc yake).
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Colors.transparent,
                      Colors.black.withOpacity(0.55),
                    ],
                    stops: const <double>[0.45, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      storyShelfLabel(context, shelf),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Rafu ipo, lakini vichujio vyote vimeonyesha orodha tupu.
class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.onClear});

  /// Hufuta vichujio vyote — hatua pekee inayosaidia hapa.
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return AppEmptyState(
      titleSw: l10n.noStoriesFound,
      titleEn: l10n.noStoriesFound,
      messageSw: l10n.tryDifferentFilter,
      messageEn: l10n.tryDifferentFilter,
      icon: Icons.search_off_rounded,
      onAction: onClear,
      actionLabelSw: l10n.clearFilters,
      actionLabelEn: l10n.clearFilters,
      actionIcon: Icons.clear_all,
      actionVariant: AppButtonVariant.outline,
      // Task 8e: mchoro wa hali tupu ni wa Earth Brown, si kijani cha app.
      tone: AppColors.earthBrown,
    );
  }
}

/// Rafu haipo kabisa (kiungo kibovu).
class _ShelfNotFound extends StatelessWidget {
  const _ShelfNotFound();

  @override
  Widget build(BuildContext context) {
    final String title = context.localised(
      swahili: 'Rafu hii haipatikani',
      english: 'This shelf was not found',
    );

    return AppEmptyState(
      titleSw: title,
      titleEn: title,
      icon: Icons.search_off_rounded,
      tone: AppColors.earthBrown,
    );
  }
}

/// Rafu ipo lakini haina hadithi bado.
class _ShelfEmpty extends StatelessWidget {
  const _ShelfEmpty();

  @override
  Widget build(BuildContext context) {
    final String title = context.localised(
      swahili: 'Rafu hii haina hadithi bado',
      english: 'This shelf has no stories yet',
    );

    return AppEmptyState(
      titleSw: title,
      titleEn: title,
      tone: AppColors.earthBrown,
    );
  }
}
