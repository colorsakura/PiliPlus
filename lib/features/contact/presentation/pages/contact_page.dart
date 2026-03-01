import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/features/fan/fan.dart';
import 'package:PiliPlus/features/follow/presentation/pages/child/child_view.dart';
import 'package:PiliPlus/features/follow_search/follow_search.dart';
import 'package:PiliPlus/features/share/share.dart' show UserModel;
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/features/contact/presentation/providers/contact_controller.dart';

/// 联系人页面
///
/// 显示关注和粉丝列表,支持用户选择
class ContactPage extends ConsumerStatefulWidget {
  const ContactPage({super.key, this.isFromSelect = true});

  final bool isFromSelect;

  @override
  ConsumerState<ContactPage> createState() => _ContactPageState();

  /// 导航到联系人页面
  static void toContactPage({bool isFromSelect = true}) => PageUtils.toDupNamed(
    '/contact',
    parameters: {'isFromSelect': isFromSelect.toString()},
  );
}

class _ContactPageState extends ConsumerState<ContactPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);

    // Initialize controller with current user ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(contactControllerProvider.notifier)
          .initConfig(
            isFromSelect: widget.isFromSelect,
            userId: Accounts.main.mid,
          );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSelect(UserModel userModel) {
    final result = ref
        .read(contactControllerProvider.notifier)
        .onSelect(userModel);
    if (result != null) {
      PageUtils.pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(contactControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('通讯录'),
        bottom: TabBar(
          controller: _controller,
          tabs: const [
            Tab(text: '我的关注'),
            Tab(text: '我的粉丝'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final UserModel? userModel = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => FollowSearchPageV2(
                    mid: config.userId,
                    isFromSelect: config.isFromSelect,
                  ),
                ),
              );
              if (userModel != null) {
                _handleSelect(userModel);
              }
            },
            icon: const Icon(Icons.search),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: tabBarView(
        controller: _controller,
        children: [
          FollowChildPage(
            mid: config.userId,
            onSelect: config.isFromSelect ? _handleSelect : null,
          ),
          FanPageV2(
            showName: false,
            onSelect: config.isFromSelect ? _handleSelect : null,
          ),
        ],
      ),
    );
  }
}
