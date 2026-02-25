# 干净架构迁移快速开始指南

## 🎉 恭喜！核心基础设施已完成

你现在拥有了一个完整的干净架构核心层，可以开始迁移各个 Feature 了。

---

## ✅ 已搭建的基础设施

### 1. 核心错误处理

```dart
import 'package:PiliPlus/core/errors/error_handler.dart';

// 在数据源中使用
try {
  final response = await _httpClient.get('/some/endpoint');
  // ...
} on DioException catch (e) {
  throw ErrorHandler.handleDioError(e);
}

// 在仓库中使用
catch (e) {
  return ErrorHandler.handleError(e);
}
```

### 2. 网络层

```dart
import 'package:PiliPlus/core/network/http_client.dart';

// 在数据源中使用
class SomeRemoteDataSource {
  final Dio _httpClient = HttpClient.instance;

  Future<Data> fetchData() async {
    final response = await _httpClient.get('/endpoint');
    return response.data['data'];
  }
}
```

### 3. API 常量

```dart
import 'package:PiliPlus/core/constants/video_api_constants.dart';

// 使用视频相关 API
await _httpClient.get(VideoApiConstants.videoIntro);
```

### 4. 共享层

```dart
import 'package:PiliPlus/shared/data/models/loading_state.dart';

// 在仓库中使用
Future<LoadingState<Data>> getData() async {
  try {
    final data = await remoteDataSource.fetch();
    return Success(data);
  } catch (e) {
    return Error(e.toString());
  }
}

// 在 UI 中使用
widget.data.when(
  loading: () => LoadingIndicator(),
  success: (data) => DataWidget(data),
  error: (msg) => ErrorWidget(msg),
);
```

---

## 📋 Feature 迁移步骤

### 步骤 1: 创建 Domain 层

```dart
// 1.1 创建实体
// features/video/domain/entities/video.dart
class Video {
  final String bvid;
  final String title;
  // ...
}

// 1.2 创建仓库接口
// features/video/domain/repositories/video_repository.dart
abstract class VideoRepository {
  Future<LoadingState<Video>> getVideoDetail(String bvid);
}

// 1.3 创建用例
// features/video/domain/usecases/get_video_detail_usecase.dart
class GetVideoDetailUseCase {
  final VideoRepository repository;

  GetVideoDetailUseCase(this.repository);

  Future<LoadingState<Video>> call(String bvid) {
    return repository.getVideoDetail(bvid);
  }
}
```

### 步骤 2: 创建 Data 层

```dart
// 2.1 创建数据源
// features/video/data/datasources/video_remote_datasource.dart
class VideoRemoteDataSource {
  final Dio _httpClient = HttpClient.instance;

  Future<Map<String, dynamic>> getVideoDetail({
    required String bvid,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.videoIntro,
        queryParameters: {'bvid': bvid},
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(
          response.data['message'] ?? '获取视频详情失败',
          code: response.data['code'],
        );
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}

// 2.2 创建仓库实现
// features/video/data/repositories/video_repository_impl.dart
class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;

  VideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<LoadingState<Video>> getVideoDetail(String bvid) async {
    try {
      final data = await remoteDataSource.getVideoDetail(bvid: bvid);
      final video = Video.fromJson(data);
      return Success(video);
    } on ServerException catch (e) {
      return Error(e.message, code: e.code);
    } on NetworkException catch (e) {
      return Error(e.message);
    } catch (e) {
      return Error('未知错误: $e');
    }
  }
}

// 2.3 依赖注入
// features/video/data/di/video_di.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final videoRemoteDataSourceProvider = Provider<VideoRemoteDataSource>((ref) {
  return VideoRemoteDataSource();
});

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepositoryImpl(
    remoteDataSource: ref.watch(videoRemoteDataSourceProvider),
  );
});
```

### 步骤 3: 创建 Presentation 层

```dart
// 3.1 创建 Controller
// features/video/presentation/providers/video_controller.dart
final videoDetailControllerProvider =
    StateNotifierProvider.family<VideoDetailController, LoadingState, String>(
  (ref, bvid) {
    return VideoDetailController(
      ref.watch(videoRepositoryProvider),
      bvid,
    );
  },
);

class VideoDetailController extends StateNotifier<LoadingState> {
  final VideoRepository _repository;
  final String _bvid;

  VideoDetailController(this._repository, this._bvid)
      : super(const Loading());

  Future<void> loadVideo() async {
    state = const Loading();
    state = await _repository.getVideoDetail(_bvid);
  }
}

// 3.2 创建页面
// features/video/presentation/pages/video_page.dart
class VideoPage extends ConsumerWidget {
  final String bvid;

  const VideoPage({required this.bvid, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(videoDetailControllerProvider(bvid));

    useEffect(() {
      ref.read(videoDetailControllerProvider(bvid).notifier).loadVideo();
      return null;
    }, []);

    return Scaffold(
      body: switch (controller) {
        Loading() => const Center(child: CircularProgressIndicator()),
        Success(:final response) => VideoDetailWidget(response),
        Error(:final errMsg) => Center(child: Text(errMsg ?? '加载失败')),
      },
    );
  }
}
```

### 步骤 4: 创建 Feature 入口

```dart
// features/video/video.dart
// Riverpod 实现
export 'package:PiliPlus/features/video/presentation/providers/video_controller.dart';
export 'package:PiliPlus/features/video/presentation/pages/video_page.dart';
export 'package:PiliPlus/features/video/data/di/video_di.dart';
```

---

## 🎯 下一步

选择一个 Feature 开始迁移：

1. **高优先级**（核心功能）
   - `features/video/` - 视频播放
   - `features/live/` - 直播
   - `features/auth/` - 认证

2. **中优先级**（重要功能）
   - `features/dynamics/` - 动态
   - `features/search/` - 搜索
   - `features/fav/` - 收藏夹

---

## 📝 检查清单

每个 Feature 迁移完成后，检查：

- [ ] Domain 层：entities, repositories, usecases
- [ ] Data 层：datasources, repositories 实现, DI
- [ ] Presentation 层：providers, pages, widgets
- [ ] Feature 入口文件
- [ ] 运行 `flutter analyze` 无错误
- [ ] 测试功能正常

---

**需要帮助？** 查看 [完整迁移指南](./CLEAN_ARCHITECTURE_MIGRATION.md)
