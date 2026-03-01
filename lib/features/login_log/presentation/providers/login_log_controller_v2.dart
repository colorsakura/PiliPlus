import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:PiliPlus/features/login_log/domain/usecases/get_login_log_usecase.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_log/list.dart';
import 'package:PiliPlus/features/login_log/presentation/providers/login_log_providers.dart';

part 'login_log_controller_v2.g.dart';

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

/// Controller for login log (Riverpod version)
@riverpod
class LoginLogController extends _$LoginLogController {
  @override
  LoginLogState build() {
    queryData();
    return LoginLogState(listState: LoadingState.loading());
  }

  /// Fetch login log
  Future<void> queryData({bool isRefresh = true}) async {
    if (state.isEnd && !isRefresh) return;

    final getLoginLogUseCase = ref.read(getLoginLogUseCaseProvider);
    final result = await getLoginLogUseCase();

    final listState = switch (result) {
      Loading() => LoadingState<List<LoginLogItem>?>.loading(),
      Success(:final response) => Success(response.list),
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
  }

  /// Refresh login log
  Future<void> onRefresh() => queryData(isRefresh: true);

  /// Reload login log
  Future<void> onReload() => queryData(isRefresh: true);
}
