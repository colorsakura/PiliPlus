import 'dart:convert';
import 'package:PiliPlus/utils/toast_utils.dart';

import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/http/fav.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/user.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/app/theme/entities/theme_type.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/models/user/stat.dart';
import 'package:PiliPlus/models/fav/fav_folder/data.dart';
import 'package:PiliPlus/features/common/presentation/pages/common_data_controller.dart';
import 'package:PiliPlus/services/account_service.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MineController extends CommonDataController<FavFolderData, FavFolderData>
    with AccountMixin {
  @override
  AccountService accountService = Get.find<AccountService>();

  int? favFolderCount;

  // 用户信息 头像、昵称、lv
  final Rx<UserInfoData> userInfo = UserInfoData().obs;
  // 用户状态 动态、关注、粉丝
  final Rx<UserStat> userStat = const UserStat().obs;

  Rx<ThemeType> themeType = Pref.themeType.obs;

  ThemeType get nextThemeType =>
      ThemeType.values[(themeType.value.index + 1) % ThemeType.values.length];

  // 使用可空类型避免未初始化错误
  static RxBool? anonymity;

  late final list =
      <({IconData icon, double size, String title, VoidCallback onTap})>[
        (
          size: 23,
          icon: MdiIcons.folderDownloadOutline,
          title: '离线缓存',
          onTap: () => PageUtils.pushNamed(AppRoutes.download),
        ),
        (
          size: 23,
          icon: Icons.history,
          title: '观看记录',
          onTap: () {
            if (isLogin) {
              PageUtils.pushNamed(AppRoutes.history);
            }
          },
        ),
        (
          size: 20,
          icon: Icons.subscriptions_outlined,
          title: '我的订阅',
          onTap: () {
            if (isLogin) {
              PageUtils.pushNamed(AppRoutes.subscription);
            }
          },
        ),
        (
          size: 22,
          icon: Icons.watch_later_outlined,
          title: '稍后再看',
          onTap: () {
            if (isLogin) {
              PageUtils.pushNamed(AppRoutes.later);
            }
          },
        ),
      ];

  @override
  void onInit() {
    super.onInit();
    // 初始化 anonymity（必须在 Accounts.init() 之后调用）
    anonymity ??=
        (Accounts.account.isNotEmpty && !Accounts.heartbeat.isLogin).obs;
    UserInfoData? userInfoCache = Pref.userInfoCache;
    if (userInfoCache != null) {
      userInfo.value = userInfoCache;
      queryData();
      queryUserInfo();
    }
  }

  bool get isLogin {
    if (!accountService.isLogin.value) {
      // ToastUtils.showToast('账号未登录');
      return false;
    }
    return true;
  }

  Future<void> queryUserInfo() async {
    final res = await UserHttp.userInfo();
    if (res case Success(:final response)) {
      if (response.isLogin == true) {
        userInfo.value = response;
        if (response != Pref.userInfoCache) {
          GStorage.userInfoRepository.set('userInfoCache', response);
        }
        accountService
          ..face.value = response.face!
          ..isLogin.value = true;
      } else {
        LoginUtils.onLogoutMain();
        return;
      }
    } else {
      final errMsg = res.toString();
      ToastUtils.showToast(errMsg);
      if (errMsg == '账号未登录') {
        LoginUtils.onLogoutMain();
        return;
      }
    }
    queryUserStatOwner();
  }

  Future<void> queryUserStatOwner() async {
    final res = await UserHttp.userStatOwner();
    if (res case Success(:final response)) {
      userStat.value = response;
    }
  }

  @override
  bool customHandleResponse(bool isRefresh, Success<FavFolderData> response) {
    favFolderCount = response.response.count;
    loadingState.value = response;
    return true;
  }

  @override
  Future<LoadingState<FavFolderData>> customGetData() {
    return FavHttp.userfavFolder(
      pn: 1,
      ps: 20,
      mid: Accounts.main.mid,
    );
  }

  static void onChangeAnonymity() {
    if (Accounts.account.isEmpty) {
      ToastUtils.showToast('请先登录');
      return;
    }
    if (anonymity == null) {
      anonymity = false.obs;
    }
    final newVal = !anonymity!.value;
    anonymity!.value = newVal;
    if (newVal) {
      ToastUtils.dismiss();
      showModalBottomSheet<bool>(
        context: Get.context!,
        useSafeArea: true,
        builder: (context) {
          final theme = Theme.of(context);
          final style = TextStyle(
            color: theme.colorScheme.onSecondaryContainer,
          );
          return ColoredBox(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: EdgeInsets.only(
                top: 15,
                left: 20,
                right: 20,
                bottom: MediaQuery.viewPaddingOf(context).bottom + 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const Icon(MdiIcons.incognito, size: 20),
                      const SizedBox(width: 10),
                      Text('已进入无痕模式', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '搜索、观看视频/直播不携带身份信息（包含大会员）\n'
                    '不产生查询或播放记录\n'
                    '点赞等其它操作不受影响\n'
                    '(前往隐私设置了解详情)',
                    style: theme.textTheme.bodySmall,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                          ToastUtils.showToast('已设为永久无痕模式');
                        },
                        child: Text('保存为永久', style: style),
                      ),
                      const SizedBox(width: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          ToastUtils.showToast('已设为临时无痕模式');
                        },
                        child: Text('仅本次（默认）', style: style),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ).then((res) {
        if (res == false) {
          return;
        }
        res == true
            ? Accounts.set(AccountType.heartbeat, AnonymousAccount())
            : Accounts.accountMode[AccountType.heartbeat.index] =
                  AnonymousAccount();
      });
    } else {
      Accounts.set(AccountType.heartbeat, Accounts.main);
      Navigator.of(Get.context!).pop(false);
      ToastUtils.showToast('已退出无痕模式');
    }
  }

  void onChangeTheme() {
    final newVal = nextThemeType;
    themeType.value = newVal;
    GStorage.settingRepository.setInt(SettingBoxKey.themeMode, newVal.index);
    Get.changeThemeMode(newVal.toThemeMode);
  }

  void push(String name) {
    late final mid = userInfo.value.mid;
    if (isLogin && mid != null) {
      // Map route names to AppRoutes
      final route = switch (name) {
        'memberDynamics' => AppRoutes.memberDynamics,
        'follow' => AppRoutes.follow,
        'fan' => AppRoutes.fan,
        _ => null,
      };

      if (route != null) {
        PageUtils.pushNamed(route, parameters: {'mid': mid.toString()});
      }
    }
  }

  void onLogin([bool longPress = false]) {
    if (!accountService.isLogin.value || longPress) {
      PageUtils.pushNamed(AppRoutes.loginPage);
    } else {
      final mid = userInfo.value.mid;
      if (mid != null) {
        PageUtils.toMemberPage(mid);
      }
    }
  }

  @override
  Future<void> onRefresh() {
    if (!accountService.isLogin.value) {
      return Future.syncValue(null);
    }
    queryUserInfo();
    return super.onRefresh();
  }

  @override
  void onChangeAccount(bool isLogin) {
    if (isLogin) {
      onRefresh();
    } else {
      userInfo.value = UserInfoData();
      userStat.value = const UserStat();
      loadingState.value = LoadingState.loading();
    }
  }
}
