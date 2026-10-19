/// Hadithi ya "Mti wa Babu" — hadithi moja ya seed iliyo kwenye faili yake.
///
/// ## Kwa nini faili tofauti
///
/// `story_sample_data.dart` ni jalada la hadithi za mwanzo. Hadithi mpya
/// inapoongezwa, inapata faili yake ndogo ili mabadiliko ya hadithi moja
/// yasiguse nyingine na `git diff` ubaki wa kusomeka.
///
/// ## Ujumbe
///
/// Neema anapanda mti mdogo pamoja na babu yake, lakini anataka uwe mkubwa
/// mara moja. Babu anamfundisha kwamba kila kitu kizuri hukua polepole.
/// Hadithi hii inamfundisha mtoto uvumilivu na kumtia hamu ya kutunza mimea.
library;


import '../../../../config/theme/colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';
import '../../domain/entities/story_shelf.dart';

/// Mti wa Babu — hadithi ya uvumilivu kwa miaka 6–8.
const Story storyMtiWaBabu = Story(
  id: 'mti-wa-babu',
  titleSw: 'Mti wa Babu',
  titleEn: "Grandfather's Tree",
  synopsisSw:
      'Neema anapanda mti mdogo pamoja na babu yake. Kila siku anautazama '
      'na kujiuliza kwa nini haukui. Babu anamfundisha uvumilivu — na miaka '
      'mingi baadaye, Neema anaketi chini ya mti mkubwa.',
  synopsisEn:
      'Neema plants a small seedling with her grandfather. Every day she '
      'watches it and wonders why it does not grow. Grandfather teaches her '
      'patience — and many years later, Neema sits under a big tree.',
  author: 'Hadithi za Jadi',
  category: StoryCategory.mazingira,
  ageGroup: AgeGroup.miaka_6_8,
  readingLevel: ReadingLevel.darasa_1_2,
  coverAsset: 'assets/images/stories/mti_wa_babu_cover.webp',
  accent: AppColors.brightGreen,
  shelves: const <StoryShelf>[
    StoryShelf.science,
    StoryShelf.moralsWisdom,
  ],
  rating: 4.7,
  readCount: 0,
  pages: const <StoryPage>[
    // Ukurasa 1 — Babu na Neema wamepiga magoti shambani, wanapanda mti mdogo.
    StoryPage(
      textSw: 'Babu alinipa mti mdogo wa embe. Tulipiga magoti kwenye '
          'udongo na kuupanda pamoja. Babu alisema, "Mti huu ni wako, '
          'Neema. Uutunze."',
      textEn: 'Grandfather gave me a small mango seedling. We knelt in the '
          'soil and planted it together. Grandfather said, "This tree is '
          'yours, Neema. Take care of it."',
      illustration: 'assets/images/stories/pages/mti-wa-babu/page_01.webp',
      hotspots: const <StoryHotspot>[],
    ),
    // Ukurasa 2 — Neema anamwaga maji na kuchungulia udongo; hana subira.
    StoryPage(
      textSw: 'Kila siku nilimwaga maji na kuchungulia udongo. "Babu, '
          'mbona haukui?" nilimuuliza. Babu alicheka na kusema, "Kila '
          'kitu kizuri hukua polepole. Subiri."',
      textEn: 'Every day I poured water and peeped at the soil. '
          '"Grandfather, why is it not growing?" I asked him. '
          'Grandfather laughed and said, "Everything good grows slowly. '
          'Wait."',
      illustration: 'assets/images/stories/pages/mti-wa-babu/page_02.webp',
      hotspots: const <StoryHotspot>[],
    ),
    // Ukurasa 3 — Miaka mingi baadaye, Neema amekua na anaketi chini ya mti.
    StoryPage(
      textSw: 'Miaka mingi baadaye, niliketi chini ya mti huo mkubwa. '
          'Majani yake yalitupatia kivuli chepesi. Nilikumbuka maneno ya '
          'Babu: "Kila kitu kizuri hukua polepole."',
      textEn: 'Many years later, I sat under that big tree. Its leaves gave '
          'us cool shade. I remembered Grandfather\'s words: "Everything '
          'good grows slowly."',
      illustration: 'assets/images/stories/pages/mti-wa-babu/page_03.webp',
      hotspots: const <StoryHotspot>[],
    ),
  ],
);
