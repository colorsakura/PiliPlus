import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:PiliPlus/features/subscription_detail/presentation/pages/subscription_detail_page_v2.dart';
import 'package:PiliPlus/models/sub/sub/list.dart';
import 'package:get/get.dart';

// Adapter to use Riverpod page with GetX routing
import 'package:PiliPlus/utils/page_utils.dart';
class SubDetailPage extends StatelessWidget {
  const SubDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final id = int.tryParse(Get.parameters['id'] ?? '') ?? 0;
    final heroTag = Get.parameters['heroTag'];
    // subInfo would need to be passed via Get.arguments if needed
    return SubscriptionDetailPageV2(
      id: id,
      heroTag: heroTag,
    );
  }

  static void toSubDetailPage(
    int id, {
    String? heroTag,
    SubItemModel? subInfo,
  }) {
    PageUtils.pushNamed(AppRoutes.subDetail, parameters: {
        'id': id.toString(),
        if (heroTag != null) 'heroTag': heroTag,
      },
    );
  }
}
