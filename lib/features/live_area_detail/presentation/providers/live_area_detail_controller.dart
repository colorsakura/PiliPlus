import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/live_area_detail/domain/entities/live_area_item_entity.dart';
import 'package:PiliPlus/features/live_area_detail/domain/usecases/fetch_live_area_detail.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/live_area_detail/presentation/providers/live_area_detail_list_provider.dart';

part 'live_area_detail_controller.g.dart';

/// State for live area detail list
class LiveAreaDetailState {
  LiveAreaDetailState({
    LoadingState<List<LiveAreaItemEntity>?>? listState,
    this.isLoading = false,
    this.initialIndex = 0,
  }) : listState = listState ?? LoadingState.loading();

  final LoadingState<List<LiveAreaItemEntity>?> listState;
  final bool isLoading;
  final int initialIndex;

  LiveAreaDetailState copyWith({
    LoadingState<List<LiveAreaItemEntity>?>? listState,
    bool? isLoading,
    int? initialIndex,
  }) {
    return LiveAreaDetailState(
      listState: listState ?? this.listState,
      isLoading: isLoading ?? this.isLoading,
      initialIndex: initialIndex ?? this.initialIndex,
    );
  }
}

/// Controller for live area detail list (Riverpod version)
@riverpod
class LiveAreaDetailController extends _$LiveAreaDetailController {
  @override
  LiveAreaDetailState build(dynamic areaId, dynamic parentAreaId) {
    queryData(areaId, parentAreaId);
    return LiveAreaDetailState();
  }

  Future<void> queryData(dynamic areaId, dynamic parentAreaId) async {
    state = state.copyWith(isLoading: true);

    final fetchLiveAreaDetail = ref.read(fetchLiveAreaDetailUseCaseProvider);
    final result = await fetchLiveAreaDetail(parentAreaId: parentAreaId);

    if (result is Loading) {
      state = state.copyWith(
        listState: LoadingState.loading(),
        isLoading: false,
      );
    } else if (result is Error) {
      state = state.copyWith(
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

      state = state.copyWith(
        listState: Success(dataList),
        isLoading: false,
        initialIndex: initialIdx,
      );
    }
  }

  Future<void> onReload(dynamic areaId, dynamic parentAreaId) {
    state = state.copyWith(listState: LoadingState.loading());
    return queryData(areaId, parentAreaId);
  }
}
