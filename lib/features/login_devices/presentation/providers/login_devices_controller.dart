import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_devices/device.dart';
import 'package:PiliPlus/features/login_devices/domain/usecases/get_login_devices_usecase.dart';

/// State for login devices
class LoginDevicesState {
  const LoginDevicesState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<LoginDevice>?> listState;
  final int currentPage;
  final bool isEnd;

  LoginDevicesState copyWith({
    LoadingState<List<LoginDevice>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return LoginDevicesState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for login devices
class LoginDevicesController extends ChangeNotifier {
  LoginDevicesController({
    required GetLoginDevicesUseCase getLoginDevicesUseCase,
  }) : _getLoginDevicesUseCase = getLoginDevicesUseCase,
       _state = LoginDevicesState(listState: LoadingState.loading()) {
    queryData();
  }

  final GetLoginDevicesUseCase _getLoginDevicesUseCase;

  LoginDevicesState _state;

  LoginDevicesState get state => _state;

  /// Fetch login devices
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final result = await _getLoginDevicesUseCase();

    final listState = switch (result) {
      Loading() => LoadingState<List<LoginDevice>?>.loading(),
      Success(:final response) => Success(response.devices),
      Error(:final errMsg) => Error(errMsg),
    };

    if (listState case Success(:final response)) {
      final isEnd = response == null || response.isEmpty;
      _state = _state.copyWith(
        listState: listState,
        isEnd: isEnd,
      );
    } else {
      _state = _state.copyWith(listState: listState);
    }

    notifyListeners();
  }

  /// Refresh devices
  Future<void> onRefresh() => queryData(isRefresh: true);

  /// Reload devices
  Future<void> onReload() => queryData(isRefresh: true);
}
