# Member Feature

成员空间特性管理应用的用户主页，展示用户信息、投稿内容、动态等内容。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: MemberPage                           │
│  - Widgets: UserInfoCard, TabBar               │
│  - Providers: Riverpod 状态管理                 │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: Member, MemberTab, MemberSpace     │
│  - Repositories: MemberRepository               │
│  - Use Cases: GetMemberSpace, FollowMember      │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - DataSources: 成员API远程数据源               │
│  - RepositoryImpls: 仓库实现                    │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
lib/features/member/
├── domain/                  # 领域层（核心业务逻辑）
│   ├── entities/           # 实体类
│   │   ├── member_entity.dart
│   │   ├── member_tab_entity.dart
│   │   └── member_space_entity.dart
│   ├── repositories/       # 仓库接口
│   │   └── member_repository.dart
│   └── usecases/          # 用例
│       ├── get_member_space.dart
│       └── follow_member.dart
├── data/                   # 数据层（数据获取和持久化）
│   ├── datasources/       # 数据源
│   │   └── member_api_datasource.dart
│   └── repositories/      # 仓库实现
│       └── member_repository_impl.dart
├── presentation/          # 表现层（UI 和状态管理）
│   ├── providers/         # Riverpod providers
│   │   ├── member_providers.dart
│   │   ├── member_state.dart
│   │   ├── member_controller.dart
│   │   └── member_provider.dart
│   ├── pages/            # 页面
│   │   ├── member_page.dart
│   │   ├── member_controller.dart (GetX @deprecated)
│   │   └── widget/
│   └── widgets/          # 组件
└── README.md             # 本文件
```

## 核心功能

### 1. 成员空间信息

- **实体**: `MemberSpaceEntity` 管理成员空间所有信息
- **实体**: `MemberEntity` 管理成员基本信息
- **用例**: `GetMemberSpaceUseCase` 获取成员空间
- **状态**: `MemberController` 保存空间状态

### 2. 标签页管理

- **实体**: `MemberTabEntity` 管理标签页信息
- **标签页类型**: 动态、投稿、收藏、追番等
- **过滤**: 自动过滤无效的标签页

### 3. 关注操作

- **用例**: `FollowMemberUseCase` 关注/取消关注
- **方法**: `MemberController.toggleFollow()`
- **状态**: 自动更新关注状态

### 4. 关系管理

- **拉黑**: 添加/移除黑名单
- **举报**: 举报违规成员
- **关系状态**: 0-未关注, 2-已关注, 128-已拉黑

### 5. 直播状态

- **实体**: `Live` 直播信息
- **状态**: `MemberSpaceEntity.isLive`
- **显示**: 在用户头像显示直播标识

## 使用方法

### 在代码中使用 Providers

```dart
// 在 Widget 中使用
class MemberPageWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final memberState = ref.watch(memberControllerProvider);
    final memberController = ref.read(memberControllerProvider.notifier);

    return Scaffold(
      body: memberState.isLoading
          ? CircularProgressIndicator()
          : MemberInfo(member: memberState.member),
    );
  }
}
```

### 获取成员空间

```dart
// 获取成员空间信息
await ref.read(memberControllerProvider.notifier).queryMemberSpace(mid: 12345);

// 检查是否加载成功
if (memberState.loadingState is Success) {
  // 显示成员信息
}
```

### 关注操作

```dart
// 切换关注状态
final isFollow = memberState.isFollow;
ref.read(memberControllerProvider.notifier).toggleFollow(!isFollow);
```

### 拉黑操作

```dart
// 拉黑/取消拉黑
ref.read(memberControllerProvider.notifier).blockMember(context);
```

## 迁移状态

本特性正在进行从 GetX 到 Riverpod + 干净架构的迁移。

### 已完成 ✅

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、仓库实现）
- ✅ Presentation 层（Providers、State、Controller）
- ⏳ 完善关注和拉黑功能实现

### 待完成 🚧

- ⏳ 实现关注/取消关注API
- ⏳ 实现拉黑/取消拉黑API
- ⏳ 完善错误处理和加载状态
- ⏳ 添加完整的测试用例

### 待整合的现有功能

- `presentation/pages/member_controller.dart` - 现有的GetX控制器（需要迁移）
- `presentation/providers/member_state.dart` - 现有状态定义（已使用）
- `presentation/providers/member_controller.dart` - 现有控制器（已使用）
- `presentation/providers/member_provider.dart` - 现有provider（已使用）

### 保留文件（向后兼容）

以下文件保留用于向后兼容，将在迁移完成后标记为 `@Deprecated`：

- `presentation/pages/member_controller.dart` - 旧的GetX控制器

这些文件可以在确认所有功能正常后被删除或整合。

## 依赖规则

- **Domain Layer**: 不依赖任何外层，纯粹的业务逻辑
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 错误处理

所有用例都定义了明确的错误处理：

```dart
try {
  await memberController.queryMemberSpace(mid: mid);
} on UnauthorizedFailure catch (e) {
  // 处理未授权错误
  print('Unauthorized: ${e.message}');
} on ServerFailure catch (e) {
  // 处理服务器错误
  print('Server error: ${e.message}');
} on NetworkFailure catch (e) {
  // 处理网络错误
  print('Network error: ${e.message}');
}
```

## 相关文件

- 成员模型: `lib/models/member/`
- 空间模型: `lib/models/space/`
- 成员HTTP: `lib/http/member.dart`
- 成员常量: `lib/core/constants/member_api_constants.dart`
- 标签类型: `lib/models/common/member/tab_type.dart`
