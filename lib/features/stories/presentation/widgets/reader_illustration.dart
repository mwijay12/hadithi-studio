import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../domain/entities/story_page.dart';
import 'interactive_hotspot.dart';

/// Shows the complete illustration in the available area. Hotspot coordinates
/// are fractions of the illustration, not of the screen or letterboxing.
class ReaderIllustration extends StatefulWidget {
  const ReaderIllustration({
    super.key,
    required this.asset,
    required this.hotspots,
    required this.onHotspotTapped,
    required this.enabled,
    required this.compact,
    this.canvasMode = false,
    this.safeTop = 0,
    this.safeBottom = 0,
  });

  final String asset;
  final List<StoryHotspot> hotspots;
  final void Function(StoryHotspot hotspot, Rect globalRect) onHotspotTapped;
  final bool enabled;
  final bool compact;
  /// Edge-to-edge reader mode; default retains the standalone contain widget.
  final bool canvasMode;
  final double safeTop;
  final double safeBottom;

  @override
  State<ReaderIllustration> createState() => _ReaderIllustrationState();
}

class _ReaderIllustrationState extends State<ReaderIllustration> {
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Size? _imageSize;
  bool _failed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolve();
  }

  @override
  void didUpdateWidget(ReaderIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _resolve();
  }

  void _resolve() {
    _stream?.removeListener(_listener!);
    _imageSize = null;
    _failed = false;
    _stream = AssetImage(widget.asset).resolve(createLocalImageConfiguration(context));
    _listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
      final Size size = Size(info.image.width.toDouble(), info.image.height.toDouble());
      info.dispose();
      if (mounted) setState(() => _imageSize = size);
    }, onError: (Object error, StackTrace? stack) {
      if (mounted) setState(() => _failed = true);
    });
    _stream!.addListener(_listener!);
  }

  @override
  void dispose() {
    _stream?.removeListener(_listener!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (_failed) return const Center(child: Icon(Icons.image_outlined, size: 48));
      final Size? size = _imageSize;
      if (size == null || constraints.biggest.isEmpty) return const SizedBox.expand();
      final view = constraints.biggest;
      if (!widget.canvasMode) {
        final fitted = applyBoxFit(BoxFit.contain, size, view);
        final rect = Alignment.center.inscribe(fitted.destination, Offset.zero & view);
        return Stack(children: <Widget>[
          Positioned.fromRect(rect: rect, child: Image.asset(widget.asset, fit: BoxFit.fill)),
          for (final hotspot in widget.hotspots) _hotspot(rect, hotspot, view),
        ]);
      }
      final layout = readerCanvasLayout(size, view,
        safeTop: widget.safeTop, safeBottom: widget.safeBottom);
      final rect = layout.imageRect;
      return ClipRect(child: Stack(fit: StackFit.expand, children: <Widget>[
        // The ambient layer is only used where the image cannot fill without
        // an extreme crop; it is ignored for hit testing and accessibility.
        if (layout.ambient)
          IgnorePointer(child: ExcludeSemantics(child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
            child: Transform.scale(scale: 1.15, child: Image.asset(widget.asset, fit: BoxFit.cover)),
          ))),
        if (layout.ambient)
          const IgnorePointer(child: ColoredBox(color: Color(0x480F0C0A))),
        Positioned.fromRect(
          rect: rect,
          child: layout.ambient
              ? _FeatheredArtwork(asset: widget.asset)
              : Image.asset(widget.asset, fit: BoxFit.fill),
        ),
        for (final hotspot in widget.hotspots)
          if (hotspotCenterVisible(rect, hotspot, view)) _hotspot(rect, hotspot, view),
      ]));
    });
  }

  Widget _hotspot(Rect rect, StoryHotspot hotspot, Size view) => Positioned.fromRect(
    rect: widget.canvasMode
        ? canvasHotspotTargetRect(rect, hotspot)
        : hotspotTargetRect(rect, hotspot, view),
    child: Builder(builder: (hotspotContext) => InteractiveHotspot(
      hotspot: hotspot,
      onTapped: (selected) {
        final box = hotspotContext.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final target = box.localToGlobal(Offset.zero) & box.size;
          // The canvas clips targets that straddle an edge. Anchor the bubble
          // to the visible hit area, not to the invisible part outside it.
          final viewport = context.findRenderObject() as RenderBox?;
          if (viewport != null && viewport.hasSize) {
            final visible = viewport.localToGlobal(Offset.zero) & viewport.size;
            final clipped = target.intersect(visible);
            if (!clipped.isEmpty) widget.onHotspotTapped(selected, clipped);
          }
        }
      }, enabled: widget.enabled, compact: widget.compact,
    )),
  );
}

