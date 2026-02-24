import 'package:PiliPlus/features/member_coin_arc/domain/entities/member_coin_arc_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for fetching member coin archives
abstract class MemberCoinArcRepository {
  /// Fetch coin archives for a member
  ///
  /// [mid] - Member ID
  /// [page] - Page number (1-indexed)
  Future<LoadingState<List<MemberCoinArcItemEntity>>> fetchMemberCoinArcs({
    required dynamic mid,
    required int page,
  });
}
