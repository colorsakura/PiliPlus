import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/shared/widgets/view_safe_area.dart';
import 'package:PiliPlus/models/common/reply/reply_search_type.dart';
import 'package:PiliPlus/features/reply_search/presentation/providers/reply_search_providers.dart';
import 'package:PiliPlus/features/reply_search/presentation/widgets/reply_search_child_page_v2.dart';

/// Reply Search Page V2 (Riverpod version)
class ReplySearchPageV2 extends ConsumerStatefulWidget {
  const ReplySearchPageV2({
    super.key,
    required this.type,
    required this.oid,
  });

  final int type;
  final int oid;

  @override
  ConsumerState<ReplySearchPageV2> createState() =>
      _ReplySearchPageV2State();
}

class _ReplySearchPageV2State extends ConsumerState<ReplySearchPageV2>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(replySearchControllerProvider(
      (type: widget.type, oid: widget.oid),
    ));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: '搜索',
            onPressed: controller.submit,
            icon: const Icon(Icons.search, size: 22),
          ),
          const SizedBox(width: 10),
        ],
        title: TextField(
          autofocus: true,
          focusNode: controller.focusNode,
          controller: controller.editingController,
          textInputAction: TextInputAction.search,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: '搜索',
            visualDensity: VisualDensity.standard,
            border: InputBorder.none,
            suffixIcon: IconButton(
              tooltip: '清空',
              icon: const Icon(Icons.clear, size: 22),
              onPressed: controller.onClear,
            ),
          ),
          onSubmitted: (value) => controller.submit(),
        ),
      ),
      body: ViewSafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '视频'),
                Tab(text: '专栏'),
              ],
              onTap: (index) {
                if (!_tabController.indexIsChanging) {
                  if (index == 0) {
                    controller.videoController.animateToTop();
                  } else {
                    controller.articleController.animateToTop();
                  }
                }
              },
            ),
            Expanded(
              child: tabBarView(
                controller: _tabController,
                children: [
                  ReplySearchChildPageV2(
                    controller: controller.videoController,
                    searchType: ReplySearchType.video,
                  ),
                  ReplySearchChildPageV2(
                    controller: controller.articleController,
                    searchType: ReplySearchType.article,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
