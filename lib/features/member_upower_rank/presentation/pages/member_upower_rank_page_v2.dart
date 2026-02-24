import 'package:PiliPlus/common/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/common/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/common/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/common/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/common/widgets/scroll_physics.dart';
import 'package:PiliPlus/features/member_upower_rank/presentation/providers/member_upower_rank_list_provider.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/image_type.dart';
import 'package:PiliPlus/models/upower_rank/rank_info.dart';
import 'package:PiliPlus/utils/extension/widget_ext.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberUpowerRankPage extends ConsumerStatefulWidget {
  const MemberUpowerRankPage({
    super.key,
    required this.upMid,
    this.privilegeType,
  });

  final String upMid;
  final int? privilegeType;

  @override
  ConsumerState<MemberUpowerRankPage> createState() =>
      _MemberUpowerRankPageState();
}

class _MemberUpowerRankPageState extends ConsumerState<MemberUpowerRankPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final controller = ref.watch(
      memberUpowerRankListControllerProvider(
        (
          upMid: widget.upMid,
          privilegeType: widget.privilegeType,
        ),
      ),
    );
    final listState = controller.state.listState;
    final theme = Theme.of(context);
    final padding = MediaQuery.viewPaddingOf(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          controller.state.name == null
              ? '充电排行榜'
              : '${controller.state.name} 充电排行榜${controller.state.memberTotal == 0 ? '' : '(${controller.state.memberTotal})'}',
        ),
      ),
      body: refreshIndicator(
        onRefresh: controller.onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.only(
                left: padding.left,
                right: padding.right,
                bottom: padding.bottom + 100,
              ),
              sliver: _buildBody(theme, listState, controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    LoadingState listState,
    dynamic controller,
  ) {
    return switch (listState) {
      Loading() => const SliverToBoxAdapter(
          child: LoadingWidget(),
        ),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = response[index];
                    return _buildListItem(item, theme);
                  },
                  childCount: response.length,
                ),
              )
            : HttpError(onReload: controller.onReload),
      Error(:final errMsg) => HttpError(
          errMsg: errMsg,
          onReload: controller.onReload,
        ),
    };
  }

  Widget _buildListItem(UpowerRankInfo item, ThemeData theme) {
    return CommonListTile(
      title: Text(
        item.user?.nickname ?? '',
        style: theme.textTheme.titleSmall,
      ),
      leading: item.user?.face != null
          ? NetworkImgLayer(
              type: ImageType.avatar,
              src: item.user!.face!,
            )
          : null,
      trailing: _buildTrailing(item, theme),
      onTap: () {},
    ).marginOnly(bottom: 10);
  }

  Widget _buildTrailing(UpowerRankInfo item, ThemeData theme) {
    final amount = item.amount ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${(amount / 1000).toStringAsFixed(1)}k',
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        if (item.rank != null)
          Text(
            'No.${item.rank}',
            style: theme.textTheme.labelSmall,
          ),
      ],
    );
  }
}
