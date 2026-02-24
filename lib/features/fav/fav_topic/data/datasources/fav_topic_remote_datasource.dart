import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/fav/fav_topic/data.dart';
import 'package:PiliPlus/models/fav/fav_topic/topic_item.dart';

/// Remote data source for favorite topics
class FavTopicRemoteDatasource {
  /// Get favorite topics from API
  Future<LoadingState<FavTopicData>> getFavTopics({required int page}) {
    return FavHttp.favTopic(page: page);
  }

  /// Remove topic from favorites via API
  Future<LoadingState<void>> removeTopic(int id) {
    return FavHttp.delFavTopic(id);
  }
}

/// Extension to convert FavTopicData to List<FavTopicItem>
extension FavTopicDataExtension on FavTopicData {
  List<FavTopicItem> toItemList() {
    return topicList?.topicItems ?? [];
  }
}
