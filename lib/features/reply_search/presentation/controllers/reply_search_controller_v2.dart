import 'package:flutter/material.dart';
import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show SearchItemReply, SearchItem, SearchItemType;
import 'package:PiliPlus/grpc/reply.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/reply/reply_search_type.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';

/// Reply search child controller V2 (Riverpod version)
///
/// Handles search results for either video or article type
class ReplySearchChildControllerV2 extends CommonListControllerV2<SearchItemReply, SearchItem> {
  ReplySearchChildControllerV2({
    required this.parentController,
    required this.searchType,
  });

  final ReplySearchControllerV2 parentController;
  final ReplySearchType searchType;

  @override
  List<SearchItem>? getDataList(SearchItemReply response) {
    if (!response.cursor.hasNext) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  Future<LoadingState<SearchItemReply>> customGetData() {
    return ReplyGrpc.searchItem(
      page: page,
      itemType: searchType == ReplySearchType.video
          ? SearchItemType.VIDEO
          : SearchItemType.ARTICLE,
      oid: parentController.oid,
      type: parentController.type,
      keyword: parentController.editingController.text,
    );
  }
}

/// Reply search main controller V2 (Riverpod version)
///
/// Manages the search UI state and coordinates child controllers
class ReplySearchControllerV2 extends ChangeNotifier {
  ReplySearchControllerV2({
    required this.type,
    required this.oid,
  });

  final int type;
  final int oid;

  // Input controllers
  final FocusNode focusNode = FocusNode();
  final TextEditingController editingController = TextEditingController();

  // Child controllers - created lazily
  ReplySearchChildControllerV2? _videoController;
  ReplySearchChildControllerV2? _articleController;

  ReplySearchChildControllerV2 get videoController {
    _videoController ??= ReplySearchChildControllerV2(
      parentController: this,
      searchType: ReplySearchType.video,
    );
    return _videoController!;
  }

  ReplySearchChildControllerV2 get articleController {
    _articleController ??= ReplySearchChildControllerV2(
      parentController: this,
      searchType: ReplySearchType.article,
    );
    return _articleController!;
  }

  void onClear() {
    if (editingController.value.text.isNotEmpty) {
      editingController.clear();
      focusNode.requestFocus();
    }
  }

  void submit() {
    videoController.scrollController.jumpTo(0);
    videoController.onReload();
    articleController.scrollController.jumpTo(0);
    articleController.onReload();
  }

  @override
  void dispose() {
    focusNode.dispose();
    editingController.dispose();
    _videoController?.dispose();
    _articleController?.dispose();
    super.dispose();
  }
}
