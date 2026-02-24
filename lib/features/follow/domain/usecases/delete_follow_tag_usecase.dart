import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/follow/domain/repositories/follow_repository.dart';

/// Use case for deleting a follow tag
class DeleteFollowTagUseCase {
  const DeleteFollowTagUseCase(this._repository);

  final FollowRepository _repository;

  Future<LoadingState<void>> call(int tagId) =>
      _repository.deleteFollowTag(tagId);
}
