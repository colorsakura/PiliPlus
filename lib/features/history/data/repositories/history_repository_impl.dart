import 'package:PiliPlus/features/history/data/datasources/history_remote_datasource.dart';
import 'package:PiliPlus/features/history/domain/entities/history_item.dart';
import 'package:PiliPlus/features/history/domain/entities/history_result.dart';
import 'package:PiliPlus/features/history/domain/entities/history_tab.dart';
import 'package:PiliPlus/features/history/domain/repositories/history_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// 历史记录仓库实现
class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource _remoteDataSource;

  HistoryRepositoryImpl({
    required HistoryRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<HistoryResultEntity> getHistoryList({
    String? type,
    int? max,
    int? viewAt,
  }) async {
    final result = await _remoteDataSource.fetchHistoryList(
      type: type,
      max: max,
      viewAt: viewAt,
    );

    return _mapHistoryResult(result);
  }

  @override
  Future<bool> deleteHistory(List<String> keys) async {
    final result = await _remoteDataSource.deleteHistory(keys);
    return result.isSuccess;
  }

  @override
  Future<bool?> getHistoryStatus() async {
    final result = await _remoteDataSource.getHistoryStatus();
    if (result case Success(:final response)) {
      return response as bool;
    }
    return null;
  }

  /// 将API响应映射为领域实体
  HistoryResultEntity _mapHistoryResult(
    LoadingState<dynamic> result,
  ) {
    if (result case Success(:final response)) {
      // response 是 HistoryData
      final list = response.list as List<dynamic>?;
      final tabData = response.tab as List<dynamic>?;

      final items = list?.map(HistoryItemEntity.fromModel).toList() ?? [];

      final tabs = tabData?.map(HistoryTabEntity.fromModel).toList() ?? [];

      final lastItem = list?.lastOrNull;
      final hasMore = list?.isNotEmpty == true;

      return HistoryResultEntity(
        items: items,
        tabs: tabs,
        hasMore: hasMore,
        maxId: lastItem?.history?.oid as int?,
        viewAt: lastItem?.viewAt as int?,
      );
    } else if (result case Error(:final errMsg)) {
      throw Exception(errMsg);
    } else {
      throw Exception('加载中...');
    }
  }
}
