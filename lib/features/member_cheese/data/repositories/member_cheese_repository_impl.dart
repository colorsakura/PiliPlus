import 'package:PiliPlus/features/member_cheese/domain/entities/member_cheese_item_entity.dart';
import 'package:PiliPlus/features/member_cheese/domain/repositories/member_cheese_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of member cheese repository
class MemberCheeseRepositoryImpl implements MemberCheeseRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberCheeseRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberCheeseItemEntity>>> fetchMemberCheeses({
    required int mid,
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.spaceCheese(
        page: page,
        mid: mid,
      );
      final items = data.items ?? [];
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
