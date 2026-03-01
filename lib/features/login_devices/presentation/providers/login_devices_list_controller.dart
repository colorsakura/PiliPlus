import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/login_devices/domain/usecases/get_login_devices_usecase.dart';
import 'package:PiliPlus/models/login_devices/device.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/login_devices/presentation/providers/login_devices_providers.dart';

part 'login_devices_list_controller.g.dart';

/// State for login devices
class LoginDevicesListState {
  const LoginDevicesListState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<LoginDevice>?> listState;
  final int currentPage;
  final bool isEnd;

  LoginDevicesListState copyWith({
    LoadingState<List<LoginDevice>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return LoginDevicesListState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for login devices (Riverpod version)
@riverpod
class LoginDevicesListController extends _$LoginDevicesListController {
  @override
  LoginDevicesListState build() {
    // Fetch data on initialization
    queryData();
    return LoginDevicesListState(listState: LoadingState.loading());
  }

  /// Fetch login devices
  Future<void> queryData({bool isRefresh = true}) async {
    final currentState = state;
    if (currentState.isEnd && !isRefresh) return;

    state = state.copyWith(listState: LoadingState.loading());

    try {
      final getDevices = ref.read(getLoginDevicesUseCaseProvider);
      final result = await getDevices();

      final listState = switch (result) {
        Loading() => LoadingState<List<LoginDevice>?>.loading(),
        Success(:final response) => Success(response.devices),
        Error(:final errMsg) => Error(errMsg),
      };

      if (listState case Success(:final response)) {
        final isEnd = response == null || response.isEmpty;
        state = state.copyWith(
          listState: listState,
          isEnd: isEnd,
        );
      } else {
        state = state.copyWith(listState: listState);
      }
    } catch (e) {
      state = state.copyWith(
        listState: Error(e.toString()),
      );
    }
  }

  /// Refresh devices
  Future<void> onRefresh() => queryData(isRefresh: true);

  /// Reload devices
  Future<void> onReload() => queryData(isRefresh: true);
}
