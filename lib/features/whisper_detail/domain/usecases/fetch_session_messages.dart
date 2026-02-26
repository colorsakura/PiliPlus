import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/im/interfaces/v1.pb.dart' show RspSessionMsg;
import 'package:PiliPlus/features/whisper_detail/domain/repositories/whisper_detail_repository.dart';
import 'package:PiliPlus/features/whisper_detail/domain/entities/whisper_message_params.dart';

/// Use case for fetching whisper session messages
class FetchSessionMessages {
  final WhisperDetailRepository repository;

  const FetchSessionMessages(this.repository);

  /// Execute the fetch operation
  ///
  /// [params] contains talkerId and optional msgSeqno
  ///
  /// Returns [Success] with session messages, or [Error] if failed
  Future<LoadingState<RspSessionMsg>> call(FetchSessionMessagesParams params) {
    return repository.fetchSessionMessages(params);
  }
}
