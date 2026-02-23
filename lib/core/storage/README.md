# Storage 模块文档

## 概述

本模块实现了应用的数据持久化功能，采用**干净架构**设计，**默认使用 MMKV 存储后端**，提供高性能的键值存储。

## 存储后端

### 当前状态：完全使用 MMKV

**MMKV 存储默认启用：**
- ✅ **自动迁移**：首次启动时自动从 Hive 迁移数据到 MMKV
- ✅ **完全透明**：用户无感知，无需手动操作
- ✅ **高性能**：MMKV 提供比 Hive 更快的读写速度
- ✅ **已迁移所有数据**：setting, localCache, video, historyWord, watchProgress, userInfo, **account**

**账户系统迁移：**
- ✅ **已完成**：账户管理系统已迁移到 MMKV
- ✅ **JSON 序列化**：使用 LoginAccount.toJson/fromJson 方法
- ✅ **自动迁移**：首次启动自动从 Hive 迁移账户数据
- ✅ **向后兼容**：保留 `_AccountBoxAdapter` 适配器确保现有代码正常工作

**Hive 移除状态：**
- ✅ TypeAdapter 文件已删除（account_adapter.dart, account_type_adapter.dart, cookie_jar_adapter.dart, set_int_adapter.dart）
- ✅ Hive 适配器注册已移除
- ✅ 账户系统完全独立于 Hive
- ⚠️ Hive 依赖仍保留在 pubspec.yaml（用于其他遗留 Box 的只读访问）

### 性能对比
| 操作 | MMKV | Hive |
|------|------|------|
| 读取 | ~0.2ms | ~1-2ms |
| 写入 | ~0.3ms | ~2-3ms |
| 跨进程 | ✅ 支持 | ❌ 不支持 |
| 账户数据 | ✅ MMKV + JSON | ❌ 已迁移 |

## 架构设计

```
lib/core/storage/
├── domain/                      # Domain 层（抽象接口）
│   ├── keys/                    # 存储键常量
│   │   ├── setting_keys.dart    # 设置相关键（按功能分组）
│   │   ├── local_cache_keys.dart # 本地缓存键
│   │   └── video_keys.dart       # 视频相关键
│   └── repositories/            # 存储接口
│       ├── storage_repository.dart       # 基础类型存储接口
│       └── typed_storage_repository.dart # 复杂对象存储接口
├── data/                        # Data 层（实现）
│   ├── datasources/
│   │   ├── account_storage_repository.dart    # 账户存储（MMKV + JSON）
│   │   ├── hive_storage_repository_impl.dart  # Hive 实现（遗留兼容）
│   │   └── mmkv_storage_repository_impl.dart  # MMKV 实现（默认）
│   ├── storage_factory.dart      # 存储工厂
│   ├── storage_config.dart       # 存储配置
│   └── storage_migrator.dart     # Hive 到 MMKV 迁移工具
├── storage.dart                 # 主存储类
├── storage_key.dart             # 键常量（向后兼容）
└── storage_pref.dart            # 类型安全的访问器
```

## 使用指南

### 1. 传统 API（完全兼容）

```dart
// 使用 GStorage 直接访问（内部使用 MMKV）
final value = GStorage.setting.get(SettingBoxKey.someKey, defaultValue: 'default');
GStorage.setting.put(SettingBoxKey.someKey, 'newValue');

// 类型安全的访问
final bool enableFeature = Pref.someBoolSetting;
```

### 2. 新架构 API

```dart
// 使用存储仓库（内部使用 MMKV）
final repository = GStorage.settingRepository;

// 读写数据
final value = repository.getString('someKey') ?? 'default';
await repository.setString('someKey', 'newValue');

// 类型化存储（复杂对象）
final userInfo = GStorage.userInfoRepository.get('userInfoCache');
await GStorage.userInfoRepository.set('userInfoCache', newUserInfo);
```

### 3. 添加新的存储键

1. 在 `domain/keys/` 的相应文件中添加键常量
2. 在 `storage_key.dart` 的 `SettingBoxKey` 类中添加（向后兼容）
3. 可选：在 `storage_pref.dart` 中添加类型安全的访问器

## 存储键分类

### 视频设置（VideoSettingKeys）
- 播放器相关：`btmProgressBehavior`, `fullScreenMode`, `autoPlayEnable`
- 解码相关：`defaultDecode`, `hardwareDecoding`, `videoSync`
- 音频相关：`defaultAudioQa`, `audioOutput`, `expandBuffer`

### 弹幕设置（DanmakuSettingKeys）
- 显示控制：`enableShowDanmaku`, `showVipDanmaku`, `mergeDanmaku`
- 过滤规则：`danmakuBlockType`, `danmakuWeight`, `danmakuShowArea`
- 样式设置：`danmakuOpacity`, `danmakuFontScale`, `danmakuDuration`

### 字幕设置（SubtitleSettingKeys）
- 字幕偏好：`subtitlePreferenceV2`, `enableDragSubtitle`
- 样式设置：`subtitlePaddingH`, `subtitleBgOpacity`, `subtitleFontScale`

### UI 设置（UISettingKeys）
- 界面布局：`hideTopBar`, `hideBottomBar`, `barHideType`
- 卡片样式：`smallCardWidth`, `recommendCardWidth`
- 动态设置：`showDynInteraction`, `dynamicBadgeMode`

### 桌面端设置（DesktopSettingKeys）
- 窗口管理：`windowSize`, `windowPosition`, `isWindowMaximized`
- 系统集成：`showWindowTitleBar`, `showTrayIcon`, `uiScale`

