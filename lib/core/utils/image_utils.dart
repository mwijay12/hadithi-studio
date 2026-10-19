/// IMAGE UTILS — picha kwa mazingira ya Tanzania (2G/3G, simu za 16–32GB).
///
/// Kwa nini faili hili lipo: picha ndizo kitu kikubwa kabisa kwenye hadithi
/// iliyo na vielelezo. Kwenye mtandao wa 2G/3G wa vijijini, kupakua picha
/// kamili ya ukurasa mmoja kunaweza kuchukua dakika — na kwenye simu ya
/// 16GB nafasi inaisha haraka. Hivyo tunahitaji mahali pamoja pa kujibu
/// maswali manne:
///
/// 1. **Ubora gani nitume?** (`qualityFor`) — chini kwenye 2G, juu kwenye Wi-Fi.
/// 2. **Nafasi ngapi inaruhusiwa?** (`cacheLimitMb`) — kutoka [AppConstants].
/// 3. **Picha ya zamani ifutwe lini?** (`isExpired`).
/// 4. **Nionyeshe nini wakati picha haijafika?** (`placeholderForCategory`).
///
/// **Kanuni ya kutokurudia:** ukubwa wa cache (`imageCacheSizeMb` = 120) na
/// muda wa kuhifadhi (`offlineCacheExpiryDays` = 60) hutoka [AppConstants];
/// njia za assets hutoka [AssetConstants]. Faili hili halina hifadhi yoyote
/// iliyoandikwa kwa mkono — ni mantiki (logic) pekee.
///
/// TANBIHI: `cached_network_image` ndiyo inayoshikilia cache halisi ya
/// diski. Faili hili linatoa **sheria** tu; kuziunganisha ni kazi ya
/// `cached_image.dart` (core/widgets) na `cache_manager.dart` (core/storage).
library;

import '../../config/constants/app_constants.dart';
import '../../config/constants/asset_constants.dart';
import '../enums/app_enums.dart';

/// Ubora wa picha unaotumika kuomba na kuhifadhi picha.
///
/// Thamani za `maxWidthPx` zimechaguliwa kwa skrini za 5.0"–5.5" zenye
/// 720p–1080p: `480` inatosha kwa kadi, `720` kwa ukurasa wa kusoma, na
/// `1080` kwa kuirudisha ukurasa mzima wa hadithi.
enum ImageQuality {
  low(40, 480, 'Ubora wa chini', 'Low quality'),
  medium(65, 720, 'Ubora wa kati', 'Medium quality'),
  high(85, 1080, 'Ubora wa juu', 'High quality');

  const ImageQuality(this.quality, this.maxWidthPx, this.labelSw, this.labelEn);

  /// Ubora wa ubadilishaji (1–100) unaotumwa kwenye kigezo `q=`.
  final int quality;

  /// Upana wa juu kabisa wa picha kwa pikseli, unaotumwa kwenye kigezo `w=`.
  final int maxWidthPx;

  /// Lebo kwa Kiswahili — kwa `storage_settings_page.dart`.
  final String labelSw;

  /// Lebo kwa Kiingereza.
  final String labelEn;
}

/// Hushughulikia ukubwa, ubora na njia za picha.
abstract final class AppImageUtils {
  // ---------------------------------------------------------------------------
  // Cache (kutoka AppConstants)
  // ---------------------------------------------------------------------------

  /// Ukubwa wa juu wa cache ya picha kwa MB.
  static int get cacheLimitMb => AppConstants.imageCacheSizeMb;

  /// Ukubwa wa juu wa cache ya picha kwa baiti.
  ///
  /// Hii hutolewa kwa `cache_manager.dart` na kwa `ImageCache` ya Flutter
  /// (`maximumSizeBytes`) ili kikomo kimoja kionekane mahali pamoja.
  static int get cacheLimitBytes => AppConstants.imageCacheSizeMb * 1024 * 1024;

  /// Siku ambazo picha iliyohifadhiwa inaweza kubaki bila kutumika.
  static int get expiryDays => AppConstants.offlineCacheExpiryDays;

  /// Muda wa kuhifadhi picha kabla ya kufutwa kiotomatiki.
  static Duration get cacheExpiry => Duration(days: expiryDays);

