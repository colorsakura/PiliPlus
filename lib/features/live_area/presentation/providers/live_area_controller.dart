import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/models/live/live_area_list/area_list.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/get_live_area_list_usecase.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/get_live_fav_tag_usecase.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/set_live_fav_tag_usecase.dart';

/// State for live area
class LiveAreaState {
  const LiveAreaState({
    required this.listState,
    required this.favState,
    this.isEditing = false,
  });

  final LoadingState<List<AreaList>?> listState;
  final LoadingState<List<AreaItem>> favState;
  final bool isEditing;

  LiveAreaState copyWith({
    LoadingState<List<AreaList>?>? listState,
    LoadingState<List<AreaItem>>? favState,
    bool? isEditing,
  }) {
    return LiveAreaState(
      listState: listState ?? this.listState,
      favState: favState ?? this.favState,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

/// Controller for live area
class LiveAreaController extends ChangeNotifier {
  LiveAreaController({
    required this.isLogin,
    required GetLiveAreaListUseCase getLiveAreaListUseCase,
    required GetLiveFavTagUseCase getLiveFavTagUseCase,
    required SetLiveFavTagUseCase setLiveFavTagUseCase,
  }) : _getLiveAreaListUseCase = getLiveAreaListUseCase,
       _getLiveFavTagUseCase = getLiveFavTagUseCase,
       _setLiveFavTagUseCase = setLiveFavTagUseCase,
       _state = LiveAreaState(
         listState: LoadingState.loading(),
         favState: LoadingState.loading(),
       ) {
    if (isLogin) {
      queryFavTags();
    }
    queryData();
  }

  final bool isLogin;
  final GetLiveAreaListUseCase _getLiveAreaListUseCase;
  final GetLiveFavTagUseCase _getLiveFavTagUseCase;
  final SetLiveFavTagUseCase _setLiveFavTagUseCase;

  LiveAreaState _state;

  LiveAreaState get state => _state;

  void _updateState(LiveAreaState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Fetch live area list
  Future<void> queryData() async {
    final result = await _getLiveAreaListUseCase();

    final listState = switch (result) {
      Loading() => LoadingState<List<AreaList>?>.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };

    _updateState(_state.copyWith(listState: listState));
  }

  /// Fetch favorite tags
  Future<void> queryFavTags() async {
    final result = await _getLiveFavTagUseCase();
    _updateState(_state.copyWith(favState: result));
  }

  /// Set favorite tags
  Future<void> setFavTag() async {
    final favState = _state.favState;
    if (favState case Success(:final response)) {
      final ids = response.map((e) => e.id).join(',');
      final result = await _setLiveFavTagUseCase(ids);
      if (result.isSuccess) {
        _updateState(_state.copyWith(isEditing: false));
      }
      result.toast();
    } else {
      _updateState(_state.copyWith(isEditing: false));
    }
  }

  /// Toggle edit mode
  void onEdit() {
    if (_state.isEditing) {
      setFavTag();
    } else {
      _updateState(_state.copyWith(isEditing: true));
    }
  }

  /// Refresh data
  Future<void> onRefresh() async {
    if (isLogin) {
      await queryFavTags();
    }
    await queryData();
  }
}
