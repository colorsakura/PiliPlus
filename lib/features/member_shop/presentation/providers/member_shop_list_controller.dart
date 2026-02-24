import 'package:PiliPlus/features/member_shop/domain/entities/member_shop_item_entity.dart';
import 'package:PiliPlus/features/member_shop/domain/usecases/fetch_member_shop_items.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/foundation.dart';

/// State for member shop list
class MemberShopListState {
  MemberShopListState({
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

  MemberShopListState copyWith({
    LoadingState<List<MemberShopItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    bool? showMoreTab,
    String? clickUrl,
    String? showMoreDesc,
  }) {
    return MemberShopListState(
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

/// Controller for member shop list
class MemberShopListController extends ChangeNotifier {
  MemberShopListController({
    required this.mid,
    required FetchMemberShopItemsUseCase fetchShopItems,
  }) : _fetchShopItems = fetchShopItems {
    queryData(isRefresh: true);
  }

  final int mid;
  final FetchMemberShopItemsUseCase _fetchShopItems;

  MemberShopListState _state = MemberShopListState();

  MemberShopListState get state => _state;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _state.isEnd)) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final page = isRefresh ? 1 : _state.currentPage;
    final result = await _fetchShopItems(mid: mid, page: page);

    if (result is Loading) {
      if (isRefresh) {
        _state = _state.copyWith(
          listState: LoadingState.loading(),
          isLoading: false,
        );
      }
    } else if (result is Error) {
      if (isRefresh) {
        _state = _state.copyWith(
          listState: result,
          isLoading: false,
        );
      }
    } else if (result is Success<List<MemberShopItemEntity>>) {
      final dataList = result.response;

      if (dataList.isEmpty) {
        _state = _state.copyWith(isEnd: true, isLoading: false);
        if (isRefresh) {
          _state = _state.copyWith(listState: Success(dataList));
        }
      } else {
        if (isRefresh) {
          _state = _state.copyWith(
            listState: Success(dataList),
            isLoading: false,
            currentPage: 2,
          );
        } else {
          final currentState = _state.listState;
          if (currentState is Success<List<MemberShopItemEntity>?>) {
            final currentList = currentState.response ?? [];
            final updatedList = [...currentList, ...dataList];
            _state = _state.copyWith(
              listState: Success(updatedList),
              isLoading: false,
              currentPage: page + 1,
            );
          }
        }
      }
    }

    notifyListeners();
  }

  Future<void> onRefresh() {
    _state = _state.copyWith(currentPage: 1, isEnd: false);
    return queryData(isRefresh: true);
  }

  Future<void> onReload() {
    _state = _state.copyWith(listState: LoadingState.loading());
    notifyListeners();
    return queryData(isRefresh: true);
  }

  Future<void> onLoadMore() {
    return queryData(isRefresh: false);
  }
}
