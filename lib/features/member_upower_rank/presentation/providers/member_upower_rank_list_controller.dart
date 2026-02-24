import 'package:PiliPlus/features/member_upower_rank/domain/entities/member_upower_rank_item_entity.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/usecases/fetch_member_upower_rank.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/upower_rank/level_info.dart';
import 'package:flutter/foundation.dart';

/// State for member upower rank list
class MemberUpowerRankListState {
  MemberUpowerRankListState({
    LoadingState<List<MemberUpowerRankItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
    this.name,
    this.tabs,
    this.memberTotal,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<MemberUpowerRankItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;
  final String? name;
  final List<LevelInfo>? tabs;
  final int? memberTotal;

  MemberUpowerRankListState copyWith({
    LoadingState<List<MemberUpowerRankItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    String? name,
    List<LevelInfo>? tabs,
    int? memberTotal,
  }) {
    return MemberUpowerRankListState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      name: name ?? this.name,
      tabs: tabs ?? this.tabs,
      memberTotal: memberTotal ?? this.memberTotal,
    );
  }
}

/// Controller for member upower rank list
class MemberUpowerRankListController extends ChangeNotifier {
  MemberUpowerRankListController({
    required this.upMid,
    this.privilegeType,
    required FetchMemberUpowerRankUseCase fetchUpowerRank,
  }) : _fetchUpowerRank = fetchUpowerRank {
    queryData(isRefresh: true);
  }

  final String upMid;
  final int? privilegeType;
  final FetchMemberUpowerRankUseCase _fetchUpowerRank;

  MemberUpowerRankListState _state = MemberUpowerRankListState();

  MemberUpowerRankListState get state => _state;

  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _state.isEnd)) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final page = isRefresh ? 1 : _state.currentPage;
    final result = await _fetchUpowerRank(
      upMid: upMid,
      page: page,
      privilegeType: privilegeType,
    );

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
    } else if (result is Success<List<MemberUpowerRankItemEntity>>) {
      final dataList = result.response;

      // Always set isEnd = true as in original controller
      _state = _state.copyWith(isEnd: true, isLoading: false);

      if (dataList.isEmpty) {
        if (isRefresh) {
          _state = _state.copyWith(listState: Success(dataList));
        }
      } else {
        if (isRefresh) {
          _state = _state.copyWith(
            listState: Success(dataList),
            currentPage: 2,
          );
        } else {
          final currentState = _state.listState;
          if (currentState is Success<List<MemberUpowerRankItemEntity>?>) {
            final currentList = currentState.response ?? [];
            final updatedList = [...currentList, ...dataList];
            _state = _state.copyWith(
              listState: Success(updatedList),
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
