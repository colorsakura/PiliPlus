import 'package:PiliPlus/features/shell/data/datasources/dynamic_remote_datasource.dart';
import 'package:PiliPlus/features/shell/domain/entities/unread_dynamic.dart';
import 'package:PiliPlus/features/shell/domain/repositories/dynamic_repository.dart';

/// 动态仓库实现
class DynamicRepositoryImpl implements DynamicRepository {
  final DynamicRemoteDataSource _remoteDataSource;

  DynamicRepositoryImpl({
    required DynamicRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<UnreadDynamic> getUnreadDynamic() async {
    final count = await _remoteDataSource.getDynRed();
    return UnreadDynamic(count: count ?? 0);
  }

  @override
  Future<bool> shouldCheckUnread(int lastCheckTime, int period) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - lastCheckTime) >= period;
  }
}
