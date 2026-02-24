import 'package:PiliPlus/features/member_shop/domain/entities/member_shop_item_entity.dart';
import 'package:PiliPlus/features/member_shop/domain/repositories/member_shop_repository.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/space/space_shop/data.dart';

/// Implementation of member shop repository
class MemberShopRepositoryImpl implements MemberShopRepository {
  const MemberShopRepositoryImpl();

  @override
  Future<LoadingState<List<MemberShopItemEntity>>> fetchMemberShopItems({
    required int mid,
    required int page,
  }) async {
    final result = await MemberHttp.spaceShop(mid: mid);

    return result.when(
      loading: LoadingState.loading,
      success: (data) {
        final items = data.data ?? [];
        return Success(items);
      },
      error: (errMsg, {code}) => Error(errMsg, code: code),
    );
  }
}
