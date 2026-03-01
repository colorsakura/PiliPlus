import 'package:PiliPlus/shared/widgets/flutter/text_field/controller.dart';
import 'package:PiliPlus/core/controllers/common_list_controller.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show MainListReply, ReplyInfo, SubjectControl, Mode;
import 'package:PiliPlus/grpc/bilibili/pagination.pb.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/features/reply/data/datasources/reply_remote_datasource.dart';
import 'package:PiliPlus/models/common/reply/reply_sort_type.dart';
import 'package:PiliPlus/features/common/presentation/pages/publish/publish_route.dart';
import 'package:PiliPlus/features/video/presentation/pages/reply_new/view.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/reply_utils.dart';
import 'package:PiliPlus/utils/request_utils.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/toast_utils.dart';

/// Base controller for reply/comment functionality
///
/// Extends CommonListController with:
/// - Reply sorting (time/hot)
/// - Comment count tracking
/// - Reply submission and management
/// - Top comment pinning
/// - Comment anti-fraud checking
///
/// Generic type R: The raw API response type (typically MainListReply)
abstract class ReplyController<R> extends CommonListController<R, ReplyInfo> {
  final ReplyRemoteDataSource _replyDataSource = ReplyRemoteDataSource();
  final RxInt count = (-1).obs;

  late final Rx<ReplySortType> sortType;
  late final Rx<Mode> mode;

  /// Saved draft replies keyed by (oid or replyItem.oid + replyItem.id)
  final savedReplies = <Object, List<RichTextItem>?>{};

  Int64? upMid;
  Int64? cursorNext;
  SubjectControl? subjectControl;
  FeedPaginationReply? paginationReply;
  late bool hasUpTop = false;

  @override
  bool? get hasFooter => true;

  // comment antifraud settings
  late final _enableCommAntifraud = Pref.enableCommAntifraud;
  late final _biliSendCommAntifraud = Pref.biliSendCommAntifraud;
  bool get enableCommAntifraud =>
      _enableCommAntifraud || _biliSendCommAntifraud;

  /// Source ID for anti-fraud checking (e.g., video bvid, article id)
  dynamic get sourceId;

  @override
  void onInit() {
    super.onInit();
    final cacheSortType = Pref.replySortType;
    sortType = cacheSortType.obs;
    mode =
        (cacheSortType == .time ? Mode.MAIN_LIST_TIME : Mode.MAIN_LIST_HOT).obs;
  }

