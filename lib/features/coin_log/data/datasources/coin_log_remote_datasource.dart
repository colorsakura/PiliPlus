import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/coin_log/data.dart';

/// 硬币日志远程数据源
///
/// 负责从远程API获取硬币日志数据
class CoinLogRemoteDataSource {
  /// 获取硬币日志
  Future<LoadingState<CoinLogData>> getCoinLog() {
    return UserHttp.coinLog();
  }
}
