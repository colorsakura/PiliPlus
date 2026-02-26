import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart'
    show PlayURLResp, DetailItem, ThumbUpResp, CoinAddResp;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';

/// Data source interface for audio operations
abstract class AudioRemoteDataSource {
  /// Fetch audio play URL via gRPC
  Future<LoadingState<PlayURLResp>> fetchPlayUrl(FetchAudioPlayUrlParams params);

  /// Fetch audio playlist via gRPC
  Future<LoadingState<List<DetailItem>?>> fetchPlaylist(FetchAudioPlaylistParams params);

  /// Thumb up audio via gRPC
  Future<LoadingState<ThumbUpResp>> thumbUp(ThumbUpAudioParams params);

  /// Triple like audio via gRPC
  Future<LoadingState<dynamic>> tripleLike(TripleLikeAudioParams params);

  /// Add coin to audio via gRPC
  Future<LoadingState<CoinAddResp>> addCoin(CoinAudioParams params);
}
