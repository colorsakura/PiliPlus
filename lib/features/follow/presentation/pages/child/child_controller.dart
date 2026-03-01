import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/common/follow_order_type.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/core/controllers/common_list_controller.dart';
import 'package:PiliPlus/features/follow/presentation/providers/follow_controller.dart';
import 'package:PiliPlus/features/follow/data/datasources/follow_api_datasource.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:get/get.dart';

class FollowChildController
    extends CommonListController<FollowData, FollowItemModel> {
  FollowChildController(this.controller, this.mid, this.tagid) {
    _followDataSource = FollowRemoteDataSource();
  }

  late final FollowRemoteDataSource _followDataSource;
  final FollowController? controller;
  final int? tagid;
  final int mid;
  int? total;

  late final loadSameFollow = controller?.isOwner == false;
  late final Rx<LoadingState<List<FollowItemModel>?>> sameState =
      LoadingState<List<FollowItemModel>?>.loading().obs;

  late final Rx<FollowOrderType> orderType = Pref.followOrderType.obs;

  void setOrderType(FollowOrderType type) {
    orderType.value = type;
    GStorage.settingRepository.setInt(SettingBoxKey.followOrderType, type.index);
  }

  @override
  void onInit() {
    super.onInit();
    queryData();
    if (loadSameFollow) {
      _loadSameFollow();
    }
  }

  @override
  List<FollowItemModel>? getDataList(FollowData response) {
    total = response.total;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (total != null && length >= total!) {
      isEnd = true;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<FollowData> response) {
    if (controller != null) {
      try {
        if (controller!.isOwner && tagid == null && isRefresh) {
          final tabs = controller!.tabs;
          if (tabs != null && tabs.isNotEmpty) {
            tabs[0].count = response.response.total;
            controller!.notifyListeners();
          }
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Future<LoadingState<FollowData>> customGetData() async {
    if (tagid != null) {
      return MemberHttp.followUpGroup(mid: mid, tagid: tagid, pn: page);
    }

    try {
      final result = await _followDataSource.followings(
        vmid: mid,
        pn: page,
        orderType: orderType.value.type,
      );
      return Success(FollowData.fromJson(result));
    } catch (e) {
      return Error(e.toString());
    }
  }

  Future<void> _loadSameFollow() async {
    final res = await UserHttp.sameFollowing(mid: mid);
    if (res case Success(:final response)) {
      sameState.value = Success(response.list);
    }
  }
}
