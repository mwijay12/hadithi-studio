/// Maandishi ya lugha mbili — kwa hali ya **"Lugha Zote"**.
///
/// ## Tatizo lililokuwa
///
/// `AppLanguage.bilingual` ina code ya ISO `'sw'`. Kwa hivyo mtumiaji
/// aliyechagua **"Lugha Zote"** aliona Kiswahili pekee — kitu kile kile
/// alichokiona kwenye "Kiswahili". Chaguo lilikuwa halifanyi kazi.
///
/// ## Suluhisho
///
/// [BilingualText] hupokea **maandishi yote mawili** na huamua mwenyewe:
///
/// * **Lugha Zote** → Kiswahili **juu**, Kiingereza **chini** (ndogo kidogo,
///   italiki, rangi hafifu) na mstari mwembamba kati yao — kama vitabu vya
///   watoto vya Kiswahili/Kiingereza halisi.
/// * **Kiswahili** → Kiswahili pekee.
/// * **Kiingereza** → Kiingereza pekee.
///
/// ## Kwa nini widget na si `if` kila mahali
///
/// Hali hii inahitajika kwenye ukurasa wa maelezo, kwenye reader, na kwenye
/// kadi za hadithi. Kuandika `if (isBilingual)` mara tatu kungeunda mahali
/// patatu panapoweza kutofautiana. Mahali pamoja = tabia moja.
///
/// ## Uwiano wa rangi
///
/// Maandishi ya Kiingereza hutumia `mutedText` (#666666) — uwiano wa
/// **5.7:1** juu ya mandhari ya cream, yaani unakidhi WCAG AA (4.5:1).
/// Kuifanya hafifu zaidi kungeifanya isisomeke kwenye jua la Tanzania.
library;

import 'package:flutter/material.dart';

import '../../config/theme/spacing.dart';
import '../extensions/context_extensions.dart';

/// Huonyesha maandishi kwa lugha moja au mbili, kulingana na chaguo la lugha.
class BilingualText extends StatelessWidget {
  /// Huunda maandishi ya lugha mbili.
  const BilingualText({
    super.key,
    required this.swahili,
    required this.english,
    this.style,
    this.textAlign,
    this.maxLines,
    this.showDivider = true,
  });

  /// Maandishi ya Kiswahili.
  final String swahili;

  /// Maandishi ya Kiingereza.
  final String english;

  /// Mtindo wa maandishi ya msingi (Kiswahili, au lugha iliyochaguliwa).
  final TextStyle? style;

  /// Mpangilio wa maandishi.
  final TextAlign? textAlign;

  /// Kikomo cha mistari kwa kila lugha.
  final int? maxLines;

  /// `true` = mstari mwembamba kati ya lugha mbili.
  final bool showDivider;

  /// Mtindo wa lugha ya pili — ndogo, italiki, hafifu.
  ///
  /// Hukokotolewa kutoka [style] ili kuhifadhi fonti na urefu wa mstari wa
  /// mandhari husika (mfano Merriweather kwenye reader).
  TextStyle _secondaryStyle(BuildContext context) {
    final TextStyle base = style ?? DefaultTextStyle.of(context).style;
    return base.copyWith(
      fontSize: (base.fontSize ?? 15) * 0.88,
      fontStyle: FontStyle.italic,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lugha moja — tabia ya kawaida, bila Column ya bure.
    if (!context.isBilingual) {
      return Text(
        context.isSwahili ? swahili : english,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          swahili,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow:
              maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(height: 1, thickness: 1),
          )
        else
          const SizedBox(height: AppSpacing.xs),
        Text(
          english,
          style: _secondaryStyle(context),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow:
              maxLines == null ? TextOverflow.clip : TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
