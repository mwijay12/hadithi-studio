import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// Theme ya mwanga (light) ya Hadithi Studio.
///
/// Kumbuka: `inputDecorationTheme` na `cardTheme` kwa makusudi HAZIWEKWI hapa
/// kwa sababu aina zao zimebadilika kati ya matoleo ya Flutter
/// (`InputDecorationThemeData` / `CardThemeData`). Badala yake, styling hizo
/// zinaishi kwenye widgets zetu: `CustomTextField` na `AppCard`.
abstract final class AppTheme {
  /// ColorScheme ya mwanga — **mahali pamoja**.
  ///
  /// **Kwa nini imetolewa peke yake:** `AppTheme.light` hujenga `ThemeData`
  /// NZIMA, ikiwemo `AppTypography`, ambayo hutumia `google_fonts`.
  /// `google_fonts` hupakua fonti kwa **HTTP** wakati wa kujenga. Kwenye
  /// majaribio (bila mtandao, au bila fonti zilizowekwa ndani ya app),
  /// kurudisha theme nzima **hutupa exception** — hivyo theme yenyewe
  /// **haingeweza kupimwa kamwe**.
  ///
  /// Kwa kutenganisha scheme, tunaipima bila typography. Hii ni sababu
  /// ya kweli ya kupima, sivyo ya kupamba.
  ///
  static ColorScheme get lightScheme => ColorScheme.fromSeed(
          seedColor: AppColors.safariGreen,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.safariGreen,
          onPrimary: Colors.white,
          secondary: AppColors.zanzibarTurquoise,
          onSecondary: Colors.white,
          tertiary: AppColors.kangaOrange,
          onTertiary: Colors.white,
          surface: AppColors.cardBackground,
          onSurface: AppColors.bodyText,
          // **Kwa nini hii imeandikwa wazi:** `onSurfaceVariant` haikuwa
          // ikiwekwa, hivyo ilirudi kwenye default ya Material (#49454F).
          // Juu ya mandhari NYEUSI ya dark mode, kijivu hicho hutoa
          // **~1.8:1** — maandishi yasiyoonekana. Kila jukumu la rangi
          // linalotumiwa na UI lazima liwe na thamani iliyopimwa.
          //
          // #666666 juu ya #FFFFFF = 5.74:1 (WCAG AA) ✓
          onSurfaceVariant: AppColors.mutedText,
          error: AppColors.spiceRed,
          onError: Colors.white,
          // **Mipaka na vidhibiti ni vitu viwili tofauti.**
          // `outline` hutumiwa na Material kwa **vidhibiti** (kitufe cha
          // `Switch` kilicho ZIMWA, mipaka ya uwanja). `divider` (#E8E8E8)
          // juu ya uso wa switch (#E0E4D6) ni **1.05:1** — kitufe
          // hakionekani. Ukaguzi wa macho uliipata hii kwenye "Ofa na
          // matangazo": kintele kilikuwa king'aa bila mstari.
          // `mutedText` (#666666) ni 5.74:1 — vya kutosha.
          outline: AppColors.mutedText,
          // `outlineVariant` hubaki kwa **mistari ya mapambo** (mipaka ya
          // kadi) — hapo hafifu ndiyo sahihi.
          outlineVariant: AppColors.divider,
        );

  static ThemeData get light => build(
        scheme: lightScheme,
        scaffoldBackground: AppColors.background,
        bodyColor: AppColors.bodyText,
        mutedColor: AppColors.mutedText,
        dividerColor: AppColors.divider,
        appBarBackground: AppColors.background,
        appBarForeground: AppColors.darkText,
        inputFill: AppColors.cardBackground,
        navBackground: AppColors.cardBackground,
        navSelected: AppColors.safariGreen,
        navUnselected: AppColors.mutedText,
        brightness: Brightness.light,
      );

  /// Builder mmoja unaotumiwa na light na dark theme ili kubaki consistent.
  static ThemeData build({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color bodyColor,
    required Color mutedColor,
    required Color dividerColor,
    required Color appBarBackground,
    required Color appBarForeground,
    required Color inputFill,
    required Color navBackground,
    required Color navSelected,
    required Color navUnselected,
    required Brightness brightness,
  }) {
    final textTheme = AppTypography.textTheme(
      bodyColor: bodyColor,
      mutedColor: mutedColor,
    );

    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        toolbarHeight: AppSpacing.appBarHeight,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: appBarForeground, size: AppSpacing.iconMd),
      ),

      iconTheme: IconThemeData(color: bodyColor, size: AppSpacing.iconMd),

      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.primary.withOpacity(0.08),
        selectedColor: scheme.primary,
        labelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: bodyColor,
        ),
        secondaryLabelStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusPill,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.primary.withOpacity(0.35),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          backgroundColor: scheme.secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withOpacity(0.5)),
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusMd,
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: GoogleFonts.nunito(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.onSurface,
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: scheme.surface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSm,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBackground,
        selectedItemColor: navSelected,
        unselectedItemColor: navUnselected,
        selectedLabelStyle: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.primary.withOpacity(0.15),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),

      // `FadeUpwardsPageTransitionsBuilder` inatumika badala ya
      // `FadeForwardsPageTransitionsBuilder` kwa sababu ya mwisho iliongezwa
      // kwenye matoleo ya Flutter ya baadaye; hii inahakikisha app inajenga
      // kuanzia Flutter 3.2 (SDK constraint yetu).
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // `inputFill` inatumika na CustomTextField.
      extensions: const [],
    );
  }

  /// Rangi ya kujaza kwenye text fields (inatumika na CustomTextField).
  static Color get lightInputFill => AppColors.cardBackground;
}
