import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/reply_search/presentation/controllers/reply_search_controller_v2.dart';

/// Provider for ReplySearchControllerV2
///
/// Creates a new controller instance for each unique (type, oid) pair
final replySearchControllerProvider =
    Provider.family<ReplySearchControllerV2, ({int type, int oid})>(
  (ref, args) {
    final controller = ReplySearchControllerV2(
      type: args.type,
      oid: args.oid,
    );
    ref.onDispose(controller.dispose);
    return controller;
  },
);

/// Provider for ReplySearchChildControllerV2 (video type)
final replySearchVideoChildProvider = Provider.family<
    ReplySearchChildControllerV2, ({int type, int oid})>((ref, args) {
  final parent = ref.watch(replySearchControllerProvider(args));
  final child = parent.videoController;
  ref.onDispose(child.dispose);
  return child;
});

/// Provider for ReplySearchChildControllerV2 (article type)
final replySearchArticleChildProvider = Provider.family<
    ReplySearchChildControllerV2, ({int type, int oid})>((ref, args) {
  final parent = ref.watch(replySearchControllerProvider(args));
  final child = parent.articleController;
  ref.onDispose(child.dispose);
  return child;
});
