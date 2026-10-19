/// Mkataba kati ya presentation na data — kwa ajili ya hadithi.
///
/// ## Kwa nini `Either<Failure, T>` na si exceptions
///
/// Kanuni ya 6: kila mwito unaweza kushindwa hurudisha
/// `Either<Failure, Success>`. Sababu ni ya kibinadamu, si ya kinadharia:
/// Tanzania ina 2G/3G isiyoaminika, kwa hivyo "haikufanikiwa" ni **hali ya
/// kawaida**, si dharura. `Failure` ina ujumbe kwa Kiswahili **na**
/// Kiingereza (`failure.message(swahili: …)`), kwa hivyo `presentation`
/// haihitaji kutafsiri kosa — inaonyesha lile lililotolewa.
///
/// ## Kwa nini `Future` wakati data ni ya ndani
///
/// Kwa sasa data inatoka kwenye faili la ndani (`StorySampleData`) na
/// haihitaji mtandao. Lakini mkataba huu ni **wa kudumu**: API ya
/// `/api/v1/stories` itachukua nafasi hiyo bila kubadilisha mkataba huu na
/// bila kugusa UI. Kutumia `Future` mapema kunamaanisha kwamba siku hiyo ni
/// mabadiliko ya `data/` pekee — si mabadiliko ya `presentation/`.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/story.dart';
import '../entities/story_shelf.dart';

/// Chanzo kimoja cha hadithi kwa app yote.
abstract class StoryRepository {
  /// Hadithi zote zilizopo, kwa mpangilio wa kuchapishwa (mpya kwanza).
  Future<Either<Failure, List<Story>>> getAllStories();

  /// Hadithi moja kwa [id].
  ///
  /// [id] isipopatikana hurudisha `Left(NotFoundFailure())` — si orodha tupu
  /// wala `null`. Skrini ya maelezo inaonyesha "hatukupata" (l10n
  /// `noResults`) badala ya ukurasa mweupe.
  Future<Either<Failure, Story>> getStoryById(String id);

  /// Hadithi zilizo kwenye rafu moja.
  Future<Either<Failure, List<Story>>> getStoriesByShelf(StoryShelf shelf);

  /// Hadithi zinazopendekezwa kwenye Nyumbani ("Hadithi Bora").
  ///
  /// Ni orodha fupi (3) kwa makusudi: kadi kuu ya "Hadithi ya Leo" ipo juu
  /// yake, kwa hivyo zaidi ya tatu zingeanza kuonekana kama Maktaba ya pili.
  Future<Either<Failure, List<Story>>> getFeaturedStories({int limit = 3});

  /// Hadithi zinazopendwa zaidi — "Zinazopendwa" (trending).
  Future<Either<Failure, List<Story>>> getTrendingStories({int limit = 5});

  /// Utafutaji wa ndani kwa jina, mwandishi au uainishaji.
  ///
  /// Huvumilia makosa ya kuandika ya Kiswahili kwa kutumia
  /// `SwahiliTextUtils.matches`, ambayo hukunja digraph (`ny` → `n`) na
  /// herufi zinazorudiwa — kwa hivyo `nyumba` na `numba` zinapatana. Hii ni
  /// muhimu kwenye simu ndogo ambako watu huandika kwa kifupi.
  Future<Either<Failure, List<Story>>> searchStories(String query);
}
