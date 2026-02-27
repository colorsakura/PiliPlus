import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/app/router/route_guards.dart';
import 'package:PiliPlus/features/about/presentation/pages/about_page.dart';
import 'package:PiliPlus/features/article_list/article_list.dart';
import 'package:PiliPlus/features/backup/presentation/pages/backup_page.dart';
import 'package:PiliPlus/features/blacklist/presentation/pages/blacklist_page.dart';
import 'package:PiliPlus/features/history/history.dart';
import 'package:PiliPlus/features/home/presentation/pages/home_page.dart';
import 'package:PiliPlus/features/home_hot/presentation/pages/hot_page.dart';
import 'package:PiliPlus/features/later/presentation/pages/later_page.dart';
import 'package:PiliPlus/features/shell/presentation/pages/shell_page.dart';
import 'package:PiliPlus/features/article/article.dart';
import 'package:PiliPlus/features/audio/audio.dart';
import 'package:PiliPlus/features/danmaku_block/danmaku_block.dart';
import 'package:PiliPlus/features/dlna/dlna.dart';
import 'package:PiliPlus/features/download/download.dart';
import 'package:PiliPlus/features/dynamics/presentation/pages/dynamics_page.dart'
    as dynamics;
import 'package:PiliPlus/features/dynamics_create_vote/dynamics_create_vote.dart';
import 'package:PiliPlus/features/dynamics_detail/dynamics_detail.dart';
import 'package:PiliPlus/features/dynamics_topic/dynamics_topic.dart';
import 'package:PiliPlus/features/dynamics_topic_rcmd/dynamics_topic_rcmd.dart';
import 'package:PiliPlus/features/fan/fan.dart';
import 'package:PiliPlus/features/fav/fav.dart';
import 'package:PiliPlus/features/fav_create/fav_create.dart';
import 'package:PiliPlus/features/fav_detail/fav_detail.dart';
import 'package:PiliPlus/features/fav_search/fav_search.dart';
import 'package:PiliPlus/features/follow/follow.dart';
import 'package:PiliPlus/features/followed/followed.dart';
import 'package:PiliPlus/features/follow_same/follow_same.dart';
import 'package:PiliPlus/features/follow_search/follow_search.dart';
import 'package:PiliPlus/features/history_search/history_search.dart';
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
        pageBuilder: (context, state) => MaterialPage(child: ShellPage()),
        routes: [
          // Home tab
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) =>
                MaterialPage(child: const HomePage()),
          ),
          // Hot tab
          GoRoute(
            path: AppRoutes.hot,
            pageBuilder: (context, state) =>
                MaterialPage(child: const HotPage()),
          ),
        ],
      ),

      // Standalone routes (not in shell)
      GoRoute(
        path: AppRoutes.video,
        pageBuilder: (context, state) => const MaterialPage(
          child: VideoDetailPageV(),
        ),
      ),

      GoRoute(
        path: AppRoutes.webview,
        pageBuilder: (context, state) {
          final url = state.uri.queryParameters['url'];
          return MaterialPage(child: WebviewPage(url: url));
        },
      ),

      GoRoute(
        path: AppRoutes.setting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const SettingPage()),
      ),

      GoRoute(
        path: AppRoutes.fav,
        pageBuilder: (context, state) =>
            const MaterialPage(child: FavPage()),
      ),

      GoRoute(
        path: AppRoutes.favDetail,
        pageBuilder: (context, state) => const MaterialPage(
          child: FavDetailPage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.later,
        pageBuilder: (context, state) =>
            MaterialPage(child: const LaterPage()),
      ),

      GoRoute(
        path: AppRoutes.history,
        pageBuilder: (context, state) =>
            MaterialPage(child: const HistoryPageV2()),
      ),

      GoRoute(
        path: AppRoutes.search,
        pageBuilder: (context, state) =>
            MaterialPage(child: const SearchPage()),
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
            MaterialPage(child: const dynamics.DynamicsPage()),
      ),

      GoRoute(
        path: AppRoutes.dynamicDetail,
        pageBuilder: (context, state) => const MaterialPage(
          child: DynamicDetailPage(),
        ),
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
        pageBuilder: (context, state) =>
            MaterialPage(child: const FanPageV2()),
      ),

      GoRoute(
        path: AppRoutes.liveRoom,
        pageBuilder: (context, state) => const MaterialPage(
          child: LiveRoomPage(),
        ),
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
            MaterialPage(child: const MemberSearchPageV2()),
      ),

      GoRoute(
        path: AppRoutes.recommendSetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const RecommendSetting()),
      ),

      GoRoute(
        path: AppRoutes.videoSetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const VideoSetting()),
      ),

      GoRoute(
        path: AppRoutes.playSetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const PlaySetting()),
      ),

      GoRoute(
        path: AppRoutes.styleSetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const StyleSetting()),
      ),

      GoRoute(
        path: AppRoutes.privacySetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const PrivacySetting()),
      ),

      GoRoute(
        path: AppRoutes.extraSetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const ExtraSetting()),
      ),

      GoRoute(
        path: AppRoutes.blackListPage,
        pageBuilder: (context, state) =>
            MaterialPage(child: const BlacklistPage()),
      ),

      GoRoute(
        path: AppRoutes.colorSetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const ColorSelectPage()),
      ),

      GoRoute(
        path: AppRoutes.displayModeSetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const SetDisplayMode()),
      ),

      GoRoute(
        path: AppRoutes.about,
        pageBuilder: (context, state) =>
            MaterialPage(child: const AboutPage()),
      ),

      GoRoute(
        path: AppRoutes.articlePage,
        pageBuilder: (context, state) => const MaterialPage(
          child: ArticlePage(),
        ),
      ),

      GoRoute(
        path: AppRoutes.playSpeedSet,
        pageBuilder: (context, state) =>
            MaterialPage(child: const PlaySpeedPage()),
      ),

      GoRoute(
        path: AppRoutes.favSearch,
        pageBuilder: (context, state) =>
            MaterialPage(child: const FavSearchPage()),
      ),

      GoRoute(
        path: AppRoutes.historySearch,
        pageBuilder: (context, state) =>
            MaterialPage(child: const HistorySearchPage()),
      ),

      GoRoute(
        path: AppRoutes.followSearch,
        pageBuilder: (context, state) =>
            MaterialPage(child: const FollowSearchPageV2()),
      ),

      GoRoute(
        path: AppRoutes.whisper,
        pageBuilder: (context, state) =>
            MaterialPage(child: const WhisperPage()),
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
            MaterialPage(child: const MsgReplyMePageV2()),
      ),

      GoRoute(
        path: AppRoutes.atMe,
        pageBuilder: (context, state) =>
            MaterialPage(child: const MsgAtMePageV2()),
      ),

      GoRoute(
        path: AppRoutes.likeMe,
        pageBuilder: (context, state) =>
            MaterialPage(child: const MsgLikeMePageV2()),
      ),

      GoRoute(
        path: AppRoutes.sysMsg,
        pageBuilder: (context, state) =>
            MaterialPage(child: const MsgSysMsgPageV2()),
      ),

      GoRoute(
        path: AppRoutes.loginPage,
        pageBuilder: (context, state) =>
            MaterialPage(child: const LoginPage()),
      ),

      GoRoute(
        path: AppRoutes.memberDynamics,
        pageBuilder: (context, state) =>
            MaterialPage(child: const MemberDynamicsPageV2()),
      ),

      GoRoute(
        path: AppRoutes.subscription,
        pageBuilder: (context, state) =>
            MaterialPage(child: const SubscriptionPageV2()),
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
            MaterialPage(child: const DanmakuBlockPageV2()),
      ),

      GoRoute(
        path: AppRoutes.sponsorBlock,
        pageBuilder: (context, state) =>
            MaterialPage(child: const SponsorBlockPage()),
      ),

      GoRoute(
        path: AppRoutes.createFav,
        pageBuilder: (context, state) =>
            MaterialPage(child: const CreateFavPage()),
      ),

      GoRoute(
        path: AppRoutes.editProfile,
        pageBuilder: (context, state) =>
            MaterialPage(child: const EditProfilePage()),
      ),

      GoRoute(
        path: AppRoutes.settingsSearch,
        pageBuilder: (context, state) =>
            MaterialPage(child: const SettingsSearchPage()),
      ),

      GoRoute(
        path: AppRoutes.webdavSetting,
        pageBuilder: (context, state) =>
            MaterialPage(child: const BackupPage()),
      ),

      GoRoute(
        path: AppRoutes.searchTrending,
        pageBuilder: (context, state) =>
            MaterialPage(child: const SearchTrendingPage()),
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
            MaterialPage(child: const BarSetPage()),
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
            MaterialPage(child: const SpaceSettingPage()),
      ),

      GoRoute(
        path: AppRoutes.dynTopicRcmd,
        pageBuilder: (context, state) =>
            MaterialPage(child: const DynTopicRcmdPage()),
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
            MaterialPage(child: const LiveDmBlockPageV2()),
      ),

      GoRoute(
        path: AppRoutes.createVote,
        pageBuilder: (context, state) =>
            MaterialPage(child: const CreateVotePage()),
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
            MaterialPage(child: const PopularSeriesPage()),
      ),

      GoRoute(
        path: AppRoutes.popularPrecious,
        pageBuilder: (context, state) =>
            MaterialPage(child: const PopularPreciousPage()),
      ),

      GoRoute(
        path: AppRoutes.audio,
        pageBuilder: (context, state) => MaterialPage(child: const AudioPage()),
      ),

      GoRoute(
        path: AppRoutes.mainReply,
        pageBuilder: (context, state) =>
            MaterialPage(child: const MainReplyPage()),
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
            MaterialPage(child: const DownloadPage()),
      ),

      GoRoute(
        path: AppRoutes.dlna,
        pageBuilder: (context, state) => MaterialPage(child: const DlnaPage()),
      ),
    ],
  );
}