### 其他
- WebDAV 备份：`WebdavSettingKeys`
- SponsorBlock：`SponsorBlockSettingKeys`
- 代理设置：`ProxySettingKeys`

## 自动迁移

### 迁移流程

1. **首次启动**：应用检测到 Hive 数据
2. **自动迁移**：后台将 Hive 数据复制到 MMKV
3. **标记完成**：记录迁移标志，避免重复迁移
4. **切换后端**：所有后续操作使用 MMKV

### 迁移的存储

- ✅ `setting` - 应用设置
- ✅ `localCache` - 本地缓存
- ✅ `video` - 视频设置
- ✅ `historyWord` - 搜索历史
- ✅ `userInfo` - 用户信息（JSON 序列化）
- ✅ `watchProgress` - 观看进度
- ✅ `account` - 账户管理（JSON 序列化，使用 `LoginAccount.toJson/fromJson`）

### 未迁移的存储

**所有存储均已迁移！** 🎉

账户系统已成功迁移到 MMKV，使用 JSON 序列化：
- 移除了复杂的 TypeAdapter 链
- 使用标准的 JSON 序列化
- 保持了完整的向后兼容性

### 手动触发迁移

如需重新迁移，可以删除迁移标志：

```dart
// 删除迁移标志
StorageMigrator.clearMigrationFlag('setting');

// 重启应用会重新迁移
```

### 迁移状态检查

```dart
// 检查是否已迁移
bool hasMigrated = StorageMigrator.hasMigrated('setting');
```

## API 参考

### StorageRepository

基础类型存储接口，支持：
- `String? getString(String key)`
- `Future<void> setString(String key, String? value)`
- `int? getInt(String key)`
- `Future<void> setInt(String key, int? value)`
- `double? getDouble(String key)`
- `Future<void> setDouble(String key, double? value)`
- `bool? getBool(String key)`
- `Future<void> setBool(String key, bool? value)`
- `List<String>? getStringList(String key)`
- `Future<void> setStringList(String key, List<String>? value)`
- `Future<void> remove(String key)`
- `Future<void> clear()`
- `bool containsKey(String key)`
- `List<dynamic> get keys`
- `Map<dynamic, dynamic> toMap()`

### TypedStorageRepository<T>

复杂对象存储接口，支持 JSON 序列化：
- `T? get(String key)`
- `Future<void> set(String key, T? value)`
- `Future<void> remove(String key)`
- `Map<String, T> toMap()`
- `Future<void> putAll(Map<String, T> map)`
- `Future<void> clear()`
- `List<dynamic> get keys`
- `bool containsKey(String key)`

### StorageConfig

存储配置类：
```dart
const StorageConfig({
  required String name,        // 存储名称
  StorageType type = StorageType.hive,  // 存储类型
  String? cryptKey,            // 加密密钥（MMKV）
  String? rootDir,             // 根目录（MMKV）
  bool readOnly = false,        // 是否只读（MMKV）
  int expectedCapacity = 0,    // 预期容量（MMKV）
})
```

## 最佳实践

1. **使用类型安全的访问器**：优先使用 `Pref` 类而不是直接访问 `GStorage`
2. **按功能分组键**：新键应添加到相应功能分类的文件中
3. **提供默认值**：读取设置时应提供合理的默认值
4. **保持向后兼容**：不要随意删除或重命名现有的键
5. **复杂对象使用 JSON**：需要存储复杂对象时，添加 `toJson/fromJson` 方法

## 故障排除

### 问题：设置未保存
- 确认使用的是 `GStorage.settingRepository` 而不是直接操作 MMKV
- 检查键名拼写是否正确
- 验证数据类型是否匹配

### 问题：迁移后数据丢失
- 检查迁移日志确认迁移是否成功
- 使用 `StorageMigrator.hasMigrated()` 检查迁移状态
- 必要时可回滚到 Hive（需要修改代码）

### 问题：性能问题
- MMKV 已提供高性能，一般不会有性能问题
- 避免在循环中频繁读写
- 使用批量操作（`putAll`）

### 问题：导入/导出失败
- 导入导出现在使用 MMKV 数据
- 如果需要旧 Hive 数据，先运行一次应用完成迁移

### 问题：账户数据丢失
- 账户系统仍使用 Hive，不受 MMKV 迁移影响
- 如遇到账户问题，检查 `utils/accounts.dart` 和 Hive 初始化

## 技术细节

### MMKV vs Hive

| 特性 | MMKV | Hive |
|------|------|------|
| 存储方式 | 内存映射文件 | NoSQL 数据库 |
| 跨进程支持 | ✅ 原生支持 | ❌ 需要额外处理 |
| 读取速度 | 极快（内存） | 较快（文件+缓存） |
| 写入速度 | 极快（异步） | 较慢（同步） |
| 数据加密 | ✅ 支持 | ✅ 支持 |
| 复杂对象 | 需序列化 | 原生支持 |
| 适用场景 | 频繁读写、小数据 | 大数据、复杂查询 |

### 数据序列化

对于复杂对象（如 `UserInfoData`），使用 JSON 序列化：

```dart
// 模型需要实现 toJson/fromJson
class UserInfoData {
  Map<String, dynamic> toJson() { ... }
  factory UserInfoData.fromJson(Map<String, dynamic> json) { ... }
}

// MMKV 会自动序列化/反序列化
await repository.set('key', userInfo);
final data = repository.get('key');
```

## 相关文件

- `lib/core/storage/` - 存储模块主目录
- `lib/services/app_initializer/` - 应用初始化（包含存储初始化）
- `lib/models/` - 数据模型（需要序列化的类）
- `CLAUDE.md` - 项目整体文档
