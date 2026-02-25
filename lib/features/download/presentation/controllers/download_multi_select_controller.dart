import 'package:flutter/foundation.dart';
import 'package:PiliPlus/models/download/download_info.dart';

/// Download multi-select controller V2 - Riverpod version
class DownloadMultiSelectControllerV2 extends ChangeNotifier {
  bool _enableMultiSelect = false;
  int _checkedCount = 0;

  bool get enableMultiSelect => _enableMultiSelect;
  int get checkedCount => _checkedCount;

  void onSelect(DownloadPageInfo item) {
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

  /// Get all checked items from the list
  Iterable<DownloadPageInfo> getAllChecked(List<DownloadPageInfo> list) {
    return list.where((item) => item.checked);
  }

  void handleSelect({bool checked = false, bool disableSelect = true}) {
    if (!checked) {
      _enableMultiSelect = false;
      notifyListeners();
    }
  }

  void onRemove() {
    // To be implemented by the caller
  }

  void clearSelection() {
    _checkedCount = 0;
    _enableMultiSelect = false;
    notifyListeners();
  }
}
