import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart' show PlayURLResp, DetailItem;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';

/// Repository interface for audio operations
abstract class AudioRepository {
  /// Fetch audio play URL
  Future<LoadingState<PlayURLResp>> fetchPlayUrl(FetchAudioPlayUrlParams params);

  /// Fetch audio playlist
  Future<LoadingState<List<DetailItem>?>> fetchPlaylist(FetchAudioPlaylistParams params);

  /// Thumb up audio
  Future<LoadingState<Null>> thumbUp(ThumbUpAudioParams params);

  /// Triple like audio (like, fav, coin)
  Future<LoadingState<dynamic>> tripleLike(TripleLikeAudioParams params);

  /// Add coin to audio
  Future<LoadingState<Map<String, dynamic>?>> addCoin(CoinAudioParams params);
}
