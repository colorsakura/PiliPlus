import 'package:PiliPlus/features/member_shop/domain/entities/member_shop_item_entity.dart';
import 'package:PiliPlus/features/member_shop/domain/repositories/member_shop_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of member shop repository
class MemberShopRepositoryImpl implements MemberShopRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberShopRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberShopItemEntity>>> fetchMemberShopItems({
    required int mid,
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.spaceShop(mid: mid, pn: page);
      final items = data.data ?? [];
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
