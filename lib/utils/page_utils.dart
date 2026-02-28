import 'dart:math';

import 'package:PiliPlus/app/router/go_router_config.dart';
import 'package:PiliPlus/app/router/app_routes.dart';
import 'package:PiliPlus/shared/widgets/image_viewer/gallery_viewer.dart';
import 'package:PiliPlus/shared/widgets/image_viewer/hero_dialog_route.dart';
import 'package:PiliPlus/grpc/im.dart';
import 'package:PiliPlus/http/dynamics.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/search.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/image_preview_type.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:PiliPlus/models/dynamics/result.dart';
import 'package:PiliPlus/models/pgc/pgc_info_model/episode.dart';
import 'package:PiliPlus/features/common/presentation/pages/common_intro_controller.dart';
import 'package:PiliPlus/features/common/presentation/pages/publish/publish_route.dart';
import 'package:PiliPlus/features/contact/contact.dart';
import 'package:PiliPlus/features/fav_panel/fav_panel.dart';
import 'package:PiliPlus/features/share/share.dart';
import 'package:PiliPlus/utils/app_scheme.dart';
import 'package:PiliPlus/utils/extension/context_ext.dart';
import 'package:PiliPlus/utils/extension/extension.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/extension/size_ext.dart';
import 'package:PiliPlus/utils/extension/string_ext.dart';
import 'package:PiliPlus/utils/feed_back.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/id_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/utils/url_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class PageUtils {
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();

  static RelativeRect menuPosition(Offset offset) {
    return .fromLTRB(offset.dx, offset.dy, offset.dx, 0);
  }

  static Future<void> imageView({
    int initialPage = 0,
    required List<SourceModel> imgList,
    int? quality,
  }) {
    final navigatorState = rootNavigatorKey.currentState;
    if (navigatorState == null) {
      return Future.value();
    }
    return navigatorState.push<void>(
      HeroDialogRoute(
        pageBuilder: (context, animation, secondaryAnimation) => GalleryViewer(
          sources: imgList,
          initIndex: initialPage,
          quality: quality ?? GlobalData().imgQuality,
        ),
      ),
    );
  }

  static Future<void> pmShare(
    BuildContext context, {
    required Map content,
  }) async {
    // if (kDebugMode) debugPrint(content.toString());

    List<UserModel> userList = <UserModel>[];

    final res = await ImGrpc.shareList(size: 5);
    if (res case Success(:final response)) {
      if (response.sessionList.isNotEmpty) {
        userList.addAll(
          response.sessionList.map<UserModel>(
            (item) => UserModel(
              mid: item.talkerId.toInt(),
              name: item.talkerUname,
              avatar: item.talkerIcon,
            ),
          ),
        );
      }
    }

    if (userList.isEmpty && context.mounted) {
      final UserModel? userModel = await Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const ContactPage()),
      );
      if (userModel != null) {
        userList.add(userModel);
      }
    }

    if (context.mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) => SharePanel(
          content: content,
          userList: userList,
        ),
        useSafeArea: true,
        enableDrag: false,
        isScrollControlled: true,
      );
    }
  }

  static Future<void> pushDynFromId({
    String? id,
    Object? rid,
    bool off = false,
  }) async {
    assert(id != null || rid != null);
    SmartDialog.showLoading();
    final res = await DynamicsHttp.dynamicDetail(
      id: id,
      rid: rid,
      type: rid != null ? 2 : null,
    );
    SmartDialog.dismiss();
    if (res case Success(:final response)) {
      if (response.basic?.commentType == 12) {
        toDupNamed(
          '/articlePage',
          parameters: {
            'id': id!,
            'type': 'opus',
          },
          off: off,
        );
      } else {
        toDupNamed(
          '/dynamicDetail',
          arguments: {
            'item': response,
          },
          off: off,
        );
      }
    } else {
      res.toast();
    }
  }

  static void showFavBottomSheet({
    required BuildContext context,
    required FavMixin ctr,
  }) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: min(640, context.mediaQueryShortestSide),
      ),
      builder: (BuildContext context) {
        final maxChildSize =
            PlatformUtils.isMobile && !context.mediaQuerySize.isPortrait
            ? 1.0
            : 0.7;
        return DraggableScrollableSheet(
          minChildSize: 0,
          maxChildSize: 1,
          snap: true,
          expand: false,
          snapSizes: [maxChildSize],
          initialChildSize: maxChildSize,
          builder: (BuildContext context, ScrollController scrollController) {
            return FavPanel(
              ctr: ctr,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  static void reportVideo(int aid) {
    toDupNamed(
      '/webview',
      parameters: {'url': 'https://www.bilibili.com/appeal/?avid=$aid'},
    );
  }

  static void enterPip({int? width, int? height, bool isAuto = false}) {
    if (width != null && height != null) {
      Rational aspectRatio = Rational(width, height);
      aspectRatio = aspectRatio.fitsInAndroidRequirements
          ? aspectRatio
          : height > width
          ? const Rational.vertical()
          : const Rational.landscape();
      Floating().enable(
        isAuto
            ? AutoEnable(aspectRatio: aspectRatio)
            : EnableManual(aspectRatio: aspectRatio),
      );
    } else {
      Floating().enable(isAuto ? const AutoEnable() : const EnableManual());
    }
  }

  static Future<void> pushDynDetail(
    DynamicItemModel item, {
    bool isPush = false,
  }) async {
    feedBack();

    void push() {
      if (item.basic?.commentType == 12) {
        toDupNamed(
          '/articlePage',
          parameters: {
            'id': item.idStr,
            'type': 'opus',
          },
        );
      } else {
        toDupNamed(
          '/dynamicDetail',
          arguments: {
            'item': item,
          },
        );
      }
    }

    /// 点击评论action 直接查看评论
    if (isPush) {
      push();
      return;
    }

    // if (kDebugMode) debugPrint('pushDynDetail: ${item.type}');

    switch (item.type) {
      case 'DYNAMIC_TYPE_AV':
        final archive = item.modules.moduleDynamic!.major!.archive!;
        // pgc
        if (archive.type == 2) {
          // jumpUrl
          if (archive.jumpUrl case final jumpUrl?) {
            if (viewPgcFromUri(jumpUrl)) {
              return;
            }
          }
          // redirectUrl from intro
          final res = await VideoHttp.videoIntro(bvid: archive.bvid!);
          if (res.dataOrNull?.redirectUrl case final redirectUrl?) {
            if (viewPgcFromUri(redirectUrl)) {
              return;
            }
          }
          // redirectUrl from jumpUrl
          if (await UrlUtils.parseRedirectUrl(archive.jumpUrl.http2https, false)
              case final redirectUrl?) {
            if (viewPgcFromUri(redirectUrl)) {
              return;
            }
          }
        }

        try {
          String bvid = archive.bvid!;
          String cover = archive.cover!;
          int? cid = await SearchHttp.ab2c(bvid: bvid);
          if (cid != null) {
            toVideoPage(
              bvid: bvid,
              cid: cid,
              cover: cover,
            );
          }
        } catch (err) {
          SmartDialog.showToast(err.toString());
        }
        break;

      /// 专栏文章查看
      case 'DYNAMIC_TYPE_ARTICLE':
        toDupNamed(
          '/articlePage',
          parameters: {
            'id': item.idStr,
            'type': 'opus',
          },
        );
        break;

      case 'DYNAMIC_TYPE_PGC':
        // if (kDebugMode) debugPrint('番剧');
        SmartDialog.showToast('暂未支持的类型，请联系开发者');
        break;

      case 'DYNAMIC_TYPE_LIVE':
        DynamicLive2Model liveRcmd = item.modules.moduleDynamic!.major!.live!;
        toLiveRoom(liveRcmd.id);
        break;

      case 'DYNAMIC_TYPE_LIVE_RCMD':
        DynamicLiveModel liveRcmd =
            item.modules.moduleDynamic!.major!.liveRcmd!;
        toLiveRoom(liveRcmd.roomId);
        break;

      case 'DYNAMIC_TYPE_SUBSCRIPTION_NEW':
        LivePlayInfo live = item
            .modules
            .moduleDynamic!
            .major!
            .subscriptionNew!
            .liveRcmd!
            .content!
            .livePlayInfo!;
        toLiveRoom(live.roomId);
        break;

      /// 合集查看
      case 'DYNAMIC_TYPE_UGC_SEASON':
        DynamicArchiveModel ugcSeason =
            item.modules.moduleDynamic!.major!.ugcSeason!;
        int aid = ugcSeason.aid!;
        String bvid = IdUtils.av2bv(aid);
        String cover = ugcSeason.cover!;
        int? cid = await SearchHttp.ab2c(bvid: bvid);
        if (cid != null) {
          toVideoPage(
            aid: aid,
            bvid: bvid,
            cid: cid,
            cover: cover,
          );
        }
        break;

      /// 番剧查看
      case 'DYNAMIC_TYPE_PGC_UNION':
        // if (kDebugMode) debugPrint('DYNAMIC_TYPE_PGC_UNION 番剧');
        DynamicArchiveModel pgc = item.modules.moduleDynamic!.major!.pgc!;
        if (pgc.epid != null) {
          viewPgc(epId: pgc.epid);
        }
        break;

      case 'DYNAMIC_TYPE_MEDIALIST':
        if (item.modules.moduleDynamic?.major?.medialist
            case final medialist?) {
          final String? url = medialist.jumpUrl;
          if (url != null) {
            if (url.contains('medialist/detail/ml')) {
              PageUtils.toDupNamed(
                '/favDetail',
                parameters: {
                  'heroTag': '${medialist.cover}',
                  'mediaId': '${medialist.id}',
                },
              );
            } else {
              handleWebview(url.http2https);
            }
          }
        }
        break;

      case 'DYNAMIC_TYPE_COURSES_SEASON':
        PageUtils.viewPugv(
          seasonId: item.modules.moduleDynamic!.major!.courses!.id,
        );
        break;

      // 纯文字动态查看
      // case 'DYNAMIC_TYPE_WORD':
      // # 装扮/剧集点评/普通分享
      // case 'DYNAMIC_TYPE_COMMON_SQUARE':
      // 转发的动态
      // case 'DYNAMIC_TYPE_FORWARD':
      // 图文动态查看
      // case 'DYNAMIC_TYPE_DRAW':
      default:
        push();
        break;
    }
  }

  static void onHorizontalPreviewState(
    ScaffoldState state,
    List<SourceModel> imgList,
    int index,
  ) {
    state.showBottomSheet(
      constraints: const BoxConstraints(),
      (context) => GalleryViewer(
        sources: imgList,
        initIndex: index,
        quality: GlobalData().imgQuality,
      ),
      enableDrag: false,
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: AnimationStyle.noAnimation,
    );
  }

  static void inAppWebview(
    String url, {
    bool off = false,
  }) {
    if (Pref.openInBrowser) {
      launchURL(url);
    } else {
      // Use go_router navigation
      final extra = <String, dynamic>{
        'inApp': true,
        'off': off,
      };
      if (off) {
        replaceNamed(
          AppRoutes.webview,
          parameters: {'url': url},
          extra: extra,
        );
      } else {
        pushNamed(
          AppRoutes.webview,
          parameters: {'url': url},
          extra: extra,
        );
      }
    }
  }

  static Future<void> launchURL(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: mode)) {
        SmartDialog.showToast('Could not launch $url');
      }
    } catch (e) {
      SmartDialog.showToast(e.toString());
    }
  }

  static Future<void> handleWebview(
    String url, {
    bool off = false,
    bool inApp = false,
    Map? parameters,
  }) async {
    if (!inApp && Pref.openInBrowser) {
      if (!await PiliScheme.routePushFromUrl(url, selfHandle: true)) {
        launchURL(url);
      }
    } else {
      if (off) {
        // Use go_router navigation
        final uri = _buildUri(AppRoutes.webview, {
          'url': url,
          ...?parameters,
        });
        final context = rootNavigatorKey.currentContext;
        if (context != null) {
          context.pushReplacement(uri.toString(), extra: {'inApp': inApp, 'off': off});
        }
      } else {
        PiliScheme.routePushFromUrl(url, parameters: parameters);
      }
    }
  }

  static Future<void>? showVideoBottomSheet(
    BuildContext context, {
    required Widget child,
    required ValueGetter<bool> isFullScreen,
    double? padding,
  }) {
    if (!context.mounted) {
      return null;
    }
    final navigatorState = rootNavigatorKey.currentState;
    if (navigatorState == null) {
      return null;
    }
    return navigatorState.push(
      PublishRoute(
        pageBuilder: (context, animation, secondaryAnimation) {
          if (context.isPortrait) {
            return SafeArea(
              child: FractionallySizedBox(
                heightFactor: 0.7,
                widthFactor: 1.0,
                alignment: Alignment.bottomCenter,
                child: isFullScreen() && padding != null
                    ? Padding(
                        padding: EdgeInsets.only(bottom: padding),
                        child: child,
                      )
                    : child,
              ),
            );
          }
          return SafeArea(
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              alignment: Alignment.centerRight,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final begin = context.isPortrait
              ? const Offset(0.0, 1.0)
              : const Offset(1.0, 0.0);
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: begin,
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        settings: RouteSettings(arguments: Get.arguments),
      ),
    );
  }

  static void toLiveRoom(
    int? roomId, {
    bool off = false,
  }) {
    if (roomId == null) {
      return;
    }
    // Use go_router navigation
    if (off) {
      replaceNamed(AppRoutes.liveRoom, extra: roomId);
    } else {
      pushNamed(AppRoutes.liveRoom, extra: roomId);
    }
  }

  static Future<void>? toVideoPage({
    VideoType videoType = VideoType.ugc,
    int? aid,
    String? bvid,
    required int cid,
    int? seasonId,
    int? epId,
    int? pgcType,
    String? cover,
    String? title,
    int? progress, // milliseconds
    Map? extraArguments,
    bool off = false,
  }) {
    final arguments = <String, dynamic>{
      'aid': aid ?? IdUtils.bv2av(bvid!),
      'bvid': bvid ?? IdUtils.av2bv(aid!),
      'cid': cid,
      'seasonId': ?seasonId,
      'epId': ?epId,
      'pgcType': ?pgcType,
      'cover': ?cover,
      'title': ?title,
      'progress': ?progress,
      'videoType': videoType,
      'heroTag': Utils.makeHeroTag(cid),
      ...?extraArguments,
    };
    // Use go_router navigation
    if (off) {
      replaceNamed(AppRoutes.video, extra: arguments);
    } else {
      pushNamed(AppRoutes.video, extra: arguments);
    }
    return Future.value();
  }

  static final _pgcRegex = RegExp(r'(ep|ss)(\d+)');
  static bool viewPgcFromUri(
    String uri, {
    bool isPgc = true,
    int? progress, // milliseconds
    int? aid,
  }) {
    RegExpMatch? match = _pgcRegex.firstMatch(uri);
    if (match != null) {
      bool isSeason = match.group(1) == 'ss';
      String id = match.group(2)!;
      if (isPgc) {
        viewPgc(
          seasonId: isSeason ? id : null,
          epId: isSeason ? null : id,
          progress: progress,
        );
      } else {
        viewPugv(
          seasonId: isSeason ? id : null,
          epId: isSeason ? null : id,
          aid: aid,
        );
      }
      return true;
    }
    return false;
  }

  static EpisodeItem findEpisode(
    List<EpisodeItem> episodes, {
    dynamic epId,
    bool isPgc = true,
  }) {
    // epId episode -> progress episode -> first episode
    EpisodeItem? episode;
    if (epId != null) {
      epId = epId.toString();
      episode = episodes.firstWhereOrNull(
        (item) => (isPgc ? item.epId : item.id).toString() == epId,
      );
    }
    return episode ?? episodes.first;
  }

  static Future<void> viewPgc({
    dynamic seasonId,
    dynamic epId,
    int? progress, // milliseconds
  }) async {
    try {
      SmartDialog.showLoading(msg: '资源获取中');
      final res = await SearchHttp.pgcInfo(seasonId: seasonId, epId: epId);
      SmartDialog.dismiss();
      if (res case Success(:final response)) {
        final episodes = response.episodes;
        final hasEpisode = episodes != null && episodes.isNotEmpty;

        EpisodeItem? episode;

        void viewSection(EpisodeItem episode) {
          toVideoPage(
            videoType: VideoType.ugc,
            bvid: episode.bvid!,
            cid: episode.cid!,
            seasonId: response.seasonId,
            epId: episode.epId,
            cover: episode.cover,
            progress: progress,
            extraArguments: {
              'pgcApi': true,
              'pgcItem': response,
            },
          );
        }

        if (epId != null) {
          epId = epId.toString();
          if (hasEpisode) {
            episode = episodes.firstWhereOrNull(
              (item) => item.epId.toString() == epId,
            );
          }

          // find section
          if (episode == null) {
            final sections = response.section;
            if (sections != null && sections.isNotEmpty) {
              for (final section in sections) {
                final episodes = section.episodes;
                if (episodes != null && episodes.isNotEmpty) {
                  for (final episode in episodes) {
                    if (episode.epId.toString() == epId) {
                      // view as ugc
                      viewSection(episode);
                      return;
                    }
                  }
                }
              }
            }
          }
        }

        if (hasEpisode) {
          episode ??= findEpisode(
            episodes,
            epId: response.userStatus?.progress?.lastEpId,
          );
          toVideoPage(
            videoType: VideoType.pgc,
            bvid: episode.bvid!,
            cid: episode.cid!,
            seasonId: response.seasonId,
            epId: episode.epId,
            pgcType: response.type,
            cover: episode.cover,
            progress: progress,
            extraArguments: {
              'pgcItem': response,
            },
          );
          return;
        } else {
          episode ??= response.section?.firstOrNull?.episodes?.firstOrNull;
          if (episode != null) {
            viewSection(episode);
            return;
          }
        }

        SmartDialog.showToast('资源加载失败');
      } else {
        res.toast();
      }
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast('$e');
      if (kDebugMode) debugPrint('$e');
    }
  }

  static Future<void> viewPugv({
    dynamic seasonId,
    dynamic epId,
    int? aid,
  }) async {
    try {
      SmartDialog.showLoading(msg: '资源获取中');
      final res = await SearchHttp.pugvInfo(seasonId: seasonId, epId: epId);
      SmartDialog.dismiss();
      if (res case Success(:final response)) {
        final episodes = response.episodes;
        if (episodes != null && episodes.isNotEmpty) {
          EpisodeItem? episode;
          if (aid != null) {
            episode = episodes.firstWhereOrNull((e) => e.aid == aid);
          }
          episode ??= findEpisode(
            episodes,
            epId: epId ?? response.userStatus?.progress?.lastEpId,
            isPgc: false,
          );
          toVideoPage(
            videoType: VideoType.pugv,
            aid: episode.aid!,
            cid: episode.cid!,
            seasonId: response.seasonId,
            epId: episode.id,
            cover: episode.cover,
            extraArguments: {
              'pgcItem': response,
            },
          );
        } else {
          SmartDialog.showToast('资源加载失败');
        }
      } else {
        res.toast();
      }
    } catch (e) {
      SmartDialog.dismiss();
      SmartDialog.showToast(e.toString());
    }
  }

  static Future<T?> toDupNamed<T extends Object?>(
    String page, {
    dynamic arguments,
    Map<String, String>? parameters,
    bool off = false,
    bool preventDuplicates = false,
    int? id,
  }) {
    // Use GetX navigation for compatibility with pages that use Get.arguments
    // Note: Video page (/videoV) has been migrated to go_router (Phase 13)
    // TODO: Migrate remaining pages to go_router navigation
    if (off) {
      return Get.offNamed<T>(
        page,
        arguments: arguments,
        parameters: parameters,
        preventDuplicates: preventDuplicates,
        id: id,
      ) as Future<T?>;
    } else {
      return Get.toNamed<T>(
        page,
        arguments: arguments,
        parameters: parameters,
        preventDuplicates: preventDuplicates,
        id: id,
      ) as Future<T?>;
    }
  }

  /// Build URI with path and query parameters
  static Uri _buildUri(String path, Map<String, String>? parameters) {
    if (parameters == null || parameters.isEmpty) {
      return Uri.parse(path);
    }
    return Uri.parse(path).replace(queryParameters: parameters);
  }

  /// go_router specific navigation method
  static void goNamed(
    String path, {
    Object? extra,
    Map<String, String>? parameters,
  }) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final uri = _buildUri(path, parameters);
    context.go(uri.toString(), extra: extra);
  }

  /// go_router specific push method
  static void pushNamed(
    String path, {
    Object? extra,
    Map<String, String>? parameters,
  }) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final uri = _buildUri(path, parameters);
    context.push(uri.toString(), extra: extra);
  }

  /// go_router specific replace method
  static void replaceNamed(
    String path, {
    Object? extra,
    Map<String, String>? parameters,
  }) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;

    final uri = _buildUri(path, parameters);
    context.pushReplacement(uri.toString(), extra: extra);
  }

  /// Check if router can pop
  static bool canPop() {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return false;
    return context.canPop();
  }

  /// Pop the current route
  static void pop<T extends Object?>([T? result]) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    context.pop(result);
  }
}
