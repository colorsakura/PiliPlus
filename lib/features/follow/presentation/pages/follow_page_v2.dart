import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/shared/widgets/view_safe_area.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/member/tags.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/features/follow/presentation/pages/child/child_view.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:PiliPlus/features/follow/presentation/providers/follow_controller.dart';
import 'package:PiliPlus/features/follow/presentation/providers/follow_state.dart';
import 'package:PiliPlus/features/follow/presentation/providers/follow_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show LengthLimitingTextInputFormatter;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

/// Follow page (Clean Architecture with Riverpod)
///
/// Note: This page uses Riverpod for the main FollowController but
/// still uses GetX for FollowChildController. Full migration pending
/// child controller migration.
class FollowPageV2 extends ConsumerStatefulWidget {
  const FollowPageV2({
    super.key,
    required this.mid,
    this.isOwner = false,
    this.userName,
  });

  final int mid;
  final bool isOwner;
  final String? userName;

  @override
  ConsumerState<FollowPageV2> createState() => _FollowPageV2State();

  /// Navigate to follow page
  static void toFollowPage({
    required dynamic mid,
    String? name,
    bool isOwner = false,
  }) {
    final midInt = mid is int
        ? mid
        : (mid != null ? int.tryParse(mid.toString()) : null);
    if (midInt == null) return;
    PageUtils.toDupNamed(
      '/follow',
      arguments: {
        'mid': midInt,
        'name': name,
        'isOwner': isOwner,
      },
    );
  }
}

class _FollowPageV2State extends ConsumerState<FollowPageV2>
    with SingleTickerProviderStateMixin {
  late final FollowController _controller;
  TabController? _tabController;
  final _tag = Utils.generateRandomString(8);

  @override
  void initState() {
    super.initState();
    _controller = ref.read(
      followControllerProvider(
        FollowParams(
          mid: widget.mid,
          isOwner: widget.isOwner,
          userName: widget.userName,
        ),
      ),
    );

    // Initialize TabController when tabs are loaded
    _controller.addListener(() {
      final tabs = _controller.tabs;
      if (tabs != null && tabs.isNotEmpty && _tabController == null) {
        if (mounted) {
          setState(() {
            _tabController = TabController(
              length: tabs.length,
              vsync: this,
            );
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  bool _isCustomTag(int? tagid) {
    return tagid != null && tagid != 0 && tagid != -10 && tagid != -2;
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: widget.isOwner
            ? const Text('我的关注')
            : Text('${state.userName ?? ''}的关注'),
        actions: widget.isOwner
            ? [
                IconButton(
                  onPressed: _onCreateTag,
                  icon: const Icon(Icons.add),
                  tooltip: '新建分组',
                ),
                IconButton(
                  onPressed: () {
                    // Note: Still using GetX navigation for compatibility
                  },
                  icon: const Icon(Icons.search_outlined),
                  tooltip: '搜索',
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      onTap: () {
                        // Note: Still using GetX navigation for compatibility
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.block, size: 19),
                          SizedBox(width: 10),
                          Text('黑名单管理'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
              ]
            : null,
      ),
      body: widget.isOwner ? _buildBody(state) : _childPage(),
    );
  }

  Widget _buildBody(FollowState state) {
    return switch (state.tabsState) {
      Loading() => loadingWidget,
      Success() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ViewSafeArea(
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              tabs: (_controller.tabs ?? []).map((item) {
                final isCustom = _isCustomTag(item.tagid);
                return Tab(
                  child: isCustom
                      ? GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onLongPress: () {
                            Feedback.forLongPress(context);
                            _onHandleTag(item);
                          },
                          onSecondaryTap: PlatformUtils.isMobile
                              ? null
                              : () => _onHandleTag(item),
                          child: Row(
                            children: [
                              Text(
                                '${item.name}${item.count != null ? '(${item.count})' : ''} ',
                              ),
                              const Icon(Icons.menu, size: 18),
                            ],
                          ),
                        )
                      : Text(
                          '${item.name}${item.count != null ? '(${item.count})' : ''}',
                        ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: tabBarView(
              controller: _tabController,
              children: (_controller.tabs ?? []).map(_childPage).toList(),
            ),
          ),
        ],
      ),
      Error(:final errMsg) => Center(child: Text(errMsg ?? '加载失败')),
    };
  }

  Widget _childPage([MemberTagItemModel? item]) {
    // Note: Still using GetX FollowChildController for now
    return FollowChildPage(
      tag: _tag,
      mid: widget.mid,
      tagid: item?.tagid,
    );
  }

  void _onCreateTag() {
    String tagName = '';
    showConfirmDialog(
      context: context,
      title: '新建分组',
      content: TextFormField(
        autofocus: true,
        onChanged: (value) => tagName = value,
        inputFormatters: [
          LengthLimitingTextInputFormatter(16),
        ],
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: '请输入分组名称',
        ),
      ),
      onConfirm: () async {
        if (tagName.isEmpty) return;
        final success = await _controller.createTag(tagName);
        if (success && mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  void _onHandleTag(MemberTagItemModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        clipBehavior: Clip.hardEdge,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              onTap: () {
                Navigator.pop(context);
                String tagName = item.name!;
                showConfirmDialog(
                  context: context,
                  title: '编辑分组名称',
                  content: TextFormField(
                    autofocus: true,
                    initialValue: tagName,
                    onChanged: (value) => tagName = value,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(16),
                    ],
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onConfirm: () async {
                    final success = await _controller.updateTag(item, tagName);
                    if (success) {
                      if (mounted) Navigator.pop(context);
                    }
                  },
                );
              },
              leading: const Icon(Icons.edit),
              title: const Text('修改分组名称'),
            ),
            ListTile(
              onTap: () {
                Navigator.pop(context);
                showConfirmDialog(
                  context: context,
                  title: '确认删除该分组吗？',
                  onConfirm: () async {
                    final success = await _controller.deleteTag(item.tagid!);
                    if (success) {
                      if (mounted) Navigator.pop(context);
                    }
                  },
                );
              },
              leading: const Icon(Icons.delete_outline),
              title: const Text('删除分组'),
            ),
          ],
        ),
      ),
    );
  }
}
