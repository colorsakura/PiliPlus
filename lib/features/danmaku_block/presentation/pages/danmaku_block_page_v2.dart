import 'package:PiliPlus/shared/widgets/button/icon_button.dart';
import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/keep_alive_wrapper.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/models/common/dm_block_type.dart';
import 'package:PiliPlus/models/user/danmaku_block.dart';
import 'package:PiliPlus/models/user/danmaku_rule.dart';
import 'package:PiliPlus/features/danmaku_block/presentation/providers/danmaku_block_controller.dart';
import 'package:PiliPlus/features/danmaku_block/presentation/providers/danmaku_block_providers.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/page_utils.dart';

/// Danmaku block page (v2 - Riverpod)
class DanmakuBlockPageV2 extends ConsumerStatefulWidget {
  const DanmakuBlockPageV2({super.key});

  @override
  ConsumerState<DanmakuBlockPageV2> createState() => _DanmakuBlockPageV2State();
}

class _DanmakuBlockPageV2State extends ConsumerState<DanmakuBlockPageV2>
    with SingleTickerProviderStateMixin {
  late DanmakuBlockController _controller;
  late PlPlayerController plPlayerController;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(danmakuBlockControllerProvider);
    _controller.initTabController(this);
    plPlayerController = Get.arguments as PlPlayerController;
  }

  @override
  void dispose() {
    final ruleFilter = RuleFilter.fromRuleTypeEntries(_controller.state.rules);
    plPlayerController.filters = ruleFilter;
    GStorage.localCache.put(LocalCacheKey.danmakuFilterRules, ruleFilter);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('弹幕屏蔽'),
        bottom: TabBar(
          controller: _controller.tabController,
          tabs: DmBlockType.values
              .map(
                (e) => Tab(
                  text:
                      '${e.label}(${_controller.getRulesForTab(e.index).length})',
                ),
              )
              .toList(),
        ),
      ),
      body: tabBarView(
        controller: _controller.tabController,
        children: DmBlockType.values
            .map(
              (e) => KeepAliveWrapper(
                builder: (context) => tabViewBuilder(
                  e.index,
                  _controller.getRulesForTab(e.index),
                ),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: '添加',
        onPressed: () => _showAddDialog(
          DmBlockType.values[_controller.tabController.index],
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget tabViewBuilder(final int tabIndex, List<SimpleRule> list) {
    if (list.isEmpty) {
      return scrollErrorWidget();
    }
    return ListView.builder(
      itemCount: list.length,
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
      ),
      itemBuilder: (context, itemIndex) {
        final SimpleRule item = list[itemIndex];
        final child = iconButton(
          iconSize: 20,
          tooltip: '删除',
          icon: const Icon(Icons.delete_outlined),
          onPressed: () => showConfirmDialog(
            context: context,
            title: '确定删除该规则？',
            onConfirm: () => _controller.deleteRule(
              tabIndex,
              itemIndex,
              item.id,
            ),
          ),
        );
        return ListTile(
          title: Text(
            item.filter,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          trailing: tabIndex == 2
              ? child
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconButton(
                      iconSize: 20,
                      tooltip: '编辑',
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showAddDialog(
                        DmBlockType.values[_controller.tabController.index],
                        initFilter: item.filter,
                        itemIndex: itemIndex,
                        itemId: item.id,
                      ),
                    ),
                    child,
                  ],
                ),
        );
      },
    );
  }

  void _showAddDialog(
    DmBlockType type, {
    String initFilter = '',
    int? itemIndex,
    int? itemId,
  }) {
    assert((itemIndex == null) == (itemId == null));
    String filter = initFilter;
    final hintText = switch (type) {
      DmBlockType.keyword => '输入过滤的关键词，其它类别请切换标签页后添加',
      DmBlockType.regex => '输入//之间的正则表达式，无需包含头尾的"/"',
      DmBlockType.uid => '输入用户UID',
    };
    final isUid = type == DmBlockType.uid;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${itemId != null ? "编辑" : "添加新的"}${type.label}规则'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(hintText),
            TextFormField(
              autofocus: true,
              initialValue: filter,
              onChanged: (value) => filter = value,
              keyboardType: isUid ? TextInputType.number : null,
              inputFormatters: isUid
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(
              '取消',
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          TextButton(
            child: const Text('确定'),
            onPressed: () async {
              if (filter != initFilter) {
                PageUtils.pop();
                if (itemId != null) {
                  await _controller.deleteRule(
                    type.index,
                    itemIndex!,
                    itemId,
                  );
                }
                await _controller.addRule(
                  filter: filter,
                  type: type.index,
                );
                if (mounted) {
                  SmartDialog.showToast('添加成功');
                }
              } else {
                SmartDialog.showToast(
                  '输入内容${filter.isEmpty ? "不能为空" : "与上次相同"}',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
