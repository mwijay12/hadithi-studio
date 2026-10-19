import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'colors.dart';

/// Theme ya usiku (dark) — muhimu kwa kusoma usiku (bedtime stories).
abstract final class DarkTheme {
  /// ColorScheme ya usiku — **mahali pamoja** (sababu ile ile ya
  /// `AppTheme.lightScheme`: `google_fonts` hufanya theme nzima isipimwe).
  ///
  static ColorScheme get darkScheme => ColorScheme.fromSeed(
          seedColor: AppColors.zanzibarTurquoise,
          brightness: Brightness.dark,
        ).copyWith(
          primary: AppColors.zanzibarTurquoise,
          onPrimary: Colors.black,
          secondary: AppColors.sunsetGold,
          onSecondary: Colors.black,
          tertiary: AppColors.kangaOrange,
          onTertiary: Colors.black,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkBodyText,
          // **Kwa nini #B9BFD4 (na sivyo kijivu cha default):**
          // default ya Material ni #49454F, ambayo juu ya mandhari nyeusi
          // (#1C1F27) hutoa **~1.8:1** — haisomeki. Hii ni 8.99:1 ✓
          onSurfaceVariant: AppColors.readerNightPastText,
          error: AppColors.coralPink,
          onError: Colors.black,
          // `outline` = vidhibiti (switch/fields); `outlineVariant` =
          // mistari ya mapambo. `readerNightSurface` (#23233A) juu ya
          // #1C1F27 ni karibu asiyeonekana kama mstari — tunatumia kijivu
          // cha kati kwa mipaka, na `outline` kwa vidhibiti.
          outline: AppColors.readerNightPastText,
          outlineVariant: AppColors.readerNightPastText.withOpacity(0.28),
        );

  static ThemeData get dark => AppTheme.build(
        scheme: darkScheme,
        scaffoldBackground: AppColors.darkBackground,
        bodyColor: AppColors.darkBodyText,
        mutedColor: AppColors.darkMutedText,
        dividerColor: AppColors.darkDivider,
        appBarBackground: AppColors.darkBackground,
        appBarForeground: AppColors.darkBodyText,
        inputFill: AppColors.darkSurface,
        navBackground: AppColors.darkSurface,
        navSelected: AppColors.zanzibarTurquoise,
        navUnselected: AppColors.darkMutedText,
        brightness: Brightness.dark,
      );
}
