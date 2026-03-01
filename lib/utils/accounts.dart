import 'package:PiliPlus/core/storage/data/account_storage_repository.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:PiliPlus/models/common/account_type.dart';
import 'package:PiliPlus/features/mine/presentation/pages/mine_controller.dart';
import 'package:PiliPlus/utils/accounts/account.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:PiliPlus/utils/path_utils.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';

/// 账户存储适配器
///
/// 将 AccountStorageRepository 适配为 Hive Box 接口
/// 用于保持现有代码兼容性
class _AccountBoxAdapter {
  final AccountStorageRepository _repository;

  _AccountBoxAdapter(this._repository);

  /// 获取所有账户
  Iterable<LoginAccount> get values => _repository.toMap().values;

  /// 获取所有账户的 Map
  Map<String, LoginAccount> toMap() => _repository.toMap();

  /// 检查是否为空
  bool get isEmpty => _repository.isEmpty;

  /// 检查是否不为空
  bool get isNotEmpty => !_repository.isEmpty;

  /// 获取账户数量
  int get length => _repository.length;

  /// 获取所有键
  List<dynamic> get keys => _repository.keys;

  /// 获取账户
  LoginAccount? get(dynamic key) => _repository.get(key.toString());

  /// 保存账户
  Future<void> put(dynamic key, LoginAccount value) =>
      _repository.set(key.toString(), value);

  /// 批量保存账户
  Future<void> putAll(Map<dynamic, LoginAccount> entries) async {
    await _repository.putAll(
      entries.map((k, v) => MapEntry(k.toString(), v)),
    );
  }

  /// 删除账户
  Future<void> delete(dynamic key) => _repository.remove(key.toString());

  /// 清空所有账户
  Future<void> clear() => _repository.clear();
}

abstract final class Accounts {
  static late final _AccountBoxAdapter account;
  static final List<Account> accountMode = List.filled(
    AccountType.values.length,
    AnonymousAccount(),
  );
  static Account get main => accountMode[AccountType.main.index];
  static Account get heartbeat => accountMode[AccountType.heartbeat.index];
  static Account get history {
    final heartbeat = Accounts.heartbeat;
    if (heartbeat is AnonymousAccount) {
      return Accounts.main;
    }
    return heartbeat;
  }
  // static set main(Account account) => set(AccountType.main, account);

  static Future<void> init() async {
    // 初始化 MMKV 账户存储
    final repository = AccountStorageRepository.fromConfig(
      storeName: 'account',
      rootDir: path.join(appSupportDirPath, 'mmkv'),
    );
    account = _AccountBoxAdapter(repository);

    // 3. 加载账户到内存
    await refresh();
  }

  // static Future<void> _migrate() async {
  //   final Directory tempDir = await getApplicationSupportDirectory();
  //   final String tempPath = "${tempDir.path}/.plpl/";
  //   final Directory dir = Directory(tempPath);
  //   if (dir.existsSync()) {
  //     if (kDebugMode) debugPrint('migrating...');
  //     final cookieJar = PersistCookieJar(
  //       ignoreExpires: true,
  //       storage: FileStorage(tempPath),
  //     );
  //     await cookieJar.forceInit();
  //     final cookies = DefaultCookieJar(ignoreExpires: true)
  //       ..domainCookies.addAll(cookieJar.domainCookies);
  //     final localAccessKey = GStorage.localCache.get(
  //       'accessKey',
  //       defaultValue: {},
  //     );

  //     final isLogin =
  //         cookies.domainCookies['bilibili.com']?['/']?['SESSDATA'] != null;

  //     await Future.wait([
  //       GStorage.localCache.delete('accessKey'),
  //       GStorage.localCache.delete('danmakuFilterRule'),
  //       GStorage.localCache.delete('blackMidsList'),
  //       dir.delete(recursive: true),
  //       if (isLogin)
  //         LoginAccount(
  //           cookies,
  //           localAccessKey['value'],
  //           localAccessKey['refresh'],
  //           AccountType.values.toSet(),
  //         ).onChange(),
  //     ]);
  //     if (kDebugMode) debugPrint('migrated successfully');
  //   }
  // }

  static Future<void> refresh() async {
    for (final a in account.values) {
      for (final t in a.type) {
        accountMode[t.index] = a;
      }
    }
    await Future.wait(
      (accountMode.toSet()..removeWhere((i) => i.activated)).map(
        Request.buvidActive,
      ),
    );
  }

  static Future<void> clear() async {
    await account.clear();
    for (int i = 0; i < AccountType.values.length; i++) {
      accountMode[i] = AnonymousAccount();
    }
    await AnonymousAccount().delete();
    Request.buvidActive(AnonymousAccount());
  }

  static Future<void> deleteAll(Set<Account> accounts) async {
    final isLoginMain = Accounts.main.isLogin;
    for (int i = 0; i < AccountType.values.length; i++) {
      if (accounts.contains(accountMode[i])) {
        accountMode[i] = AnonymousAccount();
      }
    }
    await Future.wait(accounts.map((i) => i.delete()));
    if (isLoginMain && !Accounts.main.isLogin) {
      await LoginUtils.onLogoutMain();
    }
  }

  static Future<void> set(AccountType key, Account account) async {
    final oldAccount = accountMode[key.index]..type.remove(key);
    accountMode[key.index] = account..type.add(key);
    await Future.wait([?account.onChange(), ?oldAccount.onChange()]);
    if (!account.activated) await Request.buvidActive(account);
    switch (key) {
      case AccountType.main:
        await (account.isLogin
            ? LoginUtils.onLoginMain()
            : LoginUtils.onLogoutMain());
        break;
      case AccountType.heartbeat:
        MineController.anonymity = (!account.isLogin).obs;
        break;
      default:
        break;
    }
  }

  @pragma("vm:prefer-inline")
  static Account get(AccountType key) {
    return accountMode[key.index];
  }
}
