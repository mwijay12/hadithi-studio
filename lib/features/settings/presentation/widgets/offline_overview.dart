import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../stories/data/bundled_stories.dart';
import '../../../stories/data/datasources/story_sample_data.dart';
import '../../../stories/domain/entities/story.dart';

/// Checks manifest entries, not whether playback succeeded on a device.
class BundledStoryStatus {
  const BundledStoryStatus({required this.story, required this.missingImages, required this.missingAudio});
  final Story story;
  final int missingImages;
  final int missingAudio;
  bool get readingReady => missingImages == 0;
  bool get swAudioReady => missingAudio == 0;
}

List<BundledStoryStatus> inspectBundledStories(Iterable<Story> stories, Set<String> assets) => [
  for (final story in stories)
    BundledStoryStatus(
      story: story,
      missingImages: <String>{story.coverAsset, for (final page in story.pages) page.illustration}
          .where((path) => !assets.contains(path)).length,
      missingAudio: List<int>.generate(story.pages.length, (index) => index)
          .where((index) => !assets.contains(BundledStories.pageAudioAsset(story.id, index))).length,
    ),
];

/// Information only: it does not download or delete packaged assets.
class OfflineOverview extends StatefulWidget {
  const OfflineOverview({super.key});
  @override
  State<OfflineOverview> createState() => _OfflineOverviewState();
}

class _OfflineOverviewState extends State<OfflineOverview> {
  Future<List<BundledStoryStatus>>? _report;
  Future<List<BundledStoryStatus>> _load() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return inspectBundledStories(StorySampleData.all, manifest.listAssets().toSet());
  }
  @override
  Widget build(BuildContext context) {
    final sw = context.isSwahili;
    return ExpansionTile(
      key: const ValueKey('offline-overview'),
      leading: const Icon(Icons.offline_pin_outlined),
      title: Text(sw ? 'Hadithi za offline' : 'Offline stories'),
      subtitle: Text(sw ? 'Kagua kilichomo ndani ya app' : 'Check what is bundled in the app'),
      onExpansionChanged: (open) {
        if (open && _report == null) setState(() => _report = _load());
      },
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(sw
              ? 'Hizi ni faili zilizojumuishwa kwenye app, si upakuaji mpya. Sauti zilizokaguliwa ni za Kiswahili; sauti ya kifaa ya Kiingereza inaweza kuhitaji mtandao au sauti iliyosakinishwa. Ukaguzi huu haujaribu kucheza sauti.'
              : 'These files are bundled with the app, not newly downloaded. Checked recordings are Swahili; English device speech may need a network or an installed voice. This check does not test playback.'),
        ),
        if (_report != null) FutureBuilder<List<BundledStoryStatus>>(
          future: _report,
          builder: (context, snapshot) {
            if (snapshot.hasError) return Column(children: <Widget>[
              Text(sw ? 'Hali ya offline haijulikani.' : 'Offline status is unknown.'),
              TextButton(onPressed: () => setState(() => _report = _load()),
                child: Text(sw ? 'Jaribu tena' : 'Try again')),
            ]);
            if (!snapshot.hasData) return const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator());
            return Column(children: [
              for (final item in snapshot.data!)
                ListTile(
                  title: Text(item.story.title(swahili: sw)),
                  subtitle: Text(sw
                      ? '${item.readingReady ? 'Picha zipo' : 'Picha ${item.missingImages} hazipo'} • ${item.swAudioReady ? 'Sauti ya Kiswahili ipo' : 'Sauti ${item.missingAudio} hazipo'}'
                      : '${item.readingReady ? 'Images bundled' : '${item.missingImages} images missing'} • ${item.swAudioReady ? 'Swahili audio bundled' : '${item.missingAudio} audio files missing'}'),
                  leading: Icon(item.readingReady && item.swAudioReady
                      ? Icons.check_circle_outline : Icons.info_outline),
                ),
            ]);
          },
        ),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text(sw
          ? 'Upakuaji na kuondoa faili za hadithi moja moja havipatikani bado.'
          : 'Downloading or removing individual story files is not available yet.')),
      ],
    );
  }
}
