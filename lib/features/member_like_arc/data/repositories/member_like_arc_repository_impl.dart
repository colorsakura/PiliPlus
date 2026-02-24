import 'package:PiliPlus/features/member_like_arc/domain/entities/member_like_arc_item_entity.dart';
import 'package:PiliPlus/features/member_like_arc/domain/repositories/member_like_arc_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/member/coin_like_arc/data.dart';

/// Implementation of member like arc repository
class MemberLikeArcRepositoryImpl implements MemberLikeArcRepository {
  const MemberLikeArcRepositoryImpl();

  @override
  Future<LoadingState<List<MemberLikeArcItemEntity>>> fetchMemberLikeArcs({
    required dynamic mid,
    required int page,
  }) async {
    final result = await MemberHttp.likeArc(mid: mid, page: page);

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.item ?? [];
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}
