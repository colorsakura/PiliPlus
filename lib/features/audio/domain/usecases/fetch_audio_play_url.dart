import 'package:PiliPlus/grpc/bilibili/app/listener/v1.pb.dart' show PlayURLResp;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';
import 'package:PiliPlus/features/audio/domain/repositories/audio_repository.dart';

/// Use case for fetching audio play URL
class FetchAudioPlayUrl {
  final AudioRepository repository;

  const FetchAudioPlayUrl(this.repository);

  Future<LoadingState<PlayURLResp>> call(FetchAudioPlayUrlParams params) =>
      repository.fetchPlayUrl(params);
}
