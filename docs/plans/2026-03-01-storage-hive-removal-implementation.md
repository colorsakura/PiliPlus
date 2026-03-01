# 存储模块完全移除 Hive 实现计划

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**目标:** 完全移除存储模块中的 Hive 依赖，仅保留 MMKV 作为唯一存储后端，并添加完整的单元测试。

**架构:** 移除所有 Hive 相关代码（Box 声明、初始化、迁移逻辑、适配器），保留 MMKV 存储实现和 Repository 接口层，确保业务代码无感知。

**技术栈:** Flutter, Dart, MMKV, flutter_test

---

## 前置检查

### Task 0: 全面搜索 Hive 使用

**Files:**
- Search: 整个项目
- Modify: 无

**Step 1: 搜索所有 Hive 导入**

Run:
```bash
grep -r "import.*hive" --include="*.dart" lib/ | grep -v ".g.dart" | grep -v ".freezed.dart"
```

Expected: 找到所有使用 Hive 的文件

**Step 2: 搜索所有 Hive 使用**

Run:
```bash
grep -r "Hive\." --include="*.dart" lib/ | grep -v ".g.dart" | grep -v ".freezed.dart"
```

Expected: 找到所有直接调用 Hive API 的位置

**Step 3: 分析搜索结果**

确认：
- 所有找到的使用都在 `lib/core/storage/` 目录内
- 业务代码中没有直接使用 Hive
- 如果发现其他使用，记录下来需要额外迁移

---

## 阶段 1: 添加单元测试

### Task 1: 创建 MMKV Repository 单元测试

**Files:**
- Create: `test/core/storage/data/mmkv_storage_repository_impl_test.dart`

**Step 1: 创建测试文件骨架**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mmkv/mmkv.dart';
import 'package:PiliPlus/core/storage/data/datasources/mmkv_storage_repository_impl.dart';
import 'package:PiliPlus/core/storage/data/storage_config.dart';

void main() {
  late MMKV mmkv;
  late MMKVStorageRepositoryImpl repository;

  setUp(() {
    MMKV.initialize(
      rootDir: '/tmp/test_mmkv',
      logLevel: MMKVLogLevel.None,
    );
    mmkv = MMKV('test_repo');
    repository = MMKVStorageRepositoryImpl(
      config: const StorageConfig.mmkv(name: 'test_repo'),
    );
  });

  tearDown(() {
    mmkv.close();
    MMKV.delete('test_repo');
  });

  group('MMKVStorageRepositoryImpl - 基础类型', () {
    // 后续步骤添加测试
  });

  group('MMKVStorageRepositoryImpl - List 类型', () {
    // 后续步骤添加测试
  });

  group('MMKVStorageRepositoryImpl - 边界情况', () {
    // 后续步骤添加测试
  });
}
```

**Step 2: 运行测试确保骨架正常**

Run:
```bash
flutter test test/core/storage/data/mmkv_storage_repository_impl_test.dart
```

Expected: PASS (0 tests)

**Step 3: 添加 String 类型测试**

```dart
test('getString/setString - 存储和读取字符串', () {
  const key = 'test_string';
  const value = 'Hello World';

  repository.setString(key, value);
  final result = repository.getString(key);

  expect(result, equals(value));
});

test('getString - 读取不存在的键返回 null', () {
  final result = repository.getString('non_existent_key');

  expect(result, isNull);
});
```

**Step 4: 运行测试验证 String 功能**

Run:
```bash
flutter test test/core/storage/data/mmkv_storage_repository_impl_test.dart
```

Expected: PASS (2 tests)

**Step 5: 添加 Int 类型测试**

```dart
test('getInt/setInt - 存储和读取整数', () {
  const key = 'test_int';
  const value = 42;

  repository.setInt(key, value);
  final result = repository.getInt(key);

  expect(result, equals(value));
});

