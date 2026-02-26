import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/home_zone/data/datasources/rank_remote_datasource.dart';
import 'package:PiliPlus/features/home_zone/domain/entities/rank_params.dart';
import 'package:PiliPlus/features/home_zone/domain/repositories/rank_repository.dart';

/// Implementation of rank repository
class RankRepositoryImpl implements RankRepository {
  final RankRemoteDataSource remoteDataSource;

  const RankRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState> fetchRank(FetchRankParams params) {
    return remoteDataSource.fetchRank(params);
  }
}
