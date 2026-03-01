import 'package:PiliPlus/shared/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/shared/widgets/flutter/refresh_indicator.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/view_sliver_safe_area.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/login_devices/device.dart';
import 'package:PiliPlus/features/login_devices/presentation/providers/login_devices_list_controller.dart';
import 'package:PiliPlus/utils/extension/widget_ext.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Login devices page (v2 - Riverpod)
class LoginDevicesPageV2 extends ConsumerWidget {
  const LoginDevicesPageV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(loginDevicesListControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('登录设备')),
      body: refreshIndicator(
        onRefresh: () => ref
            .read(loginDevicesListControllerProvider.notifier)
            .onRefresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ViewSliverSafeArea(
              sliver: _buildBody(colorScheme, state.listState),
            ),
          ],
        ),
      ).constraintWidth(),
    );
  }

  Widget _buildBody(
    ColorScheme colorScheme,
    LoadingState<List<LoginDevice>?> listState,
  ) {
    late final divider = Divider(
      height: 1,
      color: colorScheme.outline.withValues(alpha: 0.1),
    );
    return switch (listState) {
      Loading() => const SliverToBoxAdapter(),
      Success<List<LoginDevice>?>(:final response) =>
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

  Widget _buildItem(ColorScheme colorScheme, LoginDevice item) {
    final style = TextStyle(fontSize: 13, color: colorScheme.outline);
    return ListTile(
      dense: true,
      title: Text(
        item.deviceName ?? '',
        style: const TextStyle(fontSize: 14),
      ),
      subtitle: Text(
        '${item.latestLoginAt} ${item.source}',
        style: style,
      ),
      trailing: item.isCurrentDevice == true
          ? Text('(本机)', style: style)
          : null,
    );
  }
}
