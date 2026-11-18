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
}
