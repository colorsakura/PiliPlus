import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space/space_opus/data.dart';
import 'package:PiliPlus/features/member_opus/data/datasources/member_opus_remote_datasource.dart';
import 'package:PiliPlus/features/member_opus/domain/entities/member_opus_params.dart';
import 'package:PiliPlus/features/member_opus/domain/repositories/member_opus_repository.dart';

/// Implementation of member opus repository
class MemberOpusRepositoryImpl implements MemberOpusRepository {
  final MemberOpusRemoteDataSource remoteDataSource;

  const MemberOpusRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<SpaceOpusData>> fetchMemberOpus(FetchMemberOpusParams params) {
    return remoteDataSource.fetchMemberOpus(params);
  }
}
