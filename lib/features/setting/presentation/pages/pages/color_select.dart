import 'dart:io' show Platform;

import 'package:PiliPlus/app/app.dart' show MyApp;
import 'package:PiliPlus/shared/widgets/color_palette.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/home/presentation/pages/home_page.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/models/common/theme/theme_color_type.dart';
import 'package:PiliPlus/models/common/theme/theme_type.dart';
import 'package:PiliPlus/features/mine/presentation/pages/mine_controller.dart';
import 'package:PiliPlus/features/setting/presentation/widgets/popup_item.dart';
import 'package:PiliPlus/features/setting/presentation/widgets/select_dialog.dart';
import 'package:PiliPlus/utils/extension/theme_ext.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

// Providers for color selection state
final dynamicColorProvider = Provider<bool>((ref) => Pref.dynamicColor);
final currentColorProvider = Provider<int>((ref) => Pref.customColor);
final themeTypeProvider = Provider<ThemeType>((ref) => Pref.themeType);

class ColorSelectPage extends ConsumerWidget {
  const ColorSelectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dynamicColor = ref.watch(dynamicColorProvider);
    final currentColor = ref.watch(currentColorProvider);
    final themeType = ref.watch(themeTypeProvider);
    FlexSchemeVariant _dynamicSchemeVariant = Pref.schemeVariant;

    Future<void> onChanged(bool? val) async {
      val ??= !dynamicColor;
      if (val) {
        if (await MyApp.initPlatformState()) {
          Get.forceAppUpdate();
        } else {
          SmartDialog.showToast('该设备可能不支持动态取色');
          return;
        }
      } else {
        Get.forceAppUpdate();
      }
      GStorage.setting.put(SettingBoxKey.dynamicColor, val);
      // Invalidate provider to trigger rebuild
      ref.invalidate(dynamicColorProvider);
    }

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
                GStorage.setting.put(SettingBoxKey.themeMode, result.index);
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
            enabled: !dynamicColor,
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
              GStorage.setting.put(SettingBoxKey.schemeVariant, value.index);
              Get.forceAppUpdate();
            },
          ),
          if (!Platform.isIOS)
            ListTile(
              title: const Text('动态取色'),
              leading: ExcludeFocus(
                child: Checkbox(
                  value: dynamicColor,
                  onChanged: (val) => onChanged(val),
                  materialTapTargetSize: .shrinkWrap,
                  visualDensity: const VisualDensity(
                    horizontal: -4,
                    vertical: -4,
                  ),
                ),
              ),
              onTap: () => onChanged(null),
            ),
          Padding(
            padding: padding,
            child: AnimatedSize(
              curve: Curves.easeInOut,
              alignment: Alignment.topCenter,
              duration: const Duration(milliseconds: 200),
              child: dynamicColor
                  ? const SizedBox.shrink()
                  : Padding(
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
                                GStorage.setting.put(
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
