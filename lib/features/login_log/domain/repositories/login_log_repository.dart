import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_log/data.dart';

/// Repository interface for login log
abstract class LoginLogRepository {
  /// Fetch login log
  Future<LoadingState<LoginLogData>> getLoginLog();
}
