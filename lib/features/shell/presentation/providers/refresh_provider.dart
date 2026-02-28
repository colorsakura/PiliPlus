import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Refresh trigger state for double-tap navigation functionality.
///
/// When a user double-taps on the same navigation tab, this provider
/// is used to notify the corresponding page to refresh or scroll to top.
///
/// Usage:
/// - In ShellPage: Call `ref.read(refreshTriggerProvider.notifier).trigger(branchIndex)` on double-tap
/// - In pages (e.g., HomePage): Listen to `refreshTriggerProvider` and respond to changes
final refreshTriggerProvider = NotifierProvider<RefreshTriggerNotifier, int>(
  RefreshTriggerNotifier.new,
);

/// Notifier for managing refresh trigger events
class RefreshTriggerNotifier extends Notifier<int> {
  @override
  int build() => -1; // -1 indicates no refresh trigger

  /// Trigger a refresh for the specified branch index
  ///
  /// The state is immediately reset to -1 after triggering to allow
  /// consecutive triggers.
  void trigger(int branchIndex) {
    state = branchIndex;
    // Immediately reset to allow consecutive triggers
    Future.microtask(() => state = -1);
  }
}
