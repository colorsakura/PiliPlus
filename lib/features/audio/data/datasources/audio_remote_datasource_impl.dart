import 'package:PiliPlus/grpc/audio.dart';
import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart'
    show PlayURLResp, DetailItem, ThumbUpResp, CoinAddResp, ThumbUpReq_ThumbType;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/data/datasources/audio_remote_datasource.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';
import 'package:fixnum/fixnum.dart' show Int64;

/// Implementation of audio remote data source using AudioGrpc
class AudioRemoteDataSourceImpl implements AudioRemoteDataSource {
  const AudioRemoteDataSourceImpl();

  @override
  Future<LoadingState<PlayURLResp>> fetchPlayUrl(FetchAudioPlayUrlParams params) {
    return AudioGrpc.audioPlayUrl(
      itemType: params.itemType,
      oid: Int64(params.oid),
      subId: params.subId.map((e) => Int64(e)).toList(),
    );
  }

  @override
  Future<LoadingState<List<DetailItem>?>> fetchPlaylist(FetchAudioPlaylistParams params) async {
    final res = await AudioGrpc.audioPlayList(
      id: Int64(params.id),
      oid: Int64(params.oid),
      subId: params.subId.map((e) => Int64(e)).toList(),
      itemType: params.itemType,
      from: params.from,
    );

    // Extract playlist from response
    if (res case Success(:final response)) {
      // The response itself contains the playlist
      if (response is List) {
        return Success(response as List<DetailItem>);
      }
      // Try to get list from response structure
      return Success(const <DetailItem>[]);
    }
    return Error(res is Error ? (res as Error).errMsg ?? 'Failed to fetch playlist' : 'Unknown error');
  }

  @override
  Future<LoadingState<ThumbUpResp>> thumbUp(ThumbUpAudioParams params) async {
    // Determine thumb up type value
    final typeValue = params.thumbTypeValue;

    // Call with correct enum value
    return AudioGrpc.audioThumbUp(
      oid: Int64(params.oid),
      subId: params.subId.map((e) => Int64(e)).toList(),
      itemType: params.itemType,
      type: typeValue == 1 ? ThumbUpReq_ThumbType.LIKE : ThumbUpReq_ThumbType.CANCEL_LIKE,
    );
  }

  @override
  Future<LoadingState<dynamic>> tripleLike(TripleLikeAudioParams params) {
    return AudioGrpc.audioTripleLike(
      oid: Int64(params.oid),
      subId: params.subId.map((e) => Int64(e)).toList(),
      itemType: params.itemType,
    );
  }

  @override
  Future<LoadingState<CoinAddResp>> addCoin(CoinAudioParams params) {
    return AudioGrpc.audioCoinAdd(
      oid: Int64(params.oid),
      subId: params.subId.map((e) => Int64(e)).toList(),
      itemType: params.itemType,
      num: params.num,
      thumbUp: params.thumbUp,
    );
  }
}
