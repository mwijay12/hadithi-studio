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
  final ValueChanged<StoryHotspot> onHotspotTapped;
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
          Positioned(
            left: rect.left + hotspot.left * rect.width,
            top: rect.top + hotspot.top * rect.height,
            width: hotspot.width * rect.width,
            height: hotspot.height * rect.height,
            child: InteractiveHotspot(
              hotspot: hotspot,
              onTapped: widget.onHotspotTapped,
              enabled: widget.enabled,
              compact: widget.compact,
            ),
          ),
      ]);
    });
  }
}
