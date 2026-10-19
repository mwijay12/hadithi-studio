/// Utekelezaji wa [StoryRepository] kwa kutumia data ya ndani.
///
/// ## Kwa nini data ya ndani, si mtandao
///
/// Tanzania ni nchi ya vijiji: mtumiaji wa kwanza wa app hii anaweza kuwa
/// shuleni ambako hakuna Wi-Fi, au nyumbani ambako bando limeisha. Kwa hivyo
/// orodha ya kuanzia inatoka kwenye [StorySampleData] — faili la Dart lenyewe,
/// bila I/O, bila Hive, bila HTTP. Hii inafanya Library, Nyumbani na Rafu
/// Yangu zifanye kazi **mara ya kwanza kabisa** mtumiaji afungue app, hata
/// akiwa nje ya mtandao (kanuni ya 7: offline-graceful).
///
/// ## Kwa nini bado tunarudisha `Future<Either<Failure, T>>`
///
/// Kwa sababu huu ni **mkataba wa kudumu**, si utekelezaji wa kudumu. Siku
/// `/api/v1/stories` itakapokuwa hai, tutaandika `StoryRemoteDataSource` na
/// kubadilisha **faili hili pekee** — `presentation/` na `domain/` hazitaguswa
/// hata mstari mmoja. Hiyo ndiyo faida ya Clean Architecture iliyoandikwa
/// kwenye kanuni ya 1.
///
/// `Future.value(...)` (si `Future.delayed`) hutumika kwa makusudi: hakuna
/// ucheleweshaji wa kubuni. Skrini zinaonyesha `AppLoading` kwa sababu hali
/// ya BLoC hupita `loading` kwanza — sio kwa sababu tunaingiza `sleep`.
library;

import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/text_utils.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_shelf.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_sample_data.dart';

/// Utekelezaji halisi wa [StoryRepository] kwa sasa.
class StoryRepositoryImpl implements StoryRepository {
  /// Huunda repository. [stories] inaweza kubadilishwa kwenye test.
  ///
  /// Kwa nini parameter ipo: kila kitu cha app hii kinapimwa (unit test) kwa
  /// orodha ndogo ya kubuni. Kutumia `StorySampleData.all` moja kwa moja
  /// kungefanya testi zote zitegemee maudhui halisi — hadithi moja
  /// inapobadilishwa, testi zinaanguka bure.
  StoryRepositoryImpl({List<Story>? stories})
      : _stories = stories ?? StorySampleData.all;

  final List<Story> _stories;

  @override
  Future<Either<Failure, List<Story>>> getAllStories() async {
    // Mpangilio ni "mpya kwanza", kisha kwa idadi ya wasomaji: hadithi
    // inayopendwa zaidi haipaswi kufichwa chini ya orodha kwa sababu
    // ilichapishwa mapema kidogo.
    final List<Story> ordered = List<Story>.of(_stories)
      ..sort((Story a, Story b) {
        final int byYear = b.publishedYear.compareTo(a.publishedYear);
        if (byYear != 0) return byYear;
        return b.readCount.compareTo(a.readCount);
      });
    return Right<Failure, List<Story>>(ordered);
  }

  @override
  Future<Either<Failure, Story>> getStoryById(String id) async {
    // `firstWhere` yenye `orElse` inayorudisha `null` — kwa hivyo hakuna
    // exception inayovuja kutoka `StateError`, na `Left` ina ujumbe kwa
    // Kiswahili **na** Kiingereza (kanuni ya 4 na 6).
    final Story? match = _firstWhereOrNull(
      _stories,
      (Story story) => story.id == id,
    );
    if (match == null) {
      return const Left<Failure, Story>(NotFoundFailure());
    }
    return Right<Failure, Story>(match);
  }

  @override
  Future<Either<Failure, List<Story>>> getStoriesByShelf(
    StoryShelf shelf,
  ) async {
    final List<Story> matches = _stories
        .where((Story story) => story.shelves.contains(shelf))
        .toList(growable: false);
    // Orodha tupu hapa ni **jibu halali**, si kosa: rafu inaweza kuwa tupu
    // ikiwa mwandishi hajaandika hadithi yake bado. Skrini ya rafu
    // inaonyesha `AppEmptyState` (kanuni ya 12), si `AppErrorWidget`.
    return Right<Failure, List<Story>>(matches);
  }

  @override
  Future<Either<Failure, List<Story>>> getFeaturedStories({
    int limit = 3,
  }) async {
    final List<Story> ordered = List<Story>.of(_stories)
      ..sort((Story a, Story b) => b.rating.compareTo(a.rating));
    return Right<Failure, List<Story>>(_take(ordered, limit));
  }

  @override
  Future<Either<Failure, List<Story>>> getTrendingStories({
    int limit = 5,
  }) async {
    final List<Story> ordered = List<Story>.of(_stories)
      ..sort((Story a, Story b) => b.readCount.compareTo(a.readCount));
    return Right<Failure, List<Story>>(_take(ordered, limit));
  }

  @override
  Future<Either<Failure, List<Story>>> searchStories(String query) async {
    final String? needle = SwahiliTextUtils.normaliseQuery(query);
    // Hoja tupu hurudisha yote — si kosa wala orodha tupu. Mtumiaji
    // anafuta kwa kufuta herufi moja baada ya nyingine; hapo kati,
    // kumwonyesha "hakuna matokeo" ni kumdanganya.
    if (needle == null) {
      return Right<Failure, List<Story>>(List<Story>.of(_stories));
    }

    final List<Story> matches = _stories.where((Story story) {
      // Tunatafuta kwenye vitu vinne: jina (lugha zote mbili), mwandishi,
      // uainishaji na muhtasari. `SwahiliTextUtils.matches` hukunja digraph
      // (`nyumba` → `numba`) na herufi zinazorudiwa, kwa hivyo mtoto
      // anayeandika kwa kifupi bado apate hadithi yake.
      return SwahiliTextUtils.matches(story.titleSw, needle) ||
          SwahiliTextUtils.matches(story.titleEn, needle) ||
          SwahiliTextUtils.matches(story.author, needle) ||
          SwahiliTextUtils.matches(story.category.labelSw, needle) ||
          SwahiliTextUtils.matches(story.category.labelEn, needle) ||
          SwahiliTextUtils.matches(story.synopsisSw, needle);
    }).toList(growable: false);

    return Right<Failure, List<Story>>(matches);
  }

  /// Hukata orodha kwa [limit]. `limit <= 0` hurudisha orodha tupu.
  ///
  /// Tunalinda hapa kwa sababu `sublist` hutupa `RangeError` ikiwa
  /// `end > length` — bila hii `getFeaturedStories(limit: 99)` ingeangusha
  /// app badala ya kurudisha zote zilizopo.
  List<Story> _take(List<Story> source, int limit) {
    if (limit <= 0) return const <Story>[];
    if (limit >= source.length) return source;
    return source.sublist(0, limit);
  }

  /// `firstWhere` isiyotupa exception — `dartz`/`collection` haipo hapa,
  /// na kuandika `try/catch` kwa kitu rahisi hivi ni kelele.
  static Story? _firstWhereOrNull(
    List<Story> list,
    bool Function(Story) test,
  ) {
    for (final Story story in list) {
      if (test(story)) return story;
    }
    return null;
  }
}
