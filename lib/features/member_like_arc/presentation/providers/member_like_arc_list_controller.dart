import 'package:PiliPlus/features/member_like_arc/domain/entities/member_like_arc_item_entity.dart';
import 'package:PiliPlus/features/member_like_arc/domain/usecases/fetch_member_like_arcs.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/foundation.dart';

/// State for member like arc list
class MemberLikeArcListState {
  MemberLikeArcListState({
    LoadingState<List<MemberLikeArcItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<MemberLikeArcItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;

  MemberLikeArcListState copyWith({
    LoadingState<List<MemberLikeArcItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
  }) {
    return MemberLikeArcListState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Controller for member like arc list
class MemberLikeArcListController extends ChangeNotifier {
  MemberLikeArcListController({
    required this.mid,
    required FetchMemberLikeArcsUseCase fetchLikeArcs,
  }) : _fetchLikeArcs = fetchLikeArcs {
    queryData(isRefresh: true);
  }

  final dynamic mid;
  final FetchMemberLikeArcsUseCase _fetchLikeArcs;

  MemberLikeArcListState _state = MemberLikeArcListState();

  MemberLikeArcListState get state => _state;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _state.isEnd)) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final page = isRefresh ? 1 : _state.currentPage;
    final result = await _fetchLikeArcs(mid: mid, page: page);

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
    } else if (result is Success<List<MemberLikeArcItemEntity>>) {
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
          if (currentState is Success<List<MemberLikeArcItemEntity>?>) {
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
