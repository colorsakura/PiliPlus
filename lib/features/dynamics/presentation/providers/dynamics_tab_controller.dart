import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:PiliPlus/features/dynamics/domain/entities/dynamics_tab.dart';
import 'package:PiliPlus/features/dynamics/presentation/providers/dynamics_providers.dart';

/// Controller for dynamics tab configuration.
final dynamicsTabControllerProvider = Provider<DynamicsTabConfig>((ref) {
  final useCase = ref.watch(getDynamicsTabConfigUseCaseProvider);
  return useCase.call();
});

/// Notifier for dynamics tab configuration.
class DynamicsTabController extends Notifier<DynamicsTabConfig> {
  @override
  DynamicsTabConfig build() {
    final useCase = ref.read(getDynamicsTabConfigUseCaseProvider);
    return useCase.call();
  }

  /// Get the default tab index.
  int getDefaultTabIndex() {
    return state.defaultTabIndex;
  }

  /// Check if all followed UPs should be shown.
  bool isShowAllFollowedUp() {
    return state.showAllFollowedUp;
  }

  /// Get the UP panel position preference.
  String getUpPanelPosition() {
    final useCase = ref.read(getDynamicsTabConfigUseCaseProvider);
    return useCase.getUpPanelPosition();
  }
}

/// Dynamics tab controller notifier provider.
final dynamicsTabControllerNotifierProvider =
    NotifierProvider<DynamicsTabController, DynamicsTabConfig>(
  DynamicsTabController.new,
);
