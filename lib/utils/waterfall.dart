import 'dart:math';

import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/shared/skeleton/dynamic_card.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'
    show
        SliverConstraints,
        SliverGridLayout,
        SliverGridRegularTileLayout;
import 'package:waterfall_flow/waterfall_flow.dart'
    show SliverWaterfallFlowDelegate;

mixin DynMixin {
  late double maxWidth;

  late final dynGridDelegate =
      SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: Pref.smallCardWidth * 2,
        crossAxisSpacing: 4,
        afterCalc: (value) => maxWidth = value,
      );

  Widget buildPage(Widget child) {
    if (GlobalData().dynamicsWaterfallFlow) {
      return child;
    }
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.crossAxisExtent;
        final cardWidth = Pref.smallCardWidth * 2;
        final flag = cardWidth < maxWidth;
        this.maxWidth = flag ? cardWidth : maxWidth;
        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: flag ? (maxWidth - cardWidth) / 2 : 0,
          ),
          sliver: child,
        );
      },
    );
  }

  late final skeDelegate = SliverGridDelegateWithExtentAndRatio(
    crossAxisSpacing: 4,
    mainAxisSpacing: 4,
    maxCrossAxisExtent: Pref.smallCardWidth * 2,
    childAspectRatio: StyleString.aspectRatio,
    mainAxisExtent: 50,
  );

  Widget get dynSkeleton {
    if (GlobalData().dynamicsWaterfallFlow) {
      return SliverGrid.builder(
        gridDelegate: skeDelegate,
        itemBuilder: (_, _) => const DynamicCardSkeleton(),
        itemCount: 10,
      );
    }
    return SliverPrototypeExtentList.builder(
      prototypeItem: const DynamicCardSkeleton(),
      itemBuilder: (_, _) => const DynamicCardSkeleton(),
      itemCount: 10,
    );
  }
}

class SliverWaterfallFlowDelegateWithMaxCrossAxisExtent
    extends SliverWaterfallFlowDelegate {
  /// Creates a delegate that makes masonry layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// All of the arguments must not be null. The [maxCrossAxisExtent],
  /// [mainAxisSpacing], and [crossAxisSpacing] arguments must not be negative.
  SliverWaterfallFlowDelegateWithMaxCrossAxisExtent({
    required this.maxCrossAxisExtent,
    super.mainAxisSpacing,
    super.crossAxisSpacing,
    super.lastChildLayoutTypeBuilder,
    super.collectGarbage,
    super.viewportBuilder,
    super.closeToTrailing,
    this.afterCalc,
  }) : assert(maxCrossAxisExtent >= 0);

  /// The maximum extent of tiles in the cross axis.
  ///
  /// This delegate will select a cross-axis extent for the tiles that is as
  /// large as possible subject to the following conditions:
  ///
  ///  - The extent evenly divides the cross-axis extent of the grid.
  ///  - The extent is at most [maxCrossAxisExtent].
  ///
  /// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
  /// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
  /// columns that are 125.0 pixels wide.
  final double maxCrossAxisExtent;

  int? crossAxisCount;
  double? crossAxisExtent;

  final ValueChanged<double>? afterCalc;

  @override
  int getCrossAxisCount(SliverConstraints constraints) {
    final crossAxisExtent = constraints.crossAxisExtent;
    if (crossAxisCount != null && this.crossAxisExtent == crossAxisExtent) {
      return crossAxisCount!;
    }
    this.crossAxisExtent = crossAxisExtent;
    crossAxisCount = (crossAxisExtent / (maxCrossAxisExtent + crossAxisSpacing))
        .ceil();
    afterCalc?.call(
      (crossAxisExtent - ((crossAxisCount! - 1) * crossAxisSpacing)) /
          crossAxisCount!,
    );
    return crossAxisCount!;
  }

  @override
  bool shouldRelayout(SliverWaterfallFlowDelegate oldDelegate) {
    final flag =
        (oldDelegate.runtimeType != runtimeType) ||
        (oldDelegate is SliverWaterfallFlowDelegateWithMaxCrossAxisExtent &&
            (oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
                super.shouldRelayout(oldDelegate)));
    if (flag) {
      crossAxisCount = null;
    }
    return flag;
  }
}

