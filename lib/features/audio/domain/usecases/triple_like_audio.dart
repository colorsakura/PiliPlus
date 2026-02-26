import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';
import 'package:PiliPlus/features/audio/domain/repositories/audio_repository.dart';

/// Use case for triple like audio
class TripleLikeAudio {
  final AudioRepository repository;

  const TripleLikeAudio(this.repository);

  Future<LoadingState<dynamic>> call(TripleLikeAudioParams params) =>
      repository.tripleLike(params);
}
