import 'dart:async';
import 'dart:math';

import 'package:PiliPlus/shared/widgets/flutter/draggable_sheet/draggable_scrollable_sheet_topic.dart'
    as topic_sheet;
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/features/dynamics_select_topic/presentation/providers/topic_search_controller.dart';
import 'package:PiliPlus/features/dynamics_select_topic/presentation/providers/topic_search_providers.dart';
import 'package:PiliPlus/features/dynamics_select_topic/presentation/widgets/topic_item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';
import 'package:PiliPlus/utils/extension/context_ext.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/mixins/debounce_stream_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/page_utils.dart';

/// Panel for selecting topics for a dynamic post
class SelectTopicPanel extends StatefulWidget {
  const SelectTopicPanel({
    super.key,
    this.scrollController,
    this.onCachePos,
  });

  final ScrollController? scrollController;
  final ValueChanged<double>? onCachePos;

  /// Show the topic selection panel as a modal bottom sheet
  ///
  /// [context] - The build context
  /// [offset] - Initial scroll offset (default 0)
  /// [onCachePos] - Callback when scroll position changes
  ///
  /// Returns the selected topic item or null
  static Future<TopicItem?> onSelectTopic(
    BuildContext context, {
    double offset = 0,
    ValueChanged<double>? onCachePos,
  }) {
    return showModalBottomSheet<TopicItem?>(
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
          builder: (context, scrollController) => SelectTopicPanel(
            scrollController: scrollController,
            onCachePos: onCachePos,
          ),
        ),
      ),
    );
  }

  @override
  State<SelectTopicPanel> createState() => _SelectTopicPanelState();
}

class _SelectTopicPanelState
    extends DebounceStreamState<SelectTopicPanel, String> {
  @override
  Duration get duration => const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    // Store controller reference for onValueChanged
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller = ProviderScope.containerOf(
        context,
      ).read(topicSearchControllerProvider);
    });
  }

  TopicSearchController? _controller;

  @override
  void onValueChanged(String value) {
    _controller?.controller.text = value;
    _controller
        ?.searchTopics(value)
        .whenComplete(
          () => WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.scrollController?.jumpToTop(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                focusNode: ref.watch(topicSearchControllerProvider).focusNode,
                controller: ref.watch(topicSearchControllerProvider).controller,
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
                  hintText: '搜索话题',
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
                        topicSearchControllerProvider,
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
                                      .read(topicSearchControllerProvider)
                                      .searchTopics()
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
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is UserScrollNotification) {
                    final controller = ref.watch(topicSearchControllerProvider);
                    if (controller.focusNode.hasFocus) {
                      controller.focusNode.unfocus();
                    }
                  } else if (notification is ScrollEndNotification) {
                    widget.onCachePos?.call(notification.metrics.pixels);
                  }
                  return false;
                },
                child: Consumer(
                  builder: (context, ref, _) {
                    final controllerState = ref.watch(
                      topicSearchControllerProvider,
                    );
                    return _buildBody(
                      theme,
                      controllerState.state.searchResults,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<TopicItem>?> loadingState,
  ) {
    return Consumer(
      builder: (context, ref, _) {
        final controller = ref.read(topicSearchControllerProvider);
        return switch (loadingState) {
          Loading() => loadingWidget,
          Success<List<TopicItem>?>(:final response) =>
            response != null && response.isNotEmpty
                ? ListView.builder(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
                    ),
                    controller: widget.scrollController,
                    itemBuilder: (context, index) {
                      if (index == response.length - 1) {
                        controller.loadMore();
                      }
                      return TopicItemWidget(
                        item: response[index],
                        onTap: (item) => PageUtils.pop(item),
                      );
                    },
                    itemCount: response.length,
                  )
                : _errWidget(),
          Error(:final errMsg) => _errWidget(errMsg),
        };
      },
    );
  }

  Widget _errWidget([String? errMsg]) => scrollErrorWidget(
    errMsg: errMsg,
    controller: widget.scrollController,
    onReload: () => _controller?.onRefresh(),
  );
}
