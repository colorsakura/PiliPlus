import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';

/// State for dynamics topic selection functionality
///
/// Manages the UI state for searching and selecting topics.
class TopicSearchState {
  final LoadingState<List<TopicItem>?> searchResults;
  final bool isLoadingMore;
  final bool isEnd;

  const TopicSearchState({
    required this.searchResults,
    this.isLoadingMore = false,
    this.isEnd = false,
  });

  TopicSearchState copyWith({
    LoadingState<List<TopicItem>?>? searchResults,
    bool? isLoadingMore,
    bool? isEnd,
  }) {
    return TopicSearchState(
      searchResults: searchResults ?? this.searchResults,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}
