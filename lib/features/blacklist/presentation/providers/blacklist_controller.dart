import 'package:PiliPlus/features/blacklist/domain/entities/blacklist_item.dart';
import 'package:PiliPlus/features/blacklist/domain/entities/blacklist_result.dart';
import 'package:PiliPlus/features/blacklist/domain/usecases/fetch_blacklist.dart';
import 'package:PiliPlus/features/blacklist/domain/usecases/remove_from_blacklist.dart';
import 'package:PiliPlus/features/blacklist/presentation/providers/blacklist_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 黑名单状态
class BlacklistState {
  /// 黑名单结果
  final BlacklistResultEntity? result;

  /// 是否正在加载
  final bool isLoading;

  /// 错误信息
  final String? errorMessage;

  const BlacklistState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  /// 复制并更新
  BlacklistState copyWith({
    BlacklistResultEntity? result,
    bool? isLoading,
    String? errorMessage,
  }) {
    return BlacklistState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// 获取用户列表
  List<BlacklistItemEntity> get items {
    return result?.items ?? [];
  }

  /// 获取总数
  int get total {
    return result?.total ?? 0;
  }

  /// 是否为空
  bool get isEmpty {
    return items.isEmpty && !isLoading;
  }
}

/// 黑名单Controller
class BlacklistController extends Notifier<BlacklistState> {
  late final FetchBlacklistUseCase _fetchUseCase;
  late final RemoveFromBlacklistUseCase _removeUseCase;

  int _currentPage = 1;
  bool _isEnd = false;
  static const int _pageSize = 50;

  @override
  BlacklistState build() {
    _fetchUseCase = ref.read(fetchBlacklistUseCaseProvider);
    _removeUseCase = ref.read(removeFromBlacklistUseCaseProvider);

    return const BlacklistState(isLoading: true);
  }

  /// 初始化并加载数据
  Future<void> initialize() => fetchBlacklist(isRefresh: true);

  /// 获取黑名单
  Future<void> fetchBlacklist({bool isRefresh = true}) async {
    if (state.isLoading && state.result != null) return;
    if (!isRefresh && _isEnd) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _fetchUseCase(
        pn: isRefresh ? 1 : _currentPage,
        ps: _pageSize,
      );

      if (isRefresh) {
        _currentPage = 1;
        _isEnd = false;
        state = state.copyWith(result: result);
      } else {
        final currentItems = state.result?.items ?? [];
        final mergedItems = [...currentItems, ...result.items];

        state = state.copyWith(
          result: BlacklistResultEntity(
            items: mergedItems,
            total: result.total,
            hasMore: result.hasMore,
            currentPage: result.currentPage,
          ),
        );
      }

      _currentPage++;
      _isEnd = !result.hasMore;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 刷新
  Future<void> onRefresh() => fetchBlacklist(isRefresh: true);

  /// 加载更多
  Future<void> onLoadMore() => fetchBlacklist(isRefresh: false);

  /// 重试
  Future<void> onReload() => fetchBlacklist(isRefresh: true);

  /// 从黑名单移除用户
  ///
  /// [index] 列表索引
  /// [mid] 用户ID
  /// 返回是否成功
  Future<bool> removeFromBlacklist(int index, int mid) async {
    try {
      final success = await _removeUseCase(mid: mid);

      if (success && state.result != null) {
        final updatedItems = List<BlacklistItemEntity>.from(state.result!.items)
          ..removeAt(index);

        state = state.copyWith(
          result: BlacklistResultEntity(
            items: updatedItems,
            total: state.result!.total - 1,
            hasMore: state.result!.hasMore,
            currentPage: state.result!.currentPage,
          ),
        );
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// 从列表中移除视频（用于UI直接更新）
  void removeVideo(int index) {
    if (state.result != null &&
        index >= 0 &&
        index < state.result!.items.length) {
      final updatedItems = List<BlacklistItemEntity>.from(state.result!.items)
        ..removeAt(index);

      state = state.copyWith(
        result: BlacklistResultEntity(
          items: updatedItems,
          total: state.result!.total - 1,
          hasMore: state.result!.hasMore,
          currentPage: state.result!.currentPage,
        ),
      );
    }
  }
}

/// 黑名单Controller Provider
final blacklistControllerProvider =
    NotifierProvider<BlacklistController, BlacklistState>(
      BlacklistController.new,
    );