  /// `true` kama picha iliyohifadhiwa [cachedAt] imepitwa na wakati.
  ///
  /// Kusudi: mtumiaji wa simu ya 16–32GB hawezi kufuta cache mwenyewe kwa
  /// urahisi. Picha za hadithi zisizosomwa kwa siku [expiryDays] hufutwa
  /// kiotomatiki ili maktaba mpya ipate nafasi.
  ///
  /// `now` hupitishwa kwenye tests ili matokeo yasitegemee saa ya mashine.
  static bool isExpired(DateTime cachedAt, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return reference.difference(cachedAt) >= cacheExpiry;
  }

  // ---------------------------------------------------------------------------
  // Ubora kwa hali ya mtandao
  // ---------------------------------------------------------------------------

  /// Ubora unaofaa kwa hali ya mtandao wa sasa.
  ///
  /// Kipaumbele:
  /// - `lowDataMode` → ubora wa chini **daima**. Mtumiaji ameamua mwenyewe
  ///   (spec §7.3: "Low data mode option"), hivyo hatupingi uamuzi wake hata
  ///   akiwa kwenye Wi-Fi.
  /// - Wi-Fi → ubora wa juu, kwa sababu bundle haitumiki.
  /// - Vinginevyo (data ya mkononi) → kati: picha ionekane vizuri bila
  ///   kummaliza bundle ya mtumiaji.
  static ImageQuality qualityFor({
    bool lowDataMode = false,
    bool onWifi = false,
  }) {
    if (lowDataMode) return ImageQuality.low;
    return onWifi ? ImageQuality.high : ImageQuality.medium;
  }

  /// Lebo ya ubora kwa UI.
  static String qualityLabel(ImageQuality quality, {bool swahili = true}) =>
      swahili ? quality.labelSw : quality.labelEn;

  // ---------------------------------------------------------------------------
  // Njia za picha (URL / assets / faili)
  // ---------------------------------------------------------------------------

