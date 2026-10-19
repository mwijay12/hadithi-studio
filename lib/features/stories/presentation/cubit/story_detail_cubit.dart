/// Cubit ya **maelezo ya hadithi moja**.
///
/// Ukurasa wa maelezo huumwa na matatizo mawili tu:
///
/// 1. **Kiungo cha zamani.** Mtumiaji anashirikiwa `/story/safari-ya-simba`,
///    halafu hadithi inaondolewa. `getStoryById` hurudisha
///    `Left(NotFoundFailure)` — sio orodha tupu. Hali hii haibadilishi kosa
///    hilo; `AppErrorWidget` inajua `NotFoundFailure` yenyewe na huonyesha
///    ujumbe sahihi wa lugha mbili.
/// 2. **Kurudi kwenye skrini nyeupe.** Kama hadithi ipo tayari mkononi
///    (tuliipata kwenye kadi tuliyogusa), hatuifuti wakati wa kupakia upya.
///    Hivyo kugusa "Jaribu tena" hakuonyeshi spinner juu ya ukurasa kamili.
library;

import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/story_repository.dart';
import '../stories_dependencies.dart';
import '../state/story_detail_state.dart';

/// Cubit ya maelezo ya hadithi.
class StoryDetailCubit extends Cubit<StoryDetailState> {
  /// [initialStory] ni hadithi tuliyoipata kwenye kadi iliyoguswa.
  ///
  /// Kuiweka tayari kunamaanisha ukurasa unaonekana **papo hapo**, bila
  /// spinner — kisha ombi la `getStoryById` linaithibitisha chinichini.
  /// Kama `id` haipo kwenye hifadhi ya ndani (mfano kiungo cha mtandao
  /// kilichoshirikiwa), `initialStory` ni `null` na spinner inaonekana.
  StoryDetailCubit({StoryRepository? repository, Story? initialStory})
      : _repository = repository ?? resolveStoryRepository(),
        super(StoryDetailState(
          status: initialStory == null
              ? StoryDetailStatus.initial
              : StoryDetailStatus.success,
          story: initialStory,
        ));

  final StoryRepository _repository;

  /// Namba ya ombi — hutupa majibu ya ombi la zamani.
  int _requestId = 0;

  /// Hupakia hadithi kwa [id].
  ///
  /// Haina hoja ya `force`: kwa data ya ndani (bila mtandao) ombi hili
  /// linakamilika papo hapo, hivyo kulazimisha upakiaji upya hakuna faida.
  Future<void> load(String id) async {
    final int requestId = ++_requestId;

    // Tunabadilisha `status` tu ikiwa hatuna hadithi tayari — tazama doc ya
    // faili hili (hoja 2).
    if (state.story == null) {
      emit(state.copyWith(
        status: StoryDetailStatus.loading,
        clearFailure: true,
      ));
    }

    final Either<Failure, Story> result = await _repository.getStoryById(id);
    if (isClosed || requestId != _requestId) return;

    result.fold(
      (Failure failure) {
        emit(StoryDetailState(
          status: StoryDetailStatus.failure,
          failure: failure,
        ));
      },
      (Story story) {
        emit(StoryDetailState(
          status: StoryDetailStatus.success,
          story: story,
        ));
      },
    );
  }

  /// Hurudia ombi la mwisho — "Jaribu tena".
  Future<void> retry() async {
    final String? id = state.story?.id;
    if (id == null) return;
    await load(id);
  }
}
