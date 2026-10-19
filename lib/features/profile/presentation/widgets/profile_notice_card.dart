/// **KADI YA TAARIFA** — kisanduku cha ukweli kinachotumika kwenye skrini za
/// wasifu.
///
/// ## Kwa nini kipo
///
/// Skrini za wasifu na usajili zinapaswa kumweleza mtumiaji **kinachofanya
/// kazi na kisichofanya kazi** (hakuna akaunti, hakuna malipo). Kama kila
/// ukurasa ungeunda kisanduku chake, rangi na ukubwa vingetofautiana — na
/// zaidi, mtu mmoja akibadilisha moja, mwingine asingejua.
///
/// ## Kwa nini rangi hutoka `ColorScheme`, sivyo `AppColors`
///
/// App ina `ThemeMode.system`. `AppColors.background` ni cream (#FAFAF8);
/// kwenye dark mode hiyo ikitumika kama mandhari wakati maandishi yanatoka
/// theme (nyeupe), tunapata **maandishi yasiyoonekana**. Hapa rangi ya
/// msisitizo inachukuliwa kutoka scheme (`primary`/`error`) na maandishi
/// kutoka `onSurface`/`onSurfaceVariant` — hivyo hali zote mbili zinasomeka.
library;

import 'package:flutter/material.dart';

import '../../../../config/theme/spacing.dart';

/// Aina ya taarifa: ya kawaida au ya tahadhari.
enum ProfileNoticeTone {
  /// Maelezo ya kawaida (mfano: data iko kwenye kifaa).
  info,

  /// Tahadhari kuhusu kitu ambacho **hakifanyi kazi** bado.
  warning,
}

/// Kisanduku cha taarifa chenye aikoni, kichwa na maelezo.
///
/// Hutumika kwa taarifa za uaminifu (ukweli kuhusu kifaa, malipo n.k.) ili
/// mtumiaji asidhani kipengele kisichopo kinafanya kazi.
class ProfileNoticeCard extends StatelessWidget {
  /// Huunda kisanduku cha taarifa.
  const ProfileNoticeCard({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.tone = ProfileNoticeTone.info,
  });

  /// Aikoni ya maelezo (hupewa rangi ya msisitizo).
  final IconData icon;

  /// Kichwa kifupi cha taarifa.
  final String title;

  /// Maelezo kamili — sentensi moja hadi tatu.
  final String message;

  /// Aina ya taarifa (hubadilisha rangi ya msisitizo).
  final ProfileNoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    // Tahadhari hutumia `error`, taarifa ya kawaida `primary`. Hakuna rangi
    // iliyowekwa kwa mkono — hivyo inafuata theme ya sasa (light/dark).
    final Color accent = tone == ProfileNoticeTone.warning
        ? scheme.error
        : scheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        // `withOpacity` (sivyo `withValues`) — Flutter 3.16 haijui `withValues`.
        color: accent.withOpacity(0.08),
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Aikoni huhifadhiwa juu ili kichwa kianze sawa na maelezo yake.
          Icon(icon, size: AppSpacing.iconMd, color: accent),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  // `height: 1.5` — sentensi ndefu kwenye simu ya 320dp
                  // inahitaji nafasi ya kupumua, sivyo inakuwa ukuta.
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
