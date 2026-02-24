import 'package:PiliPlus/features/exp_log/domain/entities/exp_log_item.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 经验日志仓库接口
///
/// 定义经验日志相关数据操作的抽象
abstract interface class ExpLogRepository {
  /// 获取经验日志
  Future<LoadingState<ExpLogResultEntity>> getExpLog();
}
