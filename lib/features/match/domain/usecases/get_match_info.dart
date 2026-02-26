import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/match/domain/entities/match_contest_entity.dart';
import 'package:PiliPlus/features/match/domain/repositories/match_repository.dart';

/// Get match info use case
class GetMatchInfo {
  final MatchRepository repository;

  const GetMatchInfo(this.repository);

  Future<LoadingState<MatchContestEntity>> call({
    required Object cid,
    int platform = 2,
  }) {
    return repository.getMatchInfo(
      cid: cid,
      platform: platform,
    );
  }
}
