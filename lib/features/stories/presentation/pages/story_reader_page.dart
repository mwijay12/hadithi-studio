/// **STORY READER** — ukurasa wa kusoma na kusikiliza (`/story/:id/read`).
///
/// Huu ni ukurasa wa kati wa app: hapa mtoto husoma mwenyewe au kusikiliza
/// hadithi ikisomwa. Kuna tabaka **tano** (5) zilizopangwa juu ya mchoro:
///
/// | Tabaka | Kitu | Lini huonekana |
/// |--------|------|----------------|
/// | 1 | Kurasa (`PageView`) — mchoro, maandishi, maeneo ya kugusa | daima |
/// | 2 | Kifuniko cha usiku (`nightModeOverlay`) | `isNightMode` |
/// | 3 | Upau wa juu (`_TopControls`) | `_showControls` |
/// | 4 | Upau wa sauti (`TtsControls`) | `_showControls` (au `listenOnly`) |
/// | 5 | Kisanduku cha mipangilio (`ReaderSettingsPanel`) | `_showSettings` |
///
/// **Mwenendo wa vidole (gestures).** Kugusa mara moja hufunua/kuficha vidhibiti,
/// kugusa mara mbili huingia hali ya skrini nzima, na kutelereza **juu**
/// hufungua mipangilio (chini hufunga). Kugeuza ukurasa kwa kutelereza
/// **kushoto/kulia** kunashughulikiwa na `PageView` yenyewe.
///
/// Kwa nini `PageView` na si `onHorizontalDragEnd` hapa? Kwa sababu
/// `GestureDetector` ya baba na `Scrollable` ya `PageView` hutafuta vidole
/// kimoja — na `Scrollable` ikiwa ndani zaidi hushinda kwa kawaida, hivyo
/// kishika chetu kingekuwa **kifo tu** (dead code) wakati mwingine, na
/// wakati mwingine kingeiba telezi kwa kugeuza ukurasa mara mbili. Kutelereza
/// kwa `PageView` pia kunafuata kidole, ambayo ni UX bora kwa kitabu cha mtoto.
///
/// **Hotspot haigeuzi ukurasa.** Kila eneo la kugusa huita `_onHotspotTapped`
/// inayoweka `_hotspotTapped = true` — hivyo mguso wa eneo haugeuki kuwa
/// mguso wa kifuniko ambayo ingeficha vidhibiti bila kusudi.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../config/theme/typography.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/text_utils.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/swahili_text_widget.dart';
import '../../../../l10n/l10n.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';
import '../cubit/reader_cubit.dart';
import '../state/reader_state.dart';
import '../widgets/interactive_hotspot.dart';
import '../widgets/reader_settings_panel.dart';
import '../widgets/tts_controls.dart';
import '../../../../core/widgets/leo_mascot.dart';

/// Ukurasa wa kusoma/kusikiliza hadithi.
class StoryReaderPage extends StatefulWidget {
  const StoryReaderPage({
    super.key,
    required this.storyId,
    this.autoPlay = false,
  });

  /// `id` ya hadithi — hutumika kwa "jaribu tena".
  final String storyId;

  /// `true` = anza kusoma ukurasa wa kwanza mara moja ("Sikiliza Sasa").
  ///
  /// Pia huzima swali la "Endelea kutoka ukurasa…?": mtumiaji ameonyesha
  /// wazi kuwa anataka kuanza kusikiliza **sasa**.
  final bool autoPlay;

  @override
  State<StoryReaderPage> createState() => _StoryReaderPageState();
}

class _StoryReaderPageState extends State<StoryReaderPage> {
  final PageController _pageController = PageController();

  /// Vidhibiti (upau wa juu na wa sauti) vinaonekana.
  bool _showControls = true;

  /// Kisanduku cha mipangilio kimefunguliwa.
  bool _showSettings = false;

  /// Hali ya skrini nzima (kugusa mara mbili).
  bool _isFullscreen = false;

  /// Eneo la kugusa limegusa hivi punde — hivyo mguso huu si wa kifuniko.
  bool _hotspotTapped = false;

  /// Eneo la kugusa lililobofya sasa — kibonge chake kinaonyeshwa.
  ///
  /// Kwa nini kibonge huwekwa HAPA (ngazi ya skrini) na sivyo ndani ya eneo:
  /// eneo ni kisanduku kidogo kilicho pembezoni, na Flutter haikati
  /// `Positioned`. Kibonge kilichowekwa ndani kilikuwa **kinatoka nje ya
  /// skrini** kwa nusu. Tazama `_hotspotBubble`.
  StoryHotspot? _activeHotspot;

