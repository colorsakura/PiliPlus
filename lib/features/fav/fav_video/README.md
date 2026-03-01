# Fav Video Feature

收藏视频功能模块，管理用户的视频收藏夹。

## Architecture

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

## 目录结构

```
lib/features/fav/fav_video/
├── domain/                      # 领域层
│   ├── entities/               # 实体类
│   │   └── fav_video_item_entity.dart
│   ├── repositories/           # 仓库接口
│   │   └── fav_video_repository.dart
│   └── usecases/              # 用例
│       └── get_fav_folders_usecase.dart
├── data/                       # 数据层
│   ├── datasources/           # 数据源
│   │   └── fav_video_remote_datasource.dart
│   └── repositories/          # 仓库实现
│       └── fav_video_repository_impl.dart
├── presentation/              # 表现层
│   ├── providers/            # Providers
│   │   ├── fav_video_list_controller.dart (ChangeNotifier)
│   │   ├── fav_video_providers.dart
│   │   └── fav_folder_list_controller.dart (Riverpod - New)
│   └── pages/                # 页面
│       ├── fav_video_page.dart (ChangeNotifier)
│       └── fav_video_page_v2.dart (Riverpod - New)
└── fav_video.dart             # 导出文件
```

## 核心功能

### 1. 收藏夹管理

- **获取收藏夹**: FetchFoldersUseCase
- **分页加载**: 支持分页获取收藏夹列表
- **收藏夹信息**: 文件夹名称、视频数量等

### 2. 状态管理

#### ChangeNotifier (Legacy)
- `FavVideoController` - 收藏夹列表管理

#### Riverpod (New - Recommended)
- `FavFolderListController` - 收藏夹列表管理

### 3. 页面实现

#### ChangeNotifier (Legacy)
- `FavVideoPage` - 收藏夹列表页面

#### Riverpod (New - Recommended)
- `FavVideoPageV2` - 收藏夹列表页面（新版本）
  - 卡片式布局
  - 下拉刷新
  - 自动加载更多
  - 空状态提示

## 使用方法

### 使用 Riverpod 版本（推荐）

```dart
import 'package:PiliPlus/features/fav/fav_video/fav_video.dart';

// 使用新版本
class MyPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FavVideoPageV2();
  }
}
```

### 使用 ChangeNotifier 版本（向后兼容）

```dart
import 'package:PiliPlus/features/fav/fav_video/fav_video.dart';

// 使用旧版本
class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavVideoController(
        getFavFoldersUseCase: GetFavFoldersUseCase(repository),
      ),
      child: FavVideoPage(),
    );
  }
}
```

## 数据模型

### FavFolderInfo

```dart
class FavFolderInfo {
  final String? title;      // 收藏夹名称
  final int? mediaCount;   // 视频数量
  final String? cover;      // 封面图
  final String? fid;        // 收藏夹ID
  final int? favOrder;    // 排序
  final int? type;         // 类型
}
```

## 迁移状态

- ✅ Domain 层完成
- ✅ Data 层完成
- ✅ Presentation 层完成（ChangeNotifier + Riverpod）
- ⏳ 测试（待添加）
- ✅ 文档完成

## 代码质量

- ✅ `flutter analyze` 无错误（仅警告）
- ✅ `dart format .` 格式化通过
- ✅ Riverpod 代码生成验证通过
- ✅ 架构合规性验证通过

## 技术特点

1. **状态管理**: Riverpod Notifier 模式（新版本）
2. **向后兼容**: 保留 ChangeNotifier 版本
3. **分页加载**: 自动检测并加载更多
4. **空状态处理**: 友好的空状态提示

## 后续工作

- [ ] 添加UI测试
- [ ] 添加集成测试
- [ ] 实现收藏夹创建功能
- [ ] 实现收藏夹编辑功能
- [ ] 实现收藏夹删除功能
- [ ] 性能优化（大量收藏夹场景）

## 依赖规则

- **Domain Layer**: 无外部依赖
- **Data Layer**: 实现 Domain 层接口
- **Presentation Layer**: 通过 Riverpod 管理状态

## 相关文件

- Fav 模块: `lib/features/fav/`
- 收藏HTTP: `lib/http/fav.dart`
- 收藏模型: `lib/models/fav/fav_folder/`

## 参考文档

- [干净架构迁移规范](../../../../docs/CLEAN_ARCHITECTURE_MIGRATION.md)
- [迁移检查清单](../../../../docs/MIGRATION_CHECKLIST.md)
- [Msg模块参考实现](../../msg/)
- [Whisper模块参考实现](../../whisper/)
