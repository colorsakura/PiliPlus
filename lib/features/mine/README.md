# Mine Feature

我的页面特性管理应用的个人中心，包括用户信息展示、设置管理和快捷功能入口。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: MinePage                              │
│  - Widgets: UserHeader, ActionButtons           │
│  - Providers: Riverpod 状态管理                 │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: UserInfo, UserStat, FavFolder      │
│  - Repositories: MineRepository                 │
│  - Use Cases: GetUserInfo, GetUserStat, etc.    │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - DataSources: 我的页面远程数据源              │
│  - RepositoryImpls: 仓库实现                    │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
lib/features/mine/
├── domain/                  # 领域层（核心业务逻辑）
│   ├── entities/           # 实体类
│   │   ├── user_info_entity.dart
│   │   ├── user_stat_entity.dart
│   │   ├── fav_folder_entity.dart
│   │   └── mine_settings_entity.dart
│   ├── repositories/       # 仓库接口
│   │   └── mine_repository.dart
│   └── usecases/          # 用例
│       ├── get_user_info.dart
│       ├── get_user_stat.dart
│       └── get_fav_folders.dart
├── data/                   # 数据层（数据获取和持久化）
│   ├── datasources/       # 数据源
│   │   └── mine_remote_datasource.dart
│   └── repositories/      # 仓库实现
│       └── mine_repository_impl.dart
├── presentation/          # 表现层（UI 和状态管理）
│   ├── providers/         # Riverpod providers
│   │   ├── mine_providers.dart
│   │   └── mine_controller.dart
│   ├── pages/            # 页面
│   │   ├── mine_page.dart
│   │   └── mine_controller.dart (GetX @deprecated)
│   └── widgets/          # 组件
│       └── item.dart
├── mine.dart             # 导出文件
└── README.md             # 本文件
```

## 核心功能

### 1. 用户信息

- **实体**: `UserInfoEntity` 管理用户基本信息
- **用例**: `GetUserInfoUseCase` 获取用户信息
- **状态**: `MineController.userInfo` 保存用户信息
- **包含**: 头像、昵称、等级、会员状态等

### 2. 用户统计

- **实体**: `UserStatEntity` 管理用户统计数据
- **用例**: `GetUserStatUseCase` 获取统计信息
- **状态**: `MineController.userStat` 保存统计数据
- **包含**: 动态数、关注数、粉丝数

### 3. 收藏夹

- **实体**: `FavFolderListEntity` 管理收藏夹列表
- **用例**: `GetFavFoldersUseCase` 获取收藏夹
- **状态**: `MineController.favFolders` 保存收藏夹列表

### 4. 设置管理

- **实体**: `MineSettingsEntity` 管理页面设置
- **功能**: 主题切换、匿名模式切换
- **方法**: `MineController.changeTheme()` 切换主题
- **方法**: `MineController.toggleAnonymous()` 切换匿名模式

### 5. 状态管理（Riverpod）

- **`mineControllerProvider`**: 我的页面状态管理
- **状态包含**: 用户信息、统计数据、收藏夹、设置等

## 使用方法

### 在代码中使用 Providers

```dart
// 在 Widget 中使用
class MinePageWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mineState = ref.watch(mineControllerProvider);
    final mineController = ref.read(mineControllerProvider.notifier);

    return Scaffold(
      body: mineState.isLoading
          ? CircularProgressIndicator()
          : UserHeader(userInfo: mineState.userInfo),
    );
  }
}
```

### 获取用户信息

```dart
// 刷新用户信息
ref.read(mineControllerProvider.notifier).refresh();

// 或单独获取用户信息
await ref.read(mineControllerProvider.notifier).fetchUserInfo();
```

### 切换主题

```dart
// 切换到下一个主题
ref.read(mineControllerProvider.notifier).changeTheme();
```

### 切换匿名模式

```dart
// 切换匿名模式
ref.read(mineControllerProvider.notifier).toggleAnonymous();
```

### 导航操作

```dart
// 导航到用户主页
final url = ref.read(mineControllerProvider.notifier).getUserProfileUrl();
Get.toNamed(url);

// 导航到登录页
final loginUrl = ref.read(mineControllerProvider.notifier).getLoginPageUrl();
Get.toNamed(loginUrl);
```

## 迁移状态

本特性正在进行从 GetX 到 Riverpod + 干净架构的迁移。

### 已完成 ✅

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、仓库实现）
- ✅ Presentation 层（Providers、Controller）
- ⏳ UI 层迁移（待进行）

### 待完成 🚧

- ⏳ 将现有页面迁移到新的状态管理
- ⏳ 添加完整的错误处理和加载状态
- ⏳ 集成账号服务
- ⏳ 添加完整的测试用例

### 保留文件（向后兼容）

以下文件保留用于向后兼容，将在迁移完成后标记为 `@Deprecated`：

- `presentation/pages/mine_controller.dart` - 旧的 `MineController`（GetX）

这些文件可以在确认所有功能正常后被删除。

## 依赖规则

- **Domain Layer**: 不依赖任何外层，纯粹的业务逻辑
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 错误处理

所有用例都定义了明确的错误处理：

```dart
try {
  await mineController.fetchUserInfo();
} on UnauthorizedFailure catch (e) {
  // 处理未授权错误
  print('Unauthorized: ${e.message}');
  // 跳转到登录页
} on ServerFailure catch (e) {
  // 处理服务器错误
  print('Server error: ${e.message}');
} on NetworkFailure catch (e) {
  // 处理网络错误
  print('Network error: ${e.message}');
}
```

## 相关文件

- 用户模型: `lib/models/user/`
- 用户HTTP: `lib/http/user.dart`
- 收藏夹HTTP: `lib/http/fav.dart`
- 账号管理: `lib/utils/accounts.dart`
- 主题类型: `lib/models/common/theme/theme_type.dart`
