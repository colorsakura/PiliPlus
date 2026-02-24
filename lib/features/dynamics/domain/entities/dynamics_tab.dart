// Re-export DynamicsTabType from models
export 'package:PiliPlus/models/common/dynamic/dynamics_type.dart' show DynamicsTabType;

/// Configuration for dynamics tabs.
class DynamicsTabConfig {
  const DynamicsTabConfig({
    required this.defaultTabIndex,
    required this.showAllFollowedUp,
    required this.upPanelPosition,
  });

  final int defaultTabIndex;
  final bool showAllFollowedUp;
  final String upPanelPosition;

  /// Get the UP panel position preference.
  String getUpPanelPosition() => upPanelPosition;
}
