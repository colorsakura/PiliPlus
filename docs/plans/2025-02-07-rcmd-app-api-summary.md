# App端推荐API实现总结

## 概述

Bilibili的推荐API有两个版本：
- **Web端API**: `/x/web-interface/wbi/index/top/feed/rcmd` (需要WBI签名)
- **App端API**: `/x/v2/feed/index` (不需要WBI签名，使用不同的参数)

## 已有实现

### Dart实现 (已存在)

App端推荐API已经在 `lib/http/video.dart` 中实现：

```dart
static Future<LoadingState<List<RecVideoItemAppModel>>> rcmdVideoListApp({
  required int freshIdx,
}) async {
  // ...实现细节...
  final res = await Request().get(
    Api.recommendListApp,
    queryParameters: params,
    options: Options(headers: {...}),
  );
  // ...过滤和解析...
}
```

**关键点：**
- URL: `https://app.bilibili.com/x/v2/feed/index`
- 返回类型: `RecVideoItemAppModel`
- 过滤规则: 屏蔽广告、拉黑用户、内容分区过滤

### Rust实现 (新添加)

创建了新的Rust实现文件：`rust/src/api/rcmd_app.rs`

**函数：**
```rust
#[frb]
pub async fn get_recommend_list_app(ps: i32, fresh_idx: i32)
    -> Result<Vec<RcmdVideoInfo>, SerializableError>
```

**特性：**
- 纯Rust实现，不依赖Dart HTTP层
- 更快的JSON解析 (serde)
- 与Web端API相同的数据结构
- 自动过滤广告和视频内容

## 使用方式

### Dart版本 (推荐用于生产环境)

```dart
final result = await VideoHttp.rcmdVideoListApp(freshIdx: 0);

result.when(
  (videos) {
    print('Got ${videos.length} recommendations');
    for (final video in videos) {
      print('${video.title} - ${video.bvid}');
    }
  },
  (error) {
    print('Error: ${error.errMsg}');
  },
);
```

### Rust版本 (需要修复flutter_rust_bridge绑定)

```dart
final result = await getRecommendListApp(ps: 10, freshIdx: 0);
// result: List<RcmdVideoInfo>
```

**注意：** Rust版本的flutter_rust_bridge绑定尚未完全配置好，需要：
1. 重新生成Rust端分发器代码
2. 更新Dart端API定义
3. 验证funcId映射

## 数据模型差异

### Web端 (RecVideoItemModel)
- 来源: Web API
- 字段: `owner`, `stat`, `duration`, `pubdate`
- 数据结构: 嵌套的JSON结构

### App端 (RecVideoItemAppModel)
- 来源: App API
- 字段: `args` (包含up_name, up_id), `cover_right_text`
- 数据结构: 更扁平的JSON结构
- 特殊字段: `three_point_v2` (不感兴趣、反馈等)

## API对比

| 特性 | Web端API | App端API |
|------|---------|---------|
| URL | `/x/web-interface/wbi/index/top/feed/rcmd` | `/x/v2/feed/index` |
| 签名 | WBI签名 | 无需签名 |
| 认证 | 需要 (cookie) | 需要 (设备信息) |
| 响应格式 | Web推荐格式 | App推荐格式 |
| 过滤支持 | 黑名单、推荐过滤 | 黑名单、推荐过滤、广告过滤 |
| 推荐原因 | `rcmd_reason` | `rcmd_reason`, `bottom_rcmd_reason`, `top_rcmd_reason` |

## 当前状态

✅ **已完成：**
- Dart端App推荐API实现 (在`VideoHttp`中)
- Rust端App推荐API实现 (`rcmd_app.rs`)
- 数据模型定义 (`RecVideoItemAppModel`)
- 过滤和黑名单支持

⚠️ **待完成：**
- Rust版本的flutter_rust_bridge绑定配置
- 统一的facade模式 (Web/App切换)
- 性能对比测试

## 下一步建议

1. **立即可用**: 使用现有的Dart版本 `VideoHttp.rcmdVideoListApp`
2. **性能优化**: 完成Rust版本绑定后可提供更好的性能
3. **统一接口**: 创建统一facade支持Web/App端动态切换

## 测试

运行测试验证App端API:
```bash
flutter test test/test_rcmd_app_api.dart
```

预期结果:
- 成功获取推荐列表
- 正确过滤广告和黑名单用户
- 返回`RecVideoItemAppModel`类型的列表
