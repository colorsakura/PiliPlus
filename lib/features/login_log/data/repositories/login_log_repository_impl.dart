import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_log/data.dart';
import 'package:PiliPlus/features/login_log/domain/repositories/login_log_repository.dart';
import 'package:PiliPlus/features/login_log/data/datasources/login_log_remote_datasource.dart';

/// Repository implementation for login log
class LoginLogRepositoryImpl implements LoginLogRepository {
  const LoginLogRepositoryImpl(this._remoteDatasource);

  final LoginLogRemoteDatasource _remoteDatasource;

  @override
  Future<LoadingState<LoginLogData>> getLoginLog() =>
      _remoteDatasource.getLoginLog();
}
