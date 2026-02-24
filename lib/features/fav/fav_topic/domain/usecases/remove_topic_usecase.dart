import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/fav/fav_topic/domain/repositories/fav_topic_repository.dart';

/// Use case for removing a topic from favorites
class RemoveTopicUseCase {
  const RemoveTopicUseCase(this._repository);

  final FavTopicRepository _repository;

  Future<LoadingState<void>> call(int id) {
    return _repository.removeTopic(id);
  }
}
