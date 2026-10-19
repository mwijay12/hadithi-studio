/// Hadithi moja kamili — kichwa, mwandishi, ukurasa na picha ya jalada.
///
/// ## Maandishi mawili, si tafsiri
///
/// Kila kitu kinachomfikia mtumiaji hubeba Kiswahili **na** Kiingereza
/// (kanuni ya 4). Hapa hazitafsiriwi: mwandishi huandika zote mbili. Njia
/// za kuzipata ni [title], [synopsis] na `StoryPage.text` — zote zinaitwa
/// kwa `swahili: context.isSwahili`, kwa hivyo hakuna mahali panapohitaji
/// `if` lingine kuhusu lugha.
///
/// ## Kwa nini `Color` ipo kwenye entity
///
/// Clean Architecture husema entity iwe Dart tupu. Hapa tumefanya uamuzi wa
/// makusudi: `accent` ni **sehemu ya utambulisho wa hadithi** — kadi ya
/// "Safari ya Simba" ni ya kijani ya safari kila mahali (Nyumbani, Maktaba,
/// Rafu Yangu, ukurasa wa maelezo). Kuiweka kwenye presentation kungehitaji
/// ramani ya `id → rangi` kwenye widget, ambayo ni chanzo cha pili cha ukweli
/// kinachoweza kutofautiana na data. `Color` hutoka `dart:ui`, haina I/O na
/// haina `BuildContext` — kwa hivyo haivunji uwezo wa kupimwa wa entity.
library;

import 'package:equatable/equatable.dart';
import 'package:flutter/painting.dart';

import '../../../../config/constants/app_constants.dart';
import '../../../../core/enums/app_enums.dart';
import '../../../../core/utils/text_utils.dart';
import 'story_page.dart';
import 'story_shelf.dart';

/// Hadithi moja.
///
/// Ni `Equatable` kwa sababu hutumika kwenye `BlocState`: bila value
/// equality, kila `emit` ingefanya UI ijenge upya kadi zote hata data
/// haijabadilika — kazi isiyo ya lazima kwenye simu ya Tanzania.
class Story extends Equatable {
  const Story({
    required this.id,
    required this.titleSw,
    required this.titleEn,
    required this.synopsisSw,
    required this.synopsisEn,
    required this.author,
    required this.category,
    required this.ageGroup,
    required this.readingLevel,
    required this.coverAsset,
    required this.accent,
    required this.shelves,
    required this.pages,
    this.isFree = true,
    this.rating = 4.5,
    this.readCount = 0,
    this.publishedYear = 2026,
  });

  /// Kitambulisho cha kudumu — hutumika kwenye URL: `/story/safari-ya-simba`.
  ///
  /// Ni Kiingereza-kwa-Kiswahili *slug*: herufi ndogo, maneno yametenganishwa
  /// kwa `-`. Slugs za Kiswahili zinabaki jinsi zilivyo (`safari-ya-simba`)
  /// — hazibadilishwi kuwa Kiingereza, kwa sababu hadithi ni ya Tanzania
  /// kwanza na kiungo kinaonekana kwenye UI ya Kiswahili.
  final String id;

  /// Jina la hadithi kwa Kiswahili.
  final String titleSw;

  /// Jina la hadithi kwa Kiingereza.
  final String titleEn;

  /// Muhtasari kwa Kiswahili — kadi na ukurasa wa maelezo.
  final String synopsisSw;

  /// Muhtasari kwa Kiingereza.
  final String synopsisEn;

  /// Jina la mwandishi (au "Hadithi za Jadi" kwa ngano za jamii).
  final String author;

  /// Uainishaji wa kihariri (`StoryCategory` kutoka `core/enums`).
  final StoryCategory category;

  /// Kundi la umri linalopendekezwa.
  final AgeGroup ageGroup;

  /// Kiwango cha kusoma — hubadilisha urefu na ugumu wa maneno.
  final ReadingLevel readingLevel;

  /// Picha ya jalada.
  final String coverAsset;

