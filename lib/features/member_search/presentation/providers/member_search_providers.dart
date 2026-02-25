import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/member_search/presentation/controllers/member_search_controller_v2.dart';

/// Provider for MemberSearchControllerV2
///
/// Creates a new controller instance for each unique mid
final memberSearchControllerProvider =
    Provider.family<MemberSearchControllerV2, String>((ref, mid) {
      final controller = MemberSearchControllerV2(mid: mid);
      ref.onDispose(controller.dispose);
      return controller;
    });

/// Provider for the member's uname (optional display name)
///
/// This should be overridden by the calling code with the actual uname
final memberSearchUnameProvider = Provider.family<String?, String>(
  (ref, mid) => null,
);

/// Provider for MemberSearchChildControllerV2 (archive type)
final memberSearchArchiveChildProvider =
    Provider.family<MemberSearchChildControllerV2, String>((ref, mid) {
      final parent = ref.watch(memberSearchControllerProvider(mid));
      final child = parent.archiveController;
      ref.onDispose(child.dispose);
      return child;
    });

/// Provider for MemberSearchChildControllerV2 (dynamic type)
final memberSearchDynamicChildProvider =
    Provider.family<MemberSearchChildControllerV2, String>((ref, mid) {
      final parent = ref.watch(memberSearchControllerProvider(mid));
      final child = parent.dynamicController;
      ref.onDispose(child.dispose);
      return child;
    });
