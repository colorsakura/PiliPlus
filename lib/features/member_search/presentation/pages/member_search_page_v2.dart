import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/shared/widgets/view_safe_area.dart';
import 'package:PiliPlus/models/common/member/search_type.dart';
import 'package:PiliPlus/features/member_search/presentation/providers/member_search_providers.dart';
import 'package:PiliPlus/features/member_search/presentation/widgets/member_search_child_page_v2.dart';

/// Member Search Page V2 (Riverpod version)
class MemberSearchPageV2 extends ConsumerStatefulWidget {
  const MemberSearchPageV2({super.key});

  @override
  ConsumerState<MemberSearchPageV2> createState() => _MemberSearchPageV2State();
}

class _MemberSearchPageV2State extends ConsumerState<MemberSearchPageV2>
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
    // Get mid from route parameters
    final mid = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    final controller = ref.watch(memberSearchControllerProvider(mid));

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
          onChanged: (value) {
            if (value.isEmpty && controller.hasData) {
              // Clear hasData when input is cleared
            }
          },
        ),
      ),
      body: ViewSafeArea(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ListenableBuilder(
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
                                    '视频 ${controller.counts[0] != -1 ? controller.counts[0] : ''}',
                              );
                            },
                          ),
                          ListenableBuilder(
                            listenable: controller,
                            builder: (context, child) {
                              return Tab(
                                text:
                                    '动态 ${controller.counts[1] != -1 ? controller.counts[1] : ''}',
                              );
                            },
                          ),
                        ],
                        onTap: (index) {
                          if (!_tabController.indexIsChanging) {
                            if (index == 0) {
                              controller.archiveController.animateToTop();
                            } else {
                              controller.dynamicController.animateToTop();
                            }
                          }
                        },
                      ),
                      Expanded(
                        child: tabBarView(
                          controller: _tabController,
                          children: [
                            MemberSearchChildPageV2(
                              controller: controller.archiveController,
                              searchType: MemberSearchType.archive,
                            ),
                            MemberSearchChildPageV2(
                              controller: controller.dynamicController,
                              searchType: MemberSearchType.dynamic,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListenableBuilder(
              listenable: controller,
              builder: (context, child) {
                return controller.hasData
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: const Alignment(0, -0.5),
                        child: Text(
                          '搜索「${controller.uname ?? mid}」的动态、视频',
                          textAlign: TextAlign.center,
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
