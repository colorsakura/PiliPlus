import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_archive/data.dart';
import 'package:PiliPlus/features/member_video/data/datasources/member_video_remote_datasource.dart';
import 'package:PiliPlus/features/member_video/domain/entities/member_video_params.dart';

/// Implementation of member video remote data source
class MemberVideoRemoteDataSourceImpl implements MemberVideoRemoteDataSource {
  const MemberVideoRemoteDataSourceImpl();

  @override
  Future<LoadingState<SpaceArchiveData>> fetchMemberArchive(FetchMemberArchiveParams params) {
    return MemberHttp.spaceArchive(
      type: params.type,
      mid: params.mid,
      aid: params.aid,
      order: params.order,
      sort: params.sort,
      pn: params.page,
      next: params.next,
      seasonId: params.seasonId,
      seriesId: params.seriesId,
      includeCursor: params.includeCursor,
    );
  }

  @override
  Future<String?> searchVideoCid(String aid, String bvid) async {
    final cid = await SearchHttp.ab2c(aid: aid, bvid: bvid);
    return cid?.toString();
  }
}
