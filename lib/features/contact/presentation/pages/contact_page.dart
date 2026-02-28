import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/features/fan/fan.dart';
import 'package:PiliPlus/features/follow/presentation/pages/child/child_view.dart';
import 'package:PiliPlus/features/follow_search/follow_search.dart';
import 'package:PiliPlus/features/share/share.dart' show UserModel;
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 联系人页面
///
/// 显示关注和粉丝列表,支持用户选择
class ContactPage extends StatefulWidget {
  const ContactPage({super.key, this.isFromSelect = true});

  final bool isFromSelect;

  @override
  State<ContactPage> createState() => _ContactPageState();

  /// 导航到联系人页面
  static void toContactPage({bool isFromSelect = true}) => PageUtils.toDupNamed(
    '/contact',
    parameters: {'isFromSelect': isFromSelect.toString()},
  );
}

class _ContactPageState extends State<ContactPage>
    with SingleTickerProviderStateMixin {
  late final mid = Accounts.main.mid;
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void onSelect(UserModel userModel) {
    Get.back(result: userModel);
  }

  @override
  Widget build(BuildContext context) {
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
                GetPageRoute(
                  page: () => FollowSearchPageV2(
                    mid: mid,
                    isFromSelect: widget.isFromSelect,
                  ),
                ),
              );
              if (userModel != null) {
                Get.back(result: userModel);
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
            mid: mid,
            onSelect: widget.isFromSelect ? onSelect : null,
          ),
          FanPageV2(
            showName: false,
            onSelect: widget.isFromSelect ? onSelect : null,
          ),
        ],
      ),
    );
  }
}
