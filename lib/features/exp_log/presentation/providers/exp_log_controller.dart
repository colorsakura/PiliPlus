import 'package:PiliPlus/features/exp_log/domain/entities/exp_log_item.dart';
import 'package:PiliPlus/features/exp_log/domain/usecases/get_exp_log.dart';
import 'package:PiliPlus/features/exp_log/presentation/providers/exp_log_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 经验日志页面状态
class ExpLogState {
  /// 加载状态
  final LoadingState<List<ExpLogItemEntity>?> loadingState;

  /// 标题
  final String title;

  const ExpLogState({
    required this.loadingState,
    required this.title,
  });

  /// 复制并更新状态
  ExpLogState copyWith({
    LoadingState<List<ExpLogItemEntity>?>? loadingState,
    String? title,
  }) {
    return ExpLogState(
      loadingState: loadingState ?? this.loadingState,
      title: title ?? this.title,
    );
  }

  /// 获取表头
  ExpLogItemEntity get header => ExpLogItemEntity.header;

  /// 获取列的flex和文本
  List<(int, String)> getFlexAndText(ExpLogItemEntity item) {
    return [(2, item.time), (1, item.delta), (2, item.reason)];
  }
}

/// 经验日志Controller
///
/// 使用Riverpod管理经验日志页面的状态
class ExpLogController extends Notifier<ExpLogState> {
  late final GetExpLogUseCase _getExpLogUseCase;

  @override
  ExpLogState build() {
    _getExpLogUseCase = ref.read(getExpLogUseCaseProvider);
    // 自动加载数据
    fetchExpLog();
    return ExpLogState(
      loadingState: LoadingState.loading(),
      title: '经验记录',
    );
  }

  /// 获取经验日志
  Future<void> fetchExpLog() async {
    state = ExpLogState(
      loadingState: LoadingState.loading(),
      title: '经验记录',
    );
    final result = await _getExpLogUseCase();

    state = switch (result) {
      Loading() => ExpLogState(
        loadingState: LoadingState.loading(),
        title: '经验记录',
      ),
      Success(:final response) => ExpLogState(
        loadingState: Success(response.items),
        title: '经验记录',
      ),
      Error() => ExpLogState(
        loadingState: result as LoadingState<List<ExpLogItemEntity>?>,
        title: '经验记录',
      ),
    };
  }

  /// 重新加载数据
  void onReload() {
    fetchExpLog();
  }
}
