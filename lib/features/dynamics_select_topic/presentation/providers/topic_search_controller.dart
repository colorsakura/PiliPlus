import 'package:PiliPlus/features/dynamics_select_topic/domain/entities/topic_search_state.dart';
import 'package:PiliPlus/features/dynamics_select_topic/domain/usecases/search_topics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';
import 'package:flutter/material.dart';

/// Controller for dynamics topic selection functionality
///
/// Manages searching for topics and tracking pagination state.
class TopicSearchController extends ChangeNotifier {
  final SearchTopics _searchTopics;

  TopicSearchState _state = TopicSearchState(
    searchResults: LoadingState.loading(),
  );

  int _currentPage = 1;

  TopicSearchController(this._searchTopics);

  TopicSearchState get state => _state;

  final FocusNode focusNode = FocusNode();
  final TextEditingController controller = TextEditingController();

  /// Search for topics
  ///
  /// [keywords] - The search keywords (null for initial load)
  /// [refresh] - Whether to reset pagination and start from page 1
  Future<void> searchTopics([String? keywords, bool refresh = true]) async {
    if (refresh) {
      _currentPage = 1;
      _updateState(_state.copyWith(
        searchResults: LoadingState.loading(),
        isEnd: false,
      ));
    } else {
      _updateState(_state.copyWith(isLoadingMore: true));
    }

    final result = await _searchTopics.call(
      keywords: keywords,
      pageNum: _currentPage,
    );

    if (result case Success(:final response)) {
      final hasMore = response.pageInfo?.hasMore ?? false;
      final newTopics = response.topicItems ?? [];

      _currentPage++;

      List<TopicItem>? currentList;
      if (_state.searchResults case Success(:final value)) {
        currentList = value;
      }

      final updatedList = refresh
          ? newTopics
          : [...?currentList, ...newTopics];

      _updateState(_state.copyWith(
        searchResults: Success(updatedList),
        isEnd: !hasMore,
        isLoadingMore: false,
      ));
    } else {
      _updateState(_state.copyWith(
        searchResults: result,
        isLoadingMore: false,
      ));
    }
  }

  /// Load more topics
  Future<void> loadMore() async {
    if (_state.isLoadingMore || _state.isEnd) return;
    await searchTopics(controller.text, false);
  }

  /// Refresh search with current keyword
  Future<void> onRefresh() async {
    await searchTopics(controller.text, true);
  }

  void _updateState(TopicSearchState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    focusNode.dispose();
    controller.dispose();
    super.dispose();
  }
}
