import 'package:PiliPlus/features/exp_log/domain/entities/exp_log_item.dart';
import 'package:PiliPlus/features/exp_log/domain/repositories/exp_log_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 获取经验日志用例
///
/// 负责获取经验日志的业务逻辑
class GetExpLogUseCase {
  final ExpLogRepository _repository;

  const GetExpLogUseCase(this._repository);

  /// 获取经验日志
  Future<LoadingState<ExpLogResultEntity>> call() {
    return _repository.getExpLog();
  }
}