class SliverGridDelegateWithExtentAndRatio extends SliverGridDelegate {
  /// Creates a delegate that makes grid layouts with tiles that have a maximum
  /// cross-axis extent.
  ///
  /// The [maxCrossAxisExtent], [mainAxisExtent], [mainAxisSpacing],
  /// and [crossAxisSpacing] arguments must not be negative.
  /// The [childAspectRatio] argument must be greater than zero.
  SliverGridDelegateWithExtentAndRatio({
    required this.maxCrossAxisExtent,
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
    this.childAspectRatio = 1.0,
    this.mainAxisExtent = 0.0,
    this.minHeight = 0.0,
  }) : assert(maxCrossAxisExtent > 0),
       assert(mainAxisSpacing >= 0),
       assert(crossAxisSpacing >= 0),
       assert(childAspectRatio > 0),
       assert(minHeight >= 0);

  final double minHeight;

  /// The maximum extent of tiles in the cross axis.
  ///
  /// This delegate will select a cross-axis extent for the tiles that is as
  /// large as possible subject to the following conditions:
  ///
  ///  - The extent evenly divides the cross-axis extent of the grid.
  ///  - The extent is at most [maxCrossAxisExtent].
  ///
  /// For example, if the grid is vertical, the grid is 500.0 pixels wide, and
  /// [maxCrossAxisExtent] is 150.0, this delegate will create a grid with 4
  /// columns that are 125.0 pixels wide.
  final double maxCrossAxisExtent;

  /// The number of logical pixels between each child along the main axis.
  final double mainAxisSpacing;

  /// The number of logical pixels between each child along the cross axis.
  final double crossAxisSpacing;

  /// The ratio of the cross-axis to the main-axis extent of each child.
  final double childAspectRatio;

  /// The extent of each tile in the main axis. If provided, it would add
  /// after [childAspectRatio] is used.
  final double mainAxisExtent;

  bool _debugAssertIsValid(double crossAxisExtent) {
    assert(crossAxisExtent > 0.0);
    assert(maxCrossAxisExtent > 0.0);
    assert(mainAxisSpacing >= 0.0);
    assert(crossAxisSpacing >= 0.0);
    assert(childAspectRatio > 0.0);
    return true;
  }

  SliverGridLayout? layoutCache;
  double? crossAxisExtentCache;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    // invoked before each frame
    assert(_debugAssertIsValid(constraints.crossAxisExtent));
    if (layoutCache != null &&
        constraints.crossAxisExtent == crossAxisExtentCache) {
      return layoutCache!;
    }
    crossAxisExtentCache = constraints.crossAxisExtent;
    int crossAxisCount =
        ((constraints.crossAxisExtent - crossAxisSpacing) /
                (maxCrossAxisExtent + crossAxisSpacing))
            .ceil();
    // Ensure a minimum count of 1, can be zero and result in an infinite extent
    // below when the window size is 0.
    crossAxisCount = max(1, crossAxisCount);
    final double usableCrossAxisExtent = max(
      0.0,
      constraints.crossAxisExtent - crossAxisSpacing * (crossAxisCount - 1),
    );
    final double childCrossAxisExtent = usableCrossAxisExtent / crossAxisCount;
    final double childMainAxisExtent = max(
      minHeight,
      childCrossAxisExtent / childAspectRatio + mainAxisExtent,
    );
    return layoutCache = SliverGridRegularTileLayout(
      crossAxisCount: crossAxisCount,
      mainAxisStride: childMainAxisExtent + mainAxisSpacing,
      crossAxisStride: childCrossAxisExtent + crossAxisSpacing,
      childMainAxisExtent: childMainAxisExtent,
      childCrossAxisExtent: childCrossAxisExtent,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(SliverGridDelegateWithExtentAndRatio oldDelegate) {
    final flag =
        oldDelegate.maxCrossAxisExtent != maxCrossAxisExtent ||
        oldDelegate.mainAxisSpacing != mainAxisSpacing ||
        oldDelegate.crossAxisSpacing != crossAxisSpacing ||
        oldDelegate.childAspectRatio != childAspectRatio ||
        oldDelegate.mainAxisExtent != mainAxisExtent;
    if (flag) layoutCache = null;
    return flag;
  }
}
