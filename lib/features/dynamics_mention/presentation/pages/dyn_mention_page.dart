import 'dart:async';
import 'dart:math';

import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/shared/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:PiliPlus/shared/widgets/flutter/draggable_sheet/draggable_scrollable_sheet_topic.dart'
    as topic_sheet;
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/features/dynamics_mention/presentation/providers/dyn_mention_controller.dart';
import 'package:PiliPlus/features/dynamics_mention/presentation/providers/dyn_mention_providers.dart';
import 'package:PiliPlus/features/dynamics_mention/presentation/widgets/dyn_mention_item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/group.dart';
import 'package:PiliPlus/utils/extension/context_ext.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/mixins/debounce_stream_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// Panel for selecting users to mention in a dynamic post
class DynMentionPanel extends StatefulWidget {
  const DynMentionPanel({
    super.key,
    this.scrollController,
    this.onCachePos,
  });

  final ScrollController? scrollController;
  final ValueChanged<double>? onCachePos;

  /// Show the mention panel as a modal bottom sheet
  ///
  /// [context] - The build context
  /// [offset] - Initial scroll offset (default 0)
  /// [onCachePos] - Callback when scroll position changes
  ///
  /// Returns the selected mention item or set of mention items
  static Future onDynMention(
    BuildContext context, {
    double offset = 0,
    ValueChanged<double>? onCachePos,
  }) {
    return showModalBottomSheet(
      context: Get.context!,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: min(600, context.mediaQueryShortestSide),
      ),
      builder: (context) => ProviderScope(
        child: topic_sheet.DraggableScrollableSheet(
          expand: false,
          snap: true,
          minChildSize: 0,
          maxChildSize: 1,
          initialChildSize: offset == 0 ? 0.65 : 1,
          initialScrollOffset: offset,
          snapSizes: const [0.65],
          builder: (context, scrollController) => DynMentionPanel(
            scrollController: scrollController,
            onCachePos: onCachePos,
          ),
        ),
      ),
    );
  }

  @override
  State<DynMentionPanel> createState() => _DynMentionPanelState();
}

class _DynMentionPanelState
    extends DebounceStreamState<DynMentionPanel, String> {
  @override
  Duration get duration => const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    // Store controller reference for onValueChanged
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller = ProviderScope.containerOf(
        context,
      ).read(dynMentionControllerProvider);
    });
  }

  DynMentionController? _controller;

  @override
  void onValueChanged(String value) {
    _controller?.controller.text = value;
    _controller
        ?.searchMentions(value)
        .whenComplete(
          () => WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.scrollController?.jumpToTop(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final padding = MediaQuery.paddingOf(context).bottom;
    final viewInset = MediaQuery.viewInsetsOf(context).bottom;
    return Consumer(
      builder: (context, ref, _) {
        return Column(
          children: [
            SizedBox(
              height: 35,
              child: Center(
                child: Container(
                  width: 32,
                  height: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outline,
                    borderRadius: const BorderRadius.all(Radius.circular(3)),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 5),
              child: TextField(
                focusNode: ref.watch(dynMentionControllerProvider).focusNode,
                controller: ref.watch(dynMentionControllerProvider).controller,
                onChanged: ctr!.add,
                decoration: InputDecoration(
                  visualDensity: .standard,
                  border: const OutlineInputBorder(
                    gapPadding: 0,
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(25)),
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: theme.colorScheme.onInverseSurface,
                  hintText: '输入你想@的人',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Icon(Icons.search, size: 20),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  suffixIcon: Consumer(
                    builder: (context, ref, _) {
                      final controllerState = ref.watch(
                        dynMentionControllerProvider,
                      );
                      final controller = controllerState.controller;
                      final enableClear = controller.text.isNotEmpty;
                      return enableClear
                          ? Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                child: Container(
                                  padding: const EdgeInsetsDirectional.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: theme.colorScheme.secondaryContainer,
                                  ),
                                  child: Icon(
                                    Icons.clear,
                                    size: 16,
                                    color:
                                        theme.colorScheme.onSecondaryContainer,
                                  ),
                                ),
                                onTap: () {
                                  controller.clear();
                                  ctr!.add('');
                                  ref
                                      .read(dynMentionControllerProvider)
                                      .searchMentions()
                                      .whenComplete(
                                        () => WidgetsBinding.instance
                                            .addPostFrameCallback(
                                              (_) => widget.scrollController
                                                  ?.jumpToTop(),
                                            ),
                                      );
                                },
                              ),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minHeight: 0,
                    minWidth: 0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is UserScrollNotification) {
                        final controller = ref.watch(
                          dynMentionControllerProvider,
                        );
                        if (controller.focusNode.hasFocus) {
                          controller.focusNode.unfocus();
                        }
                      } else if (notification is ScrollEndNotification) {
                        widget.onCachePos?.call(notification.metrics.pixels);
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      controller: widget.scrollController,
                      slivers: [
                        Consumer(
                          builder: (context, ref, _) {
                            final controllerState = ref.watch(
                              dynMentionControllerProvider,
                            );
                            return _buildBody(
                              theme,
                              controllerState.state.searchResults,
                            );
                          },
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(height: padding + viewInset + 100),
                        ),
                      ],
                    ),
                  ),
                  Consumer(
                    builder: (context, ref, _) {
                      final controllerState = ref.watch(
                        dynMentionControllerProvider,
                      );
                      final showBtn = controllerState.state.showConfirmButton;
                      return Positioned(
                        right: kFloatingActionButtonMargin,
                        bottom:
                            padding +
                            kFloatingActionButtonMargin +
                            (showBtn ? viewInset : 0),
                        child: AnimatedSlide(
                          offset: showBtn ? Offset.zero : const Offset(0, 3),
                          duration: const Duration(milliseconds: 120),
                          child: FloatingActionButton(
                            onPressed: () {
                              final controller = ref.read(
                                dynMentionControllerProvider,
                              );
                              if (controller.state.selectedMentions?.isEmpty ??
                                  true) {
                                controller.clearSelection();
                                return;
                              }
                              PageUtils.pop(controller.state.selectedMentions);
                              controller.clearSelection();
                            },
                            child: const Icon(Icons.check),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<MentionGroup>?> loadingState,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.read(dynMentionControllerProvider);
        return switch (loadingState) {
          Loading() => SliverPadding(
            padding: const EdgeInsets.only(top: 8),
            sliver: linearLoading,
          ),
          Success<List<MentionGroup>?>(:final response) =>
            response != null && response.isNotEmpty
                ? SliverMainAxisGroup(
                    slivers: response.map((group) {
                      if (group.items.isNullOrEmpty) {
                        return const SliverToBoxAdapter();
                      }
                      return SliverMainAxisGroup(
                        slivers: [
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: CustomSliverPersistentHeaderDelegate(
                              extent: 40,
                              needRebuild: true,
                              bgColor: theme.colorScheme.surface,
                              child: Container(
                                height: 40,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Text(group.groupName!),
                              ),
                            ),
                          ),
                          SliverList.builder(
                            itemCount: group.items!.length,
                            itemBuilder: (context, index) {
                              final item = group.items![index];
                              return DynMentionItem(
                                item: item,
                                onTap: () => PageUtils.pop(item),
                                onCheck: (value) =>
                                    controller.toggleMention(item, value),
                              );
                            },
                          ),
                        ],
                      );
                    }).toList(),
                  )
                : HttpError(onReload: controller.onRefresh),
          Error(:final errMsg) => HttpError(
            errMsg: errMsg,
            onReload: controller.onRefresh,
          ),
        };
      },
    );
  }
}