  /// Sherehe ya kumaliza imeonyeshwa tayari (mara moja kwa kila kikao).
  bool _celebrationShown = false;

  /// Swali la "Endelea kutoka ukurasa…?" limeulizwa tayari.
  bool _resumePromptShown = false;

  /// Hali ya mwisho tuliyoiona — `BlocConsumer.listener` haitoi ya awali,
  /// lakini sherehe ya kumaliza inahitaji kulinganisha "ilikuwa inasoma" na
  /// "imekoma". Kwa hivyo tunaikumbuka sisi wenyewe.
  ReaderState? _lastState;

  /// Kipima-muda cha kutua kwa `_hotspotTapped`.
  Timer? _hotspotRelease;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lugha inaweza kubadilika. Cubit inahifadhi lugha ya maandishi na maneno
    // ya karaoke — hivyo inaitwa hapa, si kwenye build (kuita `emit` wakati
    // wa build husababisha kosa la setState).
    context.read<ReaderCubit>().setLanguage(context.isSwahili);
  }

  @override
  void dispose() {
    _hotspotRelease?.cancel();
    _pageController.dispose();
    // Rudisha mfumo kwenye hali ya kawaida — tumeiba `SystemUiMode` wakati
    // wa skrini nzima, na kushindwa kuirudisha kungeacha app bila status bar.
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.edgeToEdge,
        overlays: SystemUiOverlay.values,
      ),
    );
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Vidhibiti vya vidole
  // ---------------------------------------------------------------------------

  /// Kugusa mara moja: funua/kuficha vidhibiti.
  void _handleTap() {
    // Mguso uliotangulia kuwa wa eneo la kugusa — usifanye kitu.
    if (_hotspotTapped) return;
    setState(() => _showControls = !_showControls);
  }

  /// Kugusa mara mbili: ingia/toka skrini nzima.
  void _handleDoubleTap() {
    setState(() => _isFullscreen = !_isFullscreen);
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        _isFullscreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
        overlays: _isFullscreen
            // Kwenye skrini nzima tunabakiza hali ya juu (saa/betri) ili
            // mtoto asikose muktadha, lakini tunaficha urambazaji.
            ? const <SystemUiOverlay>[SystemUiOverlay.top]
            : SystemUiOverlay.values,
      ),
    );
  }

  /// Kutelereza juu/chini: fungua/funga mipangilio.
  void _handleVerticalDrag(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 120) return; // Telezi ndogo — puuza.
    final bool opening = velocity < 0; // Juu = hasi kwenye skrini.
    if (opening == _showSettings) return;
    setState(() {
      _showSettings = opening;
      if (opening) _showControls = false;
    });
  }

  /// Eneo la kugusa limegusa: weka bendera, kisha itue baada ya muda mfupi.
  void _onHotspotTapped(StoryHotspot hotspot) {
    // Onyesha kibonge chake (kwenye ngazi ya skrini, kikidhibitiwa).
    if (mounted) setState(() => _activeHotspot = hotspot);

    _hotspotTapped = true;
    _hotspotRelease?.cancel();
    // Kutua: mguso wa eneo haupaswi kamwe kugeuza ukurasa, lakini pia
    // haupaswi kuzuia kugusa kifuniko kinachofuata.
    _hotspotRelease = Timer(
      AppSpacing.wordTapFeedback,
      () => _hotspotTapped = false,
    );
  }

  /// Hukokotoa nafasi ya kibonge **ndani ya skrini**.
  ///
  /// Kosa la awali: kibonge kiliwekwa ndani ya kisanduku cha eneo (upana
  /// 200-280) na eneo lililo pembezoni likakisukuma nje ya skrini. Hapa
  /// tunakiweka katikati ya eneo, kisha **tunakibana** ndani ya mipaka —
  /// hivyo hakiwezi kutoka nje hata kama data ya eneo ni mbaya.
  Widget _hotspotBubble(BuildContext context, StoryHotspot hotspot) {
    final Size screen = MediaQuery.of(context).size;
    const double margin = AppSpacing.lg;

    // Upana: kamwe usizidi skrini ukiondoa kando kando ya skrini.
    final double width = (screen.width - margin * 2).clamp(0.0, 300.0);

    // Mlalo: katikati ya eneo, kisha kubanwa ndani ya skrini.
    final double centreX = (hotspot.left + hotspot.width / 2) * screen.width;
    final double maxLeft = screen.width - width - margin;
    final double left = maxLeft <= margin
        ? margin
        : (centreX - width / 2).clamp(margin, maxLeft);

    // Wima: juu ya eneo; kama nafasi haitoshi, chini yake; kisha kubanwa.
    // Urefu wa kibonge umekadiriwa kwa ukarimu (maandishi ya Kiswahili
    // ni marefu). Chini tunatenga **150**: upau wa sauti (76) + chips (44)
    // huelea juu ya skrini, na kibonge kilichowekwa chini yao kingefichwa
    // kabisa — ndiyo sababu mtumiaji aliona jibu bila swali.
    const double estimatedHeight = 220;
    const double bottomReserve = 150;
    final double hotspotTop = hotspot.top * screen.height;
    final double hotspotBottom =
        (hotspot.top + hotspot.height) * screen.height;
    final double maxTop =
        screen.height - estimatedHeight - bottomReserve - margin;

    double top = hotspotTop - estimatedHeight - AppSpacing.sm;
    if (top < margin) top = hotspotBottom + AppSpacing.sm;
    if (maxTop > margin) top = top.clamp(margin, maxTop);

    return Positioned(
      left: left,
      top: top,
      width: width,
      child: HotspotSpeechBubble(
        // Kitufe kwa eneo: kubofya eneo lingine huunda kibonge kipya
        // (saa ya kujificha huanza upya) badala ya kubadilisha maudhui
        // ya kile kile.
        key: ValueKey<String>('${hotspot.labelSw}|${hotspot.type.name}'),
        hotspot: hotspot,
        onDismissed: () {
          if (mounted) setState(() => _activeHotspot = null);
        },
      ),
    );
  }

  /// Husawazisha `PageView` na `state.pageIndex`.
  ///
  /// Hii ni muhimu kwa "auto page turn" na vitufe vya mbele/nyuma: cubit
  /// hubadilisha `pageIndex`, lakini `PageView` haijui. Tunasogeza controller
  /// hadi ukurasa huo baada ya frame ili tusianzishe `animateToPage` wakati
  /// wa build.
  void _syncPage(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final int current = _pageController.page?.round() ?? 0;
      if (current == index) return;
      _pageController.animateToPage(
        index,
        // 400 ms + `easeInOutCubic` — mwendo laini wa kugeuza ukurasa.
        duration: AppSpacing.readerPageTurn,
        curve: Curves.easeInOutCubic,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // Maendeleo na sherehe
  // ---------------------------------------------------------------------------

  /// Huuliza "Endelea kutoka ukurasa…?" mara moja tu kwa kila kikao.
  Future<void> _maybeAskToResume(ReaderCubit cubit, ReaderState state) async {
    if (_resumePromptShown || widget.autoPlay) return;
    if (!state.isReady || state.totalPages <= 1) return;

    _resumePromptShown = true;
    final int? saved = await cubit.savedPage();
    if (!mounted || saved == null) return;
    // Ukurasa wa kwanza hauhitaji swali, na ukurasa wa mwisho ungemaanisha
    // mtoto amekwisha maliza — hivyo hatumuulizi.
    if (saved <= 0 || saved >= state.totalPages - 1) return;

    final bool? go = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        final AppLocalizations l10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(context.l10n.continueReading),
          content: Text(l10n.continuePrompt(saved + 1)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    if (go ?? false) cubit.goToPage(saved);
  }

  /// Huonyesha sherehe TTS inapomaliza ukurasa wa mwisho.
  void _maybeCelebrate(ReaderState previous, ReaderState current) {
    if (_celebrationShown) return;
    // Ishara ya kumaliza: sauti ilikuwa inasoma, ikakoma, na tuko ukurasa
    // wa mwisho. Hii ni ukweli unaoonekana — si kubahatisha kwa `pageIndex`.
    final bool justFinished =
        previous.isSpeaking && !current.isSpeaking && current.isLastPage;
    if (!justFinished) return;
    // `listener` huitwa kabla frame kuisha; kuonyesha dialog papo hapo
    // kungeita `setState` ya `Navigator` ndani ya build. Tunasubiri frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _showCelebration(current);
    });
  }

  /// Kilele cha hadithi: hongera + chaguo la kuanza tena au kusoma nyingine.
  void _showCelebration(ReaderState state) {
    _celebrationShown = true;
    final String title = state.story?.title(swahili: context.isSwahili) ?? '';
    final ReaderCubit cubit = context.read<ReaderCubit>();

    unawaited(
      showDialog<void>(
        context: context,
        builder: (BuildContext dialogContext) {
          final AppLocalizations l10n = dialogContext.l10n;
          return AlertDialog(
            // **LEO** anasherehekea badala ya ikoni. Kumaliza hadithi ni
            // wakati muhimu kwa mtoto — kumpa rafiki anayeshangilia naye
            // kunaimarisha hisia kuliko ikoni isiyo na uso.
            icon: const LeoMascot(pose: LeoPose.celebrate, height: 110),
            title: Text(l10n.congratulations),
            content: Text(
              '${l10n.storyComplete}\n\n$title',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop();
                  _celebrationShown = false;
                  await cubit.startOver();
                },
                child: Text(l10n.startOver),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  // Kurudi nyuma = ukurasa wa maelezo au nyumbani.
                  Navigator.of(context).maybePop();
                },
                child: Text(l10n.readAnother),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReaderCubit, ReaderState>(
      listenWhen: (ReaderState a, ReaderState b) =>
          a.pageIndex != b.pageIndex ||
          a.status != b.status ||
          a.isSpeaking != b.isSpeaking,
      listener: (BuildContext context, ReaderState state) {
        final ReaderState previous = _lastState ?? state;
        _lastState = state;
        _syncPage(state.pageIndex);
        // Sherehe hupimwa kwa kulinganisha hali mbili — hivyo hapa, si kwa
        // kubashiri kwa `pageIndex`.
        _maybeCelebrate(previous, state);
      },
      buildWhen: (ReaderState a, ReaderState b) =>
          a != b || a.status != b.status,
      builder: (BuildContext context, ReaderState state) {
        final ReaderCubit cubit = context.read<ReaderCubit>();

        // Sherehe na swali la kuendelea zinahitaji hali mpya — hivyo
        // zinahitaji mahali penye `emit`-safe. Hapa ni salama: `listener`
        // huitwa nje ya build.
        if (state.isReady && !_resumePromptShown) {
          unawaited(_maybeAskToResume(cubit, state));
        }

        // Skrini nzima + usiku: mandhari ya msingi inabadilika.
        final Color backdrop = state.isNightMode
            ? AppColors.readerNightBackground
            : AppColors.readerBackground;

        return PopScope(
          // Hifadhi maendeleo kabla ya kuondoka — mtoto aendelee hapo
          // alipoacha. `close()` pia huhifadhi, lakini hii inahakikisha
          // hata kama widget haiitwi `dispose` kwa utaratibu.
          onPopInvokedWithResult: (bool didPop, Object? result) {
            if (didPop) unawaited(cubit.saveProgressNow());
          },
          child: Scaffold(
            backgroundColor: backdrop,
            body: _buildBody(context, state, cubit),
          ),
        );
      },
    );
  }

  /// Hali nne: loading, failure, tupu, na reader kamili.
  Widget _buildBody(
    BuildContext context,
    ReaderState state,
    ReaderCubit cubit,
  ) {
    if (state.isLoading) {
      return const Center(child: AppLoading());
    }

    if (state.hasFailure) {
      return AppErrorWidget(
        failure: state.failure!,
        onRetry: () => cubit.loadById(widget.storyId),
      );
    }

    final Story? story = state.story;
    if (story == null || story.pages.isEmpty) {
      return const Center(child: AppLoading());
    }

    // Upau wa sauti huonekana pamoja na vidhibiti — lakini katika
    // `listenOnly` unabaki wazi ili mtoto aweze kusimamisha sauti hata
    // akiwa ameficha vidhibiti vingine.
    final bool showTtsBar =
        _showControls || state.readingMode == ReadingMode.listenOnly;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // ---------------------------------------------------------------
        // TABAKA 1 + 2 — kurasa, na kifuniko cha usiku.
        // ---------------------------------------------------------------
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          onDoubleTap: _handleDoubleTap,
          onVerticalDragEnd: _handleVerticalDrag,
          child: PageView.builder(
            controller: _pageController,
            itemCount: state.totalPages,
            // Cubit hupokea kila ukurasa unaotulia — ikiwa ni mkono wa mtumiaji
            // au `animateToPage` yetu.
            onPageChanged: (int index) {
              // Kibonge cha ukurasa uliopita hakipaswi kubaki juu ya mpya.
              if (_activeHotspot != null) {
                setState(() => _activeHotspot = null);
              }
              cubit.onPageSettled(index);
            },
            itemBuilder: (BuildContext context, int index) => _StoryPageView(
              page: story.pages[index],
              index: index,
              state: state,
              onHotspotTapped: _onHotspotTapped,
            ),
          ),
        ),

        // ---------------------------------------------------------------
        // TABAKA 2b — kibonge cha eneo (ngazi ya SKRINI).
        // ---------------------------------------------------------------
        //
        // Huwekwa hapa, sivyo ndani ya eneo, ili **kisitoke nje ya skrini**.
        // Pia huweka kibonge **kimoja** tu kwa wakati mmoja.
        if (_activeHotspot != null) _hotspotBubble(context, _activeHotspot!),

        // ---------------------------------------------------------------
        // TABAKA 3 — upau wa juu.
        // ---------------------------------------------------------------
        _TopControls(
          visible: _showControls && !_showSettings,
          state: state,
          cubit: cubit,
          onClose: () => Navigator.of(context).maybePop(),
          onSettings: () => setState(() {
            _showSettings = true;
            _showControls = false;
          }),
        ),

        // ---------------------------------------------------------------
        // TABAKA 4 — upau wa sauti (chini).
        // ---------------------------------------------------------------
        Align(
          alignment: Alignment.bottomCenter,
          child: AnimatedSlide(
            duration: AppSpacing.normal,
            curve: Curves.easeOutCubic,
            offset: showTtsBar ? Offset.zero : const Offset(0, 1),
            child: AnimatedOpacity(
              duration: AppSpacing.normal,
              opacity: showTtsBar ? 1 : 0,
              child: IgnorePointer(
                ignoring: !showTtsBar,
                child: TtsControls(
                  state: state,
                  cubit: cubit,
                  onBookmark: () => _onBookmark(context, cubit, state),
                ),
              ),
            ),
          ),
        ),

        // ---------------------------------------------------------------
        // TABAKA 5 — kisanduku cha mipangilio.
        // ---------------------------------------------------------------
        if (_showSettings)
          // Kifuniko cheusi kinachogusa hufunga panel.
          GestureDetector(
            onTap: () => setState(() => _showSettings = false),
            child: ColoredBox(
              color: Colors.black.withValues(alpha: 0.35),
              child: const SizedBox.expand(),
            ),
          ),
        AnimatedPositioned(
          duration: AppSpacing.settingsPanel,
          curve: Curves.easeOutCubic,
          top: 0,
          bottom: 0,
          right: _showSettings ? 0 : -_settingsWidth(context),
          child: ReaderSettingsPanel(
            state: state,
            cubit: cubit,
            width: _settingsWidth(context),
            onClose: () => setState(() {
              _showSettings = false;
              _showControls = true;
            }),
          ),
        ),
      ],
    );
  }

  /// Upana wa kisanduku cha mipangilio kwa skrini ya sasa.
  ///
  /// Kwenye simu nyembamba tunatumia asilimia (80%) — panel ya 300 px
  /// ingeacha mchoro milango 20 tu, ambao hausaidii mtu.
  double _settingsWidth(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double ratio = screenWidth * AppSpacing.settingsPanelWidthRatio;
    return ratio < AppSpacing.settingsPanelWidth
        ? ratio
        : AppSpacing.settingsPanelWidth;
  }

  /// Alama: mtetemo + ujumbe, kisha cubit huhifadhi (local kwanza).
  Future<void> _onBookmark(
    BuildContext context,
    ReaderCubit cubit,
    ReaderState state,
  ) async {
    final bool wasBookmarked = state.isCurrentPageBookmarked;
    // Mtetemo kwanza — mtoto ahisi kuwa kitu kimetokea **papo hapo**.
    await HapticFeedback.lightImpact();
    cubit.toggleBookmark();
    if (!context.mounted) return;

    final AppLocalizations l10n = context.l10n;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: AppSpacing.fast,
          content: Text(wasBookmarked ? l10n.bookmarkRemoved : l10n.bookmarkAdded),
        ),
      );
  }
}

