# Video Feature

视频播放特性管理应用的播放页面，包括视频详情、播放控制、互动操作等功能。

## 架构

本特性采用**干净架构（Clean Architecture）**设计，遵循依赖倒置原则。

### 分层结构

```
┌─────────────────────────────────────────────────┐
│           Presentation Layer                    │
│  - Pages: VideoPage                             │
│  - Widgets: PlayerControls, VideoInfo           │
│  - Providers: Riverpod 状态管理                 │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Domain Layer                       │
│  - Entities: VideoDetail, VideoRelation, etc.   │
│  - Repositories: VideoRepository                │
│  - Use Cases: GetVideoDetail, LikeVideo, etc.   │
└───────────────────┬─────────────────────────────┘
                    │
┌───────────────────┴─────────────────────────────┐
│              Data Layer                         │
│  - DataSources: 视频远程数据源                  │
│  - RepositoryImpls: 仓库实现                    │
└─────────────────────────────────────────────────┘
```

## 目录结构

```
lib/features/video/
├── domain/                  # 领域层（核心业务逻辑）
│   ├── entities/           # 实体类
│   │   ├── video_detail_entity.dart
│   │   ├── video_relation_entity.dart
│   │   ├── video_play_url_entity.dart
│   │   ├── video_ai_conclusion_entity.dart
│   │   └── video_play_info_entity.dart
│   ├── repositories/       # 仓库接口
│   │   └── video_repository.dart
│   └── usecases/          # 用例
│       ├── get_video_detail.dart
│       ├── get_video_play_url.dart
│       ├── like_video.dart
│       ├── get_video_relation.dart
│       └── get_ai_conclusion.dart
├── data/                   # 数据层（数据获取和持久化）
│   ├── datasources/       # 数据源
│   │   └── video_remote_datasource.dart
│   └── repositories/      # 仓库实现
│       └── video_repository_impl.dart
├── presentation/          # 表现层（UI 和状态管理）
│   ├── providers/         # Riverpod providers
│   │   ├── video_providers.dart
│   │   └── video_controller.dart
│   ├── pages/            # 页面
│   │   ├── video_page.dart
│   │   ├── ai_conclusion/
│   │   ├── download_panel/
│   │   ├── introduction/
│   │   └── ...
│   └── widgets/          # 组件
│       ├── header_control.dart
│       └── ...
├── controller.dart        # 旧 VideoController（@deprecated）
└── README.md             # 本文件
```

## 核心功能

### 1. 视频详情

- **实体**: `VideoDetailEntity` 管理视频的详细信息
- **用例**: `GetVideoDetailUseCase` 获取视频详情
- **状态**: `VideoController.videoDetail` 保存视频详情

### 2. 视频关系

- **实体**: `VideoRelationEntity` 表示点赞、投币、收藏状态
- **用例**: `GetVideoRelationUseCase` 获取关系状态
- **状态**: `VideoController.videoRelation` 保存关系状态

### 3. 视频播放

- **实体**: `VideoPlayUrlEntity` 表示播放URL信息
- **用例**: `GetVideoPlayUrlUseCase` 获取播放URL
- **方法**: `VideoController.getVideoPlayUrl()` 获取播放地址

### 4. 互动操作

- **点赞**: `LikeVideoUseCase` 执行点赞操作
- **投币**: `VideoRepository.coinVideo()` 执行投币操作
- **收藏**: `VideoRepository.favVideo()` 执行收藏操作
- **方法**: `VideoController.toggleLike()` 切换点赞状态

### 5. AI总结

- **实体**: `VideoAIConclusionEntity` 表示AI总结内容
- **用例**: `GetAIConclusionUseCase` 获取AI总结
- **方法**: `VideoController.fetchAIConclusion()` 获取总结

## 使用方法

### 在代码中使用 Providers

```dart
// 在 Widget 中使用
class VideoPlayerWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videoState = ref.watch(videoControllerProvider);
    final videoController = ref.read(videoControllerProvider.notifier);

    return Scaffold(
      body: videoState.isLoading
          ? CircularProgressIndicator()
          : VideoDetailWidget(detail: videoState.videoDetail),
    );
  }
}
```

### 初始化视频

```dart
// 初始化视频信息
ref.read(videoControllerProvider.notifier).initVideo(
  bvid: 'BV1xx411c7mD',
);
```

### 切换分P

```dart
// 切换到第2个分P
ref.read(videoControllerProvider.notifier).changeCidIndex(1);
```

### 点赞操作

```dart
// 切换点赞状态
ref.read(videoControllerProvider.notifier).toggleLike();
```

### 获取播放URL

```dart
// 获取高清播放地址
final playUrl = await ref.read(videoControllerProvider.notifier)
    .getVideoPlayUrl(qn: 80);
```

## 迁移状态

本特性正在进行从 GetX 到 Riverpod + 干净架构的迁移。

### 已完成 ✅

- ✅ Domain 层（实体、仓库接口、用例）
- ✅ Data 层（数据源、仓库实现）
- ✅ Presentation 层（Providers、Controller）
- ⏳ UI 层迁移（进行中）

### 待完成 🚧

- ⏳ 将现有页面迁移到新的状态管理
- ⏳ 更新所有子页面使用新的架构
- ⏳ 添加完整的测试用例
- ⏳ 优化错误处理和加载状态

### 保留文件（向后兼容）

以下文件保留用于向后兼容，将在迁移完成后标记为 `@Deprecated`：

- `controller.dart` - 旧的 `VideoController`（GetX）
- `view.dart` - 旧的 `VideoPage`（GetX）

这些文件可以在确认所有功能正常后被删除。

## 依赖规则

- **Domain Layer**: 不依赖任何外层，纯粹的业务逻辑
- **Data Layer**: 实现 Domain 层定义的接口
- **Presentation Layer**: 通过 Use Case 调用业务逻辑

## 错误处理

所有用例都定义了明确的错误处理：

```dart
try {
  await videoController.initVideo(bvid: bvid);
} on ServerFailure catch (e) {
  // 处理服务器错误
  print('Server error: ${e.message}');
} on NetworkFailure catch (e) {
  // 处理网络错误
  print('Network error: ${e.message}');
} on ValidationFailure catch (e) {
  // 处理验证错误
  print('Validation error: ${e.message}');
}
```

## 相关文件

- 视频模型: `lib/models/video/`
- 视频常量: `lib/core/constants/video_api_constants.dart`
- HTTP客户端: `lib/core/network/http_client.dart`
