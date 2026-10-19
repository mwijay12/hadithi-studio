/// Mtiririko wa kuwakaribisha watumiaji wapya (onboarding).
///
/// Skrini nne, kila moja ikieleza thamani moja ya app: kusoma, kusikiliza,
/// kutengeneza, na kuchagua lugha. Slide ya mwisho inakusanya **lugha** —
/// chaguo la kwanza la mtumiaji na linaloathiri kila kitu kinachofuata.
///
/// **Muundo wa macho (visual):** skrini hii ina tabaka nne:
///
/// 1. **Mandhari inayotembea** ([_AnimatedBackdrop]) — gradient laini pamoja
///    na madoa matatu ya rangi yanayoelea polepole. Rangi hubadilika
///    kulingana na slide, kwa hivyo skrini haionekani tuli.
/// 2. **Mchoro usio na background** — picha zilizo kwenye
///    `assets/images/onboarding/` zina background ya **wazi (transparent)**,
///    kwa hivyo zinaelea juu ya mandhari badala ya kukaa ndani ya kisanduku
///    cheupe. Mchoro unaingia kwa fade + kupanda, kisha unaendelea kuelea
///    na kuzunguka kidogo.
/// 3. **Nyota zinazong'aa** ([_Sparkles]) kuzunguka mchoro — huongeza
///    uhai bila kuongeza kelele.
/// 4. **Nakala ya maandishi** — beji, kichwa, maelezo, vidonge vya
///    vipengele (feature pills) na (kwenye slide ya mwisho) kichaguzi cha
///    lugha. Kila kipengele kinaingia kwa mpangilio (staggered).
///
/// **Lugha:** chips za lugha **zinabadilisha app nzima papo hapo** kwa
/// kutumia [AppLocaleController]. Hapo awali chips zilibadilisha tu hali ya
/// ndani ya skrini hii, kwa hivyo mtumiaji aliyechagua Kiswahili
/// alikuwa akiendelea kuona Kiingereza — hiyo ilikuwa hitilafu iliyoripotiwa.
///
/// **Hali (state):** `StatefulWidget` yenye `setState`. Hii ni ya makusudi
/// kwa hatua hii: skrini haina mawasiliano ya mtandao wala hifadhi, kwa
/// hivyo `Cubit` ingeongeza faili tatu bila faida ya mtihani.
/// TODO(onboarding): hamishia hadi `OnboardingCubit` pindi kuhifadhi chaguo
/// kwenye `LocalStorage` (`StorageKeys.onboardingComplete`) na
/// `ageGroup`/`interests` zitakapoongezwa.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../config/theme/colors.dart';
import '../../../../config/theme/spacing.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/services/library_store.dart';
import '../../../../l10n/app_locale_controller.dart';
import '../../../../l10n/l10n.dart';

