import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/enums/app_enums.dart';
import 'package:hadithi_studio/l10n/l10n.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story_page.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/interactive_hotspot.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/reader_illustration.dart';

void main() {
  testWidgets('landscape illustration and hotspot fit inside a portrait area', (tester) async {
    const hotspot = StoryHotspot(
      type: HotspotType.info_popup,
      labelSw: 'Jaribio', labelEn: 'Test',
      revealSw: 'Habari', revealEn: 'Hello',
      left: 0.5, top: 0.25, width: 0.25, height: 0.5,
    );
    Rect? tappedRect;
    StoryHotspot? tappedHotspot;
    await tester.pumpWidget(MaterialApp(localizationsDelegates: AppLocalizationsSetup.localizationsDelegates, supportedLocales: AppLocalizationsSetup.supportedLocales, home: Scaffold(body: Center(
      child: SizedBox(width: 300, height: 500, child: ReaderIllustration(
        asset: 'assets/images/stories/pages/kuku-na-mwewe/page_01.webp',
        hotspots: const [hotspot], onHotspotTapped: (hotspot, rect) { tappedHotspot = hotspot; tappedRect = rect; }, enabled: true, compact: false,
      )),
    ))));
    await tester.runAsync(() async {
      await precacheImage(const AssetImage('assets/images/stories/pages/kuku-na-mwewe/page_01.webp'), tester.element(find.byType(ReaderIllustration)));
    });
    await tester.pump();
    final image = tester.getRect(find.descendant(of: find.byType(ReaderIllustration), matching: find.byType(Image)));
    final marker = tester.getRect(find.byType(InteractiveHotspot));
    expect(image.width, closeTo(300, 0.1));
    expect(image.height, lessThan(500));
    expect(marker.left, closeTo(image.left + image.width * .5, .1));
    expect(marker.top, closeTo(image.top + image.height * .25, .1));
    expect(marker.width, closeTo(image.width * .25, .1));
    await tester.tap(find.byType(InteractiveHotspot));
    expect(tappedHotspot, hotspot);
    expect(tappedRect, marker);
  });
  test('small hotspot targets stay tappable and inside bounds', () {
    const hotspot = StoryHotspot(
      type: HotspotType.info_popup,
      labelSw: 'A', labelEn: 'A', revealSw: 'B', revealEn: 'B',
      left: 0.98, top: 0.98, width: 0.02, height: 0.02,
    );
    final target = hotspotTargetRect(const Rect.fromLTWH(50, 25, 200, 100), hotspot, const Size(300, 150));
    expect(target.width, 48);
    expect(target.height, 48);
    expect(target.right, lessThanOrEqualTo(300));
    expect(target.bottom, lessThanOrEqualTo(150));
    final tiny = hotspotTargetRect(const Rect.fromLTWH(0, 0, 20, 10), hotspot, const Size(20, 10));
    expect(tiny, const Rect.fromLTWH(0, 0, 20, 10));
  });
  test('adaptive geometry maps hotspots through cover or contain at multiple viewports', () {
    const hotspot = StoryHotspot(
      type: HotspotType.info_popup,
      labelSw: 'A', labelEn: 'A', revealSw: 'B', revealEn: 'B',
      left: .4, top: .25, width: .2, height: .2,
    );
    for (final view in <Size>[
      const Size(375, 667), const Size(412, 915),
      const Size(820, 1180), const Size(1180, 820),
    ]) {
      for (final image in <Size>[const Size(1536, 2048), const Size(1376, 768)]) {
        final layout = readerCanvasLayout(image, view, safeTop: 80, safeBottom: view.height * .42);
        final rect = layout.imageRect;
        expect(rect.width / rect.height, closeTo(image.width / image.height, .0001));
        final target = canvasHotspotTargetRect(rect, hotspot);
        expect(target.center.dx, closeTo(rect.left + rect.width * .5, .001));
        expect(target.center.dy, closeTo(rect.top + rect.height * .35, .001));
        if (layout.ambient) {
          expect(rect.left, greaterThanOrEqualTo(-.001));
          expect(rect.right, lessThanOrEqualTo(view.width + .001));
          expect(rect.top, greaterThanOrEqualTo(79.999));
        } else {
          expect(rect.left, lessThanOrEqualTo(0));
          expect(rect.top, lessThanOrEqualTo(0));
          expect(rect.right, greaterThanOrEqualTo(view.width));
          expect(rect.bottom, greaterThanOrEqualTo(view.height));
        }
      }
    }
  });

  testWidgets('mismatched artwork uses feathered ambient with aligned hotspots', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const asset = 'assets/images/stories/pages/kuku-na-mwewe/page_01.webp';
    const hotspot = StoryHotspot(type: HotspotType.info_popup, labelSw: 'A', labelEn: 'A',
      revealSw: 'B', revealEn: 'B', left: .4, top: .2, width: .2, height: .2);
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      home: Scaffold(body: Center(child: SizedBox(width: 375, height: 667,
        child: ReaderIllustration(asset: asset, hotspots: const [hotspot],
          onHotspotTapped: (_, __) {}, enabled: true, compact: false,
          canvasMode: true, safeTop: 80, safeBottom: 280)))),
    ));
    await tester.runAsync(() => precacheImage(const AssetImage(asset), tester.element(find.byType(ReaderIllustration))));
    await tester.pump();
    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(find.byType(ShaderMask), findsNWidgets(2));
    final marker = tester.getRect(find.byType(InteractiveHotspot));
    final frame = tester.getRect(find.byType(ReaderIllustration));
    final layout = readerCanvasLayout(const Size(1536, 1024), const Size(375, 667), safeTop: 80, safeBottom: 280);
    expect(marker.center.dx, closeTo(frame.left + layout.imageRect.left + layout.imageRect.width * .5, 1));
    expect(marker.center.dy, closeTo(frame.top + layout.imageRect.top + layout.imageRect.height * .3, 1));
  });
  testWidgets('edge hotspot passes only its visible area as bubble anchor', (tester) async {
    tester.view.physicalSize = const Size(375, 667);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const asset = 'assets/images/stories/pages/kuku-na-mwewe/page_01.webp';
    const hotspot = StoryHotspot(type: HotspotType.info_popup, labelSw: 'A', labelEn: 'A',
      revealSw: 'B', revealEn: 'B', left: 0, top: .4, width: .01, height: .1);
    Rect? anchor;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      home: Scaffold(body: SizedBox.expand(child: ReaderIllustration(
        asset: asset, hotspots: const [hotspot], enabled: true, compact: false,
        canvasMode: true, safeTop: 80, safeBottom: 280,
        onHotspotTapped: (_, rect) => anchor = rect,
      ))),
    ));
    await tester.runAsync(() => precacheImage(const AssetImage(asset), tester.element(find.byType(ReaderIllustration))));
    await tester.pump();
    final target = tester.getRect(find.byType(InteractiveHotspot));
    final viewport = tester.getRect(find.byType(ReaderIllustration));
    expect(target.left, lessThan(viewport.left));
    await tester.tapAt(Offset(viewport.left + 4, target.center.dy));
    expect(anchor, target.intersect(viewport));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('hotspot pulse respects motion, inactive pages and ticker mode', (tester) async {
    const hotspot = StoryHotspot(type: HotspotType.info_popup, labelSw: 'A', labelEn: 'A',
      revealSw: 'B', revealEn: 'B', left: .4, top: .4, width: .2, height: .2);
    var taps = 0;
    Widget app({bool reduced = false, bool enabled = true, bool ticker = true}) => MaterialApp(
      localizationsDelegates: AppLocalizationsSetup.localizationsDelegates,
      supportedLocales: AppLocalizationsSetup.supportedLocales,
      home: MediaQuery(data: MediaQueryData(disableAnimations: reduced),
        child: TickerMode(enabled: ticker, child: Scaffold(body: Center(
          child: SizedBox(width: 60, height: 60, child: InteractiveHotspot(
            hotspot: hotspot, enabled: enabled, onTapped: (_) => taps++,
          )),
        ))),
      ),
    );
    final pulse = find.byKey(const ValueKey('hotspot-pulse'));
    double scale() => tester.widget<Transform>(pulse).transform.storage[0];
    await tester.pumpWidget(app());
    final initial = scale();
    await tester.pump(const Duration(milliseconds: 500));
    expect(scale(), isNot(initial));
    await tester.pumpWidget(app(reduced: true));
    final stopped = scale();
    await tester.pump(const Duration(seconds: 2));
    expect(scale(), stopped);
    await tester.pumpWidget(app(enabled: false));
    await tester.tap(find.byType(InteractiveHotspot));
    expect(taps, 0);
    await tester.pumpWidget(app(ticker: false));
    final tickerStopped = scale();
    await tester.pump(const Duration(seconds: 2));
    expect(scale(), tickerStopped);
    await tester.pumpWidget(app());
    await tester.tap(find.byType(InteractiveHotspot));
    expect(taps, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
