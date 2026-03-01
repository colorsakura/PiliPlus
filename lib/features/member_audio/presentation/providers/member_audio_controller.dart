import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/member_audio/domain/entities/member_audio_item_entity.dart';
import 'package:PiliPlus/features/member_audio/domain/usecases/fetch_member_audios.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/member_audio/presentation/providers/member_audio_list_provider.dart';

part 'member_audio_controller.g.dart';

/// State for member audio list
class MemberAudioState {
  MemberAudioState({
    LoadingState<List<MemberAudioItemEntity>?>? listState,
    this.isLoading = false,
    this.isEnd = false,
    this.currentPage = 1,
    this.totalSize,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<MemberAudioItemEntity>?> listState;
  final bool isLoading;
  final bool isEnd;
  final int currentPage;
  final int? totalSize;

  MemberAudioState copyWith({
    LoadingState<List<MemberAudioItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    int? totalSize,
  }) {
    return MemberAudioState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      totalSize: totalSize ?? this.totalSize,
    );
  }
}

/// Controller for member audio list (Riverpod version)
@riverpod
class MemberAudioController extends _$MemberAudioController {
  @override
  MemberAudioState build(int mid) {
    // Fetch data on initialization
    queryData(mid, isRefresh: true);
    return MemberAudioState();
  }

  Future<void> queryData(int mid, {bool isRefresh = true}) async {
    final currentState = state;
    if (currentState.isLoading || (!isRefresh && currentState.isEnd)) return;

    state = state.copyWith(isLoading: true);

    final page = isRefresh ? 1 : currentState.currentPage;
    final fetchAudios = ref.read(fetchMemberAudiosUseCaseProvider);
    final result = await fetchAudios(mid: mid, page: page);

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
    } else if (result is Success<List<MemberAudioItemEntity>>) {
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
          if (currentStateList is Success<List<MemberAudioItemEntity>?>) {
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
