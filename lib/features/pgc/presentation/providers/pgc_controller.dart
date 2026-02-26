import 'package:flutter/foundation.dart';
import 'package:PiliPlus/features/pgc/domain/usecases/get_pgc_data.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

/// PGC page state
class PgcState {
  /// Main PGC index list loading state
  final LoadingState<List<PgcIndexItem>?> mainListState;

  /// Follow list loading state
  final LoadingState<List<FavPgcItemModel>?> followListState;

  /// Timeline loading state
  final LoadingState<List<TimelineResult>?> timelineState;

  /// Current page for main list
  final int currentPage;

  /// Current page for follow list
  final int followPage;

  /// Is main list at end
  final bool isMainEnd;

  /// Is follow list at end
  final bool isFollowEnd;

  const PgcState({
    required this.mainListState,
    required this.followListState,
    required this.timelineState,
    this.currentPage = 1,
    this.followPage = 1,
    this.isMainEnd = false,
    this.isFollowEnd = false,
  });

  /// Copy with
  PgcState copyWith({
    LoadingState<List<PgcIndexItem>?>? mainListState,
    LoadingState<List<FavPgcItemModel>?>? followListState,
    LoadingState<List<TimelineResult>?>? timelineState,
    int? currentPage,
    int? followPage,
    bool? isMainEnd,
    bool? isFollowEnd,
  }) {
    return PgcState(
      mainListState: mainListState ?? this.mainListState,
      followListState: followListState ?? this.followListState,
      timelineState: timelineState ?? this.timelineState,
      currentPage: currentPage ?? this.currentPage,
      followPage: followPage ?? this.followPage,
      isMainEnd: isMainEnd ?? this.isMainEnd,
      isFollowEnd: isFollowEnd ?? this.isFollowEnd,
    );
  }
}

/// PGC controller
///
/// Manages PGC page state with three data sources
class PgcController extends ChangeNotifier {
  late final GetPgcIndexUseCase _getPgcIndexUseCase;
  late final GetPgcFollowUseCase _getPgcFollowUseCase;
  late final GetPgcTimelineUseCase _getPgcTimelineUseCase;
  late final HomeTabType _tabType;
  PgcState _state = PgcState(
    mainListState: LoadingState.loading(),
    followListState: LoadingState.loading(),
    timelineState: LoadingState.loading(),
  );

  PgcState get state => _state;

  PgcController({
    required HomeTabType tabType,
    required GetPgcIndexUseCase getPgcIndexUseCase,
    required GetPgcFollowUseCase getPgcFollowUseCase,
    required GetPgcTimelineUseCase getPgcTimelineUseCase,
  }) {
    _tabType = tabType;
    _getPgcIndexUseCase = getPgcIndexUseCase;
    _getPgcFollowUseCase = getPgcFollowUseCase;
    _getPgcTimelineUseCase = getPgcTimelineUseCase;
    // Load initial data
    Future.microtask(() => onRefresh());
  }

  void _updateState(PgcState newState) {
    // Check if controller is still alive before notifying
    if (!hasListeners) return;

    _state = newState;
    notifyListeners();
  }

  /// Query main PGC index list
  Future<void> queryMainList({bool isRefresh = true}) async {
    if (_state.isMainEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.currentPage;

    final result = await _getPgcIndexUseCase(page, _tabType);

    if (result case Success(:final response)) {
      if (response == null || response.isEmpty) {
        _updateState(
          _state.copyWith(
            mainListState: isRefresh ? result : _state.mainListState,
            isMainEnd: true,
          ),
        );
      } else if (isRefresh) {
        _updateState(
          _state.copyWith(
            mainListState: result,
            currentPage: 2,
            isMainEnd: response.isEmpty,
          ),
        );
      } else {
        // Append to existing list
        final currentList = _state.mainListState is Success
            ? (_state.mainListState as Success<List<PgcIndexItem>?>).response ??
                  []
            : <PgcIndexItem>[];
        final newList = [...currentList, ...response];
        _updateState(
          _state.copyWith(
            mainListState: Success(newList),
            currentPage: page + 1,
            isMainEnd: response.isEmpty,
          ),
        );
      }
    } else {
      _updateState(_state.copyWith(mainListState: result));
    }
  }

  /// Query follow list
  Future<void> queryFollowList({bool isRefresh = true}) async {
    if (_state.isFollowEnd && !isRefresh) return;

    final page = isRefresh ? 1 : _state.followPage;

    final result = await _getPgcFollowUseCase(page, _tabType);

    if (result case Success(:final response)) {
      if (response == null || response.isEmpty) {
        _updateState(
          _state.copyWith(
            followListState: isRefresh ? result : _state.followListState,
            isFollowEnd: true,
          ),
        );
      } else if (isRefresh) {
        _updateState(
          _state.copyWith(
            followListState: result,
            followPage: 2,
            isFollowEnd: response.isEmpty,
          ),
        );
      } else {
        // Append to existing list
        final currentList = _state.followListState is Success
            ? (_state.followListState as Success<List<FavPgcItemModel>?>)
                      .response ??
                  []
            : <FavPgcItemModel>[];
        final newList = [...currentList, ...response];
        _updateState(
          _state.copyWith(
            followListState: Success(newList),
            followPage: page + 1,
            isFollowEnd: response.isEmpty,
          ),
        );
      }
    } else {
      _updateState(_state.copyWith(followListState: result));
    }
  }

  /// Query timeline
  Future<void> queryTimeline() async {
    final result = await _getPgcTimelineUseCase();
    _updateState(_state.copyWith(timelineState: result));
  }

  /// Refresh all data
  Future<void> onRefresh() async {
    await Future.wait([
      queryMainList(isRefresh: true),
      queryFollowList(isRefresh: true),
      queryTimeline(),
    ]);
  }

  /// Reload main list on error
  void onReloadMain() {
    queryMainList(isRefresh: true);
  }

  /// Reload follow list on error
  void onReloadFollow() {
    queryFollowList(isRefresh: true);
  }
}
