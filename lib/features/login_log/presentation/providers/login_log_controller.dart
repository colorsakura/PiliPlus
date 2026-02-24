import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_log/list.dart';
import 'package:PiliPlus/features/login_log/domain/usecases/get_login_log_usecase.dart';

/// State for login log
class LoginLogState {
  const LoginLogState({
    required this.listState,
    this.currentPage = 1,
    this.isEnd = false,
  });

  final LoadingState<List<LoginLogItem>?> listState;
  final int currentPage;
  final bool isEnd;

  LoginLogState copyWith({
    LoadingState<List<LoginLogItem>?>? listState,
    int? currentPage,
    bool? isEnd,
  }) {
    return LoginLogState(
      listState: listState ?? this.listState,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// Controller for login log
class LoginLogController extends ChangeNotifier {
  LoginLogController({
    required GetLoginLogUseCase getLoginLogUseCase,
  }) : _getLoginLogUseCase = getLoginLogUseCase,
       _state = LoginLogState(listState: LoadingState.loading()) {
    queryData();
  }

  final GetLoginLogUseCase _getLoginLogUseCase;

  LoginLogState _state;

  LoginLogState get state => _state;

  /// Fetch login log
  Future<void> queryData({bool isRefresh = true}) async {
    if (_state.isEnd && !isRefresh) return;

    final result = await _getLoginLogUseCase();

    final listState = switch (result) {
      Loading() => LoadingState<List<LoginLogItem>?>.loading(),
      Success(:final response) => Success(response.list),
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

  /// Refresh login log
  Future<void> onRefresh() => queryData(isRefresh: true);

  /// Reload login log
  Future<void> onReload() => queryData(isRefresh: true);
}
