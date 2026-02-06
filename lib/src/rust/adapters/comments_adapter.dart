import 'package:PiliPlus/models/reply/content.dart';
import 'package:PiliPlus/models/reply/cursor.dart';
import 'package:PiliPlus/models/reply/data.dart';
import 'package:PiliPlus/models/reply/member.dart';
import 'package:PiliPlus/models/reply/reply.dart';
import 'package:PiliPlus/src/rust/models/comments.dart' as rust;

/// Adapter for converting Rust CommentList to Flutter ReplyData.
///
/// This adapter handles field name mappings and type conversions between:
/// - Rust-generated models (from flutter_rust_bridge)
/// - Flutter app models (from lib/models/)
///
/// Key conversions:
/// - `Comment.id` (Rust) → `rpid` (Flutter)
/// - `Comment.oid` (Rust) → `oid` (Flutter)
/// - `Comment.uid` (Rust) → `mid` (Flutter)
/// - `Comment.username` (Rust) → `member.name` (Flutter)
/// - `Comment.avatar` (Rust) → `member.avatar` (Flutter)
/// - `Comment.content` (Rust) → `content.message` (Flutter)
/// - `Comment.likeCount` (Rust) → `like` (Flutter)
/// - `Comment.replyCount` (Rust) → `rcount` (Flutter)
/// - `Comment.publishTime` (Rust) → `ctime` (Flutter)
/// - `Comment.replies` (Rust) → `replies` (Flutter, recursive)
/// - `PlatformInt64` (Rust) → int (Flutter)
/// - `BigInt` (Rust) → int (Flutter for counts)
///
/// Note: The Rust Comment model is a simplified subset of the full Flutter
/// ReplyItemModel. Fields not present in Rust are left null or set to defaults.
class CommentsAdapter {
  /// Convert Rust CommentList to Flutter ReplyData.
  ///
  /// Provides sensible defaults for fields not present in the Rust model.
  /// Only maps the basic fields available in the Rust implementation.
  static ReplyData fromRust(rust.CommentList rustCommentList) {
    return ReplyData(
      replies: rustCommentList.comments.map(_convertComment).toList(),
      // Set defaults for fields not in Rust model
      cursor: ReplyCursor(
        isEnd: rustCommentList.page * rustCommentList.pageSize >=
            rustCommentList.totalCount,
        next: rustCommentList.page + 1,
        // All other cursor fields are null (not in Rust model)
        isBegin: null,
        prev: null,
        paginationReply: null,
        sessionId: null,
        mode: null,
        modeText: null,
        allCount: null,
        supportMode: null,
        name: null,
      ),
      // All other fields are null as they're not in the Rust model
      top: null,
      topReplies: null,
      upSelection: null,
      assist: null,
      blacklist: null,
      vote: null,
      upper: null,
      control: null,
      note: null,
      esportsGradeCard: null,
      callbacks: null,
      contextFeature: null,
    );
  }

  /// Convert a single Rust Comment to Flutter ReplyItemModel.
  ///
  /// Handles nested replies recursively.
  static ReplyItemModel _convertComment(rust.Comment rustComment) {
    return ReplyItemModel(
      // Basic ID fields
      rpid: rustComment.id.toInt(),
      oid: rustComment.oid.toInt(),
      type: 1, // Video comment type
      mid: rustComment.uid.toInt(),

      // Timestamp
      ctime: rustComment.publishTime.toInt(),

      // Counts
      like: rustComment.likeCount.toInt(),
      rcount: rustComment.replyCount.toInt(),

      // Member information
      member: ReplyMember(
        mid: rustComment.uid.toInt().toString(),
        uname: rustComment.username,
        avatar: rustComment.avatar.url,
        // All other member fields are null (not in Rust model)
        levelInfo: null,
        officialVerify: null,
        nameplate: null,
        pendant: null,
        sex: null,
        sign: null,
        rank: null,
        senior: null,
        isSeniorMember: null,
        faceNftNew: null,
        vip: null,
        fansDetail: null,
        isContractor: null,
        contractDesc: null,
        nftInteraction: null,
      ),

      // Content
      content: ReplyContent(
        message: rustComment.content,
        // All other content fields are null (not in Rust model)
        members: null,
        jumpUrl: null,
        maxLine: null,
        pictures: null,
        pictureScale: null,
      ),

      // Nested replies (recursive conversion)
      replies: rustComment.replies.map(_convertComment).toList(),

      // All other fields are null (not in Rust model)
      root: null,
      parent: null,
      dialog: null,
      count: null,
      state: null,
      fansgrade: null,
      attr: null,
      midStr: null,
      oidStr: null,
      rpidStr: null,
      rootStr: null,
      parentStr: null,
      dialogStr: null,
      action: null,
      assist: null,
      upAction: null,
      invisible: null,
      replyControl: null,
      folder: null,
      dynamicId: null,
      dynamicIdStr: null,
      noteCvidStr: null,
      trackInfo: null,
    );
  }
}
