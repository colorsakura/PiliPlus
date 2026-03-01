import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/live_follow/domain/entities/live_follow_item_entity.dart';
import 'package:PiliPlus/features/live_follow/domain/usecases/fetch_live_follow.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/live_follow/presentation/providers/live_follow_list_provider.dart';

part 'live_follow_controller.g.dart';

/// State for live follow list
class LiveFollowState {
  LiveFollowState({
    LoadingState<List<LiveFollowItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
    this.count,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<LiveFollowItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;
  final int? count;

  LiveFollowState copyWith({
    LoadingState<List<LiveFollowItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    int? count,
  }) {
    return LiveFollowState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      count: count ?? this.count,
    );
  }
}

/// Controller for live follow list (Riverpod version)
@riverpod
class LiveFollowController extends _$LiveFollowController {
  @override
  LiveFollowState build() {
    queryData(isRefresh: true);
    return LiveFollowState();
  }

  Future<void> queryData({bool isRefresh = true}) async {
    final currentState = state;
    if (currentState.isLoading || (!isRefresh && currentState.isEnd)) return;

    state = state.copyWith(isLoading: true);

    final page = isRefresh ? 1 : currentState.currentPage;
    final fetchLiveFollow = ref.read(fetchLiveFollowUseCaseProvider);
    final result = await fetchLiveFollow(page: page);

    if (result is Loading) {
      if (isRefresh) {
        state = state.copyWith(
          listState: LoadingState.loading(),
          isLoading: false,
        );
      }
    } else if (result is Error) {
      if (isRefresh) {
        state = state.copyWith(
          listState: result,
          isLoading: false,
        );
      }
    } else if (result is Success<List<LiveFollowItemEntity>>) {
      final dataList = result.response;

      if (dataList.isEmpty) {
        state = state.copyWith(isEnd: true, isLoading: false);
        if (isRefresh) {
          state = state.copyWith(listState: Success(dataList));
        }
      } else {
        // Custom checkIsEnd logic from original controller
        final totalCount = state.count;
        final currentLength = isRefresh
            ? dataList.length
            : (state.listState is Success<List<LiveFollowItemEntity>?>
                      ? (state.listState
                                    as Success<List<LiveFollowItemEntity>?>)
                                .response
                                ?.length ??
                            0
                      : 0) +
                  dataList.length;

        final shouldEnd = totalCount != null && currentLength >= totalCount;

        if (isRefresh) {
          state = state.copyWith(
            listState: Success(dataList),
            isLoading: false,
            currentPage: 2,
            isEnd: shouldEnd,
          );
        } else {
          final currentStateList = state.listState;
          if (currentStateList is Success<List<LiveFollowItemEntity>?>) {
            final currentList = currentStateList.response ?? [];
            final updatedList = [...currentList, ...dataList];
            state = state.copyWith(
              listState: Success(updatedList),
              isLoading: false,
              currentPage: page + 1,
              isEnd: shouldEnd,
            );
          }
        }
      }
    }
  }

  Future<void> onRefresh() {
    state = state.copyWith(currentPage: 1, isEnd: false, count: null);
    return queryData(isRefresh: true);
  }

  Future<void> onReload() {
    state = state.copyWith(listState: LoadingState.loading());
    return queryData(isRefresh: true);
  }

  Future<void> onLoadMore() {
    return queryData(isRefresh: false);
  }
}
