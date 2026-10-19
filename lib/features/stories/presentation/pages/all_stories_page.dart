/// Ukurasa wa hadithi **zote** — Maktaba kamili pamoja na utafutaji,
/// mpangilio na vichujio (`/stories/all`).
///
/// ## Kwa nini kichwa si `AppTopBar`
///
/// Kurasa nyingine hutumia `AppTopBar` (upau mweupe mwembamba). Ukurasa huu
/// ni **pa kuingia** kwa maktaba nzima: mtumiaji hufika hapa kutoka "Tazama
/// Zote" na mara nyingi huja **kutafuta** kitu maalum. Kichwa cha kijani cha
/// Safari kinachoshuka hadi kwenye upau wa utafutaji kinatoa uzito wa kuona
/// unaosema "hapa ndipo unapotafuta" — wakati upau mwembamba ungesema
/// "ukurasa mwingine wa orodha". Kitufe cha "Rudi" kipo ndani ya kichwa
/// (kichwa cha kawaida hakiwepo), kwa hivyo mtumiaji hafungwi.
///
/// ## Kwa nini `StatefulWidget`
///
/// `TextField` inamiliki `TextEditingController`. Controller hiyo inapaswa
/// kutolewa (`dispose`) — kama haitolewa, `TextField` inabaki na marejeleo
/// ya `FocusNode`/controller baada ya ukurasa kufungwa, na kwenye simu za
/// Tanzania (2GB RAM) hiyo huonekana kama memory leak inayokua kwa kila
/// kufungua/kufunga ukurasa. Pia tunahifadhi mpangilio na vichujio vya
/// **ukurasa huu** (si vya cubit — tazama chini).
///
/// ## Kwa nini msimbo wa utafutaji upo kwenye cubit
///
/// Hati ya `StoryListCubit.searchDebounced` ina `Duration(milliseconds: 300)`
/// yake **na** inaifuta kwenye `close()`. Kwa hivyo ukurasa huu **hauandiki
/// `Timer`**: kuweka `Timer` wa pili hapa kungezalisha muda wa kusubiri
/// unaopingana na wa cubit, na herufi moja ingeweza kusababisha maombi
/// mawili. Ukurasa unaita tu; kila herufi haisababishi ombi jipya.
///
/// ## Kwa nini mpangilio na vichujio viko kwenye kumbukumbu
///
/// `StoryListCubit` haina `sortBy` wala kichujo cha umri/kiwango/bei: inaleta
/// hadithi zote kwa ombi moja (maktaba yetu ni fupi). Kwa hivyo mpangilio na
/// vichujio hufanyika kwa [applyStoryQuery] juu ya orodha ambayo cubit tayari
/// ameileta — kugusa kichujo ni **papo hapo**, hakuna mzunguko wa mtandao.
/// Sababu kamili iko kwenye doc ya `story_query.dart`, ikiwa ni pamoja na kwa
/// nini sehemu ya "Lugha" na bendi za bei hazijajengwa.
///
/// **Utafutaji haufanyiki hapa.** Hoja ya utafutaji inachujwa na cubit
/// (`searchStories` kwenye hifadhi), kwa hivyo hapa tunapita `query: ''` kwa
/// [applyStoryQuery]. Kuchuja **mara ya pili** kwa maneno kule kungeweza
/// kutofautiana na hifadhi — mfano hifadhi ikitafuta kwenye muhtasari wa
/// hadithi na sisi tusitafute — na matokeo yangekuwa machache kuliko
/// yanayotarajiwa.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_shelf.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../data/datasources/story_sample_data.dart';
import '../cubit/story_list_cubit.dart';
import '../state/story_list_state.dart';
import '../story_navigation.dart';
import '../story_query.dart';
import '../widgets/shelf_tile.dart';
import '../widgets/story_chip.dart';
import '../widgets/story_filter_sheet.dart';
import '../widgets/story_grid_view.dart';

