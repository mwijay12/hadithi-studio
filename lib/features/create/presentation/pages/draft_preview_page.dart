/// **ONYESHO LA RASIMU** — kusoma rasimu bila kuihariri.
///
/// ## Kwa nini ukurasa tofauti, sivyo `TextField` zilizozimwa
///
/// Mtoto anayegusa rasimu anataka **kuisoma**, sivyo kuiona kwenye fomu.
/// `TextField` yenye `readOnly` bado ina mwonekano wa fomu (mstari, lebo,
/// kishikio cha maandishi) na haisogei kwa urahisi. Hapa ni maandishi
/// matupu kwenye karatasi, na vitufe vya "nyuma/mbele" kama kitabu.
///
/// ## Hakuna sauti, hakuna hotspot
///
/// `DraftStory` haina data ya sauti wala ya maeneo ya kugusa; kuongeza
/// vitufe hivyo kungezua ahadi ambayo haitekelezwi. Kwa hivyo onyesho ni
/// la maandishi pekee — na linasema hivyo.
library;

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/library_store.dart';

/// Onyesho la rasimu [draft], ukurasa mmoja kwa wakati.
class DraftPreviewPage extends StatefulWidget {
  /// Huunda onyesho la [draft].
  const DraftPreviewPage({super.key, required this.draft});

  /// Rasimu inayoonyeshwa.
  final DraftStory draft;

  @override
  State<DraftPreviewPage> createState() => _DraftPreviewPageState();
}

class _DraftPreviewPageState extends State<DraftPreviewPage> {
  /// Ukurasa unaoonyeshwa sasa (kuanzia 0).
  int _index = 0;

  /// Kurasa halisi za rasimu.
  ///
  /// Maandishi ya Kiswahili ni ya msingi; Kiingereza ni akiba kwa rasimu
  /// zilizoingizwa kwa njia nyingine. Hatuchanganyi kurasa za lugha mbili.
  List<String> get _pages => widget.draft.pagesSw.isNotEmpty
      ? widget.draft.pagesSw
      : widget.draft.pagesEn;

  void _goTo(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final List<String> pages = _pages;
    // Skrini ya 320dp: padding ya 24 kwa upande ingeacha nafasi ndogo
    // mno kwa maandishi ya hadithi.
    final double side = context.isCompact ? AppSpacing.lg : AppSpacing.xxl;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        title: Text(
          widget.draft.titleSw,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: pages.isEmpty
            ? _NoPages(titleSw: widget.draft.titleSw)
            : Padding(
                padding: EdgeInsets.fromLTRB(
                  side,
                  AppSpacing.md,
                  side,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: <Widget>[
                    // Ukurasa usio halali hauwezi kutokea kwa kugusa vitufe
                    // vilivyozimwa, lakini `clamp` hulinda dhidi ya data
                    // iliyohifadhiwa vibaya.
                    _PageBody(
                      key: ValueKey<int>(_index),
                      text: pages[_clampedIndex(pages.length)],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        IconButton(
                          onPressed: _clampedIndex(pages.length) > 0
                              ? () => _goTo(_clampedIndex(pages.length) - 1)
                              : null,
                          icon: const Icon(Icons.chevron_left_rounded),
                          iconSize: AppSpacing.iconLg,
                          tooltip: context.isSwahili
                              ? 'Ukurasa uliopita'
                              : 'Previous page',
                        ),
                        Expanded(
                          child: Text(
                            context.isSwahili
                                ? 'Ukurasa ${_clampedIndex(pages.length) + 1} '
                                    'kati ya ${pages.length}'
                                : 'Page ${_clampedIndex(pages.length) + 1} '
                                    'of ${pages.length}',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              _clampedIndex(pages.length) < pages.length - 1
                                  ? () => _goTo(_clampedIndex(pages.length) + 1)
                                  : null,
                          icon: const Icon(Icons.chevron_right_rounded),
                          iconSize: AppSpacing.iconLg,
                          tooltip:
                              context.isSwahili ? 'Ukurasa unaofuata' : 'Next page',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      context.isSwahili
                          ? 'Rasimu ya maandishi — hakuna sauti wala '
                              'viungo vya kugusa.'
                          : 'Text draft — no audio and no tappable hotspots.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Faharasa salama ndani ya [length] kurasa.
  int _clampedIndex(int length) {
    if (_index < 0) return 0;
    if (_index >= length) return length - 1;
    return _index;
  }
}

/// Maandishi ya ukurasa mmoja, yanayosogea yenyewe.
class _PageBody extends StatelessWidget {
  const _PageBody({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: SingleChildScrollView(
          child: Text(
            text,
            // Rangi na ukubwa hutoka theme; `height` ni nafasi ya kupumua
            // kwa msomaji mdogo.
            style: TextStyle(
              fontSize: 17,
              height: 1.7,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

/// Rasimu isiyo na kurasa — hali ya kujua, sivyo kosa.
class _NoPages extends StatelessWidget {
  const _NoPages({required this.titleSw});

  final String titleSw;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.menu_book_rounded,
              size: AppSpacing.iconXl,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              context.isSwahili
                  ? '"$titleSw" haina kurasa zenye maandishi.'
                  : '"$titleSw" has no pages with text.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
