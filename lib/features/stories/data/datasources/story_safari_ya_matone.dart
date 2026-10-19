/// Hadithi ya "Safari ya Matone" — mzunguko wa maji kama safari.
///
/// ## Kwa nini faili tofauti
///
/// Kama `story_twiga_mrefu.dart`, hadithi hii ina faili yake ndogo ili
/// mabadiliko ya hadithi moja yasiguse nyingine na `git diff` ubaki wa
/// kusomeka. Haijaunganishwa kwenye orodha ya `story_sample_data.dart` bado.
///
/// ## Ujumbe
///
/// Mtoto anafuata tone dogo la maji kuanzia baharini, akipanda kama mvuke,
/// akawa wingu, akanyesha kwenye theluji ya Kilimanjaro, na kurudi baharini.
/// Sayansi ya mzunguko wa maji inasimuliwa kama safari, si kama somo.
library;


import '../../../../config/theme/colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';
import '../../domain/entities/story_shelf.dart';

/// Safari ya Matone — sayansi ya mzunguko wa maji kwa miaka 6–8.
const Story storySafariYaMatone = Story(
  id: 'safari-ya-matone',
  titleSw: 'Safari ya Matone',
  titleEn: 'The Journey of the Droplets',
  synopsisSw:
      'Tone ni tone dogo la maji linaloishi baharini. Jua linampasha joto, '
      'upepo unampandisha juu angani, na safari yake ndefu inaanza — '
      'kutoka wingu jeupe hadi theluji ya Kilimanjaro, na kurudi baharini.',
  synopsisEn:
      'Tone is a little water droplet who lives in the sea. The sun warms '
      'him, the wind lifts him high into the sky, and his long journey '
      'begins — from a white cloud to the snow of Kilimanjaro, and back '
      'to the sea.',
  author: 'Hadithi za Jadi',
  category: StoryCategory.sayansi_na_teknolojia,
  ageGroup: AgeGroup.miaka_6_8,
  readingLevel: ReadingLevel.darasa_1_2,
  coverAsset: 'assets/images/stories/safari_ya_matone_cover.webp',
  accent: AppColors.skyBlue,
  shelves: <StoryShelf>[
    StoryShelf.science,
    StoryShelf.safari,
  ],
  rating: 4.7,
  readCount: 0,
  pages: <StoryPage>[
    // Ukurasa 1 — Tone anaruka kutoka baharini chini ya jua.
    StoryPage(
      textSw: 'Bahari ilikuwa ya bluu na tulivu. Jua la asubuhi '
          'likampasha moto tone dogo la maji anayeitwa Tone. Tone '
          'akawa mwepesi, akaruka juu angani!',
      textEn: 'The sea was blue and calm. The morning sun warmed a '
          'little drop of water named Tone. Tone became light and '
          'leaped up into the sky!',
      illustration:
          'assets/images/stories/pages/safari-ya-matone/page_01.webp',
      hotspots: <StoryHotspot>[],
    ),
    // Ukurasa 2 — Tone ni mvuke; upepo unampeleka kwenye wingu kubwa.
    StoryPage(
      textSw: 'Juu angani, Tone akageuka kuwa mvuke mwembamba usioonekana '
          'vizuri. Upepo ukamsukuma juu, juu, hadi alipofika kwenye '
          'wingu jeupe. Mvuke wengi walikutana, wakawa wingu kubwa.',
      textEn: 'High in the sky, Tone turned into thin vapour that is hard '
          'to see. The wind pushed him up and up, until he reached a '
          'white cloud. Many vapours met there and became one big cloud.',
      illustration:
          'assets/images/stories/pages/safari-ya-matone/page_02.webp',
      hotspots: <StoryHotspot>[],
    ),
    // Ukurasa 3 — mvua inanyesha kwenye kilele cha Kilimanjaro, maji
    // yanarudi baharini.
    StoryPage(
      textSw: 'Wingu likasafiri hadi mlima Kilimanjaro, likaganda na kuwa '
          'zito. Tone akashuka chini kama tone la mvua, moja kwa moja '
          'kwenye theluji ya kilele. Kisha maji yakatiririka kwenye mito, '
          'yakarudi baharini — tayari kwa safari mpya!',
      textEn: 'The cloud travelled to Mount Kilimanjaro and grew cold and '
          'heavy. Tone fell down as a raindrop, right onto the snow at '
          'the peak. Then the water flowed down the rivers, back to the '
          'sea — ready for a new journey!',
      illustration:
          'assets/images/stories/pages/safari-ya-matone/page_03.webp',
      hotspots: <StoryHotspot>[],
    ),
  ],
);
