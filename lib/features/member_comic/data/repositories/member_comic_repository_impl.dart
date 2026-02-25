import 'package:PiliPlus/features/member_comic/domain/entities/member_comic_item_entity.dart';
import 'package:PiliPlus/features/member_comic/domain/repositories/member_comic_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/member/contribute_type.dart';

/// Implementation of member comic repository
class MemberComicRepositoryImpl implements MemberComicRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberComicRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberComicItemEntity>>> fetchMemberComics({
    required int mid,
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.spaceArchive(
        type: ContributeType.comic,
        mid: mid,
      );
      final items = data.item ?? [];
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
