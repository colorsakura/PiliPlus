import 'package:PiliPlus/features/member_upower_rank/domain/entities/member_upower_rank_item_entity.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/repositories/member_upower_rank_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member upower rank
class FetchMemberUpowerRankUseCase {
  const FetchMemberUpowerRankUseCase(this._repository);

  final MemberUpowerRankRepository _repository;

  Future<LoadingState<List<MemberUpowerRankItemEntity>>> call({
    required String upMid,
    required int page,
    int? privilegeType,
  }) {
    return _repository.fetchMemberUpowerRank(
      upMid: upMid,
      page: page,
      privilegeType: privilegeType,
    );
  }
}
