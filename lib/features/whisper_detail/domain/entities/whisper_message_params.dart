import 'package:PiliPlus/grpc/bilibili/im/type.pb.dart' show MsgType;

/// Parameters for fetching whisper session messages
class FetchSessionMessagesParams {
  /// Talker ID (the other user's ID)
  final int talkerId;

  /// Message sequence number for pagination
  final int? msgSeqno;

  const FetchSessionMessagesParams({
    required this.talkerId,
    this.msgSeqno,
  });

  @override
  String toString() => 'FetchSessionMessagesParams(talkerId: $talkerId, msgSeqno: $msgSeqno)';
}

/// Parameters for sending a whisper message
class SendMessageParams {
  /// Sender's user ID
  final int senderUid;

  /// Receiver's user ID
  final int receiverId;

  /// Message content (text or JSON-encoded picture message)
  final String content;

  /// Message type
  final MsgType msgType;

  /// Message index (for recall operations)
  final int? index;

  const SendMessageParams({
    required this.senderUid,
    required this.receiverId,
    required this.content,
    required this.msgType,
    this.index,
  });

  /// Check if this is a picture message (type index 2)
  bool get isPicture => msgType.value == 2;

  /// Check if this is a text message (type index 1)
  bool get isText => msgType.value == 1;

  /// Check if this is a recall operation (type index 5)
  bool get isRecall => msgType.value == 5;

  @override
  String toString() => 'SendMessageParams(receiverId: $receiverId, msgType: $msgType)';
}

/// Parameters for acknowledging session messages as read
class AckSessionMsgParams {
  /// Talker ID (the other user's ID)
  final int talkerId;

  /// Acknowledgment sequence number
  final int ackSeqno;

  const AckSessionMsgParams({
    required this.talkerId,
    required this.ackSeqno,
  });

  @override
  String toString() => 'AckSessionMsgParams(talkerId: $talkerId, ackSeqno: $ackSeqno)';
}

/// Entity representing a sent message result
class SendMessageResult {
  /// Whether the send was successful
  final bool isSuccess;

  /// Error message if send failed
  final String? errorMessage;

  /// New message data (if successful)
  final Map<String, dynamic>? messageData;

  const SendMessageResult({
    required this.isSuccess,
    this.errorMessage,
    this.messageData,
  });

  /// Create a success result
  factory SendMessageResult.success([Map<String, dynamic>? messageData]) {
    return SendMessageResult(
      isSuccess: true,
      messageData: messageData,
    );
  }

  /// Create an error result
  factory SendMessageResult.error(String errorMessage) {
    return SendMessageResult(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}

