import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/entities/member_upower_rank_item_entity.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/usecases/fetch_member_upower_rank.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/member_upower_rank/presentation/providers/member_upower_rank_list_provider.dart';
import 'package:PiliPlus/models/upower_rank/level_info.dart';

part 'member_upower_rank_controller.g.dart';

/// State for member upower rank list
class MemberUpowerRankState {
  MemberUpowerRankState({
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

  MemberUpowerRankState copyWith({
    LoadingState<List<MemberUpowerRankItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    String? name,
    List<LevelInfo>? tabs,
    int? memberTotal,
  }) {
    return MemberUpowerRankState(
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

/// Controller for member upower rank list (Riverpod version)
@riverpod
class MemberUpowerRankController extends _$MemberUpowerRankController {
  @override
  MemberUpowerRankState build(String upMid, int? privilegeType) {
    queryData(upMid, privilegeType, isRefresh: true);
    return MemberUpowerRankState();
  }

  Future<void> queryData(
    String upMid,
    int? privilegeType, {
    bool isRefresh = true,
  }) async {
    final currentState = state;
    if (currentState.isLoading || (!isRefresh && currentState.isEnd)) return;

    state = state.copyWith(isLoading: true);

    final page = isRefresh ? 1 : currentState.currentPage;
    final fetchUpowerRank = ref.read(fetchMemberUpowerRankUseCaseProvider);
    final result = await fetchUpowerRank(
      upMid: upMid,
      page: page,
      privilegeType: privilegeType,
    );

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
    } else if (result is Success<List<MemberUpowerRankItemEntity>>) {
      final dataList = result.response;

      // Always set isEnd = true as in original controller
      state = state.copyWith(isEnd: true, isLoading: false);

      if (dataList.isEmpty) {
        if (isRefresh) {
          state = state.copyWith(listState: Success(dataList));
        }
      } else {
        if (isRefresh) {
          state = state.copyWith(
            listState: Success(dataList),
            currentPage: 2,
          );
        } else {
          final currentStateList = state.listState;
          if (currentStateList is Success<List<MemberUpowerRankItemEntity>?>) {
            final currentList = currentStateList.response ?? [];
            final updatedList = [...currentList, ...dataList];
            state = state.copyWith(
              listState: Success(updatedList),
              currentPage: page + 1,
            );
          }
        }
      }
    }
  }

  Future<void> onRefresh(String upMid, int? privilegeType) {
    state = state.copyWith(currentPage: 1, isEnd: false);
    return queryData(upMid, privilegeType, isRefresh: true);
  }

  Future<void> onReload(String upMid, int? privilegeType) {
    state = state.copyWith(listState: LoadingState.loading());
    return queryData(upMid, privilegeType, isRefresh: true);
  }

  Future<void> onLoadMore(String upMid, int? privilegeType) {
    return queryData(upMid, privilegeType, isRefresh: false);
  }
}
