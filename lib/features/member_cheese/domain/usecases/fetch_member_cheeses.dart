import 'package:PiliPlus/features/member_cheese/domain/entities/member_cheese_item_entity.dart';
import 'package:PiliPlus/features/member_cheese/domain/repositories/member_cheese_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member cheeses
class FetchMemberCheesesUseCase {
  const FetchMemberCheesesUseCase(this._repository);

  final MemberCheeseRepository _repository;

  Future<LoadingState<List<MemberCheeseItemEntity>>> call({
    required int mid,
    required int page,
  }) {
    return _repository.fetchMemberCheeses(mid: mid, page: page);
  }
}
