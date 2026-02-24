import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/login_log/data.dart';

/// Remote data source for login log
class LoginLogRemoteDatasource {
  const LoginLogRemoteDatasource();

  /// Fetch login log
  Future<LoadingState<LoginLogData>> getLoginLog() => UserHttp.loginLog();
}
