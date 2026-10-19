/// Kadi ya picha ya hadithi au rafu — kipande kimoja kinachotumika kila mahali.
///
/// Ilianza kama widget ya faragha kwenye `app_shell.dart`, ambapo haikuwa na
/// mguso wowote — ndiyo maana kadi zote zilionekana kama mapambo. Sasa ni ya
/// umma na ina [onTap], kwa hivyo Nyumbani, Maktaba, Rafu Yangu na ukurasa wa
/// rafu zote hutumia widget **ile ile** yenye tabia ile ile. Tofauti moja tu
/// inabaki: rangi na picha.
///
/// ## Kwa nini picha ina scrim nyeusi
///
/// Kichwa cha hadithi ni cheupe. Kwenye picha nyepesi (mfano anga la
/// Kilimanjaro) cheupe hakisomeki. Badala ya kuchagua rangi ya maandishi
/// kulingana na picha — jambo lisilowezekana kwa picha za mtandao —
/// tunaweka safu nyeusi inayozidi kuwa nyeusi kuelekea chini (scrim). Hivyo
/// maandishi yanasomeka juu ya picha **yoyote**.
///
/// ## Uzito
///
/// Kila picha ina `cacheWidth` iliyowekwa kwa upana wa skrini. Bila hiyo,
/// picha ya 1020px inapakiwa kikamilifu kwenye kadi ya 140dp — kumbukumbu
/// inayoharibu simu za 1GB RAM.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';

/// Kadi ya picha yenye kichwa, badge, maendeleo na mguso.
class StoryArtwork extends StatelessWidget {
  /// Huunda kadi.
  const StoryArtwork({
    super.key,
    required this.title,
    required this.asset,
    required this.accent,
    this.height = 120,
    this.badge,
    this.progress,
    this.titleStyle,
    this.onTap,
    this.semanticLabel,
  });

  /// Kichwa cha hadithi au jina la kundi.
  final String title;

  /// Njia ya picha ndani ya `assets/images/`.
  final String asset;

  /// Rangi ya kadi — hutumika kwa badge, kivuli na akiba ya picha.
  final Color accent;

  /// Urefu wa kadi.
  final double height;

  /// Lebo ndogo juu ya kichwa (mfano "Hadithi ya Leo"). Si lazima.
  final String? badge;

  /// Maendeleo ya kusoma: `0.0`–`1.0`. Si lazima.
  final double? progress;

  /// Huwaruhusu wito kubadilisha ukubwa wa kichwa (hero ni kubwa kuliko kadi).
  final TextStyle? titleStyle;

  /// Hutekelezwa kadi inapoguswa. `null` = kadi si kiungo.
  ///
  /// `null` si kosa: kadi ya mapambo (mfano kwenye Wasifu) haipaswi
  /// kuonyesha mwitikio wa mguso ambao hauleti kitu.
  final VoidCallback? onTap;

  /// Maelezo kwa screen reader. Kama hayatolewi, [title] hutumika.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;

    final Widget card = Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.20),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.asset(
            asset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            // Kichwa cha hadithi kinasomwa na screen reader — picha ni
            // mapambo yanayorudia wazo hilo.
            excludeFromSemantics: true,
            // Picha za 1020px zinapakiwa chini kwa upana wa kadi, si kwa
            // ukubwa wao kamili.
            cacheWidth: _cacheWidthFor(context, 140),
            errorBuilder: (_, __, ___) => DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[accent, accent.withValues(alpha: 0.65)],
                ),
              ),
            ),
          ),
          // Scrim: huhakikisha maandishi ni meupe-juu-ya-giza kila wakati.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.72),
                ],
                stops: const <double>[0.40, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (badge != null) ...<Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusPill),
                    ),
                    child: Text(
                      badge!,
                      style: text.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: (titleStyle ?? text.titleSmall)?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (progress != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusPill),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.30),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.sunsetGold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      // `Semantics` ipo hata bila mguso ili screen reader isome kichwa
      // badala ya kukaa kimya kwenye picha.
      return Semantics(
        label: semanticLabel ?? title,
        image: true,
        child: ExcludeSemantics(child: card),
      );
    }

    return Semantics(
      button: true,
      label: semanticLabel ?? title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap!.call();
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: card,
        ),
      ),
    );
  }

  /// Hupunguza ukubwa wa picha inayopakiwa.
  ///
  /// Kwa kadi ndogo (140dp) tunapakia picha kwa ~2x ya density ili
  /// ionekane safi kwenye skrini za retina bila kutumia kumbukumbu ya
  /// picha kamili.
  static int _cacheWidthFor(BuildContext context, double logicalWidth) {
    final double ratio = MediaQuery.of(context).devicePixelRatio;
    return (logicalWidth * ratio).round().clamp(120, 2048);
  }
}
