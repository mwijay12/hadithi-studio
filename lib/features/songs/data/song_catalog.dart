/// Katalogi ya **nyimbo za watoto** — hugundua faili zilizowekwa kwenye
/// `assets/audio/songs/`.
///
/// ## Kwa nini hugundua badala ya kuorodhesha kwa mkono
///
/// Mtumiaji (au mwandishi wa maudhui) atakapopata nyimbo za bure za
/// hakimiliki, kazi inapaswa kuwa **kuweka faili na kujenga** — siyo
/// kuhariri msimbo. Kanuni hii ni ile ile iliyotumika kwa sauti ya hadithi
/// (`StoryAudioPlayer`): `AssetManifest.json` ndiyo orodha ya ukweli.
///
/// ### Kanuni ya jina la faili
///
/// ```
/// assets/audio/songs/01_kitendawili.mp3
/// assets/audio/songs/02_safari_ya_wanyama.mp3
/// ```
///
/// Nambari ya mwanzo hutumika kwa **mpangilio**; mstari chini (`_`) hubadilishwa
/// kuwa nafasi. Jina linakuwa kichwa cha wimbo: `kitendawili` → `Kitendawili`.
/// Kiendelezi `.mp3`, `.m4a` au `.wav` kinakubaliwa.
///
/// Ukitaka kichwa cha Kiswahili **na** Kiingereza kwa wimbo mmoja, weka faili
/// ya pembeni yenye jina lile lile na kiendelezi `.json`:
///
/// ```json
/// { "titleSw": "Kitendawili", "titleEn": "The Riddle Song",
///   "artist": "Hadithi Studio" }
/// ```
///
/// Bila `.json`, kichwa kinaundwa kutoka jina la faili na hutumika kwa lugha
/// zote mbili — sivyo kuvunja ukurasa.
library;

import 'dart:convert';

import 'package:flutter/services.dart';

/// Wimbo mmoja kwenye katalogi.
class Song {
  const Song({
    required this.id,
    required this.titleSw,
    required this.titleEn,
    required this.asset,
    this.artistSw,
    this.artistEn,
  });

  final String id;
  final String titleSw;
  final String titleEn;

  /// Njia kamili ya asset, mf. `assets/audio/songs/01_kitendawili.mp3`.
  final String asset;

  final String? artistSw;
  final String? artistEn;
}

/// Ugunduzi wa nyimbo kutoka `AssetManifest`.
abstract final class SongCatalog {
  const SongCatalog._();

  /// Kabla ya alama ya mwisho.
  static const String folder = 'assets/audio/songs/';

  static const List<String> _extensions = <String>['.mp3', '.m4a', '.wav'];

  /// Hurudisha nyimbo zilizopangwa kwa nambari ya mwanzo.
  ///
  /// Haizuii app ikiwa manifest imeshindwa — hurudisha orodha tupu, na
  /// ukurasa unaonyesha hali tupu kwa uwazi.
  static Future<List<Song>> discover({AssetBundle? bundle}) async {
    final AssetBundle assets = bundle ?? rootBundle;

    List<String> files;
    try {
      final AssetManifest manifest =
          await AssetManifest.loadFromAssetBundle(assets);
      files = manifest
          .listAssets()
          .where((String path) => _isSong(path))
          .toList();
    } catch (error) {
      // Kwenye build ya web yenye renderer ya HTML, manifest inaweza
      // kukosekana. Ukurasa utaonyesha "hakuna nyimbo" — sivyo kuanguka.
      return const <Song>[];
    }

    files.sort(_byIndex);
    final List<Song> songs = <Song>[];
    for (final String path in files) {
      final Song? song = await _read(path, assets);
      if (song != null) songs.add(song);
    }
    return songs;
  }

  static bool _isSong(String path) {
    if (!path.startsWith(folder)) return false;
    final String lower = path.toLowerCase();
    return _extensions.any(lower.endsWith);
  }

  /// `01_kichwa.mp3` → 1. Faili zenye nambari huja kwanza.
  static int _byIndex(String a, String b) {
    final int? ia = _leadingNumber(a);
    final int? ib = _leadingNumber(b);
    if (ia != null && ib != null) return ia.compareTo(ib);
    if (ia != null) return -1;
    if (ib != null) return 1;
    return a.compareTo(b);
  }

  static int? _leadingNumber(String path) {
    final String name = path.split('/').last;
    final RegExpMatch? m = RegExp(r'^(\d+)').firstMatch(name);
    return m == null ? null : int.tryParse(m.group(1)!);
  }

  static Future<Song?> _read(String path, AssetBundle assets) async {
    final String fileName = path.split('/').last;
    final String base = fileName.contains('.')
        ? fileName.substring(0, fileName.lastIndexOf('.'))
        : fileName;

    String titleSw = _titleFromFile(base);
    String titleEn = titleSw;
    String? artistSw;
    String? artistEn;

    // Faili ya pembeni (hiari): `01_kichwa.json`.
    try {
      final String raw = await assets.loadString('$folder$base.json');
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        final String? sw = decoded['titleSw'] as String?;
        final String? en = decoded['titleEn'] as String?;
        final String? artist = decoded['artist'] as String?;
        if (sw != null && sw.trim().isNotEmpty) titleSw = sw.trim();
        if (en != null && en.trim().isNotEmpty) titleEn = en.trim();
        artistSw = artist;
        artistEn = artist;
      }
    } catch (_) {
      // Hakuna `.json` — hilo ni kawaida, sivyo kosa.
    }

    if (titleSw.trim().isEmpty) return null;

    return Song(
      id: base,
      titleSw: titleSw,
      titleEn: titleEn,
      asset: path,
      artistSw: artistSw,
      artistEn: artistEn,
    );
  }

  /// `02_safari_ya_wanyama` → `Safari Ya Wanyama`.
  static String _titleFromFile(String base) {
    final String withoutIndex = base.replaceFirst(RegExp(r'^\d+[\s_-]*'), '');
    final String spaced = withoutIndex.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    if (spaced.isEmpty) return '';
    return spaced
        .split(RegExp(r'\s+'))
        .map((String w) => w.isEmpty
            ? w
            : (w[0].toUpperCase() + w.substring(1).toLowerCase()))
        .join(' ');
  }
}
