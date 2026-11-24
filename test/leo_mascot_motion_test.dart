import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/widgets/leo_mascot.dart';

void main() {
  testWidgets('Leo follows system reduced motion changes', (tester) async {
    Widget app(bool reduceMotion) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduceMotion),
            child: const Scaffold(
              body: LeoMascot(
                pose: LeoPose.reading,
                semanticLabel: 'Leo',
              ),
            ),
          ),
        );

    final animation = find.descendant(
      of: find.byType(LeoMascot), matching: find.byType(AnimatedBuilder),
    );
    await tester.pumpWidget(app(true));
    expect(animation, findsNothing);
    await tester.pumpWidget(app(false));
    expect(animation, findsOneWidget);
    await tester.pumpWidget(app(true));
    expect(animation, findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets('gentle whole-body motion stops when tickers are disabled', (tester) async {
    Widget app(bool enabled) => MaterialApp(
      home: TickerMode(enabled: enabled, child: const Scaffold(
        body: LeoMascot(pose: LeoPose.wave, semanticLabel: 'Leo'),
      )),
    );
    final transforms = find.descendant(of: find.byType(LeoMascot), matching: find.byType(Transform));
    await tester.pumpWidget(app(true));
    final start = tester.widget<Transform>(transforms.first).transform.storage.toList();
    await tester.pump(const Duration(milliseconds: 800));
    final moved = tester.widget<Transform>(transforms.first).transform.storage.toList();
    expect(moved, isNot(equals(start)));
    await tester.pumpWidget(app(false));
    final stopped = tester.widget<Transform>(transforms.first).transform.storage.toList();
    await tester.pump(const Duration(seconds: 3));
    expect(tester.widget<Transform>(transforms.first).transform.storage.toList(), equals(stopped));
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('wave pose blinks briefly and respects motion settings', (tester) async {
    Widget app({bool reduced = false, bool ticker = true, LeoPose pose = LeoPose.wave}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduced),
        child: TickerMode(enabled: ticker, child: Scaffold(
          body: LeoMascot(pose: pose, semanticLabel: 'Leo'),
        )),
      ),
    );
    final blink = find.byKey(const ValueKey('leo-blink-frame'));
    await tester.pumpWidget(app());
    expect(tester.widget<Opacity>(blink).opacity, 0);
    await tester.pump(const Duration(milliseconds: 4100));
    expect(tester.widget<Opacity>(blink).opacity, 1);
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.widget<Opacity>(blink).opacity, 0);
    await tester.pumpWidget(app(reduced: true));
    expect(blink, findsNothing);
    await tester.pumpWidget(app(ticker: false));
    expect(blink, findsNothing);
    await tester.pumpWidget(app(pose: LeoPose.reading));
    expect(blink, findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
