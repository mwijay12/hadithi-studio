/// Rafu (shelf) za Maktaba — makundi ambayo mtoto huchagua kwa **picha**.
///
/// ## Kwa nini enum ya pekee, wakati `StoryCategory` ipo tayari?
///
/// Ni vitu viwili tofauti, na kuvichanganya kungeharibu mmoja wao:
///
/// * `StoryCategory` (`core/enums/app_enums.dart`) ni **uainishaji wa
///   kihariri** — maneno 14 yanayotumika kwenye metadata ya hadithi, API
///   (`/api/v1/stories/category/:slug`) na kwenye dodoso la mwandishi.
/// * `StoryShelf` ni **rafu ya kuonekana**: vitufe sita tu ambavyo mtoto wa
///   miaka 3–8 anaweza kutofautisha kwa picha moja. "Hadithi za Wanyama" ni
///   rafu; `ngano`, `maadili` na `burudani` zinaweza kuwa hadithi za wanyama
///   zote tatu.
///
/// Kwa hivyo hadithi moja inaweza kukaa kwenye **rafu zaidi ya moja** —
/// `Story.shelves` ni orodha, na `sungura` anaweza kuwa kwenye
/// [animalStories] **na** [moralsWisdom] kwa wakati mmoja. Hii inaendana na
/// jinsi mzazi husema "hii ni hadithi ya wanyama *na* ya maadili".
///
/// ## Kwa nini `asset` na `accent` ziko hapa
///
/// Rafu ni kitu cha **kudumu**: picha yake na rangi yake hazitofautiani
/// kwenye Maktaba, kwenye ukurasa wa rafu, na kwenye Mwongozo. Kuziweka
/// pamoja na `id` kunazuia faili tatu kuwa na nakala tatu za njia ile ile
/// ya picha — na kuzipotosha zote siku moja Picha inapobadilishwa.
///
/// **Lebo haipo hapa.** Lebo (`catAnimalStories` n.k.) zinatoka ARB, kwa
/// hivyo hazina mahali kwenye domain. `storyShelfLabel(l10n, shelf)` kwenye
/// `presentation/widgets/shelf_tile.dart` ndiyo mahali pamoja panaposoma
/// `context.l10n`.
library;

import 'package:flutter/painting.dart';

import '../../../../config/theme/colors.dart';

/// Rafu sita za Maktaba — mpangilio unafuata mpangilio wa vitufe.
enum StoryShelf {
  /// Hadithi za wanyama — ngano nyingi za Tanzania ni za wanyama.
  animalStories(
    'animal-stories',
    'assets/images/categories/cat_animal_stories.png',
    AppColors.brightGreen,
  ),

  /// Maadili na hekima — hadithi zinazofundisha tabia njema.
  moralsWisdom(
    'morals-wisdom',
    'assets/images/categories/cat_morals_wisdom.png',
    AppColors.zanzibarTurquoise,
  ),

  /// Sayansi kwa watoto — mwili, wanyama, mimea, anga.
  science(
    'science',
    'assets/images/categories/cat_science.png',
    AppColors.skyBlue,
  ),

  /// Utamaduni wa Tanzania — historia, desturi, makabila, sikukuu.
  culture(
    'culture',
    'assets/images/categories/cat_culture.png',
    AppColors.spiceRed,
  ),

  /// Mashairi na nyimbo — kanga, ngoma, nyimbo za kazi.
  poemsSongs(
    'poems-songs',
    'assets/images/categories/cat_poems_songs.png',
    AppColors.purpleFun,
  ),

  /// Safari na vituko — matukio, ushujaa, vituko.
  safari(
    'safari',
    'assets/images/categories/cat_safari.png',
    AppColors.kangaOrange,
  );

  const StoryShelf(this.id, this.asset, this.accent);

  /// Kitambulisho kinachotumika kwenye URL: `/category/animal-stories`.
  ///
  /// Ni `id` ya mkono (si `name`) kwa sababu ni sehemu ya URL yenye watu
  /// wanaweza kuishiriki; kubadilisha `name` ya Dart basi kusingevunja kiungo
  /// chochote, lakini kubadilisha `id` kungevunja.
  final String id;

  /// Picha ya rafu — ile ile inayoonekana kwenye kadi.
  final String asset;

  /// Rangi ya rafu — kivuli, badge na akiba ya picha.
  final Color accent;

  /// Hupata rafu kutoka `id` ya URL. `null` = id haijulikani.
  ///
  /// Hurudisha `null` badala ya rafu ya default kwa makusudi: kiungo
  /// kisichojulikana kinapaswa kuonyesha "kundi halipo", si kumtupa mtumiaji
  /// kwenye rafu isiyo sahihi bila kumwambia.
  static StoryShelf? fromId(String id) {
    for (final StoryShelf shelf in StoryShelf.values) {
      if (shelf.id == id) return shelf;
    }
    return null;
  }
}
