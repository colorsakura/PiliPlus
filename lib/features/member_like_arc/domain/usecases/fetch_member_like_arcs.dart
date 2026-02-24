import 'package:PiliPlus/features/member_like_arc/domain/entities/member_like_arc_item_entity.dart';
import 'package:PiliPlus/features/member_like_arc/domain/repositories/member_like_arc_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member like arcs
class FetchMemberLikeArcsUseCase {
  const FetchMemberLikeArcsUseCase(this._repository);

  final MemberLikeArcRepository _repository;

  Future<LoadingState<List<MemberLikeArcItemEntity>>> call({
    required dynamic mid,
    required int page,
  }) {
    return _repository.fetchMemberLikeArcs(mid: mid, page: page);
  }
}
