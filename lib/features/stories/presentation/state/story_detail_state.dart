/// Hali ya ukurasa wa maelezo ya hadithi moja.
///
/// Ukurasa huu hauna utafutaji wala makundi — ni hadithi **moja** iliyoombwa
/// kwa `id`. Kwa hivyo hali ni nyepesi: [story] au [failure].
///
/// Uamuzi wa makusudi: [story] inabaki kwenye hali baada ya kufanikiwa pekee.
/// Tukiifuta kwenye kila `load()`, ukurasa ungerudi kwenye skrini nyeupe kila
/// mtumiaji anapogusa "Jaribu tena" — wakati hadithi ipo tayari mkononi.
///
/// TANBIHI kwa [StoryDetailStatus.failure]: `getStoryById` hurudisha
/// `Left(NotFoundFailure)` kwa `id` isiyojulikana (mfano kiungo cha zamani
/// kilichoshirikiwa). Huko [failure] ni [NotFoundFailure] halisi, kwa hivyo
/// `AppErrorWidget` huonyesha ujumbe sahihi wa lugha mbili bila `if` ya
/// ziada hapa.
library;

import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/story.dart';

/// Hatua ya mzigo wa maelezo.
enum StoryDetailStatus { initial, loading, success, failure }

/// Hali ya ukurasa wa maelezo ya hadithi.
class StoryDetailState extends Equatable {
  const StoryDetailState({
    this.status = StoryDetailStatus.initial,
    this.story,
    this.failure,
  });

  /// Hatua ya sasa.
  final StoryDetailStatus status;

  /// Hadithi iliyopatikana.
  final Story? story;

  /// Kosa lililotokea.
  final Failure? failure;

  /// `true` = ombi linaendelea.
  bool get isLoading => status == StoryDetailStatus.loading;

  /// `true` = kosa la kweli.
  bool get hasFailure => status == StoryDetailStatus.failure;

  /// `true` = hadithi ipo tayari kuonyeshwa.
  bool get hasStory => status == StoryDetailStatus.success && story != null;

  /// Nakala mpya yenye mabadiliko.
  StoryDetailState copyWith({
    StoryDetailStatus? status,
    Story? story,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return StoryDetailState(
      status: status ?? this.status,
      story: story ?? this.story,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, story, failure];
}
