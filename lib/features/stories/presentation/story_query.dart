/// Vichujio (filters) na mpangilio (sorting) wa orodha ya hadithi.
///
/// ## Kwa nini logiki hii haipo kwenye `StoryListCubit`
///
/// Cubit inashughulikia **mzigo wa data**: `loadShelf`, `loadAll`, `search` na
/// hali ya kosa. Haina `sortBy` wala `filterByShelf` ya ziada, na kuiongezea
/// kungeifanya iwe na vigezo vinane vinavyoweza kupingana (`shelf` + `query` +
/// `sort` + `price` + `umri` + `kiwango`) wakati data yenyewe ni **fupi**:
/// maktaba yetu inarudisha hadithi zote kwa ombi moja.
///
/// Kwa hivyo mpangilio na uchujaji wa ziada hufanyika hapa, **kwenye
/// kumbukumbu**, juu ya orodha ambayo cubit tayari ameileta. Faida:
///
/// * Kubadilisha kichujo ni **papo hapo** — hakuna mzunguko wa mtandao.
/// * Mtumiaji anayeona "VIP" na kupata orodha tupu haambiwi uongo: `isFree`
///   ndiyo sehemu pekee ya bei iliyopo kwenye [Story] leo.
/// * Cubit inabaki nyembamba, na funguo za ARB zinazohitajika ni zile zile.
///
/// ## Kikomo kinachojulikana
///
/// [Story] **haina** `priceTZS`, `isPremium` wala lugha ya hadithi. Kwa hivyo:
///
/// * "Bei" ina thamani mbili tu zinazowezekana — `isFree` (`Bure`) na
///   kinyume chake (`VIP`). Bendi za bei ("TZS 500-2000") hazijajengwa kwa
///   sababu hazina data ya kuunga mkono.
/// * Kichujo cha lugha **hakipo**: kila hadithi yetu ina `titleSw` **na**
///   `titleEn` kwa wakati mmoja (kanuni ya 4), hivyo kuchuja kwa lugha
///   hakutatenganisha kitu — kungekuwa kitufe kisichofanya kazi.
library;

import 'package:flutter/widgets.dart';

import '../../../core/enums/app_enums.dart';
import '../../../l10n/l10n.dart';
import '../domain/entities/story.dart';

// ---------------------------------------------------------------------------
// Mpangilio (sorting)
// ---------------------------------------------------------------------------

/// Mpangilio unaoweza kutumika kwenye orodha ya hadithi.
enum StorySort {
  /// Mpangilio wa mkusanyaji ("Zote") — orodha inabaki kama ilivyotoka
  /// kwenye hifadhi. Hii ni muhimu kwa sababu mkusanyaji wa maktaba ndiye
  /// anayeamua hadithi ipi inaonekana kwanza; kuipanga upya kwa `id` au kwa
  /// `publishedYear` kungebatilisha uamuzi huo.
  curated,

  /// Mpya zaidi — `publishedYear` kubwa kwanza.
  newest,

  /// Zinazopendwa — `readCount` kubwa kwanza.
  popular,

  /// Rating bora — `rating` kubwa kwanza.
  rating,

  /// Jina (A-Z) kwa lugha ya sasa.
  ///
  /// Hupanga kwa lugha ya mtumiaji: mtumiaji anayesoma Kiswahili asipange
  /// kwa "A" ya Kiingereza.
  name,
}

/// Jina la mpangilio kwa lugha iliyochaguliwa sasa.
///
/// Ni `switch` **kamili** (haijumuishi `default`) kwa makusudi: thamani mpya
/// ikiongezwa kwenye [StorySort], mkusanyaji atalalamika hapa badala ya
/// kutumia jina la kwanza kimya kimya.
String storySortLabel(BuildContext context, StorySort sort) {
  final AppLocalizations l10n = context.l10n;
  switch (sort) {
    case StorySort.curated:
      return l10n.all;
    case StorySort.newest:
      return l10n.newLabel;
    case StorySort.popular:
      return l10n.popular;
    case StorySort.rating:
      return l10n.sortRating;
    case StorySort.name:
      return l10n.sortName;
  }
}

// ---------------------------------------------------------------------------
// Kichujo cha bei
// ---------------------------------------------------------------------------

