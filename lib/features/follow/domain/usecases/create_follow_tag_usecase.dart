import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/follow/domain/repositories/follow_repository.dart';

/// Use case for creating a follow tag
class CreateFollowTagUseCase {
  const CreateFollowTagUseCase(this._repository);

  final FollowRepository _repository;

  Future<LoadingState<void>> call(String tagName) =>
      _repository.createFollowTag(tagName);
}
