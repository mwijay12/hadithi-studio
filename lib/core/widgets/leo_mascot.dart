/// **LEO** — mascot wa Hadithi Studio (simba mdogo).
///
/// ## Poses
///
/// Five complete, transparent storybook poses of Leo, with space around his
/// ears, paws and tail. `BoxFit.contain` keeps the artwork intact.
///
/// ## Hii ni nini — na nini HAIYO
///
/// Hii ni **daraja la uaminifu** kuelekea Rive rig halisi. Inabadilisha
/// **pose** na kuongeza mwendo mdogo wa mwili mzima. Pose ya wave pia
/// ina blink ya frame iliyolinganishwa. **HAIFANYI** kupunga mkono kwa joint,
/// kupumua halisi, wala lip-sync. Hizo zinahitaji
/// layered rig ndani ya Rive Editor na faili `.riv` ambayo **haipo**.
///
/// Hivyo hatuandiki `RiveAnimation.asset(...)` hapa — faili haipo, na
/// kuandika msimbo wa faili isiyopo ni udanganyifu.
///
/// ## Kuheshimu "reduced motion" — maboresho juu ya prototype
///
/// Prototype ilikuwa na switch ya mkono (`reduceMotion`). Tumeongeza
/// **upendeleo wa mfumo**: `MediaQuery.disableAnimations` (yaani
/// "Remove animations" kwenye Android, "Reduce motion" kwenye iOS/web).
/// Mtumiaji anayeweka hilo **hataona mwendo** hata kama app haikuuliza.
/// Hii ni sehemu ya ufikivu (WCAG 2.3.3) na ni muhimu kwa watoto
/// wanaosikia vizuri lakini wanaathiriwa na mwendo.
library;

import 'package:flutter/material.dart';

import '../extensions/context_extensions.dart';

/// Hali (pose) za Leo.
///
/// Majina yanafuata state zilizopendekezwa kwa `LeoStateMachine` ya Rive,
/// ili siku ya rig halisi tuunganishe **bila kubadilisha majina**.
enum LeoPose {
  /// Salamu — mkono juu. Splash, onboarding.
  wave,

  /// Anasoma kitabu. Ukurasa wa hadithi.
  reading,

  /// Anasikiliza. TTS inapocheza.
  listening,

  /// Furaha — mikono juu. Kumaliza hadithi.
  celebrate,

  /// Udadisi — kichwa kimeinama. Kosa, hali tupu, swali.
  curious,
}

/// Huonyesha Leo kwenye [pose] iliyochaguliwa.
class LeoMascot extends StatefulWidget {
  /// Huunda Leo.
  const LeoMascot({
    super.key,
    required this.pose,
    this.height = 200,
    this.reduceMotion = false,
    this.semanticLabel,
  });

  /// Pose ya kuonyesha.
  final LeoPose pose;

  /// Urefu wa picha (upana hufuata uwiano).
  final double height;

  /// `true` = hakuna mwendo (huongezwa kwa upendeleo wa mfumo).
  final bool reduceMotion;

  /// Maelezo kwa screen reader. Kama ni `null`, hutumia ya lugha mbili.
  final String? semanticLabel;

  @override
  State<LeoMascot> createState() => _LeoMascotState();
}

