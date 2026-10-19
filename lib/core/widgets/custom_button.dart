/// WIDGET: vitufe vinavyotumika kwenye app yote.
///
/// **Kwa nini wrapper badala ya `FilledButton` moja kwa moja:** kanuni ya 4
/// inasema kila kitu kinachoonekana kwa mtumiaji kiwe na Kiswahili **na**
/// Kiingereza. `FilledButton` haijui hilo, hivyo kila mahali kungekuwa na
/// `context.localised(...)` iliyorudiwa — na mahali pamoja pangepotea. Hapa
/// tunachukua `labelSw`/`labelEn` mara moja na kuchagua kwa wakati wa build.
///
/// **Hali ya kupakia (loading) ni ya lazima, si mapambo.** Mtumiaji wa M-Pesa
/// anayebonyeza "Lipa 5,000" kisha kuona kitufe kile kile bila mabadiliko
/// atabonyeza tena — na anaweza kusababisha malipo mawili. [AppButton] huzima
/// kitufe na kuonyesha mduara ndani yake mara moja `isLoading` inapokuwa `true`.
///
/// **Ukubwa wa kugusa (touch target):** `AppButtonSize.small` ina urefu wa
/// 40dp kwa **muonekano**, lakini `MaterialTapTargetSize.padded` (default ya
/// Flutter) inahakikisha eneo la kugusa linabaki 48dp — kwa hivyo haivunji
/// kanuni ya ufikiaji ([AppSpacing.minTouchTarget]).
library;

import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';
import '../../config/theme/typography.dart';
import '../../l10n/l10n.dart';
import '../extensions/context_extensions.dart';
import 'cached_image.dart';
import 'loading_widget.dart';

/// Aina ya kitufe — hubadilisha rangi na uzito wa kuonekana.
enum AppButtonVariant {
  /// Hatua kuu: "Anza Kusoma", "Lipa", "Hifadhi".
  primary,

  /// Hatua ya pili: "Shiriki", "Pakua".
  secondary,

  /// Hatua isiyo na rangi: "Sogeza mbele", "Rudi".
  outline,

  /// Kiungo cha maandishi: "Soma zaidi", "Ruka".
  text,

  /// Hatua ya kuharibu: "Futa akaunti", "Ondoa".
  danger,
}

/// Ukubwa wa kitufe.
enum AppButtonSize {
  small,
  medium,
  large;

  /// Urefu wa kuonekana kwa kitufe.
  double get height => switch (this) {
        AppButtonSize.small => AppSpacing.buttonHeightSmall,
        AppButtonSize.medium => AppSpacing.buttonHeight,
        AppButtonSize.large => AppSpacing.buttonHeight + AppSpacing.sm,
      };

  /// Ukubwa wa maandishi — kwenye kitufe kidogo tunapunguza.
  ///
  /// Namba zinatoka `AppTypography` ili kubadilisha ukubwa wa maandishi
  /// kufanyike mahali pamoja (kanuni: "delegate, don't duplicate").
  double get fontSize => this == AppButtonSize.small
      ? AppTypography.sizeBodySmall
      : AppTypography.sizeBody;

  /// Padding ya ndani — kitufe kikubwa kinapata nafasi zaidi kwa maandishi.
  EdgeInsetsGeometry get padding => EdgeInsets.symmetric(
        horizontal: this == AppButtonSize.small
            ? AppSpacing.lg
            : AppSpacing.xxl,
      );
}

