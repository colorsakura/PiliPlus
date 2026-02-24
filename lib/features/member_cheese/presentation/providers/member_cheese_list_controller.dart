import 'package:PiliPlus/features/member_cheese/domain/entities/member_cheese_item_entity.dart';
import 'package:PiliPlus/features/member_cheese/domain/usecases/fetch_member_cheeses.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/foundation.dart';

/// State for member cheese list
class MemberCheeseListState {
  MemberCheeseListState({
    LoadingState<List<MemberCheeseItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<MemberCheeseItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;

  MemberCheeseListState copyWith({
    LoadingState<List<MemberCheeseItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
  }) {
    return MemberCheeseListState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Controller for member cheese list
class MemberCheeseListController extends ChangeNotifier {
  MemberCheeseListController({
    required this.mid,
    required this._fetchCheeses,
    this.isEnd,
  }) : _fetchCheeses = _fetchCheeses {
    queryData(isRefresh: true);
  }

  final int mid;
  final FetchMemberCheesesUseCase _fetchCheeses;
  final bool? isEnd;

  MemberCheeseListState _state = MemberCheeseListState();

  MemberCheeseListState get state => _state;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _state.isEnd)) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final page = isRefresh ? 1 : _state.currentPage;
    final result = await _fetchCheeses(mid: mid, page: page);

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
    } else if (result is Success<List<MemberCheeseItemEntity>>) {
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
          if (currentState is Success<List<MemberCheeseItemEntity>?>) {
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
