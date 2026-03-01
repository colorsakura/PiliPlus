import 'dart:io' show Platform;
import 'package:PiliPlus/utils/toast_utils.dart';

import 'package:PiliPlus/app/app.dart' show MyApp;
import 'package:PiliPlus/shared/widgets/color_palette.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/home/presentation/pages/home_page.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/app/theme/entities/theme_colors.dart';
import 'package:PiliPlus/app/theme/entities/theme_type.dart';
import 'package:PiliPlus/features/mine/presentation/pages/mine_controller.dart';
import 'package:PiliPlus/features/setting/presentation/widgets/popup_item.dart';
import 'package:PiliPlus/features/setting/presentation/widgets/select_dialog.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

// Providers for color selection state
final currentColorProvider = Provider<int>((ref) => Pref.customColor);
final themeTypeProvider = Provider<ThemeType>((ref) => Pref.themeType);

class ColorSelectPage extends ConsumerWidget {
  const ColorSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentColor = ref.watch(currentColorProvider);
    final themeType = ref.watch(themeTypeProvider);
    FlexSchemeVariant _dynamicSchemeVariant = Pref.schemeVariant;

    final theme = Theme.of(context);
    TextStyle titleStyle = theme.textTheme.titleMedium!;
    TextStyle subTitleStyle = theme.textTheme.labelMedium!.copyWith(
      color: theme.colorScheme.outline,
    );
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.viewPaddingOf(
      context,
    ).copyWith(top: 0, bottom: 0);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('选择应用主题')),
      body: ListView(
        children: [
          ListTile(
            onTap: () async {
              final result = await showDialog<ThemeType>(
                context: context,
                builder: (context) => SelectDialog<ThemeType>(
                  title: '主题模式',
                  value: themeType,
                  values: ThemeType.values.map((e) => (e, e.desc)).toList(),
                ),
              );
              if (result != null) {
                try {
                  Get.find<MineController>().themeType.value = result;
                } catch (_) {}
                GStorage.settingRepository.setInt(SettingBoxKey.themeMode, result.index);
                Get.changeThemeMode(result.toThemeMode);
                ref.invalidate(themeTypeProvider);
              }
            },
            leading: const Icon(Icons.flashlight_on_outlined),
            title: Text('主题模式', style: titleStyle),
            subtitle: Text(
              '当前模式：${themeType.desc}',
              style: subTitleStyle,
            ),
          ),
          PopupListTile<FlexSchemeVariant>(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('调色板风格'),
            value: () =>
                (_dynamicSchemeVariant, _dynamicSchemeVariant.variantName),
            itemBuilder: (_) => FlexSchemeVariant.values
                .map(
                  (e) => PopupMenuItem(value: e, child: Text(e.variantName)),
                )
                .toList(),
            onSelected: (value, setState) {
              _dynamicSchemeVariant = value;
              GStorage.settingRepository.setInt(SettingBoxKey.schemeVariant, value.index);
              Get.forceAppUpdate();
            },
          ),
          Padding(
            padding: padding,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 22,
                        runSpacing: 18,
                        children: colorThemeTypes.indexed.map(
                          (e) {
                            final index = e.$1;
                            final item = e.$2;
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                GStorage.settingRepository.setInt(
                                  SettingBoxKey.customColor,
                                  index,
                                );
                                Get.forceAppUpdate();
                                ref.invalidate(currentColorProvider);
                              },
                              child: Column(
                                spacing: 3,
                                children: [
                                  ColorPalette(
                                    colorScheme: item.color.asColorSchemeSeed(
                                      _dynamicSchemeVariant,
                                      theme.brightness,
                                    ),
                                    selected: currentColor == index,
                                  ),
                                  Text(
                                    item.label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: currentColor != index
                                          ? theme.colorScheme.outline
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
          ),
          Padding(
            padding: padding,
            child: ExcludeFocus(
              child: IgnorePointer(
                child: Container(
                  height: size.height / 2,
                  width: size.width,
                  color: theme.colorScheme.surface,
                  child: const HomePage(),
                ),
              ),
            ),
          ),
          ExcludeFocus(
            child: IgnorePointer(
              child: NavigationBar(
                destinations: NavigationBarType.values
                    .map(
                      (item) => NavigationDestination(
                        icon: item.icon,
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
