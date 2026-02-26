import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';
import 'package:PiliPlus/features/audio/domain/repositories/audio_repository.dart';

/// Use case for thumbing up audio
class ThumbUpAudio {
  final AudioRepository repository;

  const ThumbUpAudio(this.repository);

  Future<LoadingState<Null>> call(ThumbUpAudioParams params) =>
      repository.thumbUp(params);
}
