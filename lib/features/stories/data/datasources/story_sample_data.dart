/// Hadithi za kuanzia (seed content) za Hadithi Studio.
///
/// ## Kwa nini faili hili lipo
///
/// App iliyo tupu haifundishi kitu na haiuzi kitu. Hadi API ya
/// `/api/v1/stories` iwe hai, faili hili ndilo linalofanya Maktaba, Nyumbani
/// na Rafu Yangu ziwe na maisha — na ndilo linalotupa kitu cha kweli cha
/// kupima Reader dhidi yake (kanuni #15: TTS word highlighting hujaribiwa
/// kwa hadithi halisi, si kwa "lorem ipsum").
///
/// Data hii **ni ya ndani kabisa**: haina mtandao, haina I/O. Kwa hivyo
/// inafanya kazi kwenye ndege, kwenye basi la Dar–Mwanza, na kwenye kijiji
/// kisicho na 3G — ndiyo hali ya matumizi ya kwanza ya app hii.
///
/// ## Maudhui — kwa nini hizi hadithi
///
/// Kila hadithi imeandikwa kwa **Kiswahili halisi na Kiingereza halisi**
/// (si tafsiri ya mashine). Mandhari ni za Tanzania: Serengeti, Kilimanjaro,
/// Zanzibar, ngoma, chapati za mama, kuku na mwewe. Mtoto anaposoma
/// "Simba", anajiona. Hili ni tofauti ya msingi kati ya app hii na app
/// yoyote ya hadithi iliyotafsiriwa.
///
/// ## Kurasa na picha
///
/// Kwa sasa kuna picha 12 tu zilizopangwa kwenye `assets/images/`. Kwa hivyo
/// kila ukurasa unatumia picha **inayolingana na mandhari** ya ukurasa
/// (safari, wanyama, sayansi…) badala ya picha ya kubahatisha. Kurasa
/// zinapopewa michoro halisi, mabadiliko ni ya `illustration:` pekee —
/// hakuna skrini, widget wala BLoC inayohitaji kubadilishwa.
library;


import '../../../../config/theme/colors.dart';
import '../../../../core/enums/app_enums.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_page.dart';
import '../../domain/entities/story_shelf.dart';
import 'story_kifaru_mdogo.dart';
import 'story_mti_wa_babu.dart';
import 'story_safari_ya_matone.dart';
import 'story_twiga_mrefu.dart';

/// Picha zinazopatikana kwa sasa — majina mafupi kwa urahisi wa kusoma.
///
/// Ni `abstract final class` yenye `static const`, kwa hivyo hazitumii
/// kumbukumbu wakati wa runtime: zote zinakunjwa kwenye compile.
abstract final class _Art {
  static const String hero = 'assets/images/hero_home.png';
  static const String animals =
      'assets/images/categories/cat_animal_stories.png';
  static const String morals =
      'assets/images/categories/cat_morals_wisdom.png';
  static const String culture = 'assets/images/categories/cat_culture.png';
  static const String songs = 'assets/images/categories/cat_poems_songs.png';
  static const String listen =
      'assets/images/onboarding/onboarding_listen.png';
  static const String create =
      'assets/images/onboarding/onboarding_create.png';
  static const String language =
      'assets/images/onboarding/onboarding_language.png';
}

/// Hadithi zote za kuanzia.
abstract final class StorySampleData {
  const StorySampleData._();

  /// Orodha kamili. Mpangilio ni "mpya kwanza" — hadithi ya kwanza
  /// inaonekana kwenye Nyumbani kama "Hadithi ya Leo".
  /// Rafu zenye hadithi **halisi** pekee.
  ///
  /// **Kwa nini hii ipo:** Maktaba ilikuwa ikionyesha rafu zote za enum,
  /// hata zile zisizo na hadithi hata moja — mtoto alibofya kadi tupu.
  /// Sasa kile kinachoonyeshwa ni kile kilicho na maudhui.
  static List<StoryShelf> get activeShelves {
    final Set<StoryShelf> used = <StoryShelf>{};
    for (final Story story in all) {
      used.addAll(story.shelves);
    }
    return StoryShelf.values
        .where((StoryShelf shelf) => used.contains(shelf))
        .toList();
  }

  /// Idadi ya hadithi kwenye rafu fulani.
  static int countInShelf(StoryShelf shelf) =>
      all.where((Story s) => s.shelves.contains(shelf)).length;