/// Orodha ya hadithi zote, ikiwa na utafutaji, mpangilio na vichujio.
class AllStoriesPage extends StatefulWidget {
  /// Huunda ukurasa wa hadithi zote.
  const AllStoriesPage({super.key});

  @override
  State<AllStoriesPage> createState() => _AllStoriesPageState();
}

class _AllStoriesPageState extends State<AllStoriesPage> {
  /// Mpangilio wa sasa. `curated` = mkusanyaji wa maktaba (chanzo-msingi).
  StorySort _sort = StorySort.curated;

  /// Vichujio vya sasa vya ukurasa huu (umri, kiwango, bei).
  ///
  /// Ni hali ya **ukurasa**, si ya cubit: vichujio hivi havihitaji ombi jipya
  /// la mtandao, na kuviweka kwenye cubit kungeifanya iwe na vigezo vinane
  /// vinavyoweza kupingana bila faida yoyote (tazama doc ya `story_query`).
  StoryFilter _filter = StoryFilter.none;

  final TextEditingController _searchController = TextEditingController();

  /// Maandishi ya utafutaji ya sasa — kwa kuonyesha/kuficha kitufe cha X.
  ///
  /// Hii ni nakala ya kuonyesha pekee; **hoja** ya utafutaji inaishi kwenye
  /// cubit (`StoryListState.query`).
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Hutuma hoja ya utafutaji kwa cubit (yenye debounce yake ya 300ms).
  void _onQueryChanged(String value) {
    setState(() => _query = value);
    context.read<StoryListCubit>().searchDebounced(value);
  }

