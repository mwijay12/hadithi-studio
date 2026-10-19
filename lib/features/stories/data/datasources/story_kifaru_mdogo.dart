/// Hadithi ya "Kifaru Mdogo na Ndege Mdogo" — kifaru kijana na ndege mdogo.
///
/// ## Kwa nini hadithi hii ipo
///
/// Watoto wa miaka 3–5 hupenda wanyama wakubwa, lakini pia huogopa sauti na
/// harakati zao. Kifaru hapa ni mdogo, si mkubwa — mtoto anajiona ndani yake
/// anapokasirika kwa kitu kidogo kilichokaa mgongoni mwake. Hadithi inaonyesha
/// kwa vitendo, si kwa mahubiri, kwamba msaada mara nyingi huja kutoka kwa
/// yule tunayemdhani mdogo mno wa kumsikiliza.
///
/// ## Lugha
///
/// Sentensi ni fupi na za wakati uliopo, maneno ni yale ya kila siku ya
/// nyumbani na shambani ("nyasi", "kupe", "vumbi"). Hakuna methali wala
/// nahau hapa: mtoto wa miaka mitatu bado hajazijua, na hadithi hii ni
/// ngazi ya kwanza, si daraja la mwisho.
///
/// Kiswahili ni cha asili na Kiingereza ni tafsiri yake ya uaminifu — si
/// tafsiri ya mashine (kanuni ya 4: kila kitu hubeba lugha zote mbili).
library;

// `Color` haihitajiki hapa kwa jina — `AppColors.safariGreen` inatosha, kwa
// hivyo hakuna `import 'package:flutter/material.dart'` isiyotumika.
import '../../../../config/theme/colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';
import '../../domain/entities/story_shelf.dart';

/// "Kifaru Mdogo na Ndege Mdogo" — hadithi moja kamili, kurasa tatu.
///
/// Ni `const` kwa sababu maudhui yake hayabadilika wakati app inafanya kazi:
/// hakuna I/O, hakuna mtandao. Kurasa tatu tu — urefu unaofaa kikao kimoja
/// cha kusoma cha mtoto mdogo kabla ya usingizi.
const Story storyKifaruMdogo = Story(
  id: 'kifaru-mdogo',
  titleSw: 'Kifaru Mdogo na Ndege Mdogo',
  titleEn: 'Little Rhino and Little Bird',
  synopsisSw:
      'Kifaru mdogo hukasirika ndege mdogo anapokaa mgongoni mwake. Lakini '
      'ndege huyo humtoa kupe na kumwonya kuhusu hatari. Marafiki wawili '
      'hujifunza kusaidiana.',
  synopsisEn:
      'Little Rhino is cross when a little bird lands on his back. But the '
      'bird picks off his ticks and warns him of danger. The two friends '
      'learn to help each other.',
  author: 'Hadithi za Jadi',
  category: StoryCategory.wanyama,
  ageGroup: AgeGroup.miaka_3_5,
  readingLevel: ReadingLevel.mtoto_mdogo,
  coverAsset: 'assets/images/stories/kifaru_mdogo_cover.webp',
  accent: AppColors.safariGreen,
  shelves: <StoryShelf>[StoryShelf.animalStories],
  rating: 4.7,
  readCount: 0,
  pages: <StoryPage>[
    // Ukurasa wa 1 — kukutana: kifaru anatembea, ndege anafika.
    StoryPage(
      textSw: 'Kifaru mdogo anatembea kwenye nyasi ndefu. Ndege mdogo '
          'anakaa mgongoni mwake. Kifaru anasema, "Nenda zako!"',
      textEn: 'Little Rhino walks in the tall grass. Little Bird sits on '
          'his back. Little Rhino says, "Go away!"',
      illustration: 'assets/images/stories/pages/kifaru-mdogo/page_01.webp',
      hotspots: <StoryHotspot>[],
    ),

    // Ukurasa wa 2 — msaada wa kwanza: ndege humtoa kupe.
    StoryPage(
      textSw: 'Ndege anamtoa kupe mgongoni mwa kifaru. Kifaru anapumua '
          'kwa raha. "Ah! Hiyo ni vizuri," anasema.',
      textEn: 'Little Bird picks the ticks off Rhino\'s back. Little Rhino '
          'breathes with ease. "Ah! That is nice," he says.',
      illustration: 'assets/images/stories/pages/kifaru-mdogo/page_02.webp',
      hotspots: <StoryHotspot>[],
    ),

    // Ukurasa wa 3 — msaada wa pili: ndege anaona hatari, wote wako salama.
    StoryPage(
      textSw: 'Jua linazama. Ndege anaona vumbi: kuna hatari! "Kimbia!" '
          'anaonya. Kifaru anakimbia, na wote wawili wako salama.',
      textEn: 'The sun goes down. Little Bird sees dust: danger! "Run!" he '
          'warns. Little Rhino runs, and both of them are safe.',
      illustration: 'assets/images/stories/pages/kifaru-mdogo/page_03.webp',
      hotspots: <StoryHotspot>[],
    ),
  ],
);
