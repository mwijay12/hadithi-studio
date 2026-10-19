import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';
import '../../l10n/l10n.dart';
import '../extensions/context_extensions.dart';
import '../extensions/widget_extensions.dart';
import '../utils/image_utils.dart';
import 'cached_image.dart';
import 'custom_button.dart';

/// Widget ya **hali tupu** (empty state) — maktaba haina hadithi, Maktaba
/// haipo, hakuna matokeo ya utafutaji, hakuna vipakuliwa.
///
/// ## Kwa nini widget hii ipo
///
/// Skrini tupu **inaonekana kama app iliyovunjika.** Mtumiaji mpya wa Hadithi
/// Studio anaanza na maktaba tupu — kama anaona skrini nyeupe, anafikiri
/// kulikuwa na kosa, anafunga app, na hatarudi. Hali tupu lazima: (1)
/// ikubali kwamba hakuna kitu, (2) **iseme kwa nini**, na (3) **impe hatua
/// moja** ya kufanya.
///
/// ## Tofauti na [AppErrorWidget]
///
/// `AppErrorWidget` inashughulikia kitu **kiliharibika**. Hii inashughulikia
/// kitu **hakijatokea bado** — hivyo rangi ni ya app (safariGreen) na si
/// nyekundu, na mchoro ni wa kukaribisha. Kuchanganya hizi mbili
/// kunamfundisha mtumiaji kuogopa skrini tupu.
///
/// ## Kutumia na `RefreshIndicator`
///
/// Kwenye ukurasa usio `compact`, widget inajifunga kwenye
/// `SingleChildScrollView` yenye `AlwaysScrollableScrollPhysics`.
/// **Hii ni muhimu:** `RefreshIndicator` haifyatii kama mtoto wake
/// hawezi kusogea — bila hivi, mtumiaji mwenye orodha tupu hangeweza
/// kuvuta chini ili kupakia upya.
///
/// Matumizi:
/// ```dart
/// if (books.isEmpty) {
///   return const AppEmptyState.noResults(
///     messageSw: 'Badilisha kichujio au tafuta neno lingine.',
///     messageEn: 'Change the filter or search another word.',
///   );
/// }
/// ```
class AppEmptyState extends StatelessWidget {
  /// Hali tupu ya jumla — maandishi huja kutoka nje.
  ///
  /// **Kanuni:** usirudie sentensi za Kiswahili/Kiingereza hapa chini.
  /// Maandishi yanatoka kwenye ARB, na kuna njia mbili za kuyaleta:
  ///
  /// * Njia ya **jumla** — pitisha kitu kile kile kwa `titleSw` na `titleEn`,
  ///   kwa sababu `context.l10n.<key>` tayari imetafsiri kwa lugha ya sasa:
  ///   `titleSw: context.l10n.favorites, titleEn: context.l10n.favorites`.
  ///   Ni maneno mawili mara moja, lakini hairuhusu kuandika sentensi mpya
  ///   hapa — ndiyo lengo.
  /// * Njia **fupi** — kama funguo hiyo inarudi mara nyingi (mfano orodha tupu
  ///   baada ya utafutaji), ongeza preset hapa chini (tazama
  ///   [AppEmptyState.noResults]) ili wito usirudiwe kwenye skrini nyingi.
  const AppEmptyState({
    super.key,
    required this.titleSw,
    required this.titleEn,
    this.messageSw,
    this.messageEn,
    this.icon = Icons.auto_stories_outlined,
    this.onAction,
    this.actionLabelSw,
    this.actionLabelEn,
    this.actionIcon,
    this.actionVariant = AppButtonVariant.primary,
    this.compact = false,
    this.useIllustration = true,
    this.tone,
  })  : _preset = _EmptyPreset.custom,
        assert(
          (onAction == null) ||
              (actionLabelSw != null && actionLabelEn != null),
          'Kitufe cha hatua kinahitaji actionLabelSw NA actionLabelEn '
          '(kanuni ya 4: Kiswahili na Kiingereza).',
        );