/// Kurasa ya kuwakaribisha.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();

  /// Kielekezi cha ukurasa wa sasa — hutumika kwa dots, progress bar,
  /// mandhari na maandishi ya kitufe kikuu.
  int _index = 0;

  /// Jumla ya slides.
  static const int _slideCount = 4;

  /// Rangi ya kila slide — huamua mandhari, mwanga na progress bar.
  static const List<Color> _accents = <Color>[
    AppColors.safariGreen,
    AppColors.kilimanjaroBlue,
    AppColors.kangaOrange,
    AppColors.purpleFun,
  ];

  /// Mchoro wa kila slide — uwiano wa 3:2, background ya wazi (transparent).
  static const List<String> _illustrations = <String>[
    'assets/images/onboarding/onboarding_read.png',
    'assets/images/onboarding/onboarding_listen.png',
    'assets/images/onboarding/onboarding_create.png',
    'assets/images/onboarding/onboarding_language.png',
  ];

  /// Rangi za akiba ikiwa picha haipatikani (`errorBuilder`).
  static const List<List<Color>> _fallbackGradients = <List<Color>>[
    <Color>[AppColors.safariGreen, AppColors.brightGreen],
    <Color>[AppColors.kilimanjaroBlue, AppColors.skyBlue],
    <Color>[AppColors.kangaOrange, AppColors.playfulYellow],
    <Color>[AppColors.purpleFun, AppColors.zanzibarTurquoise],
  ];

  static const List<IconData> _fallbackIcons = <IconData>[
    Icons.auto_stories_rounded,
    Icons.headphones_rounded,
    Icons.auto_awesome_rounded,
    Icons.translate_rounded,
  ];

  Color get _accent => _accents[_index];

  /// Chaguo la lugha kama namba (0 = Kiswahili, 1 = Kiingereza, 2 = Zote).
  ///
  /// Tunaisoma **moja kwa moja** kutoka [AppLocaleController] badala ya
  /// kuhifadhi nakala yake hapa: chanzo kimoja cha ukweli. Kama tungeshika
  /// nakala, skrini ya settings na onboarding zingeweza kutofautiana.
  int get _selectedLanguage {
    final AppLanguage language = AppLocaleController.instance.language;
    if (language == AppLanguage.english) {
      return 1;
    }
    if (language == AppLanguage.bilingual) {
      return 2;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    // `AppLocaleController` inabadilika pia kutoka skrini nyingine (mfano
    // Settings). Kusikiliza hapa kunahakikisha chips na mandhari
    // zinabadilika mara moja, bila kutegemea kwamba router itajengwa upya.
    AppLocaleController.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    AppLocaleController.instance.removeListener(_onLocaleChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _isLastSlide => _index == _slideCount - 1;

  /// Hubadilisha lugha ya app nzima (Kiswahili / Kiingereza / Zote mbili).
  void _selectLanguage(AppLanguage language) {
    HapticFeedback.selectionClick();
    AppLocaleController.instance.use(language);
  }

  /// Huenda slide inayofuata, au humaliza mtiririko kwenye slide ya mwisho.
  void _next() {
    HapticFeedback.lightImpact();
    if (_isLastSlide) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: AppSpacing.normal,
      curve: Curves.easeOutCubic,
    );
  }

  /// Huruka hadi slide fulani — dots zinagusa.
  void _goTo(int index) {
    if (index == _index) {
      return;
    }
    HapticFeedback.selectionClick();
    _controller.animateToPage(
      index,
      duration: AppSpacing.normal,
      curve: Curves.easeOutCubic,
    );
  }

  /// Humaliza onboarding na kuingia shell.
  ///
  /// Chaguo la lugha **limeshahifadhiwa** kwenye [AppLocaleController]
  /// (papo hapo mtumiaji alipogusa chipu). Kinachobaki ni kuhifadhi kwenye
  /// kifaa ili kitumike baada ya kufunga app.
  ///
  /// Huhifadhi kwamba onboarding imemalizika, kisha kuingia shell.
  ///
  /// **C10 ilikuwa hapa:** kazi hii ilifanya `context.go(home)` pekee, bila
  /// kuandika kitu. Splash ilirudi kwenye onboarding kila kufungua app.
  /// Sasa tunaandika kwa [LibraryStore] **kabla** ya kuondoka, ili hali
  /// isipotee hata kama mtumiaji atafunga app mara moja.
  ///
  /// Lugha imeshahifadhiwa na [AppLocaleController] alipogusa chipu.
  void _finish() {
    // `unawaited` ni sahihi hapa: uandishi ni wa haraka na hauwezi kushindwa
    // kwa njia inayozuia urambazaji (faili hilo hufunga makosa yote).
    unawaited(LibraryStore.instance.completeOnboarding());
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          // Tabaka la 1: mandhari inayotembea.
          Positioned.fill(child: _AnimatedBackdrop(accent: _accent)),
          SafeArea(
            child: Column(
              children: <Widget>[
                _Header(l10n: l10n, onSkip: _finish),
                _ProgressStrip(
                  index: _index,
                  count: _slideCount,
                  accent: _accent,
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slideCount,
                    onPageChanged: (int index) {
                      HapticFeedback.selectionClick();
                      setState(() => _index = index);
                    },
                    itemBuilder: (BuildContext context, int index) {
                      return _OnboardingSlide(
                        // Funguo kwa index huhakikisha kila slide inapata
                        // hali yake mwenyewe ya uhuishaji.
                        key: ValueKey<int>(index),
                        index: index,
                        // Slide inayojengwa mbele ya wakati haipaswi
                        // kuhuisha — tunaanza tu inapoonekana.
                        active: index == _index,
                        showLanguagePicker: index == _slideCount - 1,
                        selectedLanguage: _selectedLanguage,
                        accent: _accents[index],
                        asset: _illustrations[index],
                        fallbackGradient: _fallbackGradients[index],
                        fallbackIcon: _fallbackIcons[index],
                        onLanguageChanged: (int value) {
                          _selectLanguage(_languageFromIndex(value));
                        },
                      );
                    },
                  ),
                ),
                _DotsIndicator(
                  count: _slideCount,
                  activeIndex: _index,
                  accent: _accent,
                  onDotTap: _goTo,
                ),
                _BottomActions(
                  l10n: l10n,
                  showBack: _index > 0,
                  isLastSlide: _isLastSlide,
                  accent: _accent,
                  onBack: () {
                    HapticFeedback.selectionClick();
                    _controller.previousPage(
                      duration: AppSpacing.normal,
                      curve: Curves.easeOutCubic,
                    );
                  },
                  onNext: _next,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hubadilisha namba ya chipu (0/1/2) kuwa [AppLanguage].
  static AppLanguage _languageFromIndex(int value) {
    switch (value) {
      case 1:
        return AppLanguage.english;
      default:
        return AppLanguage.swahili;
    }
  }
}

// ---------------------------------------------------------------------------
// TABAKA LA 1 — MANDHARI INAYOTEMBEA
// ---------------------------------------------------------------------------

/// Mandhari ya nyuma: gradient laini + madoa matatu yanayoelea.
///
/// Madoa ni miduara yenye `RadialGradient` inayokwenda hadi `opacity = 0`
/// kwenye ukingo — hakuna mpaka mkali, kwa hivyo yanaonekana kama mwanga
/// usiofaa kufuatiliwa kwa macho (soft aurora). Mwendo ni wa polepole sana
/// (dakika 0.2 kwa mzunguko mmoja) ili usivute fikira kutoka maudhui.
class _AnimatedBackdrop extends StatefulWidget {
  const _AnimatedBackdrop({required this.accent});

  /// Rangi ya slide ya sasa — hubadilika kwa `TweenAnimationBuilder`.
  final Color accent;

  @override
  State<_AnimatedBackdrop> createState() => _AnimatedBackdropState();
}

class _AnimatedBackdropState extends State<_AnimatedBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Rangi ya mandhari inabadilika kwa upole slide inapobadilika —
    // `TweenAnimationBuilder<Color?>` haihitaji controller ya tatu.
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(end: widget.accent),
      duration: AppSpacing.slow,
      builder: (BuildContext context, Color? animated, Widget? child) {
        final Color accent = animated ?? widget.accent;
        return AnimatedBuilder(
          animation: _motion,
          builder: (BuildContext context, Widget? _) {
            final double t = _motion.value * 2 * math.pi;
            return Stack(
              children: <Widget>[
                // Msingi: karatasi nyeupe yenye tinti hafifu ya rangi.
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          AppColors.background,
                          Color.lerp(
                            AppColors.background,
                            accent,
                            0.10,
                          )!,
                        ],
                      ),
                    ),
                  ),
                ),
                // Madoa matatu yenye awamu tofauti.
                _blob(
                  accent,
                  alignment: Alignment(
                    -0.95 + 0.06 * math.sin(t),
                    -0.92 + 0.05 * math.cos(t),
                  ),
                  diameter: 260,
                  opacity: 0.20,
                ),
                _blob(
                  accent,
                  alignment: Alignment(
                    1.02 + 0.05 * math.cos(t * 0.8),
                    -0.48 + 0.06 * math.sin(t * 0.9),
                  ),
                  diameter: 200,
                  opacity: 0.16,
                ),
                _blob(
                  accent,
                  alignment: Alignment(
                    -0.78 + 0.05 * math.cos(t * 1.15),
                    1.02 + 0.04 * math.sin(t * 1.05),
                  ),
                  diameter: 230,
                  opacity: 0.14,
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Doa moja la rangi.
  Widget _blob(
    Color accent, {
    required Alignment alignment,
    required double diameter,
    required double opacity,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              accent.withOpacity(opacity),
              accent.withOpacity(0.0),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// KICHWA, PROGRESS NA VITUFE
// ---------------------------------------------------------------------------

/// Kichwa: utambulisho wa brand kushoto, "Ruka" kulia.
///
/// "Ruka" hukaa mahali pamoja wakati slides zinabadilika — kitu
/// kinachotembea hukera mtu anayejaribu kukigusa.
class _Header extends StatelessWidget {
  const _Header({required this.l10n, required this.onSkip});

  final AppLocalizations l10n;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        children: <Widget>[
          ClipOval(
            child: Image.asset(
              'assets/images/mascot_lion.png',
              width: AppSpacing.avatarMd,
              height: AppSpacing.avatarMd,
              fit: BoxFit.cover,
              // Simba ni mapambo hapa — jina la app linatosha kwa
              // wasomaji wa screen reader.
              excludeFromSemantics: true,
              errorBuilder: (_, __, ___) => const SizedBox(
                width: AppSpacing.avatarMd,
                height: AppSpacing.avatarMd,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  l10n.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.safariGreen,
                      ),
                ),
                Text(
                  l10n.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.mutedText,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSkip,
            child: Text(l10n.skip),
          ),
        ],
      ),
    );
  }
}

/// Mstari mwembamba unaoonyesha maendeleo kwa ujumla (si dots pekee).
///
/// Dots husema "slide ipi", mstari huu husema "tumefika wapi" — vitu
/// viwili tofauti, na wote ni muhimu kwa mtumiaji anayesoma kwa haraka.
class _ProgressStrip extends StatelessWidget {
  const _ProgressStrip({
    required this.index,
    required this.count,
    required this.accent,
  });

  final int index;
  final int count;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        0,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: (index + 1) / count),
          duration: AppSpacing.normal,
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, double value, Widget? _) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 5,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation<Color>(accent),
            );
          },
        ),
      ),
    );
  }
}

