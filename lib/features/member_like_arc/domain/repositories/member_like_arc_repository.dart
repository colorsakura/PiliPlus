import 'package:PiliPlus/features/member_like_arc/domain/entities/member_like_arc_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for member like arc data
abstract class MemberLikeArcRepository {
  Future<LoadingState<List<MemberLikeArcItemEntity>>> fetchMemberLikeArcs({
    required dynamic mid,
    required int page,
  });
}
