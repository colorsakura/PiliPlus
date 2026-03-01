# PiliPlus - Claude Code 开发指南

> B站第三方客户端 Flutter 项目，基于干净架构（Clean Architecture）设计

## 📋 项目概述

- **技术栈:** Flutter 3.41.2, Dart 3.10+
- **状态管理:** Riverpod 3.2.1 + go_router 17.1.0
- **架构:** Feature-based 干净架构
- **迁移状态:** GetX → Riverpod 已完成（视频详情页等核心模块）

## 🔄 修改验证流程

**每次代码修改后必须执行以下步骤：**

```bash
# 1. 静态分析（必须无错误）
flutter analyze

# 2. Linux 平台运行测试（30秒超时，必须无错误）
timeout 30 flutter run -d linux

# 3. 确认上述两步无错误后，输出确认标识
【冰狗】
```

## ⚠️ 开发约束

### 依赖管理
- **禁止新增任何依赖**，除非有明确需求并获得批准
- 使用现有依赖解决问题

### 代码规范
- 遵循干净架构原则（参考 `docs/CLEAN_ARCHITECTURE_MIGRATION.md`）
- Feature 模块结构：`lib/features/{feature_name}/`
- 状态管理优先使用 Riverpod，避免使用 GetX 新功能
- 导航使用 go_router，通过 `PageUtils` 工具类

## 📚 文档规范

- **图表绘制:** 使用 Mermaid 语法
- **架构文档:** 参考 `docs/CLEAN_ARCHITECTURE_MIGRATION.md`
- **Feature README:** 每个 feature 目录应包含 README.md 说明

## 🏗️ 项目结构

```
lib/
├── main.dart                 # 应用入口
├── app/                      # 应用层配置（路由、主题等）
├── core/                     # 核心层（常量、错误处理、存储等）
├── features/                 # 功能模块（按功能划分）
│   ├── video/               # 视频播放模块
│   ├── home/                # 首页模块
│   ├── login/               # 登录模块
│   └── ...                  # 其他功能模块
├── shared/                   # 共享组件和工具
└── utils/                    # 工具类
```

## 🔧 常用命令

```bash
# 依赖管理
flutter pub get               # 获取依赖
flutter pub outdated          # 检查过时依赖

# 代码质量
flutter analyze               # 静态分析
flutter test                  # 运行测试
dart format .              # 格式化代码

# 构建运行
flutter run -d linux         # Linux 平台运行
flutter run -d android       # Android 平台运行
```

## 📖 相关文档

- [干净架构迁移指南](./docs/CLEAN_ARCHITECTURE_MIGRATION.md) - 架构设计和迁移方案

## 🎯 开发优先级

1. **正确性 > 性能** - 先确保功能正确
2. **简洁 > 复杂** - 避免过度设计
3. **测试 > 假设** - 实际运行验证
4. **文档 > 记忆** - 及时记录重要决策