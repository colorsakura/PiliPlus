import 'dart:math';

import 'package:PiliPlus/features/live_area_detail/domain/entities/live_area_item_entity.dart';
import 'package:PiliPlus/features/live_area_detail/domain/usecases/fetch_live_area_detail.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter/foundation.dart';

/// State for live area detail list
class LiveAreaDetailListState {
  LiveAreaDetailListState({
    LoadingState<List<LiveAreaItemEntity>?>? listState,
    this.isLoading = false,
    this.initialIndex = 0,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<LiveAreaItemEntity>?> listState;
  final bool isLoading;
  final int initialIndex;

  LiveAreaDetailListState copyWith({
    LoadingState<List<LiveAreaItemEntity>?>? listState,
    bool? isLoading,
    int? initialIndex,
  }) {
    return LiveAreaDetailListState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      initialIndex: initialIndex ?? this.initialIndex,
    );
  }
}

/// Controller for live area detail list
class LiveAreaDetailListController extends ChangeNotifier {
  LiveAreaDetailListController({
    required this.areaId,
    required this.parentAreaId,
    required FetchLiveAreaDetailUseCase fetchLiveAreaDetail,
  }) : _fetchLiveAreaDetail = fetchLiveAreaDetail {
    queryData();
  }

  final dynamic areaId;
  final dynamic parentAreaId;
  final FetchLiveAreaDetailUseCase _fetchLiveAreaDetail;

  LiveAreaDetailListState _state = LiveAreaDetailListState();

  LiveAreaDetailListState get state => _state;

  Future<void> queryData() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    final result = await _fetchLiveAreaDetail(parentAreaId: parentAreaId);

    if (result is Loading) {
      _state = _state.copyWith(
        listState: LoadingState.loading(),
        isLoading: false,
      );
    } else if (result is Error) {
      _state = _state.copyWith(
        listState: result,
        isLoading: false,
      );
    } else if (result is Success<List<LiveAreaItemEntity>>) {
      final dataList = result.response;

      // Calculate initialIndex as in original controller
      int initialIdx = 0;
      if (dataList.isNotEmpty) {
        initialIdx = max(0, dataList.indexWhere((e) => e.id == areaId));
      }

      _state = _state.copyWith(
        listState: Success(dataList),
        isLoading: false,
        initialIndex: initialIdx,
      );
    }

    notifyListeners();
  }

  Future<void> onReload() {
    _state = _state.copyWith(listState: LoadingState.loading());
    notifyListeners();
    return queryData();
  }
}
