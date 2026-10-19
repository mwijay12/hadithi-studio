/// WIDGET: hali za kupakia (loading) — zinazotumika kwenye skrini zote.
///
/// **Kwa nini kuna widget tatu tofauti badala ya `CircularProgressIndicator`
/// moja:** simu za Tanzania (Tecno/Itel/Infinix, 2GB RAM) zinaonyesha
/// `CircularProgressIndicator` inayotetemeka wakati GPU inashughulika. Kwa
/// hivyo:
///
/// - [AppShimmerBox] hutumika kwenye maeneo yenye **umuhimu wa kujua umbo**
///   (kadi za hadithi, orodha) — mtumiaji anaona kadi itakuja, si mduara.
/// - [AppLoading] hutumika kwa kazi fupi yenye ujumbe ("Inapakia hadithi…").
/// - [AppLoadingOverlay] huzuia kugusa wakati kazi inaendelea (malipo!).
///
/// **Kwa nini shimmer si `LinearProgressIndicator`:** shimmer haiendi hatua
/// kwa hatua, hivyo haidanganyi mtumiaji kuhusu "asilimia" ambayo hatuijui.
/// Upakuaji wa hadithi unaweza kuisha kwa sekunde 3 au 90.
library;

// `kIsWeb` iko kwenye `foundation`, ambayo `material.dart` haitoi kwa
// jina hili — hivyo tunaileta kwa `show`.
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../config/theme/spacing.dart';
import '../../l10n/l10n.dart';
import '../extensions/context_extensions.dart';

/// Ukubwa wa kiashiria cha kupakia.
enum AppLoadingSize {
  /// Kwenye kitufe au kwenye safu ya orodha.
  small(diameter: 16, strokeWidth: 2),

  /// Kwa kawaida — katikati ya sehemu.
  medium(diameter: 28, strokeWidth: 3),

  /// Ukurasa mzima (mfano splash, kusubiri AI).
  large(diameter: 44, strokeWidth: 4);

  const AppLoadingSize({required this.diameter, required this.strokeWidth});

  final double diameter;
  final double strokeWidth;
}

/// Kiashiria cha kupakia chenye ujumbe wa lugha mbili.
///
/// Maandishi yanatoka kwa `context.localised` badala ya ARB kwa sababu wito
/// huu hutumika kwa ujumbe **wa muda** (mfano "Inatengeneza picha yako…") ambao
/// hubadilika na hatua ya kazi. Kwa maandishi ya kudumu, tumia keys za ARB
/// (`context.l10n.loading` ndiyo ya akiba hapa).
class AppLoading extends StatelessWidget {
  const AppLoading({
    super.key,
    this.messageSw,
    this.messageEn,
    this.size = AppLoadingSize.medium,
    this.color,
  });

  /// Ujumbe kwa Kiswahili. Acha `null` zote mbili kwa mduara pekee.
  final String? messageSw;

  /// Ujumbe kwa Kiingereza.
  final String? messageEn;

  final AppLoadingSize size;

  /// Rangi ya mduara — kwa default `colorScheme.primary`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = context.colorScheme;
    final label = _label(context);

    return Semantics(
      liveRegion: true,
      label: label ?? context.l10n.loading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: size.diameter,
            height: size.diameter,
            child: CircularProgressIndicator(
              strokeWidth: size.strokeWidth,
              color: color ?? scheme.primary,
            ),
          ),
          if (label != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }

  /// Hurudisha `null` kama hakuwa na ujumbe; la sivyo ujumbe kwa lugha ya
  /// sasa. Tukitoa moja tu, lile lolote linatumika kwa lugha zote mbili —
  /// afadhali kuonyesha Kiswahili kwa mtumiaji wa Kiingereza kuliko wazi.
  String? _label(BuildContext context) {
    if (messageSw == null && messageEn == null) return null;
    return context.localised(
      swahili: messageSw ?? messageEn!,
      english: messageEn ?? messageSw!,
    );
  }
}

