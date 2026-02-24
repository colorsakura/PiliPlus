import 'package:PiliPlus/core/controllers/reply_controller.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart';
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:get/get.dart';

/// Base controller for dynamic comment functionality
///
/// Extends ReplyController with dynamic-specific:
/// - Title visibility toggle on scroll
/// - Horizontal preview mode settings
/// - Dynamic detail ratio settings
/// - Automatic data fetching for dynamic comments
///
/// Subclasses must provide:
/// - oid: The comment thread ID
/// - replyType: The comment type (1 for video, 14 for article, etc.)
abstract class CommonDynController extends ReplyController<MainListReply> {
  /// The comment thread ID
  int get oid;

  /// The comment type (1=video, 14=article, etc.)
  int get replyType;

  late final RxBool showTitle = false.obs;

  late final horizontalPreview = Pref.horizontalPreview;
  late final List<double> ratio = Pref.dynamicDetailRatio;

  @override
  Future<LoadingState<MainListReply>> customGetData() => ReplyGrpc.mainList(
    type: replyType,
    oid: oid,
    mode: mode.value,
    cursorNext: cursorNext,
    offset: paginationReply?.nextOffset,
  );

  @override
  List<ReplyInfo>? getDataList(MainListReply response) {
    return response.replies;
  }
}