// =============================================================================
// TABAKA 1 — UKURASA MMOJA (mchoro, maandishi, maeneo ya kugusa)
// =============================================================================

/// Ukurasa mmoja wa hadithi: mchoro kamili (full-bleed) + maandishi chini.
///
/// Mchoro hutumia `Image.asset` **mbichi** (si `StoryArtwork`): widget huyo
/// hupanga upya picha hadi 140 dp (`_cacheWidthFor(context, 140)`) kwa sababu
/// ameundwa kwa kadi — hapa tunahitaji picha **kamili ya skrini**, na
/// kupunguza azimio kungeipa mchoro ukungu.
class _StoryPageView extends StatelessWidget {
  const _StoryPageView({
    required this.page,
    required this.index,
    required this.state,
    required this.onHotspotTapped,
  });

  final StoryPage page;
  final int index;
  final ReaderState state;
  /// Hupeleka **eneo lenyewe** — mzazi anahitaji `left`/`top`/`width`/
  /// `height` ili kuweka kibonge ndani ya skrini.
  final ValueChanged<StoryHotspot> onHotspotTapped;

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = index == state.pageIndex;

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Mchoro kamili.
        ColoredBox(
          color: state.isNightMode
              ? AppColors.readerNightBackground
              : AppColors.readerBackground,
          child: Image.asset(
            page.illustration,
            fit: BoxFit.cover,
            // Mchoro haupo? Tusiangushe ukurasa — tunaonyesha mahali pake.
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(
                Icons.image_outlined,
                size: AppSpacing.iconXl,
                color: AppColors.mutedText,
              ),
            ),
          ),
        ),

        // Tabaka 2 — kifuniko cha usiku. Huenda **juu ya mchoro** lakini
        // **chini ya maandishi**, ili mandhari iwe nyeusi huku maneno
        // yakisomeka kwa rangi kamili.
        if (state.isNightMode)
          const ColoredBox(color: AppColors.nightModeOverlay),

        // Maandishi (chini) — hufichwa katika `listenOnly`.
        if (state.showsStoryText)
          _TextOverlay(page: page, state: state, isCurrent: isCurrent),

        // Maeneo ya kugusa — juu ya maandishi, ili vibonge vyao
        // visifichwe na kifuniko cha maandishi.
        for (final StoryHotspot hotspot in page.hotspots)
          Positioned(
            // Ratios (0.0–1.0) → pixelsi. Hii hulinda eneo la kugusa likiwa
            // lile lile kwenye Tecno ya inchi 5 na kwenye tablet.
            left: hotspot.left * MediaQuery.of(context).size.width,
            top: hotspot.top * MediaQuery.of(context).size.height,
            width: hotspot.width * MediaQuery.of(context).size.width,
            height: hotspot.height * MediaQuery.of(context).size.height,
            child: InteractiveHotspot(
              hotspot: hotspot,
              onTapped: onHotspotTapped,
              enabled: isCurrent,
              // Kwenye simu ndogo sana (Tecno/Itel za 5.0") vitufe vya eneo
              // hupunguzwa ili visifunike mchoro — kizingiti kiko
              // `AppBreakpoints`, si `AppSpacing`.
              compact:
                  MediaQuery.of(context).size.width < AppBreakpoints.smallPhone,
            ),
          ),
      ],
    );
  }
}

