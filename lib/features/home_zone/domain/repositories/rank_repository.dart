import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/home_zone/domain/entities/rank_params.dart';

/// Repository interface for rank video operations
abstract class RankRepository {
  /// Fetch rank video list
  Future<LoadingState> fetchRank(FetchRankParams params);
}
