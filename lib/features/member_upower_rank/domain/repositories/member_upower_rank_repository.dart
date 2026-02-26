import 'package:PiliPlus/features/member_upower_rank/domain/entities/member_upower_rank_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for member upower rank data
abstract class MemberUpowerRankRepository {
  Future<LoadingState<List<MemberUpowerRankItemEntity>>> fetchMemberUpowerRank({
    required String upMid,
    required int page,
    int? privilegeType,
  });
}
