import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/pgc/domain/usecases/get_pgc_data.dart';
import 'package:PiliPlus/features/pgc/presentation/providers/pgc_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/home_tab_type.dart';
import 'package:PiliPlus/models/fav/fav_pgc/list.dart';
import 'package:PiliPlus/models/pgc/pgc_index_result/list.dart';
import 'package:PiliPlus/models/pgc/pgc_timeline/result.dart';

part 'pgc_controller_v2.g.dart';

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

/// PGC controller (Riverpod version)
///
/// Manages PGC page state with three data sources
@riverpod
class PgcController extends _$PgcController {
  @override
  PgcState build(HomeTabType tabType) {
    // Load initial data
    Future.microtask(() => onRefresh(tabType));

    return PgcState(
      mainListState: LoadingState.loading(),
      followListState: LoadingState.loading(),
      timelineState: LoadingState.loading(),
    );
  }

  /// Query main PGC index list
  Future<void> queryMainList(HomeTabType tabType, {bool isRefresh = true}) async {
    if (state.isMainEnd && !isRefresh) return;

    final page = isRefresh ? 1 : state.currentPage;
    final getPgcIndexUseCase = ref.read(getPgcIndexUseCaseProvider);
    final result = await getPgcIndexUseCase(page, tabType);

    if (result case Success(:final response)) {
      if (response == null || response.isEmpty) {
        state = state.copyWith(
          mainListState: isRefresh ? result : state.mainListState,
          isMainEnd: true,
        );
      } else if (isRefresh) {
        state = state.copyWith(
          mainListState: result,
          currentPage: 2,
          isMainEnd: response.isEmpty,
        );
      } else {
        // Append to existing list
        final currentList = state.mainListState is Success
            ? (state.mainListState as Success<List<PgcIndexItem>?>).response ??
                  []
            : <PgcIndexItem>[];
        final newList = [...currentList, ...response];
        state = state.copyWith(
          mainListState: Success(newList),
          currentPage: page + 1,
          isMainEnd: response.isEmpty,
        );
      }
    } else {
      state = state.copyWith(mainListState: result);
    }
  }

  /// Query follow list
  Future<void> queryFollowList(HomeTabType tabType,
      {bool isRefresh = true}) async {
    if (state.isFollowEnd && !isRefresh) return;

    final page = isRefresh ? 1 : state.followPage;
    final getPgcFollowUseCase = ref.read(getPgcFollowUseCaseProvider);
    final result = await getPgcFollowUseCase(page, tabType);

    if (result case Success(:final response)) {
      if (response == null || response.isEmpty) {
        state = state.copyWith(
          followListState: isRefresh ? result : state.followListState,
          isFollowEnd: true,
        );
      } else if (isRefresh) {
        state = state.copyWith(
          followListState: result,
          followPage: 2,
          isFollowEnd: response.isEmpty,
        );
      } else {
        // Append to existing list
        final currentList = state.followListState is Success
            ? (state.followListState as Success<List<FavPgcItemModel>?>)
                      .response ??
                  []
            : <FavPgcItemModel>[];
        final newList = [...currentList, ...response];
        state = state.copyWith(
          followListState: Success(newList),
          followPage: page + 1,
          isFollowEnd: response.isEmpty,
        );
      }
    } else {
      state = state.copyWith(followListState: result);
    }
  }

  /// Query timeline
  Future<void> queryTimeline() async {
    final getPgcTimelineUseCase = ref.read(getPgcTimelineUseCaseProvider);
    final result = await getPgcTimelineUseCase();
    state = state.copyWith(timelineState: result);
  }

  /// Refresh all data
  Future<void> onRefresh(HomeTabType tabType) async {
    await Future.wait([
      queryMainList(tabType, isRefresh: true),
      queryFollowList(tabType, isRefresh: true),
      queryTimeline(),
    ]);
  }

  /// Reload main list on error
  void onReloadMain(HomeTabType tabType) {
    queryMainList(tabType, isRefresh: true);
  }

  /// Reload follow list on error
  void onReloadFollow(HomeTabType tabType) {
    queryFollowList(tabType, isRefresh: true);
  }
}
