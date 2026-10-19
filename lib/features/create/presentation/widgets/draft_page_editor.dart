/// **Kihariri cha ukurasa mmoja** wa rasimu ya mtumiaji.
///
/// ## Kwa nini ni widget tofauti, sivyo kodi ndani ya ukurasa
///
/// Ukurasa wa "Tengeneza" unaorodhesha kurasa kwa `for` au `ListView`. Kila
/// ukurasa unahitaji vitu vinne: kichwa ("Ukurasa 1"), kihesabu cha herufi
/// kinachoendelea kuishi, uwanja wa maandishi wenye lebo, na kitufe cha
/// kufuta. Kurudia hayo ndani ya `build` kungefanya ukurasa mzima ujengwe
/// upya kila herufi inapobadilika — hapa `ValueListenableBuilder` hujenga
/// **mstari mmoja** pekee.
///
/// ## Kwa nini rangi zote zinatoka theme
///
/// Mandhari ya app hufuata mfumo (`ThemeMode.system`). Tukiweka `Colors.white`
/// au cream hapa, maandishi ya `TextField` (yanayotoka theme, karibu meupe
/// kwenye dark mode) yangeonekana **yeupe juu ya nyeupe**. Kwa hivyo:
/// mandhari = `scheme.surface`, maandishi = `scheme.onSurface`, pembeni =
/// `scheme.outlineVariant`.
library;

import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/context_extensions.dart';

/// Kihariri cha ukurasa mmoja.
class DraftPageEditor extends StatelessWidget {
  /// Huunda kihariri cha ukurasa wa nambari [index] (kuanzia 1).
  const DraftPageEditor({
    super.key,
    required this.index,
    required this.controller,
    required this.onDelete,
  });

  /// Nambari ya ukurasa inayoonyeshwa kwa mtumiaji (1, 2, 3…).
  final int index;

  /// Maandishi ya ukurasa. Ni ya nje kwa sababu ukurasa wa "Tengeneza"
  /// humiliki na kuyafuta yote kwenye `dispose`.
  final TextEditingController controller;

  /// `null` = huu ni ukurasa pekee uliobaki; hauwezi kufutwa.
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        // Nyuso zote za fomu hutumia rangi ya theme ili ziwe sawa kwenye
        // mchana na usiku.
        color: scheme.surface,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  context.isSwahili ? 'Ukurasa $index' : 'Page $index',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              // Kihesabu hiki hujengwa upya pekee kila herufi inapobadilika.
              // Bila `ValueListenableBuilder`, `setState` ya ukurasa mzima
              // ingeharibu focus ya uwanja unaoandikwa.
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (
                  BuildContext context,
                  TextEditingValue value,
                  Widget? child,
                ) {
                  return Text(
                    context.isSwahili
                        ? 'herufi ${value.text.length}'
                        : '${value.text.length} chars',
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  );
                },
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: AppSpacing.iconSm + 2,
                  ),
                  color: scheme.error,
                  tooltip: context.isSwahili
                      ? 'Futa ukurasa $index'
                      : 'Delete page $index',
                  // Eneo la kugusa linabaki 48dp hata ikoni ni ndogo —
                  // vidole vya watoto havihitaji usahihi.
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: controller,
            minLines: 4,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: scheme.onSurface,
            ),
            decoration: InputDecoration(
              // Lebo halisi kwa screen reader; kichwa cha juu ni kwa macho.
              labelText: context.isSwahili ? 'Maandishi ya ukurasa' : 'Page text',
              hintText: context.isSwahili
                  ? 'Andika mwanzo wa hadithi hapa…'
                  : 'Write the beginning of the story here…',
              alignLabelWithHint: true,
              filled: true,
              // Rangi nyepesi ya `onSurface` hufanya kazi kwenye mandhari
              // zote mbili: nyeupe inakuwa kijivu hafifu, nyeusi inakuwa
              // kijivu hafifu pia.
              fillColor: scheme.onSurface.withValues(alpha: 0.04),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(color: scheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusSm,
                borderSide: BorderSide(color: scheme.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
