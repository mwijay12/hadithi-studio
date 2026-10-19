import 'package:flutter/material.dart';

import '../../config/app_config.dart';
import '../../config/theme/spacing.dart';
import '../../l10n/l10n.dart';
import '../errors/failures.dart';
import '../extensions/context_extensions.dart';
import '../utils/image_utils.dart';
import 'cached_image.dart';
import 'custom_button.dart';

/// Widgets za kuonyesha **kosa** kwa mtumiaji (kanuni ya 13: loading/error/empty
/// states kwenye kila screen).
///
/// ## Kwa nini widget hii ipo
///
/// Bila widget moja, kila screen ingeandika `Column(Icon, Text, Button)`
/// yake — na kwenye app yenye skrini ~40, hilo linamaanisha aina 40 za
/// "kosa" zinazotofautiana kwa nafasi, ukubwa wa aikoni na maneno. Mtumiaji
/// anayeona "Hakuna mtandao" kwa namna tatu tofauti anadhani app inavunjika.
///
/// ## Vyanzo viwili vya maandishi
///
/// 1. **Kichwa (title)** — hutoka kwenye ARB (`context.l10n.error` au
///    `context.l10n.noInternet`), kwa sababu ni maneno mafupi ya UI
///    yanayopaswa kutafsiriwa na watafsiri.
/// 2. **Maelezo (detail)** — hutoka kwenye [Failure] yenyewe
///    (`messageSw`/`messageEn`). Failures **tayari** zina maandishi ya lugha
///    mbili (kanuni ya 4), kwa hivyo kurudia sentensi hizi hapa kungenakili
///    chanzo kimoja na kuharibu siku moja tutakapobadilisha ujumbe wa kosa.
///
/// ## Kikomo cha kujaribu tena (retry)
///
/// Kitufe cha "Jaribu tena" **hakionyeshwa kwa kila kosa.** Kosa la
/// `AuthFailure` (kikao kimeisha) na `PermissionFailure.planLimitReached`
/// (kikomo cha plan) halitatuliwi kwa kubonyeza tena — mtumiaji anahitaji
/// **kitufe tofauti** ("Ingia tena", "Panda daraja"). Kuonyesha "Jaribu tena"
/// hapo ni kumwongoza mtumiaji kwenye mzunguko usio na mwisho. Kwa hivyo
/// uamuzi wa retry unaishi mahali pamoja: [AppFailurePresentation.isRetryable].
///
/// Matumizi ya kawaida kwenye BLoC listener:
/// ```dart
/// if (state is LibraryError) {
///   return AppErrorWidget(
///     failure: state.failure,
///     onRetry: () => context.read<LibraryCubit>().refresh(),
///   );
/// }
/// ```
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.failure,
    this.onRetry,
    this.onSecondary,
    this.secondaryLabelSw,
    this.secondaryLabelEn,
    this.titleSw,
    this.titleEn,
    this.retryLabelSw,
    this.retryLabelEn,
    this.compact = false,
    this.useIllustration = false,
  });

  /// Kosa lililotokea — chanzo cha maelezo ya lugha mbili.
  final Failure failure;

  /// `null` = hakuna kitufe cha kujaribu tena (mfano kosa la uthibitisho).
  final VoidCallback? onRetry;

  /// Hatua mbadala — mfano "Ingia tena" kwa [AuthFailure].
  ///
  /// Ni **muhimu** kwa makosa yasiyojaribika: bila hii, mtumiaji wa kikao
  /// kilichoisha anaona ujumbe bila njia ya kutoka (dead end).
  final VoidCallback? onSecondary;

  /// Lebo ya hatua mbadala kwa Kiswahili (lazima ikiwa na [onSecondary]).
  final String? secondaryLabelSw;

  /// Lebo ya hatua mbadala kwa Kiingereza.
  final String? secondaryLabelEn;

  /// Kichwa maalum — kwa kawaida hutumika [failure] pekee.
  final String? titleSw;
  final String? titleEn;

  /// Lebo maalum ya kitufe cha kujaribu tena (chaguo-msingi: ARB `retry`/`tryAgain`).
  final String? retryLabelSw;
  final String? retryLabelEn;

  /// `true` = onyesha kwa nafasi ndogo, kwa matumizi **ndani** ya ukurasa
  /// (mfano kadi ya sehemu iliyoshindwa kupakia) badala ya ukurasa mzima.
  final bool compact;

  /// `true` = tumia picha ya msanii ([AssetConstants.iconErrorState] kupitia
  /// [AppImageUtils.errorPlaceholder]) badala ya aikoni ya Material.
  ///
  /// Chaguo-msingi ni `false` kwa sababu aikoni za per-kind zinaeleza **nini
  /// kifanyike** (hakuna mtandao / seva imelala / kikomo cha plan), wakati
  /// mchoro mmoja wa jumla hausemi kitu. Tumia `true` kwa kufa kabisa
  /// (fatal/app-level) ambapo hakuna hatua ya mtumiaji.
  final bool useIllustration;

  @override
  Widget build(BuildContext context) {
    final title = _resolveTitle(context);
    final detail = failure.message(swahili: context.isSwahili);
    final icon = AppFailurePresentation.iconFor(failure);
    final tone = AppFailurePresentation.toneFor(failure, context.colorScheme);

    // Retry huonyeshwa tu kama mtumiaji amepitisha `onRetry` **na** aina ya
    // kosa inaruhusu. Kosa la plan limit linaweza kutokea kwenye screen
    // iliyoandikwa kwa ukaribu na `onRetry` ya jumla; kuifanya widget hii
    // ichetue mwenyewe kunazuia kitufe kipotoshe.
    final canRetry = onRetry != null && AppFailurePresentation.isRetryable(failure);

    final iconSize = compact ? AppSpacing.iconLg : AppSpacing.iconXl;
    final horizontal = compact ? AppSpacing.lg : AppSpacing.xxl;

    return Semantics(
      // Error ni taarifa **mpya** kwa mtumiaji asiyeona — `liveRegion`
      // inasababisha screen reader ikisome mara moja badala ya kusubiri
      // mtumiaji aipitie kwa mkono.
      container: true,
      liveRegion: true,
      label: '$title. $detail',
      child: Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontal,
              vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ErrorGlyph(
                  icon: icon,
                  tone: tone,
                  size: iconSize,
                  useIllustration: useIllustration,
                ),
                SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),

                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineSmall,
                ),
                SizedBox(height: AppSpacing.sm),

                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium,
                ),

                // Code ya kiufundi — kwa msanidi pekee. Mtumiaji wa kawaida
                // hahitaji kuona 'NETWORK_ERROR'; msanidi anayeangalia log
                // anaihitaji ili kulinganisha na Sentry.
                if (AppConfig.enableLogging && failure.code != null) ...[
                  SizedBox(height: AppSpacing.md),
                  Text(
                    failure.code!,
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelSmall,
                  ),
                ],

                if (canRetry || onSecondary != null) ...[
                  SizedBox(height: compact ? AppSpacing.lg : AppSpacing.xxl),
                  _ErrorActions(
                    canRetry: canRetry,
                    onRetry: onRetry,
                    retryLabelSw: retryLabelSw,
                    retryLabelEn: retryLabelEn,
                    onSecondary: onSecondary,
                    secondaryLabelSw: secondaryLabelSw,
                    secondaryLabelEn: secondaryLabelEn,
                    compact: compact,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kichwa: maalum kwanza, kisha kwa aina ya kosa, kisha jumla.
  ///
  /// Kosa la mtandao linapata kichwa cha "Hakuna Mtandao" kwa sababu
  /// `context.l10n.error` ("Hitilafu imetokea") ingeeleza kitu kibaya
  /// kinachotokea ndani ya app, wakati tatizo liko nje — kwenye muunganisho.
  String _resolveTitle(BuildContext context) {
    if (titleSw != null && titleEn != null) {
      return context.localised(swahili: titleSw!, english: titleEn!);
    }
    if (AppFailurePresentation.isOffline(failure)) {
      return context.l10n.noInternet;
    }
    return context.l10n.error;
  }
}

/// Aikoni ya kosa ndani ya mduara wenye rangi hafifu.
///
/// Mduara huo unarahisisha kusoma aikoni kwenye mandhari yenye kelele nyingi
/// (kanga/mkitenge background) na kuzuia aikoni isionekane "imeanguka" peke
/// yake kwenye skrini kubwa.
class _ErrorGlyph extends StatelessWidget {
  const _ErrorGlyph({
    required this.icon,
    required this.tone,
    required this.size,
    required this.useIllustration,
  });

  final IconData icon;
  final Color tone;
  final double size;
  final bool useIllustration;

  @override
  Widget build(BuildContext context) {
    final circle = size * 2.2;

    if (useIllustration) {
      return ExcludeSemantics(
        child: AppAssetIcon(
          assetPath: AppImageUtils.errorPlaceholder,
          fallbackIcon: icon,
          size: circle,
          color: tone,
        ),
      );
    }

    return ExcludeSemantics(
      child: Container(
        width: circle,
        height: circle,
        decoration: BoxDecoration(
          // `0.10` inatosha kuonekana kwenye `cardBackground` nyeupe na
          // kwenye `darkSurface`; kwa hivyo thamani moja inafaa mandhari zote.
          color: tone.withOpacity(0.10),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: size, color: tone),
      ),
    );
  }
}

/// Vitufe vya kosa: "Jaribu tena" (primary) na hatua mbadala (text).
class _ErrorActions extends StatelessWidget {
  const _ErrorActions({
    required this.canRetry,
    required this.onRetry,
    required this.retryLabelSw,
    required this.retryLabelEn,
    required this.onSecondary,
    required this.secondaryLabelSw,
    required this.secondaryLabelEn,
    required this.compact,
  });

  final bool canRetry;
  final VoidCallback? onRetry;
  final String? retryLabelSw;
  final String? retryLabelEn;
  final VoidCallback? onSecondary;
  final String? secondaryLabelSw;
  final String? secondaryLabelEn;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canRetry)
          AppButton(
            labelSw: retryLabelSw ?? context.l10n.retry,
            labelEn: retryLabelEn ?? context.l10n.tryAgain,
            icon: Icons.refresh_rounded,
            size: compact ? AppButtonSize.small : AppButtonSize.medium,
            expand: !compact,
            onPressed: onRetry,
          ),

        // Hatua mbadala inaonekana **baada** ya retry kwa makusudi: kwa kosa
        // linalojaribika, kujaribu tena ni hatua inayowezekana zaidi; kwa
        // kosa lisilojaribika, hii ndiyo njia pekee ya kutoka.
        if (onSecondary != null &&
            secondaryLabelSw != null &&
            secondaryLabelEn != null) ...[
          if (canRetry) const SizedBox(height: AppSpacing.xs),
          AppButton(
            labelSw: secondaryLabelSw!,
            labelEn: secondaryLabelEn!,
            variant: AppButtonVariant.text,
            size: compact ? AppButtonSize.small : AppButtonSize.medium,
            onPressed: onSecondary,
          ),
        ],
      ],
    );
  }
}

