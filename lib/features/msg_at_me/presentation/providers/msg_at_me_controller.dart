import 'package:PiliPlus/core/controllers/common_list_controller_v2.dart';
import 'package:PiliPlus/features/msg_at_me/domain/usecases/get_msg_at_me_items_usecase.dart';
import 'package:PiliPlus/features/msg_at_me/domain/usecases/remove_msg_item_usecase.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/msg_at/data.dart';
import 'package:PiliPlus/models/msg/msg_at/item.dart';
import 'package:PiliPlus/utils/toast_utils.dart';

/// Controller for @Me notifications page (Clean Architecture with Riverpod)
///
/// Manages @Me mentions with cursor-based pagination
class MsgAtMeController extends CommonListControllerV2<MsgAtData, MsgAtItem> {
  MsgAtMeController({
    required GetMsgAtMeItemsUseCase getItemsUseCase,
    required RemoveMsgItemUseCase removeItemUseCase,
  }) : _getItemsUseCase = getItemsUseCase,
       _removeItemUseCase = removeItemUseCase {
    queryData();
  }

  final GetMsgAtMeItemsUseCase _getItemsUseCase;
  final RemoveMsgItemUseCase _removeItemUseCase;

  int? _cursor;
  int? _cursorTime;

  @override
  List<MsgAtItem>? getDataList(MsgAtData response) {
    if (response.cursor?.isEnd == true) {
      isEnd = true;
    }
    _cursor = response.cursor?.id;
    _cursorTime = response.cursor?.time;
    return response.items;
  }

  @override
  Future<void> onRefresh() {
    _cursor = null;
    _cursorTime = null;
    return super.onRefresh();
  }

  @override
  Future<LoadingState<MsgAtData>> customGetData() => _getItemsUseCase(
    cursor: _cursor,
    cursorTime: _cursorTime,
  );

  /// Remove a notification item
  @pragma('vm:notify-debugger-on-exception')
  Future<void> removeItem(Object id, int index) async {
    try {
      final res = await _removeItemUseCase(id: id);
      if (res.isSuccess && loadingState is Success) {
        final currentList =
            (loadingState as Success<List<MsgAtItem>?>).response;
        if (currentList != null && index < currentList.length) {
          final newList = List<MsgAtItem>.from(currentList)..removeAt(index);
          loadingState = Success(newList);
          ToastUtils.showToast('删除成功');
        }
      } else {
        res.toast();
      }
    } catch (_) {}
  }
}
