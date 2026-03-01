import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/popular_precious/domain/entities/popular_precious_item_entity.dart';
import 'package:PiliPlus/features/popular_precious/domain/usecases/fetch_popular_precious.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/popular_precious/presentation/providers/popular_precious_list_provider.dart';

part 'popular_precious_controller.g.dart';

/// State for popular precious list
class PopularPreciousState {
  PopularPreciousState({
    LoadingState<List<PopularPreciousItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
    this.mediaId,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<PopularPreciousItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;
  final int? mediaId;

  PopularPreciousState copyWith({
    LoadingState<List<PopularPreciousItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    int? mediaId,
  }) {
    return PopularPreciousState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      mediaId: mediaId ?? this.mediaId,
    );
  }
}

/// Controller for popular precious list (Riverpod version)
@riverpod
class PopularPreciousController extends _$PopularPreciousController {
  @override
  PopularPreciousState build() {
    // Fetch data on initialization
    queryData(isRefresh: true);
    return PopularPreciousState();
  }

  Future<void> queryData({bool isRefresh = true}) async {
    final currentState = state;
    if (currentState.isLoading || (!isRefresh && currentState.isEnd)) return;

    state = state.copyWith(isLoading: true);

    final page = isRefresh ? 1 : currentState.currentPage;
    final fetchPrecious = ref.read(fetchPopularPreciousUseCaseProvider);
    final result = await fetchPrecious(page: page);

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
    } else if (result is Success<List<PopularPreciousItemEntity>>) {
      final dataList = result.response;

      if (dataList.isEmpty) {
        state = state.copyWith(isEnd: true, isLoading: false);
        if (isRefresh) {
          state = state.copyWith(listState: Success(dataList));
        }
      } else {
        if (isRefresh) {
          state = state.copyWith(
            listState: Success(dataList),
            isLoading: false,
            currentPage: 2,
          );
        } else {
          final currentState = state.listState;
          if (currentState is Success<List<PopularPreciousItemEntity>?>) {
            final currentList = currentState.response ?? [];
            final updatedList = [...currentList, ...dataList];
            state = state.copyWith(
              listState: Success(updatedList),
              isLoading: false,
              currentPage: page + 1,
            );
          }
        }
      }
    }
  }

  Future<void> onRefresh() {
    state = state.copyWith(currentPage: 1, isEnd: false);
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
