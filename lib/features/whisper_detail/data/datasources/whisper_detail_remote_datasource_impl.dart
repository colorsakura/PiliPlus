import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/grpc/bilibili/im/interfaces/v1.pb.dart' show RspSessionMsg;
import 'package:PiliPlus/features/whisper_detail/data/datasources/whisper_detail_remote_datasource.dart';
import 'package:PiliPlus/features/whisper_detail/domain/entities/whisper_message_params.dart';
import 'package:PiliPlus/grpc/im.dart' as grpc;
import 'package:PiliPlus/http/msg.dart' as http;
import 'package:fixnum/fixnum.dart' show Int64;

/// Implementation of whisper detail remote data source
class WhisperDetailRemoteDataSourceImpl implements WhisperDetailRemoteDataSource {
  const WhisperDetailRemoteDataSourceImpl();

  @override
  Future<LoadingState<RspSessionMsg>> fetchSessionMessages(FetchSessionMessagesParams params) {
    return grpc.ImGrpc.syncFetchSessionMsgs(
      talkerId: params.talkerId,
      beginSeqno: params.msgSeqno != null ? Int64.ZERO : null,
      endSeqno: params.msgSeqno != null ? Int64(params.msgSeqno!) : null,
    );
  }

  @override
  Future<LoadingState<Map<String, dynamic>?>> sendMessage(SendMessageParams params) async {
    final res = await grpc.ImGrpc.sendMsg(
      senderUid: params.senderUid,
      receiverId: params.receiverId,
      content: params.content,
      msgType: params.msgType,
    );
    // Convert RspSendMsg result
    if (res case Success(:final response)) {
      // Try to get the message data from response
      try {
        final json = response?.toProto3Json() as Map<String, dynamic>?;
        return Success(json);
      } catch (_) {
        // Return empty map if conversion fails
        return Success(<String, dynamic>{});
      }
    }
    return Error((res as Error).errMsg ?? 'Send failed');
  }

  @override
  Future<LoadingState<void>> ackSessionMessage(AckSessionMsgParams params) {
    return http.MsgHttp.ackSessionMsg(
      talkerId: params.talkerId,
      ackSeqno: params.ackSeqno,
    );
  }
}
