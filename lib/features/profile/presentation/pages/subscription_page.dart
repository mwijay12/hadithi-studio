/// **USAJILI** — ukurasa unaoeleza mpango wa malipo **bila kuuza kitu**.
///
/// ## Kwa nini ukurasa huu ni wa uaminifu kiasi hiki
///
/// Kadi ya "Jiandikishe" kwenye tab ya Wasifu ilikuwa **haigusi**. Wakati huo
/// huo, hakuna malipo yaliyowekwa: hakuna M-Pesa, Tigo Pesa, Airtel Money,
/// wala backend ya malipo. Kufungua ukurasa unaoonyesha "Jiandikishe sasa"
/// na bei ya kubuni ni **data ya uongo** — mtumiaji anaweza kujaribu kulipa
/// na kukuta hakuna kinachotokea, au aamini amejiandikisha kumbe hakuna.
///
/// Kwa hivyo ukurasa huu:
/// * **hauonyeshi bei** wala ngazi za mpango — `[Bei]` / `[Price]` ni
///   kishika-nafasi wazi, sivyo namba ya kubuni,
/// * **hauna kitufe cha "Jiandikishe sasa"**,
/// * unaeleza wazi kwamba malipo **hayajatekelezwa** kwenye build hii,
/// * unatoa **kitendo kimoja halisi**: switch ya "Nijulishe" inayohifadhiwa
///   kwenye kifaa kwa ufunguo `hadithi_notify_launch`.
///
/// ## Kwa nini switch, na si "pre-order"
///
/// Switch ni ahadi ndogo tunayoweza kuitimiza: tunakumbuka chaguo la mtumiaji
/// kwenye kifaa hiki. Hatuwezi kutuma email (hakuna akaunti, hakuna seva),
/// hivyo maandishi yanasema hivyo waziwazi.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/leo_mascot.dart';
// `localised(...)` ni nyongeza ya `L10nX` iliyo kwenye faili hili, sivyo
// `ContextX` — kwa hivyo import hii ni ya lazima (sivyo hiari).
import '../../../../l10n/l10n.dart';
import '../widgets/profile_notice_card.dart';

/// Ufunguo wa hifadhi ya chaguo la "Nijulishe".
///
/// Umewekwa hapa (sivyo kwenye `LibraryStore`) kwa sababu ni mapendeleo ya
/// ukurasa huu pekee; hakuna sehemu nyingine ya app inayoyasoma. Jina
/// linaanza na `hadithi_` ili lisigongane na funguo nyingine za kivinjari.
const String kNotifyLaunchKey = 'hadithi_notify_launch';

/// Ukurasa wa maelezo ya usajili (bila malipo).
class SubscriptionPage extends StatefulWidget {
  /// Huunda ukurasa.
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  /// Hali ya switch. Huanza `false` hadi hifadhi isomwe.
  bool _notify = false;

