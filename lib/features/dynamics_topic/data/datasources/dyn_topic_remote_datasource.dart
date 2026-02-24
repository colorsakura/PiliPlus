import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_feed/topic_card_list.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/top_details.dart';

/// Dynamics topic remote data source
class DynTopicRemoteDataSource {
  /// Get topic top details from API
  Future<LoadingState<TopDetails?>> getTopicTop({
    required Object topicId,
  }) {
    return DynamicsHttp.topicTop(topicId: topicId);
  }

  /// Get topic feed from API
  Future<LoadingState<TopicCardList?>> getTopicFeed({
    required Object topicId,
    required String offset,
    required int sortBy,
  }) {
    return DynamicsHttp.topicFeed(
      topicId: topicId,
      offset: offset,
      sortBy: sortBy,
    );
  }

  /// Add topic to favorites
  Future<dynamic> addFavTopic(Object topicId) {
    return FavHttp.addFavTopic(topicId);
  }

  /// Remove topic from favorites
  Future<dynamic> delFavTopic(Object topicId) {
    return FavHttp.delFavTopic(topicId);
  }

  /// Like topic
  Future<dynamic> likeTopic(Object topicId, bool isLike) {
    return FavHttp.likeTopic(topicId, isLike);
  }
}