/// Kichujo cha bei — hupima [Story.isFree] pekee.
///
/// Bendi za bei ("TZS 500-2000") hazipo kwa makusudi: hakuna sehemu ya bei
/// kwenye [Story]. Kuonyesha kichujo kisichochuja kitu kungefanya mtumiaji
/// aamini app imevunjika.
enum StoryPriceFilter {
  /// Hadithi zote — bila kuchuja bei.
  any,

  /// Zinazopatikana kwa plan ya BURE pekee.
  free,

  /// Zinazohitaji plan ya kulipia (leo: hakuna, kwa hivyo orodha ni tupu).
  premium;

  /// `true` kama [story] inaingia kwenye kichujo hiki.
  bool accepts(Story story) {
    switch (this) {
      case StoryPriceFilter.any:
        return true;
      case StoryPriceFilter.free:
        return story.isFree;
      case StoryPriceFilter.premium:
        return !story.isFree;
    }
  }
}

/// Jina la kichujo cha bei kwa lugha iliyochaguliwa sasa.
String storyPriceLabel(BuildContext context, StoryPriceFilter price) {
  final AppLocalizations l10n = context.l10n;
  switch (price) {
    case StoryPriceFilter.any:
      return l10n.all;
    case StoryPriceFilter.free:
      return l10n.free;
    case StoryPriceFilter.premium:
      return l10n.premium;
  }
}

// ---------------------------------------------------------------------------
// Kichujo cha pamoja
// ---------------------------------------------------------------------------

/// Vichujio vyote vya ukurasa mmoja, kama kitu kimoja.
///
/// Ni `@immutable` na ina `==`, kwa sababu hutumika kama hoja ya widget:
/// vichujio visivyobadilika lakini visivyo na usawa huisababisha gridi
/// kujengwa upya kila `setState` — kazi bure kwenye simu ya 1GB RAM.
@immutable
class StoryFilter {
  /// Huunda kichujo.
  const StoryFilter({
    this.ageGroups = const <AgeGroup>{},
    this.readingLevel,
    this.price = StoryPriceFilter.any,
  });

  /// Kichujo tupu — hakuna kitu kinachochujwa.
  static const StoryFilter none = StoryFilter();

  /// Makundi ya umri yaliyochaguliwa. Tupu = yote.
  ///
  /// Ni `Set` kwa sababu umri ni **multi-select** (mzazi anaweza kuwa na
  /// watoto wa miaka 4 na 10 kwa wakati mmoja).
  final Set<AgeGroup> ageGroups;

  /// Kiwango cha kusoma. `null` = vyote.
  ///
  /// Ni kimoja kwa sababu kiwango ni **single-select**: kuchagua "Darasa la
  /// 1-2" na "Sekondari" pamoja kungeonyesha orodha isiyo na maana.
  final ReadingLevel? readingLevel;

  /// Kichujo cha bei.
  final StoryPriceFilter price;

  /// `true` = hakuna kichujo kinachotumika.
  bool get isEmpty =>
      ageGroups.isEmpty &&
      readingLevel == null &&
      price == StoryPriceFilter.any;

  /// Idadi ya vichujio vinavyotumika — kwa badge ya kitufe cha "Vichujio".
  ///
  /// Kila kundi la umri linahesabiwa mmoja mmoja: mzazi aliyechagua umri
  /// miwili anaona "Vichujio (2)", si "Vichujio (1)".
  int get activeCount =>
      ageGroups.length +
      (readingLevel == null ? 0 : 1) +
      (price == StoryPriceFilter.any ? 0 : 1);

