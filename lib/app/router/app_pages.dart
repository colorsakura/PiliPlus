import 'package:PiliPlus/features/about/presentation/pages/about_page.dart';
import 'package:PiliPlus/features/article_list/article_list.dart';
import 'package:PiliPlus/features/backup/presentation/pages/backup_page.dart';
import 'package:PiliPlus/features/blacklist/presentation/pages/blacklist_page.dart';
import 'package:PiliPlus/features/history/presentation/pages/history_page.dart';
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
import 'package:PiliPlus/features/follow_search/follow_search.dart';
import 'package:PiliPlus/pages/follow_type/follow_same/view.dart';
import 'package:PiliPlus/pages/follow_type/followed/view.dart';
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
import 'package:PiliPlus/pages/msg_feed_top/at_me/view.dart';
import 'package:PiliPlus/pages/msg_feed_top/like_detail/view.dart';
import 'package:PiliPlus/pages/msg_feed_top/like_me/view.dart';
import 'package:PiliPlus/pages/msg_feed_top/reply_me/view.dart';
import 'package:PiliPlus/pages/msg_feed_top/sys_msg/view.dart';
import 'package:PiliPlus/features/music/music.dart';
import 'package:PiliPlus/features/popular_precious/popular_precious.dart';
import 'package:PiliPlus/features/popular_series/popular_series.dart';
import 'package:PiliPlus/features/search/search.dart';
import 'package:PiliPlus/features/search_result/search_result.dart';
import 'package:PiliPlus/features/search_trending/search_trending.dart';
import 'package:PiliPlus/pages/setting/extra_setting.dart';
import 'package:PiliPlus/pages/setting/pages/bar_set.dart';
import 'package:PiliPlus/pages/setting/pages/color_select.dart';
import 'package:PiliPlus/pages/setting/pages/display_mode.dart';
import 'package:PiliPlus/pages/setting/pages/font_size_select.dart';
import 'package:PiliPlus/pages/setting/pages/play_speed_set.dart';
import 'package:PiliPlus/pages/setting/play_setting.dart';
import 'package:PiliPlus/pages/setting/privacy_setting.dart';
import 'package:PiliPlus/pages/setting/recommend_setting.dart';
import 'package:PiliPlus/pages/setting/style_setting.dart';
import 'package:PiliPlus/pages/setting/video_setting.dart';
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
import 'package:get/get.dart';

