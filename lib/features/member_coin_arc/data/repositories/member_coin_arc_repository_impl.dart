import 'package:PiliPlus/features/member_coin_arc/domain/entities/member_coin_arc_item_entity.dart';
import 'package:PiliPlus/features/member_coin_arc/domain/repositories/member_coin_arc_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of member coin arc repository
class MemberCoinArcRepositoryImpl implements MemberCoinArcRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberCoinArcRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberCoinArcItemEntity>>> fetchMemberCoinArcs({
    required dynamic mid,
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.coinArc(mid: mid, pn: page);
      final items = data.item ?? [];
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
