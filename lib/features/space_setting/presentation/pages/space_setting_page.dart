import 'dart:math';

import 'package:PiliPlus/common/widgets/loading_widget/loading_widget.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/space_setting/privacy.dart';
import 'package:PiliPlus/features/space_setting/domain/entities/space_setting_state.dart';
import 'package:PiliPlus/features/space_setting/presentation/providers/space_setting_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpaceSettingPage extends ConsumerStatefulWidget {
  const SpaceSettingPage({super.key});

  @override
  ConsumerState<SpaceSettingPage> createState() => _SpaceSettingPageState();
}

class _SpaceSettingPageState extends ConsumerState<SpaceSettingPage> {
  @override
  void dispose() {
    // Save mods on dispose
    ref.read(spaceSettingControllerProvider.notifier).saveMods();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controllerState = ref.watch(spaceSettingControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('空间设置')),
      body: _buildBody(theme, controllerState),
    );
  }

  Widget _buildBody(ThemeData theme, SpaceSettingState controllerState) {
    return switch (controllerState.privacy) {
      Loading() => const SizedBox.shrink(),
      Success<Privacy?>(:final response) =>
        response == null
            ? scrollErrorWidget(
                onReload: () => ref
                    .read(spaceSettingControllerProvider.notifier)
                    .onReload(),
              )
            : Builder(
                builder: (context) {
                  final padding = MediaQuery.viewPaddingOf(context);
                  final divider = Divider(
                    height: 1,
                    indent: max(16, padding.left),
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                  );
                  final dividerL = SliverToBoxAdapter(
                    child: Divider(
                      height: 12,
                      thickness: 12,
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  );
                  return CustomScrollView(
                    slivers: [
                      dividerL,
                      SliverList.separated(
                        itemCount: response.list1.length,
                        itemBuilder: (context, index) {
                          return _item(response.list1[index]);
                        },
                        separatorBuilder: (context, index) => divider,
                      ),
                      dividerL,
                      SliverList.separated(
                        itemCount: response.list2.length,
                        itemBuilder: (context, index) {
                          return _item(response.list2[index]);
                        },
                        separatorBuilder: (context, index) => divider,
                      ),
                      dividerL,
                      SliverList.separated(
                        itemCount: response.list3.length,
                        itemBuilder: (context, index) {
                          return _item(response.list3[index]);
                        },
                        separatorBuilder: (context, index) => divider,
                      ),
                      dividerL,
                      SliverToBoxAdapter(
                        child: SizedBox(height: padding.bottom + 100),
                      ),
                    ],
                  );
                },
              ),
      Error(:final errMsg) => scrollErrorWidget(
        errMsg: errMsg,
        onReload: () => ref.read(spaceSettingControllerProvider.notifier).onReload(),
      ),
    };
  }

  Widget _item(SpaceSettingModel item) {
    return ListTile(
      dense: true,
      onTap: () => ref
          .read(spaceSettingControllerProvider.notifier)
          .updateSettingValue(item, null),
      title: Text(
        item.name,
        style: const TextStyle(fontSize: 14),
      ),
      trailing: Transform.scale(
        alignment: Alignment.centerRight,
        scale: 0.8,
        child: Switch(
          value: item.boolVal,
          onChanged: (value) => ref
              .read(spaceSettingControllerProvider.notifier)
              .updateSettingValue(item, value),
        ),
      ),
    );
  }
}
