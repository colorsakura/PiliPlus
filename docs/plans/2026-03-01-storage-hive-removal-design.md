# 存储模块完全移除 Hive 设计文档

**日期:** 2026-03-01
**作者:** Claude Code
**状态:** 已批准

## 1. 概述

### 1.1 目标
完全移除存储模块中的 Hive 依赖和相关代码，仅使用 MMKV 作为唯一存储后端。

### 1.2 背景
- 所有用户数据已完成从 Hive 到 MMKV 的迁移
- 业务代码已不再使用 Hive Box
- 保留 Hive 代码仅用于向后兼容和迁移
- 迁移工具已完成历史使命

### 1.3 预期收益
- 代码简化约 500 行
- 启动速度提升（无迁移检查）
- 维护负担降低
- 更好的可测试性

## 2. 架构设计

### 2.1 目标架构

```
┌─────────────────────────────────────────────────┐
│                    应用层                        │
│              (业务代码、Features)                │
└─────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                   存储接口层                     │
│  • StorageRepository                             │
│  • TypedStorageRepository<T>                     │
└─────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                  存储实现层                      │
│       MMKVStorageRepositoryImpl                  │
│    (实现所有 Repository 接口)                    │
└─────────────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                   存储后端                       │
│                   MMKV SDK                       │
└─────────────────────────────────────────────────┘
```

### 2.2 核心原则
- **单一存储后端**：仅使用 MMKV
- **接口驱动**：业务代码通过接口访问存储
- **类型安全**：使用类型化仓库处理复杂对象
- **可测试**：依赖注入便于单元测试

## 3. 重构范围

### 3.1 要删除的文件

```
lib/core/storage/data/datasources/hive_storage_repository_impl.dart
lib/core/storage/data/storage_migrator.dart
```

### 3.2 要修改的文件

**lib/core/storage/storage.dart**
- 移除所有 Hive Box 声明（6个）
- 移除 `_initHiveForCompatibility()` 方法
- 移除 `_registerAdaptersIfNeeded()` 方法
- 移除 `regAdapter()` 公共方法
- 移除 `_migrateIfNeeded()` 方法
- 移除所有 Hive 导入

**lib/core/storage/data/storage_factory.dart**
- 移除 `HiveStorageConfig` 类
- 移除 Hive 实现的工厂逻辑

**pubspec.yaml**
- 移除 `hive_flutter` 依赖
- 移除相关依赖（如果仅用于 Hive）

### 3.3 要保留的文件

```
lib/core/storage/domain/repositories/storage_repository.dart
lib/core/storage/domain/repositories/typed_storage_repository.dart
lib/core/storage/data/datasources/mmkv_storage_repository_impl.dart
lib/core/storage/data/storage_config.dart
lib/core/storage/data/storage_factory.dart (修改后)
```

## 4. 数据流设计

### 4.1 初始化流程

```
应用启动
    ↓
GStorage.initCritical() (阻塞阶段)
    ↓
MMKV.initialize()
    ↓
创建 settingRepository
    ↓
应用 UI 渲染
    ↓
GStorage.init() (非阻塞阶段)
    ↓
批量创建所有 Repository
    ↓
Accounts.init()
    ↓
完成
```

### 4.2 存储操作流程

```
业务代码
    ↓
GStorage.settingRepository / videoRepository 等
    ↓
MMKVStorageRepositoryImpl (方法调用)
    ↓
MMKV SDK (实际存储)
```

### 4.3 移除的流程

- ❌ Hive 初始化流程
- ❌ 迁移检查流程
- ❌ Hive Box 打开/关闭流程

## 5. 错误处理

### 5.1 初始化错误

**MMKV 初始化失败：**
```dart
try {
  await MMKV.initialize(...);
} catch (e) {
  AppLog.severe('MMKV initialization failed: $e', name: 'Storage');
  throw StorageInitializationException('Failed to initialize MMKV: $e');
}
```

**Repository 创建失败：**
```dart
try {
  settingRepository = StorageFactory.getRepository(config);
} catch (e) {
  AppLog.severe('Failed to create repository: $e', name: 'Storage');
  throw StorageCreationException('Failed to create repository: $e');
}
```

### 5.2 存储操作错误

- MMKV 操作一般不会抛出异常（设计可靠）
- 对于类型不匹配：记录警告并返回默认值
- 对于存储失败：记录错误但不中断流程

## 6. 测试策略

### 6.1 测试范围

**Repository 测试：**
- 基础类型：String, Int, Double, Bool
- 复杂类型：List, Map
- 类型化对象：UserInfoData
- 边界情况：空值, 不存在的键

**Factory 测试：**
- MMKV 配置创建
- 正确的 Repository 类型

**GStorage 测试：**
- initCritical 流程
- 完整 init 流程
- 重复初始化幂等性

### 6.2 测试文件结构

```
test/core/storage/
├── data/
│   ├── mmkv_storage_repository_impl_test.dart
│   └── storage_factory_test.dart
└── storage_test.dart
```

### 6.3 测试覆盖率目标

- 存储核心代码：≥ 80%
- 关键路径：100%

## 7. 验收标准

### 7.1 功能验收
- [ ] 应用正常启动
- [ ] 设置功能正常（读取/写入）
- [ ] 用户信息存储正常
- [ ] 视频缓存功能正常
- [ ] 搜索历史功能正常
- [ ] 观看进度功能正常

### 7.2 代码质量验收
- [ ] `flutter analyze` 无错误
- [ ] `flutter test` 全部通过
- [ ] 测试覆盖率 ≥ 80%
- [ ] 无 Hive 相关代码残留
- [ ] pubspec.yaml 已移除 hive_flutter

### 7.3 性能验收
- [ ] 应用启动速度提升
- [ ] 存储操作响应时间正常

## 8. 风险与缓解

### 8.1 风险

**风险 1：遗漏的 Hive 使用**
- 影响：编译错误或运行时崩溃
- 概率：低
- 缓解：全面搜索项目中所有 Hive 使用

**风险 2：MMKV 数据损坏**
- 影响：用户数据丢失
- 概率：极低
- 缓解：MMKV 已验证的可靠性

**风险 3：类型化存储序列化错误**
- 影响：特定功能异常
- 概率：低
- 缓解：完整的单元测试覆盖

### 8.2 回滚计划

如果发现严重问题：
1. 恢复 Hive 相关代码（从 git 历史）
2. 重新启用迁移逻辑
3. 发布修复版本

## 9. 实施计划

详细的实施步骤将由 `writing-plans` skill 生成。

## 10. 附录

### 10.1 相关文档
- [干净架构迁移指南](./CLEAN_ARCHITECTURE_MIGRATION.md)
- [存储模块 README](./storage/README.md)

### 10.2 变更历史
- 2026-03-01: 初始设计文档
