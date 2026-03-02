import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/features/dynamics_select_topic/dynamics_select_topic.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/presentation/providers/dyn_topic_rcmd_controller_v2.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/topic_item.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dynamics topic recommendation page
class DynTopicRcmdPage extends ConsumerWidget {
  const DynTopicRcmdPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dynTopicRcmdControllerProvider);
    final controller = ref.read(dynTopicRcmdControllerProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('话题')),
      body: refreshIndicator(
        onRefresh: () => controller.onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: _buildBody(state.topicListState, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    LoadingState<List<TopicItem>?> loadingState,
    DynTopicRcmdController controller,
  ) {
    return switch (loadingState) {
      Loading() => linearLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.builder(
                itemCount: response.length,
                itemBuilder: (context, index) {
                  return TopicItemWidget(
                    item: response[index],
                    onTap: (item) => PageUtils.pushNamed(
                      AppRoutes.dynTopic,
                      parameters: {
                        'id': item.id.toString(),
                        'name': item.name,
                      },
                    ),
                  );
                },
              )
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