test('getInt - 读取不存在的键返回 null', () {
  final result = repository.getInt('non_existent_key');

  expect(result, isNull);
});
```

**Step 6: 运行测试验证 Int 功能**

Run:
```bash
flutter test test/core/storage/data/mmkv_storage_repository_impl_test.dart
```

Expected: PASS (4 tests)

**Step 7: 添加 Double 类型测试**

```dart
test('getDouble/setDouble - 存储和读取浮点数', () {
  const key = 'test_double';
  const value = 3.14;

  repository.setDouble(key, value);
  final result = repository.getDouble(key);

  expect(result, equals(value));
});
```

**Step 8: 添加 Bool 类型测试**

```dart
test('getBool/setBool - 存储和读取布尔值', () {
  const key = 'test_bool';
  const value = true;

  repository.setBool(key, value);
  final result = repository.getBool(key);

  expect(result, equals(value));
});
```

**Step 9: 添加 StringList 类型测试**

```dart
test('getStringList/setStringList - 存储和读取字符串列表', () {
  const key = 'test_list';
  const value = ['item1', 'item2', 'item3'];

  repository.setStringList(key, value);
  final result = repository.getStringList(key);

  expect(result, equals(value));
});

test('getStringList - 存储 JSON 列表', () {
  const key = 'test_json_list';
  final value = ['{"key":"value"}', '123'];

  repository.setStringList(key, value);
  final result = repository.getStringList(key);

  expect(result, equals(value));
});
```

**Step 10: 运行所有测试验证基础类型**

Run:
```bash
flutter test test/core/storage/data/mmkv_storage_repository_impl_test.dart
```

Expected: PASS (10+ tests)

**Step 11: 添加边界情况测试**

```dart
test('removeKey - 删除键后读取返回 null', () {
  const key = 'test_remove';
  repository.setString(key, 'value');

  repository.removeKey(key);
  final result = repository.getString(key);

  expect(result, isNull);
});

test('clear - 清空所有数据', () {
  repository.setString('key1', 'value1');
  repository.setInt('key2', 42);

  repository.clear();

  expect(repository.getString('key1'), isNull);
  expect(repository.getInt('key2'), isNull);
});

test('toMap - 返回所有键值对', () {
  repository.setString('key1', 'value1');
  repository.setInt('key2', 42);

  final map = repository.toMap();

  expect(map, containsPair('key1', 'value1'));
  expect(map, containsPair('key2', 42));
});
```

**Step 12: 运行完整测试套件**

Run:
```bash
flutter test test/core/storage/data/mmkv_storage_repository_impl_test.dart
```

Expected: PASS (15+ tests)

**Step 13: 提交测试文件**

```bash
git add test/core/storage/data/mmkv_storage_repository_impl_test.dart
git commit -m "test: add MMKV repository unit tests"
```

---

### Task 2: 创建 Typed Repository 单元测试

**Files:**
- Create: `test/core/storage/data/typed_storage_repository_test.dart`

**Step 1: 创建类型化存储测试文件**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mmkv/mmkv.dart';
import 'package:PiliPlus/core/storage/data/storage_config.dart';
import 'package:PiliPlus/core/storage/data/storage_factory.dart';
import 'package:PiliPlus/models/user/info.dart';

void main() {
  late MMKV mmkv;
  late TypedStorageRepository<UserInfoData> repository;

  setUp(() {
    MMKV.initialize(
      rootDir: '/tmp/test_mmkv',
      logLevel: MMKVLogLevel.None,
    );
    mmkv = MMKV('test_typed');
    repository = StorageFactory.getTypedRepository<UserInfoData>(
      const StorageConfig.mmkv(name: 'test_typed'),
      codec: JsonCodec(
        fromJson: UserInfoData.fromJson,
        toJson: (data) => data.toJson(),
      ),
    );
  });

  tearDown(() {
    mmkv.close();
    MMKV.delete('test_typed');
  });

  group('TypedStorageRepository - UserInfoData', () {
    test('setObject/getObject - 存储和读取用户信息', () {
      const key = 'test_user';
      final user = UserInfoData(
        mid: 123456,
        name: 'Test User',
        face: 'https://example.com/face.jpg',
      );

      repository.setObject(key, user);
      final result = repository.getObject(key);

      expect(result, isNotNull);
      expect(result!.mid, equals(user.mid));
      expect(result.name, equals(user.name));
      expect(result.face, equals(user.face));
    });

    test('getObject - 读取不存在的键返回 null', () {
      final result = repository.getObject('non_existent');

      expect(result, isNull);
    });

    test('setObject - 覆盖已有数据', () {
      const key = 'test_user';
      final user1 = UserInfoData(mid: 111, name: 'User 1');
      final user2 = UserInfoData(mid: 222, name: 'User 2');

      repository.setObject(key, user1);
      repository.setObject(key, user2);
      final result = repository.getObject(key);

      expect(result!.mid, equals(222));
      expect(result.name, equals('User 2'));
    });
  });
}
```

