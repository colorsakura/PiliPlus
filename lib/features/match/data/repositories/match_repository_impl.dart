import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/features/match/data/datasources/match_remote_datasource.dart';
import 'package:PiliPlus/features/match/domain/entities/match_contest_entity.dart';
import 'package:PiliPlus/features/match/domain/repositories/match_repository.dart';

/// Match repository implementation
class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDataSource remoteDataSource;

  const MatchRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<MatchContestEntity>> getMatchInfo({
    required Object cid,
    int platform = 2,
  }) async {
    try {
      final contestModel = await remoteDataSource.matchInfo(
        cid,
        platform: platform,
      );

      if (contestModel != null) {
        final entity = MatchContestEntity.fromModel(contestModel);
        return Success(entity);
      } else {
        return const Error('未找到赛事信息');
      }
    } on ServerException catch (e) {
      return Error(e.message ?? '获取赛事信息失败');
    } on Exception catch (e) {
      return Error(e.toString());
    }
  }
}
