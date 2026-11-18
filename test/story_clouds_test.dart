import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/widgets/story_clouds.dart';

void main() {
  testWidgets('clouds animate gently and stop for reduced motion', (tester) async {
    Widget app(bool reduced) => MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: const Scaffold(body: SizedBox(height: 120, child: StoryClouds())),
          ),
        );
    Finder cloudTransform() => find.byKey(const ValueKey('cloud-drift'));
    await tester.pumpWidget(app(false));
    await tester.pump(const Duration(seconds: 1));
    final before = tester.widget<Transform>(cloudTransform()).transform.getTranslation().x;
    await tester.pump(const Duration(seconds: 1));
    final after = tester.widget<Transform>(cloudTransform()).transform.getTranslation().x;
    expect(after, greaterThan(before));
    await tester.pumpWidget(app(true));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<Transform>(cloudTransform()).transform.getTranslation().x, 0);
    await tester.pumpWidget(const SizedBox());
  });
}
