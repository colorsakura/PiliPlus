import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/features/member_dynamics/domain/repositories/member_dynamics_repository.dart';
import 'package:PiliPlus/utils/toast_utils.dart';

/// Controller for member dynamics page (Clean Architecture with Riverpod)
///
/// Manages user's dynamics with offset-based pagination and actions
class MemberDynamicsController
    extends CommonListControllerV2<DynamicsDataModel, DynamicItemModel> {
  MemberDynamicsController({
    required int mid,
    required MemberDynamicsRepository repository,
  }) : _mid = mid,
       _repository = repository {
    queryData();
  }

  final int _mid;
  final MemberDynamicsRepository _repository;
  String offset = '';

  @override
  Future<void> onRefresh() {
    offset = '';
    return super.onRefresh();
  }

  @override
  Future<void> queryData([bool isRefresh = true]) async {
    if (!isRefresh && (isEnd || offset == '-1')) {
      return;
    }
    return super.queryData(isRefresh);
  }

  @override
  List<DynamicItemModel>? getDataList(DynamicsDataModel response) {
    offset = response.offset?.isNotEmpty == true ? response.offset! : '-1';
    if (response.hasMore == false) {
      isEnd = true;
    }
    return response.items;
  }

  @override
  Future<LoadingState<DynamicsDataModel>> customGetData() =>
      _repository.getMemberDynamics(
        mid: _mid,
        offset: offset,
      );

  /// Remove a dynamic post
  Future<void> removeDynamic(dynamic dynamicId) async {
    final res = await _repository.removeDynamic(dynIdStr: dynamicId);
    if (res.isSuccess) {
      final currentList = loadingState;
      if (currentList case Success(:final response)) {
        final newList = List<DynamicItemModel>.from(response!)
          ..removeWhere((item) => item.idStr == dynamicId);
        loadingState = Success(newList);
      }
      ToastUtils.showToast('删除成功');
    } else {
      res.toast();
    }
  }

  /// Set or unset a dynamic as top
  Future<void> setDynamicTop(bool isTop, dynamic dynamicId) async {
    final res = await _repository.setDynamicTop(
      dynamicId: dynamicId,
      isTop: isTop,
    );
    if (res.isSuccess) {
      final currentList = loadingState;
      if (currentList case Success(:final response)) {
        final newList = List<DynamicItemModel>.from(response!);
        if (newList.isNotEmpty) {
          // Clear top from first item
          newList[0].modules
            ..moduleTag = null
            ..moduleAuthor?.isTop = false;

          if (isTop) {
            loadingState = Success(newList);
            ToastUtils.showToast('取消置顶成功');
          } else {
            // Set top on selected item and move to top
            final item = newList.firstWhere((item) => item.idStr == dynamicId);
            item.modules
              ..moduleTag = ModuleTag(text: '置顶')
              ..moduleAuthor?.isTop = true;
            newList
              ..remove(item)
              ..insert(0, item);
            loadingState = Success(newList);
            ToastUtils.showToast('置顶成功');
          }
        }
      }
    } else {
      res.toast();
    }
  }
}
