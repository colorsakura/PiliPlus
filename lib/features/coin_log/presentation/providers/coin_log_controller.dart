import 'package:PiliPlus/features/coin_log/domain/entities/coin_log_item.dart';
import 'package:PiliPlus/features/coin_log/domain/usecases/get_coin_log.dart';
import 'package:PiliPlus/features/coin_log/presentation/providers/coin_log_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 硬币日志页面状态
class CoinLogState {
  /// 加载状态
  final LoadingState<List<CoinLogItemEntity>?> loadingState;

  /// 标题
  final String title;

  const CoinLogState({
    required this.loadingState,
    required this.title,
  });

  /// 复制并更新状态
  CoinLogState copyWith({
    LoadingState<List<CoinLogItemEntity>?>? loadingState,
    String? title,
  }) {
    return CoinLogState(
      loadingState: loadingState ?? this.loadingState,
      title: title ?? this.title,
    );
  }

  /// 获取表头
  CoinLogItemEntity get header => CoinLogItemEntity.header;

  /// 获取列的flex和文本
  List<(int, String)> getFlexAndText(CoinLogItemEntity item) {
    return [(3, item.time), (1, item.delta), (4, item.reason)];
  }
}

/// 硬币日志Controller
///
/// 使用Riverpod管理硬币日志页面的状态
class CoinLogController extends Notifier<CoinLogState> {
  late final GetCoinLogUseCase _getCoinLogUseCase;

  @override
  CoinLogState build() {
    _getCoinLogUseCase = ref.read(getCoinLogUseCaseProvider);
    // 自动加载数据
    fetchCoinLog();
    return CoinLogState(
      loadingState: LoadingState.loading(),
      title: '硬币记录',
    );
  }

  /// 获取硬币日志
  Future<void> fetchCoinLog() async {
    state = CoinLogState(
      loadingState: LoadingState.loading(),
      title: '硬币记录',
    );
    final result = await _getCoinLogUseCase();

    state = switch (result) {
      Loading() => CoinLogState(
          loadingState: LoadingState.loading(),
          title: '硬币记录',
        ),
      Success(:final response) => CoinLogState(
          loadingState: Success(response.items),
          title: '硬币记录',
        ),
      Error() => CoinLogState(
          loadingState: result as LoadingState<List<CoinLogItemEntity>?>,
          title: '硬币记录',
        ),
    };
  }

  /// 重新加载数据
  void onReload() {
    fetchCoinLog();
  }
}
