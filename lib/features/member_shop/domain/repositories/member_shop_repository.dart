import 'package:PiliPlus/features/member_shop/domain/entities/member_shop_item_entity.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Repository interface for member shop data
abstract class MemberShopRepository {
  Future<LoadingState<List<MemberShopItemEntity>>> fetchMemberShopItems({
    required int mid,
    required int page,
  });
}
