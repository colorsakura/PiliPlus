# Contact Feature

联系人功能模块，显示关注和粉丝列表，支持用户选择。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

## 目录结构

\`\`\`
lib/features/contact/
├── domain/                      # 领域层
│   └── entities/               # 实体类
│       └── contact_config.dart
├── data/                       # 数据层（本模块为UI组合，数据层留空）
├── presentation/              # 表现层
│   ├── providers/            # Riverpod providers
│   │   └── contact_controller.dart
│   └── pages/                # 页面
│       └── contact_page.dart
└── README.md                 # 本文件
\`\`\`

## 核心功能

### 1. 联系人显示
- **我的关注**: 显示用户关注的其他用户列表
- **我的粉丝**: 显示关注当前用户的粉丝列表

### 2. 用户选择模式
- **选择模式**: 点击用户后返回选中的用户信息
- **浏览模式**: 纯浏览，不可选择

### 3. 搜索功能
- 支持搜索用户并快速跳转

## 状态管理

### ContactConfig
\`\`\`dart
class ContactConfig {
  final bool isFromSelect;  // 是否为选择模式
  final int userId;         // 用户ID
}
\`\`\`

### ContactController
- `initConfig()`: 初始化配置
- `onSelect()`: 处理用户选择

## 使用方法

### 导航到联系人页面

\`\`\`dart
// 选择模式（默认）
ContactPage.toContactPage();

// 浏览模式
ContactPage.toContactPage(isFromSelect: false);
\`\`\`

### 在代码中使用

\`\`\`dart
class SomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => ContactPage.toContactPage(),
      child: Text('选择联系人'),
    );
  }
}
\`\`\`

## 架构说明

### UI组合模式

Contact模块是一个**UI组合功能**，主要职责是：
- 组织和显示其他功能模块的页面
- 管理选择模式的交互逻辑
- 提供统一的用户界面

本模块不包含：
- 独立的数据获取逻辑（委托给 follow 和 fan 模块）
- 独立的业务逻辑（作为编排层）

### 依赖关系

```
Contact Module
├── uses → FollowChildPage (follow模块)
├── uses → FanPageV2 (fan模块)
└── uses → FollowSearchPageV2 (follow_search模块)
```

## 迁移状态

- ✅ Domain 层完成（ContactConfig实体）
- ⚪ Data 层（本模块为UI组合，无需数据层）
- ✅ Presentation 层完成（Controller、Page）
- ⏳ 测试（待添加）
- ✅ 文档完成

## 代码质量

- ✅ `flutter analyze` 无错误
- ✅ `dart format .` 格式化通过
- ✅ 从 GetX 迁移到 Riverpod
- ✅ 使用 @riverpod 注解
- ✅ 代码生成验证通过

## 技术特点

1. **状态管理**: Riverpod Notifier 模式
2. **生命周期管理**: 正确处理 TabController 和 Timer
3. **用户选择**: 支持选择模式和浏览模式
4. **导航集成**: 保留原有导航逻辑

## 后续工作

- [ ] 添加单元测试（UI测试）
- [ ] 添加集成测试
- [ ] 性能优化（大数据量时）

## 依赖规则

- **Domain Layer**: ContactConfig 无外部依赖
- **Presentation Layer**: 通过 Riverpod 管理状态
- **数据获取**: 委托给 follow 和 fan 模块

## 相关文件

- Follow 模块: `lib/features/follow/`
- Fan 模块: `lib/features/fan/`
- 用户模型: `lib/features/share/`

## 参考文档

- [干净架构迁移规范](../../../docs/CLEAN_ARCHITECTURE_MIGRATION.md)
- [迁移检查清单](../../../docs/MIGRATION_CHECKLIST.md)
- [Login模块参考实现](../login/)