/// Maandishi ya ukurasa kwenye kifuniko cha gradient.
///
/// Muundo: gradient (uwazi → cheusi 0.70; usiku → #1A1A2E 0.90), kona ya juu
/// ya 20, padding 24/32/100 (chini 100 kwa sababu upau wa sauti unaelea juu
/// ya sehemu hiyo ya skrini), Merriweather, urefu wa mstari 1.6, na urefu wa
/// juu wa 40% ya skrini.
class _TextOverlay extends StatelessWidget {
  const _TextOverlay({
    required this.page,
    required this.state,
    required this.isCurrent,
  });

  final StoryPage page;
  final ReaderState state;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final bool swahili = context.isSwahili;
    final bool night = state.isNightMode;
    final ReaderCubit cubit = context.read<ReaderCubit>();

    // Merriweather + urefu wa mstari 1.6. Rangi: nyeupe juu ya gradient
    // nyeusi (au `readerNightText` gizani).
    final TextStyle storyStyle = AppTypography.storyText(
      fontSize: state.storyFontSize,
      color: night ? AppColors.readerNightText : Colors.white,
      height: 1.6,
    // Kivuli cha tabaka mbili: kimoja kikubwa kwa utulivu, kimoja
    // kidogo kwa makali. Bila hii, neno moja juu ya theluji au mchanga
    // mweupe hupotea hata scrim ikiwa na nguvu.
    ).copyWith(
      shadows: <Shadow>[
        Shadow(color: Colors.black.withValues(alpha: 0.42), blurRadius: 10),
        Shadow(
          color: Colors.black.withValues(alpha: 0.28),
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    );

    final Gradient scrim = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      // **Kosa la awali:** scrim ilikuwa na rangi mbili pekee —
      // `transparent` juu na `black 0.70` chini kabisa. Maandishi
      // huanza karibu na juu ya kisanduku, mahali ambapo alpha ilikuwa
      // ~0.10, kwa hivyo yalikuwa **nyeupe juu ya mchoro mweupe**.
      // Sasa kuna kituo cha kati: 0.55 kwa 42%, na 0.92 chini.
      colors: <Color>[
        night
            ? AppColors.readerNightBackground.withValues(alpha: 0.0)
            : Colors.transparent,
        night
            ? AppColors.readerNightBackground.withValues(alpha: 0.78)
            : Colors.black.withValues(alpha: 0.55),
        night
            ? AppColors.readerNightBackground.withValues(alpha: 0.96)
            : Colors.black.withValues(alpha: 0.92),
      ],
      stops: const <double>[0.0, 0.42, 1.0],
    );

    final double maxHeight =
        MediaQuery.of(context).size.height * AppSpacing.textOverlayMaxHeightRatio;

    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        // Urefu wa juu wa 40% — mchoro lazima ubaki kuonekana.
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: scrim,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.readerOverlayRadius),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.xxl,
            // **Kosa la awali:** 100 haikutosha. Upau wa sauti (76) +
            // chips (44) + nafasi ya kupumua hufika ~140, kwa hivyo mstari
            // wa mwisho ulifichwa chini ya kadi nyeupe.
            148,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Kidokezo cha kugusa — "Gusa kupata majibu!".
                if (page.hasHotspots) _TapHint(isNight: night),
                AppKaraokeText(
                  text: page.text(swahili: swahili),
                  // Karaoke ni ya ukurasa wa sasa pekee; kurasa zilizo pembeni
                  // hazina mwanga (zinaonyesha maandishi ya kawaida).
                  highlightStart: isCurrent ? state.highlightStart : null,
                  highlightEnd: isCurrent ? state.highlightEnd : null,
                  // Rangi za spec: mandhari ya neno #FFD93D, maandishi #1A1A2E.
                  highlightColor: AppColors.playfulYellow,
                  onHighlightColor: AppColors.darkText,
                  // Neno linalosomwa ni **kubwa 1.1×** na **nene** — hivi
                  // ndivyo "uchawi" wa kusoma pamoja unaonekana.
                  emphasisScale: 1.1,
                  emphasisWeight: FontWeight.w700,
                  // Kugusa neno husikiliza neno hilo (kipengele cha msamiati).
                  onWordTap: isCurrent && state.speechAvailable
                      ? (TextToken token) => cubit.speakWord(token.text)
                      : null,
                  style: storyStyle,
                  semanticsLabel: context.localised(
                    swahili: 'Maandishi ya ukurasa',
                    english: 'Page text',
                  ),
                ),

