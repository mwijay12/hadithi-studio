/// Ukurasa mmoja wa hadithi — maandishi ya lugha **zote mbili** pamoja na picha.
///
/// **Kanuni ya 4 na nafasi yake hapa:** maandishi ya hadithi hayatoki kwenye
/// ARB. ARB ni kwa ajili ya *strings za UI* ("Soma Sasa", "Ukurasa") ambazo
/// mtafsiri anaweza kuzibadilisha bila kuandika upya hadithi. Maandishi ya
/// hadithi ni **maudhui** — mwandishi huandika Kiswahili na Kiingereza kwa
/// mkono, na yote mawili husafiri pamoja kwenye entity hii. Kwa hivyo ukurasa
/// hubeba `textSw` **na** `textEn`, si `text` moja pekee.
///
/// Hii ndiyo inafanya "Bilingual" iwezekane bila kuandika hadithi mara mbili:
/// ukurasa mmoja, maandishi mawili. Kwa hivyo mtumiaji anayechagua Kiswahili
/// hapati maandishi ya Kiingereza yaliyotafsiriwa na mashine — anapata yale
/// yaliyoandikwa kwa Kiswahili halisi.
library;

import 'package:equatable/equatable.dart';

import '../../../../core/enums/app_enums.dart';

/// Eneo linaloguswa kwenye picha — "hotspot".
///
/// Mtoto hana ngoja ya kusoma: anagusa kitu kwenye picha na kitu kinatokea.
/// Ndiyo maana ya [AppLocalizations.tapToInteract] ("Gusa kupata majibu!").
///
/// Nafasi zinatolewa kwa **uwiano** (`0.0`–`1.0`) badala ya pikseli. Kwa nini:
/// picha ile ile hutumika kwenye simu ya 5" (Tecno/Itel) na kwenye tablet —
/// pikseli tuli zingepoteza mahali gusa linapaswa kuwa.
class StoryHotspot extends Equatable {
  const StoryHotspot({
    required this.type,
    required this.labelSw,
    required this.labelEn,
    required this.revealSw,
    required this.revealEn,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  /// Aina ya mwingiliano (mnyama anena, sauti, mchezo mdogo…).
  final HotspotType type;

  /// Jina fupi la kitu kinachoguswa — kwa Kiswahili.
  final String labelSw;

  /// Jina fupi la kitu kinachoguswa — kwa Kiingereza.
  final String labelEn;

  /// Kile kinachofichuka mtoto anapogusa — kwa Kiswahili.
  final String revealSw;

  /// Kile kinachofichuka mtoto anapogusa — kwa Kiingereza.
  final String revealEn;

  /// Umbali kutoka kushoto, kwa uwiano wa upana wa picha.
  final double left;

  /// Umbali kutoka juu, kwa uwiano wa urefu wa picha.
  final double top;

  /// Upana, kwa uwiano wa upana wa picha.
  final double width;

  /// Urefu, kwa uwiano wa urefu wa picha.
  final double height;

  /// Lebo kwa lugha iliyochaguliwa sasa.
  ///
  /// Hubadilisha `swahili`/`english` — si `Locale` — kwa sababu maandishi yote
  /// mawili yapo tayari; hakuna tafsiri inayoendelea.
  String label({required bool swahili}) => swahili ? labelSw : labelEn;

  /// Kile kinachofichuka, kwa lugha iliyochaguliwa sasa.
  String reveal({required bool swahili}) => swahili ? revealSw : revealEn;

  @override
  List<Object?> get props => <Object?>[
        type,
        labelSw,
        labelEn,
        revealSw,
        revealEn,
        left,
        top,
        width,
        height,
      ];
}

/// Ukurasa mmoja wa hadithi.
///
/// Namba ya ukurasa haihifadhiwi: **mpangilio wa orodha** (`Story.pages`) ndiyo
/// ukurasa wa kwanza, wa pili n.k. Kuweka namba mbili (kwenye orodha **na**
/// kwenye ukurasa) kungeunda vyanzo viwili vya ukweli vinavyoweza kutofautiana
/// — tatizo lilelile la `AppSpacing.pageTurn`. Skrini ya kusoma inatumia
/// `index + 1` kwa "Ukurasa 3 kati ya 8".
class StoryPage extends Equatable {
  const StoryPage({
    required this.textSw,
    required this.textEn,
    required this.illustration,
    this.layout = PageLayout.fullIllustrationTextBottom,
    this.hotspots = const <StoryHotspot>[],
  });

  /// Maandishi ya ukurasa kwa Kiswahili — lugha ya msingi ya app.
  final String textSw;

  /// Maandishi ya ukurasa kwa Kiingereza.
  final String textEn;

  /// Njia ya picha ndani ya `assets/images/`.
  ///
  /// **Hali ya sasa:** hadithi tatu za kuanzia (Safari ya Simba, Mlima
  /// Kilimanjaro, Nyota za Usiku) zina **mchoro wake kwa kila ukurasa** —
  /// jumla ya 17 — chini ya `assets/images/stories/pages/<story-id>/`.
  /// Majina hufuata kanuni ile ile ya sauti (`page_01`, `page_02`…), hivyo
  /// mchoro na sauti ya ukurasa mmoja husafiri pamoja.
  ///
  /// Hadithi tatu zilizobaki bado zinatumia michoro ya branding iliyopo.
  /// Zikipata michoro yake, mabadiliko ni **hapa pekee** — hakuna skrini
  /// inayohitaji kubadilishwa.
  final String illustration;

  /// Muundo wa ukurasa (picha juu, maandishi chini, n.k.).
  final PageLayout layout;

  /// Vitu vinavyoguswa kwenye picha.
  final List<StoryHotspot> hotspots;

  /// Maandishi kwa lugha iliyochaguliwa sasa.
  String text({required bool swahili}) => swahili ? textSw : textEn;

  /// Ukurasa huu una kitu cha kugusa?
  bool get hasHotspots => hotspots.isNotEmpty;

  @override
  List<Object?> get props =>
      <Object?>[textSw, textEn, illustration, layout, hotspots];
}
