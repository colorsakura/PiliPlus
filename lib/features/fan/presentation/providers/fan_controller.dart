import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/features/fan/domain/repositories/fan_repository.dart';
import 'package:PiliPlus/http/member.dart';
import 'package:PiliPlus/utils/toast_utils.dart';

/// Controller for fan/follower page (Clean Architecture with Riverpod)
///
/// Manages list of fans (followers) with pagination
class FanController
    extends CommonListControllerV2<FollowData, FollowItemModel> {
  FanController({
    required int mid,
    required FanRepository repository,
    String? name,
  }) : _mid = mid,
       _repository = repository,
       _name = name {
    if (name == null) {
      _queryUserName();
    }
    queryData();
  }

  final int _mid;
  final FanRepository _repository;
  String? _name;

  int? total;

  /// Get user name
  String? get name => _name;

  /// Get mid
  int get mid => _mid;

  Future<void> _queryUserName() async {
    final res = await MemberHttp.memberCardInfo(mid: _mid);
    _name = res.dataOrNull?.card?.name;
    notifyListeners();
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
  Future<LoadingState<FollowData>> customGetData() => _repository.getFans(
    vmid: _mid,
    pn: page,
    orderType: 'attention',
  );

  /// Remove a fan from the list
  Future<void> removeFan(int index, int mid) async {
    final res = await _repository.removeFan(
      mid: mid,
      act: 7,
      reSrc: 11,
    );
    if (res.isSuccess) {
      final currentList = loadingState;
      if (currentList case Success(:final response)) {
        final newList = List<FollowItemModel>.from(response!)..removeAt(index);
        loadingState = Success(newList);
        if (total != null && total! > 0) {
          total = total! - 1;
        }
      }
      ToastUtils.showToast('移除成功');
    } else {
      res.toast();
    }
  }
}
