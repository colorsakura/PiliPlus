import 'package:PiliPlus/features/login_log/presentation/providers/login_log_controller_v2.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_log/list.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/utils/extension/widget_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login log page (v2 - Riverpod)
class LoginLogPageV2 extends ConsumerWidget {
  const LoginLogPageV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginLogControllerProvider);
    final controller = ref.read(loginLogControllerProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('登录记录')),
      body: refreshIndicator(
        onRefresh: () => controller.onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: _buildHeader(colorScheme),
            ),
            ViewSliverSafeArea(
              sliver: _buildBody(colorScheme, state.listState),
            ),
          ],
        ),
      ).constraintWidth(),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    const header = LoginLogItem(
      timeAt: '时间',
      ip: 'IP',
      geo: '地理位置',
    );

    final style = TextStyle(
      fontSize: 13,
      color: colorScheme.outline,
      fontWeight: FontWeight.w500,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(header.timeAt, style: style)),
          Expanded(flex: 2, child: Text(header.ip, style: style)),
          Expanded(flex: 3, child: Text(header.geo, style: style)),
        ],
      ),
    );
  }

  Widget _buildBody(
    ColorScheme colorScheme,
    LoadingState<List<LoginLogItem>?> listState,
  ) {
    late final divider = Divider(
      height: 1,
      color: colorScheme.outline.withValues(alpha: 0.1),
    );

    return switch (listState) {
      Loading() => const SliverToBoxAdapter(),
      Success<List<LoginLogItem>?>(:final response) =>
        response != null && response.isNotEmpty
            ? SliverList.separated(
                itemBuilder: (context, index) {
                  return _buildItem(colorScheme, response[index]);
                },
                itemCount: response.length,
                separatorBuilder: (_, _) => divider,
              )
            : const HttpError(),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: null,
      ),
    };
  }

  Widget _buildItem(ColorScheme colorScheme, LoginLogItem item) {
    final style = TextStyle(fontSize: 13, color: colorScheme.outline);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(item.timeAt, style: style)),
          Expanded(flex: 2, child: Text(item.ip, style: style)),
          Expanded(flex: 3, child: Text(item.geo, style: style)),
        ],
      ),
    );
  }
}
