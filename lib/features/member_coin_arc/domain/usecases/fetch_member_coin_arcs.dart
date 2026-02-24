import 'package:PiliPlus/features/member_coin_arc/domain/entities/member_coin_arc_item_entity.dart';
import 'package:PiliPlus/features/member_coin_arc/domain/repositories/member_coin_arc_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member coin archives
class FetchMemberCoinArcsUseCase {
  const FetchMemberCoinArcsUseCase(this._repository);

  final MemberCoinArcRepository _repository;

  /// Execute the use case
  Future<LoadingState<List<MemberCoinArcItemEntity>>> call({
    required dynamic mid,
    required int page,
  }) {
    return _repository.fetchMemberCoinArcs(mid: mid, page: page);
  }
}
