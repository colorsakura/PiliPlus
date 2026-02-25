import 'package:get/get.dart';
import 'package:PiliPlus/features/history/domain/entities/history_item.dart';
import 'package:PiliPlus/models/history/list.dart';
import 'package:PiliPlus/features/common/presentation/pages/multi_select/base.dart';

/// 简单的多选控制器适配器
/// 用于在Clean Architecture中使用需要GetX MultiSelectBase的现有组件
class HistoryMultiSelectController extends GetxController
    implements MultiSelectBase<HistoryItemModel> {
  @override
  final RxBool enableMultiSelect = false.obs;

  final RxInt rxCount = 0.obs;

  @override
  int get checkedCount => rxCount.value;

  @override
  void onSelect(HistoryItemModel item) {
    item.checked = !item.checked;
    if (item.checked) {
      rxCount.value++;
    } else {
      rxCount.value--;
    }
    if (checkedCount == 0) {
      enableMultiSelect.value = false;
    }
    update();
  }

  @override
  void handleSelect({bool checked = false, bool disableSelect = true}) {
    // 简化实现 - 在此场景中不需要全选功能
    if (!checked) {
      enableMultiSelect.value = false;
    }
  }

  @override
  void onRemove() {
    // 不需要实现
  }
}

/// 将 Entity 转换为 Model 并添加 checked 支持
HistoryItemModel adaptHistoryItemEntity(HistoryItemEntity entity) {
  final model = entity.toModel();
  // checked is initialized to false by MultiSelectData mixin
  return model;
}
