import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/member_comic/domain/entities/member_comic_item_entity.dart';
import 'package:PiliPlus/features/member_comic/domain/usecases/fetch_member_comics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/member_comic/presentation/providers/member_comic_list_provider.dart';

part 'member_comic_controller.g.dart';

/// State for member comic list
class MemberComicState {
  MemberComicState({
    LoadingState<List<MemberComicItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<MemberComicItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;

  MemberComicState copyWith({
    LoadingState<List<MemberComicItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
  }) {
    return MemberComicState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Controller for member comic list (Riverpod version)
@riverpod
class MemberComicController extends _$MemberComicController {
  @override
  MemberComicState build(int mid) {
    queryData(mid, isRefresh: true);
    return MemberComicState();
  }

  Future<void> queryData(int mid, {bool isRefresh = true}) async {
    final currentState = state;
    if (currentState.isLoading || (!isRefresh && currentState.isEnd)) return;

    state = state.copyWith(isLoading: true);

    final page = isRefresh ? 1 : currentState.currentPage;
    final fetchComics = ref.read(fetchMemberComicsUseCaseProvider);
    final result = await fetchComics(mid: mid, page: page);

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
    } else if (result is Success<List<MemberComicItemEntity>>) {
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
          final currentStateList = state.listState;
          if (currentStateList is Success<List<MemberComicItemEntity>?>) {
            final currentList = currentStateList.response ?? [];
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

  Future<void> onRefresh(int mid) {
    state = state.copyWith(currentPage: 1, isEnd: false);
    return queryData(mid, isRefresh: true);
  }

  Future<void> onReload(int mid) {
    state = state.copyWith(listState: LoadingState.loading());
    return queryData(mid, isRefresh: true);
  }

  Future<void> onLoadMore(int mid) {
    return queryData(mid, isRefresh: false);
  }
}
