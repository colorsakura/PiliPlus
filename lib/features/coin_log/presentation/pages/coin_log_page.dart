import 'package:PiliPlus/shared/widgets/loading_widget/http_error.dart';
import 'package:PiliPlus/shared/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/features/coin_log/domain/entities/coin_log_item.dart';
import 'package:PiliPlus/features/coin_log/presentation/providers/coin_log_controller.dart';
import 'package:PiliPlus/features/coin_log/presentation/providers/coin_log_providers.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/utils/extension/widget_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 硬币记录页面
///
/// 显示用户的硬币获取和消费记录
class CoinLogPage extends ConsumerWidget {
  const CoinLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.viewPaddingOf(context);
    final state = ref.watch(coinLogControllerProvider);
    final controller = ref.read(coinLogControllerProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(state.title)),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: EdgeInsets.only(
              left: 10 + padding.left,
              right: 10 + padding.right,
              bottom: padding.bottom + 100,
            ),
            sliver: _buildBody(state.loadingState, state, controller, ref),
          ),
        ],
      ).constraintWidth(constraints: const BoxConstraints(maxWidth: 680)),
    );
  }

  Widget _buildBody(
    LoadingState<List<CoinLogItemEntity>?> loadingState,
    CoinLogState state,
    CoinLogController controller,
    WidgetRef ref,
  ) {
    return switch (loadingState) {
      Loading() => linearLoading,
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? Builder(
                builder: (context) {
                  final them = Theme.of(context);
                  final outline = them.colorScheme.outline.withValues(
                    alpha: 0.1,
                  );
                  final divider = Divider(
                    height: 1,
                    color: outline,
                  );
                  final sliverDivider = SliverToBoxAdapter(
                    child: divider,
                  );
                  final dividerV = VerticalDivider(
                    width: 1,
                    color: outline,
                  );
                  return SliverMainAxisGroup(
                    slivers: [
                      sliverDivider,
                      SliverToBoxAdapter(
                        child: ColoredBox(
                          color: them.colorScheme.onInverseSurface,
                          child: _item(
                            state.header,
                            dividerV,
                            state.getFlexAndText,
                            isHeader: true,
                          ),
                        ),
                      ),
                      sliverDivider,
                      SliverList.separated(
                        itemCount: response.length,
                        itemBuilder: (context, index) {
                          return _item(
                            response[index],
                            dividerV,
                            state.getFlexAndText,
                          );
                        },
                        separatorBuilder: (context, index) => divider,
                      ),
                      sliverDivider,
                    ],
                  );
                },
              )
            : HttpError(onReload: () => controller.onReload()),
      Error(:final errMsg) => HttpError(
        errMsg: errMsg,
        onReload: () => controller.onReload(),
      ),
    };
  }

  Widget _item(
    CoinLogItemEntity item,
    Widget divider,
    List<(int, String)> Function(CoinLogItemEntity) getFlexAndText, {
    bool isHeader = false,
  }) {
    Widget text(int flex, String text) => Expanded(
      flex: flex,
      child: Padding(
        padding: isHeader
            ? const EdgeInsets.symmetric(vertical: 6)
            : const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: isHeader
                ? const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                : const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );

    Widget content = Row(
      children: [
        divider,
        for (final (i, j) in getFlexAndText(item)) ...[
          text(i, j),
          divider,
        ],
      ],
    );
    return IntrinsicHeight(
      child: isHeader ? content : SelectionArea(child: content),
    );
  }
}
