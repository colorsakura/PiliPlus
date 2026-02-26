import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/match/domain/entities/match_contest_entity.dart';

/// Match repository interface
abstract class MatchRepository {
  /// Get match contest info by ID
  Future<LoadingState<MatchContestEntity>> getMatchInfo({
    required Object cid,
    int platform = 2,
  });
}
