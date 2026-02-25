import 'package:PiliPlus/features/member_like_arc/domain/entities/member_like_arc_item_entity.dart';
import 'package:PiliPlus/features/member_like_arc/domain/repositories/member_like_arc_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of member like arc repository
class MemberLikeArcRepositoryImpl implements MemberLikeArcRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberLikeArcRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberLikeArcItemEntity>>> fetchMemberLikeArcs({
    required dynamic mid,
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.likeArc(mid: mid, pn: page);
      final items = data.item ?? [];
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
