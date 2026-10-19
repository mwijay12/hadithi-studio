/// Ujumbe wa kimataifa (global snackbars).
///
/// **Kwa nini funguo ya kimataifa na si `ScaffoldMessenger.of(context)`:**
/// makosa mengi hutokea **nje ya** mti wa widget — kwenye interceptor ya
/// mtandao, kwenye `catch` ya async, au kwenye mchakato wa malipo. Mahali
/// hapo hakuna `BuildContext`, na `context` iliyohifadhiwa inaweza kuwa
/// **imefutwa** (unmounted) — kuitumia huangusha app.
///
/// Funguo ya kimataifa ([appMessengerKey]) ipo kwenye `MaterialApp`, hivyo
/// inaishi maisha yote ya app. Hii ndiyo njia pekee salama ya kuonyesha kosa
/// kutoka mahali popote.
///
/// **Kanuni ya lugha:** faili hili **haliandiki** maneno ya mtumiaji.
/// Neno huja kama hoja ([message], [actionLabel]) — kwa hivyo huja tayari
/// kwa lugha iliyochaguliwa (`context.l10n`). Hivyo kanuni ya 3 ya mradi
/// (Kiswahili NA Kiingereza) haivunjwi hapa.
library;

import 'package:flutter/material.dart';

import '../../config/theme/colors.dart';
import '../../config/theme/spacing.dart';

/// Funguo ya `ScaffoldMessenger` ya app nzima.
///
/// Sajili kwenye `MaterialApp`/`MaterialApp.router`:
/// ```dart
/// MaterialApp.router(scaffoldMessengerKey: appMessengerKey, ...)
/// ```
final GlobalKey<ScaffoldMessengerState> appMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Hudhibiti ujumbe wa app nzima.
abstract final class SnackbarService {
  /// Muda wa ujumbe wa kosa — mrefu kidogo, kwa sababu unasomeka.
  static const Duration _errorDuration = Duration(seconds: 5);

  /// Muda wa ujumbe wa kawaida.
  static const Duration _normalDuration = Duration(seconds: 4);

  /// Huonyesha kosa.
  ///
  /// [actionLabel] na [onAction] ni hiari: kama mtumiaji anaweza kufanya
  /// kitu kuhusu kosa (mfano "Jaribu Tena"), mpe kitufe. Kama hakuna
  /// kitu cha kufanya, usionyeshe kitufe kisichofanya kitu.
  static void showError(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _show(
      message: message,
      icon: Icons.error_outline_rounded,
      background: AppColors.spiceRed,
      duration: _errorDuration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Huonyesha mafanikio (kijani cha mafanikio).
  static void showSuccess(String message) {
    _show(
      message: message,
      icon: Icons.check_circle_outline_rounded,
      background: AppColors.success,
      duration: _normalDuration,
    );
  }

  /// Huonyesha taarifa (bluu).
  static void showInfo(String message) {
    _show(
      message: message,
      icon: Icons.info_outline_rounded,
      background: AppColors.info,
      duration: _normalDuration,
    );
  }

  /// Hufuta ujumbe unaoonekana sasa.
  static void dismiss() => appMessengerKey.currentState?.hideCurrentSnackBar();

  static void _show({
    required String message,
    required IconData icon,
    required Color background,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    // `currentState` ni `null` kabla `MaterialApp` kujengwa, au baada ya app
    // kufungwa. Kuitumia bila sharti ni crash — hivyo tunarudi kimya.
    final ScaffoldMessengerState? messenger = appMessengerKey.currentState;
    if (messenger == null) {
      debugPrint('SnackbarService: messenger haipo bado — ujumbe umepotea.');
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: <Widget>[
              Icon(icon, color: Colors.white, size: AppSpacing.iconMd),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSm,
          ),
          duration: duration,
          action: (actionLabel != null && onAction != null)
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: Colors.white,
                  onPressed: onAction,
                )
              : null,
        ),
      );
  }
}
