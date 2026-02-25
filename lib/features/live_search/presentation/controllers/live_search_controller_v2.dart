import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/live.dart';
import 'package:PiliPlus/models/common/live/live_search_type.dart';
import 'package:PiliPlus/models/live/live_search/data.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';

/// Live search child controller V2 (Riverpod version)
///
/// Handles search results for either room or user type
class LiveSearchChildControllerV2 extends CommonListControllerV2<LiveSearchData, dynamic> {
  LiveSearchChildControllerV2({
    required this.parentController,
    required this.searchType,
  });

  final LiveSearchControllerV2 parentController;
  final LiveSearchType searchType;

  @override
  void checkIsEnd(int length) {
    switch (searchType) {
      case LiveSearchType.room:
        if (parentController.counts[0] != -1 &&
            length >= parentController.counts[0]) {
          isEnd = true;
        }
        break;
      case LiveSearchType.user:
        if (parentController.counts[1] != -1 &&
            length >= parentController.counts[1]) {
          isEnd = true;
        }
        break;
    }
  }

  @override
  List? getDataList(LiveSearchData response) {
    switch (searchType) {
      case LiveSearchType.room:
        final total = response.room?.totalRoom ?? 0;
        parentController.updateCount(0, total);
        return response.room?.list;
      case LiveSearchType.user:
        final total = response.user?.totalUser ?? 0;
        parentController.updateCount(1, total);
        return response.user?.list;
    }
  }

  @override
  Future<LoadingState<LiveSearchData>> customGetData() {
    return LiveHttp.liveSearch(
      page: page,
      keyword: parentController.editingController.text,
      type: searchType,
    );
  }
}

/// Live search main controller V2 (Riverpod version)
///
/// Manages the search UI state and coordinates child controllers
class LiveSearchControllerV2 extends ChangeNotifier {
  LiveSearchControllerV2({
    this.mid,
    this.uname,
  });

  final String? mid;
  final String? uname;

  // State
  bool _hasData = false;
  List<int> _counts = <int>[-1, -1];

  bool get hasData => _hasData;
  List<int> get counts => _counts;

  // Input controllers
  final TextEditingController editingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // Child controllers - created lazily
  LiveSearchChildControllerV2? _roomController;
  LiveSearchChildControllerV2? _userController;

  LiveSearchChildControllerV2 get roomController {
    _roomController ??= LiveSearchChildControllerV2(
      parentController: this,
      searchType: LiveSearchType.room,
    );
    return _roomController!;
  }

  LiveSearchChildControllerV2 get userController {
    _userController ??= LiveSearchChildControllerV2(
      parentController: this,
      searchType: LiveSearchType.user,
    );
    return _userController!;
  }

  void updateCount(int index, int value) {
    if (_counts[index] != value) {
      _counts[index] = value;
      notifyListeners();
    }
  }

  void onClear() {
    if (editingController.value.text.isNotEmpty) {
      editingController.clear();
      _counts = <int>[-1, -1];
      _hasData = false;
      focusNode.requestFocus();
      notifyListeners();
    }
  }

  void submit() {
    if (editingController.text.isEmpty) return;

    // If input is digit-only, navigate directly to live room
    if (IdUtils.digitOnlyRegExp.hasMatch(editingController.text)) {
      final roomId = int.tryParse(editingController.text);
      if (roomId != null) {
        PageUtils.toLiveRoom(roomId);
        return;
      }
    }

    // Otherwise, search
    _hasData = true;
    notifyListeners();

    // Trigger reload on both child controllers
    roomController.scrollController.jumpTo(0);
    roomController.onReload();
    userController.scrollController.jumpTo(0);
    userController.onReload();
  }

  @override
  void dispose() {
    editingController.dispose();
    focusNode.dispose();
    _roomController?.dispose();
    _userController?.dispose();
    super.dispose();
  }
}
