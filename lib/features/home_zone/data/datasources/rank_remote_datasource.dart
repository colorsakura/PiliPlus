import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/home_zone/domain/entities/rank_params.dart';

/// Data source interface for rank video operations
abstract class RankRemoteDataSource {
  /// Fetch rank video list via API
  Future<LoadingState> fetchRank(FetchRankParams params);
}