**Step 2: 运行测试验证类型化存储**

Run:
```bash
flutter test test/core/storage/data/typed_storage_repository_test.dart
```

Expected: PASS (3 tests)

**Step 3: 提交测试文件**

```bash
git add test/core/storage/data/typed_storage_repository_test.dart
git commit -m "test: add typed repository unit tests"
```

---

### Task 3: 创建 Storage Factory 单元测试

**Files:**
- Create: `test/core/storage/data/storage_factory_test.dart`

**Step 1: 创建工厂测试文件**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mmkv/mmkv.dart';
import 'package:PiliPlus/core/storage/data/storage_config.dart';
import 'package:PiliPlus/core/storage/data/storage_factory.dart';
import 'package:PiliPlus/core/storage/domain/repositories/storage_repository.dart';
import 'package:PiliPlus/core/storage/domain/repositories/typed_storage_repository.dart';

void main() {
  setUpAll(() {
    MMKV.initialize(
      rootDir: '/tmp/test_factory',
      logLevel: MMKVLogLevel.None,
    );
  });

  group('StorageFactory - MMKV Repository 创建', () {
    test('getRepository - 返回 MMKVStorageRepositoryImpl', () {
      final config = const StorageConfig.mmkv(name: 'test_factory');
      final repository = StorageFactory.getRepository(config);

      expect(repository, isA<StorageRepository>());
      expect(repository.runtimeType.toString(), contains('MMKV'));
    });

    test('getRepository - 多次调用返回相同实例', () {
      final config = const StorageConfig.mmkv(name: 'test_singleton');
      final repo1 = StorageFactory.getRepository(config);
      final repo2 = StorageFactory.getRepository(config);

      expect(identical(repo1, repo2), isTrue);
    });

    test('getTypedRepository - 返回 TypedStorageRepository', () {
      final config = const StorageConfig.mmkv(name: 'test_typed_factory');
      final repository = StorageFactory.getTypedRepository<TestModel>(
        config,
        codec: const JsonCodec(
          fromJson: TestModel.fromJson,
          toJson: (model) => model.toJson(),
        ),
      );

      expect(repository, isA<TypedStorageRepository<TestModel>>());
    });
  });
}

// 测试用模型
class TestModel {
  final String id;
  final String name;