/// Safu ya vitufe: "Rudi" + kitufe kikuu.
class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.l10n,
    required this.showBack,
    required this.isLastSlide,
    required this.accent,
    required this.onBack,
    required this.onNext,
  });

  final AppLocalizations l10n;
  final bool showBack;
  final bool isLastSlide;
  final Color accent;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Row(
        children: <Widget>[
          // "Rudi" huonekana tu tunapokuwa mbele ya slide ya kwanza.
          if (showBack) ...<Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: onBack,
                child: Text(l10n.back),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            // Kitufe kikuu ni kikubwa mara mbili — ndiyo hatua tunayotaka
            // mtumiaji aichukue.
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(backgroundColor: accent),
              icon: AnimatedSwitcher(
                duration: AppSpacing.fast,
                child: Icon(
                  isLastSlide
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_forward_rounded,
                  key: ValueKey<bool>(isLastSlide),
                  size: AppSpacing.iconSm,
                ),
              ),
              label: Text(isLastSlide ? l10n.getStarted : l10n.next),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TABAKA LA 2 — SLIDE
// ---------------------------------------------------------------------------

/// Slide moja ya onboarding — ikiwa na uhuishaji.
class _OnboardingSlide extends StatefulWidget {
  const _OnboardingSlide({
    super.key,
    required this.index,
    required this.active,
    required this.showLanguagePicker,
    required this.selectedLanguage,
    required this.accent,
    required this.asset,
    required this.fallbackGradient,
    required this.fallbackIcon,
    required this.onLanguageChanged,
  });

  final int index;

  /// `true` kama slide hii ndiyo inayoonekana sasa.
  final bool active;
  final bool showLanguagePicker;
  final int selectedLanguage;
  final Color accent;
  final String asset;
  final List<Color> fallbackGradient;
  final IconData fallbackIcon;
  final ValueChanged<int> onLanguageChanged;

  @override
  State<_OnboardingSlide> createState() => _OnboardingSlideState();
}

class _OnboardingSlideState extends State<_OnboardingSlide>
    with TickerProviderStateMixin {
  /// Kuingia: fade + kupanda + kukua. Huanza [widget.active] inapokuwa true.
  late final AnimationController _entrance;

  /// Kuelea: mwendo wa polepole unaojirudia — mchoro haukai tuli.
  late final AnimationController _float;

  late final Animation<double> _rise;
  late final Animation<double> _scale;
  late final Animation<double> _drift;
  late final Animation<double> _tilt;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    );
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _rise = CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.92, end: 1.0).animate(_rise);
    _drift = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(parent: _float, curve: Curves.easeInOut),
    );
    _tilt = Tween<double>(begin: -0.014, end: 0.014).animate(
      CurvedAnimation(parent: _float, curve: Curves.easeInOut),
    );
    _syncMotion();
  }

  @override
  void didUpdateWidget(covariant _OnboardingSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _syncMotion();
    }
  }

  /// Huwasha mwendo slide inapoonekana na kuuzima inapoondoka.
  ///
  /// Hii ni muhimu kwa betri: `PageView` hujenga slides za jirani mapema,
  /// na kuhuisha zote nne kwa wakati mmoja kungechoma CPU bure.
  void _syncMotion() {
    if (widget.active) {
      _entrance.forward(from: 0);
      if (!_float.isAnimating) {
        _float.repeat(reverse: true);
      }
    } else {
      _entrance.value = 0;
      _float
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  /// Beji ya juu ya kila slide — muhtasari mmoja wa wazo.
  (IconData, String) _badge(AppLocalizations l10n) {
    switch (widget.index) {
      case 1:
        return (Icons.graphic_eq_rounded, l10n.readAloud);
      case 2:
        return (Icons.auto_awesome_rounded, l10n.createStory);
      case 3:
        return (Icons.translate_rounded, l10n.chooseLanguage);
      default:
        return (Icons.flag_rounded, l10n.createdInTanzania);
    }
  }

  /// Vidonge vitatu vya vipengele — "kuna nini ndani".
  List<(IconData, String)> _pills(AppLocalizations l10n) {
    switch (widget.index) {
      case 1:
        return <(IconData, String)>[
          (Icons.record_voice_over_rounded, l10n.ttsVoice),
          (Icons.format_size_rounded, l10n.fontSize),
          (Icons.speed_rounded, l10n.speed),
        ];
      case 2:
        return <(IconData, String)>[
          (Icons.edit_note_rounded, l10n.generateStory),
          (Icons.palette_rounded, l10n.chooseArtStyle),
          (Icons.publish_rounded, l10n.publish),
        ];
      default:
        return <(IconData, String)>[
          (Icons.menu_book_rounded, l10n.readNow),
          (Icons.headphones_rounded, l10n.listenNow),
          (Icons.download_for_offline_rounded, l10n.downloads),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;

    final List<String> titles = <String>[
      l10n.onboardingTitle1,
      l10n.onboardingTitle2,
      l10n.onboardingTitle3,
      l10n.onboardingTitle4,
    ];

    final List<String> bodies = <String>[
      l10n.onboardingBody1,
      l10n.onboardingBody2,
      l10n.onboardingBody3,
      l10n.onboardingBody4,
    ];

    final (IconData, String) badge = _badge(l10n);

    // `LayoutBuilder` + `ConstrainedBox(minHeight)` hutuwezesha kuweka
    // maudhui katikati wakati kuna nafasi ya kutosha, lakini kuruhusu
    // scroll kwenye skrini ndogo au kwa watumiaji wanaokuzwa maandishi
    // (accessibility text scaling).
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // --- Mchoro ---
                _FadeUp(
                  progress: _entrance,
                  begin: 0.0,
                  end: 0.55,
                  child: Transform.scale(
                    scale: _scale.value,
                    child: _IllustrationStage(
                      asset: widget.asset,
                      accent: widget.accent,
                      fallbackGradient: widget.fallbackGradient,
                      fallbackIcon: widget.fallbackIcon,
                      drift: _drift,
                      tilt: _tilt,
                      // Mchoro ni wa mapambo kwa screen reader; kichwa cha
                      // slide kinasema wazo hilo hilo kwa maneno.
                      semanticLabel: titles[widget.index],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // --- Beji ---
                _FadeUp(
                  progress: _entrance,
                  begin: 0.20,
                  end: 0.68,
                  child: _SlideBadge(
                    icon: badge.$1,
                    label: badge.$2,
                    accent: widget.accent,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // --- Kichwa ---
                _FadeUp(
                  progress: _entrance,
                  begin: 0.28,
                  end: 0.76,
                  child: Text(
                    titles[widget.index],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkText,
                        ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // --- Maelezo ---
                _FadeUp(
                  progress: _entrance,
                  begin: 0.36,
                  end: 0.86,
                  child: Text(
                    bodies[widget.index],
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.mutedText,
                        ),
                  ),
                ),
                // --- Vidonge vya vipengele ---
                //
                // Slide ya mwisho haipati vidonge: kichaguzi cha lugha
                // kinachukua nafasi hiyo, na kuongeza vyote viwili
                // kungefanya slide inyooshe sana.
                if (!widget.showLanguagePicker) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  _FadeUp(
                    progress: _entrance,
                    begin: 0.44,
                    end: 0.96,
                    child: _FeaturePills(
                      pills: _pills(l10n),
                      accent: widget.accent,
                    ),
                  ),
                ],
                // --- Kichaguzi cha lugha ---
                if (widget.showLanguagePicker) ...<Widget>[
                  const SizedBox(height: AppSpacing.lg),
                  _FadeUp(
                    progress: _entrance,
                    begin: 0.40,
                    end: 0.92,
                    child: Column(
                      children: <Widget>[
                        Text(
                          l10n.chooseLanguage,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          l10n.chooseLanguageSubtitle,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.mutedText,
                                  ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Chips MBILI: Kiswahili, Kiingereza.
                        // "Lugha Zote" imeondolewa — mtumiaji achague lugha
                        // moja waziwazi; kubadilisha baadaye kuko Settings.
                        // Kila chipu ni kubwa vya kutosha kuguswa
                        // (`AppSpacing.minTouchTarget`).
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          alignment: WrapAlignment.center,
                          children: <Widget>[
                            _LanguageChip(
                              label: l10n.swahili,
                              selected: widget.selectedLanguage == 0,
                              accent: widget.accent,
                              onTap: () => widget.onLanguageChanged(0),
                            ),
                            _LanguageChip(
                              label: l10n.english,
                              selected: widget.selectedLanguage == 1,
                              accent: widget.accent,
                              onTap: () => widget.onLanguageChanged(1),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// TABAKA LA 3 — MCHORO
// ---------------------------------------------------------------------------

/// Eneo la mchoro: mwanga, kivuli laini chini, mchoro unaoelea, na nyota.
///
/// **Kwa nini hakuna kisanduku cheupe tena:** picha zina background ya
/// **wazi (transparent)**. Kisanduku cheupe kilikuwa kikifunika ukurasa
/// mzima kama kadi; sasa mchoro unaelea moja kwa moja juu ya mandhari,
/// ambao ndiyo unaofanya skrini ionekane hai badala ya "boring".
class _IllustrationStage extends StatelessWidget {
  const _IllustrationStage({
    required this.asset,
    required this.accent,
    required this.fallbackGradient,
    required this.fallbackIcon,
    required this.drift,
    required this.tilt,
    required this.semanticLabel,
  });

  final String asset;
  final Color accent;
  final List<Color> fallbackGradient;
  final IconData fallbackIcon;

  /// Mwendo wa juu-chini (kuelea).
  final Animation<double> drift;

  /// Mzunguko mdogo sana — huondoa hisia ya picha iliyokwama.
  final Animation<double> tilt;

  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: AspectRatio(
        aspectRatio: 3 / 2,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            // Mwanga laini unaotoka nyuma ya mchoro — huunganisha picha
            // (iliyo na background ya wazi) na mandhari.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.72,
                    colors: <Color>[
                      accent.withOpacity(0.24),
                      accent.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
            // Kivuli laini chini — hufanya mchoro "ukae" badala ya kuelea
            // bila msaada wowote (muhimu hasa kwa picha zenye background
            // ya wazi).
            Positioned(
              bottom: AppSpacing.sm,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 210,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    gradient: RadialGradient(
                      colors: <Color>[
                        Colors.black.withOpacity(0.14),
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Nyota zinazong'aa kuzunguka mchoro.
            Positioned.fill(child: _Sparkles(accent: accent)),
            // Mchoro wenyewe.
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: AnimatedBuilder(
                animation: Listenable.merge(<Listenable>[drift, tilt]),
                builder: (BuildContext context, Widget? child) {
                  return Transform.translate(
                    offset: Offset(0, drift.value),
                    child: Transform.rotate(angle: tilt.value, child: child),
                  );
                },
                child: Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  semanticLabel: semanticLabel,
                  // Picha haipo? Rudisha kisanduku cha rangi kilichokuwa
                  // hapo awali. Skrini inaendelea kufanya kazi.
                  errorBuilder: (_, __, ___) => DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: fallbackGradient,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Center(
                      child: Icon(
                        fallbackIcon,
                        size: AppSpacing.iconXl,
                        color: Colors.white.withOpacity(0.95),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Nyota ndogo zinazong'aa kuzunguka mchoro.
///
/// Kila nyota ina awamu (phase) yake, kwa hivyo haziang'ae zote kwa pamoja
/// — mwendo wa pamoja unaonekana kama kufumba na kufumbua kwa taa.
class _Sparkles extends StatefulWidget {
  const _Sparkles({required this.accent});

  final Color accent;

  @override
  State<_Sparkles> createState() => _SparklesState();
}

class _SparklesState extends State<_Sparkles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  /// Mahali pa kila nyota — nje kidogo ya mchoro ili zisionekane kama
  /// uchafu juu ya picha.
  static const List<Alignment> _spots = <Alignment>[
    Alignment(-1.06, -0.78),
    Alignment(1.02, -0.52),
    Alignment(-0.92, 0.72),
    Alignment(0.96, 0.80),
    Alignment(0.10, -1.04),
  ];

  static const List<IconData> _icons = <IconData>[
    Icons.star_rounded,
    Icons.auto_awesome_rounded,
    Icons.star_rounded,
    Icons.auto_awesome_rounded,
    Icons.circle,
  ];

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (BuildContext context, Widget? _) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: List<Widget>.generate(_spots.length, (int i) {
              // Awamu: kila nyota iko mbali na nyingine kwa 1/n ya mzunguko.
              final double t = (_pulse.value + i / _spots.length) % 1.0;
              // Pembetatu 0 → 1 → 0.
              final double glow = 1 - (2 * t - 1).abs();
              return Align(
                alignment: _spots[i],
                child: Opacity(
                  opacity: 0.20 + 0.60 * glow,
                  child: Icon(
                    _icons[i],
                    size: 9 + 9 * glow,
                    color: i.isEven ? widget.accent : AppColors.sunsetGold,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ELEMENTI NDOGO ZA MAANDISHI
// ---------------------------------------------------------------------------

/// Huingiza mtoto kwa fade + kupanda, kwa muda uliopangwa.
///
/// `begin`/`end` ni sehemu ya muda wa `progress` (0.0–1.0). Kutumia muda
/// tofauti kwa kila kipengele hufanya maandishi kuonekana kama yanajipanga
/// wenyewe badala ya kuibuka yote kwa pamoja.
class _FadeUp extends StatelessWidget {
  const _FadeUp({
    required this.progress,
    required this.begin,
    required this.end,
    required this.child,
  });

  final Animation<double> progress;
  final double begin;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (BuildContext context, Widget? c) {
        final double raw =
            ((progress.value - begin) / (end - begin)).clamp(0.0, 1.0);
        final double curved = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - curved)),
            child: c,
          ),
        );
      },
      child: child,
    );
  }
}

/// Beji ya juu ya slide — ikoni + kiini cha wazo kwa maneno mafupi.
class _SlideBadge extends StatelessWidget {
  const _SlideBadge({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(color: accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppSpacing.iconSm, color: accent),
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Safu ya vidonge vya vipengele — ikoni + jina la kipengele.
class _FeaturePills extends StatelessWidget {
  const _FeaturePills({required this.pills, required this.accent});

  final List<(IconData, String)> pills;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: pills
          .map(
            ((IconData, String) pill) => _FeaturePill(
              icon: pill.$1,
              label: pill.$2,
              accent: accent,
            ),
          )
          .toList(),
    );
  }
}

/// Kidonge kimoja cha kipengele.
class _FeaturePill extends StatelessWidget {
  const _FeaturePill({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 148),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.09),
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppSpacing.iconSm, color: accent),
          const SizedBox(width: AppSpacing.xs + 2),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chipu ya kuchagua lugha.
class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: AnimatedContainer(
        duration: AppSpacing.fast,
        constraints: const BoxConstraints(
          minHeight: AppSpacing.minTouchTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? accent : accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          border: Border.all(
            color: selected ? accent : accent.withOpacity(0.30),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: selected ? Colors.white : accent,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

/// Dots zinazoonyesha ukurasa wa sasa.
///
/// Dots zinaweza kuguswa: kuruka slide moja ni haraka kuliko kupitia
/// zote, na hiyo hupunguza idadi ya watumiaji wanaobonyeza "Ruka" kwa
/// kukosa uvumilivu.
class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({
    required this.count,
    required this.activeIndex,
    required this.accent,
    required this.onDotTap,
  });

  final int count;
  final int activeIndex;
  final Color accent;
  final ValueChanged<int> onDotTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool active = index == activeIndex;
        return Semantics(
          button: true,
          selected: active,
          label: '${index + 1}/$count',
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onDotTap(index),
            child: Container(
              // Eneo la kugusa linatosha hata kama dot yenyewe ni ndogo.
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: AppSpacing.md,
              ),
              child: AnimatedContainer(
                duration: AppSpacing.fast,
                // Dot hai ni pana zaidi — huonyesha mwelekeo, si rangi
                // pekee (muhimu kwa watumiaji wasioona rangi vizuri).
                width: active ? AppSpacing.xxl : AppSpacing.sm,
                height: AppSpacing.sm,
                decoration: BoxDecoration(
                  color:
                      active ? accent : AppColors.mutedText.withOpacity(0.30),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