  /// `true` kama njia ni URL ya mtandao.
  static bool isRemote(String path) {
    final lower = path.toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  /// `true` kama njia ni asset iliyopangwa ndani ya app (kazi bila mtandao).
  static bool isAsset(String path) => path.startsWith('assets/');

  /// `true` kama njia ni faili iliyohifadhiwa kwenye simu.
  static bool isLocalFile(String path) =>
      path.startsWith('/') || path.startsWith('file:');

  /// Kiendelezi cha faili kutoka njia: `.../picha.png` → `png`.
  ///
  /// Hurudisha [fallback] kama hakuna kiendelezi kinachosomeka. Hii ni
  /// muhimu kwa sababu URL za API zetu mara nyingi huwa
  /// `.../illustration/42` **bila** kiendelezi kabisa — na `CachedNetworkImage`
  /// inahitaji jina la faili lenye kiendelezi kwenye diski.
  static String extensionOf(String path, {String fallback = 'jpg'}) {
    final cleanPath = path.split('?').first.split('#').first;
    final lastDot = cleanPath.lastIndexOf('.');
    if (lastDot <= 0 || lastDot == cleanPath.length - 1) return fallback;

    final candidate = cleanPath.substring(lastDot + 1).toLowerCase();
    if (candidate.length > 5) return fallback;
    for (final codeUnit in candidate.codeUnits) {
      final isDigit = codeUnit >= 0x30 && codeUnit <= 0x39; // 0-9
      final isLetter = codeUnit >= 0x61 && codeUnit <= 0x7A; // a-z
      if (!isDigit && !isLetter) return fallback;
    }
    return candidate;
  }

  // ---------------------------------------------------------------------------
  // Funguo za cache (stable keys)
  // ---------------------------------------------------------------------------

  /// Ufunguo thabiti wa cache kwa URL ya picha.
  ///
  /// Tunatumia FNV-1a (32-bit) kwa mkono badala ya `url.hashCode`: Dart
  /// haitoi uhakika kwamba `hashCode` ya `String` itabaki ile ile kwenye
  /// matoleo (versions) au tope (builds) tofauti. Ufunguo wa cache
  /// ukibadilika, kila pakua huanza kutoka mwanzo — cache ya 120MB inajaa
  /// mara mbili na mtumiaji wa bundle ndogo analipa tena kwa data ile ile.
  ///
  /// FNV-1a ni rahisi, haina dependency, na hutoa herufi 8 za hex.
  static String cacheKeyFor(String url) {
    var hash = 0x811C9DC5; // FNV offset basis (2166136261)
    for (final codeUnit in url.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xFFFFFFFF; // FNV prime (16777619)
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  /// Jina la faili la cache: `a1b2c3d4.png`.
  static String cacheFileNameFor(String url, {String? extension}) =>
      '${cacheKeyFor(url)}.${extension ?? extensionOf(url)}';

  // ---------------------------------------------------------------------------
  // Kubadilisha picha kwa CDN
  // ---------------------------------------------------------------------------

  /// Kuongeza vigezo vya ukubwa, ubora na muundo kwenye URL ya picha.
  ///
  /// TANBIHI LA MSINGI: hii inafanya kazi **tu** kama CDN (Cloudflare R2 image
  /// resizing, au `/cdn-cgi/image/`) inaunga mkono vigezo `w`/`q`/`fm`. Kama
  /// backend haijawezesha, URL hurudishwa kama ilivyo — hivyo mtumiaji haoni
  /// picha iliyovunjika (broken image) badala ya picha ndogo.
  ///
  /// `fm=webp` ni salama kwenye Android na iOS zote tunazolenga: Flutter
  /// hu-decode WebP yenyewe (si kwa kutegemea mfumo), na WebP huokoa ~30%
  /// ya ukubwa kuliko JPEG kwa ubora ule ule.
  static String cdnTransform(String url, {required ImageQuality quality}) {
    if (url.isEmpty || !isRemote(url)) return url;
    // URL iliyobadilishwa tayari — tusirudie vigezo.
    if (url.contains('w=') || url.contains('q=')) return url;

    final separator = url.contains('?') ? '&' : '?';
    return '$url$separator'
        'w=${quality.maxWidthPx}&q=${quality.quality}&fm=webp';
  }

  // ---------------------------------------------------------------------------
  // Picha za kushika nafasi (placeholders — assets za ndani)
  // ---------------------------------------------------------------------------

  /// Picha ya kushika nafasi kwa kundi la hadithi.
  ///
  /// Kwa nini hii ni muhimu: kwenye 2G/3G picha ya mtandao inaweza kuchukua
  /// sekunde kadhaa, na bila mtandao haiji kabisa. Kadi yenye picha ya kundi
  /// (asset ya ndani) inaonekana **mara moja**, na mtumiaji anajua kadi ni
  /// ya kundi gani hata kabla ya picha halisi kufika.
  static String placeholderForCategory(StoryCategory category) {
    switch (category) {
      case StoryCategory.hadithi_za_kiswahili:
        return AssetConstants.categoryHadithiZaKiswahili;
      case StoryCategory.hadithi_za_kisasa:
        return AssetConstants.categoryHadithiZaKisasa;
      case StoryCategory.ngano:
        return AssetConstants.categoryNgano;
      case StoryCategory.methali_na_nahau:
        return AssetConstants.categoryMethali;
      case StoryCategory.historia_ya_tanzania:
        return AssetConstants.categoryHistoria;
      case StoryCategory.sayansi_na_teknolojia:
        return AssetConstants.categorySayansi;
      case StoryCategory.mazingira:
        return AssetConstants.categoryMazingira;
      // Kundi jipya la wanyama linatumia picha ya safari — ndiyo picha ya
      // kundi iliyopo karibu zaidi (wanyama wa Serengeti).
      case StoryCategory.wanyama:
        return AssetConstants.categoryWanyama;
      case StoryCategory.maadili:
        return AssetConstants.categoryMaadili;
      case StoryCategory.ujasiriamali:
        return AssetConstants.categoryUjasiriamali;
      case StoryCategory.burudani:
        return AssetConstants.categoryBurudani;
      case StoryCategory.elimu:
        return AssetConstants.categoryElimu;
      case StoryCategory.dini:
        return AssetConstants.categoryDini;
      case StoryCategory.michezo:
        return AssetConstants.categoryMichezo;
      case StoryCategory.sanaa:
        return AssetConstants.categorySanaa;
    }
  }

  /// Picha ya jumla kwa orodha tupu (empty state).
  static String get emptyPlaceholder => AssetConstants.iconEmptyState;

  /// Picha ya kosa wakati picha haipatikani.
  ///
  /// Tunatumia asset ya ndani ili "error" ionekane hata bila mtandao —
  /// kosa la mtandao likionyesha picha ya mtandao lingeshindwa pia.
  static String get errorPlaceholder => AssetConstants.iconErrorState;

  /// Beji ya mafanikio ambayo hayajafikiwa bado.
  static String get lockedBadgePlaceholder => AssetConstants.badgeLocked;
}
