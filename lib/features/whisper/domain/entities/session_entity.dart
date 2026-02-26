import 'package:PiliPlus/grpc/bilibili/app/im/v1.pb.dart';

/// Entity representing a message session (simplified wrapper)
class SessionEntity {
  /// Original session data
  final Session session;

  const SessionEntity({
    required this.session,
  });

  /// Get session ID
  String get sessionId => session.id.toString();

  /// Get unread count (simplified)
  int get unreadCount {
    try {
      final unread = session.unread;
      // Access the field directly - protobuf generated code uses field numbers
      return unread.getField(3) as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Get timestamp
  int get timestamp => session.timestamp.toInt();

  /// Check if session is pinned
  bool get isPinned => session.isPinned;

  @override
  String toString() => 'SessionEntity(sessionId: $sessionId, unreadCount: $unreadCount)';
}

/// Entity representing session list result
class SessionListResult {
  /// List of sessions
  final List<SessionEntity> sessions;

  /// Whether there are more sessions to load
  final bool hasMore;

  /// Pagination offset for next page
  final Map<int, dynamic>? offset;

  const SessionListResult({
    required this.sessions,
    required this.hasMore,
    this.offset,
  });
}

/// Entity representing unread message counts
class UnreadCountsEntity {
  /// Reply messages count
  final int reply;

  /// @mention messages count
  final int at;

  /// Like messages count
  final int like;

  /// System messages count
  final int sysMsg;

  const UnreadCountsEntity({
    required this.reply,
    required this.at,
    required this.like,
    required this.sysMsg,
  });

  /// Get unread counts as a list
  List<int> toList() => [reply, at, like, sysMsg];

  @override
  String toString() =>
      'UnreadCountsEntity(reply: $reply, at: $at, like: $like, sysMsg: $sysMsg)';
}
