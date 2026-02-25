/// 账户状态实体
class AccountState {
  /// 用户头像 URL
  final String face;

  /// 是否已登录
  final bool isLogin;

  /// 是否匿名登录
  final bool isAnonymous;

  const AccountState({
    this.face = '',
    this.isLogin = false,
    this.isAnonymous = false,
  });

  /// 创建未登录状态
  const AccountState.loggedOut()
    : face = '',
      isLogin = false,
      isAnonymous = false;

  /// 是否有头像
  bool get hasFace => face.isNotEmpty;

  AccountState copyWith({
    String? face,
    bool? isLogin,
    bool? isAnonymous,
  }) {
    return AccountState(
      face: face ?? this.face,
      isLogin: isLogin ?? this.isLogin,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountState &&
          runtimeType == other.runtimeType &&
          face == other.face &&
          isLogin == other.isLogin &&
          isAnonymous == other.isAnonymous;

  @override
  int get hashCode => face.hashCode ^ isLogin.hashCode ^ isAnonymous.hashCode;
}
