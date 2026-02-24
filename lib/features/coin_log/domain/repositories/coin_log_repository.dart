import 'package:PiliPlus/features/coin_log/domain/entities/coin_log_item.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 硬币日志仓库接口
///
/// 定义硬币日志相关数据操作的抽象
abstract interface class CoinLogRepository {
  /// 获取硬币日志
  Future<LoadingState<CoinLogResultEntity>> getCoinLog();
}
