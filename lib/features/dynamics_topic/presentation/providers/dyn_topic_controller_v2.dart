import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/dynamics_topic/domain/usecases/get_dyn_topic_data.dart';
import 'package:PiliPlus/features/dynamics_topic/presentation/providers/dyn_topic_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_feed/item.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/top_details.dart';
import 'package:PiliPlus/utils/accounts.dart';

part 'dyn_topic_controller_v2.g.dart';

/// Dynamics topic state
class DynTopicState {
  /// Topic feed list loading state
  final LoadingState<List<TopicCardItem>?> feedListState;

  /// Topic top details loading state
  final LoadingState<TopDetails?> topState;

  /// Current page offset for pagination
  final String offset;

  /// Current sort by option
  final int sortBy;

  /// Is feed list at end
  final bool isEnd;

  /// Is topic favorited
  final bool? isFav;

  /// Is topic liked
  final bool? isLike;

  const DynTopicState({
    required this.feedListState,
    required this.topState,
    this.offset = '',
    this.sortBy = 0,
    this.isEnd = false,
    this.isFav,
    this.isLike,
  });

  DynTopicState copyWith({
    LoadingState<List<TopicCardItem>?>? feedListState,
    LoadingState<TopDetails?>? topState,
    String? offset,
    int? sortBy,
    bool? isEnd,
    bool? isFav,
    bool? isLike,
  }) {
    return DynTopicState(
      feedListState: feedListState ?? this.feedListState,
      topState: topState ?? this.topState,
      offset: offset ?? this.offset,
      sortBy: sortBy ?? this.sortBy,
      isEnd: isEnd ?? this.isEnd,
      isFav: isFav ?? this.isFav,
      isLike: isLike ?? this.isLike,
    );
  }
}

/// Controller for dynamics topic functionality (Riverpod version)
///
/// Manages topic details, feed list, and user interactions (favorite, like).
@riverpod
class DynTopicController extends _$DynTopicController {
  late final String _topicId;
  late final String _topicName;
  late final bool _isLogin;

  @override
  DynTopicState build(String topicId, String topicName) {
    _topicId = topicId;
    _topicName = topicName;
    _isLogin = Accounts.main.isLogin;

    // Load initial data
    Future.microtask(() {
      queryTop();
      queryFeedList();
    });

    return DynTopicState(
      feedListState: LoadingState.loading(),
      topState: LoadingState.loading(),
    );
  }

  String get topicId => _topicId;
  String get topicName => _topicName;
  bool get isLogin => _isLogin;

  /// Query topic top details
  Future<void> queryTop() async {
    final getTopicTopUseCase = ref.read(getTopicTopUseCaseProvider);
    final result = await getTopicTopUseCase(topicId: _topicId);
    if (result case Success(:final response)) {
      final topicItem = response?.topicItem;
      if (topicItem != null) {
        _topicName = topicItem.name;
        state = state.copyWith(
          topState: Success(response),
          isFav: topicItem.isFav,
          isLike: topicItem.isLike,
        );
      } else {
        state = state.copyWith(topState: Success(response));
      }
    } else {
      state = state.copyWith(topState: result as LoadingState<TopDetails?>);
    }
  }

  /// Query feed list
  Future<void> queryFeedList({bool isRefresh = true}) async {
    if (state.isEnd && !isRefresh) return;

    final offset = isRefresh ? '' : state.offset;
    final getTopicFeedUseCase = ref.read(getTopicFeedUseCaseProvider);
    final result = await getTopicFeedUseCase(
      topicId: _topicId,
      offset: offset,
      sortBy: state.sortBy,
    );

    if (result case Success(:final response)) {
      if (response == null || response.items?.isEmpty == true) {
        state = state.copyWith(
          feedListState: isRefresh
              ? Success<List<TopicCardItem>?>(response?.items)
              : state.feedListState,
          isEnd: true,
        );
      } else if (isRefresh) {
        state = state.copyWith(
          feedListState: Success<List<TopicCardItem>?>(response.items),
          offset: response.offset ?? '',
          isEnd: response.hasMore == false,
        );
      } else {
        // Append to existing list
        final currentList = state.feedListState is Success
            ? (state.feedListState as Success<List<TopicCardItem>?>)
                      .response ??
                  []
            : <TopicCardItem>[];
        final newList = [...currentList, ...response.items!];
        state = state.copyWith(
          feedListState: Success<List<TopicCardItem>?>(newList),
          offset: response.offset ?? '',
          isEnd: response.hasMore == false,
        );
      }
    } else if (result is Error) {
      state = state.copyWith(feedListState: result as LoadingState<List<TopicCardItem>?>);
    }
  }

  /// Refresh all data
  Future<void> onRefresh() async {
    await Future.wait([
      queryTop(),
      queryFeedList(isRefresh: true),
    ]);
  }

  /// Reload on error
  void onReload() {
    queryFeedList(isRefresh: true);
  }

  /// Change sort by option
  void onSort(int sortBy) {
    state = state.copyWith(sortBy: sortBy);
    onReload();
  }

  /// Toggle favorite
  Future<void> onFav() async {
    final isFav = state.isFav ?? false;
    final addFavTopicUseCase = ref.read(addFavTopicUseCaseProvider);
    final delFavTopicUseCase = ref.read(delFavTopicUseCaseProvider);
    final result = isFav
        ? await delFavTopicUseCase(_topicId)
        : await addFavTopicUseCase(_topicId);

    if (result is! Map || result['code'] != 0) {
      // Error handling would happen in the UI layer via toast
      return;
    }

    // Update local state
    final currentTopState = state.topState;
    if (currentTopState is Success<TopDetails?>) {
      final response = currentTopState.response;
      final topicItem = response?.topicItem;
      if (topicItem != null) {
        if (isFav) {
          topicItem.fav -= 1;
        } else {
          topicItem.fav += 1;
        }
      }
      state = state.copyWith(
        isFav: !isFav,
        topState: Success(response),
      );
    }
  }

  /// Toggle like
  Future<void> onLike() async {
    final isLike = state.isLike ?? false;
    final likeTopicUseCase = ref.read(likeTopicUseCaseProvider);
    final result = await likeTopicUseCase(_topicId, isLike);

    if (result is! Map || result['code'] != 0) {
      // Error handling would happen in the UI layer via toast
      return;
    }

    // Update local state
    final currentTopState = state.topState;
    if (currentTopState is Success<TopDetails?>) {
      final response = currentTopState.response;
      final topicItem = response?.topicItem;
      if (topicItem != null) {
        if (isLike) {
          topicItem.like -= 1;
        } else {
          topicItem.like += 1;
        }
      }
      state = state.copyWith(
        isLike: !isLike,
        topState: Success(response),
      );
    }
  }

  /// Update topic name
  void updateTopicName(String name) {
    _topicName = name;
  }
}
