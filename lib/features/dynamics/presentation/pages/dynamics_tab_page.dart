import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/core/constants/constants.dart' show StyleString;
import 'package:PiliPlus/features/dynamics/domain/entities/dynamic_item.dart';
import 'package:PiliPlus/features/dynamics/presentation/widgets/dynamic_panel_widget.dart';
import 'package:PiliPlus/features/dynamics_tab/presentation/pages/dynamics_tab_controller.dart'
    show DynamicsTabController;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/shared/skeleton/dynamic_card.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart' as waterfall_flow;
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';

/// Grid delegate for dynamics waterfall flow.
final dynGridDelegate =
    waterfall_flow.SliverWaterfallFlowDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: Pref.smallCardWidth * 2,
      crossAxisSpacing: 4,
    );

/// Tab page for displaying dynamics of a specific type.
///
/// This uses the existing GetX controller wrapped in Riverpod for compatibility.
/// TODO: Migrate controller to pure Riverpod implementation
class DynamicsTabPage extends ConsumerStatefulWidget {
  const DynamicsTabPage({
    super.key,
    required this.dynamicsType,
  });

  final DynamicsTabType dynamicsType;

  @override
  ConsumerState<DynamicsTabPage> createState() => _DynamicsTabPageState();
}

class _DynamicsTabPageState extends ConsumerState<DynamicsTabPage>
    with AutomaticKeepAliveClientMixin {
  late final DynamicsTabController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      DynamicsTabController(dynamicsType: widget.dynamicsType),
      tag: widget.dynamicsType.name,
    );
  }

  @override
  void dispose() {
    // Don't delete the controller as it's managed by GetX
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final useWaterfall = GlobalData().dynamicsWaterfallFlow;

    return refreshIndicator(
      onRefresh: () => _controller.onRefresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _controller.scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: _buildBody(useWaterfall),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool useWaterfall) {
    // Use the existing GetX controller
    return Obx(
      () => _buildBodyState(_controller.loadingState.value, useWaterfall),
    );
  }

  Widget _buildBodyState(
    LoadingState<List<DynamicItemModel>?> loadingState,
    bool useWaterfall,
  ) {
    if (loadingState is Loading) {
      return SliverGrid.builder(
        gridDelegate: SliverGridDelegateWithExtentAndRatio(
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
          maxCrossAxisExtent: Pref.smallCardWidth * 2,
          childAspectRatio: (16 / 9),
          mainAxisExtent: 50,
        ),
        itemBuilder: (_, _) => const DynamicCardSkeleton(),
        itemCount: 10,
      );
    }

    if (loadingState is Success<List<DynamicItemModel?>>) {
      final dynamicsList = loadingState.data;

      if (dynamicsList == null || dynamicsList.isEmpty) {
        return HttpError(onReload: () => _controller.onReload());
      }

      if (useWaterfall) {
        return waterfall_flow.SliverWaterfallFlow(
          gridDelegate: dynGridDelegate,
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == dynamicsList.length - 1) {
                _controller.onLoadMore();
              }
              final item = dynamicsList[index];
              return DynamicPanelWidget(
                item: DynamicItemEntity(model: item),
                maxWidth: 800,
              );
            },
            childCount: dynamicsList.length,
          ),
        );
      }

      return SliverList.builder(
        itemBuilder: (context, index) {
          if (index == dynamicsList.length - 1) {
            _controller.onLoadMore();
          }
          final item = dynamicsList[index];
          return DynamicPanelWidget(
            item: DynamicItemEntity(model: item),
            maxWidth: 800,
          );
        },
        itemCount: dynamicsList.length,
      );
    }

    return HttpError(onReload: () => _controller.onReload());
  }
}