  /// Nakala mpya yenye mabadiliko.
  ///
  /// `clearReadingLevel` ipo kwa sababu `readingLevel: null` haiwezi
  /// kutofautishwa na "acha kama ilivyo" kwenye `copyWith` ya kawaida —
  /// hivyo kuchagua kiwango kile kile tena (kuondoa) kungeacha kichujo.
  StoryFilter copyWith({
    Set<AgeGroup>? ageGroups,
    ReadingLevel? readingLevel,
    bool clearReadingLevel = false,
    StoryPriceFilter? price,
  }) {
    return StoryFilter(
      ageGroups: ageGroups ?? this.ageGroups,
      readingLevel: clearReadingLevel ? null : (readingLevel ?? this.readingLevel),
      price: price ?? this.price,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StoryFilter &&
        other.price == price &&
        other.readingLevel == readingLevel &&
        _sameAgeGroups(other.ageGroups, ageGroups);
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(ageGroups),
        readingLevel,
        price,
      );

  /// `Set` haina `==` ya maana kwa maudhui — hivyo tunailinganisha wenyewe.
  static bool _sameAgeGroups(Set<AgeGroup> a, Set<AgeGroup> b) =>
      a.length == b.length && a.every(b.contains);
}

// ---------------------------------------------------------------------------
// Utekelezaji
// ---------------------------------------------------------------------------

/// Huchuja na kupanga [stories] kwa [sort], [filter] na [query].
///
/// Hii ni kazi **safi** (pure): orodha ya kuingiza haibadilishwi, na matokeo
/// ni orodha mpya. Hiyo inamaanisha UI inaweza kuiita kila `build` bila
/// kuogopa kwamba orodha ya cubit itaharibika.
///
/// [query] huchuja kwa kichwa (Kiswahili **na** Kiingereza), mwandishi,
/// kundi na umri — mtumiaji anayeandika "simba", "lion" au "wanyama" wote
/// wanapata kitu.
List<Story> applyStoryQuery(
  List<Story> stories, {
  required StorySort sort,
  StoryFilter filter = StoryFilter.none,
  String query = '',
  required bool swahili,
}) {
  final String needle = query.trim().toLowerCase();
  final bool hasNeedle = needle.isNotEmpty;

  final List<Story> matched = <Story>[
    for (final Story story in stories)
      if (_matchesFilter(story, filter) &&
          (!hasNeedle || _matchesQuery(story, needle)))
        story,
  ];

  switch (sort) {
    case StorySort.curated:
      // Hifadhi tayari inaorodhesha mpya kwanza — hatuipangi upya.
      return matched;
    case StorySort.newest:
      return stableSort(
        matched,
        (Story a, Story b) => b.publishedYear.compareTo(a.publishedYear),
      );
    case StorySort.popular:
      return stableSort(
        matched,
        (Story a, Story b) => b.readCount.compareTo(a.readCount),
      );
    case StorySort.rating:
      return stableSort(
        matched,
        (Story a, Story b) => b.rating.compareTo(a.rating),
      );
    case StorySort.name:
      return stableSort(
        matched,
        (Story a, Story b) => a
            .title(swahili: swahili)
            .toLowerCase()
            .compareTo(b.title(swahili: swahili).toLowerCase()),
      );
  }
}

/// Mpangilio **thabiti** (stable) — tie-break ni nafasi ya awali.
///
/// Kwa nini si `List.sort` peke yake: `List.sort` ya Dart **haiahidi
/// uthabiti**. Hadithi mbili zenye `rating` sawa zinaweza kubadilishana
/// nafasi kila `build`, na kadi zingeonekana "zinaruka" mtumiaji akigusa
/// kichujo. Kwa kutunza nafasi ya awali kama tie-break, mpangilio ni
/// unaotabirika kila mara.
List<Story> stableSort(
  List<Story> stories,
  int Function(Story a, Story b) compare,
) {
  final List<Story> items = List<Story>.of(stories);
  final List<int> order = List<int>.generate(items.length, (int i) => i);
  order.sort((int a, int b) {
    final int result = compare(items[a], items[b]);
    return result != 0 ? result : a.compareTo(b);
  });
  return <Story>[for (final int index in order) items[index]];
}

/// `true` kama [story] inapitisha vichujio vyote vya [filter].
bool _matchesFilter(Story story, StoryFilter filter) {
  if (filter.ageGroups.isNotEmpty &&
      !filter.ageGroups.contains(story.ageGroup)) {
    return false;
  }
  if (filter.readingLevel != null &&
      story.readingLevel != filter.readingLevel) {
    return false;
  }
  return filter.price.accepts(story);
}

/// `true` kama [story] inalingana na [needle] (tayari herufi ndogo).
bool _matchesQuery(Story story, String needle) {
  return story.titleSw.toLowerCase().contains(needle) ||
      story.titleEn.toLowerCase().contains(needle) ||
      story.author.toLowerCase().contains(needle) ||
      story.categoryLabel(swahili: true).toLowerCase().contains(needle) ||
      story.categoryLabel(swahili: false).toLowerCase().contains(needle) ||
      story.ageLabel(swahili: true).toLowerCase().contains(needle) ||
      story.levelLabel(swahili: true).toLowerCase().contains(needle);
}
