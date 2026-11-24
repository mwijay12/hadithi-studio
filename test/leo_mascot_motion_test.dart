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
}
