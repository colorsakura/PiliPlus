# 干净架构迁移指南

> PiliPlus 项目完整迁移到干净架构的方案文档

**版本:** 1.0
**更新日期:** 2026-02-25
**状态:** 进行中

---

## 📑 目录

- [1. 项目概述](#1-项目概述)
- [2. 干净架构原则](#2-干净架构原则)
- [3. 目标目录结构](#3-目标目录结构)
- [4. lib 目录变动方案](#4-lib-目录变动方案)
- [5. http 目录迁移方案](#5-http-目录迁移方案)
- [6. 迁移步骤](#6-迁移步骤)
- [7. 迁移检查清单](#7-迁移检查清单)
- [8. 参考资料](#8-参考资料)

---

## 1. 项目概述

### 当前项目状态

PiliPlus 是一个基于 Flutter 开发的 B 站第三方客户端，当前架构存在以下特点：

- **状态管理:** 正从 GetX 迁移到 Riverpod
- **已完成模块:** subscription, member 等已采用干净架构
- **待迁移模块:** 大部分功能仍使用旧架构
- **技术栈:** Flutter 3.41.2, Dart 3.10+, Riverpod 3.2.1, Dio 5.9.1

### 架构问题

1. **职责不清:** `http/` 目录混合了基础设施和业务逻辑
2. **依赖混乱:** 直接在 UI 层调用 HTTP 方法
3. **测试困难:** 业务逻辑与数据获取耦合
4. **代码重复:** 多处存在相似的数据处理逻辑

---

## 2. 干净架构原则

### 核心理念

```
┌─────────────────────────────────────────────┐
│         Presentation Layer                  │
│  (Widgets, Controllers, Providers)          │
└─────────────────┬───────────────────────────┘
                  │ depends on
┌─────────────────┴───────────────────────────┐
│           Domain Layer                      │
│  (Entities, Use Cases, Repository Interfaces)│
└─────────────────┬───────────────────────────┘
                  │ depends on
┌─────────────────┴───────────────────────────┐
│            Data Layer                       │
│  (Data Sources, Repository Implementations) │
└─────────────────────────────────────────────┘
```

### 依赖规则

1. **Domain Layer:** 不依赖任何外层，纯粹的业务逻辑
2. **Data Layer:** 实现 Domain 层定义的接口
3. **Presentation Layer:** 通过 Use Case 调用业务逻辑
4. **依赖方向:** 外层依赖内层，内层不依赖外层

---

## 3. 目标目录结构

```
lib/
├── main.dart                          # 应用入口
│
├── app/                               # 应用层配置
│   ├── router/                        # 路由配置
│   │   ├── router.dart               # 主路由
│   │   ├── routes.dart               # 路由定义
│   │   └── route_guards.dart         # 路由守卫
│   ├── theme/                         # 主题配置
│   │   ├── app_theme.dart
│   │   └── colors.dart
│   └── lifecycle/                      # 应用生命周期
│       └── app_lifecycle.dart
│
├── core/                              # 核心层（共享基础设施）
│   ├── constants/                     # 常量
│   │   ├── api_constants.dart        # API URL 常量
│   │   ├── app_constants.dart        # 应用常量
│   │   ├── live_api_constants.dart   # 直播 API 常量
│   │   ├── auth_api_constants.dart   # 认证 API 常量
│   │   └── storage_keys.dart         # 存储键
│   │
│   ├── errors/                        # 错误处理
│   │   ├── exceptions.dart           # 异常类
│   │   ├── failures.dart             # 失败类型
│   │   └── error_handler.dart        # 错误转换器
│   │
│   ├── network/                       # 网络层
│   │   ├── http_client.dart          # Dio 客户端配置
│   │   ├── http_interceptors/        # 拦截器
│   │   │   ├── retry_interceptor.dart
│   │   │   ├── logging_interceptor.dart
│   │   │   ├── auth_interceptor.dart  # 认证拦截器
│   │   │   └── account_interceptor.dart
│   │   ├── network_info.dart         # 网络状态
│   │   ├── retry_strategy.dart       # 重试策略
│   │   └── response_decoder.dart     # 响应解码 (gzip/brotli)
│   │
│   ├── storage/                       # 存储层
│   │   ├── storage_service.dart      # 存储服务接口
│   │   ├── hive_storage.dart         # Hive 实现
│   │   ├── mmkv_storage.dart         # MMKV 实现
│   │   └── secure_storage.dart       # 安全存储
│   │
│   ├── use_cases/                     # 通用用例
│   │   ├── usecase.dart              # UseCase 基类
│   │   └── async_usecase.dart        # 异步 UseCase 基类
│   │
│   └── utils/                         # 核心工具类
│       ├── logger.dart
│       ├── date_utils.dart
│       └── validators.dart
│
├── shared/                            # 共享层（跨 feature 共享）
│   ├── data/                          # 共享数据模型
│   │   └── models/
│   │       └── loading_state.dart    # 统一响应状态
│   │
│   ├── widgets/                       # 通用组件
│   │   ├── loading/
│   │   ├── empty/
│   │   ├── error/
│   │   ├── refresh/
│   │   └── video_card/              # 视频卡片组件
│   │
│   ├── mixins/                        # 通用 Mixin
│   │   ├── scroll_controller_mixin.dart
│   │   └── debouncer_mixin.dart
│   │
│   └── extensions/                    # 扩展方法
│       ├── context_ext.dart
│       ├── string_ext.dart
│       └── widget_ext.dart
│
├── features/                          # 功能特性层（按功能分模块）
│   │
│   ├── auth/                          # 认证功能
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── auth_local_datasource.dart
│   │   │   │   └── auth_remote_datasource.dart
│   │   │   ├── models/               # DTO（数据传输对象）
│   │   │   │   └── login_response_dto.dart
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/             # 领域实体
│   │   │   │   └── user.dart
│   │   │   ├── repositories/         # 仓库接口
│   │   │   │   └── auth_repository.dart
│   │   │   └── usecases/            # 用例
│   │   │       ├── login_usecase.dart
│   │   │       ├── get_qrcode_usecase.dart
│   │   │       ├── logout_usecase.dart
│   │   │       └── get_current_user_usecase.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   ├── auth_providers.dart
│   │   │   │   └── auth_controller.dart
│   │   │   ├── pages/
│   │   │   │   └── login_page.dart
│   │   │   └── widgets/
│   │   │       └── login_form.dart
│   │   ├── data/di/
│   │   │   └── auth_di.dart          # 依赖注入
│   │   └── auth.dart                 # Feature 入口（导出公开接口）
│   │
│   ├── video/                         # 视频播放功能
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   ├── video_local_datasource.dart
│   │   │   │   └── video_remote_datasource.dart
│   │   │   ├── models/
│   │   │   │   └── video_dto.dart
│   │   │   └── repositories/
│   │   │       └── video_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── video.dart
│   │   │   ├── repositories/
│   │   │   │   └── video_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_video_detail_usecase.dart
│   │   │       ├── get_video_url_usecase.dart
│   │   │       └── like_video_usecase.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── video_controller.dart
│   │   │   ├── pages/
│   │   │   │   └── video_page.dart
│   │   │   └── widgets/
│   │   │       ├── video_player.dart
│   │   │       └── danmaku_layer.dart
│   │   ├── data/di/
│   │   │   └── video_di.dart
│   │   └── video.dart
│   │
│   ├── live/                          # 直播功能
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── live_remote_datasource.dart
│   │   │   └── repositories/
│   │   │       └── live_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── live_room.dart
│   │   │   ├── repositories/
│   │   │   │   └── live_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_live_room_info_usecase.dart
│   │   │       └── send_danmaku_usecase.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   ├── pages/
│   │   │   └── widgets/
│   │   └── live.dart
│   │
│   ├── dynamics/                      # 动态功能
│   ├── user/                          # 用户功能
│   ├── search/                        # 搜索功能
│   ├── settings/                      # 设置功能
│   ├── subscription/                  # 订阅功能 ✅ 已完成
│   ├── member/                        # 用户空间功能 ✅ 已完成
│   └── ... (其他功能模块)
│
├── models/                            # 数据模型（外部 API 模型）
│   └── ... (保留现有的 proto 生成的模型)
│
├── grpc/                              # gRPC 定义
│   └── bilibili/
│
├── services/                          # 后台服务
│   ├── download/
│   └── sync/
│
└── utils/                            # 临时工具类（逐步迁移到 core/utils）
    └── ...
```

---

## 4. lib 目录变动方案

### 迁移优先级

#### 高优先级（已完成或进行中）
- ✅ `features/subscription/` - 已迁移到干净架构
- ✅ `features/member/` - 已迁移到干净架构

#### 中优先级（核心功能）
- `features/auth/` - 认证登录
- `features/video/` - 视频播放
- `features/live/` - 直播功能
- `features/dynamics/` - 动态发布
- `features/search/` - 搜索功能

#### 低优先级（辅助功能）
- `features/settings/` - 设置
- `features/fav/` - 收藏夹
- `features/history/` - 历史记录
- 其他辅助功能模块

### 每个 Feature 的迁移步骤

以 `video` 功能为例：

```
Step 1: 创建 Domain 层
  ├── domain/entities/video.dart
  ├── domain/repositories/video_repository.dart
  └── domain/usecases/
      ├── get_video_detail_usecase.dart
      ├── get_video_url_usecase.dart
      └── like_video_usecase.dart

Step 2: 创建 Data 层
  ├── data/datasources/
  │   ├── video_local_datasource.dart
  │   └── video_remote_datasource.dart
  ├── data/models/          # DTO 转换（如需要）
  └── data/repositories/
      └── video_repository_impl.dart

Step 3: 创建 Presentation 层
  ├── presentation/providers/
  │   ├── video_providers.dart
  │   └── video_controller.dart
  ├── presentation/pages/
  │   └── video_page.dart
  └── presentation/widgets/
      ├── video_player.dart
      └── danmaku_layer.dart

Step 4: 依赖注入
  └── data/di/video_di.dart

Step 5: 创建 Feature 入口
  └── video.dart
      // 导出所有公开接口

Step 6: 更新路由
  └── app/router/routes.dart
```

---

## 5. http 目录迁移方案

### 当前 http 目录结构

```
lib/http/
├── init.dart                    # Dio 实例初始化、Request 类
├── loading_state.dart           # 统一响应状态类型
├── constants.dart               # API URL 常量
├── api.dart                     # 所有 API 端点定义 (1000+ 行)
├── retry_interceptor.dart       # 重试拦截器
├── logging_interceptor.dart     # 日志拦截器
├── ua_type.dart                 # User-Agent 类型
├── video.dart                   # 视频 API 调用
├── login.dart                   # 登录 API 调用
├── dynamics.dart                # 动态 API 调用
├── live.dart                    # 直播 API 调用
├── user.dart                    # 用户 API 调用
├── search.dart                  # 搜索 API 调用
├── reply.dart                   # 评论 API 调用
├── follow.dart                  # 关注 API 调用
├── fav.dart                     # 收藏 API 调用
├── danmaku.dart                 # 弹幕 API 调用
├── download.dart                # 下载 API 调用
├── match.dart                   # 赛事 API 调用
├── music.dart                   # 音乐 API 调用
├── pgc.dart                     # 番剧 API 调用
├── sponsor_block.dart           # 赞助块 API 调用
├── validate.dart                # 验证 API 调用
├── black.dart                   # 黑名单 API 调用
├── fan.dart                     # 粉丝 API 调用
└── ... (约 25+ 个业务 API 文件)
```

### 问题识别

1. ❌ **职责混淆:** `http/` 目录混合了基础设施层（Dio配置、拦截器）和数据源层（业务API调用）
2. ❌ **单一职责违反:** 各个 API 文件（如 `video.dart`）直接返回 `LoadingState`，混合了数据获取和状态转换
3. ❌ **组织混乱:** `api.dart` 包含所有 API 端点（1000+ 行），缺乏按功能模块组织
4. ❌ **业务耦合:** 业务逻辑和数据获取混在一起，难以测试

### 迁移目标结构

```
lib/http/  →  拆分迁移到以下位置:

├── core/
│   ├── network/
│   │   ├── http_client.dart           # 来自 http/init.dart
│   │   ├── http_interceptors/
│   │   │   ├── retry_interceptor.dart # 来自 http/retry_interceptor.dart
│   │   │   └── logging_interceptor.dart # 来自 http/logging_interceptor.dart
│   │   └── response_decoder.dart      # 响应解码逻辑
│   │
│   ├── constants/
│   │   ├── api_constants.dart         # 来自 http/constants.dart 基础 URL
│   │   ├── video_api_constants.dart   # 来自 http/api.dart 视频相关端点
│   │   ├── live_api_constants.dart    # 来自 http/api.dart 直播相关端点
│   │   ├── auth_api_constants.dart    # 来自 http/api.dart 认证相关端点
│   │   └── ... (按功能拆分的 API 常量)
│   │
│   └── errors/
│       ├── exceptions.dart
│       └── failures.dart
│
├── shared/
│   └── data/
│       └── models/
│           └── loading_state.dart     # 来自 http/loading_state.dart
│
└── features/
    ├── video/
    │   └── data/
    │       └── datasources/
    │           └── video_remote_datasource.dart  # 来自 http/video.dart
    ├── live/
    │   └── data/
    │       └── datasources/
    │           └── live_remote_datasource.dart   # 来自 http/live.dart
    ├── auth/
    │   └── data/
    │       └── datasources/
    │           └── auth_remote_datasource.dart   # 来自 http/login.dart
    └── ... (其他功能的 datasources)
```

### 迁移对照表

| 旧文件路径 | 新位置 | 说明 |
|-----------|--------|------|
| `http/init.dart` | `core/network/http_client.dart` | Dio 客户端配置 |
| `http/loading_state.dart` | `shared/data/models/loading_state.dart` | 统一响应状态 |
| `http/constants.dart` | `core/constants/api_constants.dart` | API URL 常量 |
| `http/api.dart` | 拆分到各 `core/constants/*_api_constants.dart` | API 端点定义 |
| `http/retry_interceptor.dart` | `core/network/http_interceptors/retry_interceptor.dart` | 重试拦截器 |
| `http/logging_interceptor.dart` | `core/network/http_interceptors/logging_interceptor.dart` | 日志拦截器 |
| `http/ua_type.dart` | `core/constants/ua_constants.dart` | User-Agent 常量 |
| `http/video.dart` | `features/video/data/datasources/video_remote_datasource.dart` | 视频数据源 |
| `http/login.dart` | `features/auth/data/datasources/auth_remote_datasource.dart` | 认证数据源 |
| `http/live.dart` | `features/live/data/datasources/live_remote_datasource.dart` | 直播数据源 |
| `http/dynamics.dart` | `features/dynamics/data/datasources/dynamics_remote_datasource.dart` | 动态数据源 |
| `http/user.dart` | `features/user/data/datasources/user_remote_datasource.dart` | 用户数据源 |
| `http/search.dart` | `features/search/data/datasources/search_remote_datasource.dart` | 搜索数据源 |
| `http/reply.dart` | `features/reply/data/datasources/reply_remote_datasource.dart` | 评论数据源 |
| `http/follow.dart` | `features/follow/data/datasources/follow_remote_datasource.dart` | 关注数据源 |
| `http/fav.dart` | `features/fav/data/datasources/fav_remote_datasource.dart` | 收藏数据源 |
| `http/danmaku.dart` | `features/danmaku/data/datasources/danmaku_remote_datasource.dart` | 弹幕数据源 |
| `http/download.dart` | `features/download/data/datasources/download_remote_datasource.dart` | 下载数据源 |

---

## 6. 迁移步骤

### 第一阶段：建立核心基础设施

#### 1. 创建核心错误处理

```dart
// core/errors/exceptions.dart
abstract class AppException implements Exception {
  final String message;
  final int? code;

  const AppException(this.message, {this.code});
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code});
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException() : super('未授权或登录已过期');
}

class CacheException extends AppException {
  const CacheException(super.message);
}
```

```dart
// core/errors/failures.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? code;
  const ServerFailure(super.message, {this.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure() : super('未授权或登录已过期');
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}
```

```dart
// core/errors/error_handler.dart
class ErrorHandler {
  static Failure handleException(AppException exception) {
    if (exception is ServerException) {
      return ServerFailure(exception.message, code: exception.code);
    } else if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    } else if (exception is UnauthorizedException) {
      return const UnauthorizedFailure();
    } else if (exception is CacheException) {
      return CacheFailure(exception.message);
    }
    return Failure(exception.message);
  }

  static AppException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('网络连接超时');
      case DioExceptionType.connectionError:
        return const NetworkException('网络连接失败');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return const UnauthorizedException();
        }
        return ServerException(
          error.response?.data?['message'] ?? '服务器错误',
          code: statusCode,
        );
      default:
        return NetworkException('网络请求失败: ${error.message}');
    }
  }
}
```

#### 2. 创建网络层

```dart
// core/network/http_client.dart
import 'package:dio/dio.dart';
import 'package:PiliPlus/core/network/http_interceptors/retry_interceptor.dart';
import 'package:PiliPlus/core/network/http_interceptors/logging_interceptor.dart';
import 'package:PiliPlus/core/network/http_interceptors/account_interceptor.dart';
import 'package:PiliPlus/core/network/response_decoder.dart';
import 'package:PiliPlus/core/constants/api_constants.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class HttpClient {
  HttpClient._();

  static final Dio instance = _createDio();

  static Dio _createDio() {
    final options = BaseOptions(
      baseUrl: ApiConstants.apiBaseUrl,
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 10000),
      headers: {
        'user-agent': 'Dart/3.6 (dart:io)',
        'accept-encoding': 'br,gzip',
      },
      responseDecoder: ResponseDecoder.decoder,
      persistentConnection: true,
    );

    final dio = Dio(options)
      ..interceptors.addAll([
        RetryInterceptor(Pref.retryCount, Pref.retryDelay),
        AccountInterceptor(),
        if (kDebugMode) LoggingInterceptor(),
      ]);

    // 配置 HTTP/2 或 HTTP/1.1
    _configureHttpClientAdapter(dio);

    dio
      ..transformer = BackgroundTransformer()
      ..options.validateStatus = (int? status) {
        return status != null && status >= 200 && status < 300;
      };

    return dio;
  }

  static void _configureHttpClientAdapter(Dio dio) {
    // 迁移现有的 HTTP/2 配置逻辑
    final enableHttp2 = Pref.enableHttp2;
    // ... HTTP/2 或 HTTP/1.1 配置
  }
}

// 使用示例
class SomeRemoteDataSource {
  final Dio _httpClient = HttpClient.instance;

  Future<Map<String, dynamic>> fetchData() async {
    final response = await _httpClient.get('/some/endpoint');
    return response.data['data'];
  }
}
```

#### 3. 拆分 API 常量

```dart
// core/constants/api_constants.dart
abstract class ApiConstants {
  // 基础 URL
  static const String baseUrl = 'https://www.bilibili.com';
  static const String apiBaseUrl = 'https://api.bilibili.com';
  static const String tUrl = 'https://api.vc.bilibili.com';
  static const String appBaseUrl = 'https://app.bilibili.com';
  static const String liveBaseUrl = 'https://api.live.bilibili.com';
  static const String passBaseUrl = 'https://passport.bilibili.com';
  static const String messageBaseUrl = 'https://message.bilibili.com';
  static const String dynamicShareBaseUrl = 'https://t.bilibili.com';
  static const String spaceBaseUrl = 'https://space.bilibili.com';
  static const String accountBaseUrl = 'https://account.bilibili.com';
  static const String mallBaseUrl = 'https://mall.bilibili.com';
  static const String sponsorBlockBaseUrl = 'https://www.bsbsb.top';
}

// core/constants/video_api_constants.dart
abstract class VideoApiConstants {
  // 视频流
  static const String ugcUrl = '/x/player/wbi/playurl';

  // 视频详情
  static const String videoIntro = '/x/web-interface/view';

  // 点赞/投币/收藏
  static const String likeVideo = '$appBaseUrl/x/v2/view/like';
  static const String coinVideo = '$appBaseUrl/x/v2/view/coin/add';
  static const String favVideo = '/x/v3/fav/resource/batch-deal';

  // 相关视频
  static const String relatedList = '/x/web-interface/archive/related';

  // 视频互动
  static const String videoRelation = '/x/web-interface/archive/relation';
  static const String ugcTriple = '/x/web-interface/archive/like/triple';

  // 弹幕
  static const String shootDanmaku = '/x/v2/dm/post';
  static const String danmakuFilter = '/x/dm/filter/user';

  // AI 总结
  static const String aiConclusion = '/x/web-interface/view/conclusion/get';

  // 视频 Tag
  static const String videoTags = '/x/web-interface/view/detail/tag';
}

// core/constants/live_api_constants.dart
abstract class LiveApiConstants {
  // 直播列表
  static const String liveList = '$liveBaseUrl/xlive/web-interface/v1/second/getUserRecommend';

  // 直播间信息
  static const String liveRoomInfo = '$liveBaseUrl/xlive/web-room/v2/index/getRoomPlayInfo';
  static const String liveRoomInfoH5 = '$liveBaseUrl/xlive/web-room/v1/index/getH5InfoByRoom';

  // 弹幕
  static const String sendLiveMsg = '$liveBaseUrl/msg/send';
  static const String liveRoomDmPrefetch = '$liveBaseUrl/xlive/web-room/v1/dM/gethistory';
  static const String liveRoomDmToken = '$liveBaseUrl/xlive/web-room/v1/index/getDanmuInfo';

  // 礼物/超级聊天
  static const String superChatMsg = '$liveBaseUrl/av/v1/SuperChat/getMessageList';
}

// core/constants/auth_api_constants.dart
abstract class AuthApiConstants {
  // 二维码登录
  static const String getTVCode = '$passBaseUrl/x/passport-tv-login/qrcode/auth_code';
  static const String qrcodePoll = '$passBaseUrl/x/passport-tv-login/qrcode/poll';

  // 验证码
  static const String getCaptcha = '$passBaseUrl/x/passport-login/captcha?source=main_web';

  // 短信登录
  static const String smsCode = '$passBaseUrl/x/passport-login/web/sms/send';
  static const String logInByWebPwd = '$passBaseUrl/x/passport-login/web/login';

  // 退出登录
  static const String logout = '$passBaseUrl/login/exit/v2';

  // 用户信息
  static const String userInfo = '/x/web-interface/nav';
  static const String userStatOwner = '/x/web-interface/nav/stat';
}
```

#### 4. 创建响应解码器

```dart
// core/network/response_decoder.dart
import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:brotli/brotli.dart';

class ResponseDecoder {
  static const GZipDecoder _gzipDecoder = GZipDecoder();
  static const BrotliDecoder _brotliDecoder = BrotliDecoder();

  static List<int> decodeBytes(
    List<int> responseBytes,
    Map<String, List<String>> headers,
  ) {
    final encoding = headers['content-encoding']?.firstOrNull;

    switch (encoding) {
      case 'gzip':
        return _gzipDecoder.decodeBytes(responseBytes);
      case 'br':
        return _brotliDecoder.convert(responseBytes);
      default:
        return responseBytes;
    }
  }

  static String decoder(
    List<int> responseBytes,
    RequestOptions options,
    ResponseBody responseBody,
  ) {
    return utf8.decode(
      decodeBytes(responseBytes, responseBody.headers),
      allowMalformed: true,
    );
  }
}
```

#### 5. 拦截器迁移

```dart
// core/network/http_interceptors/retry_interceptor.dart
// (从 http/retry_interceptor.dart 迁移，保持现有逻辑)

// core/network/http_interceptors/logging_interceptor.dart
// (从 http/logging_interceptor.dart 迁移，保持现有逻辑)

// core/network/http_interceptors/account_interceptor.dart
// (从 http/init.dart 中的 AccountManager 迁移)
```

### 第二阶段：迁移通用组件和工具

#### 6. 迁移 LoadingState

```dart
// shared/data/models/loading_state.dart
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

sealed class LoadingState<T> {
  const LoadingState();

  factory LoadingState.loading() => const Loading._internal();

  bool get isSuccess => this is Success<T>;

  T get data => switch (this) {
    Success(:final response) => response,
    _ => throw this,
  };

  T? get dataOrNull => switch (this) {
    Success(:final response) => response,
    _ => null,
  };

  Future<void> toast() => SmartDialog.showToast(toString());
}

class Loading extends LoadingState<Never> {
  const Loading._internal();

  @override
  String toString() => 'ApiException: loading';
}

@immutable
class Success<T> extends LoadingState<T> {
  final T response;
  const Success(this.response);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is Success<T>) {
      return response == other.response;
    }
    return false;
  }

  @override
  int get hashCode => response.hashCode;
}

@immutable
class Error extends LoadingState<Never> {
  final int? code;
  final String? errMsg;
  const Error(this.errMsg, {this.code});

  @override
  String toString() => errMsg ?? code?.toString() ?? '';
}
```

### 第三阶段：逐个迁移 Feature

#### 7. 视频功能迁移示例

**Domain 层：**

```dart
// features/video/domain/entities/video.dart
class Video {
  final String bvid;
  final int aid;
  final String title;
  final String cover;
  final String ownerName;
  final int ownerMid;
  final int viewCount;
  final int danmakuCount;
  final int likeCount;
  final int coinCount;
  final int collectCount;
  final int shareCount;

  Video({
    required this.bvid,
    required this.aid,
    required this.title,
    required this.cover,
    required this.ownerName,
    required this.ownerMid,
    required this.viewCount,
    required this.danmakuCount,
    required this.likeCount,
    required this.coinCount,
    required this.collectCount,
    required this.shareCount,
  });
}
```

```dart
// features/video/domain/repositories/video_repository.dart
import 'package:PiliPlus/shared/data/models/loading_state.dart';

abstract class VideoRepository {
  /// 获取视频详情
  Future<LoadingState<Map<String, dynamic>>> getVideoDetail(String bvid);

  /// 获取视频播放 URL
  Future<LoadingState<Map<String, dynamic>>> getVideoPlayUrl({
    required int cid,
    required int qn,
  });

  /// 点赞视频
  Future<LoadingState<void>> likeVideo({
    required String bvid,
    required bool like,
  });

  /// 投币
  Future<LoadingState<void>> coinVideo({
    required String bvid,
    required int num,
  });

  /// 收藏
  Future<LoadingState<void>> favVideo({
    required String bvid,
    required List<int> folderIds,
  });
}
```

```dart
// features/video/domain/usecases/get_video_detail_usecase.dart
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';

class GetVideoDetailUseCase {
  final VideoRepository repository;

  GetVideoDetailUseCase(this.repository);

  Future<LoadingState<Map<String, dynamic>>> call(String bvid) {
    return repository.getVideoDetail(bvid);
  }
}
```

**Data 层：**

```dart
// features/video/data/datasources/video_remote_datasource.dart
import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/video_api_constants.dart';
import 'package:PiliPlus/core/errors/exceptions.dart';
import 'package:PiliPlus/core/errors/error_handler.dart';
import 'package:dio/dio.dart';

class VideoRemoteDataSource {
  final Dio _httpClient = HttpClient.instance;

  /// 获取视频详情
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

  /// 获取视频播放 URL
  Future<Map<String, dynamic>> getVideoPlayUrl({
    required int cid,
    required int qn,
  }) async {
    try {
      final response = await _httpClient.get(
        VideoApiConstants.ugcUrl,
        queryParameters: {'cid': cid, 'qn': qn},
      );

      if (response.data['code'] == 0) {
        return response.data['data'];
      } else {
        throw ServerException(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  /// 点赞视频
  Future<void> likeVideo({
    required String bvid,
    required bool like,
  }) async {
    try {
      final response = await _httpClient.post(
        VideoApiConstants.likeVideo,
        data: {
          'bvid': bvid,
          'like': like ? 1 : 2,
        },
      );

      if (response.data['code'] != 0) {
        throw ServerException(response.data['message']);
      }
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
```

```dart
// features/video/data/repositories/video_repository_impl.dart
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';
import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';
import 'package:PiliPlus/shared/data/models/loading_state.dart';
import 'package:PiliPlus/core/network/network_info.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<LoadingState<Map<String, dynamic>>> getVideoDetail(String bvid) async {
    if (!await networkInfo.isConnected) {
      return const Error('网络连接失败');
    }

    try {
      final data = await remoteDataSource.getVideoDetail(bvid: bvid);
      return Success(data);
    } on ServerException catch (e) {
      return Error(e.message, code: e.code);
    } on NetworkException catch (e) {
      return Error(e.message);
    } catch (e) {
      return Error('未知错误: $e');
    }
  }

  @override
  Future<LoadingState<Map<String, dynamic>>> getVideoPlayUrl({
    required int cid,
    required int qn,
  }) async {
    try {
      final data = await remoteDataSource.getVideoPlayUrl(cid: cid, qn: qn);
      return Success(data);
    } on ServerException catch (e) {
      return Error(e.message, code: e.code);
    } on NetworkException catch (e) {
      return Error(e.message);
    } catch (e) {
      return Error('获取播放地址失败');
    }
  }

  @override
  Future<LoadingState<void>> likeVideo({
    required String bvid,
    required bool like,
  }) async {
    try {
      await remoteDataSource.likeVideo(bvid: bvid, like: like);
      return const Success(null);
    } catch (e) {
      return Error('操作失败');
    }
  }

  @override
  Future<LoadingState<void>> coinVideo({
    required String bvid,
    required int num,
  }) async {
    // 实现
  }

  @override
  Future<LoadingState<void>> favVideo({
    required String bvid,
    required List<int> folderIds,
  }) async {
    // 实现
  }
}
```

**依赖注入：**

```dart
// features/video/data/di/video_di.dart
import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';
import 'package:PiliPlus/features/video/data/repositories/video_repository_impl.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';
import 'package:PiliPlus/core/network/network_info.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 数据源 Provider
final videoRemoteDataSourceProvider = Provider<VideoRemoteDataSource>((ref) {
  return VideoRemoteDataSource();
});

// 仓库 Provider
final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  return VideoRepositoryImpl(
    remoteDataSource: ref.watch(videoRemoteDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// 网络状态 Provider（全局）
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl();
});
```

**Presentation 层：**

```dart
// features/video/presentation/providers/video_providers.dart
import 'package:PiliPlus/features/video/domain/usecases/get_video_detail_usecase.dart';
import 'package:PiliPlus/features/video/data/di/video_di.dart';
import 'package:PiliPlus/shared/data/models/loading_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// UseCase Provider
final getVideoDetailUseCaseProvider = Provider<GetVideoDetailUseCase>((ref) {
  return GetVideoDetailUseCase(
    ref.watch(videoRepositoryProvider),
  );
});

// Video Detail Controller Provider
final videoDetailControllerProvider =
    StateNotifierProvider<VideoDetailController, LoadingState>((ref) {
  return VideoDetailController(
    ref.watch(getVideoDetailUseCaseProvider),
  );
});

class VideoDetailController extends StateNotifier<LoadingState> {
  final GetVideoDetailUseCase _getVideoDetailUseCase;

  VideoDetailController(this._getVideoDetailUseCase)
      : super(const Loading());

  Future<void> loadVideo(String bvid) async {
    state = const Loading();
    state = await _getVideoDetailUseCase(bvid);
  }
}

// Video Play URL Controller Provider
final videoPlayUrlControllerProvider =
    StateNotifierProvider.family<VideoPlayUrlController, LoadingState, int>((ref, cid) {
  return VideoPlayUrlController(
    ref.watch(videoRepositoryProvider),
    cid,
  );
});

class VideoPlayUrlController extends StateNotifier<LoadingState> {
  final VideoRepository _repository;
  final int _cid;

  VideoPlayUrlController(this._repository, this._cid)
      : super(const Loading());

  Future<void> loadUrl({int qn = 80}) async {
    state = const Loading();
    state = await _repository.getVideoPlayUrl(cid: _cid, qn: qn);
  }
}
```

**Feature 入口：**

```dart
// features/video/video.dart
// Riverpod 实现（新）
export 'package:PiliPlus/features/video/presentation/providers/video_providers.dart';
export 'package:PiliPlus/features/video/presentation/pages/video_page.dart';
export 'package:PiliPlus/features/video/data/di/video_di.dart';
```

### 第四阶段：清理旧代码

#### 8. 删除已迁移的代码

迁移完成后，逐步删除旧代码：

```bash
# 删除已迁移的 http 目录文件
rm lib/http/init.dart
rm lib/http/loading_state.dart
rm lib/http/constants.dart
rm lib/http/api.dart
rm lib/http/retry_interceptor.dart
rm lib/http/logging_interceptor.dart
rm lib/http/video.dart
rm lib/http/login.dart
# ... 其他已迁移的文件

# 最终删除整个 http 目录（当所有文件都迁移完成后）
rm -rf lib/http/
```

#### 9. 更新路由

```dart
// app/router/routes.dart
import 'package:PiliPlus/features/video/video.dart';
import 'package:PiliPlus/features/auth/auth.dart';
import 'package:PiliPlus/features/live/live.dart';

// 使用 Feature 导出的页面
class AppRoutes {
  static const String video = '/video';
  static const String login = '/login';
  static const String live = '/live';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.video:
        return MaterialPageRoute(
          builder: (_) => const VideoPage(),
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      // ... 其他路由
      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundPage(),
        );
    }
  }
}
```

---

## 7. 迁移检查清单

### 核心层检查清单

- [ ] **core/network/** 网络基础设施
  - [ ] `http_client.dart` - Dio 客户端配置完成
  - [ ] `http_interceptors/` - 所有拦截器迁移完成
  - [ ] `network_info.dart` - 网络状态检测
  - [ ] `response_decoder.dart` - 响应解码器

- [ ] **core/constants/** 常量定义
  - [ ] `api_constants.dart` - 基础 URL 常量
  - [ ] `video_api_constants.dart` - 视频 API 常量
  - [ ] `live_api_constants.dart` - 直播 API 常量
  - [ ] `auth_api_constants.dart` - 认证 API 常量
  - [ ] 其他 API 常量按功能拆分完成

- [ ] **core/errors/** 错误处理
  - [ ] `exceptions.dart` - 异常定义
  - [ ] `failures.dart` - 失败类型
  - [ ] `error_handler.dart` - 错误转换器

### 共享层检查清单

- [ ] **shared/data/models/**
  - [ ] `loading_state.dart` - 统一响应状态

- [ ] **shared/widgets/** 通用组件
  - [ ] 通用 loading 组件
  - [ ] 通用 empty 组件
  - [ ] 通用 error 组件

- [ ] **shared/mixins/** 通用 Mixin
- [ ] **shared/extensions/** 扩展方法

### Feature 检查清单（每个功能模块）

- [ ] **Domain 层**
  - [ ] `entities/` - 领域实体定义
  - [ ] `repositories/` - 仓库接口定义
  - [ ] `usecases/` - 用例实现

- [ ] **Data 层**
  - [ ] `datasources/` - 数据源实现
  - [ ] `models/` - DTO 定义（如需要）
  - [ ] `repositories/` - 仓库实现
  - [ ] `di/` - 依赖注入配置

- [ ] **Presentation 层**
  - [ ] `providers/` - Riverpod providers
  - [ ] `pages/` - 页面实现
  - [ ] `widgets/` - 组件实现

- [ ] **Feature 入口**
  - [ ] Feature 导出文件创建

### 清理检查清单

- [ ] 删除已迁移的 `http/` 目录文件
- [ ] 删除已迁移的 `pages/` 目录文件
- [ ] 删除已迁移的 `utils/` 目录文件
- [ ] 更新所有 import 路径
- [ ] 运行 `flutter pub get`
- [ ] 运行 `flutter analyze` 无错误
- [ ] 运行测试验证功能完整性

---

## 8. 参考资料

### 干净架构相关

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture Example](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Riverpod Documentation](https://riverpod.dev/)

### 项目内参考

- 已完成模块: `lib/features/subscription/`
- 已完成模块: `lib/features/member/`
- 参考: `lib/features/home/README.md`

### 相关工具

- [Dio Documentation](https://pub.dev/packages/dio)
- [Riverpod Generator](https://riverpod.dev/docs/concepts/generators/)
- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)

---

## 附录：快速参考

### 文件命名规范

| 类型 | 命名规范 | 示例 |
|-----|---------|------|
| Feature 目录 | 小写，单词用下划线 | `video_detail/` |
| Entity 文件 | 小写，单词用下划线 | `video.dart` |
| Repository 接口 | 小写，单词用下划线，`_repository.dart` 后缀 | `video_repository.dart` |
| Repository 实现 | 小写，单词用下划线，`_repository_impl.dart` 后缀 | `video_repository_impl.dart` |
| DataSource | 小写，单词用下划线，`_datasource.dart` 后缀 | `video_remote_datasource.dart` |
| UseCase | 小写，单词用下划线，`_usecase.dart` 后缀 | `get_video_detail_usecase.dart` |
| Provider | 小写，单词用下划线，`_providers.dart` 后缀 | `video_providers.dart` |
| DI 配置 | 小写，单词用下划线，`_di.dart` 后缀 | `video_di.dart` |

### Import 顺序规范

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 3. 第三方包
import 'package:dio/dio.dart';

// 4. 项目核心层
import 'package:PiliPlus/core/network/http_client.dart';
import 'package:PiliPlus/core/constants/api_constants.dart';

// 5. 项目共享层
import 'package:PiliPlus/shared/data/models/loading_state.dart';

// 6. 项目 Domain 层
import 'package:PiliPlus/features/video/domain/entities/video.dart';
import 'package:PiliPlus/features/video/domain/repositories/video_repository.dart';

// 7. 项目 Data 层
import 'package:PiliPlus/features/video/data/datasources/video_remote_datasource.dart';
```

---

**文档维护:** 请在每次重要更新后更新版本号和更新日期
**问题反馈:** 请在项目 issue 中提交迁移过程中的问题