  /// Hufuta utafutaji na kurudi kwenye orodha kamili.
  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
    context.read<StoryListCubit>().clearSearch();
  }

  /// Hufuta vichujio vyote vya ndani (mpangilio + vichujio).
  ///
  /// **Haiti `clearSearch()`**: hali hii hufikiwa pale hadithi zipo lakini
  /// vichujio vimeziondoa zote. Utafutaji hauwezi kuwa sababu — cubit tayari
  /// amerudisha matokeo yenye vitu — kwa hivyo ombi jipya la mtandao
  /// lingekuwa kazi bure.
  void _resetAll() {
    setState(() {
      _sort = StorySort.curated;
      _filter = StoryFilter.none;
    });
  }

  /// Hufungua karatasi ya vichujio na kutumia matokeo yake.
  ///
  /// `null` = mtumiaji alifunga bila kugusa "Tumia Vichujio" — kichujo cha
  /// zamani kinabaki. Tofauti hii ni muhimu: mtumiaji anayegusa kichujo kisha
  /// kufunga karatasi **hakusudii** kukitumia.
  Future<void> _openFilters() async {
    final StoryFilter? result = await showStoryFilterSheet(context, _filter);
    if (!mounted || result == null) return;
    setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: <Widget>[
          _SearchHeader(
            controller: _searchController,
            showClear: _query.isNotEmpty,
            onChanged: _onQueryChanged,
            onClear: _clearSearch,
          ),
          _categoryPills(context),
          _sortFilterBar(context, l10n),
          Expanded(
            child: BlocBuilder<StoryListCubit, StoryListState>(
              builder: (BuildContext context, StoryListState state) {
                // Mpangilio na vichujio hufanyika hapa, kwenye kumbukumbu, juu
                // ya orodha ambayo cubit tayari ameileta (tazama doc ya faili).
                final List<Story> filtered = applyStoryQuery(
                  state.stories,
                  sort: _sort,
                  filter: _filter,
                  swahili: context.isSwahili,
                );

                // Kikokotoo hukaa pale tu data imefika **na** kuna cha
                // kuhesabu. Wakati wa kupakia au kwa kosa, "Hadithi 0
                // zinapatikana" ni uongo unaochanganya kosa na orodha tupu.
                final bool showCount =
                    state.status == StoryListStatus.success &&
                        filtered.isNotEmpty;

                return Column(
                  children: <Widget>[
                    if (showCount) _resultCount(context, l10n, filtered.length),
                    Expanded(
                      child: RefreshIndicator(
                        // `retry()` huchagua ombi sahihi yenyewe: kosa la
                        // utafutaji au la maktaba yote (tazama cubit).
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
      ),
    );
  }

  /// Vidonge vya makundi sita — njia ya haraka ya kwenda kwenye rafu.
  ///
  /// Hakuna kidonge kilichochaguliwa: ukurasa huu haujui kundi lolote
  /// (hakuna `categoryId` kama wa `ShelfPage`). Kidonge ni **kiungo**, si
  /// kichujo — kugusa kunahamisha kwenye `/category/:id`.
  ///
  /// Kwa nini si `ShelfTile`: tile ya Maktaba inaonyesha picha kubwa na jina
  /// chini; hapa tunahitaji kitu cha mstari mmoja kinachoshirikiana nafasi na
  /// chips nyingine. Tunatumia [StoryChoiceChip] na `leading` — picha ndogo
  /// ya rafu — ili mtoto wa miaka 3-8 atambue kundi kwa **jicho** kabla ya
  /// kusoma jina.
  Widget _categoryPills(BuildContext context) {
    return StoryChipRow(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        0,
      ),
      children: <Widget>[
        // **Nyimbo kwanza** — ni kitu tofauti na hadithi, na ni mahali
        // panapokua: nyimbo za watoto huingia hapa badala ya kuwa hadithi.
        StoryChoiceChip(
          label: context.isSwahili ? 'Nyimbo' : 'Songs',
          style: StoryChipStyle.category,
          selected: false,
          onSelected: (bool _) =>
              context.pushNamed(AppRoutes.songsName),
        ),
        // **Rafu zenye hadithi pekee.** Awali `StoryShelf.values` yote
        // ilionyeshwa — hata rafu tupu, ambazo mtoto alibofya na kukuta
        // ukurasa mtupu. Hii ndiyo ilikuwa "emptiness".
        for (final StoryShelf shelf in StorySampleData.activeShelves)
          StoryChoiceChip(
            label: storyShelfLabel(context, shelf),
            style: StoryChipStyle.category,
            leading: _ShelfThumb(shelf: shelf),
            selected: false,
            onSelected: (bool _) => openShelf(context, shelf),
          ),
      ],
    );
  }

  /// "Panga kwa: …" (kushoto) + "Vichujio (n)" (kulia).
  Widget _sortFilterBar(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Expanded(child: _sortButton(context, l10n)),
          const SizedBox(width: AppSpacing.sm),
          AppButton(
            // Spec inataka namba ya vichujio vilivyotumika kwenye kitufe
            // chenyewe ("Vichujio (3)"), si kwenye badge ya pembe.
            labelSw: _filterLabel(l10n),
            labelEn: _filterLabel(l10n),
            variant: AppButtonVariant.outline,
            size: AppButtonSize.small,
            expand: false,
            icon: Icons.tune_rounded,
            onPressed: _openFilters,
          ),
        ],
      ),
    );
  }

  /// Lebo ya kitufe cha vichujio — na idadi ikiwa kuna vinavyotumika.
  String _filterLabel(AppLocalizations l10n) {
    if (_filter.isEmpty) return l10n.filters;
    return '${l10n.filters} (${_filter.activeCount})';
  }

  /// Kidhibiti cha mpangilio — "Panga kwa: Mpya".
  Widget _sortButton(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton<StorySort>(
      tooltip: l10n.sortBy,
      onSelected: (StorySort sort) => setState(() => _sort = sort),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<StorySort>>[
        for (final StorySort sort in StorySort.values)
          CheckedPopupMenuItem<StorySort>(
            value: sort,
            checked: _sort == sort,
            child: Text(storySortLabel(context, sort)),
          ),
      ],
      child: Padding(
        // `Padding` hii pia ni eneo la kugusa — `PopupMenuButton` hujifunga
        // kwenye `InkWell`, na bila nafasi ya ziada kitufe kingekuwa kidogo
        // kuliko [AppSpacing.minTouchTarget].
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.sort_rounded,
              size: AppSpacing.iconSm,
              color: AppColors.earthBrown,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                // Lebo inaonyesha mpangilio wa **sasa** — bila hivyo mtumiaji
                // hajui orodha imepangwa vipi hadi afungue menyu.
                '${l10n.sortBy}: ${storySortLabel(context, _sort)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.labelMedium?.copyWith(
                  color: AppColors.earthBrown,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              color: AppColors.earthBrown,
            ),
          ],
        ),
      ),
    );
  }

  /// "Hadithi 24 zinapatikana" — huonyesha idadi **baada ya** vichujio.
  Widget _resultCount(BuildContext context, AppLocalizations l10n, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
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

    // Maktaba tupu: hakuna hadithi **kabisa** (si kichujo kilichoziweka
    // pembeni). Ujumbe tofauti kwa mtumiaji: "hakuna kilichoongezwa bado" ni
    // hali ya maktaba, "hakuna kinacholingana" ni hali ya utafutaji.
    if (state.stories.isEmpty) {
      if (state.isSearching) {
        return AppEmptyState.noResults(
          messageSw: 'Badilisha neno la utafutaji.',
          messageEn: 'Try a different search word.',
          onAction: _clearSearch,
          actionLabelSw: l10n.clearFilters,
          actionLabelEn: l10n.clearFilters,
          // Task 8e: mchoro wa hali tupu ni wa Earth Brown.
          tone: AppColors.earthBrown,
        );
      }
      return const _LibraryEmpty();
    }

    // Hadithi zipo, lakini vichujio vimeziondoa zote.
    if (filtered.isEmpty) {
      return _NoMatches(onClear: _resetAll);
    }

    // TODO: Implement pagination in Prompt 5.
    // Cubit haiko `loadMore()`: `getAllStories` hurudisha hadithi zote kwa
    // ombi moja. Hadi Prompt 5, orodha yote huonyeshwa mara moja.
    return StoryGridView(stories: filtered);
  }
}