  /// Rangi ya hadithi — kivuli, badge na akiba ya picha.
  final Color accent;

  /// Rafu ambazo hadithi hii inaonekana kwenye Maktaba.
  ///
  /// Ni orodha kwa sababu hadithi ya wanyama inaweza pia kuwa ya maadili.
  /// Maktaba hususa hadithi kwa `story.shelves.contains(shelf)`.
  final List<StoryShelf> shelves;

  /// Kurasa zote, kwa mpangilio.
  final List<StoryPage> pages;

  /// `true` = inapatikana kwa plan ya BURE (TZS 0).
  final bool isFree;

  /// Kiwango cha wastani cha nyota (`0.0`–`5.0`).
  final double rating;

  /// Idadi ya wasomaji — huonyeshwa kwa "Zinazopendwa" (trending).
  final int readCount;

  /// Mwaka wa kuchapishwa.
  final int publishedYear;

  /// Jina la hadithi kwa lugha iliyochaguliwa sasa.
  String title({required bool swahili}) => swahili ? titleSw : titleEn;

  /// Muhtasari kwa lugha iliyochaguliwa sasa.
  String synopsis({required bool swahili}) => swahili ? synopsisSw : synopsisEn;

  /// Idadi ya kurasa.
  int get pageCount => pages.length;

  /// Jina la kundi la umri kwa lugha iliyochaguliwa sasa.
  String ageLabel({required bool swahili}) =>
      swahili ? ageGroup.labelSw : ageGroup.labelEn;

  /// Jina la kiwango cha kusoma kwa lugha iliyochaguliwa sasa.
  String levelLabel({required bool swahili}) =>
      swahili ? readingLevel.labelSw : readingLevel.labelEn;

  /// Jina la uainishaji kwa lugha iliyochaguliwa sasa.
  String categoryLabel({required bool swahili}) =>
      swahili ? category.labelSw : category.labelEn;

  /// Maandishi yote ya hadithi, yameunganishwa — kwa kuhesabu maneno.
  ///
  /// Hutumia lugha **moja** pekee kwa makusudi: kuhesabu Kiswahili **na**
  /// Kiingereza pamoja kungediriki muda wa kusoma mara mbili, wakati mtoto
  /// husoma lugha moja kwa wakati mmoja.
  String get _fullTextSw => pages.map((StoryPage p) => p.textSw).join(' ');

  /// Idadi ya maneno ya Kiswahili.
  int get wordCount => SwahiliTextUtils.wordCount(_fullTextSw);

  /// Muda wa kusoma kwa **dakika kamili**, kwa kasi ya [AppConstants.wordsPerMinute].
  ///
  /// Hurudisha angalau dakika 1: hadithi ya maneno 20 haichukui "dakika 0"
  /// — hiyo ingeonyesha "dakika 0" kwenye kadi, ambayo haina maana kwa mzazi.
  /// Na kwa vile tunatumia `ceil` kwa idadi kamili, tunatoa `int` badala ya
  /// kumpa mwito `double` ya kuzungusha.
  int get readingMinutes {
    final int seconds = SwahiliTextUtils.estimateReadingSeconds(
      _fullTextSw,
      AppConstants.wordsPerMinute,
    );
    final int minutes = (seconds / 60).ceil();
    return minutes < 1 ? 1 : minutes;
  }

  /// Picha ya ukurasa wa kwanza — akiba ikiwa [coverAsset] haipo.
  String get firstPageAsset =>
      pages.isEmpty ? coverAsset : pages.first.illustration;

  /// Vitu vyote vya kugusa kwenye hadithi hii.
  int get hotspotCount => pages.fold<int>(
        0,
        (int total, StoryPage page) => total + page.hotspots.length,
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        titleSw,
        titleEn,
        synopsisSw,
        synopsisEn,
        author,
        category,
        ageGroup,
        readingLevel,
        coverAsset,
        accent,
        shelves,
        pages,
        isFree,
        rating,
        readCount,
        publishedYear,
      ];
}
