import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/app/router/route_guards.dart';
import 'package:PiliPlus/features/about/presentation/pages/about_page.dart';
import 'package:PiliPlus/features/article/article.dart';
import 'package:PiliPlus/features/article_list/article_list.dart';
import 'package:PiliPlus/features/audio/audio.dart';
import 'package:PiliPlus/features/backup/presentation/pages/backup_page.dart';
import 'package:PiliPlus/features/blacklist/presentation/pages/blacklist_page.dart';
import 'package:PiliPlus/features/danmaku_block/danmaku_block.dart';
import 'package:PiliPlus/features/dlna/dlna.dart';
import 'package:PiliPlus/features/download/download.dart';
import 'package:PiliPlus/features/dynamics/presentation/pages/dynamics_page.dart'
    as dynamics;
import 'package:PiliPlus/features/dynamics_create_vote/dynamics_create_vote.dart';
import 'package:PiliPlus/features/dynamics_detail/dynamics_detail.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/features/dynamics_topic/dynamics_topic.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/dynamics_topic_rcmd.dart';
import 'package:PiliPlus/features/fan/fan.dart';
import 'package:PiliPlus/features/fav/fav.dart';
import 'package:PiliPlus/features/fav_create/fav_create.dart';
import 'package:PiliPlus/features/fav_detail/fav_detail.dart';
import 'package:PiliPlus/features/fav_search/fav_search.dart';
import 'package:PiliPlus/features/follow/follow.dart';
import 'package:PiliPlus/features/follow_same/follow_same.dart';
import 'package:PiliPlus/features/follow_search/follow_search.dart';
import 'package:PiliPlus/features/followed/followed.dart';
import 'package:PiliPlus/features/history/history.dart';
import 'package:PiliPlus/features/history_search/history_search.dart';
import 'package:PiliPlus/features/home/presentation/pages/home_page.dart';
import 'package:PiliPlus/features/home_hot/presentation/pages/hot_page.dart';
import 'package:PiliPlus/features/later/presentation/pages/later_page.dart';
import 'package:PiliPlus/features/live_dm_block/live_dm_block.dart';
import 'package:PiliPlus/features/live_room/live_room.dart';
import 'package:PiliPlus/features/login/login.dart';
import 'package:PiliPlus/features/main_reply/main_reply.dart';
import 'package:PiliPlus/features/match_info/match_info.dart';
import 'package:PiliPlus/features/member/member.dart';
import 'package:PiliPlus/features/member_dynamics/member_dynamics.dart';
import 'package:PiliPlus/features/member_profile/member_profile.dart';
import 'package:PiliPlus/features/member_search/member_search.dart';
import 'package:PiliPlus/features/member_upower_rank/member_upower_rank.dart';
import 'package:PiliPlus/features/msg_feed/msg_feed.dart';
import 'package:PiliPlus/features/music/music.dart';
import 'package:PiliPlus/features/popular_precious/popular_precious.dart';
import 'package:PiliPlus/features/popular_series/popular_series.dart';
import 'package:PiliPlus/features/search/search.dart';
import 'package:PiliPlus/features/search_result/search_result.dart';
import 'package:PiliPlus/features/search_trending/search_trending.dart';
import 'package:PiliPlus/features/setting/presentation/pages/extra_setting.dart';
import 'package:PiliPlus/features/setting/presentation/pages/pages/bar_set.dart';
import 'package:PiliPlus/features/setting/presentation/pages/pages/color_select.dart';
import 'package:PiliPlus/features/setting/presentation/pages/pages/display_mode.dart';
import 'package:PiliPlus/features/setting/presentation/pages/pages/play_speed_set.dart';
import 'package:PiliPlus/features/setting/presentation/pages/play_setting.dart';
import 'package:PiliPlus/features/setting/presentation/pages/privacy_setting.dart';
import 'package:PiliPlus/features/setting/presentation/pages/recommend_setting.dart';
import 'package:PiliPlus/features/setting/presentation/pages/style_setting.dart';
import 'package:PiliPlus/features/setting/presentation/pages/video_setting.dart';
import 'package:PiliPlus/features/setting/setting.dart';
import 'package:PiliPlus/features/settings_search/settings_search.dart';
import 'package:PiliPlus/features/shell/presentation/pages/shell_page.dart';
import 'package:PiliPlus/features/space_setting/space_setting.dart';
import 'package:PiliPlus/features/sponsor_block/sponsor_block.dart';
import 'package:PiliPlus/features/subscription/subscription.dart';
import 'package:PiliPlus/features/subscription_detail/subscription_detail.dart';
import 'package:PiliPlus/features/video/video.dart';
import 'package:PiliPlus/features/webview/webview.dart';
import 'package:PiliPlus/features/whisper/whisper.dart';
import 'package:PiliPlus/features/whisper_detail/whisper_detail.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:go_router/go_router.dart';

