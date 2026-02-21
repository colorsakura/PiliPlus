import 'dart:async';

import 'package:PiliPlus/features/shell/controller.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';

/// Manages periodic network requests for MainController
class NetworkManager {
  final MainController controller;
  Timer? _periodicCheckTimer;

  NetworkManager(this.controller);

  /// Start periodic checks with a single timer
  void startPeriodicChecks() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _performPeriodicChecks(),
    );
  }

  /// Perform all periodic checks in a batch
  Future<void> _performPeriodicChecks() async {
    if (!controller.accountService.isLogin.value) return;

    // Only check if on home tab
    final currentNav =
        controller.navigationBars[controller.selectedIndex.value];
    if (currentNav == NavigationBarType.home) {
      await Future.wait([
        controller.checkUnreadDynamic(),
        controller.checkUnread(false),
        controller.checkDefaultSearch(),
      ]);
    }
  }

  /// Stop periodic checks
  void stop() {
    _periodicCheckTimer?.cancel();
    _periodicCheckTimer = null;
  }

  /// Dispose resources
  void dispose() {
    stop();
  }
}
