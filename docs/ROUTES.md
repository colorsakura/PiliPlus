# PiliPlus 路由文档

> 项目完整路由配置与使用说明

最后更新: 2026-02-28 (Phase 13: go_router 迁移)

---

## 目录

- [概述](#概述)
- [一、路由系统架构](#一路由系统架构)
- [二、go_router 路由](#二go_router-路由)
- [三、GetX 命名路由](#三getx-命名路由)
- [四、页面静态跳转方法](#四页面静态跳转方法)
- [五、Deep Link / Scheme 路由](#五deep-link--scheme-路由)
- [六、HTTPS 路由](#六https-路由)
- [七、工具类路由方法](#七工具类路由方法)
- [八、弹窗/面板类路由](#八弹窗面板类路由)
- [九、路由配置文件](#九路由配置文件)
- [十、使用示例](#十使用示例)

---

## 概述

PiliPlus 使用 **混合路由系统**：主要使用 go_router (Phase 13 迁移)，同时保留部分 GetX 路由用于兼容性。

### 路由类型统计 (2026-02-28)

| 类型 | 数量 | 状态 |
|------|------|------|
| go_router 路由 | 56+ 个 | ✅ 主要路由系统 |
| GetX 命名路由 | 67 个 | 🔄 逐步迁移中 |
| Deep Link Host | 19 个 | ✅ 完整支持 |
| HTTPS 域名 | 7 个 | ✅ 完整支持 |
| 页面静态方法 | 15+ 个 | ✅ 完整支持 |
| 工具类方法 | 20+ 个 | ✅ 完整支持 |
| 弹窗/面板路由 | 25+ 个 | ✅ 完整支持 |
| **总计** | **150+ 个** | - |

---

## 一、路由系统架构

### 1.1 双路由系统 (过渡期)

项目正在从 GetX 迁移到 go_router：

```
┌─────────────────────────────────────────┐
│          PiliPlus 路由层                  │
├─────────────────────────────────────────┤
│                                         │
│  ┌──────────────┐    ┌──────────────┐  │
│  │  go_router   │    │    GetX      │  │
│  │  (主要系统)   │    │  (兼容层)     │  │
│  │              │    │              │  │
│  │ • /videoV    │    │ • 其他路由    │  │
│  │ • /home      │    │   (待迁移)    │  │
│  │ • 动态路由    │    │              │  │
│  └──────────────┘    └──────────────┘  │
│         ↕                   ↕          │
│  ┌─────────────────────────────────┐   │
│  │     PageUtils (统一接口)          │   │
│  └─────────────────────────────────┘   │
└─────────────────────────────────────────┘
```

### 1.2 迁移进度

- ✅ **Phase 13 (完成)**: 视频详情页迁移到 go_router
- ⏳ **Phase 14+ (规划)**: 其他页面逐步迁移

---

## 二、go_router 路由

### 2.1 配置文件

路由配置位于 `lib/app/router/go_router_config.dart`

### 2.2 已迁移路由

| 路径 | 页面组件 | 参数传递方式 | 参数 | 迁移版本 |
|------|---------|-------------|------|---------|
| `/videoV` | VideoDetailPageV | `state.extra` (Map) | `aid`, `bvid`, `cid`, `seasonId`, `epId`, `cover`, `title`, `progress`, `videoType`, `heroTag` | Phase 13 |

### 2.3 go_router 使用方法

#### 推荐：使用 PageUtils 工具类

```dart
// 跳转视频详情页 (自动使用 go_router)
PageUtils.toVideoPage(
  bvid: 'BV1xx411c7mD',
  cid: 123456,
  cover: 'https://...',
);
```

#### 直接使用 go_router

```dart
import 'package:go_router/go_router.dart';

// Push (添加到导航栈)
context.pushNamed(
  AppRoutes.video,
  extra: {
    'bvid': 'BV1xx411c7mD',
    'cid': 123456,
    'cover': 'https://...',
    'videoType': VideoType.ugc,
    'heroTag': Utils.makeHeroTag(123456),
  },
);

// Replace (替换当前页面)
context.pushReplacementNamed(
  AppRoutes.video,
  extra: {...},
);

// Go (清空导航栈并跳转)
context.goNamed(
  AppRoutes.video,
  extra: {...},
);
```

### 2.4 参数接收模式

在 ConsumerStatefulWidget 中接收 go_router 传递的参数：

```dart
class VideoDetailPageV extends ConsumerStatefulWidget {
  const VideoDetailPageV({super.key, this.args});

  final Map<String, dynamic> args;  // go_router 通过 state.extra 传递

  @override
  ConsumerState<VideoDetailPageV> createState() => _VideoDetailPageVState();
}

class _VideoDetailPageVState extends ConsumerState<VideoDetailPageV> {
  @override
  void initState() {
    super.initState();

    // 使用 widget.args (来自 go_router)
    final args = widget.args;

    // 传递给 Provider
    ref.read(videoDetailProvider.notifier).setArgs(args);

    // 传递给 Controller
    videoDetailController = VideoDetailController(args: args);
  }
}
```

---

## 三、GetX 命名路由
---

## 一、GetX 命名路由

所有命名路由定义在 `lib/app/router/app_pages.dart` 中的 `Routes.getPages` 列表。

### 1.1 主页面路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/` | ShellPage | - | 主入口/Shell 页面 |
| `/home` | HomePage | - | 首页(推荐) |
| `/hot` | HotPage | - | 热门页面 |
| `/mine` | - | - | 我的页面 (通过 Shell 导航) |

### 1.2 内容播放路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/videoV` | VideoDetailPageV | `aid`, `bvid`, `cid`, `seasonId`, `epId`, `cover`, `title`, `progress`, `videoType`, `heroTag` | 视频详情页 |
| `/liveRoom` | LiveRoomPage | `roomId` (arguments) | 直播详情 |
| `/audio` | AudioPage | `oid`, `itemType`, `from`, `id`, `subId`, `heroTag`, `start`, `audioUrl`, `extraId` | 音频播放页 |
| `/webview` | WebviewPage | `url` (parameters), `oid`, `title`, `uaType` (arguments) | WebView 页面 |
| `/dlna` | DlnaPage | `url`, `title` (arguments) | DLNA 投屏页面 |

### 1.3 用户相关路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/member` | MemberPage | `mid` (parameters) | 用户中心 |
| `/memberSearch` | MemberSearchPageV2 | - | 用户搜索 |
| `/follow` | FollowPageV2 | `mid` (parameters) | 关注页面 |
| `/fan` | FanPageV2 | `mid`, `name` (arguments) | 粉丝页面 |
| `/followed` | FollowedPageV2 | `mid` (parameters) | 互关页面 |
| `/sameFollowing` | FollowSamePageV2 | `mid` (parameters) | 共同关注 |
| `/memberDynamics` | MemberDynamicsPageV2 | - | 用户动态 |

### 1.4 内容展示路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/dynamics` | DynamicsPage | - | 动态页面 |
| `/dynamicDetail` | DynamicDetailPage | `item` (arguments) | 动态详情 |
| `/articlePage` | ArticlePage | `id`, `type` (parameters) | 专栏文章页 |
| `/articleList` | ArticleListPage | `id` (parameters) | 专栏列表 |
| `/pgcReview` | PgcReviewPageV2 | - | 番剧点评 |
| `/search` | SearchPage | - | 搜索页面 |
| `/searchResult` | SearchResultPageV2 | `keyword` (parameters) | 搜索结果 |

### 1.5 收藏历史路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/fav` | FavPage | `index` (arguments, tab索引) | 收藏页面 |
| `/favDetail` | FavDetailPage | `mediaId`, `heroTag` (parameters) | 收藏详情 |
| `/favSearch` | FavSearchPage | - | 收藏搜索 |
| `/later` | LaterPage | - | 稍后再看 |
| `/history` | HistoryPageV2 | - | 历史记录 |
| `/historySearch` | HistorySearchPage | - | 历史记录搜索 |

### 1.6 消息通知路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/whisper` | WhisperPage | - | 私信列表 |
| `/whisperDetail` | WhisperDetailPage | `talkerId` (arguments) | 私信详情 |
| `/replyMe` | MsgReplyMePageV2 | - | 回复我的 |
| `/atMe` | MsgAtMePageV2 | - | @我的 |
| `/likeMe` | MsgLikeMePageV2 | - | 收到的赞 |
| `/sysMsg` | MsgSysMsgPageV2 | - | 系统消息 |
| `/msgLikeDetail` | LikeDetailPageV2 | `cardId`, `uri`, `counts` (parameters) | 赞详情 |
| `/mainReply` | MainReplyPage | `oid`, `replyType` (arguments) | 主回复页面 |

### 1.7 订阅相关路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/subscription` | SubPage | - | 订阅页面 |
| `/subDetail` | SubDetailPage | - | 订阅详情 |

### 1.8 设置相关路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/setting` | SettingPage | - | 设置页面 |
| `/recommendSetting` | RecommendSetting | - | 推荐流设置 |
| `/videoSetting` | VideoSetting | - | 音视频设置 |
| `/playSetting` | PlaySetting | - | 播放器设置 |
| `/styleSetting` | StyleSetting | - | 外观设置 |
| `/privacySetting` | PrivacySetting | - | 隐私设置 |
| `/extraSetting` | ExtraSetting | - | 其它设置 |
| `/barSetting` | BarSetPage | - | 栏目设置 |
| `/colorSetting` | ColorSelectPage | - | 颜色设置 |
| `/fontSizeSetting` | FontSizeSelectPage | - | 字体大小设置 |
| `/displayModeSetting` | SetDisplayMode | - | 屏幕帧率设置 |
| `/playSpeedSet` | PlaySpeedPage | - | 播放速度设置 |
| `/settingsSearch` | SettingsSearchPage | - | 设置搜索 |

### 1.9 账户功能路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/loginPage` | LoginPage | - | 登录页面 |
| `/spaceSetting` | SpaceSettingPage | - | 空间设置 |
| `/editProfile` | EditProfilePage | - | 编辑个人资料 |
| `/blackListPage` | BlacklistPage | - | 黑名单页面 |
| `/webdavSetting` | BackupPage | - | WebDAV/备份设置 |
| `/about` | AboutPage | - | 关于页面 |

### 1.10 其他功能路由

| 路径 | 页面组件 | 参数/Arguments | 说明 |
|------|---------|----------------|------|
| `/danmakuBlock` | DanmakuBlockPageV2 | - | 弹幕屏蔽管理 |
| `/sponsorBlock` | SponsorBlockPage | - | 赞助屏蔽 |
| `/liveDmBlockPage` | LiveDmBlockPageV2 | - | 直播弹幕屏蔽 |
| `/searchTrending` | SearchTrendingPage | - | 搜索趋势 |
| `/dynTopic` | DynTopicPage | `id` (parameters) | 动态话题 |
| `/dynTopicRcmd` | DynTopicRcmdPage | - | 动态话题推荐 |
| `/createFav` | CreateFavPage | - | 创建收藏夹 |
| `/createVote` | CreateVotePage | - | 创建投票 |
| `/matchInfo` | MatchInfoPage | `cid` (parameters) | 比赛信息 |
| `/upowerRank` | UpowerRankPage | - | 充电排行榜 |
| `/popularSeries` | PopularSeriesPage | - | 热门系列 |
| `/popularPrecious` | PopularPreciousPage | - | 热门珍藏 |
| `/musicDetail` | MusicDetailPage | `musicId` (parameters) | 音乐详情 |
| `/download` | DownloadPage | - | 下载页面 |

---

## 二、页面静态跳转方法

许多页面定义了静态的 `to*Page` 方法，提供更便捷和类型安全的导航方式。

### 2.1 用户相关方法

```dart
// 关注页面
FollowPageV2.toFollowPage({
  required dynamic mid,
  String? name,
  bool isOwner = false,
})

// 粉丝页面
FanPageV2.toFanPage({int? mid, String? name})
FanPageV2.toFansPage({dynamic mid, String? name})  // 别名

// 互关页面
FollowedPageV2.toFollowedPage({dynamic mid, String? name})

// 共同关注
FollowSamePageV2.toFollowSamePage({dynamic mid, String? name})
```

### 2.2 内容相关方法

```dart
// 音频播放
AudioPage.toAudioPage({
  int? id,
  required int oid,
  List<int>? subId,
  required int itemType,
  required PlaylistSource from,
  String? heroTag,
  Duration? start,
  String? audioUrl,
  int? extraId,
})

// 订阅详情
SubDetailPage.toSubDetailPage(
  int id, {
  String? heroTag,
  SubItemModel? subInfo,
})

// 主回复页
MainReplyPage.toMainReplyPage({
  required int oid,
  required int replyType,
})

// 视频回复
VideoReplyReplyPanel.toReply({
  required int oid,
  required int rootId,
  String? rpIdStr,
  required int type,
  Uri? uri,
})
```

### 2.3 功能相关方法

```dart
// DLNA 投屏
DlnaPage.toDlnaPage({
  required String url,
  String? title,
})

// WebView
WebviewPage.toWebviewPage({
  String? url,
  int? oid,
  String? title,
  UaType? uaType,
})

// 联系人
ContactPage.toContactPage({bool isFromSelect = true})

// 收藏面板
SavePanel.toSavePanel({dynamic upMid, dynamic item})
```

---

## 三、Deep Link / Scheme 路由

项目支持 `bilibili://` 自定义协议，定义在 `lib/utils/app_scheme.dart` 的 `PiliScheme.routePush` 方法中。

### 3.1 bilibili:// 协议

| Host | 路径格式 | 说明 |
|------|----------|------|
| `root` | `bilibili://root` | 返回首页 |
| `pgc` | `bilibili://pgc/season/ep/{id}` | 番剧剧集 |
| `space` | `bilibili://space/{mid}` | 用户空间 |
| `video` | `bilibili://video/{aid}` | 视频 |
| `live` | `bilibili://live/{roomId}` | 直播间 |
| `bangumi` | `bilibili://bangumi/season/{seasonId}` | 番剧季度 |
| `opus` | `bilibili://opus/{id}` | 动态/稿件 |
| `search` | `bilibili://search?keyword={keyword}` | 搜索 |
| `article` | `bilibili://article/{id}` | 专栏 |
| `comment` | `bilibili://comment/detail/{type}/{oid}/{rootId}` | 评论 |
| `following` | `bilibili://following/detail/{dynId}` | 动态详情 |
| `album` | `bilibili://album/{rid}` | 相册 |
| `medialist` | `bilibili://medialist/{mediaId}` | 播单/收藏夹 |
| `browser` | `bilibili://browser?url={url}` | 浏览器 |
| `cheese` | `bilibili://cheese/season/{seasonId}` | 课程 |
| `history` | `bilibili://history` | 历史记录 |
| `main` | `bilibili://main/favorite?tab={tab}` | 收藏 |
| `livearea` | `bilibili://livearea` | 直播区 |
| `rank` | `bilibili://rank` | 排行榜 |
| `login` | `bilibili://login` | 登录 |
| `music` | `bilibili://music/playlist/{mediaId}` | 音乐 |

### 3.2 查询参数支持

部分 Scheme 支持额外的查询参数：

```dart
// 视频带进度和弹幕
bilibili://video/{aid}?dm_progress={ms}&cid={cid}&dmid={dmid}

// 番剧带进度
bilibili://pgc/season/ep/{epId}?start_progress={ms}

// 评论跳转
bilibili://video/{aid}?comment_root_id={rootId}&comment_secondary_id={secondaryId}

// 搜索关键词
bilibili://search?keyword={keyword}
```

---

## 四、HTTPS 路由

项目支持通过 HTTPS URL 进行路由跳转，定义在 `lib/utils/app_scheme.dart` 的 `_fullPathPush` 方法中。

### 4.1 支持的域名

| 域名 | 用途 |
|------|------|
| `b23.tv` | 短链接重定向 |
| `t.bilibili.com` | 动态 |
| `live.bilibili.com` | 直播 |
| `space.bilibili.com` | 用户空间 |
| `search.bilibili.com` | 搜索 |
| `music.bilibili.com` | 音乐 |
| `www.bilibili.com` | 主站路由 |
| `m.bilibili.com` | 移动端路由 |

### 4.2 路径模式

#### 视频相关

```
https://www.bilibili.com/video/{bvid}
https://www.bilibili.com/video/av{aid}
https://www.bilibili.com/video/{bvid}?p={part}
```

#### 番剧相关

```
https://www.bilibili.com/bangumi/play/ep{epId}
https://www.bilibili.com/bangumi/play/ss{seasonId}
https://www.bilibili.com/bangumi/play/ep{epId}?start_progress={ms}
```

#### 专栏相关

```
https://www.bilibili.com/read/cv{cvid}
https://www.bilibili.com/read/readlist/rl{id}
```

#### 用户相关

```
https://space.bilibili.com/{mid}
https://space.bilibili.com/{mid}/relation/follow
https://space.bilibili.com/{mid}/relation/fans
https://space.bilibili.com/{mid}/relation/followed
https://space.bilibili.com/h5/follow?mid={mid}&type={type}
https://space.bilibili.com/{mid}/lists/{seasonId}
```

#### 播放列表

```
https://m.bilibili.com/playlist/pl{mediaId}?bvid={bvid}
```

#### 收藏夹

```
https://www.bilibili.com/medialist/detail/ml{mediaId}
```

#### 动态相关

```
https://www.bilibili.com/opus/{id}
https://t.bilibili.com/{id}
https://m.bilibili.com/dynamic/{id}
```

#### 直播相关

```
https://live.bilibili.com/{roomId}
```

#### 搜索相关

```
https://search.bilibili.com?keyword={keyword}
```

#### 音乐相关

```
https://music.bilibili.com/pc/music-detail?music_id={musicId}
https://music.bilibili.com/h5-music-detail?music_id={musicId}
```

#### 课程相关

```
https://www.bilibili.com/cheese/play/ss{seasonId}
https://www.bilibili.com/cheese/play/ep{epId}
```

#### 音频相关

```
https://www.bilibili.com/audio/au{oid}
```

#### 笔记相关

```
https://www.bilibili.com/note?cvid={cvid}
https://m.bilibili.com/note-app?cvid={cvid}
```

#### 话题相关

```
https://www.bilibili.com/topic?topic_id={id}
https://m.bilibili.com/topic-detail?topic_id={id}
```

#### 评论相关

```
https://www.bilibili.com/h5/comment/sub?oid={oid}&pageType={type}&root={rootId}
```

#### 比赛相关

```
https://www.bilibili.com/match/data/detail/{cid}
https://www.bilibili.com/match/singledata/{cid}
```

---

## 五、工具类路由方法

### 5.1 PageUtils 工具类

定义在 `lib/utils/page_utils.dart`，提供常用的页面跳转方法。

#### 视频播放

```dart
PageUtils.toVideoPage({
  VideoType videoType = VideoType.ugc,
  int? aid,
  String? bvid,
  required int cid,
  int? seasonId,
  int? epId,
  int? pgcType,
  String? cover,
  String? title,
  int? progress,  // 毫秒
  Map? extraArguments,
  bool off = false,
})
```

#### 直播

```dart
PageUtils.toLiveRoom(int? roomId, {bool off = false})
```

#### 番剧/课程

```dart
// 番剧
PageUtils.viewPgc({
  dynamic seasonId,
  dynamic epId,
  int? progress,  // 毫秒
})

// 课程
PageUtils.viewPugv({
  dynamic seasonId,
  dynamic epId,
  int? aid,
})

// 从 URI 解析番剧
PageUtils.viewPgcFromUri(
  String uri, {
  bool isPgc = true,
  int? progress,
  int? aid,
})  // 返回 bool
```

#### 动态

```dart
// 跳转动态详情（传入完整 item）
PageUtils.pushDynDetail(
  DynamicItemModel item, {
  bool isPush = false,
})

// 通过 ID 跳转动态（需要网络请求）
PageUtils.pushDynFromId({
  String? id,
  Object? rid,
  bool off = false,
})
```

#### WebView

```dart
// 应用内 WebView
PageUtils.inAppWebview(String url, {bool off = false})

// 处理 WebView（支持外部浏览器配置）
PageUtils.handleWebview(
  String url, {
  bool off = false,
  bool inApp = false,
  Map? parameters,
})
```

#### 弹窗/面板

```dart
// 图片查看器
PageUtils.imageView({
  int initialPage = 0,
  required List<SourceModel> imgList,
  int? quality,
})

// 收藏底部弹窗
PageUtils.showFavBottomSheet({
  required BuildContext context,
  required FavMixin ctr,
})

// 视频底部弹窗
PageUtils.showVideoBottomSheet(
  BuildContext context, {
  required Widget child,
  required ValueGetter<bool> isFullScreen,
  double? padding,
})
```

#### 其他

```dart
// 举报视频
PageUtils.reportVideo(int aid)

// 分享
PageUtils.pmShare(
  BuildContext context, {
  required Map content,
})

// 画中画
PageUtils.enterPip({int? width, int? height, bool isAuto = false})
```

### 5.2 PiliScheme 工具类

定义在 `lib/utils/app_scheme.dart`，处理 Deep Link 和 URL 跳转。

```dart
// URI 路由跳转
PiliScheme.routePush(
  Uri uri, {
  bool selfHandle = false,
  bool off = false,
  Map? parameters,
  int? businessId,
  int? oid,
})  // 返回 Future<bool>

// URL 字符串跳转
PiliScheme.routePushFromUrl(
  String url, {
  bool selfHandle = false,
  bool off = false,
  Map? parameters,
  int? businessId,
  int? oid,
})  // 返回 Future<bool>

// 视频推送（需要获取 cid）
PiliScheme.videoPush(
  int? aid,
  String? bvid, {
  bool showDialog = true,
  bool off = false,
  int? progress,  // 毫秒
  String? part,   // 分 P
})
```

---

## 六、弹窗/面板类路由

这些页面不通过命名路由注册，而是直接使用 `Navigator.push`、`Get.to` 或 `showModalBottomSheet` 显示。

### 6.1 推送类页面

| 页面 | 说明 | 文件 |
|------|------|------|
| `RankPage` | 排行榜 | `lib/features/home_zone/view.dart` |
| `ZonePage` | 分区页面 | `lib/features/home_zone/zone/view.dart` |
| `LivePage` | 直播页 | `lib/features/home_live/presentation/pages/live_page.dart` |

### 6.2 视频相关面板

| 页面 | 说明 | 文件 |
|------|------|------|
| `NoteListPage` | 笔记列表 | `lib/features/video/presentation/pages/note/view.dart` |
| `ViewPointsPage` | 视频看点 | `lib/features/video/presentation/pages/view_point/view.dart` |
| `MediaListPanel` | 媒体列表 | `lib/features/video/presentation/pages/medialist/view.dart` |
| `PostPanel` | 投稿面板 | `lib/features/video/presentation/pages/post_panel/view.dart` |
| `EpisodePanel` | 剧集面板 | `lib/features/episode_panel/presentation/pages/episode_panel_page.dart` |
| `PgcIntroPanel` | PGC 介绍面板 | `lib/features/video/presentation/widgets/introduction/pgc/intro_detail.dart` |
| `PayCoinsPage` | 投币页面 | `lib/features/video/presentation/pages/pay_coins/view.dart` |
| `ReplyPage` | 评论发布页 | `lib/features/video/presentation/pages/reply_new/view.dart` |

### 6.3 直播相关面板

| 页面 | 说明 | 文件 |
|------|------|------|
| `LiveSendDmPanel` | 发送弹幕面板 | `lib/features/live_room/presentation/pages/send_danmaku/view.dart` |

### 6.4 动态相关面板

| 页面 | 说明 | 文件 |
|------|------|------|
| `CreateDynPanel` | 创建动态面板 | `lib/features/dynamics_create/presentation/pages/dynamics_create_page.dart` |
| `RepostPanel` | 转发面板 | `lib/features/dynamics_repost/presentation/pages/dynamics_repost_page.dart` |

### 6.5 下载相关页面

| 页面 | 说明 | 文件 |
|------|------|------|
| `DownloadSearchPage` | 下载搜索 | `lib/features/download/presentation/pages/search/view.dart` |
| `DownloadingPage` | 下载中 | `lib/features/download/presentation/pages/downloading/view.dart` |
| `DownloadDetailPage` | 下载详情 | `lib/features/download/presentation/pages/detail/view.dart` |

### 6.6 通用弹窗

| 页面 | 说明 | 文件 |
|------|------|------|
| `GalleryViewer` | 图片查看器 | `lib/common/widgets/image_viewer/gallery_viewer.dart` |
| `ExpLogPage` | 经验日志 | `lib/features/exp_log/presentation/pages/exp_log_page.dart` |
| `CoinLogPage` | 硬币日志 | `lib/features/coin_log/presentation/pages/coin_log_page.dart` |
| `WhisperSecPage` | 联系人发起私信 | `lib/features/whisper_secondary/presentation/pages/whisper_secondary_page.dart` |
| `FavSortPage` | 收藏排序 | `lib/features/fav_sort/presentation/pages/fav_sort_page.dart` |
| `FavFolderSortPage` | 收藏夹排序 | `lib/features/fav_folder_sort/presentation/pages/fav_folder_sort_page.dart` |

### 6.7 自定义路由类型

项目中定义了以下特殊路由类型：

| 路由类型 | 说明 | 文件 |
|----------|------|------|
| `PublishRoute` | 发布面板路由 | `lib/features/common/presentation/pages/publish/publish_route.dart` |
| `HeroDialogRoute` | Hero 动画对话框路由 | `lib/common/widgets/image_viewer/hero_dialog_route.dart` |
| `CommonSlidePage` | 通用侧滑页面基类 | `lib/features/common/presentation/pages/slide/common_slide_page.dart` |

---

## 七、路由配置文件

### 7.1 核心文件

| 文件 | 说明 | 状态 |
|------|------|------|
| `lib/app/app.dart` | 应用入口，配置 `GetMaterialApp` | ✅ |
| `lib/app/router/go_router_config.dart` | go_router 路由配置 | ✅ Phase 13 |
| `lib/app/router/app_routes.dart` | 路由路径常量定义 | ✅ |
| `lib/app/router/app_pages.dart` | GetX 命名路由配置 (待迁移) | 🔄 |
| `lib/utils/app_scheme.dart` | Deep Link 和 Scheme 处理 | ✅ |
| `lib/utils/page_utils.dart` | 页面工具类 (统一接口) | ✅ |
| `lib/features/common/presentation/pages/publish/publish_route.dart` | 发布面板路由定义 | ✅ |

### 7.2 路由配置说明

#### go_router 配置

```dart
// lib/app/router/go_router_config.dart
final routerConfig = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    // 视频详情页路由
    GoRoute(
      path: '/videoV',
      name: AppRoutes.video,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;
        return VideoDetailPageV(args: args ?? const {});
      },
    ),
    // ... 其他路由
  ],
);
```

#### 路由常量定义

```dart
// lib/app/router/app_routes.dart
class AppRoutes {
  static const String video = '/videoV';
  static const String home = '/home';
  // ... 其他路由常量
}
```

---

## 八、使用示例

### 8.1 视频导航 (使用 go_router)

```dart
// 方法1: 使用 PageUtils (推荐)
PageUtils.toVideoPage(
  bvid: 'BV1xx411c7mD',
  cid: 123456,
  cover: 'https://...',
  title: '视频标题',
  videoType: VideoType.ugc,
);

// 方法2: 直接使用 go_router
import 'package:go_router/go_router.dart';

context.pushNamed(
  AppRoutes.video,
  extra: {
    'bvid': 'BV1xx411c7mD',
    'cid': 123456,
    'cover': 'https://...',
  },
);
```

### 8.2 其他页面导航 (使用 GetX，待迁移)

```dart
// 使用命名路径
Get.toNamed('/webview', arguments: {'url': 'https://www.bilibili.com'});

// 使用路径参数
Get.toNamed('/member?mid=123456');

// 替换当前页面
Get.offNamed('/loginPage');

// 替换所有页面并清除栈
Get.offAllNamed('/home');
```

### 8.3 使用页面静态方法

```dart
// 跳转关注页面
FollowPageV2.toFollowPage(mid: 123456, name: '用户名');

// 跳转音频播放
AudioPage.toAudioPage(
  oid: 123456,
  itemType: 3,
  from: PlaylistSource.AUDIO_CARD,
);

// 跳转视频回复
VideoReplyReplyPanel.toReply(
  oid: 123456,
  rootId: 789012,
  type: 1,
);
```

### 8.4 使用工具类方法

```dart
// 跳转视频播放
PageUtils.toVideoPage(
  bvid: 'BV1xx411c7mD',
  cid: 123456,
  cover: 'https://...',
);

// 跳转番剧
PageUtils.viewPgc(epId: 123456);

// 跳转直播间
PageUtils.toLiveRoom(123456);

// 打开 WebView
PageUtils.handleWebview('https://www.bilibili.com');
```

### 8.4 Deep Link 跳转

```dart
// 处理 bilibili:// 协议
PiliScheme.routePush(Uri.parse('bilibili://video/BV1xx411c7mD'));

// 处理 HTTPS URL
PiliScheme.routePushFromUrl('https://www.bilibili.com/video/BV1xx411c7mD');

// 处理短链接
PiliScheme.routePushFromUrl('https://b23.tv/abc123');
```

### 8.5 自定义参数传递

```dart
// 使用 arguments 传递复杂对象
Get.toNamed('/dynamicDetail', arguments: {
  'item': dynamicItemModel,
});

// 使用 parameters 传递简单参数
Get.toNamed('/searchResult', parameters: {
  'keyword': '搜索关键词',
});

// 获取参数
final mid = Get.parameters['mid'];
final item = Get.arguments as DynamicItemModel;
```

### 8.6 返回结果

```dart
// 跳转并等待结果
final result = await Get.toNamed('/settingsSearch');

// 返回结果
Get.back(result: 'selected_value');
```

---

## 附录

### A. 路由迁移状态

项目正在进行从 GetX 到 Riverpod 的迁移，部分页面已经迁移到 Riverpod 架构（标记为 V2），但路由系统仍使用 GetX。

### B. 相关常量

- `VideoType` - 视频类型枚举
- `FavTabType` - 收藏标签类型
- `PlaylistSource` - 播放列表来源
- `UaType` - User Agent 类型

### C. 更新日志

| 日期 | 更新内容 |
|------|----------|
| 2026-02-25 | 初始版本，完整路由文档 |
