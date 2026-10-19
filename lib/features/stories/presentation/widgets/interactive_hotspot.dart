/// **INTERACTIVE HOTSPOT** — eneo la kugusa kwenye mchoro wa ukurasa.
///
/// Kila `StoryHotspot` ni mstatili mdogo (ratios 0.0–1.0) uliowekwa juu ya
/// mchoro. Mtoto anapougusa, hufichuliwa maandishi kwenye **kibonge cha
/// maongezi** ([HotspotSpeechBubble]).
///
/// ## SOMO: kibonge hakiwi ndani ya kisanduku cha eneo
///
/// Toleo la kwanza liliweka kibonge **ndani** ya `Stack` ya eneo, kikiwa
/// `Positioned(bottom: ..., width: 200–280)`. Flutter haikati `Positioned`,
/// na eneo lililo pembezoni (mfano `left: 0.62, width: 0.24`) lilifanya
/// kibonge kianze ~0.74 × upana wa skrini → **nusu ya kibonge ilitoka nje ya
/// skrini.** Mtumiaji aliripoti hivi: *"zingine zina exceed the app borders"*.
///
/// Suluhisho: eneo **haliunda** kibonge tena. Linaita [onTapped] tu, na
/// **ukurasa wa kusoma** hukiweka kibonge kwenye ngazi ya skrini, kikidhibitiwa
/// (`clamp`) ndani ya mipaka. Hivyo kibonge hakiwezi kutoka nje, hata kama
/// data ya eneo ni mbaya.
///
/// ## Aina zinazoonyesha jibu, na aina zinazoonyesha swali
///
/// Aina **nne** ni za kufichua taarifa: `sound_effect`, `animation`,
/// `info_popup`, `character_speak` — kibonge kinaonyesha maelezo.
///
/// Aina **mbili** zinadokeza **swali au mchezo**: `story_choice` na
/// `mini_game`. Hizi **hazijajengwa**. Toleo la kwanza lilionyesha
/// `reveal` kwa kila kitu — hivyo mtoto alibofya "Uamuzi" (chaguo la
/// hadithi) na **akapata jibu la swali ambalo hakukuwa nalo.** Hilo
/// lilikuwa kosa la uaminifu. Sasa aina hizo mbili zinaonyesha hali ya
/// ukweli badala ya jibu la uongo.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../domain/entities/story_page.dart';

/// Ikoni ya kila [HotspotType].
///
/// Kila aina ina ishara tofauti ili mtoto atambue "hapa kuna mchezo" au
/// "hapa kuna sauti" **bila** kusoma maandishi — wengi wa watumiaji wetu
/// hawajui kusoma vizuri bado.
IconData hotspotIconFor(HotspotType type) {
  switch (type) {
    case HotspotType.character_speak:
      return Icons.record_voice_over_rounded;
    case HotspotType.sound_effect:
      return Icons.graphic_eq_rounded;
    case HotspotType.animation:
      return Icons.auto_awesome_rounded;
    case HotspotType.info_popup:
      return Icons.lightbulb_rounded;
    case HotspotType.mini_game:
      return Icons.videogame_asset_rounded;
    case HotspotType.story_choice:
      return Icons.alt_route_rounded;
  }
}

/// Rangi ya kila [HotspotType], ikitoka kwenye palette ya Tanzania.
Color hotspotColorFor(HotspotType type) {
  switch (type) {
    case HotspotType.character_speak:
      return AppColors.zanzibarTurquoise;
    case HotspotType.sound_effect:
      return AppColors.purpleFun;
    case HotspotType.animation:
      return AppColors.kangaOrange;
    case HotspotType.info_popup:
      return AppColors.safariGreen;
    case HotspotType.mini_game:
      return AppColors.sunsetGold;
    case HotspotType.story_choice:
      return AppColors.spiceRed;
  }
}

