import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/core/controllers/debounce_controller.dart';

/// Provider family for DebounceControllerV2
final debounceControllerProvider =
    Provider.family<DebounceControllerV2, Duration>(
      (ref, duration) {
        final controller = DebounceControllerV2(duration: duration);
        ref.onDispose(controller.dispose);
        return controller;
      },
    );

/// Default debounce controller with 300ms duration
final defaultDebounceControllerProvider = Provider<DebounceControllerV2>((ref) {
  final controller = DebounceControllerV2();
  ref.onDispose(controller.dispose);
  return controller;
});
