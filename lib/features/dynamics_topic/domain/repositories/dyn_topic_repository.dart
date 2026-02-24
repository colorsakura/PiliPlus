import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_feed/topic_card_list.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/top_details.dart';

/// Dynamics topic repository interface
abstract interface class DynTopicRepository {
  /// Get topic top details
  Future<LoadingState<TopDetails?>> getTopicTop({
    required Object topicId,
  });

  /// Get topic feed
  Future<LoadingState<TopicCardList?>> getTopicFeed({
    required Object topicId,
    required String offset,
    required int sortBy,
  });

  /// Add topic to favorites
  Future<dynamic> addFavTopic(Object topicId);

  /// Remove topic from favorites
  Future<dynamic> delFavTopic(Object topicId);

  /// Like topic
  Future<dynamic> likeTopic(Object topicId, bool isLike);
}
