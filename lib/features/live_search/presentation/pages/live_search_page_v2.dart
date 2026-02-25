import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart';
import 'package:PiliPlus/common/widgets/view_safe_area.dart';
import 'package:PiliPlus/models/common/live/live_search_type.dart';
import 'package:PiliPlus/features/live_search/presentation/providers/live_search_providers.dart';
import 'package:PiliPlus/features/live_search/presentation/widgets/live_search_child_page_v2.dart';

/// Live Search Page V2 (Riverpod version)
class LiveSearchPageV2 extends ConsumerStatefulWidget {
  const LiveSearchPageV2({super.key});

  @override
  ConsumerState<LiveSearchPageV2> createState() => _LiveSearchPageV2State();
}

class _LiveSearchPageV2State extends ConsumerState<LiveSearchPageV2>
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
    // Get parameters from route
    final args = ModalRoute.of(context)?.settings.arguments;
    final mid = args is Map ? args['mid'] as String? : null;
    final uname = args is Map ? args['uname'] as String? : null;

    final controller = ref.watch(liveSearchControllerProvider(
      (mid: mid, uname: uname),
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
            hintText: '搜索房间或主播',
            visualDensity: VisualDensity.standard,
            border: InputBorder.none,
            suffixIcon: IconButton(
              tooltip: '清空',
              icon: const Icon(Icons.clear, size: 22),
              onPressed: controller.onClear,
            ),
          ),
          onSubmitted: (value) => controller.submit(),
          onChanged: (value) {
            if (value.isEmpty && controller.hasData) {
              // Clear hasData when input is cleared
            }
          },
        ),
      ),
      body: ViewSafeArea(
        child: ListenableBuilder(
          listenable: controller,
          builder: (context, child) {
            return Opacity(
              opacity: controller.hasData ? 1 : 0,
              child: Column(
                children: [
                  TabBar(
                    controller: _tabController,
                    tabs: [
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, child) {
                          return Tab(
                            text:
                                '正在直播 ${controller.counts[0] != -1 ? controller.counts[0] : ''}',
                          );
                        },
                      ),
                      ListenableBuilder(
                        listenable: controller,
                        builder: (context, child) {
                          return Tab(
                            text:
                                '主播 ${controller.counts[1] != -1 ? controller.counts[1] : ''}',
                          );
                        },
                      ),
                    ],
                    onTap: (index) {
                      if (!_tabController.indexIsChanging) {
                        if (index == 0) {
                          controller.roomController.animateToTop();
                        } else {
                          controller.userController.animateToTop();
                        }
                      }
                    },
                  ),
                  Expanded(
                    child: tabBarView(
                      controller: _tabController,
                      children: [
                        LiveSearchChildPageV2(
                          controller: controller.roomController,
                          searchType: LiveSearchType.room,
                        ),
                        LiveSearchChildPageV2(
                          controller: controller.userController,
                          searchType: LiveSearchType.user,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
