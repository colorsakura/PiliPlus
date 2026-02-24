import 'package:PiliPlus/features/coin_log/domain/entities/coin_log_item.dart';
import 'package:PiliPlus/features/coin_log/domain/repositories/coin_log_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 获取硬币日志用例
///
/// 负责获取硬币日志的业务逻辑
class GetCoinLogUseCase {
  final CoinLogRepository _repository;

  const GetCoinLogUseCase(this._repository);

  /// 获取硬币日志
  Future<LoadingState<CoinLogResultEntity>> call() {
    return _repository.getCoinLog();
  }
}
