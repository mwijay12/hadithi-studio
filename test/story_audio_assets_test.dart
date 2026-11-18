import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/features/stories/data/bundled_stories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('completed stories include audio for every page', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets().toSet();
    const pageCounts = <String, int>{
      'safari-ya-simba': 6,
      'mlima-kilimanjaro': 6,
      'nyota-za-usiku': 5,
      'kifaru-mdogo': 3,
      'mti-wa-babu': 3,
      'safari-ya-matone': 3,
      'ngoma-ya-furaha': 5,
      'twiga-mrefu': 3,
      'kuku-na-mwewe': 5,
      'chapati-za-mama': 6,
    };
    for (final entry in pageCounts.entries) {
      for (var page = 0; page < entry.value; page++) {
        expect(assets, contains(BundledStories.pageAudioAsset(entry.key, page)));
      }
    }
  });
}
