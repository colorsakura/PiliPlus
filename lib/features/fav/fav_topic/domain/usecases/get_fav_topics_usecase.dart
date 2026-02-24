import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_topic/topic_item.dart';
import 'package:PiliPlus/features/fav/fav_topic/domain/repositories/fav_topic_repository.dart';

/// Use case for getting favorite topics
class GetFavTopicsUseCase {
  const GetFavTopicsUseCase(this._repository);

  final FavTopicRepository _repository;

  Future<LoadingState<List<FavTopicItem>>> call(int page) {
    return _repository.getFavTopics(page);
  }
}
