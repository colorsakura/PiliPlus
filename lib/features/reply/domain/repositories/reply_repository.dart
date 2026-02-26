import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/reply/data.dart';
import 'package:PiliPlus/models/reply2reply/data.dart';
import 'package:PiliPlus/models/emote/package.dart';
import 'package:PiliPlus/models/reply_interaction/data.dart';

/// Reply repository interface
abstract class ReplyRepository {
  /// Get reply list
  Future<LoadingState<ReplyData>> getReplyList({
    required bool isLogin,
    required int oid,
    required String nextOffset,
    required int type,
    required int page,
    int sort = 1,
  });

  /// Get reply to reply list (second level replies)
  Future<LoadingState<ReplyReplyData>> getReplyReplyList({
    required bool isLogin,
    required int oid,
    required int root,
    required int pageNum,
    required int type,
    bool isCheck = false,
  });

  /// Like or unlike a reply
  Future<LoadingState<Null>> likeReply({
    required int type,
    required int oid,
    required int rpid,
    required int action,
  });

  /// Hate or unhate a reply
  Future<LoadingState<Null>> hateReply({
    required int type,
    required int action,
    required int oid,
    required int rpid,
  });

  /// Get emote list for replies
  Future<LoadingState<List<Package>?>> getEmoteList({
    String? business,
  });

  /// Set or cancel reply top
  Future<LoadingState<Null>> replyTop({
    required Object oid,
    required Object type,
    required Object rpid,
    required bool isUpTop,
  });

  /// Report a reply
  Future<LoadingState<Null>> reportReply({
    required Object rpid,
    required Object oid,
    required int reasonType,
    bool banUid = true,
    String? reasonDesc,
  });

  /// Get reply interaction info
  Future<LoadingState<ReplyInteractData>> getReplyInteraction({
    required Object oid,
    required Object type,
  });

  /// Modify reply subject (close/open comments)
  Future<LoadingState<Null>> replySubjectModify({
    required int oid,
    required int type,
    required int action,
  });
}
