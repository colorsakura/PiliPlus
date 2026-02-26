import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper_detail/domain/repositories/whisper_detail_repository.dart';
import 'package:PiliPlus/features/whisper_detail/domain/entities/whisper_message_params.dart';

/// Use case for sending a whisper message
class SendMessage {
  final WhisperDetailRepository repository;

  const SendMessage(this.repository);

  /// Execute the send operation
  ///
  /// [params] contains all necessary parameters
  ///
  /// Returns [Success] with sent message data, or [Error] if failed
  Future<LoadingState<Map<String, dynamic>?>> call(SendMessageParams params) {
    return repository.sendMessage(params);
  }
}
