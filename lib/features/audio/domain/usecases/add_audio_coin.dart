import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/audio/domain/entities/audio_params.dart';
import 'package:PiliPlus/features/audio/domain/repositories/audio_repository.dart';

/// Use case for adding coin to audio
class AddAudioCoin {
  final AudioRepository repository;

  const AddAudioCoin(this.repository);

  Future<LoadingState<Map<String, dynamic>?>> call(CoinAudioParams params) =>
      repository.addCoin(params);
}
