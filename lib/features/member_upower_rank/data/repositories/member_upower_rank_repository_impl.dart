import 'package:PiliPlus/features/member_upower_rank/domain/entities/member_upower_rank_item_entity.dart';
import 'package:PiliPlus/features/member_upower_rank/domain/repositories/member_upower_rank_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of member upower rank repository
class MemberUpowerRankRepositoryImpl implements MemberUpowerRankRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberUpowerRankRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberUpowerRankItemEntity>>> fetchMemberUpowerRank({
    required String upMid,
    required int page,
    int? privilegeType,
  }) async {
    try {
      final data = await _remoteDataSource.upowerRank(
        upMid: upMid,
        page: page,
        privilegeType: privilegeType,
      );
      final items = data.rankInfo ?? [];
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
