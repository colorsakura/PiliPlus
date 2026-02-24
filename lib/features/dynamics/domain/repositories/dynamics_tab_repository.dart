import '../entities/dynamics_tab.dart';

/// Repository interface for dynamics tab configuration.
abstract class DynamicsTabRepository {
  /// Get the dynamics tab configuration.
  DynamicsTabConfig getTabConfig();

  /// Get the default tab index.
  int getDefaultTabIndex();

  /// Check if all followed UPs should be shown.
  bool isShowAllFollowedUp();

  /// Get the UP panel position preference.
  String getUpPanelPosition();
}
