import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/features/followed/domain/usecases/get_followed_list_usecase.dart';
import 'package:PiliPlus/features/followed/domain/usecases/get_user_name_usecase.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/data.dart';
import 'package:PiliPlus/models/follow/list.dart';

/// Controller for "also followed" page (Clean Architecture with Riverpod)
///
/// Shows users that are also followed by the target user
class FollowedController extends CommonListControllerV2<FollowData, FollowItemModel> {
  FollowedController({
    required GetFollowedListUseCase getListUseCase,
    required GetUserNameUseCase getUserNameUseCase,
    required int mid,
    String? name,
  })  : _getListUseCase = getListUseCase,
        _getUserNameUseCase = getUserNameUseCase,
        _mid = mid,
        _name = name {
    if (_name == null) {
      _fetchUserName();
    }
    queryData();
  }

  final GetFollowedListUseCase _getListUseCase;
  final GetUserNameUseCase _getUserNameUseCase;
  final int _mid;
  String? _name;

  int? _total;

  /// Get the user name (for display in app bar)
  String? get name => _name;

  /// Get total count (for display in app bar)
  int? get total => _total;

  /// Fetch user name if not provided
  Future<void> _fetchUserName() async {
    final name = await _getUserNameUseCase(_mid);
    if (name != null) {
      _name = name;
      notifyListeners();
    }
  }

  @override
  List<FollowItemModel>? getDataList(FollowData response) {
    _total = response.total;
    return response.list;
  }

  @override
  void checkIsEnd(int length) {
    if (_total != null && length >= _total!) {
      isEnd = true;
    }
  }

  @override
  Future<LoadingState<FollowData>> customGetData() =>
      _getListUseCase(
        mid: _mid,
        pn: page,
      );
}
