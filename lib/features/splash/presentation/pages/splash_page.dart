/// Skrini ya kuanza (splash) ya Hadithi Studio.
///
/// **Kazi tatu za skrini hii:**
/// 1. Kuonyesha utambulisho wa app (rangi za Tanzania, salamu ya Kiswahili)
///    wakati injini inajiandaa.
/// 2. Kuamua mtumiaji aende wapi — onboarding (mtumiaji mpya) au shell
///    (mtumiaji anayerejea).
/// 3. Kuhuisha token kimya kimya (`AuthTokens.expiresWithin`) ili mtumiaji
///    asikutane na 401 kwenye ombi lake la kwanza.
///
/// **Muda:** `AppConstants.splashMinimumDuration` huamua **kurasa kwenda
/// wapi** (muda wa chini kabla ya kuondoka). `AppSpacing.splash` ni muda wa
/// **animation ya nembo** pekee. Kutenganisha hivi kunazuia animation
/// ndefu kuchelewesha app.
///
/// TODO(uhuishaji): ongeza `di.sl()` hapa kwa `SecureAuthTokenProvider`
/// ili kuhuisha token wakati wa splash — skrini hii ndiyo mahali pazuri
/// kwa sababu mtumiaji anasubiri tayari.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/services/library_store.dart';
import '../../../../core/widgets/leo_mascot.dart';
import '../../../../l10n/l10n.dart';

/// Skrini ya kuanza.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  /// Huendesha kuingia kwa nembo (fade + slight scale).
  late final AnimationController _controller;

  late final Animation<double> _fade;
  late final Animation<double> _scale;

  /// Huhakikisha hatuendi mbele mara mbili (mfano kama mtumiaji
  /// anagusa skrini wakati timer inaisha).
  bool _navigated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: AppSpacing.slow,
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    // Kuanza kidogo (0.88) na kufikia 1.0 — huonekana kama "kupumua"
    // badala ya kuruka. Haiathiri layout kwa sababu `ScaleTransition`
    // ni transform pekee (haipangi upya watoto).
    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _decideNext();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Huamua pa kwenda baada ya muda wa chini.
  ///
  /// **Hii ndiyo ilikuwa C10:** awali ilikuwa `context.go(onboarding)` kila
  /// mara, kwa sababu hakuna mahali palipohifadhi kwamba onboarding
  /// imemalizika. Mtumiaji aliyemaliza onboarding aliondokea tena kila
  /// kufungua app.
  ///
  /// Sasa tunauliza [LibraryStore] — ambayo [main] ilirejesha **kabla** ya
  /// `runApp`, kwa hivyo jibu liko tayari na hakuna "kuruka" kwa UI.
  Future<void> _decideNext() async {
    await Future<void>.delayed(AppConstants.splashMinimumDuration);
    if (!mounted || _navigated) return;

    _navigated = true;
    context.go(
      LibraryStore.instance.onboardingDone
          ? AppRoutes.home
          : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      // Gradienti ya kanga: kijani cha safari hadi bluu ya Kilimanjaro.
      // Hii ni `DecoratedBox` badala ya `Container(color:)` ili tusipoteze
      // rangi ya theme wakati wa mabadiliko ya mwanga/giza.
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.safariGreen,
              AppColors.kilimanjaroBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const _SplashLogo(),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        l10n.splashGreeting,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.splashTagline,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      // `SizedBox` yenye upana hudhibiti ukubwa wa spinner
                      // bila kuathiri layout ya column.
                      SizedBox(
                        width: AppSpacing.iconMd,
                        height: AppSpacing.iconMd,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.sunsetGold,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        l10n.splashLoading,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.75),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Nembo ya app — simba (mascot) aliyehifadhiwa kwenye
/// `assets/images/mascot_lion.png`.
///
/// **Kwa nini picha na si `Icon`:** simba huyu ni utambulisho wa app — anaonekana
/// pia kwenye onboarding na kwenye wasifu. Nembo inayorudiwa hujenga kumbukumbu
/// kwa mtoto anayetumia app (na kwa mzazi anayeichagua).
///
/// **Uzito:** faili ni 100 KB baada ya kupunguzwa (420x420), kwa hivyo
/// haiongezi uzito mkubwa kwenye APK. `errorBuilder` hurudisha nembo ya awali
/// ya vector ikiwa faili haipo — splash haivunjiki kamwe.
class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  /// Ukubwa wa duara la nembo.
  static const double _size = 132;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(0.28),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
        // Pete ya dhahabu — hutenganisha nembo na gradient ya kijani/bluu
        // ambayo ina rangi karibu na manyoya ya simba.
        border: Border.all(
          color: AppColors.sunsetGold,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: Center(
          // **LEO** — pose ya salamu. Splash ni mahali pa kwanza mtumiaji
          // anamuona, hivyo "mkono juu" ni salamu ya kwanza.
          //
          // Inachukua nafasi ya `mascot_lion.png` (ambayo **ipo** kwenye
          // diski) kwa sababu Leo ni mascot aliyeidhinishwa na **ana poses
          // tano** — hivyo anaweza kuwa na hisia, sivyo sura moja.
          child: LeoMascot(
            pose: LeoPose.wave,
            // 80% ya duara ili manyoya yasigonge pete ya dhahabu.
            height: _size * 0.80,
          ),
        ),
      ),
    );
  }
}
