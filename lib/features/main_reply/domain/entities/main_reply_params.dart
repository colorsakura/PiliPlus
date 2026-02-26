import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart' show Mode;
import 'package:fixnum/fixnum.dart' show Int64;

/// Parameters for fetching main reply list
class FetchMainRepliesParams {
  final int oid; // Object ID (video/article ID)
  final int replyType; // Reply type (video=1, article=12, etc.)
  final Mode mode; // Mode (2=hot, 3=time)
  final Int64? cursorNext; // Pagination cursor
  final Map<String, dynamic>? paginationReply; // Pagination info with nextOffset

  const FetchMainRepliesParams({
    required this.oid,
    required this.replyType,
    this.mode = Mode.MAIN_LIST_TIME,
    this.cursorNext,
    this.paginationReply,
  });
}
