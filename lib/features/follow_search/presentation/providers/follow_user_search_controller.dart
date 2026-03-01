import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/features/follow_search/domain/usecases/search_follows_usecase.dart';
import 'package:PiliPlus/features/follow_search/presentation/providers/follow_search_providers.dart';

part 'follow_user_search_controller.g.dart';

/// State for follow search
class FollowUserSearchState {
  const FollowUserSearchState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<FollowItemModel>?> listState;
  final int currentPage;
  final bool isEnd;

  FollowUserSearchState copyWith({
    LoadingState<List<FollowItemModel>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return FollowUserSearchState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for follow search (Riverpod version)
@riverpod
class FollowUserSearchController extends _$FollowUserSearchController {
  @override
  FollowUserSearchState build() {
    return FollowUserSearchState(listState: LoadingState.loading());
  }

  /// Search follows
  Future<void> searchFollows(int mid, String keyword, {bool isRefresh = true}) async {
    final currentState = state;
    if (currentState.isEnd && !isRefresh) return;

    final page = isRefresh ? 1 : currentState.currentPage;

    final searchFollows = ref.read(searchFollowsUseCaseProvider);
    final result = await searchFollows(
      mid: mid,
      name: keyword,
      page: page,
    );

    // Convert LoadingState<FollowData> to LoadingState<List<FollowItemModel>?>
    final listState = switch (result) {
      Loading() => LoadingState<List<FollowItemModel>?>.loading(),
      Success(:final response) => Success(response.list),
      Error(:final errMsg) => Error(errMsg),
    };

    if (listState case Success(:final response)) {
      final newList = response ?? <FollowItemModel>[];
      final isEnd = newList.isEmpty;

      if (isRefresh) {
        state = FollowUserSearchState(
          listState: Success(newList),
          currentPage: 2,
          isEnd: isEnd,
        );
      } else {
        final currentList = state.listState is Success
            ? (state.listState as Success<List<FollowItemModel>?>).response ??
                  []
            : <FollowItemModel>[];
        state = state.copyWith(
          listState: Success([...currentList, ...newList]),
          currentPage: page + 1,
          isEnd: isEnd,
        );
      }
    } else {
      state = state.copyWith(listState: listState);
    }
  }

  /// Load more results
  void onLoadMore(int mid, String keyword) {
    if (!state.isEnd) {
      searchFollows(mid, keyword, isRefresh: false);
    }
  }

  /// Refresh search
  Future<void> onRefresh(int mid, String keyword) => searchFollows(mid, keyword, isRefresh: true);

  /// Reload search
  Future<void> onReload(int mid, String keyword) => searchFollows(mid, keyword, isRefresh: true);

  /// Clear search
  void onClear() {
    state = FollowUserSearchState(listState: LoadingState.loading());
  }
}
