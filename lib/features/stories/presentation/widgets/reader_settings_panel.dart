/// **READER SETTINGS PANEL** — kisanduku cha mipangilio kinachotokea kulia.
///
/// Upana wake ni `AppSpacing.settingsPanelWidth` (300) au
/// `settingsPanelWidthRatio` (80%) ya skrini kwenye simu ndogo — kwenye
/// Tecno ya inchi 5, panel ya 300 ingeacha milango 20 tu ya mchoro, ambayo
/// haisaidii mtu.
///
/// Kina vitu vitano:
/// 1. **Ukubwa wa maandishi** — slider `16`–`28` sp, hatua `2` (tazama
///    `_fontSteps`).
/// 2. **Hali ya usiku** — swichi.
/// 3. **Hali ya kusoma** — redio tatu (`Soma na Sikiliza` ndiyo ya kawaida).
/// 4. **Kugeuza kurasa kiotomatiki** — swichi + kichaguzi cha sekunde
///    (`1`, `2`, `3`, `5`).
/// 5. **Muziki wa mandhari** — kielelezo cha mahali (placeholder), kimezimwa
///    kwa makusudi hadi Prompt 6.
library;

import 'package:flutter/material.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../l10n/l10n.dart';
import '../cubit/reader_cubit.dart';
import '../state/reader_state.dart';

/// Hatua za ukubwa wa maandishi zinazoruhusiwa (sp).
///
/// Kwa nini hatua ya 2 na si kila sp: maandishi ya hadithi ni **Merriweather**
/// (fonti ya kitabu) — tofauti ya sp 1 haionekani, lakini inaunda hali nyingi
/// ambazo hazina maana kwa mtumiaji. Hatua ya 2 inatoa chaguo saba wazi.
const List<double> _fontSteps = <double>[16, 18, 20, 22, 24, 26, 28];

/// Kisanduku cha mipangilio ya kusoma.
class ReaderSettingsPanel extends StatelessWidget {
  const ReaderSettingsPanel({
    super.key,
    required this.state,
    required this.cubit,
    required this.width,
    this.onClose,
    this.onPreviewFont,
  });

  /// Hali ya sasa.
  final ReaderState state;

  /// Cubit ya reader.
  final ReaderCubit cubit;

  /// Upana halisi (umeshahesabiwa na ukurasa kutokana na skrini).
  final double width;

  /// Kufunga panel.
  final VoidCallback? onClose;

  /// Huitwa kwa kila mabadiliko ya slider — ukurasa huonyesha mfano.
  final ValueChanged<double>? onPreviewFont;

