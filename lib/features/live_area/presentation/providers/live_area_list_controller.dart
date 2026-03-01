import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/models/live/live_area_list/area_item.dart';
import 'package:PiliPlus/models/live/live_area_list/area_list.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/get_live_area_list_usecase.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/get_live_fav_tag_usecase.dart';
import 'package:PiliPlus/features/live_area/domain/usecases/set_live_fav_tag_usecase.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/live_area/presentation/providers/live_area_providers.dart';

part 'live_area_list_controller.g.dart';

/// State for live area
class LiveAreaListState {
  const LiveAreaListState({
    required this.listState,
    required this.favState,
    this.isEditing = false,
  });

  final LoadingState<List<AreaList>?> listState;
  final LoadingState<List<AreaItem>> favState;
  final bool isEditing;

  LiveAreaListState copyWith({
    LoadingState<List<AreaList>?>? listState,
    LoadingState<List<AreaItem>>? favState,
    bool? isEditing,
  }) {
    return LiveAreaListState(
      listState: listState ?? this.listState,
      favState: favState ?? this.favState,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

/// Controller for live area (Riverpod version)
@riverpod
class LiveAreaListController extends _$LiveAreaListController {
  @override
  LiveAreaListState build() {
    // Check login status and fetch data
    final isLogin = ref.watch(isLoginProvider);

    if (isLogin) {
      queryFavTags();
    }
    queryData();

    return LiveAreaListState(
      listState: LoadingState.loading(),
      favState: LoadingState.loading(),
    );
  }

  /// Fetch live area list
  Future<void> queryData() async {
    final getAreaList = ref.read(getLiveAreaListUseCaseProvider);
    final result = await getAreaList();

    final listState = switch (result) {
      Loading() => LoadingState<List<AreaList>?>.loading(),
      Success(:final response) => Success(response),
      Error(:final errMsg) => Error(errMsg),
    };

    state = state.copyWith(listState: listState);
  }

  /// Fetch favorite tags
  Future<void> queryFavTags() async {
    final getFavTag = ref.read(getLiveFavTagUseCaseProvider);
    final result = await getFavTag();
    state = state.copyWith(favState: result);
  }

  /// Set favorite tags
  Future<void> setFavTag() async {
    final favState = state.favState;
    if (favState case Success(:final response)) {
      final ids = response.map((e) => e.id).join(',');
      final setFavTag = ref.read(setLiveFavTagUseCaseProvider);
      final result = await setFavTag(ids);
      if (result.isSuccess) {
        state = state.copyWith(isEditing: false);
      }
      result.toast();
    } else {
      state = state.copyWith(isEditing: false);
    }
  }

  /// Toggle edit mode
  void onEdit() {
    if (state.isEditing) {
      setFavTag();
    } else {
      state = state.copyWith(isEditing: true);
    }
  }

  /// Refresh data
  Future<void> onRefresh() async {
    final isLogin = ref.watch(isLoginProvider);
    if (isLogin) {
      await queryFavTags();
    }
    await queryData();
  }
}
