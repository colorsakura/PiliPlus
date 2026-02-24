import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/coin_log/data.dart';

/// 经验日志远程数据源
///
/// 负责从远程API获取经验日志数据
class ExpLogRemoteDataSource {
  /// 获取经验日志
  Future<LoadingState<CoinLogData>> getExpLog() {
    return UserHttp.expLog();
  }
}
