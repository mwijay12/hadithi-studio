import 'package:flutter/material.dart';

import '../../../../core/extensions/context_extensions.dart';
import '../../../../l10n/l10n.dart';

/// A small optional comprehension game for Mti wa Babu.
class TreeStoryGame extends StatefulWidget {
  const TreeStoryGame({super.key});

  static Future<void> show(BuildContext context) => showDialog<void>(
        context: context,
        builder: (_) => const TreeStoryGame(),
      );

  @override
  State<TreeStoryGame> createState() => _TreeStoryGameState();
}

class _TreeStoryGameState extends State<TreeStoryGame> {
  bool? _correct;

  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    return AlertDialog(
      title: Text(sw ? 'Cheza na Leo' : 'Play with Leo'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(sw ? 'Babu alimfundisha Neema nini?' : 'What did Grandfather teach Neema?'),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _correct == true ? null : () => setState(() => _correct = false),
              child: Text(sw ? 'Miti hukua mara moja' : 'Trees grow instantly'),
            ),
            OutlinedButton(
              onPressed: _correct == true ? null : () => setState(() => _correct = true),
              child: Text(sw ? 'Vitu vizuri hukua polepole' : 'Good things grow slowly'),
            ),
            if (_correct != null) ...[
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                child: Text(
                  _correct!
                      ? (sw ? 'Hongera! Uvumilivu ni muhimu.' : 'Well done! Patience matters.')
                      : (sw ? 'Jaribu tena. Kumbuka maneno ya Babu.' : 'Try again. Remember Grandfather’s words.'),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.close),
        ),
      ],
    );
  }
}
