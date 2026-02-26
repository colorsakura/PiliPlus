import 'package:PiliPlus/shared/widgets/dialog/dialog.dart';
import 'package:PiliPlus/shared/widgets/dialog/report_member.dart';
import 'package:PiliPlus/shared/widgets/pendant_avatar.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/msg/im_user_infos/datum.dart';
import 'package:PiliPlus/models/msg/msg_dnd/uid_setting.dart';
import 'package:PiliPlus/models/msg/session_ss/data.dart';
import 'package:PiliPlus/features/whisper_link_setting/presentation/providers/whisper_link_setting_providers.dart';
import 'package:PiliPlus/features/whisper_link_setting/presentation/providers/whisper_link_setting_controller.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whisper link setting page (Clean Architecture with Riverpod)
class WhisperLinkSettingPageV2 extends ConsumerWidget {
  const WhisperLinkSettingPageV2({
    super.key,
    required this.talkerUid,
  });

  final int talkerUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      whisperLinkSettingControllerProvider(talkerUid),
    );
    final state = controller.state;

    final theme = Theme.of(context);
    final divider = Divider(
      height: 12,
      thickness: 12,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );
    final divider2 = Divider(
      height: 1,
      indent: 16,
      color: theme.colorScheme.outline.withValues(alpha: 0.1),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('聊天设置')),
      body: ListView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewPaddingOf(context).bottom + 100,
        ),
        children: [
          divider,
          _buildUserInfo(theme, divider, state.userState, controller, context),
          _buildSessionSs(
            theme,
            divider,
            divider2,
            state.sessionSs,
            controller,
            context,
          ),
          if (state.sessionSs case Success(:final response))
            _buildBlockItem(response.followStatus == 128, controller, context),
          divider2,
          ListTile(
            dense: true,
            onTap: () => _report(context, controller),
            title: const Text('举报', style: TextStyle(fontSize: 14)),
            trailing: Icon(
              Icons.keyboard_arrow_right,
              color: theme.colorScheme.outline,
            ),
          ),
          divider,
        ],
      ),
    );
  }

  Widget _buildUserInfo(
    ThemeData theme,
    Widget divider,
    LoadingState<List<ImUserInfosData>?> loadingState,
    WhisperLinkSettingController controller,
    BuildContext context,
  ) {
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final item = response.first;
                      return ListTile(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/member',
                          arguments: {'mid': item.mid},
                        ),
                        leading: PendantAvatar(
                          avatar: item.face,
                          size: 42,
                          badgeSize: 14,
                          isVip:
                              item.vip?.status != null && item.vip!.status > 0,
                          garbPendantImage: item.pendant?.image,
                          officialType: item.official?.type,
                        ),
                        title: Text(
                          item.name!,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                item.vip?.status != null &&
                                    item.vip!.status > 0 &&
                                    item.vip?.type == 2
                                ? theme.colorScheme.vipColor
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          'UID: ${item.mid}${item.sign?.isNotEmpty == true ? '\n${item.sign}' : ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.outline,
                          ),
                        ),
                        trailing: Icon(
                          size: 22,
                          Icons.keyboard_arrow_right,
                          color: theme.colorScheme.outline,
                        ),
                      );
                    },
                  ),
                  divider,
                ],
              )
            : const SizedBox.shrink(),
      Error(:final errMsg) => _errWidget(errMsg, controller.getUserInfo),
    };
  }

  Widget _buildSessionSs(
    ThemeData theme,
    Widget divider,
    Widget divider2,
    LoadingState<SessionSsData> loadingState,
    WhisperLinkSettingController controller,
    BuildContext context,
  ) {
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) => Builder(
        builder: (context) {
          final subTitleS = TextStyle(
            fontSize: 13,
            color: theme.colorScheme.outline,
          );
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (response.showPushSetting == 1)
                ListTile(
                  dense: true,
                  onTap: () =>
                      _setPush(context, controller, response.pushSetting == 0),
                  title: const Text('接收消息推送', style: TextStyle(fontSize: 14)),
                  subtitle: Text(
                    '若关闭此开关，你将不再收到该账号的图文消息与稿件推送，但通知类消息不受影响',
                    style: subTitleS,
                  ),
                  trailing: Transform.scale(
                    alignment: Alignment.centerRight,
                    scale: 0.8,
                    child: Switch(
                      value: response.pushSetting == 0,
                      onChanged: (value) => _setPush(
                        context,
                        controller,
                        response.pushSetting == 0,
                      ),
                    ),
                  ),
                ),
              divider2,
              ListTile(
                dense: true,
                onTap: controller.setPin,
                title: const Text('置顶聊天', style: TextStyle(fontSize: 14)),
                trailing: Transform.scale(
                  alignment: Alignment.centerRight,
                  scale: 0.8,
                  child: Switch(
                    value: controller.state.isPinned,
                    onChanged: (value) => controller.setPin(),
                  ),
                ),
              ),
              divider2,
              _buildMuteItem(controller.state.msgDnd, controller, context),
              divider,
            ],
          );
        },
      ),
      Error(:final errMsg) => _errWidget(errMsg, controller.getSessionSs),
    };
  }

  Widget _buildMuteItem(
    LoadingState<List<UidSetting>?> loadingState,
    WhisperLinkSettingController controller,
    BuildContext context,
  ) {
    return switch (loadingState) {
      Loading() => const SizedBox.shrink(),
      Success(:final response) =>
        response != null && response.isNotEmpty
            ? ListTile(
                dense: true,
                onTap: () => controller.setMute(response.first.setting == 1),
                title: const Text('消息免打扰', style: TextStyle(fontSize: 14)),
                trailing: Transform.scale(
                  alignment: Alignment.centerRight,
                  scale: 0.8,
                  child: Switch(
                    value: response.first.setting == 1,
                    onChanged: (value) =>
                        controller.setMute(response.first.setting == 1),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      Error(:final errMsg) => _errWidget(errMsg, controller.getMsgDnd),
    };
  }

  Widget _buildBlockItem(
    bool isBlocked,
    WhisperLinkSettingController controller,
    BuildContext context,
  ) {
    return ListTile(
      dense: true,
      onTap: () => _setBlock(context, controller, isBlocked),
      title: const Text('加入黑名单', style: TextStyle(fontSize: 14)),
      trailing: Transform.scale(
        alignment: Alignment.centerRight,
        scale: 0.8,
        child: Switch(
          value: isBlocked,
          onChanged: (value) => _setBlock(context, controller, isBlocked),
        ),
      ),
    );
  }

  Widget _errWidget(String? errMsg, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          errMsg ?? '',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _setPush(
    BuildContext context,
    WhisperLinkSettingController controller,
    bool isPush,
  ) {
    if (!isPush) {
      // Show confirmation dialog
      showConfirmDialog(
        context: context,
        title: '确认关闭内容推送吗？',
        content: '若关闭此开关，你将不再收到该账号的图文消息与稿件推送，但通知类消息不受影响',
        onConfirm: () => controller.setPush(false),
      );
    } else {
      // Turn on push directly
      controller.setPush(true);
    }
  }

  void _setBlock(
    BuildContext context,
    WhisperLinkSettingController controller,
    bool isBlocked,
  ) {
    if (!isBlocked) {
      // Show confirmation dialog for blocking
      showConfirmDialog(
        context: context,
        title: '确认拉黑该用户',
        content: '加入黑名单后，将自动解除关注关系和对该用户的合集订阅关系，禁止该用户与我互动或查看我的空间',
        onConfirm: () => controller.blockUser(),
      );
    } else {
      // Unblock directly
      controller.unblockUser();
    }
  }

  void _report(BuildContext context, WhisperLinkSettingController controller) {
    showMemberReportDialog(
      context,
      name: controller.userName,
      mid: controller.talkerUid,
    );
  }
}
