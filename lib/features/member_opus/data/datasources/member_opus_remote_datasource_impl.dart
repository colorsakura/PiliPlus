import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_opus/data.dart';
import 'package:PiliPlus/features/member_opus/data/datasources/member_opus_remote_datasource.dart';
import 'package:PiliPlus/features/member_opus/domain/entities/member_opus_params.dart';

/// Implementation of member opus remote data source using MemberHttp
class MemberOpusRemoteDataSourceImpl implements MemberOpusRemoteDataSource {
  const MemberOpusRemoteDataSourceImpl();

  @override
  Future<LoadingState<SpaceOpusData>> fetchMemberOpus(FetchMemberOpusParams params) {
    return MemberHttp.spaceOpus(
      hostMid: params.hostMid,
      page: params.page,
      offset: params.offset,
      type: params.type,
    );
  }
}
