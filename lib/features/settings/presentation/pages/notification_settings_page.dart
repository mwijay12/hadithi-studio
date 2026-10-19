/// **MIPANGILIO YA ARIFA** — mapendeleo ya arifa za Hadithi Studio.
///
/// ## Uaminifu: arifa hazitumwa bado
///
/// Miundombinu ya push (FCM) **haijasanidiwa** kwenye toleo hili la app.
/// Kwa hivyo ukurasa huu HAUSEMI kuwa arifa zinafanya kazi: unahifadhi
/// mapendeleo ya mtumiaji tu na kueleza waziwazi kuwa yatatumika mara
/// miundombinu itakapowekwa. Kusema vinginevyo kungezua matumaini ya uongo
/// kwa mzazi anayesubiri kikumbusho.
///
/// ## Kwa nini `shared_preferences`, si Hive
///
/// Mapendeleo ni funguo rahisi (`bool`/`String`). `shared_preferences`
/// inafanya kazi kwenye simu **na** kwenye kivinjari, ambapo `LocalStorage`
/// (Hive) inahitaji faili za disk — hazipo kwenye preview ya web. Hii
/// inafuata muundo ule ule wa `ReadingProgressStore`.
///
/// ## Faili hili haliwezi kuangusha app
///
/// Kusoma au kuandika mapendeleo kukishindwa, tunarudi kwa chaguo-msingi
/// (`try/catch`, hakuna `throw`) — sawa na `ReadingProgressStore`. Hifadhi
/// ya mapendeleo ni mapambo, si sharti la kufungua ukurasa.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/extensions/context_extensions.dart';

/// Ukurasa wa mipangilio ya arifa.
class NotificationSettingsPage extends StatefulWidget {
  /// Huunda ukurasa.
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  /// Kiambishi cha funguo zote za arifa — hutenganisha mapendeleo haya na
  /// funguo nyingine za app kwenye `SharedPreferences` moja.
  static const String _prefix = 'hadithi_notif_';

  // Funguo za kila kuwasha/kuzima.
  static const String _keyStreak = '${_prefix}streak_reminders';
  static const String _keyNewStory = '${_prefix}new_story_alerts';
  static const String _keyWeeklyReport = '${_prefix}weekly_report';
  static const String _keyBadges = '${_prefix}badge_milestones';
  static const String _keyChallenges = '${_prefix}challenge_reminders';
  static const String _keyCommunity = '${_prefix}community_activity';
  static const String _keyPromotions = '${_prefix}promotions';
  static const String _keyPreferredTime = '${_prefix}preferred_time';

  // Thamani za muda unaopendelea (huhifadhiwa kama `String`).
  static const String _timeMorning = 'morning';
  static const String _timeAfternoon = 'afternoon';
  static const String _timeEvening = 'evening';
  static const String _timeNight = 'night';

  /// Chaguo-msingi hutumika wakati hakuna kumbukumbu **au** kusoma kimeshindwa.
  ///
  /// Jioni (`evening`) ni chaguo-msingi la muda: ni wakati wa hadithi za
  /// kulala, ambapo arifa nyingi hutumwa.
  static const Map<String, bool> _defaults = <String, bool>{
    _keyStreak: true,
    _keyNewStory: true,
    _keyWeeklyReport: true,
    _keyBadges: true,
    _keyChallenges: true,
    _keyCommunity: true,
    _keyPromotions: false,
  };

