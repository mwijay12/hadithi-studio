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
/// Kusoma au kuandika kukishindwa, tunaonyesha kosa badala ya kudai kuwa
/// mapendeleo yamehifadhiwa. Mtumiaji anaweza kujaribu tena.
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
    _keyStreak: false,
    _keyNewStory: false,
    _keyWeeklyReport: false,
    _keyBadges: false,
    _keyChallenges: false,
    _keyCommunity: false,
    _keyPromotions: false,
  };

  /// Orodha ya mapendeleo yanayohifadhiwa kwenye kifaa.
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
  bool _loadFailed = false;
  bool _saving = false;
  bool _saveFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Husoma mapendeleo yote; kikishindwa, hurudi kwa chaguo-msingi.
  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _loadFailed = false; });
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        _defaults.forEach((String key, bool fallback) {
          _toggles[key] = prefs.getBool(key) ?? fallback;
        });
        final savedTime = prefs.getString(_keyPreferredTime);
        _preferredTime = _timeOptions.any((option) => option.value == savedTime)
            ? savedTime! : _timeEvening;
        _loading = false;
        _loadFailed = false;
      });
    } catch (error) {
      // Usionyeshe chaguo-msingi kama mapendeleo yaliyohifadhiwa.
      debugPrint(
        'NotificationSettingsPage: kusoma mapendeleo kimeshindwa — $error',
      );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  /// Apply only after the write succeeds; disable controls during the write so
  /// rapid changes cannot be persisted out of order.
  Future<void> _savePreference(String key, Object value) async {
    setState(() { _saving = true; _saveFailed = false; });
    bool saved = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      saved = value is bool
          ? await prefs.setBool(key, value)
          : await prefs.setString(key, value as String);
    } catch (error) {
      debugPrint('Notification preferences could not be saved: $error');
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saveFailed = !saved;
      if (saved) {
        if (value is bool) { _toggles[key] = value; }
        else { _preferredTime = value as String; }
      }
    });
  }

  void _onPreferredTimeChanged(String? value) {
    if (value != null && !_saving) _savePreference(_keyPreferredTime, value);
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
          : _loadFailed
              ? Center(child: TextButton(
                  onPressed: _load,
                  child: Text(context.isSwahili
                      ? 'Mapendeleo hayajasomeka. Jaribu tena'
                      : 'Could not load preferences. Try again'),
                ))
              : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
              children: <Widget>[
                const _NoticeBox(
                  swahili: 'Arifa hazitumwa bado. Miundombinu ya arifa (push) '
                      'haijasanidiwa, kwa hivyo hutapokea arifa yoyote kwa '
                      'sasa. Chaguo zako zinahifadhiwa kwenye kifaa tu.',
                  english: 'Notifications cannot be delivered yet. Push '
                      'infrastructure is not configured, so you will not '
                      'receive any notifications for now. Your preferences '
                      'are saved on this device only.',
                ),

                if (_saveFailed) Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(context.isSwahili
                      ? 'Mabadiliko hayakuhifadhiwa. Jaribu tena.'
                      : 'Change not saved. Please try again.',
                    style: TextStyle(color: scheme.error)),
                ),
                const _SectionHeading(
                  swahili: 'Mapendeleo ya arifa za baadaye',
                  english: 'Preferences for future notifications',
                ),
                for (final _ToggleSpec spec in _specs)
                  SwitchListTile(
                    value: _toggles[spec.key] ?? false,
                    onChanged: _saving ? null : (bool value) =>
                        _savePreference(spec.key, value),
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

                const _SectionHeading(
                  swahili: 'Muda unaopendelea',
                  english: 'Preferred time',
                ),
                RadioGroup<String>(
                  groupValue: _preferredTime,
                  onChanged: _onPreferredTimeChanged,
                  child: Column(
                    children: <Widget>[
                      for (final _TimeOption option in _timeOptions)
                        RadioListTile<String>(
                          enabled: !_saving,
                          value: option.value,
                          title: Text(
                            context.isSwahili ? option.swahili : option.english,
                            style: TextStyle(color: scheme.onSurface),
                          ),
                        ),
                    ],
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
                            'ikiwa arifa zitaongezwa baadaye.'
                        : 'This preference is stored locally; notification delivery is not available yet.',
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
          color: scheme.primary.withValues(alpha: 0.09),
          borderRadius: AppSpacing.borderRadiusMd,
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.notifications_off_rounded,
              color: scheme.onSurface,
              size: AppSpacing.iconMd,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                context.isSwahili ? swahili : english,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: scheme.onSurface,
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
