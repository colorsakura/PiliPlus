import 'package:flutter/foundation.dart';
import 'package:PiliPlus/models/history/list.dart';

/// Riverpod version of multi-select controller for history items
class HistoryMultiSelectControllerV2 extends ChangeNotifier {
  bool _enableMultiSelect = false;
  int _checkedCount = 0;

  bool get enableMultiSelect => _enableMultiSelect;
  int get checkedCount => _checkedCount;

  void onSelect(HistoryItemModel item) {
    item.checked = !item.checked;
    if (item.checked) {
      _checkedCount++;
    } else {
      _checkedCount--;
    }
    if (_checkedCount == 0) {
      _enableMultiSelect = false;
    }
    notifyListeners();
  }

  void handleSelect({bool checked = false, bool disableSelect = true}) {
    // Simplified implementation - not needed for this use case
    if (!checked) {
      _enableMultiSelect = false;
      notifyListeners();
    }
  }

  void onRemove() {
    // Not needed for this use case
  }

  void clearSelection() {
    _checkedCount = 0;
    _enableMultiSelect = false;
    notifyListeners();
  }
}