  /// Orodha ya swichi zinazochaguliwa na mtumiaji (bila risiti za malipo,
  /// ambazo hulazimishwa kuwaka).
  static const List<_ToggleSpec> _specs = <_ToggleSpec>[
    _ToggleSpec(
      key: _keyStreak,
      swahili: 'Kikumbusho cha mfululizo',
      english: 'Streak reminders',
      iconSwahili: 'Kikumbusho cha mfululizo wa kusoma',
      iconEnglish: 'Reading streak reminder',
    ),
    _ToggleSpec(
      key: _keyNewStory,
      swahili: 'Hadithi mpya',
      english: 'New story alerts',
      iconSwahili: 'Hadithi mpya inapoingia',
      iconEnglish: 'When a new story arrives',
    ),
    _ToggleSpec(
      key: _keyWeeklyReport,
      swahili: 'Ripoti ya wiki',
      english: 'Weekly report',
      iconSwahili: 'Muhtasari wa wiki',
      iconEnglish: 'Weekly summary',
    ),
    _ToggleSpec(
      key: _keyBadges,
      swahili: 'Alama za mafanikio',
      english: 'Badge milestones',
      iconSwahili: 'Alama mpya zinapopatikana',
      iconEnglish: 'When new badges are earned',
    ),
    _ToggleSpec(
      key: _keyChallenges,
      swahili: 'Kikumbusho cha changamoto',
      english: 'Challenge reminders',
      iconSwahili: 'Changamoto zinazoendelea',
      iconEnglish: 'Ongoing challenges',
    ),
    _ToggleSpec(
      key: _keyCommunity,
      swahili: 'Shughuli za jamii',
      english: 'Community activity',
      iconSwahili: 'Shughuli za wanajamii',
      iconEnglish: 'Community members activity',
    ),
    _ToggleSpec(
      key: _keyPromotions,
      swahili: 'Ofa na matangazo',
      english: 'Promotions',
      iconSwahili: 'Ofa na matangazo',
      iconEnglish: 'Offers and promotions',
    ),
  ];

  /// Orodha ya chaguo la muda unaopendelea.
  static const List<_TimeOption> _timeOptions = <_TimeOption>[
    _TimeOption(
      value: _timeMorning,
      swahili: 'Asubuhi',
      english: 'Morning',
    ),
    _TimeOption(
      value: _timeAfternoon,
      swahili: 'Mchana',
      english: 'Afternoon',
    ),
    _TimeOption(
      value: _timeEvening,
      swahili: 'Jioni',
      english: 'Evening',
    ),
    _TimeOption(
      value: _timeNight,
      swahili: 'Usiku',
      english: 'Night',
    ),
  ];

  /// Thamani za sasa za swichi — zinajazwa kutoka `_defaults` kwanza.
  final Map<String, bool> _toggles = <String, bool>{};

  /// Muda unaopendelea (chaguo-msingi: jioni).
  String _preferredTime = _timeEvening;

