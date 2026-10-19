/// Cubit ya **orodha ya hadithi** — hutumika rafu, utafutaji na "zote".
///
/// Hii ni cubit moja kwa nyuso tatu (tazama doc ya `story_list_state.dart`
/// kwa kwa nini). Ina njia tatu za kuingiza data:
///
/// * [loadShelf] — `/category/:id`.
/// * [loadAll] — Maktaba yote.
/// * [search] / [searchDebounced] — utafutaji wa moja kwa moja.
///
/// ## Kinga dhidi ya majibu yaliyochelewa
///
/// Utafutaji wa moja kwa moja hutuma ombi kwa kila herufi. Kama ombi la
/// "si" litachelewa na likarudi **baada** ya ombi la "simba", orodha
/// ingeonyesha matokeo ya "si" wakati mtumiaji ameandika "simba". Kwa hivyo
/// kila ombi linapata namba ([_requestId]) na majibu ya ombi la zamani
/// yanatupwa. Hii ni hitilafu ya kawaida kwenye skrini za utafutaji.
library;

import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/story.dart';
import '../../domain/entities/story_shelf.dart';
import '../../domain/repositories/story_repository.dart';
import '../stories_dependencies.dart';
import '../state/story_list_state.dart';

/// Cubit ya orodha ya hadithi.
class StoryListCubit extends Cubit<StoryListState> {
  /// Hutumia [repository] iliyotolewa, au `resolveStoryRepository()`.
  StoryListCubit({StoryRepository? repository})
      : _repository = repository ?? resolveStoryRepository(),
        super(const StoryListState());

  final StoryRepository _repository;

  /// Namba ya ombi la sasa — hutupa majibu yaliyochelewa.
  int _requestId = 0;

  /// Kipima-muda cha utafutaji (debounce).
  Timer? _debounce;

  /// Muda wa kusubiri kabla ya kutuma ombi la utafutaji.
  ///
  /// 300ms ni maelewano: mtumiaji anayeandika haraka haachi kusubiri, lakini
  /// hatutumi ombi kwa kila herufi ya neno moja.
  static const Duration searchDebounce = Duration(milliseconds: 300);

  /// Hupakia hadithi za rafu moja.
  Future<void> loadShelf(StoryShelf shelf) async {
    final int id = ++_requestId;
    emit(state.copyWith(
      status: StoryListStatus.loading,
      stories: const <Story>[],
      query: '',
      shelf: shelf,
      clearFailure: true,
    ));

    final Either<Failure, List<Story>> result =
        await _repository.getStoriesByShelf(shelf);
    if (isClosed || id != _requestId) return;

    _emitResult(result, shelf: shelf, query: '');
  }

  /// Hupakia hadithi zote (Maktaba kamili).
  Future<void> loadAll() async {
    final int id = ++_requestId;
    emit(state.copyWith(
      status: StoryListStatus.loading,
      stories: const <Story>[],
      query: '',
      clearShelf: true,
      clearFailure: true,
    ));

    final Either<Failure, List<Story>> result = await _repository.getAllStories();
    if (isClosed || id != _requestId) return;

    _emitResult(result, query: '');
  }

  /// Hutafuta mara moja. Hoja tupu inarudi kwenye orodha kamili.
  Future<void> search(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) return loadAll();

    final int id = ++_requestId;
    emit(state.copyWith(
      status: StoryListStatus.loading,
      stories: const <Story>[],
      query: trimmed,
      clearFailure: true,
    ));

    final Either<Failure, List<Story>> result =
        await _repository.searchStories(trimmed);
    if (isClosed || id != _requestId) return;

    // Tunaweka `query` ya **ombi hili**, si ya hali ya sasa: mtumiaji
    // anaweza kuwa ameandika zaidi wakati ombi lilikuwa safarini.
    _emitResult(result, query: trimmed);
  }

  /// Hutafuta baada ya mtumiaji kuacha kuandika kwa [searchDebounce].
  ///
  /// UI huita hii kwenye `onChanged`; [search] ya moja kwa moja hutumika kwa
  /// kibonye cha "tafuta" au kwa `onSubmitted`.
  void searchDebounced(String query) {
    _debounce?.cancel();
    _debounce = Timer(searchDebounce, () => search(query));
  }

  /// Hufuta utafutaji na kurudi kwenye orodha kamili.
  Future<void> clearSearch() {
    _debounce?.cancel();
    return loadAll();
  }

  /// Hurudia ombi la sasa — "Jaribu tena".
  Future<void> retry() {
    final StoryShelf? shelf = state.shelf;
    if (state.isSearching) return search(state.query);
    if (shelf != null) return loadShelf(shelf);
    return loadAll();
  }

  /// Huweka hali kutoka `Either` moja.
  ///
  /// Orodha tupu **si kosa** (kanuni 12): tunaweka `success` na kuruhusu
  /// `StoryListState.isEmpty` kuamua kuwa UI inaonyesha `AppEmptyState`.
  void _emitResult(
    Either<Failure, List<Story>> result, {
    StoryShelf? shelf,
    required String query,
  }) {
    result.fold(
      (Failure failure) {
        emit(StoryListState(
          status: StoryListStatus.failure,
          query: query,
          shelf: shelf,
          failure: failure,
        ));
      },
      (List<Story> stories) {
        emit(StoryListState(
          status: StoryListStatus.success,
          stories: stories,
          query: query,
          shelf: shelf,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