  /// Hatua ya karibu zaidi kwenye [_fontSteps] kwa saizi ya sasa.
  static double nearestFontStep(double size) {
    var nearest = _fontSteps.first;
    var smallest = (size - nearest).abs();
    for (final double step in _fontSteps) {
      final double gap = (size - step).abs();
      if (gap < smallest) {
        smallest = gap;
        nearest = step;
      }
    }
    return nearest;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final bool swahili = context.isSwahili;
    final bool night = Theme.of(context).brightness == Brightness.dark;
    final Color ink = night ? AppColors.readerNightText : AppColors.darkText;

    return Material(
      color: night ? AppColors.readerNightSurface : AppColors.cardBackground,
      child: SizedBox(
        width: width,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Kichwa cha panel.
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        l10n.readingSettings,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: ink,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      tooltip: l10n.close,
                      icon: Icon(Icons.close_rounded, color: ink),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: <Widget>[
                    // ---------------------------------------------------------
                    // 1. UKUBWA WA MAANDISHI
                    // ---------------------------------------------------------
                    _SectionTitle(label: l10n.fontSize, ink: ink),
                    Row(
                      children: <Widget>[
                        Text(
                          '${state.storyFontSize.round()}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.safariGreen,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        Text(
                          'sp',
                          style: TextStyle(color: ink.withOpacity(0.7)),
                        ),
                        const Spacer(),
                        Text(
                          swahili ? 'Ndogo' : 'Small',
                          style: TextStyle(
                            fontSize: 11,
                            color: ink.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          swahili ? 'Kubwa' : 'Large',
                          style: TextStyle(
                            fontSize: 11,
                            color: ink.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: nearestFontStep(state.storyFontSize),
                      min: _fontSteps.first,
                      max: _fontSteps.last,
                      // Hatua 6 kati ya 7 thamani — hivyo slider inashikamana
                      // kwenye kila saizi halali, si kuteleza bure.
                      divisions: _fontSteps.length - 1,
                      label: '${nearestFontStep(state.storyFontSize).round()} sp',
                      activeColor: AppColors.safariGreen,
                      onChanged: (double value) {
                        // Slider huzungumza **sp**; hali huhifadhi kizidishi.
                        // Tafsiri iko kwenye `ReaderState.textScaleForFontSize`.
                        cubit.setTextScale(
                          ReaderState.textScaleForFontSize(value),
                        );
                        onPreviewFont?.call(value);
                      },
                    ),
                    // Mfano wa maandishi — mtoto/mzazi anaona matokeo papo hapo.
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: ink.withOpacity(0.05),
                        borderRadius: AppSpacing.borderRadiusSm,
                      ),
                      child: Text(
                        context.localised(
                          swahili: 'Hapo zamani za kale…',
                          english: 'Once upon a time…',
                        ),
                        style: TextStyle(
                          fontSize: nearestFontStep(state.storyFontSize),
                          height: 1.6,
                          color: ink,
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // ---------------------------------------------------------
                    // 2. HALI YA USIKU
                    // ---------------------------------------------------------
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: state.isNightMode,
                      activeColor: AppColors.safariGreen,
                      title: Text(
                        l10n.nightMode,
                        style: TextStyle(color: ink, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        context.localised(
                          swahili: 'Rangi nyeupe hupunguza uchovu wa macho',
                          english: 'Softer colours, easier at night',
                        ),
                        style: TextStyle(fontSize: 12, color: ink.withOpacity(0.7)),
                      ),
                      onChanged: (_) => cubit.toggleNightMode(),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // ---------------------------------------------------------
                    // 3. HALI YA KUSOMA
                    // ---------------------------------------------------------
                    _SectionTitle(label: l10n.readingMode, ink: ink),
                    for (final ReadingMode mode in ReadingMode.values)
                      RadioListTile<ReadingMode>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        value: mode,
                        // `groupValue` inaweza kuwa null kwenye Flutter 3.16
                        // bila kosa — hivyo hakuna `!`.
                        groupValue: state.readingMode,
                        activeColor: AppColors.safariGreen,
                        title: Text(
                          readingModeLabel(l10n, mode),
                          style: TextStyle(color: ink),
                        ),
                        onChanged: (ReadingMode? value) {
                          if (value != null) cubit.setReadingMode(value);
                        },
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // ---------------------------------------------------------
                    // 4. KUGEUZA KURASA KIOTOMATIKI
                    // ---------------------------------------------------------
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: state.autoPageTurn,
                      activeColor: AppColors.safariGreen,
                      title: Text(
                        l10n.autoPageTurn,
                        style: TextStyle(color: ink, fontWeight: FontWeight.w600),
                      ),
                      onChanged: (_) => cubit.toggleAutoPageTurn(),
                    ),
                    if (state.autoPageTurn) ...<Widget>[
                      _SectionTitle(label: l10n.turnDelay, ink: ink),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: <Widget>[
                          for (final int seconds in ReaderState.autoTurnDelayOptions)
                            ChoiceChip(
                              // Lebo inatumia ARB (`delaySeconds`) — "2 s".
                              label: Text(l10n.delaySeconds(seconds)),
                              selected: state.autoTurnDelay == seconds,
                              selectedColor:
                                  AppColors.safariGreen.withOpacity(0.20),
                              onSelected: (_) => cubit.setAutoTurnDelay(seconds),
                            ),
                        ],
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // ---------------------------------------------------------
                    // 5. MUZIKI WA MANDHARI (kielelezo — Prompt 6)
                    // ---------------------------------------------------------
                    _SectionTitle(label: l10n.backgroundMusic, ink: ink),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.music_note_rounded,
                          size: AppSpacing.iconSm,
                          color: ink.withOpacity(0.5),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            context.localised(
                              swahili: 'Itakuja na Prompt 6',
                              english: 'Coming with Prompt 6',
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: ink.withOpacity(0.6),
                            ),
                          ),
                        ),
                        // Kimezimwa kwa makusudi: hatuweki swichi inayofanya
                        // kitu ambacho hakipo.
                        Switch(
                          value: false,
                          onChanged: null,
                          activeColor: AppColors.safariGreen,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Kitufe cha "Anza upya" — husafisha maendeleo ya hadithi.
                    OutlinedButton.icon(
                      onPressed: () => _confirmStartOver(context, l10n, swahili),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text(l10n.startOver),
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

  /// Lebo ya [ReadingMode] kutoka ARB.
  static String readingModeLabel(AppLocalizations l10n, ReadingMode mode) {
    switch (mode) {
      case ReadingMode.readAndListen:
        return l10n.readAndListen;
      case ReadingMode.listenOnly:
        return l10n.listenOnly;
      case ReadingMode.readOnly:
        return l10n.readOnly;
    }
  }

  /// Huthibitisha "Anza upya" — hatua hii hufuta maendeleo yaliyohifadhiwa.
  Future<void> _confirmStartOver(
    BuildContext context,
    AppLocalizations l10n,
    bool swahili,
  ) async {
    final bool? agreed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.startOver),
          content: Text(
            context.localised(
              swahili: 'Maendeleo yako ya hadithi hii yatafutwa. Una uhakika?',
              english: 'Your progress for this story will be cleared. '
                  'Are you sure?',
            ),
          ),
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

    if (agreed ?? false) {
      await cubit.startOver();
      onClose?.call();
    }
  }
}

/// Kichwa kidogo cha sehemu ndani ya panel.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, required this.ink});

  final String label;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          letterSpacing: 0.8,
          fontWeight: FontWeight.w700,
          color: ink.withOpacity(0.55),
        ),
      ),
    );
  }
}