  static final List<Story> all = <Story>[
    // =====================================================================
    // 1. Safari ya Simba — hadithi ya kwanza kabisa (Nyumbani, "Hadithi ya Leo")
    // =====================================================================
    const Story(
      id: 'safari-ya-simba',
      titleSw: 'Safari ya Simba',
      titleEn: "Simba's Safari",
      synopsisSw:
          'Simba anaamka asubuhi moja na kuamua kwenda safari. Njiani '
          'anakutana na Twiga, Tembo na Sungura — na anajifunza kwamba '
          'safari nzuri kuliko zote ni ile unayosafiri na marafiki.',
      synopsisEn:
          'Simba wakes up one morning and decides to go on a safari. Along '
          'the way he meets Giraffe, Elephant and Hare — and learns that the '
          'best safari of all is the one you take with friends.',
      author: 'Hadithi za Jadi',
      category: StoryCategory.ngano,
      ageGroup: AgeGroup.miaka_3_5,
      readingLevel: ReadingLevel.mtoto_mdogo,
      coverAsset: 'assets/images/stories/safari_ya_simba_cover.webp',
      accent: AppColors.safariGreen,
      shelves: <StoryShelf>[
        StoryShelf.animalStories,
        StoryShelf.safari,
      ],
      rating: 4.8,
      readCount: 1240,
      pages: <StoryPage>[
        StoryPage(
          textSw: 'Simba aliamka asubuhi mapema. Jua lilikuwa linachomoza '
              'juu ya Serengeti. "Leo nitaenda safari!" alisema Simba kwa '
              'furaha.',
          textEn: 'Simba woke up early one morning. The sun was rising over '
              'the Serengeti. "Today I am going on a safari!" said Simba '
              'happily.',
          illustration: 'assets/images/stories/pages/safari-ya-simba/page_01.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.sound_effect,
              labelSw: 'Jua',
              labelEn: 'The Sun',
              revealSw: 'Jua la Serengeti huamsha kila kitu asubuhi!',
              revealEn: 'The Serengeti sun wakes everything up in the '
                  'morning!',
              left: 0.06,
              top: 0.05,
              width: 0.26,
              height: 0.20,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Njiani alikutana na Twiga. "Habari Twiga! Ungependa kuja '
              'nami?" Twiga aliinua shingo yake ndefu na kutabasamu. '
              '"Ndiyo, lakini mimi hukimbia pole pole," alisema.',
          textEn: 'On the way he met Giraffe. "Hello Giraffe! Would you like '
              'to come with me?" Giraffe raised her long neck and smiled. '
              '"Yes, but I run quite slowly," she said.',
          illustration: 'assets/images/stories/pages/safari-ya-simba/page_02.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.character_speak,
              labelSw: 'Twiga',
              labelEn: 'Giraffe',
              revealSw: 'Twiga ana shingo ndefu ili afikie majani ya juu '
                  'kwenye miti.',
              revealEn: 'A giraffe has a long neck so she can reach the '
                  'highest leaves on the trees.',
              left: 0.52,
              top: 0.10,
              width: 0.34,
              height: 0.48,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Wakasafiri pamoja. Walikutana na Tembo. "Karibuni '
              'marafiki!" alisema Tembo kwa sauti kubwa. Tembo alitembea '
              'mbele yao, akifungua njia kwa mwili wake mkubwa.',
          textEn: 'They travelled on together. They met Elephant. "Welcome, '
              'friends!" said Elephant in a big voice. Elephant walked in '
              'front of them, opening the path with his huge body.',
          illustration: 'assets/images/stories/pages/safari-ya-simba/page_03.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.sound_effect,
              labelSw: 'Tembo',
              labelEn: 'Elephant',
              revealSw: 'Tembo hunywa maji kwa lita nyingi kwa siku moja. '
                  'Ndiyo mnyama mkubwa zaidi ardhini!',
              revealEn: 'An elephant drinks many litres of water a day. He '
                  'is the biggest animal on land!',
              left: 0.20,
              top: 0.22,
              width: 0.50,
              height: 0.50,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Hapo walikutana na Sungura mdogo. "Msiende upande ule!" '
              'alisema Sungura. "Mto umejaa maji, na mvua inakuja." Simba '
              'alimsikiliza Sungura.',
          textEn: 'Then they met little Hare. "Do not go that way!" said '
              'Hare. "The river is full, and rain is coming." Simba listened '
              'to Hare.',
          illustration: 'assets/images/stories/pages/safari-ya-simba/page_04.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.info_popup,
              labelSw: 'Sungura',
              labelEn: 'Hare',
              revealSw: 'Sungura ni mdogo, lakini ni mwerevu. Sikiliza '
                  'wadogo — wanaweza kuona kile tusichokiona.',
              revealEn: 'Hare is small, but he is clever. Listen to the '
                  'small ones — they may see what we cannot.',
              left: 0.30,
              top: 0.40,
              width: 0.36,
              height: 0.40,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Mvua ikanyesha! Wote wakakimbia mpaka kwenye pango. '
              'Wakati mvua inanyesha, Twiga alisimulia hadithi, Tembo '
              'akaimba, na Sungura akachekesha kila mtu.',
          textEn: 'The rain came down! They all ran to a cave. While the '
              'rain fell, Giraffe told stories, Elephant sang, and Hare '
              'made everyone laugh.',
          illustration: 'assets/images/stories/pages/safari-ya-simba/page_05.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.animation,
              labelSw: 'Pango',
              labelEn: 'The Cave',
              revealSw: 'Pango ni kimbilio zuri. Mbingu ikifunguka, tafuta '
                  'mahali pakavu!',
              revealEn: 'A cave is a good shelter. When the sky opens up, '
                  'find somewhere dry!',
              left: 0.58,
              top: 0.28,
              width: 0.32,
              height: 0.42,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Jioni walirudi nyumbani wote pamoja. "Safari nzuri '
              'kuliko zote," alisema Simba, "ni ile unayosafiri na '
              'marafiki." Kisha akalala chini ya mti, akiwa na furaha.',
          textEn: 'In the evening they all went home together. "The best '
              'safari of all," said Simba, "is the one you take with '
              'friends." Then he lay down under a tree, happy.',
          illustration: 'assets/images/stories/pages/safari-ya-simba/page_06.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.character_speak,
              labelSw: 'Simba',
              labelEn: 'Simba',
              revealSw: 'Simba ana nguvu, lakini anakumbuka kila mara: '
                  'furaha ni kuwa na marafiki.',
              revealEn: 'Simba is strong, but he always remembers: joy is '
                  'having friends.',
              left: 0.34,
              top: 0.42,
              width: 0.32,
              height: 0.38,
            ),
          ],
        ),
      ],
    ),

    // =====================================================================
    // 2. Mlima Kilimanjaro — makundi: Utamaduni + Sayansi
    // =====================================================================
    const Story(
      id: 'mlima-kilimanjaro',
      titleSw: 'Mlima Kilimanjaro',
      titleEn: 'Mount Kilimanjaro',
      synopsisSw:
          'Safari ya kupanda mlima mrefu zaidi Afrika. Neema na babu yake '
          'wanatembea kwa miguu kutoka msituni, hadi jangwani, hadi theluji '
          'ya kilele — na babu anasimulia hadithi ya mlima.',
      synopsisEn:
          'A climb up the tallest mountain in Africa. Neema and her '
          'grandfather walk from the forest, through the desert, up to the '
          'snow at the summit — and Grandfather tells the story of the '
          'mountain.',
      author: 'Juma Mkoba',
      category: StoryCategory.historia_ya_tanzania,
      ageGroup: AgeGroup.miaka_6_8,
      readingLevel: ReadingLevel.darasa_1_2,
      coverAsset: 'assets/images/stories/mlima_kilimanjaro_cover.webp',
      accent: AppColors.kilimanjaroBlue,
      shelves: <StoryShelf>[
        StoryShelf.culture,
        StoryShelf.science,
      ],
      rating: 4.7,
      readCount: 980,
      pages: <StoryPage>[
        StoryPage(
          textSw: 'Kilimanjaro ni mlima mrefu zaidi barani Afrika. Uko '
              'Tanzania, karibu na mji wa Moshi. Mlima huu una kilele '
              'kinachoitwa Kibo, juu sana angani.',
          textEn: 'Kilimanjaro is the tallest mountain in Africa. It stands '
              'in Tanzania, near the town of Moshi. The mountain has a peak '
              'called Kibo, very high in the sky.',
          illustration: 'assets/images/stories/pages/mlima-kilimanjaro/page_01.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.info_popup,
              labelSw: 'Kibo',
              labelEn: 'Kibo',
              revealSw: 'Kibo iko mita 5,895 juu ya bahari. Ni moja ya '
                  'vinara saba vya dunia.',
              revealEn: 'Kibo stands 5,895 metres above sea level. It is one '
                  'of the seven summits of the world.',
              left: 0.34,
              top: 0.08,
              width: 0.32,
              height: 0.30,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Neema alienda na babu yake. "Babu, kwa nini kilele '
              'kina theluji wakati hapa kuna joto?" aliuliza. Babu '
              'alicheka. "Kwa sababu juu ni baridi kushinda chini," '
              'alisema.',
          textEn: 'Neema went with her grandfather. "Babu, why does the '
              'peak have snow when it is hot down here?" she asked. '
              'Grandfather laughed. "Because up there it is colder than '
              'down here," he said.',
          illustration: 'assets/images/stories/pages/mlima-kilimanjaro/page_02.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.info_popup,
              labelSw: 'Theluji',
              labelEn: 'Snow',
              revealSw: 'Kila unapopanda juu, hewa inakuwa baridi. Kileleni '
                  'huwa na theluji hata karibu na ikweta!',
              revealEn: 'The higher you climb, the colder the air. The peak '
                  'has snow even though it is near the equator!',
              left: 0.50,
              top: 0.12,
              width: 0.36,
              height: 0.36,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Wakaanza kupanda. Kwanza msitu wenye mvua — miti mirefu '
              'na nyani wanaoruka. Kisha nyasi na maua ya rangi nyingi. '
              'Kisha jangwa la mawe.',
          textEn: 'They began to climb. First a rainy forest — tall trees '
              'and monkeys leaping. Then grass and flowers of many colours. '
              'Then a desert of stones.',
          illustration: 'assets/images/stories/pages/mlima-kilimanjaro/page_03.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.mini_game,
              labelSw: 'Msitu',
              labelEn: 'The Forest',
              revealSw: 'Kuna misitu mitano tofauti kwenye Kilimanjaro — '
                  'kila mmoja na wanyama wake!',
              revealEn: 'There are five different forests on Kilimanjaro — '
                  'each with its own animals!',
              left: 0.08,
              top: 0.18,
              width: 0.40,
              height: 0.46,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Usiku walipumzika kwenye kambi. Neema aliangalia juu. '
              '"Babu, nyota ni nyingi kuliko nilivyodhani!" Babu alimwambia '
              'kwamba watu wa kale walitumia nyota kupata njia.',
          textEn: 'At night they rested at a camp. Neema looked up. "Babu, '
              'there are more stars than I thought!" Grandfather told her '
              'that people long ago used the stars to find their way.',
          illustration: 'assets/images/stories/pages/mlima-kilimanjaro/page_04.webp',
        ),
        StoryPage(
          textSw: 'Baridi ilizidi, lakini walifika kileleni asubuhi. '
              'Theluji iling\'aa kama chumvi. Neema aligusa na kupiga '
              'kelele: "Baridi!" Babu alicheka tena.',
          textEn: 'The cold grew, but they reached the summit in the '
              'morning. The snow shone like salt. Neema touched it and '
              'shouted: "It is cold!" Grandfather laughed again.',
          illustration: 'assets/images/stories/pages/mlima-kilimanjaro/page_05.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.sound_effect,
              labelSw: 'Kilele',
              labelEn: 'The Summit',
              revealSw: 'Kutoka kileleni unaweza kuona Tanzania yote — '
                  'milima, maziwa na nyanda!',
              revealEn: 'From the summit you can see all of Tanzania — '
                  'mountains, lakes and plains!',
              left: 0.30,
              top: 0.30,
              width: 0.42,
              height: 0.44,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Walishuka wakiwa na furaha. "Mlima ni mrefu," alisema '
              'Neema, "lakini hatua moja kwa wakati mmoja unafika." Babu '
              'alimkumbatia.',
          textEn: 'They came down happy. "The mountain is tall," said '
              'Neema, "but one step at a time, you arrive." Grandfather '
              'hugged her.',
          illustration: 'assets/images/stories/pages/mlima-kilimanjaro/page_06.webp',
        ),
      ],
    ),

    // =====================================================================
    // 3. Nyota za Usiku — kadi ya pili ya "Hadithi Bora" kwenye Nyumbani
    // =====================================================================
    const Story(
      id: 'nyota-za-usiku',
      titleSw: 'Nyota za Usiku',
      titleEn: 'Stars of the Night',
      synopsisSw:
          'Baraka anaishi kijijini ambako hakuna umeme. Usiku mmoja bibi '
          'yake anamwonyesha kwamba anga ni ramani ya zamani kuliko vitabu '
          'vyote — na kila swali huzaa jibu jingine.',
      synopsisEn:
          'Baraka lives in a village with no electricity. One night his '
          'grandmother shows him that the sky is a map older than any book '
          '— and that every question gives birth to another.',
      author: 'Hadithi za Jadi',
      category: StoryCategory.maadili,
      ageGroup: AgeGroup.miaka_6_8,
      readingLevel: ReadingLevel.darasa_1_2,
      coverAsset: 'assets/images/stories/nyota_za_usiku_cover.webp',
      accent: AppColors.purpleFun,
      shelves: <StoryShelf>[
        StoryShelf.moralsWisdom,
        StoryShelf.science,
      ],
      rating: 4.6,
      readCount: 720,
      pages: <StoryPage>[
        StoryPage(
          textSw: 'Kijiji chetu hakina umeme. Usiku, tunaketi nje kwenye '
              'mkeka na kuangalia juu. Bibi alisema, "Anga ndiyo runinga ya '
              'watu wa kale."',
          textEn: 'Our village has no electricity. At night we sit outside '
              'on a mat and look up. Grandmother said, "The sky is the '
              'television of the old people."',
          illustration: 'assets/images/stories/pages/nyota-za-usiku/page_01.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.sound_effect,
              labelSw: 'Nyota',
              labelEn: 'The Stars',
              revealSw: 'Nyota hazitoki na kuzima. Zinawaka usiku kwa sababu '
                  'jua linapokwenda, giza linatuwezesha kuziona.',
              revealEn: 'Stars do not switch on and off. They shine at night '
                  'because when the sun goes away, the dark lets us see '
                  'them.',
              left: 0.08,
              top: 0.06,
              width: 0.84,
              height: 0.26,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Nilimuuliza bibi, "Nyota ni ngapi?" Bibi alicheka. '
              '"Zaidi ya mchanga wa bahari. Watu wa kale walizipanga kama '
              'picha angani."',
          textEn: 'I asked grandmother, "How many stars are there?" '
              'Grandmother laughed. "More than the sand of the sea. Long ago '
              'people arranged them like pictures in the sky."',
          illustration: 'assets/images/stories/pages/nyota-za-usiku/page_02.webp',
        ),
        StoryPage(
          textSw: 'Bibi alinyoosha kidole. "Unaona nyota nne zilizoungana '
              'kama msalaba? Hiyo ni Msalaba wa Kusini. Kama ukiifuata, '
              'unapata upande wa kusini."',
          textEn: 'Grandmother pointed. "Do you see four stars joined like '
              'a cross? That is the Southern Cross. If you follow it, you '
              'find the south."',
          illustration: 'assets/images/stories/pages/nyota-za-usiku/page_03.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.info_popup,
              labelSw: 'Msalaba wa Kusini',
              labelEn: 'The Southern Cross',
              revealSw: 'Wasafiri na mabaharia wa kale walitumia Msalaba wa '
                  'Kusini kutafuta njia baharini. Hauonekani Ulaya — ni '
                  'nyota yetu ya kusini!',
              revealEn: 'Travellers and sailors long ago used the Southern '
                  'Cross to find their way at sea. It cannot be seen in '
                  'Europe — it is our star of the south!',
              left: 0.30,
              top: 0.10,
              width: 0.38,
              height: 0.34,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Nikamuuliza, "Kwa nini mwezi unabadilika umbo?" Bibi '
              'alisema, "Mwezi unazunguka dunia. Jua linawaka upande mmoja '
              'tu, kwa hivyo tunaona sehemu tofauti kila usiku."',
          textEn: 'I asked her, "Why does the moon change shape?" '
              'Grandmother said, "The moon goes around the earth. The sun '
              'lights only one side, so we see a different part each '
              'night."',
          illustration: 'assets/images/stories/pages/nyota-za-usiku/page_04.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.animation,
              labelSw: 'Mwezi',
              labelEn: 'The Moon',
              revealSw: 'Mwezi mweusi haupotei — upo tu mahali ambapo jua '
                  'haliwezi kuufikia.',
              revealEn: 'The dark moon does not disappear — it is simply '
                  'where the sun cannot reach it.',
              left: 0.58,
              top: 0.16,
              width: 0.30,
              height: 0.30,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Usiku ule nilijifunza kitu kikubwa: kila kitu ninachojua '
              'kilianza na swali moja. Nikaamua kuwa mtaalam wa nyota.',
          textEn: 'That night I learned something big: everything I know '
              'began with one question. I decided to become a star '
              'scientist.',
          illustration: 'assets/images/stories/pages/nyota-za-usiku/page_05.webp',
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.character_speak,
              labelSw: 'Bibi',
              labelEn: 'Grandmother',
              revealSw: '"Swali ni funguo. Usiogope kuuliza hata ukikutwa '
                  'ukicheka."',
              revealEn: '"A question is a key. Never be afraid to ask, even '
                  'if someone laughs."',
              left: 0.14,
              top: 0.34,
              width: 0.32,
              height: 0.40,
            ),
          ],
        ),
      ],
    ),

    // =====================================================================
    // 4. Ngoma ya Furaha — kadi ya tatu ya "Hadithi Bora" kwenye Nyumbani
    // =====================================================================
    const Story(
      id: 'ngoma-ya-furaha',
      titleSw: 'Ngoma ya Furaha',
      titleEn: 'The Happy Drum',
      synopsisSw:
          'Ngoma kubwa ilikaa kimya kwa miaka mingi. Siku moja Juma '
          'aliipiga mara moja — na sauti ile ikawakusanya watu wote wa '
          'kijiji walioachana kwa muda mrefu.',
      synopsisEn:
          'A big drum had stayed silent for many years. One day Juma struck '
          'it once — and that sound gathered all the villagers who had '
          'grown apart.',
      author: 'Fatuma Ally',
      category: StoryCategory.sanaa,
      ageGroup: AgeGroup.miaka_6_8,
      readingLevel: ReadingLevel.darasa_1_2,
      coverAsset: 'assets/images/stories/ngoma_ya_furaha_cover.webp',
      accent: AppColors.kangaOrange,
      shelves: <StoryShelf>[
        StoryShelf.poemsSongs,
        StoryShelf.culture,
      ],
      rating: 4.5,
      readCount: 640,
      pages: <StoryPage>[
        StoryPage(
          textSw: 'Kwenye ukumbi wa kijiji kulikuwa na ngoma kubwa. Ilikuwa '
              'imetulia kimya kwa miaka mingi. Kila mtu alikuwa na shughuli '
              'zake, na hakuna aliyekumbuka kuipiga.',
          textEn: 'In the village hall there was a big drum. It had rested '
              'silent for many years. Everyone had their own work, and '
              'nobody remembered to strike it.',
          illustration: _Art.songs,
        ),
        StoryPage(
          textSw: 'Juma alipapasa vumbi kwa kitambaa. Akapiga mara moja: '
              '"Pa!" Sauti ikatoka ukumbini, ikavuka uwanja, ikafika '
              'shambani.',
          textEn: 'Juma wiped the dust away with a cloth. He struck it once: '
              '"Pa!" The sound left the hall, crossed the playground and '
              'reached the fields.',
          illustration: _Art.songs,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.sound_effect,
              labelSw: 'Ngoma',
              labelEn: 'The Drum',
              revealSw: 'Ngoma hii imetengenezwa kwa mti wa mvule, ngozi ya '
                  'mbuzi na kamba za ngozi. Kwa hivyo sauti yake ni nzito '
                  'na ndefu.',
              revealEn: 'This drum is made from mvule wood, goatskin and '
                  'leather cords. That is why its sound is deep and long.',
              left: 0.26,
              top: 0.18,
              width: 0.46,
              height: 0.50,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Mzee Hamisi alifika mbio. "Hii ni ngoma ya babu yangu!" '
              'alisema. Akamfundisha Juma mdundo: "Kamoja, kamoja, pawili." '
              'Juma alijaribu, akakosea, akajaribu tena.',
          textEn: 'Mzee Hamisi arrived at a run. "This is my grandfather\'s '
              'drum!" he said. He taught Juma the rhythm: "Once, once, '
              'twice." Juma tried, made a mistake, and tried again.',
          illustration: _Art.culture,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.mini_game,
              labelSw: 'Mdundo',
              labelEn: 'The Rhythm',
              revealSw: 'Jaribu kupiga makofi: KAMOJA, KAMOJA, PAWILI. '
                  'Mdundo ni lugha — hauhitaji maneno!',
              revealEn: 'Try clapping: ONCE, ONCE, TWICE. Rhythm is a '
                  'language — it needs no words!',
              left: 0.10,
              top: 0.44,
              width: 0.30,
              height: 0.34,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Watu walifika wengi. Mama walichemsha chai, watoto '
              'walicheza, bibi alipiga nyimbo za zamani. Uani palikuwa na '
              'furaha ambayo haikuwepo kwa muda mrefu.',
          textEn: 'Many people came. Mothers made tea, children played, '
              'grandmothers sang the old songs. There was a joy in the yard '
              'that had been missing for a long time.',
          illustration: _Art.hero,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.animation,
              labelSw: 'Wanacheza',
              labelEn: 'The Dancers',
              revealSw: 'Ngoma hukusanya watu wa umri wote mahali pamoja — '
                  'ndiyo maana ni sehemu ya utamaduni wetu.',
              revealEn: 'A drum brings people of every age together in one '
                  'place — that is why it is part of our culture.',
              left: 0.34,
              top: 0.30,
              width: 0.42,
              height: 0.44,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Juma alijifunza kwamba ngoma moja hupiga mioyo mingi. '
              'Kuanzia siku ile, kila Jumamosi, kijiji chetu hupiga ngoma '
              'pamoja.',
          textEn: 'Juma learned that one drum plays many hearts. From that '
              'day on, every Saturday, our village drums together.',
          illustration: _Art.songs,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.character_speak,
              labelSw: 'Juma',
              labelEn: 'Juma',
              revealSw: '"Ngoma moja, mioyo mingi."',
              revealEn: '"One drum, many hearts."',
              left: 0.18,
              top: 0.36,
              width: 0.32,
              height: 0.34,
            ),
          ],
        ),
      ],
    ),

    // =====================================================================
    // 5. Kuku na Mwewe — ngano ya jadi; rafu ya wanyama na ya maadili
    // =====================================================================
    const Story(
      id: 'kuku-na-mwewe',
      titleSw: 'Kuku na Mwewe',
      titleEn: 'The Hen and the Hawk',
      synopsisSw:
          'Zamani Kuku na Mwewe walikuwa marafiki na majirani. Kuku '
          'aliazima sindano ya Mwewe, akaipoteza — na hapo ndipo '
          'ufugaji wetu wa kuku ulipoanza kuchimba udongo.',
      synopsisEn:
          'Long ago Hen and Hawk were friends and neighbours. Hen borrowed '
          'Hawk\'s needle and lost it — and that is how our hens began '
          'scratching the ground.',
      author: 'Hadithi za Jadi',
      category: StoryCategory.ngano,
      ageGroup: AgeGroup.miaka_3_5,
      readingLevel: ReadingLevel.mtoto_mdogo,
      coverAsset: 'assets/images/stories/kuku_na_mwewe_cover.webp',
      accent: AppColors.brightGreen,
      shelves: <StoryShelf>[
        StoryShelf.animalStories,
        StoryShelf.moralsWisdom,
      ],
      rating: 4.4,
      readCount: 1560,
      pages: <StoryPage>[
        StoryPage(
          textSw: 'Zamani sana, Kuku na Mwewe walikuwa majirani. Wakakaa '
              'pamoja, wakala pamoja, wakacheka pamoja.',
          textEn: 'Long, long ago, Hen and Hawk were neighbours. They sat '
              'together, ate together and laughed together.',
          illustration: _Art.animals,
        ),
        StoryPage(
          textSw: 'Siku moja Kuku alitaka kushona mfuko wa nafaka. Akamwomba '
              'Mwewe, "Niazime sindano yako." Mwewe alimpa kwa furaha.',
          textEn: 'One day Hen wanted to sew a grain bag. She asked Hawk, '
              '"Lend me your needle." Hawk gave it to her happily.',
          illustration: _Art.animals,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.character_speak,
              labelSw: 'Mwewe',
              labelEn: 'Hawk',
              revealSw: '"Nitumie kesho," alisema Mwewe. Kuku alisahau '
                  'kuahidi.',
              revealEn: '"Send it back tomorrow," said Hawk. Hen forgot to '
                  'promise.',
              left: 0.52,
              top: 0.16,
              width: 0.36,
              height: 0.38,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Kuku alishona, akashona, akashona. Ghafla sindano '
              'ikaanguka kwenye nyasi. Akaichimba, akaichimba — haikuonekana. '
              'Ndiyo maana kuku huchimba udongo hata leo.',
          textEn: 'Hen sewed and sewed and sewed. Suddenly the needle fell '
              'into the grass. She scratched and scratched — it was not '
              'there. That is why hens scratch the ground even today.',
          illustration: _Art.animals,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.sound_effect,
              labelSw: 'Kuku',
              labelEn: 'The Hen',
              revealSw: 'Kuku hutafuta chakula kwa kuchimba udongo — na '
                  'kwa kuwa sindano ilipotea huko, huchimba kila siku.',
              revealEn: 'Hens look for food by scratching the ground — and '
                  'since the needle was lost there, they scratch every day.',
              left: 0.08,
              top: 0.42,
              width: 0.36,
              height: 0.44,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Mwewe alikuja kwa sindano yake. Kuku hakuwa na kitu cha '
              'kumpa. "Nilikuamini!" Mwewe alilia kwa hasira. "Kuanzia leo '
              'nitakufuata milele."',
          textEn: 'Hawk came for her needle. Hen had nothing to give. "I '
              'trusted you!" Hawk cried angrily. "From today I will chase '
              'you forever."',
          illustration: _Art.animals,
        ),
        StoryPage(
          textSw: 'Kuanzia siku ile, kila Mwewe aonapo kuku anawafukuza. '
              'Tunapowaona angani, tunakumbuka: kile ulichoazima, kirudishe.',
          textEn: 'From that day, whenever Hawk sees hens he chases them. '
              'When we see him in the sky, we remember: return what you '
              'borrow.',
          illustration: _Art.hero,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.info_popup,
              labelSw: 'Somo',
              labelEn: 'The Lesson',
              revealSw: 'Karibu ngano zote za Kiswahili zina somo moja: '
                  'uaminifu ni mali.',
              revealEn: 'Almost every Swahili folktale carries one lesson: '
                  'trustworthiness is wealth.',
              left: 0.56,
              top: 0.08,
              width: 0.36,
              height: 0.30,
            ),
          ],
        ),
      ],
    ),

    // =====================================================================
    // 6. Chapati za Mama — hadithi ya maadili kwa watoto wakubwa
    // =====================================================================
    const Story(
      id: 'chapati-za-mama',
      titleSw: 'Chapati za Mama',
      titleEn: 'Mama\'s Chapati',
      synopsisSw:
          'Zawadi ana miaka kumi na anataka kujifunza kupika chapati. '
          'Siku moja anagundua kwamba chapati ya kwanza ni ya kujifunza, '
          'na ile ya pili ni ya kushiriki.',
      synopsisEn:
          'Zawadi is ten and wants to learn to cook chapati. One day she '
          'discovers that the first chapati is for learning, and the second '
          'is for sharing.',
      author: 'Neema Kessy',
      category: StoryCategory.maadili,
      ageGroup: AgeGroup.miaka_9_12,
      readingLevel: ReadingLevel.darasa_3_4,
      coverAsset: 'assets/images/stories/chapati_za_mama_cover.webp',
      accent: AppColors.spiceRed,
      shelves: <StoryShelf>[
        StoryShelf.culture,
        StoryShelf.moralsWisdom,
      ],
      rating: 4.6,
      readCount: 830,
      pages: <StoryPage>[
        StoryPage(
          textSw: 'Kila Ijumaa jioni, mama yangu hupika chapati. Harufu '
              'yake huenea kwenye mtaa mzima wa Arusha. Siku moja '
              'nikamwambia, "Mama, nifundishe."',
          textEn: 'Every Friday evening my mother cooks chapati. Its smell '
              'spreads through the whole street in Arusha. One day I told '
              'her, "Mama, teach me."',
          illustration: _Art.create,
        ),
        StoryPage(
          textSw: 'Mama alipima unga kwa kikombe: vikombe vitatu vya unga, '
              'kikombe kimoja cha maji ya moto, chumvi kidogo. Nilihesabu '
              'kwa sauti. Hesabu ya jikoni ni hesabu halisi.',
          textEn: 'Mama measured the flour with a cup: three cups of flour, '
              'one cup of hot water, a little salt. I counted out loud. '
              'Kitchen counting is real counting.',
          illustration: _Art.create,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.info_popup,
              labelSw: 'Kipimo',
              labelEn: 'The Measure',
              revealSw: 'Majiya moto hufanya unga laini. Kwa hivyo chapati '
                  'hupatapata na kuvimba unapoiweka kwenye kikaango.',
              revealEn: 'Hot water makes the dough soft. That is why chapati '
                  'puffs up when you put it on the pan.',
              left: 0.10,
              top: 0.30,
              width: 0.34,
              height: 0.36,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Mama alifunika unga kwa kitambaa. "Tusubiri dakika '
              'ishirini," alisema. Nilisubiri, nikasubiri. "Unga unahitaji '
              'kupumzika," aliniambia, "kama sisi tu."',
          textEn: 'Mama covered the dough with a cloth. "Let us wait twenty '
              'minutes," she said. I waited and waited. "Dough needs to '
              'rest," she told me, "just like us."',
          illustration: _Art.listen,
        ),
        StoryPage(
          textSw: 'Nikaanza kusukuma kwa mti wa kusukuma. Chapati ya kwanza '
              'ikaungua, ikawa nyeusi. Nikaona aibu. Mama alicheka: "Hata '
              'mimi nilichoma cha kwanza."',
          textEn: 'I began to roll with the rolling pin. My first chapati '
              'burned and turned black. I felt ashamed. Mama laughed: "Even '
              'I burned my first one."',
          illustration: _Art.songs,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.character_speak,
              labelSw: 'Mama',
              labelEn: 'Mama',
              revealSw: '"Kukosea si kushindwa. Kukosea ni kujifunza kwa '
                  'macho."',
              revealEn: '"Making a mistake is not failing. A mistake is '
                  'learning with your eyes."',
              left: 0.52,
              top: 0.34,
              width: 0.38,
              height: 0.38,
            ),
          ],
        ),
        StoryPage(
          textSw: 'Chapati ya tano ikawa nzuri — duara, laini, yenye harufu '
              'nzuri. Mama akachukua nne, akaiweka kwenye sinia, na '
              'tukampelekea Bwana Salum mgonjwa.',
          textEn: 'The fifth chapati turned out well — round, soft and '
              'sweet-smelling. Mama took four, put them on a tray, and we '
              'carried them to the sick Bwana Salum.',
          illustration: _Art.language,
        ),
        StoryPage(
          textSw: 'Bwana Salum alifungua mlango, akaona sinia, akatabasamu '
              'hata macho yakamngaa. Nikaandika kwenye daftari langu: '
              'chapati ya pili ni ya kushiriki.',
          textEn: 'Bwana Salum opened the door, saw the tray, and smiled '
              'until his eyes shone. I wrote in my notebook: the second '
              'chapati is for sharing.',
          illustration: _Art.morals,
          hotspots: <StoryHotspot>[
            StoryHotspot(
              type: HotspotType.story_choice,
              labelSw: 'Uamuzi',
              labelEn: 'Your Choice',
              revealSw: 'Kama ungekuwa na chapati nne, ungempa nani? '
                  'Andika jibu lako kwenye daftari.',
              revealEn: 'If you had four chapatis, who would you give them '
                  'to? Write your answer in your notebook.',
              left: 0.14,
              top: 0.40,
              width: 0.40,
              height: 0.40,
            ),
          ],
        ),
      ],
    ),

    // =====================================================================
    // 7-10. Hadithi mpya (2026-10-18) — kujaza makundi yaliyokuwa matupu.
    // Kila moja ina faili yake (`story_*.dart`) na michoro yake 4.
    // =====================================================================
    storyKifaruMdogo,
    storyTwigaMrefu,
    storyMtiWaBabu,
    storySafariYaMatone,
  ];
}
