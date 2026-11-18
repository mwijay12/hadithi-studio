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
}
