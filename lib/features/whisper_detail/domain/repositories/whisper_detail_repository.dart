import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/im/interfaces/v1.pb.dart' show RspSessionMsg;
import 'package:PiliPlus/features/whisper_detail/domain/entities/whisper_message_params.dart';

/// Repository interface for whisper detail operations
abstract class WhisperDetailRepository {
  /// Fetch session messages
  ///
  /// [params] contains talkerId and optional msgSeqno for pagination
  ///
  /// Returns [Success] with session messages, or [Error] if failed
  Future<LoadingState<RspSessionMsg>> fetchSessionMessages(FetchSessionMessagesParams params);

  /// Send a whisper message
  ///
  /// [params] contains senderUid, receiverId, content, and msgType
  ///
  /// Returns [Success] with sent message data, or [Error] if failed
  Future<LoadingState<Map<String, dynamic>?>> sendMessage(SendMessageParams params);

  /// Acknowledge session messages as read
  ///
  /// [params] contains talkerId and ackSeqno
  ///
  /// Returns [Success] if ack succeeded, [Error] otherwise
  Future<LoadingState<void>> ackSessionMessage(AckSessionMsgParams params);
}
