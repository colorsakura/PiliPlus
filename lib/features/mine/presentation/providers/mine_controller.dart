import 'package:PiliPlus/core/errors/failures.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/features/mine/domain/entities/fav_folder_entity.dart';
import 'package:PiliPlus/features/mine/domain/entities/user_info_entity.dart';
import 'package:PiliPlus/features/mine/domain/entities/user_stat_entity.dart';
import 'package:PiliPlus/features/mine/domain/usecases/get_fav_folders.dart';
import 'package:PiliPlus/features/mine/domain/usecases/get_user_info.dart';
import 'package:PiliPlus/features/mine/domain/usecases/get_user_stat.dart';
import 'package:PiliPlus/features/mine/presentation/providers/mine_providers.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/app/theme/entities/theme_type.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 我的页面状态
class MineState {
  /// 是否正在加载
  final bool isLoading;

  /// 错误消息
  final String? errorMessage;

  /// 用户信息
  final UserInfoEntity? userInfo;

  /// 用户统计信息
  final UserStatEntity? userStat;

  /// 收藏夹列表
  final FavFolderListEntity? favFolders;

  /// 主题类型
  final ThemeType themeType;

  /// 是否匿名模式
  final bool isAnonymous;

  const MineState({
    this.isLoading = false,
    this.errorMessage,
    this.userInfo,
    this.userStat,
    this.favFolders,
    this.themeType = ThemeType.system,
    this.isAnonymous = false,
  });

  MineState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserInfoEntity? userInfo,
    UserStatEntity? userStat,
    FavFolderListEntity? favFolders,
    ThemeType? themeType,
    bool? isAnonymous,
  }) {
    return MineState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      userInfo: userInfo ?? this.userInfo,
      userStat: userStat ?? this.userStat,
      favFolders: favFolders ?? this.favFolders,
      themeType: themeType ?? this.themeType,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  /// 是否已登录
  bool get isLogin => userInfo?.isLogin == true;

  /// 是否有用户信息
  bool get hasUserInfo => userInfo != null && !userInfo!.isEmpty;

  /// 下一个主题类型
  ThemeType get nextThemeType {
    final currentIndex = ThemeType.values.indexOf(themeType);
    final nextIndex = (currentIndex + 1) % ThemeType.values.length;
    return ThemeType.values[nextIndex];
  }
}

/// 我的页面Controller
class MineController extends Notifier<MineState> {
  late final GetUserInfoUseCase _getUserInfoUseCase;
  late final GetUserStatUseCase _getUserStatUseCase;
  late final GetFavFoldersUseCase _getFavFoldersUseCase;

  @override
  MineState build() {
    _getUserInfoUseCase = ref.read(getUserInfoUseCaseProvider);
    _getUserStatUseCase = ref.read(getUserStatUseCaseProvider);
    _getFavFoldersUseCase = ref.read(getFavFoldersUseCaseProvider);

    // 初始化主题类型
    final initialThemeType = Pref.themeType;

    // 检查是否匿名模式
    final isAnonymous = Accounts.account.isNotEmpty &&
        !Accounts.heartbeat.isLogin;

    return MineState(
      themeType: initialThemeType,
      isAnonymous: isAnonymous,
    );
  }

  /// 获取用户信息
  Future<void> fetchUserInfo() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final userInfo = await _getUserInfoUseCase();

      // 如果用户未登录，返回空状态
      if (!userInfo.isLogin) {
        state = state.copyWith(
          isLoading: false,
          userInfo: UserInfoEntity.empty(),
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        userInfo: userInfo,
      );

      // 获取用户统计信息
      await fetchUserStat();
    } on UnauthorizedFailure {
      state = state.copyWith(
        isLoading: false,
        userInfo: UserInfoEntity.empty(),
        userStat: UserStatEntity.empty(),
      );
    } on Failure catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    }
  }

  /// 获取用户统计信息
  Future<void> fetchUserStat() async {
    try {
      final userStat = await _getUserStatUseCase();
      state = state.copyWith(userStat: userStat);
    } on Failure {
      // 统计信息获取失败不影响主流程
      // 可以记录错误
    }
  }

  /// 获取收藏夹列表
  Future<void> fetchFavFolders() async {
    if (!state.isLogin || state.userInfo?.mid == null) {
      return;
    }

    try {
      final favFolders = await _getFavFoldersUseCase(
        mid: state.userInfo!.mid!.toString(),
      );
      state = state.copyWith(favFolders: favFolders);
    } on Failure catch (e) {
      state = state.copyWith(errorMessage: e.message);
    }
  }

  /// 刷新数据
  Future<void> refresh() async {
    await fetchUserInfo();
  }

  /// 切换主题
  void changeTheme() {
    final newThemeType = state.nextThemeType;
    state = state.copyWith(themeType: newThemeType);

    // 保存设置
    GStorage.settingRepository.setInt(SettingBoxKey.themeMode, newThemeType.index);
  }

  /// 切换匿名模式
  void toggleAnonymous() {
    final newAnonymous = !state.isAnonymous;
    state = state.copyWith(isAnonymous: newAnonymous);

    // 更新账号模式
    if (newAnonymous) {
      Accounts.set(AccountType.heartbeat, AnonymousAccount());
    } else {
      Accounts.set(AccountType.heartbeat, Accounts.main);
    }
  }

  /// 清除错误消息
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// 导航到用户主页
  String getUserProfileUrl() {
    return '/member?mid=${state.userInfo?.mid ?? 0}';
  }

  /// 导航到登录页
  String getLoginPageUrl() {
    return '/loginPage';
  }
}

/// 我的页面Controller Provider
final mineControllerProvider =
    NotifierProvider<MineController, MineState>(
  MineController.new,
);
