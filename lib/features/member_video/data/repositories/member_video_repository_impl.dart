import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';
import 'package:PiliPlus/features/member_video/data/datasources/member_video_remote_datasource.dart';
import 'package:PiliPlus/features/member_video/domain/entities/member_video_params.dart';
import 'package:PiliPlus/features/member_video/domain/repositories/member_video_repository.dart';

/// Implementation of member video repository
class MemberVideoRepositoryImpl implements MemberVideoRepository {
  final MemberVideoRemoteDataSource remoteDataSource;

  const MemberVideoRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<SpaceArchiveData>> fetchMemberArchive(FetchMemberArchiveParams params) {
    return remoteDataSource.fetchMemberArchive(params);
  }

  @override
  Future<String?> searchVideoCid(String aid, String bvid) {
    return remoteDataSource.searchVideoCid(aid, bvid);
  }
}
