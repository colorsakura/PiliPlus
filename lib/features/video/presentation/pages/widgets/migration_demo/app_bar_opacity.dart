import 'package:PiliPlus/features/video/presentation/providers/video_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Migration Example: AppBar Opacity
///
/// This demonstrates migrating from GetX Obx() to Riverpod ref.watch()
///
/// BEFORE: Line 703-743 in video_page.dart
/// AFTER: This widget
class AppBarOpacityWidget extends ConsumerWidget {
  const AppBarOpacityWidget({
    required this.isPortrait,
    required this.scrollCtr,
    super.key,
  });

  final bool isPortrait;
  final ScrollController scrollCtr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final platform = Theme.of(context).platform;

    // MIGRATION: Obx() → ref.watch()
    //
    // BEFORE (GetX):
    //   child: Obx(() {
    //     final scrollRatio = videoDetailController.scrollRatio.value;
    //     bool shouldShow = scrollRatio != 0 &&
    //         videoDetailController.scrollCtr.offset != 0 &&
    //         isPortrait;
    //     return Stack(...);
    //   })
    //
    // AFTER (Riverpod):
    //   - scrollRatio is auto-synced via _onScroll() listener
    //   - Use .select() to watch only scrollRatio for better performance
    //   - Other dependencies (scrollCtr.offset, isPortrait) accessed directly

    final scrollRatio = ref.watch(
      videoDetailProvider.select((s) => s.scrollRatio)
    );

    final shouldShow =
        scrollRatio != 0 && scrollCtr.offset != 0 && isPortrait;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 0,
          systemOverlayStyle: platform == TargetPlatform.android
              ? shouldShow
                  ? null
                  : SystemUiOverlayStyle(
                      statusBarIconBrightness: Brightness.light,
                      systemNavigationBarIconBrightness:
                          themeData.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                    )
              : null,
        ),
        if (shouldShow)
          AppBar(
            backgroundColor: themeData.colorScheme.surface
                .withValues(alpha: scrollRatio),
            toolbarHeight: 0,
            systemOverlayStyle: platform == TargetPlatform.android
                ? SystemUiOverlayStyle(
                    statusBarIconBrightness:
                        themeData.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                    systemNavigationBarIconBrightness:
                        themeData.brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                  )
                : null,
          ),
      ],
    );
  }
}
