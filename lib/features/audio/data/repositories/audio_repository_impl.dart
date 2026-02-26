import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart' show PlayURLResp, DetailItem, ThumbUpResp, CoinAddResp;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/data/datasources/audio_remote_datasource.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';
import 'package:PiliPlus/features/audio/domain/repositories/audio_repository.dart';

/// Implementation of audio repository
class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource remoteDataSource;

  const AudioRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<LoadingState<PlayURLResp>> fetchPlayUrl(FetchAudioPlayUrlParams params) {
    return remoteDataSource.fetchPlayUrl(params);
  }

  @override
  Future<LoadingState<List<DetailItem>?>> fetchPlaylist(FetchAudioPlaylistParams params) {
    return remoteDataSource.fetchPlaylist(params);
  }

  @override
  Future<LoadingState<Null>> thumbUp(ThumbUpAudioParams params) async {
    final res = await remoteDataSource.thumbUp(params);
    // Convert ThumbUpResp to Null (just for success check)
    if (res case Success()) {
      return const Success(null);
    }
    return Error(res is Error ? (res as Error).errMsg ?? 'Thumb up failed' : 'Unknown error');
  }

  @override
  Future<LoadingState<dynamic>> tripleLike(TripleLikeAudioParams params) {
    return remoteDataSource.tripleLike(params);
  }

  @override
  Future<LoadingState<Map<String, dynamic>?>> addCoin(CoinAudioParams params) async {
    final res = await remoteDataSource.addCoin(params);
    // Convert CoinAddResp to Map
    if (res case Success(:final response)) {
      try {
        final json = response?.toProto3Json() as Map<String, dynamic>?;
        return Success(json);
      } catch (_) {
        return Success(<String, dynamic>{});
      }
    }
    return Error(res is Error ? (res as Error).errMsg ?? 'Add coin failed' : 'Unknown error');
  }
}
