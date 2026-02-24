import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/sub/sub/data.dart';
import 'package:PiliPlus/models/sub/sub/list.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/features/subscription/domain/repositories/subscription_repository.dart';

/// Controller for subscription page (Clean Architecture with Riverpod)
///
/// Manages user subscription folders with pagination
class SubscriptionController extends CommonListControllerV2<SubData, SubItemModel> {
  SubscriptionController({
    required SubscriptionRepository repository,
    required bool isLogin,
  })  : _repository = repository,
        _isLogin = isLogin {
    if (_isLogin) {
      queryData();
    } else {
      loadingState = const Error('账号未登录');
      notifyListeners();
    }
  }

  final SubscriptionRepository _repository;
  final bool _isLogin;
  int _mid = 0;

  /// Initialize with account mid
  void init(int mid) {
    _mid = mid;
  }

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (!_isLogin) {
      loadingState = const Error('账号未登录');
      notifyListeners();
      return;
    }
    return super.queryData(isRefresh);
  }

  @override
  List<SubItemModel>? getDataList(SubData response) {
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.list;
  }

  @override
  Future<LoadingState<SubData>> customGetData() =>
      _repository.getUserSubFolders(
        pn: page,
        ps: 20,
        mid: _mid,
      );

  /// Cancel a subscription
  Future<bool> cancelSub(SubItemModel subFolderItem) async {
    final res = await _repository.cancelSub(
      id: subFolderItem.id!,
      type: subFolderItem.type!,
    );
    if (res.isSuccess && loadingState is Success) {
      final currentList = (loadingState as Success<List<SubItemModel>?>).response;
      if (currentList != null) {
        final newList = List<SubItemModel>.from(currentList)..remove(subFolderItem);
        loadingState = Success(newList);
        return true;
      }
    }
    return false;
  }
}
