import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// USECASE — base class kwa matumizi (use cases) yote kwenye domain layer.
///
/// Kila usecase inatekeleza `call()` na hurudisha
/// `Either<Failure, Type>` (kanuni ya 6). Hii inaruhusu BLoC kupokea
/// ama kosa lililoeleweka ([Failure]) au matokeo yenye mafanikio.
///
/// Mfano:
/// ```dart
/// class GetFeaturedStories extends UseCase<List<Story>, NoParams> {
///   GetFeaturedStories(this._repository);
///   final LibraryRepository _repository;
///
///   @override
///   Future<Either<Failure, List<Story>>> call(NoParams params) {
///     return _repository.getFeaturedStories();
///   }
/// }
/// ```
abstract class UseCase<Type, Params> {
  const UseCase();

  /// Hutekeleza usecase.
  Future<Either<Failure, Type>> call(Params params);
}

/// USECASE YA STREAM — kwa matukio yanayotiririka (mfano reading progress,
/// notifications au TTS word timings zinazoendelea).
///
/// BLoC huitumia kwa `emit.forEach(...)` au `emit.onEach(...)`.
abstract class StreamUseCase<Type, Params> {
  const StreamUseCase();

  Stream<Either<Failure, Type>> call(Params params);
}

/// USECASE YA SYNCHRONOUS — hesabu rahisi zisizohitaji `Future`
/// (mfano kupanga orodha ya hadithi zilizopakuliwa).
abstract class SyncUseCase<Type, Params> {
  const SyncUseCase();

  Either<Failure, Type> call(Params params);
}

/// Parameta tupu — kwa usecase ambazo hazihitaji taarifa yoyote.
///
/// `equatable` inahitajika ili `bloc_test` iweze kulinganisha params
/// kwenye `act`.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
