import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/home_zone/domain/entities/rank_params.dart';
import 'package:PiliPlus/features/home_zone/domain/repositories/rank_repository.dart';

/// Use case for fetching rank video list
class FetchRank {
  final RankRepository repository;

  const FetchRank(this.repository);

  Future<LoadingState> call(FetchRankParams params) =>
      repository.fetchRank(params);
}
