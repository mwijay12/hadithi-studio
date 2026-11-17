import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/tree_story_game.dart';
import 'package:hadithi_studio/l10n/l10n.dart';

void main() {
  testWidgets('wrong answer can be retried and correct answer is celebrated', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('sw'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: TreeStoryGame()),
    ));
    await tester.tap(find.text('Miti hukua mara moja'));
    await tester.pump();
    expect(find.text('Jaribu tena. Kumbuka maneno ya Babu.'), findsOneWidget);
    await tester.tap(find.text('Vitu vizuri hukua polepole'));
    await tester.pump();
    expect(find.text('Hongera! Uvumilivu ni muhimu.'), findsOneWidget);
  });
  testWidgets('game has English text', (tester) async {
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: TreeStoryGame()),
    ));
    expect(find.text('What did Grandfather teach Neema?'), findsOneWidget);
    await tester.tap(find.text('Good things grow slowly'));
    await tester.pump();
    expect(find.text('Well done! Patience matters.'), findsOneWidget);
  });
}