/// `true` = aina hii **hajaijengwa** — inaonyesha hali ya ukweli, sivyo
/// "jibu".
///
/// Tazama doc ya faili hili: kutoa `reveal` kwa aina hizi ni kumpa mtoto
/// jibu la swali ambalo hakukuwa nalo.
bool hotspotTypeIsUnbuilt(HotspotType type) =>
    type == HotspotType.mini_game || type == HotspotType.story_choice;

/// Eneo la kugusa kwenye mchoro wa ukurasa.
///
/// **Haliundi kibonge.** Hutangaza mguso pekee, na mzazi
/// (`StoryReaderPage`) huamua wapi na vipi kukiweka.
class InteractiveHotspot extends StatefulWidget {
  /// Huunda eneo la kugusa.
  const InteractiveHotspot({
    super.key,
    required this.hotspot,
    this.onTapped,
    this.enabled = true,
    this.compact = false,
  });

  /// Eneo lenyewe — ikiwa na ratios na maandishi ya kufichua.
  final StoryHotspot hotspot;

  /// Huitwa eneo linapoguswa, likipeleka **eneo lenyewe**.
  ///
  /// Hupeleka `StoryHotspot` (sivyo `void`) kwa sababu mzazi anahitaji
  /// `left`/`top`/`width`/`height` ili kuweka kibonge **ndani ya skrini**.
  final ValueChanged<StoryHotspot>? onTapped;

  /// `false` = eneo halikubali mguso (mfano wakati mipangilio imefunguliwa).
  final bool enabled;

  /// `true` = ikoni ndogo (skrini ndogo / maeneo madogo).
  final bool compact;

  @override
  State<InteractiveHotspot> createState() => _InteractiveHotspotState();
}

class _InteractiveHotspotState extends State<InteractiveHotspot>
    with SingleTickerProviderStateMixin {
  /// Hupigisha mpwito bila mwisho — ishara ya "gusa hapa".
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: AppSpacing.hotspotPulse,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  /// Mguso wa eneo: sisimua, kisha mjulishe mzazi.
  void _handleTap() {
    if (!widget.enabled) return;
    // Mtetemo mfupi — mtoto ahisi kuwa kitu kimetokea, hata kama sauti
    // haipatikani kwenye kifaa hiki.
    unawaited(HapticFeedback.lightImpact());
    widget.onTapped?.call(widget.hotspot);
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = hotspotColorFor(widget.hotspot.type);
    const Color nightInk = AppColors.darkText;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double size = constraints.biggest.shortestSide;
        // **Kosa la awali:** `Container` ya duara haikuwa na upana/urefu,
        // kwa hivyo ilijaa kisanduku CHOTE cha eneo. Eneo la 0.26 × 0.20 la
        // skrini likawa duara la pikseli 160 — kubwa kuliko kichwa cha mchoro.
        final double buttonSize = (size * 0.52).clamp(40.0, 64.0);
        final double iconSize = buttonSize * 0.46;

        return Semantics(
          button: true,
          label: widget.hotspot.label(swahili: context.isSwahili),
          child: GestureDetector(
            onTap: _handleTap,
            behavior: HitTestBehavior.opaque,
            child: AnimatedBuilder(
              animation: _pulse,
              builder: (BuildContext context, Widget? child) {
                // Mpwito: duara la nje linakua na kufifia.
                final double t = _pulse.value;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Transform.scale(
                      scale: 0.85 + (t * 0.35),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withOpacity(0.18 + (t * 0.22)),
                        ),
                      ),
                    ),
                    child!,
                  ],
                );
              },
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withOpacity(0.92),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                    width: 2,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.30),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    hotspotIconFor(widget.hotspot.type),
                    size: iconSize,
                    color: nightInk,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Kibonge cha maongezi kinachojificha chenyewe.
///
/// Kinaonyesha jina la aina (kutoka [HotspotType], kwa lugha ya sasa) na
/// maandishi ya kufichua ([StoryHotspot.reveal]). Kina mstari mwembamba
/// unaopungua ili mtoto aone **muda uliobaki** kabla ya kujificha.
///
/// **Huwekwa na mzazi** (ukurasa wa kusoma), ndani ya skrini — si ndani ya
/// kisanduku cha eneo. Tazama doc ya faili hili.
class HotspotSpeechBubble extends StatefulWidget {
  /// Huunda kibonge.
  const HotspotSpeechBubble({
    super.key,
    required this.hotspot,
    required this.onDismissed,
  });

