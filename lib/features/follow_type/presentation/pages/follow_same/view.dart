import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/features/follow_type/presentation/pages/follow_same/controller.dart';
import 'package:PiliPlus/features/follow_type/follow_type.dart';
import 'package:PiliPlus/utils/extension/get_ext.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:PiliPlus/utils/page_utils.dart';

class FollowSamePage extends StatefulWidget {
  const FollowSamePage({super.key});

  @override
  State<FollowSamePage> createState() => _FollowSamePageState();

  static void toFollowSamePage({dynamic mid, String? name}) {
    if (mid == null) return;
    PageUtils.pushNamed(AppRoutes.sameFollowing, extra: {
        'mid': Utils.safeToInt(mid),
        'name': name,
      },
    );
  }
}

class _FollowSamePageState extends FollowTypePageState<FollowSamePage> {
  @override
  final controller = Get.putOrFind(
    FollowSameController.new,
    tag: Get.arguments?['mid']?.toString() ?? Utils.generateRandomString(8),
  );

  @override
  PreferredSizeWidget get appBar => AppBar(
    title: Obx(
      () {
        final name = controller.name.value;
        return Text('${name == null ? '' : '我与$name的'}共同关注');
      },
    ),
  );
}