                // Hali ya **"Lugha Zote"**: Kiswahili juu, Kiingereza chini.
                //
                // **Kwa nini Kiingereza hakipati mwanga (karaoke):**
                // `AppKaraokeText` huangaza neno linalosomwa kwa **nafasi za
                // herufi** (`highlightStart`/`highlightEnd`) za maandishi
                // yanayoonyeshwa. Maandishi mawili yenye nafasi moja
                // hayawezi kuangaziwa pamoja — mwanga ungeangukia maneno
                // yasiyolingana.
                //
                // Kwa hivyo: Kiswahili **ndicho** kinachosomwa (na TTS
                // inasoma Kiswahili), Kiingereza ni msaada wa **kusoma**.
                // Hii ni kwa makusudi — sauti inabaki Kiswahili, ambayo
                // ndiyo lugha ya mtoto.
                if (context.isBilingual)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: Text(
                      page.text(swahili: false),
                      style: storyStyle.copyWith(
                        fontSize: (storyStyle.fontSize ??
                                ReaderState.defaultStoryFontSize) *
                            0.82,
                        fontStyle: FontStyle.italic,
                        // Rangi hafifu kidogo lakini bado inasomeka juu ya
                        // gradient nyeusi.
                        color: (night
                                ? AppColors.readerNightPastText
                                : Colors.white)
                            .withValues(alpha: 0.82),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Kidokezo kidogo "Gusa kupata majibu!" ndani ya kifuniko cha maandishi.
class _TapHint extends StatelessWidget {
  const _TapHint({required this.isNight});

  final bool isNight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: AppColors.playfulYellow.withValues(alpha: isNight ? 0.22 : 0.30),
          borderRadius: AppSpacing.borderRadiusPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.touch_app_rounded,
              size: AppSpacing.iconSm,
              color: AppColors.playfulYellow,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                context.l10n.tapToInteract,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isNight ? AppColors.readerNightText : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// TABAKA 3 — UPAU WA JUU
// =============================================================================

/// Upau wa juu: funga, jina la hadithi, gia ya mipangilio, na "Zaidi".
///
/// Hufifia na kuzimwa kwa mguso (`IgnorePointer`) badala ya kutoweka kwa
/// ghafla — kufifia ni ishara laini kwamba kitu kipo bado.
class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.visible,
    required this.state,
    required this.cubit,
    required this.onClose,
    required this.onSettings,
  });

  final bool visible;
  final ReaderState state;
  final ReaderCubit cubit;
  final VoidCallback onClose;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final String title =
        state.story?.title(swahili: context.isSwahili) ?? l10n.loading;

    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedOpacity(
        duration: AppSpacing.normal,
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Container(
            height: AppSpacing.readerTopBarHeight,
            decoration: BoxDecoration(
              // Gradient cheusi 54% → uwazi: maandishi yanasomeka juu ya
              // mchoro wowote, bila kufunga picha nzima.
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.54),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: <Widget>[
                  IconButton(
                    onPressed: onClose,
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onSettings,
                    tooltip: l10n.settings,
                    icon: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white,
                    ),
                  ),
                  // Shiriki / Ripoti / Maelezo.
                  PopupMenuButton<String>(
                    tooltip: l10n.moreOptions,
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    onSelected: (String value) =>
                        _onMenuSelected(context, value),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'share',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.share_rounded),
                          title: Text(l10n.share),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'report',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.flag_rounded),
                          title: Text(l10n.reportStory),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'info',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.info_outline_rounded),
                          title: Text(l10n.storyInfo),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// "Shiriki/Ripoti/Maelezo".
  ///
  /// **Kushiriki ni kwa kweli.** Tunataka `Share.share` ile ile ya
  /// `story_detail_page`: OS hufungua karatasi yake ya kushiriki, na
  /// mtumiaji huchagua app. Hatuonyeshi "Imeshirikiwa" baada yake —
  /// `Share.share` hurudisha matokeo, lakini kufunga karatasi si uthibitisho
  /// kwamba mtumiaji alikamilisha kushiriki. Kufanya kushiriki tu ndiko
  /// kusema ukweli.
  ///
  /// **Kuripoti hakujajengwa.** Hakuna API ya kuripoti nyuma yake, kwa hivyo
  /// maneno ni ya wazi: kuripoti hakupatikani bado **na hakuna ripoti
  /// iliyotumwa**. Mtumiaji asidhani kamwe kwamba malalamiko yake
  /// yamefika mahali popote.
  void _onMenuSelected(BuildContext context, String value) {
    final AppLocalizations l10n = context.l10n;

    if (value == 'share') {
      // Skrini ya kupakia haina hadithi bado — hivyo hakuna `.title` ya
      // kupiga. Ujumbe wa jumla wenye jina la app bado unaeleweka kwa
      // mpokeaji, na hauangushi ukurasa.
      final Story? story = state.story;
      final String text = story == null
          ? context.localised(
              swahili: 'Soma hadithi kwenye Hadithi Studio!',
              english: 'Read stories on Hadithi Studio!',
            )
          : l10n.shareStoryMessage(story.title(swahili: context.isSwahili));
      unawaited(Share.share(text));
      return;
    }

    final String message;
    switch (value) {
      case 'report':
        message = context.localised(
          swahili: 'Kuripoti hakupatikani bado — hakuna ripoti iliyotumwa.',
          english: "Reporting isn't available yet — no report was sent.",
        );
      default:
        message = state.story == null
            ? l10n.loading
            : '${state.story!.author} · ${state.story!.pageCount} '
                '${l10n.pages} · ${state.story!.readingMinutes} '
                '${l10n.minutes}';
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(duration: AppSpacing.slow, content: Text(message)),
      );
  }
}
