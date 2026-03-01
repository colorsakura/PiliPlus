import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/member_shop/domain/entities/member_shop_item_entity.dart';
import 'package:PiliPlus/features/member_shop/domain/usecases/fetch_member_shop_items.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/member_shop/presentation/providers/member_shop_list_provider.dart';

part 'member_shop_controller.g.dart';

/// State for member shop items list
class MemberShopState {
  MemberShopState({
    LoadingState<List<MemberShopItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
    this.showMoreTab,
    this.clickUrl,
    this.showMoreDesc,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<MemberShopItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;
  final bool? showMoreTab;
  final String? clickUrl;
  final String? showMoreDesc;

  MemberShopState copyWith({
    LoadingState<List<MemberShopItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    bool? showMoreTab,
    String? clickUrl,
    String? showMoreDesc,
  }) {
    return MemberShopState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      showMoreTab: showMoreTab ?? this.showMoreTab,
      clickUrl: clickUrl ?? this.clickUrl,
      showMoreDesc: showMoreDesc ?? this.showMoreDesc,
    );
  }
}

/// Controller for member shop items list (Riverpod version)
@riverpod
class MemberShopController extends _$MemberShopController {
  @override
  MemberShopState build(int mid) {
    queryData(mid, isRefresh: true);
    return MemberShopState();
  }

  Future<void> queryData(int mid, {bool isRefresh = true}) async {
    final currentState = state;
    if (currentState.isLoading || (!isRefresh && currentState.isEnd)) return;

    state = state.copyWith(isLoading: true);

    final page = isRefresh ? 1 : currentState.currentPage;
    final fetchShopItems = ref.read(fetchMemberShopItemsUseCaseProvider);
    final result = await fetchShopItems(mid: mid, page: page);

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
    } else if (result is Success<List<MemberShopItemEntity>>) {
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
          if (currentStateList is Success<List<MemberShopItemEntity>?>) {
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
