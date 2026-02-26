import 'package:PiliPlus/features/emote/data/datasources/emote_remote_datasource.dart';
import 'package:PiliPlus/features/emote/domain/repositories/emote_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/emote/package.dart';

/// 表情仓库实现
///
/// 实现表情仓库接口,使用远程数据源获取数据
class EmoteRepositoryImpl implements EmoteRepository {
  final EmoteRemoteDataSource _remoteDataSource;

  EmoteRepositoryImpl({
    required EmoteRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<Package>?>> getEmotePackages({
    required String business,
  }) {
    return _remoteDataSource.getEmotePackages(business: business);
  }
}
