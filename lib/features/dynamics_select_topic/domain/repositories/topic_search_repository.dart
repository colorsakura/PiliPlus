import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_pub_search/data.dart';

/// Repository for dynamic topic search operations
///
/// Provides methods for searching topics to include in dynamic posts.
abstract class TopicSearchRepository {
  /// Search for topics by keyword
  ///
  /// [keywords] - The search keywords
  /// [pageNum] - The page number for pagination
  ///
  /// Returns search results with topic items and pagination info
  Future<LoadingState<TopicPubSearchData>> searchTopics({
    String? keywords,
    int pageNum,
  });
}
