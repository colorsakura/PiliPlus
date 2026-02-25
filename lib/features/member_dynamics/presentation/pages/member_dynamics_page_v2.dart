import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/features/dynamics/presentation/widgets/dynamic_panel.dart';
import 'package:PiliPlus/features/member_dynamics/presentation/providers/member_dynamics_controller.dart';
import 'package:PiliPlus/features/member_dynamics/presentation/providers/member_dynamics_providers.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/waterfall.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:waterfall_flow/waterfall_flow.dart'
    hide SliverWaterfallFlowDelegateWithMaxCrossAxisExtent;

/// Member dynamics page - V2 with Riverpod
class MemberDynamicsPageV2 extends ConsumerStatefulWidget {
  const MemberDynamicsPageV2({super.key, this.mid});

  final int? mid;

  @override
  ConsumerState<MemberDynamicsPageV2> createState() =>
      _MemberDynamicsPageV2State();
}

class _MemberDynamicsPageV2State extends ConsumerState<MemberDynamicsPageV2>
    with DynMixin {
  late final MemberDynamicsController _controller;
  late int mid;

  @override
  void initState() {
    super.initState();
    mid = widget.mid ?? int.parse(Get.parameters['mid']!);
    _controller = ref.read(memberDynamicsControllerProvider(
      MemberDynamicsParams(mid: mid),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context);
    return widget.mid == null
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(title: const Text('我的动态')),
            body: Padding(
              padding: EdgeInsets.only(
                left: padding.left,
                right: padding.right,
              ),
              child: _buildBody(padding),
            ),
          )
        : _buildBody(padding);
  }

  Widget _buildBody(EdgeInsets padding) {
    return refreshIndicator(
      onRefresh: _controller.onRefresh,
      child: CustomScrollView(
        controller: _controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(bottom: padding.bottom + 100),
            sliver: ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                return _buildContent(_controller.loadingState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LoadingState<List<DynamicItemModel>?> loadingState) {
    return switch (loadingState) {
      Loading() => dynSkeleton,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? GlobalData().dynamicsWaterfallFlow
                ? SliverWaterfallFlow(
                    gridDelegate: dynGridDelegate,
                    delegate: SliverChildBuilderDelegate(
                      (_, index) {
                        if (index == response.length - 1) {
                          _controller.onLoadMore();
                        }
                        return DynamicPanel(
                          item: response[index],
                          onRemove: _controller.removeDynamic,
                          onSetTop: _controller.setDynamicTop,
                          maxWidth: maxWidth,
                        );
                      },
                      childCount: response.length,
                    ),
                  )
                : SliverList.builder(
                    itemBuilder: (context, index) {
                      if (index == response.length - 1) {
                        _controller.onLoadMore();
                      }
                      return DynamicPanel(
                        item: response[index],
                        onRemove: _controller.removeDynamic,
                        onSetTop: _controller.setDynamicTop,
                        maxWidth: maxWidth,
                      );
                    },
                    itemCount: response.length,
                  )
            : HttpError(onReload: _controller.onReload),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: _controller.onReload,
      ),
    };
  }
}