  TestModel({required this.id, required this.name});

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
```

**Step 2: 运行工厂测试**

Run:
```bash
flutter test test/core/storage/data/storage_factory_test.dart
```

Expected: PASS (3 tests)

**Step 3: 提交测试文件**

```bash
git add test/core/storage/data/storage_factory_test.dart
git commit -m "test: add storage factory unit tests"
```

---

### Task 4: 创建 GStorage 初始化测试

**Files:**
- Create: `test/core/storage/storage_test.dart`

**Step 1: 创建初始化测试文件**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/domain/repositories/storage_repository.dart';

void main() {
  group('GStorage - 初始化', () {
    test('initCritical - 只执行一次', () async {
      // 第一次初始化
      await GStorage.initCritical();

      // 验证 repository 已创建
      expect(GStorage.settingRepository, isNotNull);

      // 第二次初始化应该立即返回
      final stopwatch = Stopwatch()..start();
      await GStorage.initCritical();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });

    test('init - 完整初始化', () async {
      await GStorage.initCritical();
      await GStorage.init();

      // 验证所有 repository 已创建
      expect(GStorage.settingRepository, isNotNull);
      expect(GStorage.videoRepository, isNotNull);
      expect(GStorage.localCacheRepository, isNotNull);
      expect(GStorage.historyWordRepository, isNotNull);
      expect(GStorage.userInfoRepository, isNotNull);
      expect(GStorage.watchProgressRepository, isNotNull);
    });

    test('init - 只执行一次', () async {
      await GStorage.initCritical();
      await GStorage.init();

      // 第二次初始化应该立即返回
      final stopwatch = Stopwatch()..start();
      await GStorage.init();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });
  });

  group('GStorage - 存储操作', () {
    setUp(() async {
      await GStorage.initCritical();
    });

    test('settingRepository - 读写设置', () {
      const key = 'test_setting';
      const value = 'test_value';

      GStorage.settingRepository.setString(key, value);
      final result = GStorage.settingRepository.getString(key);

      expect(result, equals(value));
    });
  });
}
```

**Step 2: 运行初始化测试**

Run:
```bash
flutter test test/core/storage/storage_test.dart
```

Expected: PASS (5 tests)

**Step 3: 提交测试文件**

```bash
git add test/core/storage/storage_test.dart
git commit -m "test: add GStorage initialization tests"
```

---

## 阶段 2: 重构存储模块

### Task 5: 重构 storage.dart - 移除 Hive Box 声明

**Files:**
- Modify: `lib/core/storage/storage.dart`

**Step 1: 读取当前文件**

Run:
```bash
head -50 lib/core/storage/storage.dart
```

**Step 2: 移除 Hive Box 声明（第 27-45 行）**

删除以下内容：
```dart
  // ============ 传统 Hive Box（向后兼容） ============

  /// 用户信息 Box
  static late final Box<UserInfoData> userInfo;

  /// 搜索历史 Box
  static late final Box<dynamic> historyWord;

  /// 本地缓存 Box
  static late final Box<dynamic> localCache;

  /// 设置 Box
  static late final Box<dynamic> setting;

  /// 视频 Box
  static late final Box<dynamic> video;

  /// 观看进度 Box
  static late final Box<int> watchProgress;
```

**Step 3: 移除 Hive 导入**

删除以下导入：
```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:PiliPlus/models/model_owner.dart';
import 'package:PiliPlus/models/user/danmaku_rule_adapter.dart';
import 'package:PiliPlus/models/user/info.dart';
```

保留 `UserInfoData` 导入（类型化存储需要）。

**Step 4: 运行静态分析检查错误**

Run:
```bash
flutter analyze
```

Expected: 仍有错误（Hive 相关方法还在使用）

**Step 5: 提交变更**

```bash
git add lib/core/storage/storage.dart
git commit -m "refactor: remove Hive Box declarations from storage.dart"
```

---

### Task 6: 重构 storage.dart - 移除 Hive 初始化方法

**Files:**
- Modify: `lib/core/storage/storage.dart`

**Step 1: 移除 _initHiveForCompatibility 方法（第 169-223 行）**

删除整个方法：
```dart
  /// 初始化 Hive（用于向后兼容）
  ///
  /// 注意：账户系统已迁移到 MMKV，不再在此初始化
  static Future<void> _initHiveForCompatibility() async {
    // ... 整个方法体
  }
```

**Step 2: 移除 initCritical 方法中的 Hive 初始化调用**

修改 `initCritical` 方法（第 82-113 行），删除：
```dart
    // 初始化 Hive（用于向后兼容，只读）
    await _initHiveForCompatibility();
```

**Step 3: 运行静态分析**

Run:
```bash
flutter analyze
```

Expected: 仍有错误（适配器注册和迁移方法还在）

**Step 4: 提交变更**

```bash
git add lib/core/storage/storage.dart
git commit -m "refactor: remove Hive initialization from storage.dart"
```

---

### Task 7: 重构 storage.dart - 移除适配器注册

**Files:**
- Modify: `lib/core/storage/storage.dart`

**Step 1: 移除 _registerAdaptersIfNeeded 方法（第 225-240 行）**

删除：
```dart
  /// 注册 Hive 适配器（只注册一次）
  ///
  /// 注意：账户相关适配器和 SetIntAdapter 已移除
  static void _registerAdaptersIfNeeded() {
    if (_hiveAdaptersRegistered) {
      return;
    }
    Hive
      ..registerAdapter(OwnerAdapter())
      ..registerAdapter(UserInfoDataAdapter())
      ..registerAdapter(LevelInfoAdapter())
      // 账户相关适配器已移除（账户系统使用 MMKV）
      // SetIntAdapter 已移除
      ..registerAdapter(RuleFilterAdapter());
    _hiveAdaptersRegistered = true;
  }
```

**Step 2: 移除 regAdapter 公共方法（第 242-245 行）**

删除：
```dart
  /// 注册 Hive 适配器（公共方法，保持向后兼容）
  static void regAdapter() {
    _registerAdaptersIfNeeded();
  }
```

**Step 3: 移除 _hiveAdaptersRegistered 标志（第 74 行）**

删除：
```dart
  /// Hive 适配器是否已注册
  static bool _hiveAdaptersRegistered = false;
```

**Step 4: 运行静态分析**

Run:
```bash
flutter analyze
```

Expected: 仍有错误（迁移方法还在）

**Step 5: 提交变更**

```bash
git add lib/core/storage/storage.dart
git commit -m "refactor: remove Hive adapter registration from storage.dart"
```

---

### Task 8: 重构 storage.dart - 移除迁移逻辑

**Files:**
- Modify: `lib/core/storage/storage.dart`

**Step 1: 移除 _migrateIfNeeded 方法（第 247-300 行）**

删除整个方法：
```dart
  /// 检查并迁移数据（Hive -> MMKV）
  static Future<void> _migrateIfNeeded(
    String boxName, {
    bool isTyped = false,
  }) async {
    // ... 整个方法体
  }
```

**Step 2: 移除 initCritical 中的迁移调用**

修改 `initCritical`，删除：
```dart
    // 检查并迁移 setting 数据
    await _migrateIfNeeded('setting');
```

**Step 3: 移除 init 中的批量迁移调用**

修改 `init` 方法（第 118-167 行），删除：
```dart
    // 迁移所有数据（如果需要）
    await Future.wait([
      _migrateIfNeeded('localCache'),
      _migrateIfNeeded('video'),
      _migrateIfNeeded('historyWord'),
      _migrateIfNeeded('userInfo', isTyped: true),
      _migrateIfNeeded('watchProgress'),
    ]);
```

**Step 4: 移除 StorageMigrator 导入**

删除：
```dart
import 'package:PiliPlus/core/storage/data/storage_migrator.dart';
```

**Step 5: 运行静态分析**

Run:
```bash
flutter analyze
```

Expected: PASS（如果项目其他地方没有使用 StorageMigrator）

**Step 6: 提交变更**

```bash
git add lib/core/storage/storage.dart
git commit -m "refactor: remove migration logic from storage.dart"
```

---

### Task 9: 简化 storage.dart - 清理 close 和 compact 方法

**Files:**
- Modify: `lib/core/storage/storage.dart`

**Step 1: 简化 compact 方法（第 370-373 行）**

修改为：
```dart
  /// 压缩所有 Box
  static Future<void> compact() async {
    // MMKV 自动管理空间，不需要手动压缩
    debugPrint('MMKV handles compaction automatically');
  }
```

**Step 2: 简化 close 方法（第 375-380 行）**

修改为：
```dart
  /// 关闭所有 Box
  static Future<void> close() async {
    // MMKV 不需要显式关闭
    _isInitialized = false;
    _isCriticalInitialized = false;
  }
```

**Step 3: 运行静态分析**

Run:
```bash
flutter analyze
```

Expected: PASS

**Step 4: 运行测试验证功能**

Run:
```bash
flutter test test/core/storage/
```

Expected: PASS（所有测试通过）

**Step 5: 提交变更**

```bash
git add lib/core/storage/storage.dart
git commit -m "refactor: simplify close and compact methods"
```

---

### Task 10: 重构 storage_factory.dart - 移除 Hive 支持

**Files:**
- Modify: `lib/core/storage/data/storage_factory.dart`

**Step 1: 读取当前文件**

Run:
```bash
cat lib/core/storage/data/storage_factory.dart
```

**Step 2: 移除 Hive 相关导入和配置**

如果有以下内容，删除：
```dart
import 'package:PiliPlus/core/storage/data/datasources/hive_storage_repository_impl.dart';
```

**Step 3: 简化 getRepository 方法**

确保只支持 MMKV：
```dart
  static StorageRepository getRepository(StorageConfig config) {
    if (config is MMKVStorageConfig) {
      return _getMMKVRepository(config);
    }
    throw ArgumentError('Unsupported storage config: $config');
  }
```

**Step 4: 运行静态分析**

Run:
```bash
flutter analyze lib/core/storage/data/storage_factory.dart
```

Expected: PASS

**Step 5: 运行测试**

Run:
```bash
flutter test test/core/storage/data/storage_factory_test.dart
```

Expected: PASS

**Step 6: 提交变更**

```bash
git add lib/core/storage/data/storage_factory.dart
git commit -m "refactor: remove Hive support from storage factory"
```

---

## 阶段 3: 删除废弃文件

### Task 11: 删除 Hive 实现文件

**Files:**
- Delete: `lib/core/storage/data/datasources/hive_storage_repository_impl.dart`

**Step 1: 确认文件存在**

Run:
```bash
ls -la lib/core/storage/data/datasources/hive_storage_repository_impl.dart
```

Expected: 文件存在

**Step 2: 删除文件**

Run:
```bash
git rm lib/core/storage/data/datasources/hive_storage_repository_impl.dart
```

**Step 3: 运行静态分析**

Run:
```bash
flutter analyze
```

Expected: PASS（如果文件没有被引用）

**Step 4: 提交删除**

```bash
git commit -m "refactor: remove Hive storage repository implementation"
```

---

### Task 12: 删除迁移工具文件

**Files:**
- Delete: `lib/core/storage/data/storage_migrator.dart`

**Step 1: 确认文件没有被使用**

Run:
```bash
grep -r "storage_migrator" --include="*.dart" lib/
```

Expected: 无结果（除了可能的 import）

**Step 2: 删除文件**

Run:
```bash
git rm lib/core/storage/data/storage_migrator.dart
```

**Step 3: 运行静态分析**

Run:
```bash
flutter analyze
```

Expected: PASS

**Step 4: 提交删除**

```bash
git commit -m "refactor: remove storage migration tool"
```

---

## 阶段 4: 清理依赖

### Task 13: 移除 Hive 依赖

**Files:**
- Modify: `pubspec.yaml`

**Step 1: 检查当前 Hive 依赖**

Run:
```bash
grep -A 2 "hive_flutter" pubspec.yaml
```

Expected: 找到依赖配置

**Step 2: 确认 Hive 仅用于存储模块**

Run:
```bash
grep -r "import.*hive" --include="*.dart" lib/ | wc -l
```

Expected: 0（如果前面步骤都完成了）

**Step 3: 移除 hive_flutter 依赖**

从 `pubspec.yaml` 的 `dependencies:` 部分删除：
```yaml
  hive_flutter: ^x.x.x
```

**Step 4: 运行 pub get**

Run:
```bash
flutter pub get
```

Expected: 成功获取依赖

**Step 5: 运行静态分析**

Run:
```bash
flutter analyze
```

Expected: PASS

**Step 6: 运行所有测试**

Run:
```bash
flutter test
```

Expected: PASS

**Step 7: 提交变更**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: remove hive_flutter dependency"
```

---

## 阶段 5: 验证和文档

### Task 14: 验证应用启动

**Files:**
- Build: 整个应用

**Step 1: 清理构建缓存**

Run:
```bash
flutter clean
```

**Step 2: 获取依赖**

Run:
```bash
flutter pub get
```

**Step 3: 运行静态分析**

Run:
```bash
flutter analyze
```

Expected: 无错误

**Step 4: 运行应用（Linux）**

Run:
```bash
timeout 30 flutter run -d linux
```

Expected: 应用正常启动，无崩溃

**Step 5: 测试核心功能**

在运行的应用中验证：
- [ ] 设置可以保存和读取
- [ ] 用户信息正常显示
- [ ] 视频播放正常
- [ ] 搜索历史正常

**Step 6: 提交验证**

```bash
git add .
git commit -m "test: verify application startup after Hive removal"
```

---

### Task 15: 运行完整测试套件

**Files:**
- Test: 所有测试

**Step 1: 运行所有单元测试**

Run:
```bash
flutter test
```

Expected: 所有测试通过

**Step 2: 检查测试覆盖率**

Run:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

Expected: 存储模块覆盖率 ≥ 80%

**Step 3: 查看覆盖率报告**

Run:
```bash
open coverage/html/index.html
```

**Step 4: 如果覆盖率不足，添加更多测试**

针对未覆盖的代码路径添加测试。

**Step 5: 提交测试结果**

```bash
git add test/
git commit -m "test: achieve 80%+ coverage for storage module"
```

---

### Task 16: 更新文档

**Files:**
- Create/Modify: `lib/core/storage/README.md`

**Step 1: 创建或更新存储模块 README**

```markdown
# 存储模块

## 概述

PiliPlus 使用 MMKV 作为唯一存储后端，提供高性能的键值存储。

## 架构

```
业务代码
    ↓
Repository 接口层
    ↓
MMKVStorageRepositoryImpl
    ↓
MMKV SDK
```

## 使用方式

### 基础类型存储

```dart
// 设置存储
await GStorage.settingRepository.setString('key', 'value');
final value = GStorage.settingRepository.getString('key');

// 类型化存储
await GStorage.userInfoRepository.setObject('user', userInfoData);
final user = GStorage.userInfoRepository.getObject('user');
```

### 初始化

```dart
// 关键初始化（阻塞）
await GStorage.initCritical();

// 完整初始化（非阻塞）
await GStorage.init();
```

## 存储仓库

- `settingRepository` - 应用设置
- `videoRepository` - 视频相关
- `localCacheRepository` - 本地缓存
- `historyWordRepository` - 搜索历史
- `userInfoRepository` - 用户信息（类型化）
- `watchProgressRepository` - 观看进度

## 技术栈

- MMKV - 高性能键值存储
- Repository 模式 - 接口驱动设计

## 测试

运行测试：
```bash
flutter test test/core/storage/
```

## 迁移历史

- 2026-02: 从 Hive 迁移到 MMKV
- 2026-03: 完全移除 Hive 依赖
```

**Step 2: 提交文档**

```bash
git add lib/core/storage/README.md
git commit -m "docs: update storage module documentation"
```

---

## 验收检查清单

在完成后，验证以下所有项目：

### 功能验收
- [ ] 应用正常启动
- [ ] 设置功能正常（读取/写入）
- [ ] 用户信息存储正常
- [ ] 视频缓存功能正常
- [ ] 搜索历史功能正常
- [ ] 观看进度功能正常

### 代码质量验收
- [ ] `flutter analyze` 无错误
- [ ] `flutter test` 全部通过
- [ ] 测试覆盖率 ≥ 80%
- [ ] 无 Hive 相关代码残留
- [ ] pubspec.yaml 已移除 hive_flutter

### 性能验收
- [ ] 应用启动速度提升
- [ ] 存储操作响应时间正常

### 文档验收
- [ ] 存储模块 README 已更新
- [ ] 设计文档已保存
- [ ] 实现计划已保存

---

## 完成标准

当满足以下条件时，重构完成：

1. ✅ 所有单元测试通过（15+ 个测试）
2. ✅ 测试覆盖率 ≥ 80%
3. ✅ `flutter analyze` 无错误
4. ✅ 应用正常启动和运行
5. ✅ 无 Hive 代码残留（确认 via `grep -r "hive"`）
6. ✅ pubspec.yaml 已移除 hive_flutter
7. ✅ 文档已更新

---

## 附录

### 相关文档
- 设计文档: `docs/plans/2026-03-01-storage-hive-removal-design.md`
- 干净架构指南: `docs/CLEAN_ARCHITECTURE_MIGRATION.md`

### 测试命令
```bash
# 运行存储模块测试
flutter test test/core/storage/

# 运行完整测试套件
flutter test

# 检查覆盖率
flutter test --coverage
```

### 调试命令
```bash
# 搜索残留的 Hive 使用
grep -r "Hive\." --include="*.dart" lib/

# 搜索残留的导入
grep -r "import.*hive" --include="*.dart" lib/
```