/// Uainishaji wa [Failure] kwa mahitaji ya UI.
///
/// Hii ni **chanzo kimoja cha ukweli** cha: aikoni ipi, rangi ipi, na kama
/// kosa linajarbika. Bila hii, kila page ingeandika `switch` yake — na
/// `Failure` si `sealed`, kwa hivyo switch isingekuwa exhaustive: kosa jipya
/// lingeanguka kwenye tawi la jumla kimya kimya kwenye page moja na si
/// nyingine.
///
/// **Kwa nini `code` inatumika, si aina pekee:** `PermissionFailure` inashughulikia
/// vitu viwili tofauti kabisa — "hauna ruhusa" (`PERMISSION_DENIED`) na
/// "umefikia kikomo cha plan" (`PLAN_LIMIT`). Ya kwanza haitatuliwi na
/// mtumiaji; ya pili inatatuliwa kwa kupanda daraja. Hatuwezi kutofautisha
/// kwa `is` — na hilo ndilo kusudi la `Failure.code`.
abstract final class AppFailurePresentation {
  const AppFailurePresentation._();

  /// `true` kama kubonyeza "Jaribu tena" kunaweza kufanikiwa.
  ///
  /// Kanuni: **kosa la muda (transient) linajarbika; kosa la haki, data au
  /// pembejeo halijarbiki.**
  static bool isRetryable(Failure failure) => switch (failure) {
        // Muda/uunganisho — jaribio lingine linaweza kufanikiwa.
        NetworkFailure() => true,
        TimeoutFailure() => true,
        ServerFailure() => true,
        CacheFailure() => true,
        UnknownFailure() => true,

        // Sauti inaweza kupatikana baada ya sekunde chache.
        TtsFailure() => true,

        // Malipo: ombi jipya la malipo ni hatua halali ya mtumiaji.
        // (Kumbuka: hii ni retry ya **mtumiaji**; `ApiClient` hairudii
        // maombi ya malipo yenyewe — tazama ApiInterceptors.)
        PaymentFailure() => true,

        // AI: rate limit inahitaji **kusubiri**, si kubonyeza tena (litashindwa
        // mara moja); content blocked haitatatuliwa kwa ombi lile lile.
        // Kosa la jumla la AI (`AI_ERROR`, mfano json mbovu kutoka model)
        // linaweza kufanikiwa jaribio lingine.
        AiGenerationFailure() =>
          failure.code != 'AI_RATE_LIMITED' && failure.code != 'AI_CONTENT_BLOCKED',

        // Haki / uthibitisho / data haipo / pembejeo mbovu.
        AuthFailure() => false,
        PermissionFailure() => false,
        NotFoundFailure() => false,
        ValidationFailure() => false,

        // Failure mpya isiyojulikana: chukulia inajarbika, kwa sababu kosa
        // lisilojulikana mara nyingi huwa la muda (mfano JSON isiyotarajiwa).
        _ => true,
      };

