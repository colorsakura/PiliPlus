import 'package:PiliPlus/features/later/data/datasources/later_remote_datasource.dart';
import 'package:PiliPlus/features/later/domain/entities/later_item.dart';
import 'package:PiliPlus/features/later/domain/entities/later_result.dart';
import 'package:PiliPlus/features/later/domain/entities/later_view_type.dart';
import 'package:PiliPlus/features/later/domain/repositories/later_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/later/data.dart';

/// 稍后再看仓库实现
class LaterRepositoryImpl implements LaterRepository {
  final LaterRemoteDataSource _remoteDataSource;

  LaterRepositoryImpl({
    required LaterRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LaterResultEntity> getLaterList({
    required int page,
    required LaterViewType viewType,
    String keyword = '',
    bool asc = false,
  }) async {
    final result = await _remoteDataSource.fetchLaterList(
      page: page,
      viewType: viewType,
      keyword: keyword,
      asc: asc,
    );

    return _mapLaterResult(result);
  }

  @override
  Future<bool> removeLaterItem(String aids) async {
    final result = await _remoteDataSource.removeLaterItem(aids);
    return result.isSuccess;
  }

  @override
  Future<bool> clearLater([int? cleanType]) async {
    final result = await _remoteDataSource.clearLater(cleanType);
    return result.isSuccess;
  }

  /// 将API响应映射为领域实体
  LaterResultEntity _mapLaterResult(
    LoadingState<LaterData> result,
  ) {
    if (result case Success(:final response)) {
      final list = response.list?.map(LaterItemEntity.fromModel).toList() ?? [];

      return LaterResultEntity(
        items: list,
        totalCount: response.count ?? 0,
      );
    } else if (result case Error(:final errMsg)) {
      throw Exception(errMsg);
    } else {
      throw Exception('加载中...');
    }
  }
}
