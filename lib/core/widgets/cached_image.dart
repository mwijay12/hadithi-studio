/// WIDGET: picha yenye cache — inashughulikia assets, faili za ndani na URL.
///
/// **Kwa nini widget hii ipo:** Tanzania ina data ya bei ghali na mtandao wa
/// 2G/3G. Kila picha ya hadithi inayopakuliwa **mara moja** inapaswa kubaki
/// kwenye kifaa. Widget hii ndiyo mahali pamoja panaposhughulikia:
///
/// 1. **Assets za ndani** (`assets/...`) — picha za kundi, placeholder.
/// 2. **Faili za ndani** (`/data/...`) — picha zilizopakuliwa kwa offline.
/// 3. **URL za mtandao** — kwa `cached_network_image` (disk cache yake).
/// 4. **Cache yetu ya offline** (`CacheManager`) — kwa `preferOfflineCache`.
///
/// **Funguo ya cache inalingana.** Tunapitisha
/// `AppImageUtils.cacheKeyFor(url)` kama `cacheKey` kwa `cached_network_image`,
/// na `AppImageUtils.cacheFileNameFor(url)` kwa `CacheManager`. Zote mbili
/// zinatumia FNV-1a ile ile, kwa hivyo jina la faili linapatana popote.
/// Ukibadilisha mmoja, badilisha mwingine — la sivyo mtumiaji atapakua picha
/// ile ile mara mbili na cache ya 120MB itajaa haraka.
///
/// **Assets hazipo bado kwenye repo.** `assets/images/` na `assets/icons/`
/// bado hazijawekwa (tazama pubspec.yaml). Kwa hivyo **kila** `Image.asset`
/// hapa ina `errorBuilder` inayorudi kwenye `IconData` ya Material — bila hiyo
/// app ingeonyesha kisanduku chekundu (red error box) badala ya picha.
library;

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';
import '../enums/app_enums.dart';
import '../storage/cache_manager.dart';
import '../utils/image_utils.dart';
import 'loading_widget.dart';

/// Aikoni inayotoka kwenye asset, ikirudi kwenye `IconData` kama asset haipo.
///
/// Hii ni widget ndogo lakini muhimu: assets za mradi bado hazijawekwa, na
/// `Image.asset` ya asset isiyokuwepo **hutupa kosa** (si picha tupu). Kwa
/// kutumia widget hii mahali pamoja, tabia ni ile ile kwenye hali zote tatu
/// (error, empty, placeholder) na tunabadilisha mahali pamoja tunapoongeza
/// assets halisi.
class AppAssetIcon extends StatelessWidget {
  const AppAssetIcon({
    super.key,
    required this.assetPath,
    required this.fallbackIcon,
    this.size = 64,
    this.color,
  });

  /// Njia ya asset (mfano `AssetConstants.iconErrorState`).
  final String assetPath;

  /// Aikoni ya Material inayotumika kama asset haipo.
  final IconData fallbackIcon;

  /// Ukubwa wa pande zote mbili (asset na aikoni).
  final double size;

  /// Rangi ya aikoni ya akiba.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      // Asset haipo (bado) → aikoni. Hii ni njia ya kawaida, si kosa.
      errorBuilder: (_, __, ___) => Icon(
        fallbackIcon,
        size: size,
        color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
      ),
    );
  }
}

