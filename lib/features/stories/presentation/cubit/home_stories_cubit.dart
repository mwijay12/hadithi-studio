/// Cubit ya ukurasa wa **Nyumbani** — huchagua na kuhifadhi makundi matatu.
///
/// Hii ni cubit moja kwa makundi matatu (`daily`, `featured`, `trending`) kwa
/// sababu matatu zote zinaonekana kwenye skrini moja na zinasomwa mara moja.
/// Cubit tatu zingeunda `BlocProvider` tatu na kusababisha skrini kujengwa
/// upya mara tatu wakati data moja inafika.
///
/// ## Mtiririko
///
/// 1. [load] inaomba orodha kamili (`getAllStories`).
/// 2. Kama orodha kamili inashindwa, ni **kosa la kweli** — Nyumbani haina
///    kitu cha kuonyesha. `AppErrorWidget` hutumika.
/// 3. Kama orodha kamili imefanikiwa, `daily` ni hadithi ya kwanza (mpangilio
///    wa `StorySampleData.all` ni "mpya kwanza").
/// 4. `featured` na `trending` zinaombwa; zikishindwa, tunarudi kwenye
///    orodha ile ile tuliyo nayo badala ya kuangusha skrini nzima (kanuni 7).
///
/// Hatua ya 4 ndiyo tofauti muhimu: kosa la sehemu moja halipaswi kufuta
/// ukurasa mzima wakati tuna data ya kutosha kuonyesha.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../stories_dependencies.dart';
import '../state/home_stories_state.dart';

/// Cubit ya Nyumbani.
class HomeStoriesCubit extends Cubit<HomeStoriesState> {
  /// Hutumia [repository] iliyotolewa, au `resolveStoryRepository()`.
  ///
  /// Hoja ipo kwa **majaribio**: tunaweza kuingiza repository ya uongo bila
  /// kupachika `get_it`. Kwenye app halisi huitwa bila hoja.
  HomeStoriesCubit({StoryRepository? repository})
      : _repository = repository ?? resolveStoryRepository(),
        super(const HomeStoriesState());

  final StoryRepository _repository;

  /// Hupakia makundi yote matatu.
  ///
  /// Ni idempotent: kuita mara mbili kunasoma data ile ile, hivyo
  /// `BlocProvider(create: (c) => HomeStoriesCubit()..load())` ni salama
  /// hata kama widget ijengwe upya.
  Future<void> load() async {
    emit(state.copyWith(
      status: HomeStoriesStatus.loading,
      clearFailure: true,
    ),);

    // -------------------------------------------------------------------
    // 1. Orodha kamili — hii inaamua kama skrini ina kitu au la.
    // -------------------------------------------------------------------
    final Either<Failure, List<Story>> allResult =
        await _repository.getAllStories();
    if (isClosed) return;

    final Failure? allFailure =
        allResult.fold((Failure failure) => failure, (_) => null);
    if (allFailure != null) {
      emit(state.copyWith(
        status: HomeStoriesStatus.failure,
        failure: allFailure,
      ),);
      return;
    }

    final List<Story> all = allResult.getOrElse(() => const <Story>[]);
    if (all.isEmpty) {
      // Maktaba haina kitu kabisa. Hii SI kosa — `isEmpty` ya hali
      // inaamua UI, hivyo hatuweki `Failure`.
      emit(const HomeStoriesState(status: HomeStoriesStatus.success));
      return;
    }

    // -------------------------------------------------------------------
    // 2. Makundi mawili ya pembeni. Kosa lao halivunji ukurasa.
    // -------------------------------------------------------------------
    final Either<Failure, List<Story>> featuredResult =
        await _repository.getFeaturedStories();
    if (isClosed) return;

    final Either<Failure, List<Story>> trendingResult =
        await _repository.getTrendingStories();
    if (isClosed) return;

    final List<Story> featured = featuredResult.getOrElse(() => const <Story>[]);
    final List<Story> trending = trendingResult.getOrElse(() => const <Story>[]);

    emit(HomeStoriesState(
      status: HomeStoriesStatus.success,
      // "Hadithi ya Leo" inachaguliwa **mara moja** hapa na kuhifadhiwa
      // kwenye hali. Hatuhesabu `DateTime.now()` kwa sababu hadithi
      // ingebadilika usiku wa manane bila mtumiaji kugusa kitu.
      daily: all.first,
      featured: featured,
      trending: trending,
    ),);
  }

  /// Hupakia upya — hutumika kwa "Jaribu tena" na kwa kuvuta-chini.
  Future<void> refresh() => load();
}
