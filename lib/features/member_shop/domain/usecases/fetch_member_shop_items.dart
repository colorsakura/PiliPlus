import 'package:PiliPlus/features/member_shop/domain/entities/member_shop_item_entity.dart';
import 'package:PiliPlus/features/member_shop/domain/repositories/member_shop_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Use case for fetching member shop items
class FetchMemberShopItemsUseCase {
  const FetchMemberShopItemsUseCase(this._repository);

  final MemberShopRepository _repository;

  Future<LoadingState<List<MemberShopItemEntity>>> call({
    required int mid,
    required int page,
  }) {
    return _repository.fetchMemberShopItems(mid: mid, page: page);
  }
}