/// The painted image rectangle is also the source of truth for hotspot mapping.
class ReaderCanvasLayout {
  const ReaderCanvasLayout(this.imageRect, this.ambient);
  final Rect imageRect;
  final bool ambient;
}

@visibleForTesting
ReaderCanvasLayout readerCanvasLayout(Size image, Size view, {double safeTop = 0, double safeBottom = 0}) {
  final imgRatio = image.width / image.height;
  final viewRatio = view.width / view.height;
  final sameOrientation = (imgRatio >= 1) == (viewRatio >= 1);
  final ratioDelta = math.max(imgRatio / viewRatio, viewRatio / imgRatio);
  final ambient = !sameOrientation || ratioDelta > 1.8;
  if (!ambient) {
    final scale = math.max(view.width / image.width, view.height / image.height);
    final size = Size(image.width * scale, image.height * scale);
    return ReaderCanvasLayout(const Alignment(0, -0.25).inscribe(size, Offset.zero & view), false);
  }
  final top = safeTop.clamp(0.0, view.height * .45);
  final bottom = safeBottom.clamp(0.0, view.height - top - 1);
  final safe = Rect.fromLTWH(0, top, view.width, view.height - top - bottom);
  final scale = math.min(safe.width / image.width, safe.height / image.height);
  final size = Size(image.width * scale, image.height * scale);
  return ReaderCanvasLayout(Alignment.center.inscribe(size, safe), true);
}

@visibleForTesting
bool hotspotCenterVisible(Rect image, StoryHotspot hotspot, Size view) {
  final center = Offset(image.left + (hotspot.left + hotspot.width / 2) * image.width,
      image.top + (hotspot.top + hotspot.height / 2) * image.height);
  return (Offset.zero & view).contains(center);
}

/// Keep the hit target centered on the artwork even when the image is cropped.
/// The enclosing ClipRect clips a partially visible target rather than moving it.
@visibleForTesting
Rect canvasHotspotTargetRect(Rect image, StoryHotspot hotspot) {
  final center = Offset(image.left + (hotspot.left + hotspot.width / 2) * image.width,
      image.top + (hotspot.top + hotspot.height / 2) * image.height);
  final width = math.max(48.0, hotspot.width * image.width);
  final height = math.max(48.0, hotspot.height * image.height);
  return Rect.fromCenter(center: center, width: width, height: height);
}

/// Only the sharp picture is feathered; hotspot hit targets remain crisp.
class _FeatheredArtwork extends StatelessWidget {
  const _FeatheredArtwork({required this.asset});
  final String asset;
  @override
  Widget build(BuildContext context) {
    const vertical = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: <Color>[Colors.transparent, Colors.white, Colors.white, Colors.transparent],
      stops: <double>[0, .12, .84, 1]);
    const horizontal = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight,
      colors: <Color>[Colors.transparent, Colors.white, Colors.white, Colors.transparent],
      stops: <double>[0, .035, .965, 1]);
    return ShaderMask(shaderCallback: (bounds) => vertical.createShader(bounds), blendMode: BlendMode.dstIn,
      child: ShaderMask(shaderCallback: (bounds) => horizontal.createShader(bounds), blendMode: BlendMode.dstIn,
        child: Image.asset(asset, fit: BoxFit.fill)));
  }
}

/// At least a 48-pixel target when space permits, centered on the illustrated
/// object and clamped to the visible illustration area.
@visibleForTesting
Rect hotspotTargetRect(Rect image, StoryHotspot hotspot, Size available) {
  final center = Offset(
    image.left + (hotspot.left + hotspot.width / 2) * image.width,
    image.top + (hotspot.top + hotspot.height / 2) * image.height,
  );
  final width = (hotspot.width * image.width).clamp(48.0, available.width < 48 ? 48.0 : available.width);
  final height = (hotspot.height * image.height).clamp(48.0, available.height < 48 ? 48.0 : available.height);
  final actualWidth = width.clamp(0.0, available.width);
  final actualHeight = height.clamp(0.0, available.height);
  final left = (center.dx - actualWidth / 2).clamp(0.0, available.width - actualWidth);
  final top = (center.dy - actualHeight / 2).clamp(0.0, available.height - actualHeight);
  return Rect.fromLTWH(left, top, actualWidth, actualHeight);
}
