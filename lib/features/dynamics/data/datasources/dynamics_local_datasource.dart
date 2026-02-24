import 'package:PiliPlus/core/storage/storage_pref.dart';

/// Local data source for dynamics preferences.
class DynamicsLocalDataSource {
  const DynamicsLocalDataSource();

  /// Get the default tab index.
  int getDefaultTabIndex() {
    return Pref.defaultDynamicTypeIndex;
  }

  /// Check if all followed UPs should be shown.
  bool isShowAllFollowedUp() {
    return Pref.dynamicsShowAllFollowedUp;
  }

  /// Get the UP panel position preference.
  String getUpPanelPosition() {
    return Pref.upPanelPosition.name;
  }

  /// Check if live panel should be expanded.
  bool isExpandLivePanel() {
    return Pref.expandDynLivePanel;
  }
}
