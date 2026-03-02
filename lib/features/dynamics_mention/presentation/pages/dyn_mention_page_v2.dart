import 'dart:async';
import 'dart:math';

import 'package:PiliPlus/features/dynamics_mention/presentation/providers/dyn_mention_controller_v2.dart';
import 'package:PiliPlus/features/dynamics_mention/presentation/widgets/dyn_mention_item.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/group.dart';
import 'package:PiliPlus/models/dynamic/dyn_mention/item.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/utils/extension/context_ext.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/shared/widgets/custom_sliver_persistent_header_delegate.dart';
import 'package:PiliPlus/shared/widgets/flutter/draggable_sheet/draggable_scrollable_sheet_topic.dart'
    as topic_sheet;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Panel for selecting users to mention in a dynamic post (V2 - Riverpod)
class DynMentionPanelV2 extends ConsumerStatefulWidget {
  const DynMentionPanelV2({
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
        builder: (context, scrollController) => DynMentionPanelV2(
          scrollController: scrollController,
          onCachePos: onCachePos,
        ),
      ),
    );
  }

  @override
  ConsumerState<DynMentionPanelV2> createState() => _DynMentionPanelV2State();
}

class _DynMentionPanelV2State extends ConsumerState<DynMentionPanelV2> {
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
        final mentionController =
            ref.read(dynMentionControllerProvider.notifier);
        mentionController.searchMentions(value).whenComplete(
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
    final state = ref.watch(dynMentionControllerProvider);
    final controller = ref.read(dynMentionControllerProvider.notifier);

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
              hintText: '搜索用户',
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
        if (state.showConfirmButton)
          SafeArea(
            top: false,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: max(16, MediaQuery.viewPaddingOf(context).bottom),
                top: 8,
              ),
              child: FilledButton(
                onPressed: () => PageUtils.pop(state.selectedMentions),
                child: const Text('确定'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState<List<MentionGroup>?> loadingState,
    DynMentionController controller,
  ) {
    return switch (loadingState) {
      Loading() => loadingWidget,
      Success<List<MentionGroup>?>(:final response) =>
        response != null && response.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
                ),
                controller: widget.scrollController,
                itemBuilder: (context, index) {
                  final group = response[index];
                  final items = group.items ?? [];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          16,
                          10,
                          16,
                          4,
                        ),
                        child: Text(
                          group.groupName ?? '',
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                      ...items.map<Widget>((user) {
                        final isSelected =
                            controller.selectedMentions?.contains(user) == true;
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (value) {
                            controller.toggleMention(user, value);
                          },
                          title: Text(user.name ?? ''),
                          subtitle: user.fans != null
                              ? Text('${user.fans}粉丝')
                              : null,
                          secondary: user.face != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user.face!),
                                )
                              : null,
                        );
                      }),
                    ],
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
        onReload: () => ref.read(dynMentionControllerProvider.notifier).onRefresh(_controller.text),
      );
}