  @override
  void checkIsEnd(int length) {
    final count = this.count.value;
    if (count != -1 && length >= count) {
      isEnd = true;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success response) {
    MainListReply data = response.response;
    cursorNext = data.cursor.next;
    paginationReply = data.paginationReply;
    count.value = data.subjectControl.count.toInt();
    if (isRefresh) {
      subjectControl = data.subjectControl;
      upMid ??= data.subjectControl.upMid;
      hasUpTop = data.hasUpTop();
      if (data.hasUpTop()) {
        data.replies.insert(0, data.upTop);
      }
    }
    isEnd = data.cursor.isEnd;
    return false;
  }

  @override
  Future<void> onRefresh() {
    cursorNext = null;
    subjectControl = null;
    paginationReply = null;
    return super.onRefresh();
  }

  /// Toggle between sort by time and sort by hot
  void queryBySort() {
    if (isLoading) return;
    feedBack();
    switch (sortType.value) {
      case ReplySortType.time:
        sortType.value = ReplySortType.hot;
        mode.value = Mode.MAIN_LIST_HOT;
        break;
      case ReplySortType.hot:
        sortType.value = ReplySortType.time;
        mode.value = Mode.MAIN_LIST_TIME;
        break;
    }
    onReload();
  }

  /// Get reply input hint and disabled state based on subject control
  (bool inputDisable, String? hint) get replyHint {
    String? hint;
    bool inputDisable = false;
    try {
      if (subjectControl case final subjectControl?) {
        inputDisable = subjectControl.inputDisable;
        if (subjectControl.hasRootText()) {
          final rootText = subjectControl.rootText;
          if (inputDisable) {
            ToastUtils.showToast(rootText);
          }
          if (rootText.contains('可发') || rootText.contains('可见')) {
            hint = rootText;
          }
        }
      }
    } catch (_) {}
    return (inputDisable, hint);
  }

  /// Open reply page to submit a new reply or reply to a comment
  void onReply(
    ReplyInfo? replyItem, {
    int? oid,
    int? replyType,
  }) {
    if (loadingState.value case Error(:final errMsg, :final code)) {
      if (errMsg != null && (code == 12061 || code == 12002)) {
        ToastUtils.showToast(errMsg);
        return;
      }
    }

    assert(replyItem != null || (oid != null && replyType != null));

    final (bool inputDisable, String? hint) = replyHint;
    if (inputDisable) {
      return;
    }

    final key = oid ?? replyItem!.oid + replyItem.id;
    Get.key.currentState!
        .push(
          PublishRoute(
            pageBuilder: (buildContext, animation, secondaryAnimation) {
              return ReplyPage(
                hint: hint,
                oid: oid ?? replyItem!.oid.toInt(),
                root: oid != null ? 0 : replyItem!.id.toInt(),
                parent: oid != null ? 0 : replyItem!.id.toInt(),
                replyType: replyItem?.type.toInt() ?? replyType!,
                replyItem: replyItem,
                items: savedReplies[key],

                /// hd api deprecated
                // canUploadPic: canUploadPic,
                onSave: (reply) {
                  if (reply.isEmpty) {
                    savedReplies.remove(key);
                  } else {
                    savedReplies[key] = reply.toList();
                  }
                },
              );
            },
            settings: RouteSettings(arguments: Get.arguments),
          ),
        )
        .then(
          (res) {
            if (res != null) {
              savedReplies.remove(key);
              ReplyInfo replyInfo = RequestUtils.replyCast(res);
              if (loadingState.value case Success(:final response)) {
                if (response == null) {
                  loadingState.value = Success([replyInfo]);
                } else {
                  if (oid != null) {
                    response.insert(hasUpTop ? 1 : 0, replyInfo);
                  } else {
                    replyItem!
                      ..count += 1
                      ..replies.add(replyInfo);
                  }
                  loadingState.refresh();
                }
              } else {
                loadingState.value = Success([replyInfo]);
              }
              count.value += 1;

              // check reply
              if (enableCommAntifraud) {
                onCheckReply(replyInfo, isManual: false);
              }
            }
          },
        );
  }

  /// Remove a reply from the list
  void onRemove(int index, ReplyInfo item, int? subIndex) {
    if (subIndex == null) {
      loadingState.value.data!.removeAt(index);
    } else {
      item
        ..count -= 1
        ..replies.removeAt(subIndex);
    }
    count.value -= 1;
    loadingState.refresh();
  }

  /// Check reply for anti-fraud
  void onCheckReply(ReplyInfo replyInfo, {required bool isManual}) {
    ReplyUtils.onCheckReply(
      replyInfo: replyInfo,
      biliSendCommAntifraud: _biliSendCommAntifraud,
      sourceId: sourceId,
      isManual: isManual,
    );
  }

  /// Toggle top comment pinning
  Future<void> onToggleTop(
    ReplyInfo item,
    int index,
    oid,
    int type,
  ) async {
    bool isUpTop = item.replyControl.isUpTop;
    final res = await _replyDataSource.replyTop(
      oid: oid,
      type: type,
      rpid: item.id,
      isUpTop: isUpTop,
    );
    if (res.isSuccess) {
      item.replyControl.isUpTop = !isUpTop;
      if (!isUpTop && index != 0) {
        final list = loadingState.value.data!;
        list
          ..first.replyControl.isUpTop = false
          ..insert(0, list.removeAt(index));
      }
      loadingState.refresh();
      ToastUtils.showToast('${isUpTop ? '取消' : ''}置顶成功');
    } else {
      res.toast();
    }
  }

  @override
  void onClose() {
    savedReplies.clear();
    super.onClose();
  }
}
