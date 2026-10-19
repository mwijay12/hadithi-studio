/// Ukuta wa makosa (error boundary) + skrini ya kurejesha.
///
/// **Kwa nini ukuta na si `try/catch` pekee:** `try/catch` hukamata makosa
/// tunayoyatarajia. Lakini kosa la fremu ya kuonyesha (widget `build`
/// linalotupa, layout isiyowezekana) **haliwezi kukamatwa** na msimbo wetu —
/// Flutter huiripoti kwa `FlutterError.onError` na kuacha fremu hiyo kupakwa.
/// Matokeo kwa mtumiaji: sehemu ya skrini inakuwa nyeupe/nyekundu.
///
/// [AppErrorBoundary] husikiliza [AppErrorHandler] na, kosa likitokea,
/// huonyesha [CrashRecoveryScreen] — skrini inayoeleza kwa utulivu na
/// kumpa mtumiaji njia ya kutoka. Mtoto wa Tanzania **hapaswi** kukutana na
/// skrini nyeupe bila maelezo.
///
/// **Mahali pake:** ndani ya `MaterialApp` (kwenye `builder:`), kwa sababu
/// skrini ya kurejesha inahitaji `Theme`, `Directionality`, na l10n — vyote
/// hutoka kwenye `MaterialApp`.
///
/// ## SOMO: husikiliza makosa MABAYA pekee
///
/// Toleo la kwanza la ukuta huu lilisikiliza `FlutterError.onError` **yote**
/// na kubadilisha skrini nzima. Matokeo halisi: **skrini ya pili ya
/// onboarding** ilionyesha "Pole! Hitilafu imetokea" kwa sababu ya kosa
/// lisilozuia kitu (overflow au asset isiyopatikana) — yaani tulifanya app
/// ionekane **imevunjika zaidi**, sivyo kidogo.
///
/// Kwa hivyo sasa tunasikiliza [AppErrorHandler.fatalCount] pekee: makosa ya
/// async yasiyokamatwa, ambapo hali ya app haijulikani. Kwa kosa la fremu,
/// Flutter yenyewe huonyesha kosa la eneo hilo na sehemu nyingine za app
/// zinaendelea kufanya kazi — hilo ni tabia **bora** kwa mtumiaji.
///
/// Makosa yote bado yanarekodiwa ([AppErrorHandler.records]) kwa uchunguzi.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/theme/colors.dart';
import '../../config/theme/spacing.dart';
import '../../l10n/l10n.dart';
import '../services/app_error_handler.dart';
import '../utils/snackbar_service.dart';
import 'leo_mascot.dart';

/// Hukamata makosa ya fremu na kuonyesha skrini ya kurejesha.
class AppErrorBoundary extends StatefulWidget {
  /// Huunda ukuta unaozunguka [child].
  const AppErrorBoundary({super.key, required this.child});

  /// Maudhui ya app.
  final Widget child;

  @override
  State<AppErrorBoundary> createState() => _AppErrorBoundaryState();
}

class _AppErrorBoundaryState extends State<AppErrorBoundary> {
  bool _crashed = false;
  int _seenCount = 0;

  @override
  void initState() {
    super.initState();
    _seenCount = AppErrorHandler.fatalCount.value;
    AppErrorHandler.fatalCount.addListener(_onFatal);
  }

  @override
  void dispose() {
    AppErrorHandler.fatalCount.removeListener(_onFatal);
    super.dispose();
  }

  void _onFatal() {
    if (!mounted) return;
    // Kosa lililotokea **kabla** ya ukuta huu kuwepo (mfano wakati wa
    // kuanzisha) haliwezi kuonyeshwa na sisi — tunalipuuza ili app isianze
    // na skrini ya kosa kwa kosa la zamani.
    if (AppErrorHandler.fatalCount.value <= _seenCount) return;
    _seenCount = AppErrorHandler.fatalCount.value;
    setState(() => _crashed = true);
  }

