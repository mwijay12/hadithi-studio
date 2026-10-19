/// **TTS CONTROLS** — upau wa kudhibiti kusoma kwa sauti.
///
/// Huu ni upau unaoelea juu ya mchoro (si sehemu ya `Scaffold.appBar`), hivyo
/// una **kona ya juu ya 24** na kivuli kinachokifanya kionekane kama kadi.
/// Muundo wake ni safu mbili:
///
/// 1. **Safu kuu** (`AppSpacing.ttsMainRowHeight` = 80) — nyuma, cheza/simamisha
///    (kitufe cha mviringo cha 56 chenye mng'ao), na mbele.
/// 2. **Safu ya chips** — kasi, sauti ya msomaji, kugeuza kurasa kiotomatiki,
///    na alama.
///
/// Juu kabisa kuna mstari mwembamba wa **Safari Green** (3 px) unaoonyesha
/// maendeleo ya kusoma. Mstari huo ni sehemu ya upau (si `AppBar` ya chini)
/// kwa sababu hapa ndipo mtoto anatazama wakati anasikiliza.
///
/// **Sauti tatu, si nne.** Task 4 inataja sauti ya "English"; `ReaderVoice`
/// haina hiyo na haipaswi kuwa nayo: lugha ya kusoma inatawaliwa na lugha ya
/// app (`context.isSwahili` → `preferSwahili` ya injini), ambayo tayari ni
/// swichi ya mtumiaji. Kuongeza "English" kama sauti kungeunda hali ambapo
/// maandishi yanaonekana Kiswahili lakini yanasomwa Kiingereza.
library;

// `FontFeature` ni ya `dart:ui`; `material.dart` haitoi hiyo — hivyo
// tunaileta kwa `show` ili tusivute `Color`/`Offset` zinazogongana.

import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/audio_utils.dart';
import '../../../../l10n/l10n.dart';
import '../cubit/reader_cubit.dart';
import '../state/reader_state.dart';

/// Lebo ya kasi kutoka `AppAudioUtils.readerSpeedLabelKey` kwenda ARB.
///
/// Sheria ya kupanga kizidishi → lebo iko kwenye `AppAudioUtils` (mahali pamoja);
/// hapa tunatafsiri tu ufunguo kuwa maandishi ya lugha iliyochaguliwa.
String speedLabelFor(AppLocalizations l10n, double multiplier) {
  switch (AppAudioUtils.readerSpeedLabelKey(multiplier)) {
    case 'slow':
      return l10n.slow;
    case 'speedGentle':
      return l10n.speedGentle;
    case 'normal':
      return l10n.normal;
    case 'speedQuick':
      return l10n.speedQuick;
    case 'fast':
      return l10n.fast;
    default:
      return l10n.veryFast;
  }
}

/// Upau wa kudhibiti TTS.
///
/// Hupokea [state] na [cubit] moja kwa moja — hivyo hakiitaji `BlocProvider`
/// ndani ya `showModalBottomSheet` (ambayo hujengwa chini ya `Navigator`, si
/// chini ya provider yetu).
class TtsControls extends StatelessWidget {
  const TtsControls({
    super.key,
    required this.state,
    required this.cubit,
    this.onBookmark,
    this.onAutoPage,
    this.showProgress = true,
  });

  /// Hali ya sasa ya reader.
  final ReaderState state;

  /// Cubit ya reader — vitufe huita moja kwa moja.
  final ReaderCubit cubit;

  /// Kugusa alama. Ukurasa huongeza mtetemo na ujumbe (`SnackBar`).
  final VoidCallback? onBookmark;

  /// Kubadilisha kugeuza kurasa kiotomatiki.
  final VoidCallback? onAutoPage;

