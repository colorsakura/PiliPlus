import 'package:PiliPlus/features/common/presentation/pages/common_list_controller.dart';
import 'package:PiliPlus/features/common/presentation/pages/multi_select/base.dart';

abstract class MultiSelectController<
  R,
  T extends MultiSelectData
> = CommonListController<R, T>
    with CommonMultiSelectMixin<T>, DeleteItemMixin;
