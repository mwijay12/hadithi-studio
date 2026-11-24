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
/// **pose** na kuongeza mwendo mdogo wa mwili mzima. **HAIFANYI**: kupepesa
/// macho, kupunga mkono kwa joint, kupumua halisi, wala lip-sync. Hizo zinahitaji
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
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    // Slow whole-body motion; this is not a separately rigged gesture.
    duration: const Duration(milliseconds: 2400),
  );

  /// Subtle grounded sway and scale, anchored at the feet. This moves the
  /// whole image; real blinking and hand animation require aligned layers.
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
    } else if (TickerMode.of(context) && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!TickerMode.of(context)) {
      _controller.stop();
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
    if (oldWidget.reduceMotion != widget.reduceMotion) _syncMotion();
  }

  @override
  void dispose() {
    _controller.dispose();
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
      child: image,
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
