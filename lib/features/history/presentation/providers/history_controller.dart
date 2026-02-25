import 'package:PiliPlus/features/history/domain/entities/history_item.dart';
import 'package:PiliPlus/features/history/domain/entities/history_result.dart';
import 'package:PiliPlus/features/history/domain/usecases/delete_history.dart';
import 'package:PiliPlus/features/history/domain/usecases/fetch_history.dart';
import 'package:PiliPlus/features/history/domain/usecases/get_history_status.dart';
import 'package:PiliPlus/features/history/presentation/providers/history_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 历史记录状态
class HistoryState {
  final HistoryResultEntity? result;
  final bool isLoading;
  final String? errorMessage;

  const HistoryState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  List<HistoryItemEntity> get items => result?.items ?? [];
  bool get hasMore => result?.hasMore ?? false;

  HistoryState copyWith({
    HistoryResultEntity? result,
    bool? isLoading,
    String? errorMessage,
  }) {
    return HistoryState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 历史记录控制器 (使用 Riverpod 3.x 的 Notifier)
/// 支持通过参数区分不同的历史记录类型
class HistoryController extends Notifier<HistoryState> {
  late FetchHistoryUseCase _fetchUseCase;
  late DeleteHistoryUseCase _deleteUseCase;
  late GetHistoryStatusUseCase _getStatusUseCase;

  // 存储不同类型的分页状态
  final Map<String?, _PaginationState> _paginationStates = {};

  @override
  HistoryState build() {
    // 注入依赖
    _fetchUseCase = ref.watch(fetchHistoryUseCaseProvider);
    _deleteUseCase = ref.watch(deleteHistoryUseCaseProvider);
    _getStatusUseCase = ref.watch(getHistoryStatusUseCaseProvider);

    return const HistoryState();
  }

  _PaginationState _getPaginationState(String? type) {
    return _paginationStates.putIfAbsent(
      type ?? 'all',
      () => _PaginationState(),
    );
  }

  List<HistoryItemEntity> get items => state.result?.items ?? [];
  bool get hasMore => state.result?.hasMore ?? false;

  Future<void> initialize({String? type}) async {
    _resetPagination(type);
    await loadHistory(type: type, isRefresh: true);
    await loadHistoryStatus();
  }

  void _resetPagination(String? type) {
    _paginationStates.remove(type ?? 'all');
  }

  Future<void> loadHistory({String? type, bool isRefresh = true}) async {
    final pagination = _getPaginationState(type);
    if (state.isLoading && state.result != null) return;
    if (!isRefresh && pagination.isEnd) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _fetchUseCase(
        type: type ?? 'all',
        max: pagination.maxId,
        viewAt: pagination.viewAt,
      );

      final currentResult = state.result;
      if (isRefresh || currentResult == null) {
        state = state.copyWith(result: result, isLoading: false);
      } else {
        final mergedItems = [...items, ...result.items];
        final mergedResult = HistoryResultEntity(
          items: mergedItems,
          tabs: result.tabs,
          hasMore: result.hasMore,
          maxId: result.maxId,
          viewAt: result.viewAt,
        );
        state = state.copyWith(result: mergedResult, isLoading: false);
      }

      pagination.maxId = result.maxId;
      pagination.viewAt = result.viewAt;
      pagination.isEnd = !result.hasMore;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> onRefresh({String? type}) =>
      loadHistory(type: type, isRefresh: true);

  Future<void> onLoadMore({String? type}) =>
      loadHistory(type: type, isRefresh: false);

  Future<void> loadHistoryStatus() async {
    try {
      await _getStatusUseCase();
    } catch (e) {
      // Ignore errors
    }
  }

  Future<bool> deleteHistory(List<String> keys) async {
    try {
      final success = await _deleteUseCase(keys);

      if (success && state.result != null) {
        final keySet = keys.toSet();
        final updatedItems = items
            .where((item) => !keySet.contains(item.deleteKey))
            .toList();
        final updatedResult = HistoryResultEntity(
          items: updatedItems,
          tabs: state.result!.tabs,
          hasMore: state.result!.hasMore,
          maxId: state.result!.maxId,
          viewAt: state.result!.viewAt,
        );
        state = state.copyWith(result: updatedResult);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteViewedHistory() async {
    final viewedKeys = items
        .where((item) => item.isViewed)
        .map((item) => item.deleteKey)
        .toList();
    if (viewedKeys.isEmpty) return false;
    return deleteHistory(viewedKeys);
  }

  Future<void> onReload({String? type}) {
    _resetPagination(type);
    return loadHistory(type: type, isRefresh: true);
  }
}

/// 分页状态
class _PaginationState {
  int? maxId;
  int? viewAt;
  bool isEnd = false;
}

/// Provider factory that creates a unique provider per type
final _historyControllers =
    <String?, NotifierProvider<HistoryController, HistoryState>>{};

NotifierProvider<HistoryController, HistoryState> _getHistoryControllerProvider(
  String? type,
) {
  return _historyControllers.putIfAbsent(
    type,
    () => NotifierProvider<HistoryController, HistoryState>(
      HistoryController.new,
    ),
  );
}

/// 历史记录控制器Provider - family pattern
/// 使用此provider获取状态
final historyControllerProvider = Provider.family<HistoryState, String?>((
  ref,
  type,
) {
  final provider = _getHistoryControllerProvider(type);
  return ref.watch(provider);
});

/// 历史记录控制器Notifier Provider - family pattern
/// 使用此provider获取控制器以调用方法
final historyControllerNotifierProvider =
    Provider.family<HistoryController, String?>((ref, type) {
      final provider = _getHistoryControllerProvider(type);
      return ref.watch(provider.notifier);
    });