  /// Hakuna matokeo ya utafutaji au kichujio — kichwa huja kutoka ARB
  /// (`noResults`), kwa hivyo hakirudiwi hapa.
  const AppEmptyState.noResults({
    super.key,
    this.messageSw,
    this.messageEn,
    this.onAction,
    this.actionLabelSw,
    this.actionLabelEn,
    this.actionIcon = Icons.clear_all,
    this.actionVariant = AppButtonVariant.outline,
    this.compact = false,
    this.useIllustration = true,
    this.tone,
  })  : titleSw = null,
        titleEn = null,
        icon = Icons.search_off_rounded,
        _preset = _EmptyPreset.noResults,
        assert(
          (onAction == null) ||
              (actionLabelSw != null && actionLabelEn != null),
          'Kitufe cha hatua kinahitaji actionLabelSw NA actionLabelEn '
          '(kanuni ya 4: Kiswahili na Kiingereza).',
        );

  /// Maktaba haiwezi kufikiwa — hakuna mtandao na hakuna hadithi
  /// zilizopakuliwa. Kichwa na maelezo yote yanatokana na ARB
  /// (`offlineMode` + `offlineBanner`).
  ///
  /// Tofauti na `AppErrorWidget` kwa `NetworkFailure.offline`: ile ni
  /// **kosa lililotokea** wakati wa ombi; hii ni **hali ya kudumu** ya
  /// kifaa — inaonyeshwa kabla ya ombi lolote kutoka.
  const AppEmptyState.offline({
    super.key,
    this.onAction,
    this.actionLabelSw,
    this.actionLabelEn,
    this.actionIcon = Icons.refresh_rounded,
    this.actionVariant = AppButtonVariant.primary,
    this.compact = false,
    this.tone,
  })  : titleSw = null,
        titleEn = null,
        messageSw = null,
        messageEn = null,
        icon = Icons.wifi_off_rounded,
        useIllustration = true,
        _preset = _EmptyPreset.offline,
        assert(
          (onAction == null) ||
              (actionLabelSw != null && actionLabelEn != null),
          'Kitufe cha hatua kinahitaji actionLabelSw NA actionLabelEn '
          '(kanuni ya 4: Kiswahili na Kiingereza).',
        );

  /// Kichwa kwa Kiswahili — `null` kwa presets zinazotumia ARB.
  final String? titleSw;

  /// Kichwa kwa Kiingereza — `null` kwa presets zinazotumia ARB.
  final String? titleEn;

  /// Maelezo ya ziada (si lazima) kwa Kiswahili.
  final String? messageSw;

  /// Maelezo ya ziada (si lazima) kwa Kiingereza.
  final String? messageEn;

  /// Aikoni ya akiba — inatumika kama asset ya `emptyPlaceholder` haipo.
  final IconData icon;

  /// Hatua moja ya kufanya. `null` = hakuna kitufe (mfano mtumiaji hana
  /// ruhusa ya kuongeza kitu).
  final VoidCallback? onAction;

  final String? actionLabelSw;
  final String? actionLabelEn;

  /// Aikoni ya kitufe cha hatua.
  final IconData? actionIcon;

  /// Aina ya kitufe cha hatua. Chaguo-msingi `primary`; tumia `outline`
  /// kwa vitendo vya upole (mfano "Ondoa kichujio") ili visilingane na
  /// hatua kuu ya ukurasa.
  final AppButtonVariant actionVariant;

  /// `true` = onyesha kwa nafasi ndogo (ndani ya kadi au sehemu ya ukurasa).
  final bool compact;

  /// `true` = onyesha mchoro wa msanii ([AssetConstants.iconEmptyState]
  /// kupitia [AppImageUtils.emptyPlaceholder]).
  ///
  /// Tofauti na `AppErrorWidget` (ambapo chaguo-msingi ni `false`), hapa
  /// chaguo-msingi ni `true`: mchoro wa rafu tupu au mascot unakaribisha,
  /// wakati aikoni ya jumla inaonekana baridi. Aikoni [icon] inabaki kama
  /// akiba, kwa hivyo hali haivunjiki kabla ya asset kuwasili.
  final bool useIllustration;

  /// Rangi ya mchoro/aikoni. `null` = `colorScheme.primary` (safariGreen).
  final Color? tone;

  final _EmptyPreset _preset;

