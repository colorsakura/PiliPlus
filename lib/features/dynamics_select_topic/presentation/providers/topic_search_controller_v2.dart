import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/dynamics_select_topic/domain/entities/topic_search_state.dart';
import 'package:PiliPlus/features/dynamics_select_topic/presentation/providers/topic_search_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';

part 'topic_search_controller_v2.g.dart';

/// Controller for dynamics topic selection functionality (Riverpod version)
///
/// Manages searching for topics and tracking pagination state.
/// Note: FocusNode and TextEditingController should be managed by the UI layer.
@riverpod
class TopicSearchController extends _$TopicSearchController {
  @override
  TopicSearchState build() {
    // Initial search on build
    Future.microtask(() => searchTopics());
    return TopicSearchState(
      searchResults: LoadingState.loading(),
    );
  }

  /// Search for topics
  ///
  /// [keywords] - The search keywords (null for initial load)
  /// [refresh] - Whether to reset pagination and start from page 1
  Future<void> searchTopics([String? keywords, bool refresh = true]) async {
    if (refresh) {
      _currentPage = 1;
      state = state.copyWith(
        searchResults: LoadingState.loading(),
        isEnd: false,
      );
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    final searchTopics = ref.read(searchTopicsProvider);
    final result = await searchTopics.call(
      keywords: keywords,
      pageNum: _currentPage,
    );

    if (result case Success(:final response)) {
      final hasMore = response.pageInfo?.hasMore ?? false;
      final newTopics = response.topicItems ?? [];

      _currentPage++;

      List<TopicItem>? currentList;
      if (state.searchResults case Success(:final response)) {
        currentList = response;
      }

      final updatedList = refresh ? newTopics : [...?currentList, ...newTopics];

      state = state.copyWith(
        searchResults: Success(updatedList),
        isEnd: !hasMore,
        isLoadingMore: false,
      );
    } else {
      // Error case - preserve error info but change type
      state = state.copyWith(
        searchResults: result as LoadingState<List<TopicItem>>,
        isLoadingMore: false,
      );
    }
  }

  /// Load more topics
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isEnd) return;
    await searchTopics(null, false);
  }

  /// Refresh search with current keyword
  Future<void> onRefresh(String keyword) async {
    await searchTopics(keyword, true);
  }

  int _currentPage = 1;
}
