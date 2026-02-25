import 'package:PiliPlus/features/blacklist/data/datasources/blacklist_remote_datasource.dart';
import 'package:PiliPlus/features/blacklist/domain/entities/blacklist_item.dart';
import 'package:PiliPlus/features/blacklist/domain/entities/blacklist_result.dart';
import 'package:PiliPlus/features/blacklist/domain/repositories/blacklist_repository.dart';
import 'package:PiliPlus/features/user/data/datasources/user_remote_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/blacklist/data.dart';

/// 黑名单仓库实现
///
/// 实现黑名单相关的数据操作
class BlacklistRepositoryImpl implements BlacklistRepository {
  final BlacklistRemoteDataSource _remoteDataSource;
  final UserRemoteDataSource _userRemoteDataSource;

  BlacklistRepositoryImpl({
    required BlacklistRemoteDataSource remoteDataSource,
    required UserRemoteDataSource userRemoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _userRemoteDataSource = userRemoteDataSource;

  @override
  Future<BlacklistResultEntity> getBlacklist({
    required int pn,
    required int ps,
  }) async {
    final result = await _remoteDataSource.fetchBlacklist(
      pn: pn,
      ps: ps,
    );

    return _mapBlacklistResult(result, pn, ps);
  }

  @override
  Future<bool> removeFromBlacklist({
    required int mid,
  }) async {
    await _userRemoteDataSource.relationMod(
      mid: mid,
      act: 6, // 6 表示移除黑名单
      reSrc: 11,
    );

    return true;
  }

  /// 将API响应映射为领域实体
  BlacklistResultEntity _mapBlacklistResult(
    LoadingState<BlackListData> result,
    int pn,
    int ps,
  ) {
    if (result case Success(:final response)) {
      final items = response.list
              ?.map(BlacklistItemEntity.fromModel)
              .toList() ??
          [];

      final total = response.total ?? 0;
      final hasMore = items.length >= ps && items.length < total;

      return BlacklistResultEntity(
        items: items,
        total: total,
        hasMore: hasMore,
        currentPage: pn,
      );
    } else if (result case Error(:final errMsg)) {
      throw Exception(errMsg);
    } else {
      throw Exception('加载中...');
    }
  }
}