/// Global navigator key for accessing navigator state outside of build context
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

/// Create and configure the go_router instance
GoRouter goRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.root,
    redirect: RouteGuard.redirect,
    observers: [
      PageUtils.routeObserver,
      FlutterSmartDialog.observer,
    ],
    routes: [
      // Root / Shell route - contains bottom navigation
      GoRoute(
        path: AppRoutes.root,
        pageBuilder: (context, state) => const MaterialPage(child: ShellPage()),
        routes: [
          // Home tab
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                const MaterialPage(child: HomePage()),
          ),
          // Hot tab
          GoRoute(
            path: AppRoutes.hot,
            pageBuilder: (context, state) =>
                const MaterialPage(child: HotPage()),
          ),
        ],
      ),

      // Standalone routes (not in shell)
      GoRoute(
        path: AppRoutes.video,
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>?;
          return MaterialPage(
            child: VideoDetailPageV(args: args ?? const {}),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.webview,
        pageBuilder: (context, state) {
          final url = state.uri.queryParameters['url'];
          final extra = state.extra as Map<String, dynamic>?;
          return MaterialPage(
            child: WebviewPage(
              url: url,
              oid: extra?['oid'],
              title: extra?['title'],
              uaType: extra?['uaType'],
              inApp: extra?['inApp'] ?? false,
              off: extra?['off'] ?? false,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.setting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SettingPage()),
      ),

      GoRoute(
        path: AppRoutes.fav,
        pageBuilder: (context, state) => const MaterialPage(child: FavPage()),
      ),

      GoRoute(
        path: AppRoutes.favDetail,
        pageBuilder: (context, state) {
          final mediaId = state.uri.queryParameters['mediaId'] ?? '';
          final heroTag = state.uri.queryParameters['heroTag'];
          return MaterialPage(
            child: FavDetailPage(
              mediaId: mediaId,
              heroTag: heroTag,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.later,
        pageBuilder: (context, state) => const MaterialPage(child: LaterPage()),
      ),

      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (context, state) =>
            const MaterialPage(child: HistoryPageV2()),
      ),

      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SearchPage()),
      ),

      GoRoute(
        path: AppRoutes.searchResult,
        pageBuilder: (context, state) {
          final keyword = state.uri.queryParameters['keyword'] ?? '';
          return MaterialPage(child: SearchResultPageV2(keyword: keyword));
        },
      ),

      GoRoute(
        path: AppRoutes.dynamics,
        pageBuilder: (context, state) =>
            const MaterialPage(child: dynamics.DynamicsPage()),
      ),

      GoRoute(
        path: AppRoutes.dynamicDetail,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final item = extra?['item'] as DynamicItemModel?;
          return MaterialPage(
            child: DynamicDetailPage(item: item),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.follow,
        pageBuilder: (context, state) {
          final mid = state.uri.queryParameters['mid'];
          return MaterialPage(
            child: FollowPageV2(
              mid: mid != null ? int.tryParse(mid) ?? 0 : 0,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.fan,
        pageBuilder: (context, state) => const MaterialPage(child: FanPageV2()),
      ),

      GoRoute(
        path: AppRoutes.liveRoom,
        pageBuilder: (context, state) {
          final roomId = state.extra as int?;
          return MaterialPage(
            child: LiveRoomPage(roomId: roomId),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.member,
        pageBuilder: (context, state) => const MaterialPage(
          child: MemberPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.memberSearch,
        pageBuilder: (context, state) =>
            const MaterialPage(child: MemberSearchPageV2()),
      ),

      GoRoute(
        path: AppRoutes.recommendSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: RecommendSetting()),
      ),

      GoRoute(
        path: AppRoutes.videoSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: VideoSetting()),
      ),

      GoRoute(
        path: AppRoutes.playSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PlaySetting()),
      ),

      GoRoute(
        path: AppRoutes.styleSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: StyleSetting()),
      ),

      GoRoute(
        path: AppRoutes.privacySetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PrivacySetting()),
      ),

      GoRoute(
        path: AppRoutes.extraSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: ExtraSetting()),
      ),

      GoRoute(
        path: AppRoutes.blackListPage,
        pageBuilder: (context, state) =>
            const MaterialPage(child: BlacklistPage()),
      ),

      GoRoute(
        path: AppRoutes.colorSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: ColorSelectPage()),
      ),

      GoRoute(
        path: AppRoutes.displayModeSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SetDisplayMode()),
      ),

      GoRoute(
        path: AppRoutes.about,
        pageBuilder: (context, state) => const MaterialPage(child: AboutPage()),
      ),

      GoRoute(
        path: AppRoutes.articlePage,
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          final type = state.uri.queryParameters['type'] ?? '';
          return MaterialPage(
            child: ArticlePage(id: id, type: type),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.playSpeedSet,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PlaySpeedPage()),
      ),

      GoRoute(
        path: AppRoutes.favSearch,
        pageBuilder: (context, state) =>
            const MaterialPage(child: FavSearchPage()),
      ),

      GoRoute(
        path: AppRoutes.historySearch,
        pageBuilder: (context, state) =>
            const MaterialPage(child: HistorySearchPage()),
      ),

      GoRoute(
        path: AppRoutes.followSearch,
        pageBuilder: (context, state) =>
            const MaterialPage(child: FollowSearchPageV2()),
      ),

      GoRoute(
        path: AppRoutes.whisper,
        pageBuilder: (context, state) =>
            const MaterialPage(child: WhisperPage()),
      ),

      GoRoute(
        path: AppRoutes.whisperDetail,
        pageBuilder: (context, state) => const MaterialPage(
          child: WhisperDetailPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.replyMe,
        pageBuilder: (context, state) =>
            const MaterialPage(child: MsgReplyMePageV2()),
      ),

      GoRoute(
        path: AppRoutes.atMe,
        pageBuilder: (context, state) =>
            const MaterialPage(child: MsgAtMePageV2()),
      ),

      GoRoute(
        path: AppRoutes.likeMe,
        pageBuilder: (context, state) =>
            const MaterialPage(child: MsgLikeMePageV2()),
      ),

      GoRoute(
        path: AppRoutes.sysMsg,
        pageBuilder: (context, state) =>
            const MaterialPage(child: MsgSysMsgPageV2()),
      ),

      GoRoute(
        path: AppRoutes.loginPage,
        pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
      ),

      GoRoute(
        path: AppRoutes.memberDynamics,
        pageBuilder: (context, state) =>
            const MaterialPage(child: MemberDynamicsPageV2()),
      ),

      GoRoute(
        path: AppRoutes.subscription,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SubscriptionPageV2()),
      ),

      GoRoute(
        path: AppRoutes.subDetail,
        pageBuilder: (context, state) {
          final id = state.uri.queryParameters['id'];
          final heroTag = state.uri.queryParameters['heroTag'];
          return MaterialPage(
            child: SubscriptionDetailPageV2(
              id: id != null ? int.tryParse(id) ?? 0 : 0,
              heroTag: heroTag,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.danmakuBlock,
        pageBuilder: (context, state) =>
            const MaterialPage(child: DanmakuBlockPageV2()),
      ),

      GoRoute(
        path: AppRoutes.sponsorBlock,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SponsorBlockPage()),
      ),

      GoRoute(
        path: AppRoutes.createFav,
        pageBuilder: (context, state) =>
            const MaterialPage(child: CreateFavPage()),
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) =>
            const MaterialPage(child: EditProfilePage()),
      ),

      GoRoute(
        path: AppRoutes.settingsSearch,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SettingsSearchPage()),
      ),

      GoRoute(
        path: AppRoutes.webdavSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: BackupPage()),
      ),

      GoRoute(
        path: AppRoutes.searchTrending,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SearchTrendingPage()),
      ),

      GoRoute(
        path: AppRoutes.dynTopic,
        pageBuilder: (context, state) => const MaterialPage(
          child: DynTopicPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.articleList,
        pageBuilder: (context, state) => const MaterialPage(
          child: ArticleListPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.barSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: BarSetPage()),
      ),

      GoRoute(
        path: AppRoutes.upowerRank,
        pageBuilder: (context, state) => const MaterialPage(
          child: MemberUpowerRankPage(upMid: ''),
        ),
      ),

      GoRoute(
        path: AppRoutes.spaceSetting,
        pageBuilder: (context, state) =>
            const MaterialPage(child: SpaceSettingPage()),
      ),

      GoRoute(
        path: AppRoutes.dynTopicRcmd,
        pageBuilder: (context, state) =>
            const MaterialPage(child: DynTopicRcmdPage()),
      ),

      GoRoute(
        path: AppRoutes.matchInfo,
        pageBuilder: (context, state) => const MaterialPage(
          child: MatchInfoPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.msgLikeDetail,
        pageBuilder: (context, state) {
          final cardId = state.uri.queryParameters['cardId'];
          final uri = state.uri.queryParameters['uri'];
          final counts = state.uri.queryParameters['counts'];
          return MaterialPage(
            child: LikeDetailPageV2(
              cardId: cardId ?? '',
              uri: uri,
              counts: counts != null ? int.tryParse(counts) ?? 0 : 0,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.liveDmBlockPage,
        pageBuilder: (context, state) =>
            const MaterialPage(child: LiveDmBlockPageV2()),
      ),

      GoRoute(
        path: AppRoutes.createVote,
        pageBuilder: (context, state) =>
            const MaterialPage(child: CreateVotePage()),
      ),

      GoRoute(
        path: AppRoutes.musicDetail,
        pageBuilder: (context, state) => const MaterialPage(
          child: MusicDetailPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.popularSeries,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PopularSeriesPage()),
      ),

      GoRoute(
        path: AppRoutes.popularPrecious,
        pageBuilder: (context, state) =>
            const MaterialPage(child: PopularPreciousPage()),
      ),

      GoRoute(
        path: AppRoutes.audio,
        pageBuilder: (context, state) => const MaterialPage(child: AudioPage()),
      ),

      GoRoute(
        path: AppRoutes.mainReply,
        pageBuilder: (context, state) =>
            const MaterialPage(child: MainReplyPage()),
      ),

      GoRoute(
        path: AppRoutes.followed,
        pageBuilder: (context, state) {
          final mid = state.uri.queryParameters['mid'];
          return MaterialPage(
            child: FollowedPageV2(
              mid: mid != null ? int.tryParse(mid) ?? 0 : 0,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.sameFollowing,
        pageBuilder: (context, state) {
          final mid = state.uri.queryParameters['mid'];
          return MaterialPage(
            child: FollowSamePageV2(
              mid: mid != null ? int.tryParse(mid) ?? 0 : 0,
            ),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.download,
        pageBuilder: (context, state) =>
            const MaterialPage(child: DownloadPage()),
      ),

      GoRoute(
        path: AppRoutes.dlna,
        pageBuilder: (context, state) => const MaterialPage(child: DlnaPage()),
      ),
    ],
  );
}