/// Kichwa cha kijani cha Safari chenye upau wa utafutaji.
///
/// Kinashuka chini ya eneo salama la kifaa (`SafeArea`) kwa sababu hakuna
/// `AppBar` inayoshughulikia notch/status bar.
class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    required this.showClear,
    required this.onChanged,
    required this.onClear,
  });

  /// Controller ya uwanja wa utafutaji (inamilikiwa na ukurasa).
  final TextEditingController controller;

  /// `true` = onyesha kitufe cha X (kuna maandishi ya kufuta).
  final bool showClear;

  /// Huitwa kwa kila herufi.
  final ValueChanged<String> onChanged;

  /// Huitwa kwa kitufe cha X.
  final VoidCallback onClear;

  /// Urefu wa upau wa utafutaji — ulioainishwa kwenye spec (Task 8a).
  static const double barHeight = 52;

  /// Radi ya upau — "fully rounded" kwa urefu wa 52: 26. Spec inasema 28;
  /// tunatumia 26 ili mviringo uwe **nusu ya urefu** (haupunguki na hauzidi),
  /// na tofauti ya 2dp haionekani.
  static const double barRadius = barHeight / 2;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return ColoredBox(
      color: AppColors.safariGreen,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Row(
            children: <Widget>[
              // "Rudi" ipo ndani ya kichwa kwa sababu `Scaffold` hapa haina
              // `AppBar`. Rangi nyeupe kwa sababu mandhari ni ya kijani.
              AppIconButton(
                icon: Icons.arrow_back_rounded,
                tooltipSw: l10n.back,
                tooltipEn: l10n.back,
                color: Colors.white,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: _searchBar(context, l10n)),
            ],
          ),
        ),
      ),
    );
  }

  /// Upau mweupe wa utafutaji — 52dp, mviringo kamili, kivuli hafifu.
  Widget _searchBar(BuildContext context, AppLocalizations l10n) {
    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        // 0.95 si weupe kamili: kijani kinaonekana kidogo kupitia, kwa hivyo
        // upau unaonekana **ndani ya** kichwa badala ya juu yake.
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(barRadius),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onChanged: onChanged,
        onSubmitted: onChanged,
        style: context.textTheme.bodyMedium?.copyWith(fontSize: 16),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          hintText: l10n.searchPlaceholder,
          hintStyle: context.textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.safariGreen,
          ),
          suffixIcon: _suffix(context, l10n),
        ),
      ),
    );
  }

  /// Vitendo vya kulia: kufuta (X) na sauti.
  ///
  /// **Sauti imezimwa kwa makusudi.** Utafutaji wa sauti haujajengwa, kwa
  /// hivyo aikoni hii **si** `AppIconButton` na haina `onPressed`: hakuna
  /// eneo la kugusa na hakuna SnackBar. Kitufe kinachogusika kisichofanya
  /// kitu hufundisha mtumiaji kuwa vitufe haviaminiki; `mic_off_rounded`
  /// iliyofifia (rangi ya `onSurfaceVariant`) inasema ukweli kabla ya kugusa.
  ///
  /// `Row` yenye `MainAxisSize.min` ni muhimu: `suffixIcon` hupokea upana
  /// usio na kikomo kwa chaguo-msingi, na `Row` ya kawaida ingejitahidi
  /// kujaza upana wote wa upau.
  Widget? _suffix(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (showClear)
          AppIconButton(
            icon: Icons.close_rounded,
            tooltipSw: l10n.cancel,
            tooltipEn: l10n.cancel,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: AppSpacing.iconSm,
            onPressed: onClear,
          ),
        // Ujumbe wa tooltip ni wa lugha mbili, kama `AppIconButton`:
        // `context.localised` huchagua lugha ya app kwa wakati huo.
        Tooltip(
          message: context.localised(
            swahili: 'Utafutaji wa sauti bado haujasanidiwa',
            english: "Voice search isn't built yet",
          ),
          child: Padding(
            // Nafasi ya kando inaleta nafasi ya kupumua badala ya kitufe
            // cha 48dp — hakuna eneo la kugusa la kuheshimu hapa.
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Icon(
              Icons.mic_off_rounded,
              size: AppSpacing.iconSm,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
      ],
    );
  }
}

