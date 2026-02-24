import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper_block/domain/entities/whisper_block_entity.dart';

/// Whisper block state
class WhisperBlockState {
  final LoadingState<WhisperBlockEntity> data;

  const WhisperBlockState({
    required this.data,
  });

  WhisperBlockState copyWith({
    LoadingState<WhisperBlockEntity>? data,
  }) {
    return WhisperBlockState(
      data: data ?? this.data,
    );
  }
}
