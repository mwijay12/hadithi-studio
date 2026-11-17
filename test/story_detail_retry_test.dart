import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hadithi_studio/core/errors/failures.dart';
import 'package:hadithi_studio/features/stories/data/datasources/story_sample_data.dart';
import 'package:hadithi_studio/features/stories/data/repositories/story_repository_impl.dart';
import 'package:hadithi_studio/features/stories/domain/entities/story.dart';
import 'package:hadithi_studio/features/stories/presentation/cubit/story_detail_cubit.dart';

class RetryRepository extends StoryRepositoryImpl {
  int calls = 0;

  @override
  Future<Either<Failure, Story>> getStoryById(String id) async {
    calls++;
    if (calls == 1) return const Left<Failure, Story>(NetworkFailure());
    return super.getStoryById(id);
  }
}

void main() {
  test('retry reloads the requested id after a failed first load', () async {
    final repository = RetryRepository();
    final cubit = StoryDetailCubit(repository: repository);
    final story = StorySampleData.all.first;
    await cubit.load(story.id);
    expect(cubit.state.hasFailure, isTrue);
    await cubit.retry();
    expect(repository.calls, 2);
    expect(cubit.state.story?.id, story.id);
    await cubit.close();
  });
}