class Routes {
  static final List<GetPage<dynamic>> getPages = [
    GetPage(name: '/', page: () => const ShellPage()),
    // 首页(推荐)
    GetPage(name: '/home', page: () => const HomePage()),
    // 热门
    GetPage(name: '/hot', page: () => const HotPage()),
    // 视频详情
    GetPage(name: '/videoV', page: () => const VideoDetailPageV()),
    //
    GetPage(name: '/webview', page: () => const WebviewPage()),
    // 设置
    GetPage(name: '/setting', page: () => const SettingPage()),
    //
    GetPage(name: '/fav', page: () => const FavPage()),
    //
    GetPage(name: '/favDetail', page: () => const FavDetailPage()),
    // 稍后再看
    GetPage(name: '/later', page: () => const LaterPage()),
    // 历史记录
    GetPage(
      name: '/history',
      page: () => const HistoryPage(),
    ),
    // 搜索页面
    GetPage(name: '/search', page: () => const SearchPage()),
    // 搜索结果
    GetPage(name: '/searchResult', page: () => const SearchResultPage()),
    // 动态
    GetPage(name: '/dynamics', page: () => const dynamics.DynamicsPage()),
    // 动态详情
    GetPage(name: '/dynamicDetail', page: () => const DynamicDetailPage()),
    // 关注
    GetPage(name: '/follow', page: () => const FollowPage()),
    // 粉丝
    GetPage(name: '/fan', page: () => const FansPage()),
    // 直播详情
    GetPage(name: '/liveRoom', page: () => const LiveRoomPage()),
    // 用户中心
    GetPage(name: '/member', page: () => const MemberPage()),
    GetPage(name: '/memberSearch', page: () => const MemberSearchPage()),
    // 推荐流设置
    GetPage(name: '/recommendSetting', page: () => const RecommendSetting()),
    // 音视频设置
    GetPage(name: '/videoSetting', page: () => const VideoSetting()),
    // 播放器设置
    GetPage(name: '/playSetting', page: () => const PlaySetting()),
    // 外观设置
    GetPage(name: '/styleSetting', page: () => const StyleSetting()),
    // 隐私设置
    GetPage(name: '/privacySetting', page: () => const PrivacySetting()),
    // 其它设置
    GetPage(name: '/extraSetting', page: () => const ExtraSetting()),
    //
    GetPage(name: '/blackListPage', page: () => const BlacklistPage()),
    GetPage(name: '/colorSetting', page: () => const ColorSelectPage()),
    GetPage(name: '/fontSizeSetting', page: () => const FontSizeSelectPage()),
    // 屏幕帧率
    GetPage(name: '/displayModeSetting', page: () => const SetDisplayMode()),
    // 关于
    GetPage(name: '/about', page: () => const AboutPage()),
    //
    GetPage(name: '/articlePage', page: () => const ArticlePage()),

    // 历史记录搜索
    GetPage(name: '/playSpeedSet', page: () => const PlaySpeedPage()),
    // 收藏搜索
    GetPage(name: '/favSearch', page: () => const FavSearchPage()),
    GetPage(name: '/historySearch', page: () => const HistorySearchPage()),
    GetPage(name: '/followSearch', page: () => const FollowSearchPage()),
    // 消息页面
    GetPage(name: '/whisper', page: () => const WhisperPage()),
    // 私信详情
    GetPage(name: '/whisperDetail', page: () => const WhisperDetailPage()),
    // 回复我的
    GetPage(name: '/replyMe', page: () => const ReplyMePage()),
    // @我的
    GetPage(name: '/atMe', page: () => const AtMePage()),
    // 收到的赞
    GetPage(name: '/likeMe', page: () => const LikeMePage()),
    // 系统消息
    GetPage(name: '/sysMsg', page: () => const SysMsgPage()),
    // 登录页面
    GetPage(name: '/loginPage', page: () => const LoginPage()),
    // 用户动态
    GetPage(name: '/memberDynamics', page: () => const MemberDynamicsPage()),
    // 订阅
    GetPage(name: '/subscription', page: () => const SubPage()),
    // 订阅详情
    GetPage(name: '/subDetail', page: () => const SubDetailPage()),
    // 弹幕屏蔽管理
    GetPage(name: '/danmakuBlock', page: () => const DanmakuBlockPage()),
    GetPage(name: '/sponsorBlock', page: () => const SponsorBlockPage()),
    GetPage(name: '/createFav', page: () => const CreateFavPage()),
    GetPage(name: '/editProfile', page: () => const EditProfilePage()),
    GetPage(name: '/settingsSearch', page: () => const SettingsSearchPage()),
    GetPage(name: '/webdavSetting', page: () => const BackupPage()),
    GetPage(name: '/searchTrending', page: () => const SearchTrendingPage()),
    GetPage(name: '/dynTopic', page: () => const DynTopicPage()),
    GetPage(name: '/articleList', page: () => const ArticleListPage()),
    GetPage(name: '/barSetting', page: () => const BarSetPage()),
    GetPage(name: '/upowerRank', page: () => const UpowerRankPage()),
    GetPage(name: '/spaceSetting', page: () => const SpaceSettingPage()),
    GetPage(name: '/dynTopicRcmd', page: () => const DynTopicRcmdPage()),
    GetPage(name: '/matchInfo', page: () => const MatchInfoPage()),
    GetPage(name: '/msgLikeDetail', page: () => const LikeDetailPage()),
    GetPage(name: '/liveDmBlockPage', page: () => const LiveDmBlockPage()),
    GetPage(name: '/createVote', page: () => const CreateVotePage()),
    GetPage(name: '/musicDetail', page: () => const MusicDetailPage()),
    GetPage(name: '/popularSeries', page: () => const PopularSeriesPage()),
    GetPage(name: '/popularPrecious', page: () => const PopularPreciousPage()),
    GetPage(name: '/audio', page: () => const AudioPage()),
    GetPage(name: '/mainReply', page: () => const MainReplyPage()),
    GetPage(name: '/followed', page: () => const FollowedPage()),
    GetPage(name: '/sameFollowing', page: () => const FollowSamePage()),
    GetPage(name: '/download', page: () => const DownloadPage()),
    GetPage(name: '/dlna', page: () => const DlnaPage()),
  ];
}
