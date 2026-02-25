import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/live_search/presentation/controllers/live_search_controller_v2.dart';

/// Provider for LiveSearchControllerV2
///
/// Creates a new controller instance with optional mid and uname
final liveSearchControllerProvider =
    Provider.family<LiveSearchControllerV2, ({String? mid, String? uname})>(
      (ref, args) {
        final controller = LiveSearchControllerV2(
          mid: args.mid,
          uname: args.uname,
        );
        ref.onDispose(controller.dispose);
        return controller;
      },
    );

/// Provider for LiveSearchChildControllerV2 (room type)
final liveSearchRoomChildProvider =
    Provider.family<
      LiveSearchChildControllerV2,
      ({String? mid, String? uname})
    >((ref, args) {
      final parent = ref.watch(liveSearchControllerProvider(args));
      final child = parent.roomController;
      ref.onDispose(child.dispose);
      return child;
    });

/// Provider for LiveSearchChildControllerV2 (user type)
final liveSearchUserChildProvider =
    Provider.family<
      LiveSearchChildControllerV2,
      ({String? mid, String? uname})
    >((ref, args) {
      final parent = ref.watch(liveSearchControllerProvider(args));
      final child = parent.userController;
      ref.onDispose(child.dispose);
      return child;
    });