  /// `true` wakati mapendeleo yanasomwa — tunaonyesha spinner badala ya
  /// swichi zenye thamani isiyo sahihi kwa sekunde moja.
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Husoma mapendeleo yote; kikishindwa, hurudi kwa chaguo-msingi.
  Future<void> _load() async {
    // Anza na chaguo-msingi ili hata kabla ya kusoma, hali ni sahihi.
    _toggles.addAll(_defaults);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _defaults.forEach((String key, bool fallback) {
          _toggles[key] = prefs.getBool(key) ?? fallback;
        });
        _preferredTime =
            prefs.getString(_keyPreferredTime) ?? _timeEvening;
        _loading = false;
      });
    } catch (error) {
      // Hifadhi kushindwa si sababu ya kufunga ukurasa — chaguo-msingi
      // zilizoingizwa juu zinatosha kuendelea.
      debugPrint(
        'NotificationSettingsPage: kusoma mapendeleo kimeshindwa — $error',
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  /// Hubadilisha swichi na kuhifadhi mara moja.
  void _onToggleChanged(String key, bool value) {
    setState(() {
      _toggles[key] = value;
    });
    _saveBool(key, value);
  }

  /// Hubadilisha muda unaopendelea na kuhifadhi mara moja.
  void _onPreferredTimeChanged(String? value) {
    if (value == null) return;
    setState(() {
      _preferredTime = value;
    });
    _saveString(_keyPreferredTime, value);
  }

  /// Huhifadhi `bool` moja; kosa hupuuzwa kwa makusudi (hakuna `throw`).
  Future<void> _saveBool(String key, bool value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (error) {
      debugPrint(
        'NotificationSettingsPage: kuhifadhi mapendeleo kimeshindwa — $error',
      );
    }
  }

  /// Huhifadhi `String` moja; kosa hupuuzwa kwa makusudi (hakuna `throw`).
  Future<void> _saveString(String key, String value) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (error) {
      debugPrint(
        'NotificationSettingsPage: kuhifadhi mapendeleo kimeshindwa — $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        foregroundColor: scheme.onSurface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: context.isSwahili ? 'Rudi' : 'Back',
        ),
        title: Text(
          context.isSwahili ? 'Mipangilio ya Arifa' : 'Notification Settings',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              children: <Widget>[
                const _NoticeBox(
                  swahili: 'Arifa hazitumwa bado. Miundombinu ya arifa (push) '
                      'haijasanidiwa, kwa hivyo hutapokea arifa yoyote kwa '
                      'sasa. Mapendeleo yako yanahifadhiwa na yataanza '
                      'kutumika mara tu miundombinu itakapowekwa.',
                  english: 'Notifications cannot be delivered yet. Push '
                      'infrastructure is not configured, so you will not '
                      'receive any notifications for now. Your preferences '
                      'are saved and will take effect once it is set up.',
                ),

                const _SectionHeading(
                  swahili: 'Arifa nitakazopata',
                  english: 'Notifications I want',
                ),
                for (final _ToggleSpec spec in _specs)
                  SwitchListTile(
                    value: _toggles[spec.key] ?? false,
                    onChanged: (bool value) =>
                        _onToggleChanged(spec.key, value),
                    title: Text(
                      context.isSwahili ? spec.swahili : spec.english,
                      style: TextStyle(color: scheme.onSurface),
                    ),
                    subtitle: Text(
                      context.isSwahili ? spec.iconSwahili : spec.iconEnglish,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                // Risiti za malipo haziwezi kuzimwa: uthibitisho wa malipo ni
                // rekodi ya kifedha, si mapendeleo. Kuzimwa kungemfanya mzazi
                // asiwe na uthibitisho wa malipo aliyofanya.
                SwitchListTile(
                  value: true,
                  onChanged: null,
                  title: Text(
                    context.isSwahili ? 'Risiti za malipo' : 'Payment receipts',
                    style: TextStyle(color: scheme.onSurface),
                  ),
                  subtitle: Text(
                    context.isSwahili
                        ? 'Hazizimiki — uthibitisho wa malipo huhifadhiwa'
                        : 'Cannot be disabled — payment receipts are kept',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),

                const _SectionHeading(
                  swahili: 'Muda unaopendelea',
                  english: 'Preferred time',
                ),
                for (final _TimeOption option in _timeOptions)
                  RadioListTile<String>(
                    value: option.value,
                    groupValue: _preferredTime,
                    onChanged: _onPreferredTimeChanged,
                    title: Text(
                      context.isSwahili ? option.swahili : option.english,
                      style: TextStyle(color: scheme.onSurface),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.xs,
                  ),
                  child: Text(
                    context.isSwahili
                        ? 'Muda unatumika mara miundombinu ya arifa '
                            'itakapowekwa.'
                        : 'The time is used once push infrastructure is set up.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Maelezo ya swichi moja inayochaguliwa na mtumiaji.
class _ToggleSpec {
  const _ToggleSpec({
    required this.key,
    required this.swahili,
    required this.english,
    required this.iconSwahili,
    required this.iconEnglish,
  });

  /// Ufunguo wa `SharedPreferences`.
  final String key;

  /// Jina la swichi (Kiswahili).
  final String swahili;

  /// Jina la swichi (Kiingereza).
  final String english;

  /// Maelezo mafupi (Kiswahili).
  final String iconSwahili;

  /// Maelezo mafupi (Kiingereza).
  final String iconEnglish;
}

/// Chaguo moja la muda unaopendelea.
class _TimeOption {
  const _TimeOption({
    required this.value,
    required this.swahili,
    required this.english,
  });

  /// Thamani inayohifadhiwa.
  final String value;

  /// Jina la chaguo (Kiswahili).
  final String swahili;

  /// Jina la chaguo (Kiingereza).
  final String english;
}

/// Sanduku la tahadhari linalovutia jicho.
///
/// Tunatumia `errorContainer`/`onErrorContainer` za scheme badala ya rangi
/// zilizowekwa kwa mkono: mandhari ya usiku ingepata sehemu moja yenye
/// mwanga mkali katikati ya ukurasa mweusi.
class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.swahili, required this.english});

  final String swahili;
  final String english;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Container(
        padding: AppSpacing.card,
        // **Kwa nini si `errorContainer`:** boksi jekundu linaonekana kama
        // kosa au hatari. Hii ni taarifa ya kawaida ("arifa hazitumwa
        // bado"), sivyo kosa — rangi ya theme yenye upole inafaa zaidi na
        // haitishi mtumiaji.
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.09),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.notifications_off_rounded,
              color: scheme.onErrorContainer,
              size: AppSpacing.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.isSwahili ? swahili : english,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kichwa cha sehemu.
class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.swahili, required this.english});

  final String swahili;
  final String english;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        context.isSwahili ? swahili : english,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
    );
  }
}
