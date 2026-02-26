import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/features/member_upower_rank/presentation/providers/member_upower_rank_list_provider.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/upower_rank/rank_info.dart';
import 'package:flutter/material.dart';
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
      memberUpowerRankListControllerProvider(widget.upMid),
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
        child: Center(child: CircularProgressIndicator()),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(
          item.nickname ?? '',
          style: theme.textTheme.titleSmall,
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item.day != null ? '${item.day}天' : '',
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
        ),
      ),
    );
  }
}