  @override
  Widget build(BuildContext context) {
    final title = switch (_preset) {
      _EmptyPreset.noResults => context.l10n.noResults,
      _EmptyPreset.offline => context.l10n.offlineMode,
      _EmptyPreset.custom => context.localised(
          swahili: titleSw ?? '',
          english: titleEn ?? '',
        ),
    };

    final message = switch (_preset) {
      _EmptyPreset.offline => context.l10n.offlineBanner,
      _EmptyPreset.noResults ||
      _EmptyPreset.custom =>
        (messageSw == null || messageEn == null)
            ? null
            : context.localised(swahili: messageSw!, english: messageEn!),
    };

    // Task 8e inataka mchoro wa 80dp. Tunatumia [AppSpacing.avatarLg] = 72.
    // Tofauti ya 8dp haionekani, na kuingiza sehemu ya tatu ya ukubwa kwenye
    // widget inayotumiwa na skrini zote za app kwa ajili yake kungeongeza
    // API bure. Ukubwa unabaki kwenye mfumo mmoja wa nafasi.
    final glyphSize = compact ? AppSpacing.avatarMd : AppSpacing.avatarLg;
    final color = tone ?? context.colorScheme.primary;
    final hasAction =
        onAction != null && actionLabelSw != null && actionLabelEn != null;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _EmptyGlyph(
          icon: icon,
          color: color,
          size: glyphSize,
          useIllustration: useIllustration,
        ),
        SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),

        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textTheme.headlineSmall,
        ),

        if (message != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
        ],

        if (hasAction) ...[
          SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xxl),
          AppButton(
            labelSw: actionLabelSw!,
            labelEn: actionLabelEn!,
            icon: actionIcon,
            variant: actionVariant,
            size: compact ? AppButtonSize.small : AppButtonSize.medium,
            expand: !compact,
            onPressed: onAction,
          ),
        ],
      ],
    ).constrainWidth(maxWidth: 560);

    return Semantics(
      container: true,
      label: message == null ? title : '$title. $message',
      child: Center(
        child: compact
            // Kwenye kadi tayari ipo scroll ya mzazi — kuongeza scroll
            // nyingine kunasababisha migogoro ya ishara za vidole.
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: content,
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                  vertical: AppSpacing.xxl,
                ),
                child: content,
              ),
      ),
    );
  }
}

/// Mchoro/aikoni ya hali tupu.
class _EmptyGlyph extends StatelessWidget {
  const _EmptyGlyph({
    required this.icon,
    required this.color,
    required this.size,
    required this.useIllustration,
  });

  final IconData icon;
  final Color color;
  final double size;
  final bool useIllustration;

  @override
  Widget build(BuildContext context) {
    // `AppAssetIcon` inashughulikia kesi ya asset isiyokuwepo — muhimu kwa
    // sababu assets za mradi bado hazijawekwa kwenye repo, na `Image.asset`
    // yenye faili isiyokuwepo **hutupa kosa** badala ya kupungua kwa upole.
    final Widget glyph = useIllustration
        ? AppAssetIcon(
            assetPath: AppImageUtils.emptyPlaceholder,
            fallbackIcon: icon,
            size: size,
            color: color,
          )
        : Icon(icon, size: size, color: color);

    // ## Kwa nini fade-in nyepesi
    //
    // Skrini tupu inayoonekana **mara moja** inasoma kama "app imekwama".
    // Kupenya kwa 300ms na kusogea juu kidogo kunasoma kama ukurasa
    // unaanza kufunguka. Hii ni nyepesi (`Opacity` + `Transform`, bila
    // `AnimationController`) kwa sababu `TweenAnimationBuilder` huanza
    // mara moja tu widget inapopandwa; ujenzi upya wa mzazi hausababishi
    // kurudi kwenye 0 — tazama doc ya `TweenAnimationBuilder`.
    return ExcludeSemantics(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (BuildContext context, double t, Widget? child) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * AppSpacing.sm),
              child: child,
            ),
          );
        },
        child: glyph,
      ),
    );
  }
}

/// Preset za maandishi ya hali tupu zinazotumia ARB.
///
/// Ni `enum` ya ndani ili constructors za [AppEmptyState] zibaki `const`
/// (maandishi yanatatuliwa wakati wa `build`, ambapo `BuildContext` ipo).
enum _EmptyPreset {
  /// Maandishi yametolewa na mwitaji.
  custom,

  /// ARB `noResults`.
  noResults,

  /// ARB `offlineMode` + `offlineBanner`.
  offline,
}
