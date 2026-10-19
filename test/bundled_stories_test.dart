/// Majaribio ya **seti ya kuanza** (hadithi 3 zinazokuja na app) na kanuni za
/// majina ya faili za sauti.
///
/// ## Kwa nini jaribio hili ni muhimu sana
///
/// Mtumiaji (au agent) huweka faili za sauti kwenye `assets/audio/<story>/`
/// na **hutegemea jina lifanane kabisa** na kile msimbo unachotafuta. Tofauti
/// ya herufi moja — `page_1.mp3` badala ya `page_01.mp3` — haitatoa kosa; app
/// itaangukia TTS kimya, na mtumiaji atadhani audio yake haifanyi kazi.
///
/// Jaribio hili hufunga kanuni hiyo kwa msimbo, ili **dokumenti na msimbo
/// visitofautiane**.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/enums/app_enums.dart';
import 'package:hadithi_studio/features/stories/data/bundled_stories.dart';
import 'package:hadithi_studio/features/stories/presentation/widgets/interactive_hotspot.dart';

void main() {
  group('BundledStories', () {
    test('hadithi 3, kwa mpangilio wa kuonyesha', () {
      expect(BundledStories.ids, <String>[
        'safari-ya-simba',
        'mlima-kilimanjaro',
        'nyota-za-usiku',
      ]);
    });

    test('isBundled hukubali hizi tatu pekee', () {
      expect(BundledStories.isBundled('safari-ya-simba'), isTrue);
      expect(BundledStories.isBundled('ngoma-ya-furaha'), isFalse);
    });

    test('kurasa 17 kwa jumla', () {
      expect(BundledStories.pageCounts['safari-ya-simba'], 6);
      expect(BundledStories.pageCounts['mlima-kilimanjaro'], 6);
      expect(BundledStories.pageCounts['nyota-za-usiku'], 5);
      expect(BundledStories.totalPages, 17);
    });

    test('bajeti: hadithi 5 MB, seti 15 MB', () {
      expect(BundledStories.maxStoryBytes, 5 * 1024 * 1024);
      expect(BundledStories.maxLaunchSetBytes, 15 * 1024 * 1024);
    });
  });

  group('kanuni ya majina ya faili za sauti', () {
    test('ukurasa huanza na 01, si 1', () {
      expect(
        BundledStories.pageAudioAsset('safari-ya-simba', 0),
        'assets/audio/safari-ya-simba/page_01.mp3',
      );
    });

    test('ukurasa wa 10 huwa page_10', () {
      expect(
        BundledStories.pageAudioAsset('nyota-za-usiku', 9),
        'assets/audio/nyota-za-usiku/page_10.mp3',
      );
    });

    test('ukurasa wa 17 huwa page_17', () {
      expect(
        BundledStories.pageAudioAsset('nyota-za-usiku', 16),
        'assets/audio/nyota-za-usiku/page_17.mp3',
      );
    });

    test('timestamps hutumia jina lile lile, `.json`', () {
      expect(
        BundledStories.pageTimingAsset('mlima-kilimanjaro', 2),
        'assets/audio/mlima-kilimanjaro/page_03.json',
      );
    });

    test('sauti na timestamps hufanana jina kwa kila ukurasa', () {
      // Hii ndiyo inayoweka uangazaji wa neno uwezekane: faili mbili
      // zinatofautiana kwa kiendelezi pekee.
      for (int i = 0; i < 6; i++) {
        final String audio =
            BundledStories.pageAudioAsset('safari-ya-simba', i);
        final String timing =
            BundledStories.pageTimingAsset('safari-ya-simba', i);
        expect(audio.replaceAll('.mp3', ''), timing.replaceAll('.json', ''));
      }
    });

    test('mp3 ndiyo kiendelezi, 48 kbps kwa usimulizi', () {
      expect(BundledStories.audioExtension, 'mp3');
      expect(BundledStories.narrationBitrateKbps, 48);
    });
  });

  group('aina za eneo (hotspots)', () {
    test('kila aina ina ikoni na rangi — hakuna tawi lililosahaulika', () {
      for (final HotspotType type in HotspotType.values) {
        expect(
          hotspotIconFor(type),
          isNotNull,
          reason: '${type.name} haina ikoni',
        );
        expect(
          hotspotColorFor(type),
          isNotNull,
          reason: '${type.name} haina rangi',
        );
      }
    });

    test('story_choice na mini_game PEKEE ndizo zisizojengwa', () {
      // Hizi mbili zilionyesha "jibu la swali ambalo hakukuwa nalo".
      expect(hotspotTypeIsUnbuilt(HotspotType.story_choice), isTrue);
      expect(hotspotTypeIsUnbuilt(HotspotType.mini_game), isTrue);

      expect(hotspotTypeIsUnbuilt(HotspotType.sound_effect), isFalse);
      expect(hotspotTypeIsUnbuilt(HotspotType.character_speak), isFalse);
      expect(hotspotTypeIsUnbuilt(HotspotType.info_popup), isFalse);
      expect(hotspotTypeIsUnbuilt(HotspotType.animation), isFalse);
    });

    test('aina nne za kufichua taarifa zinaonyesha maandishi', () {
      const List<HotspotType> informative = <HotspotType>[
        HotspotType.sound_effect,
        HotspotType.animation,
        HotspotType.info_popup,
        HotspotType.character_speak,
      ];
      expect(
        informative.where(hotspotTypeIsUnbuilt).length,
        0,
      );
    });
  });
}
