/// Hadithi ya "Twiga Mrefu" — hadithi moja ya seed iliyo kwenye faili yake.
///
/// ## Kwa nini faili tofauti
///
/// `story_sample_data.dart` ni jalada la hadithi za mwanzo. Hadithi mpya
/// zinapoongezwa, kila moja inapata faili yake ndogo ili mabadiliko ya
/// hadithi moja yasiguse nyingine na `git diff` ubaki wa kusomeka.
///
/// ## Ujumbe
///
/// Twiga anajihisi mrefu kupita kiasi kwa kucheza na wanyama wadogo.
/// Hadithi hii inamfundisha mtoto kwamba kile anachokiona kama kasoro
/// mara nyingi ni kipawa — Twiga huona mbali, na kwa sababu hiyo
/// anawaokoa wenzake kutokana na dhoruba.
library;


import '../../../../config/theme/colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';
import '../../domain/entities/story_shelf.dart';

/// Twiga mrefu — hadithi ya kujikubali kwa miaka 3–5.
const Story storyTwigaMrefu = Story(
  id: 'twiga-mrefu',
  titleSw: 'Twiga Mrefu',
  titleEn: 'The Tall Giraffe',
  synopsisSw:
      'Twiga anaona haya kwa sababu ni mrefu kuliko wanyama wote. '
      'Siku moja anainua kichwa chake juu na kuona mawingu meusi mbali '
      '— na anagundua kuwa urefu wake ni zawadi.',
  synopsisEn:
      'Twiga feels shy because she is taller than all the animals. '
      'One day she lifts her head high and sees dark clouds far away '
      '— and discovers that her height is a gift.',
  author: 'Hadithi za Jadi',
  category: StoryCategory.wanyama,
  ageGroup: AgeGroup.miaka_3_5,
  readingLevel: ReadingLevel.mtoto_mdogo,
  coverAsset: 'assets/images/stories/twiga_mrefu_cover.webp',
  accent: AppColors.sunsetGold,
  shelves: <StoryShelf>[
    StoryShelf.animalStories,
    StoryShelf.moralsWisdom,
  ],
  rating: 4.8,
  readCount: 0,
  pages: <StoryPage>[
    // Ukurasa 1 — Twiga yupo peke yake juu, wanyama wanacheza chini.
    StoryPage(
      textSw: 'Twiga alikuwa mrefu sana. Wanyama wadogo walicheza '
          'chini ya miguu yake. Twiga alitaka kucheza nao, lakini '
          'hakuweza kufika chini.',
      textEn: 'Twiga was very tall. The small animals played below her '
          'legs. Twiga wanted to play with them, but she could not '
          'reach down to them.',
      illustration: 'assets/images/stories/pages/twiga-mrefu/page_01.webp',
      hotspots: <StoryHotspot>[],
    ),
    // Ukurasa 2 — Twiga anainama kwa huzuni; wanyama wanamwangalia.
    StoryPage(
      textSw: 'Twiga aliinama chini na kusema, "Mimi ni mrefu mno." '
          'Sungura akamwambia, "Usiwe na huzuni." lakini Twiga '
          'alijihisi mpweke.',
      textEn: 'Twiga bent down low and said, "I am too tall." '
          'Rabbit told her, "Do not be sad." But Twiga still felt '
          'alone.',
      illustration: 'assets/images/stories/pages/twiga-mrefu/page_02.webp',
      hotspots: <StoryHotspot>[],
    ),
    // Ukurasa 3 — Twiga akiinua kichwa, anaona mawingu na kuwaonya wote.
    StoryPage(
      textSw: 'Ghafla Twiga aliinua kichwa juu. Aliona mawingu meusi '
          'mbali. "Dhoruba inakuja!" akaita. Wanyama wakapanda juu ya '
          'mwamba, na mvua ikapita salama.',
      textEn: 'Suddenly Twiga raised her head high. She saw dark clouds '
          'far away. "A storm is coming!" she called. The animals '
          'climbed up the rock, and the rain passed safely.',
      illustration: 'assets/images/stories/pages/twiga-mrefu/page_03.webp',
      hotspots: <StoryHotspot>[],
    ),
  ],
);
