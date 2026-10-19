/// Kila ukurasa wa hadithi za kuanzia una **picha yake halisi**?
///
/// ## Kwa nini jaribio hili lipo
///
/// Awali kurasa 33 zote zilikuwa zikichukua picha moja ya branding
/// (`hero_home.png`, `cat_safari.png`…). Mtoto alikuwa akisoma ukurasa
/// kuhusu pango wakati pichani kuna jua — picha haikuwa na uhusiano wowote
/// na maandishi.
///
/// Sasa kila ukurasa wa hadithi tatu za kuanzia una mchoro wake. Hatari
/// mpya ni **njia isiyo sahihi**: `Image.asset` yenye faili isiyopo
/// haiangushi app — inaonyesha ikoni ya `image_outlined` kimya kimya.
/// Yaani kosa lingeonekana tu kwa macho, kwenye simu.
///
/// Jaribio hili huthibitisha mambo matatu kwa kila ukurasa:
/// 1. faili **ipo** kwenye diski;
/// 2. ina ukubwa wa maana (> 20 KB) — sio faili tupu;
/// 3. ni `.webp` — sio PNG ya MB 6 ambayo ingefanya app isipakuliwe
///    kwenye simu ya Tanzania.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story.dart';

/// Hadithi zenye michoro ya kila ukurasa.
const List<String> _illustratedStories = <String>[
  'safari-ya-simba',
  'mlima-kilimanjaro',
  'nyota-za-usiku',
];

void main() {
  group('Michoro ya kurasa', () {
    test('hadithi tatu za kuanzia zina ukurasa wa kila mchoro', () {
      for (final String id in _illustratedStories) {
        final Story story = StorySampleData.all.firstWhere(
          (Story s) => s.id == id,
          orElse: () => throw StateError('Hadithi "$id" haipo'),
        );

        expect(story.pages, isNotEmpty, reason: '$id haina kurasa');

        for (int i = 0; i < story.pages.length; i++) {
          final String path = story.pages[i].illustration;
          final String expected =
              'assets/images/stories/pages/$id/page_${(i + 1).toString().padLeft(2, '0')}.webp';

          expect(
            path,
            expected,
            reason: 'Ukurasa ${i + 1} wa $id haujaelekeza kwenye mchoro wake',
          );

          final File file = File(path);
          expect(
            file.existsSync(),
            isTrue,
            reason: 'Faili haipo: $path',
          );

          final int bytes = file.lengthSync();
          expect(
            bytes,
            greaterThan(20 * 1024),
            reason: '$path ni ndogo mno ($bytes B) — huenda ni faili tupu',
          );
        }
      }
    });

    test('hakuna ukurasa unaorudia mchoro wa ukurasa mwingine', () {
      for (final String id in _illustratedStories) {
        final Story story = StorySampleData.all.firstWhere(
          (Story s) => s.id == id,
        );
        final List<String> paths =
            story.pages.map((p) => p.illustration).toList();

        expect(
          paths.toSet().length,
          paths.length,
          reason: '$id inarudia mchoro — kila ukurasa unapaswa kuwa na wake',
        );
      }
    });

    test('michoro ni WebP — sio PNG za megabytes', () {
      for (final String id in _illustratedStories) {
        final Story story = StorySampleData.all.firstWhere(
          (Story s) => s.id == id,
        );
        for (final page in story.pages) {
          expect(
            page.illustration.endsWith('.webp'),
            isTrue,
            reason: '${page.illustration} si .webp',
          );
        }
      }
    });
  });
}
