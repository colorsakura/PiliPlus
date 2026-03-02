import 'dart:async';
import 'dart:math';

import 'package:PiliPlus/features/dynamics_select_topic/presentation/providers/topic_search_controller_v2.dart';
import 'package:PiliPlus/features/dynamics_select_topic/presentation/widgets/topic_item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/utils/extension/context_ext.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/shared/widgets/flutter/draggable_sheet/draggable_scrollable_sheet_topic.dart'
    as topic_sheet;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Panel for selecting topics for a dynamic post (V2 - Riverpod)
class SelectTopicPanelV2 extends ConsumerStatefulWidget {
  const SelectTopicPanelV2({
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
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: min(600, context.mediaQueryShortestSide),
      ),
      builder: (context) => topic_sheet.DraggableScrollableSheet(
        expand: false,
        snap: true,
        minChildSize: 0,
        maxChildSize: 1,
        initialChildSize: offset == 0 ? 0.65 : 1,
        initialScrollOffset: offset,
        snapSizes: const [0.65],
        builder: (context, scrollController) => SelectTopicPanelV2(
          scrollController: scrollController,
          onCachePos: onCachePos,
        ),
      ),
    );
  }

  @override
  ConsumerState<SelectTopicPanelV2> createState() => _SelectTopicPanelV2State();
}

class _SelectTopicPanelV2State extends ConsumerState<SelectTopicPanelV2> {
  // UI controllers managed by page layer
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.text = value;
        final topicController = ref.read(topicSearchControllerProvider.notifier);
        topicController.searchTopics(value).whenComplete(
          () => WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.scrollController?.jumpToTop(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(topicSearchControllerProvider);
    final controller = ref.read(topicSearchControllerProvider.notifier);

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
            focusNode: _focusNode,
            controller: _controller,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              visualDensity: VisualDensity.standard,
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
              suffixIcon: _controller.text.isNotEmpty
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
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                        onTap: () {
                          _controller.clear();
                          _onSearchChanged('');
                        },
                      ),
                    )
                  : const SizedBox.shrink(),
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
                if (_focusNode.hasFocus) {
                  _focusNode.unfocus();
                }
              } else if (notification is ScrollEndNotification) {
                widget.onCachePos?.call(notification.metrics.pixels);
              }
              return false;
            },
            child: _buildBody(theme, state.searchResults, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<TopicItem>?> loadingState,
    TopicSearchController controller,
  ) {
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
                  // Load more when reaching the end
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
  }

  Widget _errWidget([String? errMsg]) => scrollErrorWidget(
        errMsg: errMsg,
        controller: widget.scrollController,
        onReload: () =>
            ref.read(topicSearchControllerProvider.notifier).onRefresh(_controller.text),
      );
}
