import 'package:PiliPlus/features/video/presentation/providers/video_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Migration Example: Video Height Calculation
///
/// This demonstrates migrating a multi-field Obx() to Riverpod ref.watch()
///
/// BEFORE: Uses videoDetailController.isExpanding and isCollapsing
/// AFTER: Watches full state with ref.watch()
class VideoHeightWidget extends ConsumerWidget {
  const VideoHeightWidget({
    required this.minVideoHeight,
    required this.maxVideoHeight,
    required this.animationValue,
    super.key,
  });

  final double minVideoHeight;
  final double maxVideoHeight;
  final double animationValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Multi-field Obx() → ref.watch()
    //
    // BEFORE (GetX):
    //   Obx(() {
    //     final isExpanding = videoDetailController.isExpanding;
    //     if (isExpanding) {
    //       return calculateExpandingHeight();
    //     } else {
    //       final isCollapsing = videoDetailController.isCollapsing;
    //       return calculateCollapsingHeight();
    //     }
    //   })
    //
    // AFTER (Riverpod):
    //   - Watch full state for multiple fields
    //   - Or use .select() if only specific fields needed
    //   - Both isExpanding and isCollapsing are auto-synced

    // Option 1: Watch specific fields (more performant)
    final isExpanding = ref.watch(
      videoDetailProvider.select((s) => s.isExpanding)
    );
    final isCollapsing = ref.watch(
      videoDetailProvider.select((s) => s.isCollapsing)
    );

    // Option 2: Watch full state (simpler for complex widgets)
    // final state = ref.watch(videoDetailProvider);
    // final isExpanding = state.isExpanding;
    // final isCollapsing = state.isCollapsing;

    // Calculate height based on animation state
    double height;
    if (isExpanding) {
      height = (maxVideoHeight * animationValue).clamp(minVideoHeight, maxVideoHeight);
    } else if (isCollapsing) {
      height = (maxVideoHeight -
          (maxVideoHeight - minVideoHeight) * animationValue
      ).clamp(minVideoHeight, maxVideoHeight);
    } else {
      height = minVideoHeight;
    }

    return SizedBox(
      height: height,
      child: const Placeholder(),
    );
  }
}
