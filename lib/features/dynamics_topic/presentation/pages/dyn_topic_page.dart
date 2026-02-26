import 'package:PiliPlus/shared/widgets/dynamic_sliver_appbar_medium.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/dynamics_topic/presentation/providers/dyn_topic_controller.dart';
import 'package:PiliPlus/features/dynamics_topic/presentation/providers/dyn_topic_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_feed/item.dart';
import 'package:PiliPlus/models/dynamic/dyn_topic_top/top_details.dart';
import 'package:PiliPlus/features/dynamics/presentation/widgets/dynamic_panel.dart';
import 'package:PiliPlus/utils/num_utils.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:waterfall_flow/waterfall_flow.dart'
    hide SliverWaterfallFlowDelegateWithMaxCrossAxisExtent;

/// Dynamics topic page
class DynTopicPage extends ConsumerStatefulWidget {
  const DynTopicPage({super.key});

  @override
  ConsumerState<DynTopicPage> createState() => _DynTopicPageState();
}

class _DynTopicPageState extends ConsumerState<DynTopicPage> with DynMixin {
  @override
  Widget build(BuildContext context) {
    final params = (
      id: '0', // Will be set by Get.parameters
      name: '',
    );
    final controller = ref.watch(dynTopicControllerProvider(params));

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: refreshIndicator(
        onRefresh: () => controller.onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(controller.state.topState),
            if (controller.state.sortBy > 0) _buildSortBar(controller),
            SliverPadding(
              padding: const EdgeInsets.only(bottom: 100),
              sliver: buildPage(_buildFeedBody(controller.state.feedListState)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(LoadingState<TopDetails?> topState) {
    return switch (topState) {
      Loading() => const SliverAppBar(),
      Success(:final response) when response != null =>
        DynamicSliverAppBarMedium(
          pinned: true,
          title: IgnorePointer(child: Text(response.topicItem?.name ?? '')),
          flexibleSpace: _buildFlexibleSpace(response),
          actions: [
            IconButton(
              onPressed: () {
                // TODO: Implement share
              },
              icon: const Icon(MdiIcons.share),
            ),
          ],
        ),
      _ => SliverAppBar(
        pinned: true,
        title: Text(
          ref
              .read(
                dynTopicControllerProvider((
                  id: '0',
                  name: '',
                )),
              )
              .topicName,
        ),
      ),
    };
  }

  Widget _buildFlexibleSpace(TopDetails response) {
    final theme = Theme.of(context);
    final topicItem = response.topicItem;
    final topicCreator = response.topicCreator;

    if (topicItem == null) return const SizedBox.shrink();

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/topic-header-bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (topicCreator != null) ...[
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(topicCreator.face ?? ''),
                  radius: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  topicCreator.name ?? '',
                  style: const TextStyle(fontSize: 14),
                ),
                const Text(' 发起'),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Text(
            topicItem.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            topicItem.description ?? '',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${NumUtils.numFormat(topicItem.view)}浏览 · ${NumUtils.numFormat(topicItem.discuss)}讨论',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortBar(DynTopicController controller) {
    // TODO: Implement sort bar
    return const SliverToBoxAdapter(
      child: SizedBox(height: 36),
    );
  }

  Widget _buildFeedBody(LoadingState<List<TopicCardItem>?> feedListState) {
    final controller = ref.read(
      dynTopicControllerProvider((
        id: '0',
        name: '',
      )),
    );

    return switch (feedListState) {
      Loading() => dynSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? GlobalData().dynamicsWaterfallFlow
                  ? SliverWaterfallFlow(
                      gridDelegate: dynGridDelegate,
                      delegate: SliverChildBuilderDelegate(
                        (_, index) {
                          if (index == response.length - 1) {
                            controller.queryFeedList(isRefresh: false);
                          }

                          final item = response[index];
                          if (item.dynamicCardItem != null) {
                            return DynamicPanel(
                              item: item.dynamicCardItem!,
                              maxWidth: maxWidth,
                            );
                          }

                          return Text(item.topicType ?? 'err');
                        },
                        childCount: response.length,
                      ),
                    )
                  : SliverList.builder(
                      itemBuilder: (context, index) {
                        if (index == response.length - 1) {
                          controller.queryFeedList(isRefresh: false);
                        }
                        final item = response[index];
                        if (item.dynamicCardItem != null) {
                          return DynamicPanel(
                            item: item.dynamicCardItem!,
                            maxWidth: maxWidth,
                          );
                        } else {
                          return Text(item.topicType ?? 'err');
                        }
                      },
                      itemCount: response.length,
                    )
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: controller.onReload,
      ),
    };
  }
}
