import 'package:PiliPlus/features/dynamics_topic/data/datasources/dyn_topic_remote_datasource.dart';
import 'package:PiliPlus/features/dynamics_topic/domain/repositories/dyn_topic_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_feed/topic_card_list.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/top_details.dart';

/// Dynamics topic repository implementation
class DynTopicRepositoryImpl implements DynTopicRepository {
  final DynTopicRemoteDataSource _remoteDataSource;

  const DynTopicRepositoryImpl(this._remoteDataSource);

  @override
  Future<LoadingState<TopDetails?>> getTopicTop({
    required Object topicId,
  }) {
    return _remoteDataSource.getTopicTop(topicId: topicId);
  }

  @override
  Future<LoadingState<TopicCardList?>> getTopicFeed({
    required Object topicId,
    required String offset,
    required int sortBy,
  }) {
    return _remoteDataSource.getTopicFeed(
      topicId: topicId,
      offset: offset,
      sortBy: sortBy,
    );
  }

  @override
  Future<dynamic> addFavTopic(Object topicId) {
    return _remoteDataSource.addFavTopic(topicId);
  }

  @override
  Future<dynamic> delFavTopic(Object topicId) {
    return _remoteDataSource.delFavTopic(topicId);
  }

  @override
  Future<dynamic> likeTopic(Object topicId, bool isLike) {
    return _remoteDataSource.likeTopic(topicId, isLike);
  }
}