/// Picha inayotumika kwenye app yote.
class AppCachedImage extends StatelessWidget {
  const AppCachedImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = AppSpacing.borderRadiusMd,
    this.category,
    this.quality,
    this.cacheManager,
    this.preferOfflineCache = false,
    this.fallbackIcon = Icons.image_outlined,
    this.semanticLabel,
    this.showShimmerWhileLoading = true,
    this.fadeIn = true,
  });

  /// URL, njia ya asset (`assets/...`) au njia ya faili ya ndani.
  ///
  /// TANBIHI: `width`/`height` zikiwa `null`, widget inachukua ukubwa wa
  /// mzazi. Weka ndani ya `AspectRatio`, `SizedBox` au `Expanded` — la sivyo
  /// kwenye constraints zisizo na kikomo app itatoa kosa la layout.
  final String path;

  final double? width;
  final double? height;
  final BoxFit fit;

  /// Pembe za picha. Weka `null` kwa pembe za mraba (mfano ukurasa mzima).
  final BorderRadius? borderRadius;

  /// Kundi la hadithi — hutumika kuchagua picha ya placeholder.
  final StoryCategory? category;

  /// Ubora wa kuomba kutoka CDN.
  ///
  /// Widget hii **haisomi** mipangilio wala `connectivity_plus`: ni widget ya
  /// UI, na kusoma hali ya mtandao ndani yake kungefanya kila picha
  /// kujisajili kwa `NetworkInfo`. Ukurasa (mfano `library_page.dart`) ndiyo
  /// unapaswa kuita `AppImageUtils.qualityFor(lowDataMode: …, onWifi: …)` na
  /// kupitisha matokeo hapa.
  final ImageQuality? quality;

  /// Cache yetu ya offline.
  ///
  /// Ni lazima tu kwa `preferOfflineCache` — kama `null`, picha za mtandao
  /// zinategemea cache ya `cached_network_image` pekee.
  final CacheManager? cacheManager;

  /// `true` = angalia cache yetu ya offline **kabla** ya kwenda mtandaoni.
  ///
  /// Tumia hii kwenye **kusoma** (reader) tu. Kwenye orodha (maktaba, nyumbani)
  /// iache `false`: kusubiri disk kwanza kunaongeza ~5–20 ms kwa kila picha
  /// bila faida, kwa sababu mtumiaji aliye mtandaoni anaona picha mapema
  /// akiruhusu `cached_network_image` kuanza mara moja.
  final bool preferOfflineCache;

  /// Aikoni inayoonyeshwa wakati placeholder/asset haipo.
  final IconData fallbackIcon;

  /// Lebo ya ufikiaji (screen reader) — mtoto asiyeona anaweza kusikia.
  final String? semanticLabel;

  final bool showShimmerWhileLoading;

  /// `true` = picha inaingia kwa kupungua (fade in).
  ///
  /// Kwenye simu za 2GB RAM inaweza kuzimwa ili kupunguza kazi ya
  /// kuchora wakati wa kusogeza orodha ndefu.
  final bool fadeIn;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      width: width,
      height: height,
      child: _buildContent(context),
    );

    final clipped = borderRadius == null
        ? content
        : ClipRRect(borderRadius: borderRadius!, child: content);

    if (semanticLabel == null) return clipped;

    return Semantics(image: true, label: semanticLabel, child: clipped);
  }

  // ---------------------------------------------------------------------------
  // Uchaguzi wa chanzo
  // ---------------------------------------------------------------------------

  Widget _buildContent(BuildContext context) {
    // Njia tupu → placeholder. Hii hufika kutoka kwenye data ya backend
    // yenye `illustration_url: ""`, jambo la kawaida kwa hadithi ambazo
    // picha yake bado haijatengenezwa na AI.
    if (path.isEmpty) return _placeholder(context);

    if (AppImageUtils.isAsset(path)) {
      return Image.asset(
        path,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    if (AppImageUtils.isLocalFile(path)) {
      return Image.file(
        File(path),
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _placeholder(context),
      );
    }

    // Picha ya CDN iliyobadilishwa tayari (w= / q=) inarudishwa kama ilivyo
    // na `cdnTransform`, hivyo ni salama kuiita kila mara.
    final url = AppImageUtils.cdnTransform(
      path,
      quality: quality ?? ImageQuality.medium,
    );

    if (!preferOfflineCache || cacheManager == null) {
      return _networkImage(context, url);
    }
    return _offlineFirst(context, url);
  }

  /// Huangalia cache yetu kabla ya mtandao (kwa reader/offline).
  Widget _offlineFirst(BuildContext context, String url) {
    return FutureBuilder<String?>(
      future: cacheManager!.fileFor(
        CacheCategory.illustrations,
        AppImageUtils.cacheFileNameFor(path),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Bado tunasoma disk: shimmer, si placeholder ya kundi — ili
          // mtumiaji asione "picha haipo" wakati inakuja.
          return showShimmerWhileLoading
              ? const AppShimmerBox()
              : _placeholder(context);
        }

        final localPath = snapshot.data;
        if (localPath == null) return _networkImage(context, url);

        return Image.file(
          File(localPath),
          fit: fit,
          width: width,
          height: height,
          // Faili ipo kwenye index lakini disk imefutwa (mfano mtumiaji
          // "Clear data" ya app) → rudi mtandaoni badala ya kosa.
          errorBuilder: (_, __, ___) => _networkImage(context, url),
        );
      },
    );
  }

  Widget _networkImage(BuildContext context, String url) {
    return CachedNetworkImage(
      imageUrl: url,
      // Funguo ile ile tunayotumia kwenye CacheManager (FNV-1a) — tazama
      // ufafanuzi wa faili hili.
      cacheKey: AppImageUtils.cacheKeyFor(path),
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: fadeIn ? AppSpacing.fast : Duration.zero,
      placeholder: (_, __) => showShimmerWhileLoading
          ? const AppShimmerBox()
          : _placeholder(context),
      errorWidget: (_, __, ___) => _errorPlaceholder(context),
    );
  }

  // ---------------------------------------------------------------------------
  // Placeholders
  // ---------------------------------------------------------------------------

  /// Picha ya kubeba nafasi: picha ya kundi (kama ipo) au aikoni ya tupu.
  Widget _placeholder(BuildContext context) {
    final hasCategory = category != null;
    return AppAssetIcon(
      assetPath: hasCategory
          ? AppImageUtils.placeholderForCategory(category!)
          : AppImageUtils.emptyPlaceholder,
      // Picha ya kundi ikikosekana, aikoni ya kawaida inatosha — kosa la
      // kupakua picha si kosa la kundi.
      fallbackIcon: hasCategory ? fallbackIcon : Icons.auto_stories_outlined,
      size: _placeholderIconSize,
    );
  }

  /// Picha ya kosa — hii ni tofauti na `_placeholder`: inamaanisha picha
  /// ilikuwa ipo lakini haikupakuliwa (mtandao/URL mbovu).
  Widget _errorPlaceholder(BuildContext context) {
    return AppAssetIcon(
      assetPath: AppImageUtils.errorPlaceholder,
      fallbackIcon: Icons.broken_image_outlined,
      size: _placeholderIconSize,
      color: Theme.of(context).colorScheme.error.withOpacity(0.5),
    );
  }

  /// Aikoni isizidi 40% ya upande mfupi zaidi, ili kwenye kadi ndogo
  /// (mfano 96dp) aikoni isionekane kubwa kupita kiasi.
  double get _placeholderIconSize {
    final shortest = switch ((width, height)) {
      (final double w, final double h) => w < h ? w : h,
      (final double w, null) => w,
      (null, final double h) => h,
      _ => AppSpacing.iconXl,
    };
    final scaled = shortest * 0.4;
    return scaled.clamp(AppSpacing.iconMd, AppSpacing.iconXl);
  }
}
