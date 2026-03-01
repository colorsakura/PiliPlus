import 'dart:async';
import 'dart:convert';

import 'package:PiliPlus/build_config.dart';
import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/flutter/list_tile.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/features/about/presentation/providers/about_controller.dart';
import 'package:PiliPlus/features/mine/presentation/pages/mine_controller.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/date_utils.dart';
import 'package:PiliPlus/utils/extension/context_ext.dart';
import 'package:PiliPlus/utils/extension/num_ext.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/update.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/material.dart' hide ListTile;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:re_highlight/styles/github-dark.dart';
import 'package:re_highlight/styles/github.dart';

/// About页面
///
/// 使用 Clean Architecture + Riverpod 重构
class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key, this.showAppBar = true});

  final bool showAppBar;

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  late int _pressCount = 0;

  @override
  void initState() {
    super.initState();
    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aboutControllerProvider.notifier).initialize();
    });
  }

  void _showDialog() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      constraints: StyleString.dialogFixedConstraints,
      content: TextField(
        autofocus: true,
        onSubmitted: (value) {
          PageUtils.pop();
          if (value.isNotEmpty) {
            PageUtils.handleWebview(value, inApp: true);
          }
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aboutControllerProvider);
    final controller = ref.read(aboutControllerProvider.notifier);

    final theme = Theme.of(context);
    const style = TextStyle(fontSize: 15);
    final outline = theme.colorScheme.outline;
    final subTitleStyle = TextStyle(fontSize: 13, color: outline);
    final showAppBar = widget.showAppBar;
    final padding = MediaQuery.viewPaddingOf(context);

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('关于')) : null,
      resizeToAvoidBottomInset: false,
      body: ListView(
        padding: EdgeInsets.only(
          left: showAppBar ? padding.left : 0,
          right: showAppBar ? padding.right : 0,
          bottom: padding.bottom + 100,
        ),
        children: [
          GestureDetector(
            onTap: () {
              if (++_pressCount == 5) {
                _pressCount = 0;
                _showDialog();
              }
            },
            onSecondaryTap: PlatformUtils.isDesktop ? _showDialog : null,
            child: Image.asset(
              width: 150,
              height: 150,
              excludeFromSemantics: true,
              cacheWidth: 150.cacheSize(context),
              'assets/images/logo/logo.png',
            ),
          ),
          ListTile(
            title: Text(
              Constants.appName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium!.copyWith(height: 2),
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '使用Flutter开发的B站第三方客户端',
                  style: TextStyle(color: outline),
                  semanticsLabel: '与你一起，发现不一样的世界',
                ),
                const Icon(
                  Icons.accessibility_new,
                  semanticLabel: "无障碍适配",
                  size: 18,
                ),
              ],
            ),
          ),
          ListTile(
            onTap: () => Update.checkUpdate(false),
            onLongPress: () => Utils.copyText(
              '${BuildConfig.versionName}+${BuildConfig.versionCode}',
            ),
            onSecondaryTap: PlatformUtils.isMobile
                ? null
                : () => Utils.copyText(
                    '${BuildConfig.versionName}+${BuildConfig.versionCode}',
                  ),
            title: const Text('当前版本'),
            leading: const Icon(Icons.commit_outlined),
            trailing: Text(
              '${BuildConfig.versionName}+${BuildConfig.versionCode}',
              style: subTitleStyle,
            ),
          ),
          ListTile(
            title: Text(
              'Build Time: ${DateFormatUtils.format(BuildConfig.buildTime, format: DateFormatUtils.longFormatDs)}\n'
              'Commit Hash: ${BuildConfig.commitHash}',
              style: const TextStyle(fontSize: 14),
            ),
            leading: const Icon(Icons.info_outline),
            onTap: () => PageUtils.launchURL(
              '${Constants.sourceCodeUrl}/commit/${BuildConfig.commitHash}',
            ),
            onLongPress: () => Utils.copyText(BuildConfig.commitHash),
            onSecondaryTap: PlatformUtils.isMobile
                ? null
                : () => Utils.copyText(BuildConfig.commitHash),
          ),
          Divider(
            thickness: 1,
            height: 30,
            color: theme.colorScheme.outlineVariant,
          ),
          ListTile(
            onTap: () => PageUtils.launchURL(Constants.sourceCodeUrl),
            leading: const Icon(Icons.code),
            title: const Text('Source Code'),
            subtitle: Text(Constants.sourceCodeUrl, style: subTitleStyle),
          ),
          ListTile(
            onTap: () =>
                PageUtils.launchURL('${Constants.sourceCodeUrl}/issues'),
            leading: const Icon(Icons.feedback_outlined),
            title: const Text('问题反馈'),
            trailing: Icon(
              Icons.arrow_forward,
              size: 16,
              color: outline,
            ),
          ),
          ListTile(
            onTap: () {
              final cacheSize = state.cacheInfo?.formattedSize ?? '';
              if (cacheSize.isNotEmpty) {
                showConfirmDialog(
                  context: context,
                  title: '提示',
                  content: '该操作将清除图片及网络请求缓存数据，确认清除？',
                  onConfirm: () async {
                    SmartDialog.showLoading(msg: '正在清除...');
                    try {
                      await controller.clearCache();
                      SmartDialog.showToast('清除成功');
                    } catch (err) {
                      SmartDialog.showToast(err.toString());
                    } finally {
                      SmartDialog.dismiss();
                    }
                  },
                );
              }
            },
            leading: const Icon(Icons.delete_outline),
            title: const Text('清除缓存'),
            subtitle: Text(
              '图片及网络缓存 ${state.cacheInfo?.formattedSize ?? ''}',
              style: subTitleStyle,
            ),
          ),
          ListTile(
            title: const Text('导入/导出登录信息'),
            leading: const Icon(Icons.import_export_outlined),
            onTap: () => showImportExportDialog<Map>(
              context,
              title: '登录信息',
              toJson: () => Utils.jsonEncoder.convert(Accounts.account.toMap()),
              fromJson: (json) async {
                final res = json.map(
                  (key, value) => MapEntry(key, LoginAccount.fromJson(value)),
                );
                await Accounts.account.putAll(res);
                await Accounts.refresh();
                MineController.anonymity = (!Accounts.heartbeat.isLogin).obs;
                if (Accounts.main.isLogin) {
                  await LoginUtils.onLoginMain();
                }
                return true;
              },
            ),
          ),
          ListTile(
            title: const Text('导入/导出设置'),
            dense: false,
            leading: const Icon(Icons.import_export_outlined),
            onTap: () => showImportExportDialog(
              context,
              title: '设置',
              label: 'setting',
              toJson: GStorage.exportAllSettings,
              fromJson: GStorage.importAllJsonSettings,
            ),
          ),
          ListTile(
            title: const Text('重置所有设置'),
            leading: const Icon(Icons.settings_backup_restore_outlined),
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  clipBehavior: Clip.hardEdge,
                  title: const Text('是否重置所有设置？'),
                  children: [
                    ListTile(
                      dense: true,
                      onTap: () async {
                        PageUtils.pop();
                        await Future.wait([
                          GStorage.settingRepository.clear(),
                          GStorage.videoRepository.clear(),
                        ]);
                        SmartDialog.showToast('重置成功');
                      },
                      title: const Text('重置可导出的设置', style: style),
                    ),
                    ListTile(
                      dense: true,
                      onTap: () async {
                        PageUtils.pop();
                        await Future.wait([
                          GStorage.userInfoRepository.clear(),
                          GStorage.settingRepository.clear(),
                          GStorage.localCacheRepository.clear(),
                          GStorage.videoRepository.clear(),
                          GStorage.historyWordRepository.clear(),
                          Accounts.clear(),
                          GStorage.watchProgressRepository.clear(),
                        ]);
                        SmartDialog.showToast('重置成功');
                      },
                      title: const Text('重置所有数据（含登录信息）', style: style),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showImportExportDialog<T>(
  BuildContext context, {
  required String title,
  String? label,
  required ValueGetter<String> toJson,
  required FutureOr<bool> Function(T json) fromJson,
}) => showDialog(
  context: context,
  builder: (context) {
    const style = TextStyle(fontSize: 15);
    return SimpleDialog(
      clipBehavior: Clip.hardEdge,
      title: Text('导入/导出$title'),
      children: [
        if (label != null)
          ListTile(
            dense: true,
            title: const Text('导出文件至本地', style: style),
            onTap: () {
              PageUtils.pop();
              final res = utf8.encode(toJson());
              final name =
                  'piliplus_${label}_${context.isTablet ? 'pad' : 'phone'}_'
                  '${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}.json';
              Utils.saveBytes2File(
                name: name,
                bytes: res,
                allowedExtensions: const ['json'],
              );
            },
          ),
        ListTile(
          dense: true,
          title: Text('导出$title至剪贴板', style: style),
          onTap: () {
            PageUtils.pop();
            Utils.copyText(toJson());
          },
        ),
        ListTile(
          dense: true,
          title: Text('从剪贴板导入$title', style: style),
          onTap: () async {
            PageUtils.pop();
            ClipboardData? data = await Clipboard.getData(
              'text/plain',
            );
            if (data?.text?.isNotEmpty != true) {
              SmartDialog.showToast('剪贴板无数据');
              return;
            }
            if (!context.mounted) return;
            final text = data!.text!;
            late final T json;
            late final String formatText;
            try {
              json = jsonDecode(text);
              formatText = Utils.jsonEncoder.convert(json);
            } catch (e) {
              SmartDialog.showToast('解析json失败：$e');
              return;
            }
            final highlight = Highlight()..registerLanguage('json', langJson);
            final result = highlight.highlight(
              code: formatText,
              language: 'json',
            );
            late TextSpanRenderer renderer;
            bool? isDarkMode;
            showDialog(
              context: context,
              builder: (context) {
                final isDark = context.isDarkMode;
                if (isDark != isDarkMode) {
                  isDarkMode = isDark;
                  renderer = TextSpanRenderer(
                    const TextStyle(),
                    isDark ? githubDarkTheme : githubTheme,
                  );
                  result.render(renderer);
                }
                return AlertDialog(
                  title: Text('是否导入如下$title？'),
                  content: SingleChildScrollView(
                    child: Text.rich(renderer.span!),
                  ),
                  actions: [
                    TextButton(
                      onPressed: Get.back,
                      child: Text(
                        '取消',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        PageUtils.pop();
                        try {
                          if (await fromJson(json)) {
                            SmartDialog.showToast('导入成功');
                          }
                        } catch (e) {
                          SmartDialog.showToast('导入失败：$e');
                        }
                      },
                      child: const Text('确定'),
                    ),
                  ],
                );
              },
            );
          },
        ),
        ListTile(
          dense: true,
          title: Text('输入$title', style: style),
          onTap: () {
            PageUtils.pop();
            final key = GlobalKey<FormFieldState<String>>();
            late T json;
            String? forceErrorText;

            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('输入$title'),
                constraints: StyleString.dialogFixedConstraints,
                content: TextFormField(
                  key: key,
                  minLines: 4,
                  maxLines: 12,
                  autofocus: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    errorMaxLines: 3,
                  ),
                  validator: (value) {
                    if (forceErrorText != null) return forceErrorText;
                    try {
                      json = jsonDecode(value!) as T;
                      return null;
                    } catch (e) {
                      if (e is FormatException) {}
                      return '解析json失败：$e';
                    }
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: Get.back,
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (key.currentState?.validate() == true) {
                        try {
                          if (await fromJson(json)) {
                            PageUtils.pop();
                            SmartDialog.showToast('导入成功');
                            return;
                          }
                        } catch (e) {
                          forceErrorText = '导入失败：$e';
                        }
                        key.currentState?.validate();
                        forceErrorText = null;
                      }
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  },
);
