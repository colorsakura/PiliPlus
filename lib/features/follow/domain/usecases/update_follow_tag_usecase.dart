import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/follow/domain/repositories/follow_repository.dart';

/// Use case for updating a follow tag
class UpdateFollowTagUseCase {
  const UpdateFollowTagUseCase(this._repository);

  final FollowRepository _repository;

  Future<LoadingState<void>> call(int tagId, String tagName) =>
      _repository.updateFollowTag(tagId, tagName);
}
