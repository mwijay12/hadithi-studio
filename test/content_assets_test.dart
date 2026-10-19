/// Kinga ya maudhui: picha zote zinazotajwa **zipo**, na kila ukurasa
/// wa hadithi zenye michoro una picha yake.
///
/// ## Kosa lililopelekea jaribio hili
///
/// `AssetConstants` ilikuwa ikiita `assets/images/categories/ngano.png`
/// n.k. — **faili 14 ambazo hazikuwepo**. `Image.asset` haiangushi app;
/// inaonyesha ikoni tupu kimya. Mtoto alibofya kundi na kukuta picha
/// iliyovunjika — "emptiness" ambayo haikuonekana kwenye msimbo.
///
/// Jaribio hili husoma msimbo wa vyanzo na kuthibitisha kila njia ya asset
/// iliyotajwa ipo kwenye diski.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/enums/app_enums.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Picha za makundi', () {
    test('kilа constant ya category inaelekeza kwenye faili iliyopo', () {
      // Vyanzo: `lib/config/constants/asset_constants.dart`.
      final File source =
          File('lib/config/constants/asset_constants.dart');
      expect(source.existsSync(), isTrue,
          reason: 'faili ya constants haipo');

      final String code = source
          .readAsStringSync()
          .replaceAll(r'$_images', 'assets/images');

      final Iterable<String> paths = RegExp(
        r"assets/images/categories/[A-Za-z0-9_.-]+\.(?:png|webp)",
      ).allMatches(code).map((RegExpMatch m) => m.group(0)!);

      expect(paths, isNotEmpty, reason: 'hakuna picha za makundi');

      final List<String> missing = paths
          .where((String p) => !File(p).existsSync())
          .toList();

      expect(missing, isEmpty,
          reason: 'picha hizi zinatajwa lakini hazipo: $missing');
    });
  });

  group('Maudhui ya hadithi', () {
    test('kuna hadithi 10 au zaidi (makundi hayana void)', () {
      expect(StorySampleData.all.length, greaterThanOrEqualTo(10));
    });

    test('kila cover na kila mchoro vipo kwenye diski', () {
      final List<String> missing = <String>[];
      for (final story in StorySampleData.all) {
        if (!File(story.coverAsset).existsSync()) {
          missing.add('${story.id}: ${story.coverAsset}');
        }
        for (final page in story.pages) {
          if (!File(page.illustration).existsSync()) {
            missing.add('${story.id}: ${page.illustration}');
          }
        }
      }
      expect(missing, isEmpty, reason: 'hazipo: $missing');
    });

    test('hadithi zenye michoro ya kila ukurasa hazirudii picha', () {
      final List<String> duplicated = <String>[];
      for (final story in StorySampleData.all) {
        final List<String> perPage = story.pages
            .map((p) => p.illustration)
            .where((String p) => p.contains('/pages/'))
            .toList();
        if (perPage.isEmpty) continue;
        final Set<String> unique = perPage.toSet();
        if (unique.length != perPage.length) {
          duplicated.add(story.id);
        }
      }
      expect(duplicated, isEmpty,
          reason: 'hadithi hizi zinarudia mchoro: $duplicated');
    });

    test('kundi la wanyama lina hadithi', () {
      final int animals = StorySampleData.all
          .where((s) => s.category == StoryCategory.wanyama)
          .length;
      expect(animals, greaterThanOrEqualTo(1));
    });

    test('activeShelves haina rafu tupu', () {
      for (final shelf in StorySampleData.activeShelves) {
        expect(StorySampleData.countInShelf(shelf), greaterThan(0),
            reason: 'rafu ${shelf.name} inaonekana lakini haina hadithi');
      }
    });
  });
}
