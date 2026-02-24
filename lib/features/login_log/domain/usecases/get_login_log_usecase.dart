import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_log/data.dart';
import 'package:PiliPlus/features/login_log/domain/repositories/login_log_repository.dart';

/// Use case for getting login log
class GetLoginLogUseCase {
  const GetLoginLogUseCase(this._repository);

  final LoginLogRepository _repository;

  Future<LoadingState<LoginLogData>> call() => _repository.getLoginLog();
}
