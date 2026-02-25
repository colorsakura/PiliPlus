import 'package:flutter/material.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/models/common/member/search_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/models/member/search_archive/data.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';

/// Member search child controller V2 (Riverpod version)
///
/// Handles search results for either archive or dynamic type
class MemberSearchChildControllerV2 extends CommonListControllerV2<dynamic, dynamic> {
  MemberSearchChildControllerV2({
    required this.parentController,
    required this.searchType,
  });

  final MemberSearchControllerV2 parentController;
  final MemberSearchType searchType;

  dynamic offset;

  @override
  void checkIsEnd(int length) {
    switch (searchType) {
      case MemberSearchType.archive:
        if (parentController.counts[0] != -1 &&
            length >= parentController.counts[0]) {
          isEnd = true;
        }
        break;
      case MemberSearchType.dynamic:
        if (parentController.counts[1] != -1 &&
            length >= parentController.counts[1]) {
          isEnd = true;
        }
        break;
    }
  }

  @override
  List? getDataList(dynamic response) {
    switch (searchType) {
      case MemberSearchType.archive:
        final data = response as SearchArchiveData;
        parentController.updateCount(searchType.index, data.page?.count ?? 0);
        return data.list?.vlist;
      case MemberSearchType.dynamic:
        final data = response as DynamicsDataModel;
        offset = data.offset;
        if (data.hasMore == false) {
          isEnd = true;
        }
        parentController.updateCount(searchType.index, data.total ?? 0);
        return data.items;
    }
  }

  @override
  Future<void> onRefresh() {
    offset = null;
    return super.onRefresh();
  }

  @override
  Future<LoadingState> customGetData() {
    final keyword = parentController.editingController.text;
    return switch (searchType) {
      MemberSearchType.archive => MemberHttp.searchArchive(
          mid: parentController.mid,
          pn: page,
          keyword: keyword,
          order: 'pubdate',
        ),
      MemberSearchType.dynamic => MemberHttp.dynSearch(
          mid: parentController.mid,
          pn: page,
          offset: offset ?? '',
          keyword: keyword,
        ),
    };
  }
}

/// Member search main controller V2 (Riverpod version)
///
/// Manages the search UI state and coordinates child controllers
class MemberSearchControllerV2 extends ChangeNotifier {
  MemberSearchControllerV2({
    required this.mid,
    this.uname,
  });

  final String mid;
  final String? uname;

  // State
  bool _hasData = false;
  List<int> _counts = <int>[-1, -1];

  bool get hasData => _hasData;
  List<int> get counts => _counts;

  // Input controllers
  final FocusNode focusNode = FocusNode();
  final TextEditingController editingController = TextEditingController();

  // Child controllers - created lazily
  MemberSearchChildControllerV2? _archiveController;
  MemberSearchChildControllerV2? _dynamicController;

  MemberSearchChildControllerV2 get archiveController {
    _archiveController ??= MemberSearchChildControllerV2(
      parentController: this,
      searchType: MemberSearchType.archive,
    );
    return _archiveController!;
  }

  MemberSearchChildControllerV2 get dynamicController {
    _dynamicController ??= MemberSearchChildControllerV2(
      parentController: this,
      searchType: MemberSearchType.dynamic,
    );
    return _dynamicController!;
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
    if (editingController.text.isNotEmpty) {
      _hasData = true;
      notifyListeners();

      // Trigger reload on both child controllers
      archiveController.scrollController.jumpTo(0);
      archiveController.onReload();
      dynamicController.scrollController.jumpTo(0);
      dynamicController.onReload();
    }
  }

  @override
  void dispose() {
    focusNode.dispose();
    editingController.dispose();
    _archiveController?.dispose();
    _dynamicController?.dispose();
    super.dispose();
  }
}