/// Kitufe cha app yenye maandishi ya lugha mbili na hali ya kupakia.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.labelSw,
    required this.labelEn,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.iconAsset,
    this.expand = true,
    this.trailing,
  });

  /// Maandishi kwa Kiswahili.
  final String labelSw;

  /// Maandishi kwa Kiingereza.
  final String labelEn;

  /// `null` = kitufe kimezimwa.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final AppButtonSize size;

  /// `true` = onyesha mduara na zima kitufe.
  final bool isLoading;

  /// Aikoni ya Material (mfano `Icons.play_arrow_rounded`).
  final IconData? icon;

  /// Asset ya aikoni — ikikosekana, [icon] hutumika.
  final String? iconAsset;

  /// `true` = kitufe kichukue upana wote unaopatikana.
  final bool expand;

  /// Kitufe cha ziada upande wa kulia (mfano bei kwenye "Lipa TZS 5,000").
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    final sized = SizedBox(
      width: expand ? double.infinity : null,
      child: button,
    );

    // `Semantics` inahakikisha screen reader inasoma maandishi kamili hata
    // wakati kitufe kimezimwa au kimefungwa kwa mduara.
    return Semantics(
      button: true,
      enabled: onPressed != null && !isLoading,
      label: context.localised(swahili: labelSw, english: labelEn),
      child: sized,
    );
  }

  // ---------------------------------------------------------------------------
  // Ujenzi
  // ---------------------------------------------------------------------------

  Widget _buildButton(BuildContext context) {
    final scheme = context.colorScheme;
    final style = _style(context, scheme);
    final child = _child(context, scheme);

    // `onPressed` inakuwa `null` wakati wa kupakia — hii inazima kitufe na
    // inazuia malipo/kuwasilisha mara mbili (tazama ufafanuzi wa faili).
    final handler = isLoading ? null : onPressed;

    return switch (variant) {
      AppButtonVariant.primary ||
      AppButtonVariant.danger =>
        FilledButton(style: style, onPressed: handler, child: child),
      AppButtonVariant.secondary =>
        ElevatedButton(style: style, onPressed: handler, child: child),
      AppButtonVariant.outline =>
        OutlinedButton(style: style, onPressed: handler, child: child),
      AppButtonVariant.text =>
        TextButton(style: style, onPressed: handler, child: child),
    };
  }

  ButtonStyle _style(BuildContext context, ColorScheme scheme) {
    final visual = switch (variant) {
      AppButtonVariant.primary => ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(scheme.primary),
          foregroundColor: WidgetStatePropertyAll<Color>(scheme.onPrimary),
        ),
      AppButtonVariant.secondary => ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(scheme.secondary),
          foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
        ),
      AppButtonVariant.outline => ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          foregroundColor: WidgetStatePropertyAll<Color>(scheme.primary),
          side: WidgetStatePropertyAll<BorderSide>(
            BorderSide(color: scheme.primary.withValues(alpha: 0.5)),
          ),
        ),
      AppButtonVariant.text => ButtonStyle(
          backgroundColor: const WidgetStatePropertyAll<Color>(
            Colors.transparent,
          ),
          foregroundColor: WidgetStatePropertyAll<Color>(scheme.primary),
        ),
      AppButtonVariant.danger => ButtonStyle(
          backgroundColor: WidgetStatePropertyAll<Color>(scheme.error),
          foregroundColor: WidgetStatePropertyAll<Color>(scheme.onError),
        ),
    };

    return visual.copyWith(
      // `Size(0, height)` badala ya `Size.fromHeight` ili kitufe kisichopanuka
      // kiwe na upana wa maudhui yake, si upana wote.
      minimumSize: WidgetStatePropertyAll<Size>(
        Size(0, size.height),
      ),
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(size.padding),
      // `elevation: 0` — vivuli hupunguza utendaji kwenye simu za 2GB RAM
      // wakati wa kusogeza orodha ndefu.
      elevation: const WidgetStatePropertyAll<double>(0),
      shape: const WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
      ),
      textStyle: WidgetStatePropertyAll<TextStyle?>(
        context.textTheme.labelLarge?.copyWith(fontSize: size.fontSize),
      ),
    );
  }

  Widget _child(BuildContext context, ColorScheme scheme) {
    if (isLoading) {
      return AppLoading(
        size: AppLoadingSize.small,
        color: _contentColor(scheme),
      );
    }

    final label = Text(
      context.localised(swahili: labelSw, english: labelEn),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );

    final hasIcon = icon != null || iconAsset != null;
    if (!hasIcon && trailing == null) return label;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (iconAsset != null) ...<Widget>[
          AppAssetIcon(
            assetPath: iconAsset!,
            fallbackIcon: icon ?? Icons.circle_outlined,
            size: AppSpacing.iconSm,
            color: _contentColor(scheme),
          ),
          const SizedBox(width: AppSpacing.sm),
        ] else if (icon != null) ...<Widget>[
          Icon(icon, size: AppSpacing.iconSm, color: _contentColor(scheme)),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(child: label),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: AppSpacing.sm),
          trailing!,
        ],
      ],
    );
  }

  /// Rangi ya maandishi/aikoni ndani ya kitufe — inategemea aina.
  Color _contentColor(ColorScheme scheme) => switch (variant) {
        AppButtonVariant.primary => scheme.onPrimary,
        AppButtonVariant.secondary => Colors.white,
        AppButtonVariant.danger => scheme.onError,
        AppButtonVariant.outline || AppButtonVariant.text => scheme.primary,
      };
}

