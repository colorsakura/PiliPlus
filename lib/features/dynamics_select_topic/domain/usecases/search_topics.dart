import 'package:PiliPlus/features/dynamics_select_topic/domain/repositories/topic_search_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_pub_search/data.dart';

/// Use case for searching topics
///
/// Searches for topics that can be included in a dynamic post.
class SearchTopics {
  final TopicSearchRepository repository;

  SearchTopics(this.repository);

  /// Execute the search topics use case
  ///
  /// [keywords] - Optional search keywords to filter topics
  /// [pageNum] - The page number for pagination
  ///
  /// Returns a loading state with topic search results
  Future<LoadingState<TopicPubSearchData>> call({
    String? keywords,
    int pageNum = 1,
  }) {
    return repository.searchTopics(
      keywords: keywords,
      pageNum: pageNum,
    );
  }
}