  /// `false` = ficha mstari wa maendeleo (mfano kwenye skrini ndogo sana).
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool swahili = context.isSwahili;
    // Wakati wa usiku tunatumia uso wa giza ili upau usivunjé hali nzima.
    final bool night = Theme.of(context).brightness == Brightness.dark;
    final Color surface =
        night ? AppColors.readerNightSurface : AppColors.cardBackground;
    final Color ink = night ? AppColors.readerNightText : AppColors.darkText;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xxl),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xxl),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Mstari wa maendeleo — Safari Green, 3 px.
              if (showProgress)
                LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 3,
                  color: AppColors.safariGreen,
                  backgroundColor: night
                      ? AppColors.readerNightBackground
                      : AppColors.divider,
                ),

              // Onyo la uaminifu: hakuna injini ya sauti kwenye kifaa hiki.
              if (!state.speechAvailable) _NoAudioNotice(ink: ink),

              // **Safu kuu (80 px).**
              SizedBox(
                height: AppSpacing.ttsMainRowHeight,
                child: Row(
                  children: <Widget>[
                    _RoundIconButton(
                      icon: Icons.skip_previous_rounded,
                      tooltip: context.localised(
                        swahili: 'Ukurasa uliopita',
                        english: 'Previous page',
                      ),
                      onPressed: state.isFirstPage ? null : cubit.previousPage,
                      color: ink,
                    ),
                    Expanded(
                      child: Center(
                        child: _PlayButton(
                          state: state,
                          onPressed: state.speechAvailable && state.allowsAudio
                              ? cubit.toggleReadAloud
                              : null,
                        ),
                      ),
                    ),
                    _RoundIconButton(
                      icon: Icons.skip_next_rounded,
                      tooltip: context.localised(
                        swahili: 'Ukurasa unaofuata',
                        english: 'Next page',
                      ),
                      onPressed: state.isLastPage ? null : cubit.nextPage,
                      color: ink,
                    ),
                  ],
                ),
              ),

              // **Safu ya chips.**
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: <Widget>[
                    _ReaderChip(
                      icon: Icons.speed_rounded,
                      label: speedLabelFor(l10n, state.rateMultiplier),
                      semanticLabel: l10n.speed,
                      onTap: () => _showSpeedPicker(context, l10n, swahili),
                      ink: ink,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ReaderChip(
                      icon: Icons.record_voice_over_rounded,
                      label: voiceLabelFor(l10n, state.voice),
                      semanticLabel: l10n.ttsVoice,
                      onTap: () => _showVoicePicker(context, l10n, swahili),
                      ink: ink,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ReaderChip(
                      icon: state.autoPageTurn
                          ? Icons.autorenew_rounded
                          : Icons.autorenew_outlined,
                      label: l10n.autoPageTurn,
                      semanticLabel: l10n.autoPageTurn,
                      selected: state.autoPageTurn,
                      onTap: onAutoPage ?? cubit.toggleAutoPageTurn,
                      ink: ink,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ReaderChip(
                      icon: state.isCurrentPageBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      label: l10n.bookmark,
                      semanticLabel: l10n.bookmark,
                      // Alama hupata Sunset Gold — rangi ya jua la Tanzania.
                      selectedColor: AppColors.sunsetGold,
                      selected: state.isCurrentPageBookmarked,
                      onTap: onBookmark ?? cubit.toggleBookmark,
                      ink: ink,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Kielelezo cha ukurasa — "3/6" (Task 2).
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                      ),
                      child: Text(
                        '${state.pageIndex + 1}/${state.totalPages}',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFeatures: const <FontFeature>[
                            FontFeature.tabularFigures(),
                          ],
                        ),
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

  /// Lebo ya sauti ya msomaji kutoka ARB.
  static String voiceLabelFor(AppLocalizations l10n, ReaderVoice voice) {
    switch (voice) {
      case ReaderVoice.mama:
        return l10n.voiceMama;
      case ReaderVoice.baba:
        return l10n.voiceBaba;
      case ReaderVoice.mtoto:
        return l10n.voiceMtoto;
    }
  }

  /// Huchagua kasi kati ya hatua saba za kizidishi.
  void _showSpeedPicker(
    BuildContext context,
    AppLocalizations l10n,
    bool swahili,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  l10n.speed,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              for (final double step in _readerSpeedSteps)
                ListTile(
                  leading: Icon(
                    Icons.speed_rounded,
                    color: state.rateMultiplier == step
                        ? AppColors.safariGreen
                        : AppColors.mutedText,
                  ),
                  title: Text(speedLabelFor(l10n, step)),
                  subtitle: Text(
                    AppAudioUtils.speedDescription(step, swahili: swahili),
                  ),
                  trailing: state.rateMultiplier == step
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.safariGreen,
                        )
                      : null,
                  onTap: () {
                    cubit.setRateMultiplier(step);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  /// Huchagua sauti ya msomaji (Mama / Baba / Mtoto).
  void _showVoicePicker(
    BuildContext context,
    AppLocalizations l10n,
    bool swahili,
  ) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  l10n.ttsVoice,
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                ),
              ),
              for (final ReaderVoice voice in ReaderVoice.values)
                ListTile(
                  leading: Icon(
                    Icons.person_rounded,
                    color: state.voice == voice
                        ? AppColors.safariGreen
                        : AppColors.mutedText,
                  ),
                  title: Text(voiceLabelFor(l10n, voice)),
                  subtitle: Text(
                    context.localised(
                      swahili: 'Kasi ${(voice.rate * 100).round()}%, '
                          'sauti ${voice.pitch.toStringAsFixed(2)}',
                      english: 'Rate ${(voice.rate * 100).round()}%, '
                          'pitch ${voice.pitch.toStringAsFixed(2)}',
                    ),
                  ),
                  trailing: state.voice == voice
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.safariGreen,
                        )
                      : null,
                  onTap: () {
                    cubit.setVoice(voice);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Hatua zote za kasi ya reader (`0.70`–`1.30`, hatua `0.10`).
///
/// Zinatokana na `ReaderState.minRateMultiplier`/`maxRateMultiplier` na hatua
/// ya cubit — hazijaandikwa kwa mkono ili kubadilisha kikomo mahali pamoja
/// kubadilishe orodha hii pia.
final List<double> _readerSpeedSteps = <double>[
  for (
    double step = ReaderState.minRateMultiplier;
    step <= ReaderState.maxRateMultiplier + 0.001;
    step += 0.10
  )
    double.parse(step.toStringAsFixed(2)),
];

/// Kitufe cha mviringo cha kucheza/kusimamisha (56 × 56) chenye mng'ao.
class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.state, required this.onPressed});

  final ReaderState state;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool enabled = onPressed != null;
    final IconData icon = state.isSpeaking && !state.isPaused
        ? Icons.pause_rounded
        : Icons.play_arrow_rounded;
    final String tooltip = state.isSpeaking && !state.isPaused
        ? l10n.pause
        : (state.isPaused ? l10n.resume : l10n.readAloud);

    final Color fill = enabled ? AppColors.safariGreen : AppColors.mutedText;

    return Semantics(
      button: true,
      enabled: enabled,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: AnimatedContainer(
          duration: AppSpacing.fast,
          width: AppSpacing.playButtonSize,
          height: AppSpacing.playButtonSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            // Mng'ao hupungua wakati kitufe kimezimwa — ishara ya macho
            // inayolingana na hali halisi.
            boxShadow: enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.safariGreen.withValues(alpha: 0.55),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: Icon(
                icon,
                size: AppSpacing.playIconSize,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Kitufe cha mviringo cha kawaida (nyuma/mbele) lenye eneo la kugusa la 48.
class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.color,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        iconSize: AppSpacing.iconLg,
        // Eneo la kugusa la chini kabisa — vidole vya watoto ni vidogo.
        constraints: const BoxConstraints(
          minWidth: AppSpacing.minTouchTarget,
          minHeight: AppSpacing.minTouchTarget,
        ),
      ),
    );
  }
}

/// Chip ndogo inayotumika kwenye safu ya chini ya upau.
class _ReaderChip extends StatelessWidget {
  const _ReaderChip({
    required this.icon,
    required this.label,
    required this.semanticLabel,
    required this.onTap,
    required this.ink,
    this.selected = false,
    this.selectedColor = AppColors.safariGreen,
  });

  final IconData icon;
  final String label;
  final String semanticLabel;
  final VoidCallback onTap;
  final Color ink;
  final bool selected;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: Material(
        color: selected
            ? selectedColor.withValues(alpha: 0.18)
            : ink.withValues(alpha: 0.06),
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
                Icon(
                  icon,
                  size: AppSpacing.iconSm,
                  color: selected ? selectedColor : ink,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? selectedColor : ink,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
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

/// Onyo la wazi: kifaa hiki hakiwezi kutoa sauti.
///
/// Kwa nini tunasema hivi: spec inataka uaminifu. Kitufe cha kucheza
/// kinazimwa, lakini mtumiaji asielewe kwa nini — hivyo tunasema.
class _NoAudioNotice extends StatelessWidget {
  const _NoAudioNotice({required this.ink});

  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.volume_off_rounded,
            size: AppSpacing.iconSm,
            color: AppColors.kangaOrange,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              context.localised(
                swahili: 'Sauti haipatikani kwenye kifaa hiki — unaweza '
                    'kusoma kwa macho.',
                english: 'Audio is not available on this device — you can '
                    'still read along.',
              ),
              style: TextStyle(fontSize: 12, color: ink.withValues(alpha: 0.75)),
            ),
          ),
        ],
      ),
    );
  }
}
