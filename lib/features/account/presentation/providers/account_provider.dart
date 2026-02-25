import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/features/account/domain/entities/account_state.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 账户状态 Controller
class AccountController extends Notifier<AccountState> {
  @override
  AccountState build() {
    _loadAccountState();
    return const AccountState.loggedOut();
  }

  /// 从本地存储加载账户状态
  void _loadAccountState() {
    final userInfo = Pref.userInfoCache;
    if (userInfo != null) {
      state = AccountState(
        face: userInfo.face ?? '',
        isLogin: true,
        isAnonymous: false,
      );
    } else {
      state = const AccountState.loggedOut();
    }
  }

  /// 更新用户信息
  void updateUserInfo(UserInfoData userInfo) {
    state = AccountState(
      face: userInfo.face ?? '',
      isLogin: true,
      isAnonymous: false,
    );
  }

  /// 登出
  void logout() {
    state = const AccountState.loggedOut();
  }

  /// 设置匿名状态
  void setAnonymous(bool isAnonymous) {
    state = state.copyWith(isAnonymous: isAnonymous);
  }
}

/// 账户状态 Provider
final accountControllerProvider =
    NotifierProvider<AccountController, AccountState>(
  AccountController.new,
);
