import 'package:PiliPlus/features/member_audio/domain/entities/member_audio_item_entity.dart';
import 'package:PiliPlus/features/member_audio/domain/repositories/member_audio_repository.dart';
import 'package:PiliPlus/features/member/data/datasources/member_api_datasource.dart';
import 'package:PiliPlus/http/loading_state.dart';

/// Implementation of member audio repository
class MemberAudioRepositoryImpl implements MemberAudioRepository {
  final MemberRemoteDataSource _remoteDataSource;

  MemberAudioRepositoryImpl({
    required MemberRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<LoadingState<List<MemberAudioItemEntity>>> fetchMemberAudios({
    required int mid,
    required int page,
  }) async {
    try {
      final data = await _remoteDataSource.spaceAudio(mid: mid, page: page);
      final items = data.items ?? [];
      return Success(items);
    } catch (e) {
      return Error(e.toString());
    }
  }
}