class _LeoMascotState extends State<LeoMascot>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    // Slow whole-body motion; this is not a separately rigged gesture.
    duration: const Duration(milliseconds: 2400),
  );

  // A separate, slow cycle leaves the eyes open for most of the time.
  late final AnimationController _blink = AnimationController(
    vsync: this, duration: const Duration(seconds: 5),
  );

  /// Subtle grounded sway and scale, anchored at the feet.
  late final Animation<double> _motion = CurvedAnimation(
    parent: _controller, curve: Curves.easeInOutSine,
  );

  /// `true` = tusifanye mwendo kabisa.
  bool _shouldStill(BuildContext context) =>
      widget.reduceMotion || MediaQuery.of(context).disableAnimations;

  String get _asset => switch (widget.pose) {
        LeoPose.wave => 'assets/images/mascot/leo_wave.webp',
        LeoPose.reading => 'assets/images/mascot/leo_reading.webp',
        LeoPose.listening => 'assets/images/mascot/leo_listening.webp',
        LeoPose.celebrate => 'assets/images/mascot/leo_happy.webp',
        LeoPose.curious => 'assets/images/mascot/leo_curious.webp',
      };

  // Listen to system accessibility changes as well as the widget override.
  // Avoid running a ticker when motion is disabled.
  void _syncMotion() {
    if (_shouldStill(context)) {
      _controller.stop();
      _controller.value = 0;
      _blink.stop();
      _blink.value = 0;
    } else if (TickerMode.of(context) && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!TickerMode.of(context)) {
      _controller.stop();
      _blink.stop();
    }
    if (!_shouldStill(context) && TickerMode.of(context)) {
      if (widget.pose == LeoPose.wave) {
        if (!_blink.isAnimating) _blink.repeat();
      } else {
        _blink.stop();
        _blink.value = 0;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant LeoMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reduceMotion != widget.reduceMotion ||
        oldWidget.pose != widget.pose) _syncMotion();
  }

  @override
  void dispose() {
    _controller.dispose();
    _blink.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      _asset,
      height: widget.height,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      // Kwa nini `excludeFromSemantics`: tunatoa maelezo **mazuri** kwa
      // screen reader badala ya jina la faili. Picha yenyewe hailazi kitu
      // cha maana ikiwa peke yake.
      excludeFromSemantics: true,
      // Akiba kama faili haipo — skrini isivunjike.
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) {
        return SizedBox(
          height: widget.height,
          child: const Center(
            child: Icon(
              Icons.pets_rounded,
              size: 56,
              color: Color(0xFFF39C12),
            ),
          ),
        );
      },
    );

    // The blink frame is aligned to the original canvas and only changes the
    // eyes. Keep a static image for reduced motion and all other poses.
    final Widget face = widget.pose == LeoPose.wave &&
            !_shouldStill(context) &&
            TickerMode.of(context)
        ? Stack(
            alignment: Alignment.center,
            children: [
              image,
              AnimatedBuilder(
                animation: _blink,
                child: Image.asset(
                  'assets/images/mascot/leo_wave_blink.png',
                  height: widget.height,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  excludeFromSemantics: true,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                builder: (context, child) {
                  // Close for 70 ms, hold 70 ms, reopen for 90 ms.
                  final ms = _blink.value * 5000;
                  final double opacity = ms < 4000 || ms >= 4230
                      ? 0
                      : ms < 4070
                          ? (ms - 4000) / 70
                          : ms < 4140
                              ? 1
                              : (4230 - ms) / 90;
                  return Opacity(
                    key: const ValueKey('leo-blink-frame'),
                    opacity: opacity.clamp(0.0, 1.0),
                    child: child,
                  );
                },
              ),
            ],
          )
        : image;

    // Maelezo kwa lugha iliyochaguliwa sasa. Tunatumia `context.isSwahili`
    // moja kwa moja badala ya helper — hii ni maandishi mawili pekee, na
    // `isSwahili` ni ya uhakika.
    final String label = widget.semanticLabel ??
        (context.isSwahili
            ? 'Leo, simba rafiki wa Hadithi Studio'
            : 'Leo, the Hadithi Studio lion friend');

    final Widget wrapped = Semantics(
      label: label,
      image: true,
      child: face,
    );

    // Upendeleo wa mfumo au switch ya mkono → picha tuli.
    if (_shouldStill(context)) return wrapped;

    return AnimatedBuilder(
      animation: _controller,
      child: wrapped,
      builder: (BuildContext context, Widget? child) => Transform.rotate(
        alignment: Alignment.bottomCenter,
        angle: -0.008 + 0.016 * _motion.value,
        child: Transform.scale(
          alignment: Alignment.bottomCenter,
          scale: 0.992 + 0.008 * _motion.value,
          child: child,
        ),
      ),
    );
  }
}
