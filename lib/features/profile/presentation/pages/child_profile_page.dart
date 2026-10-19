/// **WASIFU WA MTOTO** — fomu moja ndogo ya jina na kundi la umri.
///
/// ## Kwa nini ukurasa huu upo
///
/// Kwenye tab ya Wasifu, safu ya mtoto ilikuwa na `chevron_right` lakini
/// **haikugusa kitu**. Chevron ni ahadi ya "kuna ukurasa nyuma yangu"; bila
/// ukurasa, ni udanganyifu wa UI. Ukurasa huu ndio ule unaoahidiwa.
///
/// ## Kinachoheshimiwa na kisichobuniwa
///
/// Tunaandika **mambo mawili pekee** ambayo `LibraryStore` inayaweza kweli:
/// jina na kundi la umri. Hakuna kupakia picha (avatar), hakuna PIN ya
/// mzazi, na hakuna "ongeza mtoto mwingine" — hazijatekelezwa, hivyo
/// hazionyeshwi. Kitufe cha kipengele kisichofanya kazi ni kosa lile lile
/// tulilokuja kulirekebisha.
///
/// ## Ukweli kuhusu data
///
/// Hakuna akaunti na hakuna seva: [LibraryStore] huandika kwenye
/// `shared_preferences` ya kifaa hiki. Kwa hivyo taarifa ya "kifaa pekee"
/// ipo wazi kwenye ukurasa, sivyo kwa herufi ndogo.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/theme/spacing.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/library_store.dart';
import '../../../../core/widgets/leo_mascot.dart';
// `context.localised(...)` inatangazwa na `L10nX` kwenye faili hili;
// `context_extensions.dart` haina (na haiwezi kuwa na) mbadala wake.
import '../../../../l10n/l10n.dart';
import '../widgets/profile_notice_card.dart';

/// Ukurasa wa kuhariri wasifu mmoja wa mtoto.
class ChildProfilePage extends StatefulWidget {
  /// Huunda ukurasa.
  const ChildProfilePage({super.key});

  @override
  State<ChildProfilePage> createState() => _ChildProfilePageState();
}

class _ChildProfilePageState extends State<ChildProfilePage> {
  /// Kidhibiti cha jina — tunalitupa kwenye `dispose` (hakuna uvujaji).
  final TextEditingController _nameController = TextEditingController();

  /// Kundi la umri lililochaguliwa; `null` = hakuna.
  AgeGroup? _age;

