import '../entities/dynamics_tab.dart';
import '../repositories/dynamics_tab_repository.dart';

/// Use case for getting dynamics tab configuration.
class GetDynamicsTabConfigUseCase {
  const GetDynamicsTabConfigUseCase(this._repository);

  final DynamicsTabRepository _repository;

  /// Get the dynamics tab configuration.
  DynamicsTabConfig call() {
    return DynamicsTabConfig(
      defaultTabIndex: _repository.getDefaultTabIndex(),
      showAllFollowedUp: _repository.isShowAllFollowedUp(),
      upPanelPosition: _repository.getUpPanelPosition(),
    );
  }

  /// Get the default tab index.
  int getDefaultTabIndex() {
    return _repository.getDefaultTabIndex();
  }

  /// Check if all followed UPs should be shown.
  bool isShowAllFollowedUp() {
    return _repository.isShowAllFollowedUp();
  }

  /// Get the UP panel position preference.
  String getUpPanelPosition() {
    return _repository.getUpPanelPosition();
  }
}
