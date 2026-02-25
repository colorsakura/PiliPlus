import 'package:PiliPlus/shared/widgets/flutter/page/tabs.dart';
import 'package:PiliPlus/shared/widgets/gesture/horizontal_drag_gesture_recognizer.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/shared/widgets/view_safe_area.dart';
import 'package:PiliPlus/features/later/domain/entities/later_view_type.dart';
import 'package:PiliPlus/features/later/presentation/pages/later_child_page.dart';
import 'package:PiliPlus/features/later/presentation/providers/later_controller.dart';
import 'package:flutter/material.dart' hide TabBarView;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 稍后再看页面
class LaterPage extends ConsumerStatefulWidget {
  const LaterPage({super.key});

  @override
  ConsumerState<LaterPage> createState() => _LaterPageState();
}

class _LaterPageState extends ConsumerState<LaterPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: LaterViewType.values.length,
      vsync: this,
    );
    // Note: Initialization is handled automatically by the provider factory
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: _buildAppbar(),
      body: ViewSafeArea(
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: LaterViewType.values.map((item) {
                final count = ref.watch(
                  laterControllerProvider(item).select((state) => state.totalCount),
                );
                return Tab(
                  text: '${item.title}${count > 0 ? '($count)' : ''}',
                );
              }).toList(),
              onTap: (index) {
                if (!_tabController.indexIsChanging) {
                  final viewType = LaterViewType.values[index];
                  final ctr = ref.read(
                    laterControllerNotifierProvider(viewType),
                  );
                  ctr.scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
            Expanded(
              child: TabBarView(
                physics: const CustomTabBarViewScrollPhysics(),
                controller: _tabController,
                horizontalDragGestureRecognizer:
                    CustomHorizontalDragGestureRecognizer.new,
                children: LaterViewType.values
                    .map(
                      (item) => LaterChildPage(
                        viewType: item,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppbar() {
    return AppBar(
      title: const Text('稍后再看'),
      actions: [
        const SizedBox(width: 8),
        _buildClearButton(),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildClearButton() {
    return IconButton(
      icon: const Icon(Icons.delete_outline),
      onPressed: () {
        final viewType = LaterViewType.values[_tabController.index];
        _showClearDialog(viewType);
      },
      tooltip: '清空',
    );
  }

  void _showClearDialog(LaterViewType viewType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空稍后再看'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('清空已失效视频'),
              onTap: () {
                Navigator.pop(context);
                _clearLater(viewType, 1);
              },
            ),
            ListTile(
              title: const Text('清空已看完视频'),
              onTap: () {
                Navigator.pop(context);
                _clearLater(viewType, 2);
              },
            ),
            ListTile(
              title: const Text('清空全部'),
              onTap: () {
                Navigator.pop(context);
                _clearLater(viewType, null);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearLater(LaterViewType viewType, int? cleanType) async {
    final success = await ref
        .read(laterControllerNotifierProvider(viewType))
        .clear(cleanType);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('操作成功')),
      );
    }
  }
}