  /// Eneo linalohusika.
  final StoryHotspot hotspot;

  /// Huitwa kibonge kinapojificha (muda umeisha au mtumiaji amegusa).
  final VoidCallback onDismissed;

  @override
  State<HotspotSpeechBubble> createState() => _HotspotSpeechBubbleState();
}

class _HotspotSpeechBubbleState extends State<HotspotSpeechBubble>
    with SingleTickerProviderStateMixin {
  /// Huendesha mstari wa muda uliobaki.
  late final AnimationController _life = AnimationController(
    vsync: this,
    duration: AppSpacing.speechBubble,
  );

  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _life.forward();
    // Kujificha chenyewe ni sharti la UX: mtoto mdogo hawezi kutafuta kitufe
    // cha "Funga" — na mzazi asilazimike kufunga maneno ya ziada kila mara.
    _autoDismiss = Timer(AppSpacing.speechBubble, _dismiss);
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _life.dispose();
    super.dispose();
  }

  /// Hufunga kibonge na kumjulisha mzazi.
  void _dismiss() {
    _autoDismiss?.cancel();
    if (mounted) widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final bool swahili = context.isSwahili;
    final Color accent = hotspotColorFor(widget.hotspot.type);
    final bool night = Theme.of(context).brightness == Brightness.dark;
    final bool unbuilt = hotspotTypeIsUnbuilt(widget.hotspot.type);

    // **Aina zisizojengwa zinaonyesha ukweli.** Tazama doc ya faili hili:
    // kutoa `reveal` hapa ni kumpa mtoto jibu la swali ambalo hakukuwa nalo.
    final String body = unbuilt
        ? (swahili
            ? 'Hii inakuja hivi punde — bado tunaijenga.'
            : 'This is coming soon — still being built.')
        : widget.hotspot.reveal(swahili: swahili);

    return Semantics(
      liveRegion: true,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: _dismiss,
          behavior: HitTestBehavior.opaque,
          child: Container(
            decoration: BoxDecoration(
              color: night ? AppColors.readerNightSurface : Colors.white,
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: accent, width: 2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // Kichwa: aina (kutoka enum) + ikoni yake.
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.xs,
                  ),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        hotspotIconFor(widget.hotspot.type),
                        size: AppSpacing.iconSm,
                        color: accent,
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Expanded(
                        child: Text(
                          // `HotspotType` haina `label(...)` — ina
                          // `labelSw` / `labelEn` (kama ilivyoandikwa kwenye
                          // doc ya enum yenyewe).
                          swahili
                              ? widget.hotspot.type.labelSw
                              : widget.hotspot.type.labelEn,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Mwili: jina la eneo, kisha maelezo (au ukweli).
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // **Swali kwanza.** Kibonge hiki hujibu swali la
                      // mtoto, hivyo swali lenyewe lazima lionekane kwa
                      // ukubwa unaoshindana na jibu. Awali lilikuwa 14 px
                      // (sawa na jibu) — jibu lilionekana kama tamko la
                      // ghafla bila muktadha.
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Icon(
                            Icons.help_rounded,
                            size: 16,
                            color: accent,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.hotspot.label(swahili: swahili),
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.25,
                                fontWeight: FontWeight.w800,
                                color: night
                                    ? AppColors.readerNightText
                                    : AppColors.darkText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: night
                              ? AppColors.readerNightPastText
                              : AppColors.bodyText,
                        ),
                      ),
                    ],
                  ),
                ),
                // Mstari wa muda uliobaki — hupungua hadi kujificha.
                AnimatedBuilder(
                  animation: _life,
                  builder: (BuildContext context, Widget? _) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(AppSpacing.radiusSm),
                      ),
                      child: LinearProgressIndicator(
                        value: 1.0 - _life.value,
                        minHeight: 3,
                        backgroundColor: accent.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
