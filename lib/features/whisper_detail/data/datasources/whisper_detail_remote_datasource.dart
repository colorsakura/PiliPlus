import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/im/interfaces/v1.pb.dart' show RspSessionMsg;
import 'package:PiliPlus/features/whisper_detail/domain/entities/whisper_message_params.dart';

/// Data source interface for whisper detail operations
abstract class WhisperDetailRemoteDataSource {
  /// Fetch session messages via gRPC API
  Future<LoadingState<RspSessionMsg>> fetchSessionMessages(FetchSessionMessagesParams params);

  /// Send a whisper message via gRPC API
  Future<LoadingState<Map<String, dynamic>?>> sendMessage(SendMessageParams params);

  /// Acknowledge session messages as read via HTTP API
  Future<LoadingState<void>> ackSessionMessage(AckSessionMsgParams params);
}
