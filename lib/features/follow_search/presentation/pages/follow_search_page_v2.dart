import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/features/follow/presentation/widgets/follow_item.dart';
import 'package:PiliPlus/features/follow_search/presentation/providers/follow_search_controller.dart';
import 'package:PiliPlus/features/follow_search/presentation/providers/follow_search_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/follow/list.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/page_utils.dart';

/// Follow search page (v2 - Riverpod)
class FollowSearchPageV2 extends ConsumerStatefulWidget {
  const FollowSearchPageV2({
    super.key,
    this.mid,
    this.isFromSelect = false,
  });

  final int? mid;
  final bool isFromSelect;

  @override
  ConsumerState<FollowSearchPageV2> createState() => _FollowSearchPageV2State();
}

class _FollowSearchPageV2State extends ConsumerState<FollowSearchPageV2> {
  late final int mid;
  late final String tag;

  @override
  void initState() {
    super.initState();
    mid = widget.mid ?? Get.arguments?['mid'] ?? 0;
    tag = Utils.generateRandomString(8);

    // Trigger initial search after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(followSearchControllerProvider(mid));
      controller.focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(followSearchControllerProvider(mid));
    final state = controller.state;

    return Scaffold(
      appBar: _buildBar(controller),
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: controller.scrollController,
        slivers: [
          ViewSliverSafeArea(
            sliver: _buildBody(state, controller),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildBar(FollowSearchController controller) {
    return AppBar(
      actions: [
        IconButton(
          tooltip: '搜索',
          onPressed: controller.onRefresh,
          icon: const Icon(Icons.search_outlined, size: 22),
        ),
        const SizedBox(width: 10),
      ],
      title: TextField(
        autofocus: true,
        focusNode: controller.focusNode,
        controller: controller.editController,
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: '搜索',
          visualDensity: VisualDensity.standard,
          border: InputBorder.none,
          suffixIcon: IconButton(
            tooltip: '清空',
            icon: const Icon(Icons.clear, size: 22),
            onPressed: () {
              controller.onClear();
              controller.focusNode.requestFocus();
            },
          ),
        ),
        onSubmitted: (value) => controller.onRefresh(),
      ),
    );
  }

  Widget _buildBody(
    FollowSearchState state,
    FollowSearchController controller,
  ) {
    return switch (state.listState) {
      Loading() => const HttpError(),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? _buildList(response, controller)
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }

  Widget _buildList(
    List<FollowItemModel> list,
    FollowSearchController controller,
  ) {
    return SliverList.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        if (index == list.length - 1) {
          controller.onLoadMore();
        }
        return FollowItem(
          item: list[index],
          onSelect: widget.mid != null && widget.isFromSelect
              ? (userModel) => PageUtils.pop(userModel)
              : null,
        );
      },
    );
  }
}
