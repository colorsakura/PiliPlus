import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_pub_search/data.dart';

/// Remote data source for topic search
///
/// Fetches topic search data from the Bilibili API.
class TopicSearchRemoteDatasource {
  /// Search for topics by keyword
  ///
  /// [keywords] - The search keywords (nullable)
  /// [pageNum] - The page number for pagination (nullable)
  ///
  /// Returns a loading state with topic search results
  Future<LoadingState<TopicPubSearchData>> searchTopics({
    String? keywords,
    int? pageNum,
  }) {
    return SearchHttp.topicPubSearch(
      keywords: keywords ?? '',
      pageNum: pageNum ?? 1,
    );
  }
}