/// Picha ndogo ya rafu ndani ya kidonge cha kundi.
///
/// Picha ya rafu ipo (`assets/images/categories/*.png` — zote sita zipo
/// kwenye repo), lakini `errorBuilder` inabaki: pikseli moja iliyoharibika
/// haipaswi kuzalisha kisanduku cheupe katikati ya kidonge. Akiba ni
/// mraba wa rangi ya rafu.
class _ShelfThumb extends StatelessWidget {
  const _ShelfThumb({required this.shelf});

  /// Rafu inayoonyeshwa.
  final StoryShelf shelf;

  /// Upana/urefu wa picha — inatosha kwenye kidonge cha 36dp.
  static const double size = 20;

  @override
  Widget build(BuildContext context) {
    final double ratio = MediaQuery.of(context).devicePixelRatio;
    final int cacheWidth = (size * ratio).round().clamp(40, 256);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      child: Image.asset(
        shelf.asset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.low,
        excludeFromSemantics: true,
        cacheWidth: cacheWidth,
        errorBuilder: (_, __, ___) =>
            ColoredBox(color: shelf.accent, child: const SizedBox.square(dimension: size)),
      ),
    );
  }
}

/// Maktaba haina hadithi yoyote bado — si kosa, na si kichujo.
class _LibraryEmpty extends StatelessWidget {
  const _LibraryEmpty();

  @override
  Widget build(BuildContext context) {
    final String title = context.localised(
      swahili: 'Bado hakuna hadithi zilizoongezwa',
      english: 'No stories have been added yet',
    );

    return AppEmptyState(
      titleSw: title,
      titleEn: title,
      tone: AppColors.earthBrown,
    );
  }
}

/// Maktaba ina hadithi, lakini vichujio vimeonyesha orodha tupu.
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
      tone: AppColors.earthBrown,
    );
  }
}
