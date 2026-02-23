import 'package:PiliPlus/features/later/domain/entities/later_item.dart';
import 'package:PiliPlus/features/later/domain/entities/later_view_type.dart'
    as domain;
import 'package:PiliPlus/features/later/domain/usecases/clear_later.dart';
import 'package:PiliPlus/features/later/domain/usecases/fetch_later.dart';
import 'package:PiliPlus/features/later/domain/usecases/remove_later_item.dart';
import 'package:PiliPlus/features/later/presentation/providers/later_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 稍后再看状态
class LaterState {
  /// 列表数据
  final List<LaterItemEntity> items;

  /// 总数
  final int totalCount;

  /// 是否加载中
  final bool isLoading;

  /// 是否已到底
  final bool isEnd;

  /// 错误信息
  final String? errorMessage;

  const LaterState({
    this.items = const [],
    this.totalCount = 0,
    this.isLoading = false,
    this.isEnd = false,
    this.errorMessage,
  });

  LaterState copyWith({
    List<LaterItemEntity>? items,
    int? totalCount,
    bool? isLoading,
    bool? isEnd,
    String? errorMessage,
  }) {
    return LaterState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 稍后再看控制器 (使用 Riverpod 3.x 的 Notifier)
class LaterController extends Notifier<LaterState> {
  late FetchLaterUseCase _fetchUseCase;
  late RemoveLaterItemUseCase _removeUseCase;
  late ClearLaterUseCase _clearUseCase;

  int _currentPage = 1;
  bool _isEnd = false;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

  @override
  LaterState build() {
    // 注入依赖
    _fetchUseCase = ref.watch(fetchLaterUseCaseProvider);
    _removeUseCase = ref.watch(removeLaterItemUseCaseProvider);
    _clearUseCase = ref.watch(clearLaterUseCaseProvider);

    // 获取类型参数
    final viewType = ref.watch(_viewTypeProvider);

    // 初始化数据加载
    _initializeWithData(viewType);

    return const LaterState();
  }

  void _initializeWithData(domain.LaterViewType viewType) {
    // Schedule initialization after the build
    Future.microtask(() => init(viewType));
  }

  /// 初始化并获取稍后再看列表
  Future<void> init(domain.LaterViewType viewType) async {
    _currentPage = 1;
    _isEnd = false;
    await fetchLaterList(viewType);
  }

  /// 获取稍后再看列表
  Future<void> fetchLaterList(domain.LaterViewType viewType) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _fetchUseCase(
        page: _currentPage,
        viewType: viewType,
      );

      if (_currentPage == 1) {
        state = state.copyWith(
          items: result.items,
          totalCount: result.totalCount,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          items: [...state.items, ...result.items],
          totalCount: result.totalCount,
          isLoading: false,
        );
      }

      // 检查是否已到底
      if (state.items.length >= state.totalCount) {
        _isEnd = true;
        state = state.copyWith(isEnd: true);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 加载更多
  Future<void> onLoadMore(domain.LaterViewType viewType) async {
    if (_isEnd || state.isLoading) return;
    _currentPage++;
    await fetchLaterList(viewType);
  }

  /// 下拉刷新
  Future<void> onRefresh(domain.LaterViewType viewType) async {
    await init(viewType);
  }

  /// 删除稍后再看项
  Future<bool> removeItem(String aid, domain.LaterViewType viewType) async {
    try {
      final success = await _removeUseCase(aid);
      if (success) {
        // 从列表中移除
        final aidInt = int.tryParse(aid);
        final updatedItems = state.items.where((item) => item.aid != aidInt).toList();
        state = state.copyWith(
          items: updatedItems,
          totalCount: state.totalCount - 1,
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// 批量删除
  Future<bool> removeItems(
    List<String> aids,
    domain.LaterViewType viewType,
  ) async {
    try {
      final aidsStr = aids.join(',');
      final success = await _removeUseCase(aidsStr);
      if (success) {
        // 从列表中移除
        final aidInts = aids.map((e) => int.tryParse(e)).whereType<int>().toSet();
        final updatedItems =
            state.items.where((item) => !aidInts.contains(item.aid)).toList();
        state = state.copyWith(
          items: updatedItems,
          totalCount: state.totalCount - aids.length,
        );
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// 清空稍后再看
  /// [cleanType] 1-清空失效, 2-清空看完, null-清空全部
  Future<bool> clear([int? cleanType]) async {
    try {
      final success = await _clearUseCase(cleanType);
      if (success) {
        state = state.copyWith(items: [], totalCount: 0);
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  /// 重置状态
  void reset() {
    _currentPage = 1;
    _isEnd = false;
    state = const LaterState();
  }
}

/// Provider for the viewType parameter - internal
final _viewTypeProvider = Provider<domain.LaterViewType>(
  (ref) => domain.LaterViewType.all,
);

/// Provider factory that creates a unique provider per viewType
final _laterControllers = <domain.LaterViewType,
    NotifierProvider<LaterController, LaterState>>{};

NotifierProvider<LaterController, LaterState> _getLaterControllerProvider(
    domain.LaterViewType viewType) {
  return _laterControllers.putIfAbsent(
    viewType,
    () => NotifierProvider<LaterController, LaterState>(
      LaterController.new,
    ),
  );
}

/// 稍后再看控制器Provider - family pattern
/// 使用此provider获取状态
final laterControllerProvider =
    Provider.family<LaterState, domain.LaterViewType>((ref, viewType) {
  final provider = _getLaterControllerProvider(viewType);
  return ref.watch(provider);
});

/// 稍后再看控制器Notifier Provider - family pattern
/// 使用此provider获取控制器以调用方法和访问scrollController
final laterControllerNotifierProvider =
    Provider.family<LaterController, domain.LaterViewType>((ref, viewType) {
  final provider = _getLaterControllerProvider(viewType);
  return ref.watch(provider.notifier);
});