  /// `true` kama tatizo ni muunganisho (si kosa la app).
  static bool isOffline(Failure failure) =>
      failure is NetworkFailure || failure is TimeoutFailure;

  /// `true` kama kikao kimeisha na mtumiaji anahitaji kuingia tena.
  static bool isSessionExpired(Failure failure) => failure is AuthFailure;

  /// `true` kama mtumiaji amefikia kikomo cha plan (BURE = hadithi 3/mwezi).
  static bool isPlanLimit(Failure failure) =>
      failure is PermissionFailure && failure.code == 'PLAN_LIMIT';

  /// Aikoni ya kosa kwa aina yake.
  ///
  /// Kila aikoni inachaguliwa kwa **kitendo kinachofuata**: `wifi_off`
  /// inamaanisha angalia mtandao, `hourglass` inamaanisha subiri, `lock`
  /// inamaanisha ingia, `workspace_premium` inamaanisha panda daraja.
  ///
  /// **MUHIMU wa matoleo:** aikoni zote hapa zimechaguliwa kutoka kwenye
  /// familia zilizokuwepo kabla ya Flutter 3.2 (`_rounded` zilianza Flutter
  /// 2.0; `workspace_premium` ni ya 2021). Aikoni mpya zaidi (mfano
  /// `credit_card_off`, `edit_off`) zinaweza kukosekana kwenye toolchain ya
  /// msingi yetu — hivyo tunatumia mbadala za zamani zenye maana ile ile.
  static IconData iconFor(Failure failure) => switch (failure) {
        NetworkFailure() => Icons.wifi_off_rounded,
        TimeoutFailure() => Icons.hourglass_bottom_rounded,
        ServerFailure() => Icons.dns_rounded,
        CacheFailure() => Icons.storage_rounded,
        AuthFailure() => Icons.lock_rounded,
        PermissionFailure() =>
          failure.code == 'PLAN_LIMIT'
              ? Icons.workspace_premium
              : Icons.block,
        PaymentFailure() => Icons.money_off_rounded,
        AiGenerationFailure() => Icons.auto_awesome_rounded,
        TtsFailure() => Icons.volume_off_rounded,
        NotFoundFailure() => Icons.search_off_rounded,
        ValidationFailure() => Icons.report_problem_rounded,
        UnknownFailure() => Icons.error_outline_rounded,
        _ => Icons.error_outline_rounded,
      };

  /// Rangi ya aikoni.
  ///
  /// Nyekundu (`colorScheme.error`) inatumika kwa **kosa la kweli** pekee.
  /// Kukosa mtandao si kosa la app — ni hali ya kawaida Tanzania — kwa hivyo
  /// tunatumia rangi ya sekondari (zanzibarTurquoise). Kikomo cha plan
  /// kinatumia kangaOrange kwa sababu ni **nafasi**, si kosa.
  static Color toneFor(Failure failure, ColorScheme scheme) {
    if (isPlanLimit(failure)) return scheme.tertiary;
    if (isOffline(failure)) return scheme.secondary;
    return scheme.error;
  }
}
