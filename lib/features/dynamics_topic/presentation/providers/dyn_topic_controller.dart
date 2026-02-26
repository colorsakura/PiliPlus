import 'package:flutter/foundation.dart';
import 'package:PiliPlus/features/dynamics_topic/domain/usecases/get_dyn_topic_data.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_feed/item.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/top_details.dart';

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

/// Dynamics topic controller
class DynTopicController extends ChangeNotifier {
  final GetTopicTopUseCase _getTopicTopUseCase;
  final GetTopicFeedUseCase _getTopicFeedUseCase;
  final AddFavTopicUseCase _addFavTopicUseCase;
  final DelFavTopicUseCase _delFavTopicUseCase;
  final LikeTopicUseCase _likeTopicUseCase;

  late final String _topicId;
  late final String _topicName;
  late final bool _isLogin;

  DynTopicState _state = DynTopicState(
    feedListState: LoadingState.loading(),
    topState: LoadingState.loading(),
  );

  DynTopicState get state => _state;

  String get topicId => _topicId;
  String get topicName => _topicName;
  bool get isLogin => _isLogin;

  DynTopicController({
    required GetTopicTopUseCase getTopicTopUseCase,
    required GetTopicFeedUseCase getTopicFeedUseCase,
    required AddFavTopicUseCase addFavTopicUseCase,
    required DelFavTopicUseCase delFavTopicUseCase,
    required LikeTopicUseCase likeTopicUseCase,
    required String topicId,
    required String topicName,
    required bool isLogin,
  }) : _getTopicTopUseCase = getTopicTopUseCase,
       _getTopicFeedUseCase = getTopicFeedUseCase,
       _addFavTopicUseCase = addFavTopicUseCase,
       _delFavTopicUseCase = delFavTopicUseCase,
       _likeTopicUseCase = likeTopicUseCase,
       _topicId = topicId,
       _topicName = topicName,
       _isLogin = isLogin {
    // Load initial data
    Future.microtask(() {
      queryTop();
      queryFeedList();
    });
  }

  void _updateState(DynTopicState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Query topic top details
  Future<void> queryTop() async {
    final result = await _getTopicTopUseCase(topicId: _topicId);
    if (result case Success(:final response)) {
      final topicItem = response?.topicItem;
      if (topicItem != null) {
        _topicName = topicItem.name;
        _updateState(
          _state.copyWith(
            topState: result,
            isFav: topicItem.isFav,
            isLike: topicItem.isLike,
          ),
        );
      } else {
        _updateState(_state.copyWith(topState: result));
      }
    } else {
      _updateState(_state.copyWith(topState: result));
    }
  }

  /// Query feed list
  Future<void> queryFeedList({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final offset = isRefresh ? '' : _state.offset;
    final result = await _getTopicFeedUseCase(
      topicId: _topicId,
      offset: offset,
      sortBy: _state.sortBy,
    );

    if (result case Success(:final response)) {
      if (response == null || response.items?.isEmpty == true) {
        _updateState(
          _state.copyWith(
            feedListState: isRefresh
                ? Success(response?.items)
                : _state.feedListState,
            isEnd: true,
          ),
        );
      } else if (isRefresh) {
        _updateState(
          _state.copyWith(
            feedListState: Success(response.items),
            offset: response.offset ?? '',
            isEnd: response.hasMore == false,
          ),
        );
      } else {
        // Append to existing list
        final currentList = _state.feedListState is Success
            ? (_state.feedListState as Success<List<TopicCardItem>?>)
                      .response ??
                  []
            : <TopicCardItem>[];
        final newList = [...currentList, ...response.items!];
        _updateState(
          _state.copyWith(
            feedListState: Success(newList),
            offset: response.offset ?? '',
            isEnd: response.hasMore == false,
          ),
        );
      }
    } else if (result is Error) {
      _updateState(_state.copyWith(feedListState: result));
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
    _updateState(_state.copyWith(sortBy: sortBy));
    onReload();
  }

  /// Toggle favorite
  Future<void> onFav() async {
    final isFav = _state.isFav ?? false;
    final result = isFav
        ? await _delFavTopicUseCase(_topicId)
        : await _addFavTopicUseCase(_topicId);

    if (result is! Map || result['code'] != 0) {
      // Error handling would happen in the UI layer via toast
      return;
    }

    // Update local state
    final currentTopState = _state.topState;
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
      _updateState(
        _state.copyWith(
          isFav: !isFav,
          topState: Success(response),
        ),
      );
    }
  }

  /// Toggle like
  Future<void> onLike() async {
    final isLike = _state.isLike ?? false;
    final result = await _likeTopicUseCase(_topicId, isLike);

    if (result is! Map || result['code'] != 0) {
      // Error handling would happen in the UI layer via toast
      return;
    }

    // Update local state
    final currentTopState = _state.topState;
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
      _updateState(
        _state.copyWith(
          isLike: !isLike,
          topState: Success(response),
        ),
      );
    }
  }

  /// Update topic name
  void updateTopicName(String name) {
    _topicName = name;
  }
}
