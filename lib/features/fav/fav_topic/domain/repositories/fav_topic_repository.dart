import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_topic/topic_item.dart';

/// Repository interface for favorite topics
abstract class FavTopicRepository {
  /// Get favorite topics list
  Future<LoadingState<List<FavTopicItem>>> getFavTopics(int page);

  /// Remove topic from favorites
  Future<LoadingState<void>> removeTopic(int id);
}