  /// `true` wakati thamani ya awali inasomwa — switch isigusable kabla
  /// hatujui thamani halisi (vinginevyo ingeonyesha `false` ya uongo).
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotify();
  }

  /// Husoma chaguo lililohifadhiwa.
  Future<void> _loadNotify() async {
    bool stored = false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      stored = prefs.getBool(kNotifyLaunchKey) ?? false;
    } catch (error) {
      // Hifadhi isipopatikana (kivinjari kilichozima localStorage), tunaendelea
      // na `false`. Ukurasa haupaswi kuanguka kwa sababu ya mapendeleo.
      debugPrint('SubscriptionPage: kusoma mapendeleo kimeshindwa — $error');
    }
    if (!mounted) return;
    setState(() {
      _notify = stored;
      _loading = false;
    });
  }

  /// Hubadilisha na kuhifadhi chaguo la "Nijulishe".
  ///
  /// Tunaweka UI mara moja (optimistic) kisha tunathibitisha kwa hifadhi;
  /// ikishindikana, tunarudisha thamani ya awali na kumwambia mtumiaji.
  /// Bila kurudisha, switch ingesema "imehifadhiwa" kumbe hapana.
  Future<void> _setNotify(bool value) async {
    final bool previous = _notify;
    setState(() => _notify = value);

    bool saved = false;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      saved = await prefs.setBool(kNotifyLaunchKey, value);
    } catch (error) {
      debugPrint('SubscriptionPage: kuhifadhi mapendeleo kimeshindwa — $error');
      saved = false;
    }

    if (!mounted) return;
    if (!saved) {
      setState(() => _notify = previous);
      context.showSnackBar(
        context.localised(
          swahili: 'Mapendeleo hayakuhifadhiwa. Jaribu tena.',
          english: 'The preference was not saved. Please try again.',
        ),
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool swahili = context.isSwahili;

    return Scaffold(
      // Rangi hutoka theme — `AppColors.background` (cream) ingesababisha
      // maandishi ya theme kuwa meupe juu ya cream kwenye dark mode.
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        title: Text(
          context.localised(swahili: 'Usajili', english: 'Subscription'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: context.localised(swahili: 'Rudi', english: 'Back'),
        ),
      ),
      body: ListView(
        // Kila kitu kinasogea: kwenye 320dp kuna sehemu nyingi, na
        // `Column` isiyosogea ingeoverflow.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: <Widget>[
          // Leo anapunga mkono — mwaliko wa kusoma, sivyo mauzo.
          const Center(
            child: LeoMascot(pose: LeoPose.wave, height: 120),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  context.localised(
                    swahili: 'Mpango wa malipo',
                    english: 'Paid plan',
                  ),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const _ComingBadge(),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.localised(
              swahili: 'Bado haujazinduliwa. Kila kilicho hapa ni mpango, '
                  'sivyo kitu kinachoweza kununuliwa leo.',
              english: 'Not launched yet. Everything here is a plan, not '
                  'something you can buy today.',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // -----------------------------------------------------------------
          // Ukweli kuhusu malipo — kwanza kabisa, sivyo mwisho
          // -----------------------------------------------------------------
          ProfileNoticeCard(
            icon: Icons.payments_rounded,
            tone: ProfileNoticeTone.warning,
            title: context.localised(
              swahili: 'Malipo hayajatekelezwa',
              english: 'Payments are not implemented',
            ),
            message: context.localised(
              swahili: 'Malipo kwa M-Pesa, Tigo Pesa au Airtel Money '
                  'hayajawekwa kwenye build hii. Hakuna malipo yanayoweza '
                  'kufanywa, na hakuna pesa itakayotolewa kwenye simu yako '
                  'kwa njia ya app hii. Ukiona ukurasa huu, hicho ndicho '
                  'kinachofanya kazi kwa sasa: maelezo pekee.',
              english: 'M-Pesa, Tigo Pesa and Airtel Money checkout is not '
                  'implemented in this build. No payment can be made, and no '
                  'money will be taken from your phone through this app. What '
                  'works here today is the information on this page only.',
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // -----------------------------------------------------------------
          // Nini kitakachokuwa ndani
          // -----------------------------------------------------------------
          _SectionTitle(
            title: context.localised(
              swahili: 'Nini kitakachokuwemo',
              english: 'What it will include',
            ),
          ),
          Text(
            context.localised(
              swahili: 'Kila kipengele hapa ni cha baadaye — hakuna '
                  'kinachofanya kazi bado.',
              english: 'Every item here is for later — none of it works yet.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          for (final _PlanItem item in _planItems(swahili))
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PlanRow(item: item),
            ),
          const SizedBox(height: AppSpacing.xxl),

          // -----------------------------------------------------------------
          // Bei — kishika-nafasi, sivyo namba ya kubuni
          // -----------------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.30),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.localised(swahili: 'Bei', english: 'Price'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  // Kishika-nafasi cha wazi. Hatubuni "TZS 5,000 kwa mwezi":
                  // bei halisi haijaamuliwa, na namba ya kubuni ingeonekana
                  // kama ahadi kwa mzazi.
                  context.localised(swahili: '[Bei]', english: '[Price]'),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  context.localised(
                    swahili: 'Bei na njia za malipo hazijawekwa. Zitaonyeshwa '
                        'hapa kabla ya kuzindua — hatutoi namba ambayo '
                        'haijaidhinishwa.',
                    english: 'Pricing and payment options are not set. They '
                        'will appear here before launch — we do not publish a '
                        'number that has not been approved.',
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // -----------------------------------------------------------------
          // Data yako
          // -----------------------------------------------------------------
          _SectionTitle(
            title: context.localised(
              swahili: 'Data yako iko wapi?',
              english: 'Where is your data?',
            ),
          ),
          ProfileNoticeCard(
            icon: Icons.phone_android_rounded,
            title: context.localised(
              swahili: 'Kwenye kifaa chako pekee',
              english: 'On your device only',
            ),
            message: context.localised(
              swahili: 'Hakuna akaunti na hakuna seva ya Hadithi Studio. '
                  'Wasifu wa mtoto, hadithi ulizohifadhi na maendeleo ya '
                  'kusoma vyote viko kwenye kifaa hiki. Hakuna kinachotumwa '
                  'kwa mtengenezaji, na hakuna mtu mwingine anayekiona.',
              english: 'There is no account and no Hadithi Studio server. The '
                  'child profile, saved stories and reading progress all live '
                  'on this device. Nothing is sent to the developer, and no '
                  'one else can see it.',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // -----------------------------------------------------------------
          // Kitendo kimoja halisi: Nijulishe
          // -----------------------------------------------------------------
          _SectionTitle(
            title: context.localised(
              swahili: 'Nijulishe',
              english: 'Notify me',
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.30),
              borderRadius: AppSpacing.borderRadiusMd,
              border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
            ),
            child: SwitchListTile(
              value: _notify,
              // `_loading` → `null` huzima switch hadi thamani halisi isomwe.
              onChanged: _loading ? null : _setNotify,
              // `SwitchListTile` hushughulikia semantiki (jina + hali) kwa
              // screen reader — kwa hivyo hatuandiki `Semantics` ya mkono.
              title: Text(
                context.localised(
                  swahili: 'Nijulishe mpango huu unapopatikana',
                  english: 'Tell me when this plan is available',
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              subtitle: Text(
                context.localised(
                  swahili: 'Huu ni mapendeleo yaliyohifadhiwa kwenye kifaa '
                      'hiki; yataanza kutumika pale huduma itakapopatikana. '
                      'Kwa sasa hakuna arifa itakayotumwa — hakuna seva '
                      'inayoweza kuzituma.',
                  english: 'This is a preference saved on this device; it will '
                      'take effect when the service is available. No '
                      'notification will be sent for now — there is no server '
                      'to send one.',
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              secondary: Icon(
                Icons.notifications_none_rounded,
                color: scheme.onSurfaceVariant,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.localised(
              swahili: 'Badilisha chaguo hili wakati wowote. Kikifutwa, '
                  'hakuna kinachobaki.',
              english: 'You can change this at any time. If cleared, nothing '
                  'is kept.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Vipengele vinavyopangwa, vikiwa tayari kwa lugha ya sasa.
  ///
  /// Hii ni orodha ya **mpango**, sivyo ya kile kilichopo — kila kipengele
  /// kinaonyeshwa na beji ya "Inakuja" kwenye [_PlanRow].
  List<_PlanItem> _planItems(bool swahili) {
    return <_PlanItem>[
      _PlanItem(
        icon: Icons.auto_stories_rounded,
        title: swahili ? 'Hadithi zote, bila kikomo' : 'All stories, unlimited',
        detail: swahili
            ? 'Maktaba kamili pamoja na hadithi mpya zinazoongezwa.'
            : 'The full library, including new stories as they are added.',
      ),
      _PlanItem(
        icon: Icons.download_for_offline_rounded,
        title: swahili
            ? 'Upakuaji wa offline bila kikomo'
            : 'Unlimited offline downloads',
        detail: swahili
            ? 'Hadithi zote zinaweza kuhifadhiwa kwenye kifaa kwa kusoma bila internet.'
            : 'Save any story on the device to read without internet.',
      ),
      _PlanItem(
        icon: Icons.record_voice_over_rounded,
        title: swahili
            ? 'Sauti kamili ya Kiswahili'
            : 'Full Swahili narration',
        detail: swahili
            ? 'Kila hadithi inasomwa kwa sauti, sivyo baadhi pekee.'
            : 'Every story read aloud, not just some of them.',
      ),
      _PlanItem(
        icon: Icons.family_restroom_rounded,
        title: swahili ? 'Wasifu wa familia' : 'Family profiles',
        detail: swahili
            ? 'Watoto kadhaa kwenye kifaa kimoja. Hii inahitaji akaunti, ambayo haipo bado.'
            : 'Several children on one device. This needs an account, which does not exist yet.',
      ),
    ];
  }
}

/// Kipengele kimoja cha mpango unaokuja.
@immutable
class _PlanItem {
  const _PlanItem({
    required this.icon,
    required this.title,
    required this.detail,
  });

  /// Aikoni ya kipengele.
  final IconData icon;

  /// Jina la kipengele.
  final String title;

  /// Maelezo mafupi.
  final String detail;
}

/// Safu moja ya kipengele cha mpango.
class _PlanRow extends StatelessWidget {
  const _PlanRow({required this.item});

  final _PlanItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.22),
        borderRadius: AppSpacing.borderRadiusMd,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(item.icon, size: AppSpacing.iconMd, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  item.detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Beji ni nyembamba na maandishi yake ni madogo ili kwenye 320dp
          // jina la kipengele lisipewe nafasi ndogo mno.
          const _ComingBadge(),
        ],
      ),
    );
  }
}

/// Beji ndogo ya "Inakuja" / "Coming".
class _ComingBadge extends StatelessWidget {
  const _ComingBadge();

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.12),
        borderRadius: AppSpacing.borderRadiusPill,
      ),
      child: Text(
        context.localised(swahili: 'Inakuja', english: 'Coming'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
      ),
    );
  }
}

/// Kichwa cha sehemu ndani ya ukurasa.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      ),
    );
  }
}
