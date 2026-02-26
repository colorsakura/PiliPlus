import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/whisper_detail/domain/repositories/whisper_detail_repository.dart';
import 'package:PiliPlus/features/whisper_detail/domain/entities/whisper_message_params.dart';

/// Use case for acknowledging session messages as read
class AckSessionMessage {
  final WhisperDetailRepository repository;

  const AckSessionMessage(this.repository);

  /// Execute the ack operation
  ///
  /// [params] contains talkerId and ackSeqno
  ///
  /// Returns [Success] if ack succeeded, [Error] otherwise
  Future<LoadingState<void>> call(AckSessionMsgParams params) {
    return repository.ackSessionMessage(params);
  }
}