/// Kizuizi kinachofunika skrini wakati kazi inaendelea.
///
/// **Muhimu kwa malipo:** wakati M-Pesa STK push inaendelea, mtumiaji
/// **hapaswi** kuweza kubonyeza "Lipa" tena. Kinga zipo tatu, na kila moja
/// inashughulikia njia tofauti ya kutoroka:
///
/// 1. `ModalBarrier(dismissible: false)` — inafunika skrini, inameza miguso
///    **yote** inayofika chini yake (haipitishi kwa `child` ulio nyuma kwenye
///    `Stack`), na kwa `dismissible: false` haiwezi kufungwa kwa kubonyeza
///    nje ya kisanduku. Hii ndiyo inayozuia "Lipa" ya pili.
/// 2. `WillPopScope(onWillPop: () async => false)` — inazuia kitufe/gesture ya
///    "nyuma" ya Android kufunga skrini wakati ombi linaenda. Flutter 3.2
///    haina `PopScope` (ililetwa baadaye), kwa hivyo tunatumia `WillPopScope`
///    — kanuni ile ile ya toleo iliyoelezwa kwenye `context_extensions.dart`.
/// 3. `AppButton.isLoading` — kitufe chenyewe kinajizima (`onPressed == null`).
///
/// `BlockSemantics` iliyo ndani ya `ModalBarrier` inazuia screen reader
/// kumpeleka mtumiaji kwenye maudhui ya nyuma wakati malipo yanaendelea.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.messageSw,
    this.messageEn,
  });

  final Widget child;
  final bool isLoading;
  final String? messageSw;
  final String? messageEn;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    return PopScope(
      // Zima "nyuma" ya Android wakati kazi inaendelea — bila hii mtumiaji
      // anaweza kufunga skrini ya malipo kwa kitufe cha nyuma.
      canPop: false,
      child: Stack(
        children: <Widget>[
          child,
          // Skrini nzito inayomeza miguso yote ya chini NA kuzuia kubonyeza nje.
          ModalBarrier(
            dismissible: false,
            color: context.colorScheme.onSurface.withValues(alpha: 0.45),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: AppSpacing.borderRadiusLg,
              ),
              child: AppLoading(
                messageSw: messageSw,
                messageEn: messageEn,
                size: AppLoadingSize.medium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kizuizi kinachong'aa (shimmer) — kinabadilisha maeneo yenye kubeba nafasi.
///
/// `baseColor`/`highlightColor` zinatokana na `onSurface` kwa uwazi mdogo, kwa
/// hivyo shimmer inaonekana vizuri kwenye mandhari ya mchana **na** ya usiku
/// bila kuainisha rangi mbili.
class AppShimmerBox extends StatelessWidget {
  const AppShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.borderRadiusSm,
    this.child,
  });

  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  /// Kama `child` imetolewa, shimmer inafunika `child` badala ya kuwa kizuizi.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final Color base = context.colorScheme.onSurface;

    final Widget placeholder = child ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: base,
            borderRadius: borderRadius,
          ),
        );

    // **Kwa nini tunaacha mng'ao kwenye web.**
    //
    // `shimmer` hutumia `ShaderMask` (`shimmer.dart` → `ShaderMaskLayer`), na
    // `ShaderMask` huhitaji fragment shader. Renderer ya **HTML haiiungi
    // mkono** — kila kizuizi kinapojengwa, Flutter huripoti:
    //
    //     Unsupported operation: FragmentProgram is not supported
    //     for the HTML renderer.
    //
    // Hilo ni kosa halisi lililotokea: lilikamatwa na `AppErrorHandler` na
    // (kwa hitilafu yetu) likaonyesha skrini ya kurejesha kwenye onboarding.
    //
    // Tunarudi kwenye kizuizi **tuli** kwenye web: mtumiaji bado anaona
    // **umbo** la kile kinachokuja (lengo la shimmer), lakini hakuna kosa.
    // Kwenye Android — bidhaa halisi — mng'ao unaendelea kufanya kazi.
    if (kIsWeb) return placeholder;

    return Shimmer.fromColors(
      baseColor: base.withValues(alpha: 0.06),
      highlightColor: base.withValues(alpha: 0.13),
      child: placeholder,
    );
  }
}

/// Kadi ya shimmer yenye umbo la kadi ya hadithi (kifuniko + mistari miwili).
///
/// Kadi hii hutumika kwenye orodha wakati data inapakia. Mtumiaji anaona
/// **umbo** la kile kinachokuja, hivyo skrini haionekani "imevunjika".
class AppShimmerCard extends StatelessWidget {
  const AppShimmerCard({
    super.key,
    this.width,
    this.coverAspectRatio = 3 / 4,
    this.showSubtitle = true,
  });

  final double? width;

  /// Uwiano wa kifuniko — 3/4 inalingana na kadi halisi ya maktaba.
  final double coverAspectRatio;

  final bool showSubtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AspectRatio(
            aspectRatio: coverAspectRatio,
            child: const AppShimmerBox(
              borderRadius: AppSpacing.borderRadiusMd,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppShimmerBox(height: 14, borderRadius: AppSpacing.borderRadiusSm),
          if (showSubtitle) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            const SizedBox(
              width: 96,
              child: AppShimmerBox(
                height: 12,
                borderRadius: AppSpacing.borderRadiusSm,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