  /// `true` wakati hifadhi inaendelea — kitufe kisiguse mara mbili.
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Hali iliyopo inasomwa **mara moja** hapa. `LibraryStore.restore()`
    // huendesha kabla ya `runApp`, kwa hivyo thamani hizi tayari zipo —
    // hakuna haja ya spinner inayoficha fomu.
    final LibraryStore store = LibraryStore.instance;
    _nameController.text = store.childName;
    _age = _ageFromName(store.childAge);
  }

  /// Hubadilisha `AgeGroup.name` iliyohifadhiwa kuwa enum.
  ///
  /// Thamani isiyojulikana (mfano toleo la zamani lililohifadhi jina jingine)
  /// hurudisha `null` badala ya kuangusha ukurasa.
  AgeGroup? _ageFromName(String raw) {
    if (raw.isEmpty) return null;
    for (final AgeGroup group in AgeGroup.values) {
      if (group.name == raw) return group;
    }
    return null;
  }

  /// Huhifadhi kisha hurudi nyuma.
  ///
  /// `saveChild` **haiwezi kutupa** (imefungwa kwa `try/catch` ndani ya
  /// store), kwa hivyo hakuna `setState` ya "kosa" inayohitajika. Tunaandika
  /// jina tupu kama mtumiaji alifuta — hiyo ndiyo njia ya kumwondoa.
  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    final String name = _nameController.text.trim();
    await LibraryStore.instance.saveChild(name: name, age: _age?.name ?? '');

    if (!mounted) return;
    // SnackBar inamilikiwa na `ScaffoldMessenger` wa app, hivyo inaendelea
    // kuonekana baada ya `pop` — mtumiaji anarudi kwenye tab akiwa na
    // uthibitisho, sivyo akiwa hajui kama imehifadhiwa.
    context.showSnackBar(
      name.isEmpty
          ? context.localised(
              swahili: 'Taarifa za mtoto zimeondolewa kwenye kifaa hiki.',
              english: 'The child details were removed from this device.',
            )
          : context.localised(
              swahili: 'Imehifadhiwa kwenye kifaa hiki.',
              english: 'Saved on this device.',
            ),
    );
    context.pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool swahili = context.isSwahili;

    return Scaffold(
      // Mandhari hutoka theme: cream kwenye light, nyeusi kwenye dark.
      // Kuandika `AppColors.background` hapa kungeleta maandishi
      // yasiyoonekana kwenye dark mode.
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        elevation: 0,
        title: Text(
          context.localised(
            swahili: 'Wasifu wa Mtoto',
            english: 'Child Profile',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: context.localised(swahili: 'Rudi', english: 'Back'),
        ),
      ),
      body: ListView(
        // Kila kitu kinasogea — kwenye 320dp pamoja na keyboard iliyofunguliwa
        // hakuna kitu kinachopaswa kubanwa au kuoverflow.
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxxl,
        ),
        children: <Widget>[
          // Leo `curious` — tunamuuliza mtumiaji jambo (jina, umri), hivyo
          // udadisi unafaa zaidi ya shangwe.
          const Center(
            child: LeoMascot(pose: LeoPose.curious, height: 120),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            context.localised(
              swahili: 'Tuambie kuhusu mtoto wako',
              english: 'Tell us about your child',
            ),
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.localised(
              swahili: 'Taarifa hizi husaidia kuandaa app kwa mtoto wako.',
              english: 'These details help set the app up for your child.',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // -----------------------------------------------------------------
          // Jina
          // -----------------------------------------------------------------
          Text(
            context.localised(swahili: 'Jina la mtoto', english: "Child's name"),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            // Herufi 40 zinatosha kwa jina lolote la Kiswahili; counter
            // imefichwa kwa sababu haisaidii mtoto na inachukua nafasi ya
            // mstari kwenye skrini ndogo.
            maxLength: 40,
            style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
            decoration: InputDecoration(
              hintText: context.localised(
                swahili: 'Mfano: Amina',
                english: 'For example: Amina',
              ),
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              counterText: '',
              filled: true,
              // Kijazo ni `surfaceVariant` iliyo hafifu — `surface` ile ile
              // ya ukurasa ingefanya uwanja usionekane kabisa.
              fillColor: scheme.surfaceVariant.withOpacity(0.35),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.lg,
              ),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(
                  color: scheme.outline.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(
                  color: scheme.outline.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.localised(
              swahili: 'Acha wazi kama hutaki kuhifadhi jina.',
              english: 'Leave empty if you do not want to store a name.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // -----------------------------------------------------------------
          // Kundi la umri
          // -----------------------------------------------------------------
          Text(
            context.localised(swahili: 'Kundi la umri', english: 'Age group'),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            context.localised(
              swahili: 'Chagua kimoja. Gusa tena kuondoa chaguo.',
              english: 'Choose one. Tap again to clear the choice.',
            ),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // `Wrap` (sivyo `Row`): kwenye 320dp chipu tano hazitoshelezi mstari
          // mmoja, na `Row` ingeoverflow. `Wrap` inashuka mstari wa pili.
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              for (final AgeGroup group in AgeGroup.values)
                ChoiceChip(
                  label: Text(swahili ? group.labelSw : group.labelEn),
                  selected: _age == group,
                  // Kuchagua kilichochaguliwa kunakiondoa — bila hii,
                  // mtumiaji hangekuwa na njia ya kurudi kwenye "hakuna".
                  onSelected: (bool selected) {
                    setState(() => _age = selected ? group : null);
                  },
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // -----------------------------------------------------------------
          // Ukweli: hakuna akaunti, hakuna wingu
          // -----------------------------------------------------------------
          ProfileNoticeCard(
            icon: Icons.cloud_off_rounded,
            title: context.localised(
              swahili: 'Hakuna akaunti, hakuna wingu',
              english: 'No account, no cloud',
            ),
            message: context.localised(
              swahili: 'Toleo hili halina akaunti wala usawazishaji wa wingu. '
                  'Jina na kundi la umri vinahifadhiwa kwenye kifaa hiki '
                  'pekee — havipatikani kwenye simu nyingine, na '
                  'ukifuta app data vitapotea.',
              english: 'This build has no account and no cloud sync. The name '
                  'and age group are stored only on this device — they are '
                  'not available on another phone, and clearing the app data '
                  'removes them.',
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // -----------------------------------------------------------------
          // Hifadhi
          // -----------------------------------------------------------------
          SizedBox(
            height: AppSpacing.buttonHeight,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saving ? null : _save,
              // Kitufe hudhibitiwa wakati hifadhi inaendelea ili asigonge
              // mara mbili na kuandika mara mbili.
              icon: _saving
                  ? const SizedBox(
                      width: AppSpacing.iconSm,
                      height: AppSpacing.iconSm,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(
                context.localised(swahili: 'Hifadhi', english: 'Save'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            context.localised(
              swahili: 'Unaweza kubadilisha taarifa hizi wakati wowote.',
              english: 'You can change these details at any time.',
            ),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
