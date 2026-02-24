import 'package:PiliPlus/features/member_audio/domain/entities/member_audio_item_entity.dart';
import 'package:PiliPlus/features/member_audio/domain/usecases/fetch_member_audios.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/foundation.dart';

/// State for member audio list
class MemberAudioListState {
  MemberAudioListState({
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

  MemberAudioListState copyWith({
    LoadingState<List<MemberAudioItemEntity>?>? listState,
    bool? isLoading,
    bool? isEnd,
    int? currentPage,
    int? totalSize,
  }) {
    return MemberAudioListState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
      totalSize: totalSize ?? this.totalSize,
    );
  }
}

/// Controller for member audio list
///
/// This controller manages the paginated list of audios for a member.
/// It follows the ChangeNotifier pattern used in the project.
class MemberAudioListController extends ChangeNotifier {
  MemberAudioListController({
    required this.mid,
    required FetchMemberAudiosUseCase fetchAudios,
  }) : _fetchAudios = fetchAudios {
    // Load initial data
    queryData(isRefresh: true);
  }

  final int mid;
  final FetchMemberAudiosUseCase _fetchAudios;

  MemberAudioListState _state = MemberAudioListState();

  MemberAudioListState get state => _state;

  /// Query data with pagination
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isLoading || (!isRefresh && _state.isEnd)) return;

    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final page = isRefresh ? 1 : _state.currentPage;
    final result = await _fetchAudios(mid: mid, page: page);

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
    } else if (result is Success<List<MemberAudioItemEntity>>) {
      final dataList = result.response;

      if (dataList.isEmpty) {
        _state = _state.copyWith(
          isEnd: true,
          isLoading: false,
        );
        if (isRefresh) {
          _state = _state.copyWith(listState: Success(dataList));
        }
      } else {
        if (isRefresh) {
          _state = _state.copyWith(
            listState: Success(dataList),
            isLoading: false,
            currentPage: 2,
            totalSize: dataList.length,
          );
        } else {
          // Append to existing list
          final currentState = _state.listState;
          if (currentState is Success<List<MemberAudioItemEntity>?>) {
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

  /// Refresh the list
  Future<void> onRefresh() {
    _state = _state.copyWith(
      currentPage: 1,
      isEnd: false,
    );
    return queryData(isRefresh: true);
  }

  /// Reload current page
  Future<void> onReload() {
    _state = _state.copyWith(
      listState: LoadingState.loading(),
    );
    notifyListeners();
    return queryData(isRefresh: true);
  }

  /// Load more items
  Future<void> onLoadMore() {
    return queryData(isRefresh: false);
  }
}
