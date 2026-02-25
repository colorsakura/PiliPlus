import 'package:PiliPlus/features/dynamics_topic/domain/repositories/dyn_topic_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_feed/topic_card_list.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/top_details.dart';

/// Get topic top use case
class GetTopicTopUseCase {
  final DynTopicRepository _repository;

  const GetTopicTopUseCase(this._repository);

  Future<LoadingState<TopDetails?>> call({
    required Object topicId,
  }) => _repository.getTopicTop(topicId: topicId);
}

/// Get topic feed use case
class GetTopicFeedUseCase {
  final DynTopicRepository _repository;

  const GetTopicFeedUseCase(this._repository);

  Future<LoadingState<TopicCardList?>> call({
    required Object topicId,
    required String offset,
    required int sortBy,
  }) => _repository.getTopicFeed(
    topicId: topicId,
    offset: offset,
    sortBy: sortBy,
  );
}

/// Add topic to favorites use case
class AddFavTopicUseCase {
  final DynTopicRepository _repository;

  const AddFavTopicUseCase(this._repository);

  Future<dynamic> call(Object topicId) => _repository.addFavTopic(topicId);
}

/// Remove topic from favorites use case
class DelFavTopicUseCase {
  final DynTopicRepository _repository;

  const DelFavTopicUseCase(this._repository);

  Future<dynamic> call(Object topicId) => _repository.delFavTopic(topicId);
}

/// Like topic use case
class LikeTopicUseCase {
  final DynTopicRepository _repository;

  const LikeTopicUseCase(this._repository);

  Future<dynamic> call(Object topicId, bool isLike) =>
      _repository.likeTopic(topicId, isLike);
}
