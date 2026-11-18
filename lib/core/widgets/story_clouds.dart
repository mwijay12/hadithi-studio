/// Gentle decorative SVG clouds for the home header.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StoryClouds extends StatefulWidget {
  const StoryClouds({super.key});

  @override
  State<StoryClouds> createState() => _StoryCloudsState();
}

class _StoryCloudsState extends State<StoryClouds>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = 0;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ClipRect(
          child: Align(
            alignment: Alignment.centerRight,
            child: AnimatedBuilder(
              animation: _controller,
              child: Opacity(
                opacity: 0.13,
                child: SvgPicture.asset(
                  'assets/images/decorations/clouds.svg',
                  width: 190,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
              builder: (context, child) => Transform.translate(
                key: const ValueKey('cloud-drift'),
                offset: Offset(_controller.value * 8, 0),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
