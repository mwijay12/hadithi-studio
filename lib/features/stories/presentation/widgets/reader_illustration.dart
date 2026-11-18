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
  });

  final String asset;
  final List<StoryHotspot> hotspots;
  final void Function(StoryHotspot hotspot, Rect globalRect) onHotspotTapped;
  final bool enabled;
  final bool compact;

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
      final FittedSizes fitted = applyBoxFit(BoxFit.contain, size, constraints.biggest);
      final Rect rect = Alignment.center.inscribe(fitted.destination, Offset.zero & constraints.biggest);
      return Stack(children: <Widget>[
        Positioned.fromRect(
          rect: rect,
          child: Image.asset(widget.asset, fit: BoxFit.fill),
        ),
        for (final hotspot in widget.hotspots)
          Positioned.fromRect(
            rect: hotspotTargetRect(rect, hotspot, constraints.biggest),
            child: Builder(builder: (hotspotContext) {
              return InteractiveHotspot(
                hotspot: hotspot,
                onTapped: (selected) {
                  final box = hotspotContext.findRenderObject() as RenderBox?;
                  if (box != null && box.hasSize) {
                    widget.onHotspotTapped(selected, box.localToGlobal(Offset.zero) & box.size);
                  }
                },
                enabled: widget.enabled,
                compact: widget.compact,
              );
            }),
          ),
      ]);
    });
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
