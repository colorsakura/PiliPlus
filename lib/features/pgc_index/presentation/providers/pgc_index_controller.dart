import 'package:PiliPlus/features/pgc_index/domain/entities/pgc_index_item.dart';
import 'package:PiliPlus/features/pgc_index/presentation/providers/pgc_index_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/pgc/pgc_index_condition/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PGC索引页面状态
class PgcIndexState {
  /// 条件数据加载状态
  final LoadingState<PgcIndexConditionData> conditionState;

  /// 列表数据加载状态
  final LoadingState<List<PgcIndexItemEntity>?> loadingState;

  /// 索引参数
  final Map<String, dynamic> indexParams;

  /// 是否展开更多筛选
  final bool isExpand;

  /// 当前页码
  final int currentPage;

  /// 是否已加载到末尾
  final bool isEnd;

  const PgcIndexState({
    required this.conditionState,
    required this.loadingState,
    this.indexParams = const {},
    this.isExpand = false,
    this.currentPage = 1,
    this.isEnd = false,
  });

  PgcIndexState copyWith({
    LoadingState<PgcIndexConditionData>? conditionState,
    LoadingState<List<PgcIndexItemEntity>?>? loadingState,
    Map<String, dynamic>? indexParams,
    bool? isExpand,
    int? currentPage,
    bool? isEnd,
  }) {
    return PgcIndexState(
      conditionState: conditionState ?? this.conditionState,
      loadingState: loadingState ?? this.loadingState,
      indexParams: indexParams ?? this.indexParams,
      isExpand: isExpand ?? this.isExpand,
      currentPage: currentPage ?? this.currentPage,
      isEnd: isEnd ?? this.isEnd,
    );
  }
}

/// PGC索引Controller
class PgcIndexController extends Notifier<PgcIndexState> {
  final int? indexType;

  PgcIndexController({required this.indexType});

  @override
  PgcIndexState build() {
    // 自动加载条件
    fetchCondition();

    return PgcIndexState(
      conditionState: LoadingState.loading(),
      loadingState: LoadingState.loading(),
    );
  }

  /// 获取索引条件
  Future<void> fetchCondition() async {
    final getConditionUseCase = ref.read(getPgcIndexConditionUseCaseProvider);
    final res = await getConditionUseCase(indexType: indexType);

    if (res case Success(:final response)) {
      final params = <String, dynamic>{};

      if (response.order?.isNotEmpty == true) {
        params['order'] = response.order!.first.field;
      }
      if (response.filter?.isNotEmpty == true) {
        for (final item in response.filter!) {
          params['${item.field}'] = item.values?.firstOrNull?.keyword;
        }
      }

      state = state.copyWith(
        conditionState: res,
        indexParams: params,
      );

      // 获取数据
      fetchResult();
    } else {
      state = state.copyWith(
        conditionState: res,
      );
    }
  }

  /// 获取索引结果
  Future<void> fetchResult({bool isRefresh = true}) async {
    if (state.isEnd && !isRefresh) return;

    final getResultUseCase = ref.read(getPgcIndexResultUseCaseProvider);
    final page = isRefresh ? 1 : state.currentPage;
    final res = await getResultUseCase(
      page: page,
      params: state.indexParams,
      indexType: indexType,
    );

    if (res case Success(:final response)) {
      final currentList = state.loadingState is Success
          ? state.loadingState.response ?? []
          : <PgcIndexItemEntity>[];

      final newList = isRefresh
          ? (response ?? [])
          : [...currentList, ...?response];
      final isEnd = response == null || response.isEmpty;

      state = state.copyWith(
        loadingState: Success(newList),
        currentPage: page + 1,
        isEnd: isEnd,
      );
    } else {
      state = state.copyWith(
        loadingState: res,
      );
    }
  }

  /// 刷新
  Future<void> onRefresh() async {
    await fetchCondition();
  }

  /// 重新加载
  void onReload() {
    fetchCondition();
  }

  /// 加载更多
  void onLoadMore() {
    fetchResult(isRefresh: false);
  }

  /// 更新参数
  void updateParam(String key, dynamic value) {
    final newParams = Map<String, dynamic>.from(state.indexParams);
    newParams[key] = value;
    state = state.copyWith(indexParams: newParams);
    fetchResult();
  }

  /// 切换展开状态
  void toggleExpand() {
    state = state.copyWith(isExpand: !state.isExpand);
  }
}