/// Kitufe cha aikoni pekee (mfano "funga", "shiriki", "sauti").
///
/// Kina eneo la kugusa la [AppSpacing.minTouchTarget] — kanuni ya ufikiaji:
/// kitufe cha aikoni pekee ndicho kinachovunjwa mara nyingi zaidi kwenye
/// app za watoto, kwa sababu aikoni ndogo inaonekana nzuri kwenye mockup.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltipSw,
    required this.tooltipEn,
    this.onPressed,
    this.iconAsset,
    this.color,
    this.size = AppSpacing.iconMd,
    this.badgeCount,
  });

  final IconData icon;

  /// Maandishi ya maelezo (tooltip) kwa Kiswahili — pia hutumika kama
  /// `semanticLabel` kwa screen reader.
  final String tooltipSw;

  /// Maandishi ya maelezo kwa Kiingereza.
  final String tooltipEn;

  final VoidCallback? onPressed;
  final String? iconAsset;
  final Color? color;
  final double size;

  /// Namba inayoonyeshwa kwenye pembe (mfano idadi ya arifa).
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final tooltip = context.localised(swahili: tooltipSw, english: tooltipEn);
    final tint = color ??
        (onPressed == null
            ? context.colorScheme.onSurface.withValues(alpha: 0.38)
            : context.colorScheme.primary);

    final button = IconButton(
      onPressed: onPressed,
      iconSize: size,
      color: tint,
      // Urefu wa chini unahakikisha eneo la kugusa linatosha kwa kidole cha
      // mtoto (kanuni: [AppSpacing.minTouchTarget] = 48dp).
      constraints: const BoxConstraints(
        minWidth: AppSpacing.minTouchTarget,
        minHeight: AppSpacing.minTouchTarget,
      ),
      padding: EdgeInsets.zero,
      tooltip: tooltip,
      icon: iconAsset != null
          ? AppAssetIcon(
              assetPath: iconAsset!,
              fallbackIcon: icon,
              size: size,
              color: tint,
            )
          : Icon(icon),
    );

    if (badgeCount == null || badgeCount! <= 0) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        button,
        Positioned(
          top: AppSpacing.xs,
          right: AppSpacing.xs,
          child: _Badge(count: badgeCount!),
        ),
      ],
    );
  }
}

/// Doa dogo la namba (mfano arifa 3 ambazo hazijasomwa).
class _Badge extends StatelessWidget {
  const _Badge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    // Zaidi ya 99 tunaonyesha "99+" — nafasi kwenye pembe ni ndogo sana.
    final label = count > 99 ? '99+' : '$count';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 1,
      ),
      constraints: const BoxConstraints(minWidth: 18),
      decoration: BoxDecoration(
        color: context.colorScheme.error,
        borderRadius: AppSpacing.borderRadiusPill,
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colorScheme.onError,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