  void _restart() {
    AppErrorHandler.clear();
    _seenCount = 0;
    setState(() => _crashed = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_crashed) return widget.child;

    return CrashRecoveryScreen(
      record: AppErrorHandler.lastRecord,
      onRestart: _restart,
    );
  }
}

/// Skrini inayoonyeshwa kosa lisilotarajiwa linapotokea.
class CrashRecoveryScreen extends StatefulWidget {
  /// Huunda skrini ya kurejesha.
  const CrashRecoveryScreen({
    super.key,
    this.record,
    required this.onRestart,
  });

  /// Kosa lililotokea (kama lipo).
  final AppErrorRecord? record;

  /// Huitwa mtumiaji anapobofya "Anza Upya".
  final VoidCallback onRestart;

  @override
  State<CrashRecoveryScreen> createState() => _CrashRecoveryScreenState();
}

class _CrashRecoveryScreenState extends State<CrashRecoveryScreen> {
  bool _showDetails = false;

  /// Hunakili maelezo ya kosa kwenye ubao wa kunakili.
  ///
  /// **Kwa nini kunakili, si kutuma:** kutuma ripoti kunahitaji anwani ya
  /// msaada ambayo bado haipo. Kubuni anwani (`support@…`) kungetuma
  /// ripoti za watumiaji mahali pasipopokelewa. Kunakili kunafanya kazi
  /// **bila mtandao** — na mzazi anaweza kutuma kwa WhatsApp mwenyewe.
  Future<void> _copyReport() async {
    final AppErrorRecord? record = widget.record;
    final String details = record == null
        ? 'Hadithi Studio — hakuna maelezo ya kosa.'
        : 'Hadithi Studio — kosa\n'
            'Aina: ${record.kind.name}\n'
            'Wakati: ${record.at.toIso8601String()}\n'
            'Kosa: ${record.summary}\n\n'
            '${record.stackTrace ?? ''}';

    await Clipboard.setData(ClipboardData(text: details));
    if (!mounted) return;
    SnackbarService.showSuccess(context.l10n.reportProblemCopied);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AppErrorRecord? record = widget.record;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.huge),
              // **LEO** — pose ya udadisi.
              //
              // Kwa nini "udadisi" na si "furaha": mtumiaji hajasherehekea
              // kitu — kosa limetokea. Leo anayeinamisha kichwa anaonyesha
              // "kuna kitu hakiko sawa", sivyo shangwe ya uongo.
              //
              // SAREKANO: nilikuwa nimeandika hapa kuwa
              // `assets/images/mascot_lion.png` haipo kwenye diski.
              // **Hilo lilikuwa si kweli** — faili ipo (byte 225,589).
              // Uamuzi wa kutumia Leo ni wa **mtindo**, sivyo kulazimishwa
              // na faili iliyokosekana.
              const Center(
                child: LeoMascot(pose: LeoPose.curious, height: 140),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.crashTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.crashMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),

              // Anza Upya
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onRestart();
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.restartApp),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.safariGreen,
                    foregroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusMd,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Rudi Nyumbani — hurudisha nyumbani kwa njia salama
              OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  // Tunarekodi nyumbani badala ya kupiga `Navigator.pop`
                  // mara nyingi: kufuta back-stack kunazuia kurudi kwenye
                  // fremu iliyoanguka.
                  AppErrorHandler.clear();
                  widget.onRestart();
                },
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.goHome),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.safariGreen,
                  side: const BorderSide(color: AppColors.safariGreen),
                  minimumSize: const Size.fromHeight(52),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderRadiusMd,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              TextButton.icon(
                onPressed: _copyReport,
                icon: const Icon(Icons.report_problem_outlined),
                label: Text(l10n.reportProblem),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),

              // Maelezo ya kiufundi — yamefichwa kwa default.
              if (record != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: () =>
                      setState(() => _showDetails = !_showDetails),
                  child: Text(
                    _showDetails ? l10n.readLess : l10n.errorDetails,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (_showDetails)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: AppSpacing.borderRadiusSm,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      '${record.kind.name}\n\n${record.summary}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
