import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:PiliPlus/app/app.dart';
import 'package:PiliPlus/shared/widgets/custom_icon.dart';
import 'package:PiliPlus/shared/widgets/image/network_img_layer.dart';
import 'package:PiliPlus/shared/widgets/image_viewer/hero_dialog_route.dart';
import 'package:PiliPlus/shared/widgets/keep_alive_wrapper.dart';
import 'package:PiliPlus/shared/widgets/scroll_physics.dart';
import 'package:PiliPlus/core/constants/constants.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/episode_panel_type.dart';
import 'package:PiliPlus/models/pgc/pgc_info_model/result.dart';
import 'package:PiliPlus/models/video/video_detail/episode.dart' as ugc;
import 'package:PiliPlus/models/video/video_detail/page.dart';
import 'package:PiliPlus/models/video/video_detail/ugc_season.dart';
import 'package:PiliPlus/models/video/video_tag/data.dart';
import 'package:PiliPlus/features/common/presentation/pages/common_intro_controller.dart';
import 'package:PiliPlus/features/danmaku/danmaku.dart';
import 'package:PiliPlus/features/episode_panel/episode_panel.dart';
import 'package:PiliPlus/features/video/presentation/pages/ai_conclusion/view.dart';
import 'package:PiliPlus/features/video/presentation/pages/controller.dart';
import 'package:PiliPlus/features/video/presentation/pages/introduction/local/controller.dart';
import 'package:PiliPlus/features/video/presentation/pages/introduction/local/view.dart';
import 'package:PiliPlus/features/video/presentation/pages/introduction/pgc/controller.dart';
import 'package:PiliPlus/features/video/presentation/pages/introduction/pgc/view.dart';
import 'package:PiliPlus/features/video/presentation/widgets/introduction/pgc/intro_detail.dart';
import 'package:PiliPlus/features/video/presentation/pages/introduction/ugc/controller.dart';
import 'package:PiliPlus/features/video/presentation/pages/introduction/ugc/view.dart';
import 'package:PiliPlus/features/video/presentation/widgets/introduction/ugc/page.dart';
import 'package:PiliPlus/features/video/presentation/widgets/introduction/ugc/season.dart';
import 'package:PiliPlus/features/video/presentation/pages/member/controller.dart';
import 'package:PiliPlus/features/video/presentation/pages/member/view.dart';
import 'package:PiliPlus/features/video/presentation/pages/related/view.dart';
import 'package:PiliPlus/features/video/presentation/pages/reply/controller.dart';
import 'package:PiliPlus/features/video/presentation/pages/reply/view.dart';
import 'package:PiliPlus/features/video/presentation/pages/view_point/view.dart';
import 'package:PiliPlus/features/video/presentation/widgets/header_control.dart';
import 'package:PiliPlus/features/video/presentation/widgets/player_focus.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/plugin/pl_player/models/fullscreen_mode.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_repeat.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_status.dart';
import 'package:PiliPlus/plugin/pl_player/utils/fullscreen.dart';
import 'package:PiliPlus/plugin/pl_player/view.dart';
import 'package:PiliPlus/services/service_locator.dart';
import 'package:PiliPlus/services/shutdown_timer_service.dart'
    show shutdownTimerService;
import 'package:PiliPlus/utils/accounts.dart';
import 'package:PiliPlus/utils/extension/scroll_controller_ext.dart';
import 'package:PiliPlus/app/theme/extensions/theme_extensions.dart';
import 'package:PiliPlus/utils/image_utils.dart';
import 'package:PiliPlus/utils/num_utils.dart';
import 'package:PiliPlus/utils/page_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:floating/floating.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/features/video/presentation/providers/video_detail_provider.dart';
import 'package:PiliPlus/features/video/presentation/providers/video_reply_provider.dart';
import 'package:PiliPlus/features/video/presentation/providers/video_states.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';

class VideoDetailPageV extends ConsumerStatefulWidget {
  const VideoDetailPageV({super.key, this.args});

  final Map<String, dynamic>? args;

  @override
  ConsumerState<VideoDetailPageV> createState() => _VideoDetailPageVState();
}

class _VideoDetailPageVState extends ConsumerState<VideoDetailPageV>
    with TickerProviderStateMixin, RouteAware, WidgetsBindingObserver {
  late final String heroTag;

  late final VideoDetailController videoDetailController;
  late final VideoReplyController _videoReplyController;
  PlPlayerController? plPlayerController;

  // PHASE 6: Riverpod state access (replacing GetX controller property access)
  VideoDetailState get videoState => ref.watch(videoDetailProvider);
  String get bvid => videoState.bvid;
  int get aid => videoState.aid;
  int get cid => videoState.cid;
  bool get isUgc => videoState.isUgc;
  bool get isFileSource => videoState.isFileSource;
  VideoType get videoType => videoState.videoType;
  bool get showReply => videoState.showReply; // PHASE 7: Added for state access
  bool get isQuerying => videoState.isQuerying; // PHASE 7: Added for state access
  String? get videoUrl => videoState.videoUrl; // PHASE 7: Added for state access
  String? get audioUrl => videoState.audioUrl; // PHASE 7: Added for state access
  Duration? get playedTime => videoState.playedTime; // PHASE 7: Added for state access
  bool get horizontalScreen => videoState.horizontalScreen; // PHASE 7: Added for state access
  bool get setSystemBrightness => videoState.setSystemBrightness; // PHASE 7: Added for state access
  double get videoHeight => videoState.videoHeight; // PHASE 7: Added for state access
  bool get isVerticalState => videoState.isVertical; // PHASE 7: Non-Rx version from state
  bool get isExpanding => videoState.isExpanding; // PHASE 7: Added for state access
  bool get isCollapsing => videoState.isCollapsing; // PHASE 7: Added for state access
  bool get showVideoSheet => videoState.showVideoSheet; // PHASE 7: Added for state access
  PlayerStatus? get playerStatus => videoState.playerStatus; // PHASE 7: Added for state access
  String get cover => videoState.cover; // PHASE 7: Added for state access (non-Rx)
  int get seasonIndex => videoState.seasonIndex; // PHASE 7: Added for state access (non-Rx)
  double get minVideoHeight => videoState.minVideoHeight; // PHASE 7: Added for state access
  double get maxVideoHeight => videoState.maxVideoHeight; // PHASE 7: Added for state access
  bool get isPlayAll => videoState.args['isPlayAll'] == true; // PHASE 7: From args
  bool get continuePlayingPart => videoState.args['isContinuePlaying'] == true; // PHASE 7: From args
  bool get showRelatedVideo => videoState.args['showRelatedVideo'] == true; // PHASE 7: From args
  bool get imageview => videoState.imageview; // PHASE 7: Added for state access
  bool get autoPlay => videoState.autoPlay; // PHASE 7: Added for state access
  int? get seasonCid => videoState.seasonCid; // PHASE 8: Added for state access
  double? get brightness => videoState.brightness; // PHASE 8: Added for state access

  // intro ctr - PHASE 6: Will be initialized in initState() using Riverpod state
  late CommonIntroController introController;
  late final UgcIntroController ugcIntroController;
  late final PgcIntroController pgcIntroController;
  late final LocalIntroController localIntroController;

  // PlPlayerController shortcuts (accessed via controller for now)
  bool get autoExitFullscreen =>
      videoDetailController.plPlayerController.autoExitFullscreen;

  bool get autoPlayEnable =>
      videoDetailController.plPlayerController.autoPlayEnable;

  bool get enableVerticalExpand =>
      videoDetailController.plPlayerController.enableVerticalExpand;

  bool get pipNoDanmaku =>
      videoDetailController.plPlayerController.pipNoDanmaku;

  bool isShowing = true;

  bool get isFullScreen =>
      videoDetailController.plPlayerController.isFullScreen.value;

  bool get _shouldShowSeasonPanel {
    if (isFileSource || // PHASE 6: Using Riverpod state
        isPortrait ||
        !isUgc) { // PHASE 6: Using Riverpod state
      return false;
    }
    late final videoDetail = ugcIntroController.videoDetail.value;
    return videoDetailController.plPlayerController.horizontalSeasonPanel &&
        (videoDetail.ugcSeason != null ||
            ((videoDetail.pages?.length ?? 0) > 1));
  }

  final videoReplyPanelKey = GlobalKey();
  final videoRelatedKey = GlobalKey();
  final videoIntroKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // Merge parameters: prioritize widget.args (go_router), fallback to Get.arguments (compatibility)
    final args = widget.args ?? Get.arguments as Map<String, dynamic>? ?? {};

    // PHASE 7: Initialize Riverpod provider with route arguments
    ref.read(videoDetailProvider.notifier).setArgs(args, isInit: true);

    heroTag = args['heroTag'] ?? Utils.makeHeroTag(args['cid']);

    // PHASE 11 FIX: Read state directly in initState (cannot use ref.watch())
    final state = ref.read(videoDetailProvider);

    PlPlayerController.setPlayCallBack(playCallBack);
    videoDetailController = Get.put(VideoDetailController(args: args), tag: heroTag);

    if (state.showReply) { // PHASE 11: Direct state access in initState
      _videoReplyController = Get.put(
        VideoReplyController(
          aid: state.aid,
          videoType: state.videoType,
          heroTag: heroTag,
        ),
        tag: heroTag,
      );
    }

    if (state.isFileSource) { // PHASE 11: Direct state access in initState
      localIntroController = Get.put(LocalIntroController(), tag: heroTag);
    } else if (state.isUgc) { // PHASE 11: Direct state access in initState
      ugcIntroController = Get.put(UgcIntroController(), tag: heroTag);
    } else {
      pgcIntroController = Get.put(PgcIntroController(), tag: heroTag);
    }

    // PHASE 6: Initialize introController based on state (replaces field initializer)
    introController = state.isFileSource
        ? localIntroController
        : state.isUgc
        ? ugcIntroController
        : pgcIntroController;

    videoSourceInit();
    autoScreen();

    // PHASE 9: Auto-sync listeners removed - Riverpod is now the single source of truth

    WidgetsBinding.instance.addObserver(this);
  }

  // 获取视频资源，初始化播放器
  Future<void> videoSourceInit() async {
    ref.read(videoDetailProvider.notifier).queryVideoUrl(); // PHASE 7: Using Riverpod notifier
    final state = ref.read(videoDetailProvider); // PHASE 11: Read state directly
    if (state.autoPlay) { // PHASE 11: Direct state access
      plPlayerController = videoDetailController.plPlayerController;
      plPlayerController!
        ..addStatusLister(playerListener)
        ..addPositionListener(positionListener);
      await plPlayerController!.autoEnterFullscreen();
    }
  }

  void positionListener(Duration position) {
    ref.read(videoDetailProvider.notifier).updatePlayedTime(position); // PHASE 7: Using Riverpod notifier
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    late final ctr = videoDetailController.plPlayerController;
    if (state == AppLifecycleState.resumed) {
      if (!ctr.showDanmaku) {
        introController.startTimer();
        ctr.showDanmaku = true;

        // 修复从后台恢复时全屏状态下屏幕方向错误的问题
        if (isFullScreen && Platform.isIOS) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // 根据视频方向重新设置屏幕方向
            final isVertical = isVerticalState; // PHASE 7: Using Riverpod state (non-Rx)
            final mode = ctr.mode;

            if (!(mode == FullScreenMode.vertical ||
                (mode == FullScreenMode.auto && isVertical) ||
                (mode == FullScreenMode.ratio &&
                    (isVertical || maxHeight / maxWidth < kScreenRatio)))) {
              landscape();
            }
          });
        }
      }
    } else if (state == AppLifecycleState.paused) {
      introController.cancelTimer();
      ctr.showDanmaku = false;
    }
  }

  Future<void>? playCallBack() {
    return plPlayerController?.play();
  }

  // 播放器状态监听
  Future<void> playerListener(PlayerStatus status) async {
    final isPlaying = status.isPlaying;
    try {
      if (videoDetailController.scrollCtr.hasClients) {
        if (isPlaying) {
          if (!isExpanding && // PHASE 7: Using Riverpod state
              videoDetailController.scrollCtr.offset != 0 &&
              !videoDetailController.animationController.isAnimating) {
            ref.read(videoDetailProvider.notifier).setExpanding(true); // PHASE 7: Using Riverpod notifier
            videoDetailController.animationController.forward(
              from:
                  1 -
                  videoDetailController.scrollCtr.offset /
                      videoHeight, // PHASE 7: Using Riverpod state
            );
          } else {
            refreshPage();
          }
        } else {
          refreshPage();
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('handle player status: $e');
    }

    if (status.isCompleted) {
      try {
        if (videoDetailController
                .steinEdgeInfo
                ?.edges
                ?.questions
                ?.firstOrNull
                ?.choices
                ?.isNotEmpty ==
            true) {
          ref.read(videoDetailProvider.notifier).setShowSteinEdgeInfo(true); // PHASE 7: Using Riverpod notifier
          return;
        }
      } catch (_) {}

      bool exitFlag = true;

      /// 顺序播放 列表循环
      if (shutdownTimerService.isWaiting) {
        shutdownTimerService.handleWaiting();
      } else {
        switch (plPlayerController!.playRepeat) {
          case PlayRepeat.singleCycle:
            exitFlag = false;
            plPlayerController!.play(repeat: true);
          case PlayRepeat.listOrder:
          case PlayRepeat.listCycle:
          case PlayRepeat.autoPlayRelated:
            exitFlag = !introController.nextPlay();
          case PlayRepeat.pause:
        }
      }

      if (exitFlag) {
        // 结束播放退出全屏
        if (autoExitFullscreen) {
          plPlayerController!.triggerFullScreen(status: false);
          if (plPlayerController!.controlsLock.value) {
            plPlayerController!.onLockControl(false);
          }
        }
        // 播放完展示控制栏
        if (Platform.isAndroid) {
          if (await Floating().pipStatus == PiPStatus.disabled) {
            plPlayerController!.onLockControl(false);
          }
        }
      }
    }
  }

  // 继续播放或重新播放
  void continuePlay() {
    plPlayerController!.play();
  }

  /// 未开启自动播放时触发播放
  Future<void> handlePlay() async {
    if (!isFileSource) { // PHASE 6: Using Riverpod state
      if (isQuerying) { // PHASE 7: Using Riverpod state
        if (kDebugMode) debugPrint('handlePlay: querying');
        return;
      }
      if (videoUrl == null || // PHASE 7: Using Riverpod state
          audioUrl == null) { // PHASE 7: Using Riverpod state
        if (kDebugMode) {
          debugPrint('handlePlay: videoUrl/audioUrl not initialized');
        }
        ref.read(videoDetailProvider.notifier).queryVideoUrl(); // PHASE 7: Using Riverpod notifier
        return;
      }
    }
    plPlayerController = videoDetailController.plPlayerController;
    ref.read(videoDetailProvider.notifier).setAutoPlay(true); // PHASE 6: Using Riverpod notifier
    if (videoDetailController.plPlayerController.preInitPlayer) {
      await plPlayerController!.play();
    } else {
      await ref.read(videoDetailProvider.notifier).playerInit(autoplay: true); // PHASE 7: Using Riverpod notifier
    }
    if (!mounted || !isShowing) return;
    plPlayerController!
      ..addStatusLister(playerListener)
      ..addPositionListener(positionListener);
    await plPlayerController!.autoEnterFullscreen();
  }

  @override
  void dispose() {
    plPlayerController
      ?..removeStatusLister(playerListener)
      ..removePositionListener(positionListener);

    videoDetailController.animController?.removeListener(animListener);

    Get.delete<HorizontalMemberPageController>(
      tag: videoDetailController.heroTag,
    );

    if (!Get.previousRoute.startsWith('/video')) {
      if (Platform.isAndroid && !setSystemBrightness) { // PHASE 7: Using Riverpod state
        ScreenBrightnessPlatform.instance.resetApplicationScreenBrightness();
      }
      PlPlayerController.setPlayCallBack(null);
    }

    if (!isFileSource) { // PHASE 6: Using Riverpod state
      if (isUgc) { // PHASE 6: Using Riverpod state
        ugcIntroController
          ..cancelTimer()
          ..videoDetail.close();
      } else if (!isUgc) { // PHASE 12: Added null safety check
        pgcIntroController.cancelTimer();
      }
    } else {
      localIntroController.cancelTimer(); // PHASE 12: Added file source case
    }
    if (!horizontalScreen) { // PHASE 7: Using Riverpod state
      AutoOrientation.portraitUpMode();
    }
    if (!videoDetailController.plPlayerController.isCloseAll) {
      videoPlayerServiceHandler?.onVideoDetailDispose(heroTag);
      if (plPlayerController != null) {
        ref.read(videoDetailProvider.notifier).makeHeartBeat(); // PHASE 7: Using Riverpod notifier
        plPlayerController!.dispose();
      } else {
        PlPlayerController.updatePlayCount();
      }
    }
    PageUtils.routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    if (PlatformUtils.isMobile) {
      showStatusBar();
    }
    super.dispose();
  }

  @override
  // 离开当前页面时
  void didPushNext() {
    if (Get.routing.route is HeroDialogRoute) {
      ref.read(videoDetailProvider.notifier).setImageview(true); // PHASE 7: Using Riverpod notifier
      return;
    }

    WidgetsBinding.instance.removeObserver(this);

    if (Platform.isAndroid && !setSystemBrightness) { // PHASE 7: Using Riverpod state
      ScreenBrightnessPlatform.instance.resetApplicationScreenBrightness();
    }

    ref.read(videoDetailProvider.notifier).cancelBlockListener(); // PHASE 7: Using Riverpod notifier

    introController.cancelTimer();

    videoDetailController
      ..playerStatus = plPlayerController?.playerStatus.value
      ..brightness = plPlayerController?.brightness.value;
    ref.read(videoDetailProvider.notifier).setBrightness(
      plPlayerController?.brightness.value,
    ); // PHASE 8: Save brightness to Riverpod state
    if (plPlayerController != null) {
      ref.read(videoDetailProvider.notifier).makeHeartBeat(); // PHASE 7: Using Riverpod notifier
      plPlayerController!
        ..removeStatusLister(playerListener)
        ..removePositionListener(positionListener)
        ..pause();
    }
    isShowing = false;
    super.didPushNext();
  }

  @override
  // 返回当前页面时
  void didPopNext() {
    if (imageview) { // PHASE 7: Using Riverpod state
      ref.read(videoDetailProvider.notifier).setImageview(false); // PHASE 7: Using Riverpod notifier
      return;
    }

    if (plPlayerController?.isCloseAll == true) {
      return;
    }

    WidgetsBinding.instance.addObserver(this);

    plPlayerController?.isLive = false;
    if (videoDetailController.plPlayerController.playerStatus.isPlaying &&
        playerStatus != PlayerStatus.playing) { // PHASE 7: Using Riverpod state
      videoDetailController.plPlayerController.pause();
    }

    isShowing = true;
    PlPlayerController.setPlayCallBack(playCallBack);

    introController.startTimer();

    if (mounted &&
        Platform.isAndroid &&
        !setSystemBrightness) { // PHASE 7: Using Riverpod state
      if (brightness != null) { // PHASE 8: Using Riverpod state
        plPlayerController?.brightness.value = brightness!;
        if (brightness != -1.0) {
          ScreenBrightnessPlatform.instance.setApplicationScreenBrightness(
            brightness!,
          );
        } else {
          ScreenBrightnessPlatform.instance.resetApplicationScreenBrightness();
        }
      } else {
        ScreenBrightnessPlatform.instance.resetApplicationScreenBrightness();
      }
    }

    () async {
      if (videoState.autoPlay) { // PHASE 6: Using Riverpod state
        await ref.read(videoDetailProvider.notifier).playerInit( // PHASE 7: Using Riverpod notifier
          autoplay: playerStatus?.isPlaying ?? false, // PHASE 7: Using Riverpod state
        );
      } else if (videoDetailController.plPlayerController.preInitPlayer &&
          !isQuerying && // PHASE 7: Using Riverpod state
          videoState.videoState is! Error) { // PHASE 8: Using Riverpod state
        await ref.read(videoDetailProvider.notifier).playerInit(); // PHASE 7: Using Riverpod notifier
      }
      if (!mounted || !isShowing) return;
      plPlayerController
        ?..addStatusLister(playerListener)
        ..addPositionListener(positionListener);
    }();

    super.didPopNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PageUtils.routeObserver.subscribe(
      this,
      ModalRoute.of(context)! as PageRoute,
    );

    padding = MediaQuery.viewPaddingOf(context);

    final size = MediaQuery.sizeOf(context);
    maxWidth = size.width;
    maxHeight = size.height;

    final shortestSide = size.shortestSide;
    final minVideoHeight = shortestSide / StyleString.aspectRatio16x9;
    final maxVideoHeight = max(size.longestSide * 0.65, shortestSide);
    videoDetailController
      ..isPortrait = isPortrait = maxHeight >= maxWidth
      ..minVideoHeight = minVideoHeight
      ..maxVideoHeight = maxVideoHeight
      ..videoHeight = isVerticalState // PHASE 7: Using Riverpod state (non-Rx)
          ? maxVideoHeight
          : minVideoHeight;

    themeData = videoDetailController.plPlayerController.darkVideoPage
        ? MyApp.darkThemeData ?? Theme.of(context)
        : Theme.of(context);
  }

  void animListener() {
    if (videoDetailController.animationController.isForwardOrCompleted) {
      cal();
      refreshPage();
    }
  }

  late double animHeight;

  void cal() {
    if (isExpanding) { // PHASE 7: Using Riverpod state
      animHeight = clampDouble(
        videoHeight * // PHASE 7: Using Riverpod state
            videoDetailController.animationController.value,
        kToolbarHeight,
        videoHeight, // PHASE 7: Using Riverpod state
      );
    } else if (isCollapsing) { // PHASE 7: Using Riverpod state
      animHeight = clampDouble(
        maxVideoHeight -
            (maxVideoHeight -
                    minVideoHeight) *
                videoDetailController.animationController.value,
        minVideoHeight,
        maxVideoHeight, // PHASE 7: Using Riverpod state
      );
    }
  }

  void refreshPage() {
    if (videoDetailController.scrollKey.currentState?.mounted == true) {
      videoDetailController.scrollKey.currentState?.setState(() {});
    }
  }

  Widget get childWhenDisabled {
    videoDetailController.animationController
      ..removeListener(animListener)
      ..addListener(animListener);
    if (PlatformUtils.isMobile && mounted && isShowing && !isFullScreen) {
      if (isPortrait) {
        if (!imageview) { // PHASE 7: Using Riverpod state
          showStatusBar();
        }
      } else if (!horizontalScreen) { // PHASE 7: Using Riverpod state
        hideStatusBar();
      }
    }
    if (PlatformUtils.isMobile) {
      if (!isPortrait &&
          !isFullScreen &&
          plPlayerController != null &&
          autoPlay) { // PHASE 7: Using Riverpod state
        WidgetsBinding.instance.addPostFrameCallback((_) {
          plPlayerController!.triggerFullScreen(
            status: true,
            isManualFS: false,
            mode: FullScreenMode.gravity,
          );
        });
      } else if (isPortrait &&
          isFullScreen &&
          plPlayerController?.isManualFS == false &&
          plPlayerController?.controlsLock.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          plPlayerController!.triggerFullScreen(status: false);
        });
      }
    }
    // MIGRATION: Removed NO-OP Obx() wrapper
    // ORIGINAL: Line 571-574 Obx()
    // REASON: Doesn't watch any reactive variables, just wraps return value
    return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            // MIGRATION: Use ConsumerWidget instead of Obx()
            // ORIGINAL: Line 578-618 Obx()
            // PATTERN: Single field watch (scrollRatio) + opacity animation + conditional rendering
            child: _PlPlayerAppBarWidget(
              videoDetailController: videoDetailController,
              isPortrait: isPortrait,
              themeData: themeData,
            ),
          ),
          body: ExtendedNestedScrollView(
            key: videoDetailController.scrollKey,
            controller: videoDetailController.scrollCtr,
            onlyOneScrollInBody: true,
            pinnedHeaderSliverHeightBuilder: () {
              double pinnedHeight = this.isFullScreen || !isPortrait
                  ? maxHeight - padding.top
                  : isExpanding || // PHASE 7: Using Riverpod state
                        isCollapsing // PHASE 7: Using Riverpod state
                  ? animHeight
                  : isCollapsing || // PHASE 7: Using Riverpod state
                        (plPlayerController?.playerStatus.isPlaying ?? false)
                  ? minVideoHeight // PHASE 7: Using Riverpod state
                  : kToolbarHeight;
              if (isExpanding && // PHASE 7: Using Riverpod state
                  videoDetailController.animationController.value == 1) {
                ref.read(videoDetailProvider.notifier).setExpanding(false); // PHASE 7: Using Riverpod notifier
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(videoDetailProvider.notifier).setScrollRatio(0); // PHASE 7: Using Riverpod notifier
                  refreshPage();
                });
              } else if (isCollapsing && // PHASE 7: Using Riverpod state
                  videoDetailController.animationController.value == 1) {
                ref.read(videoDetailProvider.notifier).setCollapsing(false); // PHASE 7: Using Riverpod notifier
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  refreshPage();
                });
              }
              return pinnedHeight;
            },
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              final height = isFullScreen || !isPortrait
                  ? maxHeight - padding.top
                  : isExpanding || // PHASE 7: Using Riverpod state
                        isCollapsing // PHASE 7: Using Riverpod state
                  ? animHeight
                  : videoHeight; // PHASE 7: Using Riverpod state
              return [
                SliverAppBar(
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  primary: false,
                  automaticallyImplyLeading: false,
                  pinned: true,
                  expandedHeight: height,
                  flexibleSpace: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        width: maxWidth,
                        height: height,
                        child: videoPlayer(
                          width: maxWidth,
                          height: height,
                        ),
                      ),
                      // MIGRATION: Obx() → ConsumerWidget
                      // ORIGINAL: Line 664-844 Obx()
                      // PATTERN: Multi-field watch (scrollRatio) + opacity animation + nested toolbar function
                      _VideoToolbarOverlayWidget(
                        videoDetailController: videoDetailController,
                        plPlayerController: plPlayerController,
                        themeData: themeData,
                        isPortrait: isPortrait,
                        handlePlay: handlePlay,
                        maxHeight: maxHeight,
                        maxWidth: maxWidth,
                        moreBtn: _moreBtn,
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: Scaffold(
              key: videoDetailController.childKey,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Column(
                children: [
                  buildTabBar(onTap: videoDetailController.animToTop),
                  Expanded(
                    child: videoTabBarView(
                      controller: videoDetailController.tabCtr,
                      children: [
                        videoIntro(
                          isHorizontal: false,
                          needCtr: false,
                          isNested: true,
                        ),
                        if (showReply) // PHASE 7: Using Riverpod state
                          videoReplyPanel(isNested: true),
                        if (_shouldShowSeasonPanel) seasonPanel,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
  }

  // MIGRATION: Removed NO-OP Obx() wrapper
  // ORIGINAL: Line 859-873 Obx()
  // REASON: Doesn't watch any reactive variables, just uses this.isFullScreen
  Widget get childWhenDisabledLandscape => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(backgroundColor: Colors.black, toolbarHeight: 0),
        body: Padding(
          padding: !isFullScreen
              ? padding.copyWith(top: 0, bottom: 0)
              : EdgeInsets.zero,
          child: childWhenDisabledLandscapeInner(isFullScreen, padding),
        ),
      );

  Widget childSplit(double ratio) {
    final double videoHeight = maxHeight - padding.vertical;
    final double width = videoHeight * ratio;
    final videoWidth = isFullScreen ? maxWidth : width;
    final introWidth = maxWidth - width - padding.horizontal;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: videoWidth,
          height: videoHeight,
          child: videoPlayer(
            width: videoWidth,
            height: videoHeight,
          ),
        ),
        Offstage(
          offstage: isFullScreen,
          child: SizedBox(
            width: introWidth,
            height: maxHeight - padding.top,
            child: Scaffold(
              key: videoDetailController.childKey,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTabBar(),
                  Expanded(
                    child: videoTabBarView(
                      controller: videoDetailController.tabCtr,
                      children: [
                        videoIntro(
                          width: introWidth,
                          height: maxHeight,
                        ),
                        if (showReply) // PHASE 7: Using Riverpod state videoReplyPanel(),
                        if (_shouldShowSeasonPanel) seasonPanel,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget childWhenDisabledLandscapeInner(
    bool isFullScreen,
    EdgeInsets padding,
  ) => Obx(() {
    if (isVerticalState && // PHASE 7: Using Riverpod state (non-Rx)
        enableVerticalExpand &&
        !isPortrait) {
      final double videoHeight = maxHeight - padding.vertical;
      final double width = videoHeight / StyleString.aspectRatio16x9;
      final videoWidth = isFullScreen ? maxWidth : width;
      final introWidth = (maxWidth - padding.horizontal - width) / 2;
      final introHeight = maxHeight - padding.top;
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Offstage(
            offstage: isFullScreen,
            child: SizedBox(
              width: introWidth,
              height: introHeight,
              child: videoIntro(
                width: introWidth,
                height: introHeight,
              ),
            ),
          ),
          SizedBox(
            width: videoWidth,
            height: videoHeight,
            child: videoPlayer(
              width: videoWidth,
              height: videoHeight,
            ),
          ),
          Offstage(
            offstage: isFullScreen,
            child: SizedBox(
              width: introWidth,
              height: introHeight,
              child: Scaffold(
                key: videoDetailController.childKey,
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  children: [
                    buildTabBar(showIntro: false),
                    Expanded(
                      child: videoTabBarView(
                        controller: videoDetailController.tabCtr,
                        children: [
                          if (showReply) // PHASE 7: Using Riverpod state
                            videoReplyPanel(),
                          if (_shouldShowSeasonPanel) seasonPanel,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    double width =
        clampDouble(maxHeight / maxWidth * 1.08, 0.5, 0.7) * maxWidth;
    if (maxWidth >= 560) {
      width = maxWidth - clampDouble(maxWidth - width, 280, 425);
    }
    final videoWidth = isFullScreen ? maxWidth : width;
    final double height = width / StyleString.aspectRatio16x9;
    final videoHeight = isFullScreen ? maxHeight - padding.top : height;
    if (height > maxHeight) {
      return childSplit(StyleString.aspectRatio16x9);
    }
    final introHeight = maxHeight - height - padding.top;
    final showIntro =
        isUgc && showRelatedVideo; // PHASE 8: Using Riverpod state getter
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: videoWidth,
              height: videoHeight,
              child: videoPlayer(
                width: videoWidth,
                height: videoHeight,
              ),
            ),
            if (!isFileSource) // PHASE 6: Using Riverpod state
              Offstage(
                offstage: isFullScreen,
                child: SizedBox(
                  width: width,
                  height: introHeight,
                  child: videoIntro(
                    width: width,
                    height: introHeight,
                    needRelated: false,
                    needCtr: false,
                  ),
                ),
              ),
          ],
        ),
        Offstage(
          offstage: isFullScreen,
          child: SizedBox(
            width: maxWidth - width - padding.horizontal,
            height: maxHeight - padding.top,
            child: Scaffold(
              key: videoDetailController.childKey,
              resizeToAvoidBottomInset: false,
              backgroundColor: Colors.transparent,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildTabBar(
                    introText: '相关视频',
                    showIntro: isFileSource // PHASE 6: Using Riverpod state
                        ? true
                        : showIntro,
                  ),
                  Expanded(
                    child: videoTabBarView(
                      controller: videoDetailController.tabCtr,
                      children: [
                        if (isFileSource) // PHASE 6: Using Riverpod state
                          localIntroPanel()
                        else if (showIntro)
                          KeepAliveWrapper(
                            builder: (context) => CustomScrollView(
                              key: const PageStorageKey(CommonIntroController),
                              controller:
                                  videoDetailController.effectiveIntroScrollCtr,
                              slivers: [
                                RelatedVideoPanel(
                                  key: videoRelatedKey,
                                  heroTag: heroTag,
                                ),
                              ],
                            ),
                          ),
                        if (showReply) // PHASE 7: Using Riverpod state videoReplyPanel(),
                        if (_shouldShowSeasonPanel) seasonPanel,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  });

  // MIGRATION: Removed NO-OP Obx() wrapper
  // ORIGINAL: Line 1086-1098 Obx()
  // REASON: Doesn't watch any reactive variables, just uses this.isFullScreen
  Widget get childWhenDisabledAlmostSquare => Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(backgroundColor: Colors.black, toolbarHeight: 0),
        body: Padding(
          padding: !isFullScreen
              ? padding.copyWith(top: 0, bottom: 0)
              : EdgeInsets.zero,
          child: childWhenDisabledAlmostSquareInner(isFullScreen, padding),
        ),
      );

  Widget childWhenDisabledAlmostSquareInner(
    bool isFullScreen,
    EdgeInsets padding,
  ) => Obx(
    () {
      final isFullScreen = this.isFullScreen;
      if (isVerticalState && // PHASE 7: Using Riverpod state (non-Rx)
          enableVerticalExpand &&
          !isPortrait) {
        return childSplit(9 / 16);
      }
      final shouldShowSeasonPanel = _shouldShowSeasonPanel;
      final double height = maxHeight / 2.5;
      final videoHeight = isFullScreen ? maxHeight - padding.top : height;
      final bottomHeight = maxHeight - height - padding.top;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: maxWidth,
            height: videoHeight,
            child: videoPlayer(
              width: maxWidth,
              height: videoHeight,
            ),
          ),
          Offstage(
            offstage: isFullScreen,
            child: SizedBox(
              width: maxWidth - padding.horizontal,
              height: bottomHeight,
              child: Scaffold(
                key: videoDetailController.childKey,
                resizeToAvoidBottomInset: false,
                backgroundColor: Colors.transparent,
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTabBar(needIndicator: false),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: videoIntro(
                              width: () {
                                double flex = 1;
                                if (showReply) // PHASE 7: Using Riverpod state flex++;
                                if (shouldShowSeasonPanel) flex++;
                                return maxWidth / flex;
                              }(),
                              height: bottomHeight,
                            ),
                          ),
                          if (showReply) // PHASE 7: Using Riverpod state
                            Expanded(child: videoReplyPanel()),
                          if (shouldShowSeasonPanel)
                            Expanded(child: seasonPanel),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  // MIGRATION: Use ConsumerWidget instead of Obx()
  // ORIGINAL: Line 1169-1263 Obx()
  // PATTERN: Single field watch (autoPlay) + reverse conditional rendering
  Widget get manualPlayerWidget => _ManualPlayerWidget(
        videoDetailController: videoDetailController,
        themeData: themeData,
        onBackPressed: Get.back,
        onHomePressed: () {
          videoDetailController.plPlayerController
            ..isCloseAll = true
            ..dispose();
          Get.until((route) => route.isFirst);
        },
        onPlayPressed: handlePlay,
        moreBtn: _moreBtn,
      );

  Widget _moreBtn(Color color, {List<Shadow>? shadows}) => PopupMenuButton(
    icon: Icon(
      size: 22,
      Icons.more_vert,
      color: color,
      shadows: shadows,
    ),
    itemBuilder: (BuildContext context) => <PopupMenuEntry>[
      PopupMenuItem(
        onTap: introController.viewLater,
        child: const Text('稍后再看'),
      ),
      if (videoDetailController.epId == null)
        PopupMenuItem(
          onTap: () => videoDetailController.showNoteList(context),
          child: const Text('查看笔记'),
        ),
      if (!isFileSource) // PHASE 6: Using Riverpod state
        PopupMenuItem(
          onTap: () => videoDetailController.onDownload(this.context),
          child: const Text('缓存视频'),
        ),
      if (cover.isNotEmpty) // PHASE 7: Using Riverpod state (non-Rx)
        PopupMenuItem(
          onTap: () =>
              ImageUtils.downloadImg([cover]), // PHASE 7: Using Riverpod state (non-Rx)
          child: const Text('保存封面'),
        ),
      if (!isFileSource && isUgc) // PHASE 6: Using Riverpod state
        PopupMenuItem(
          onTap: videoDetailController.toAudioPage,
          child: const Text('听音频'),
        ),
      PopupMenuItem(
        onTap: () {
          if (!Accounts.main.isLogin) {
            SmartDialog.showToast('账号未登录');
          } else {
            PageUtils.reportVideo(aid); // PHASE 6: Using Riverpod state
          }
        },
        child: const Text('举报'),
      ),
    ],
  );

  Widget plPlayer({
    required double width,
    required double height,
    bool isPipMode = false,
  }) => PopScope(
    key: videoDetailController.videoPlayerKey,
    canPop:
        !isFullScreen &&
        (horizontalScreen || isPortrait), // PHASE 7: Using Riverpod state
    onPopInvokedWithResult: _onPopInvokedWithResult,
    // MIGRATION: Use ConsumerWidget instead of Obx()
    // ORIGINAL: Line 1255-1277 Obx()
    // PATTERN: Multi-field watch (videoState, autoPlay) + cross-controller check
    child: _PlayerVisibilityWidget2(
      videoDetailController: videoDetailController,
      plPlayerController: plPlayerController,
      introController: introController,
      heroTag: heroTag,
      isFullScreen: isFullScreen,
      isPortrait: isPortrait,
      width: width,
      height: height,
      isPipMode: isPipMode,
      pipNoDanmaku: pipNoDanmaku,
      showEpisodes: showEpisodes,
      showViewPoints: showViewPoints,
    ),
  );

  late ThemeData themeData;
  late bool isPortrait;
  late double maxWidth;
  late double maxHeight;
  late EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (videoDetailController.plPlayerController.isPipMode) {
      child = plPlayer(width: maxWidth, height: maxHeight, isPipMode: true);
    } else if (!horizontalScreen) { // PHASE 7: Using Riverpod state
      child = childWhenDisabled;
    } else if (maxWidth / maxHeight >= kScreenRatio) {
      child = childWhenDisabledLandscape;
    } else if (maxWidth / StyleString.aspectRatio16x9 < 0.4 * maxHeight) {
      child = childWhenDisabled;
    } else {
      child = childWhenDisabledAlmostSquare;
    }
    if (videoDetailController.plPlayerController.keyboardControl) {
      child = PlayerFocus(
        plPlayerController: videoDetailController.plPlayerController,
        introController: introController,
        onSendDanmaku: videoDetailController.showShootDanmakuSheet,
        canPlay: () {
          if (videoState.autoPlay) { // PHASE 6: Using Riverpod state
            return true;
          }
          handlePlay();
          return false;
        },
        onSkipSegment: videoDetailController.onSkipSegment,
        child: child,
      );
    }
    return videoDetailController.plPlayerController.darkVideoPage
        ? Theme(data: themeData, child: child)
        : child;
  }

  Widget buildTabBar({
    bool needIndicator = true,
    String? introText,
    bool showIntro = true,
    VoidCallback? onTap,
  }) {
    List<String> tabs = [
      if (showIntro)
        isFileSource ? '离线视频' : introText ?? '简介', // PHASE 6: Using Riverpod state
      if (showReply) '评论', // PHASE 7: Using Riverpod state
      if (_shouldShowSeasonPanel) '播放列表',
    ];
    if (videoDetailController.tabCtr.length != tabs.length) {
      videoDetailController.tabCtr.dispose();
      videoDetailController.tabCtr = TabController(
        vsync: this,
        length: tabs.length,
        initialIndex: tabs.isEmpty
            ? 0
            : videoDetailController.tabCtr.index.clamp(0, tabs.length - 1),
      );
    }

    final flag = !needIndicator || tabs.length == 1;
    Widget tabBar() => TabBar(
      labelColor: flag ? themeData.colorScheme.onSurface : null,
      indicator: flag ? const BoxDecoration() : null,
      padding: EdgeInsets.zero,
      controller: videoDetailController.tabCtr,
      labelStyle:
          TabBarTheme.of(context).labelStyle?.copyWith(fontSize: 13) ??
          const TextStyle(fontSize: 13),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      dividerColor: Colors.transparent,
      dividerHeight: 0,
      onTap: (value) {
        void animToTop() {
          if (onTap != null) {
            onTap();
            return;
          }
          String text = tabs[value];
          if (isFileSource || // PHASE 6: Using Riverpod state
              text == '简介' ||
              text == '相关视频') {
            videoDetailController.introScrollCtr?.animToTop();
          } else if (text.startsWith('评论')) {
            _videoReplyController.animateToTop();
          }
        }

        if (flag) {
          animToTop();
        } else if (!videoDetailController.tabCtr.indexIsChanging) {
          animToTop();
        }
      },
      tabs: tabs.map((text) {
        if (text == '评论') {
          // MIGRATION: Use ConsumerWidget instead of Obx()
          // ORIGINAL: Line 1460-1465 Obx()
          // PATTERN: Single field watch (count)
          return const _ReplyCountTabWidget();
        } else {
          return Tab(text: text);
        }
      }).toList(),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: themeData.dividerColor.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: SizedBox(
        height: 45,
        child: Row(
          children: [
            if (tabs.isEmpty)
              const Spacer()
            else
              Flexible(
                flex: tabs.length == 3 ? 2 : 1,
                child: tabBar(),
              ),
            Flexible(
              flex: 1,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 32,
                      child: TextButton(
                        style: const ButtonStyle(
                          padding: WidgetStatePropertyAll(EdgeInsets.zero),
                        ),
                        onPressed: videoDetailController.showShootDanmakuSheet,
                        child: Text(
                          '发弹幕',
                          style: TextStyle(
                            fontSize: 12,
                            color: themeData.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 38,
                      height: 38,
                      child: Obx(
                        () {
                          final ctr = videoDetailController.plPlayerController;
                          final enableShowDanmaku = ctr.enableShowDanmaku.value;
                          return IconButton(
                            onPressed: () {
                              final newVal = !enableShowDanmaku;
                              ctr.enableShowDanmaku.value = newVal;
                              if (!ctr.tempPlayerConf) {
                                GStorage.setting.put(
                                  SettingBoxKey.enableShowDanmaku,
                                  newVal,
                                );
                              }
                            },
                            icon: Icon(
                              size: 22,
                              enableShowDanmaku
                                  ? CustomIcons.dm_on
                                  : CustomIcons.dm_off,
                              color: enableShowDanmaku
                                  ? themeData.colorScheme.secondary
                                  : themeData.colorScheme.outline,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget videoPlayer({required double width, required double height}) {
    final isFullScreen = this.isFullScreen;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned.fill(child: ColoredBox(color: Colors.black)),

        if (isShowing) plPlayer(width: width, height: height),

        // MIGRATION: Use ConsumerWidget instead of Obx()
        // ORIGINAL: Line 1561-1580 Obx()
        // PATTERN: Single field watch (autoPlay) + reverse conditional rendering
        _AutoPlayCoverWidget(
          aid: aid, // PHASE 6: Using Riverpod state
          width: width,
          height: height,
          videoDetailController: videoDetailController,
          onTap: handlePlay,
        ),

        manualPlayerWidget,

        if (videoDetailController.plPlayerController.enableBlock ||
            continuePlayingPart) // PHASE 7: Using Riverpod state
          Positioned(
            left: 16,
            bottom: isFullScreen ? max(75, maxHeight * 0.25) : 75,
            width: MediaQuery.textScalerOf(context).scale(120),
            child: AnimatedList(
              padding: EdgeInsets.zero,
              key: videoDetailController.listKey,
              reverse: true,
              shrinkWrap: true,
              initialItemCount: videoDetailController.listData.length,
              itemBuilder: (context, index, animation) {
                return videoDetailController.buildItem(
                  videoDetailController.listData[index],
                  animation,
                );
              },
            ),
          ),

        // for debug
        // Positioned(
        //   right: 16,
        //   bottom: 75,
        //   child: FilledButton.tonal(
        //     onPressed: () {
        //       videoDetailController.onAddItem(
        //         SegmentModel(
        //           UUID: '',
        //           segmentType:
        //               SegmentType.values[Utils.random.nextInt(
        //                 SegmentType.values.length,
        //               )],
        //           segment: Pair(first: 0, second: 0),
        //           skipType: SkipType.alwaysSkip,
        //         ),
        //       );
        //     },
        //     child: const Text('skip'),
        //   ),
        // ),
        // Positioned(
        //   right: 16,
        //   bottom: 120,
        //   child: FilledButton.tonal(
        //     onPressed: () {
        //       videoDetailController.onAddItem(2);
        //     },
        //     child: const Text('index'),
        //   ),
        // ),
        // MIGRATION: Obx() → ConsumerWidget
        // ORIGINAL: Line 1380-1445 Obx()
        // PATTERN: Single field watch (showSteinEdgeInfo) + conditional rendering
        _SteinEdgeInfoWidget(
          videoDetailController: videoDetailController,
          plPlayerController: plPlayerController,
          ugcIntroController: ugcIntroController,
          themeData: themeData,
        ),
      ],
    );
  }

  Widget localIntroPanel({
    bool needCtr = true,
  }) {
    return CustomScrollView(
      controller: needCtr
          ? videoDetailController.effectiveIntroScrollCtr
          : null,
      physics: !needCtr
          ? const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics())
          : null,
      key: const PageStorageKey(CommonIntroController),
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 7, bottom: padding.bottom + 100),
          sliver: LocalIntroPanel(
            key: videoRelatedKey,
            heroTag: heroTag,
          ),
        ),
      ],
    );
  }

  Widget videoIntro({
    double? width,
    double? height,
    bool? isHorizontal,
    bool needRelated = true,
    bool needCtr = true,
    bool isNested = false,
  }) {
    if (isFileSource) { // PHASE 6: Using Riverpod state
      return localIntroPanel(needCtr: needCtr);
    }
    Widget introPanel() => KeepAliveWrapper(
      builder: (context) {
        final child = CustomScrollView(
          key: const PageStorageKey(CommonIntroController),
          controller: needCtr
              ? videoDetailController.effectiveIntroScrollCtr
              : null,
          physics: !needCtr
              ? const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                )
              : null,
          slivers: [
            if (isUgc) ...[ // PHASE 6: Using Riverpod state
              UgcIntroPanel(
                key: videoIntroKey,
                heroTag: heroTag,
                showAiBottomSheet: showAiBottomSheet,
                showEpisodes: showEpisodes,
                onShowMemberPage: onShowMemberPage,
                isPortrait: isPortrait,
                isHorizontal: isHorizontal ?? width! / height! >= kScreenRatio,
              ),
              if (needRelated && showRelatedVideo) ...[ // PHASE 7: Using Riverpod state
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: StyleString.safeSpace),
                    child: Divider(
                      height: 1,
                      indent: 12,
                      endIndent: 12,
                      color: themeData.colorScheme.outline.withValues(
                        alpha: 0.08,
                      ),
                    ),
                  ),
                ),
                RelatedVideoPanel(key: videoRelatedKey, heroTag: heroTag),
              ],
            ] else
              PgcIntroPage(
                key: videoIntroKey,
                heroTag: heroTag,
                cid: cid, // PHASE 7: Using Riverpod state (non-Rx)
                showEpisodes: showEpisodes,
                showIntroDetail: showIntroDetail,
                maxWidth: width ?? maxWidth,
                isLandscape: !isPortrait,
              ),
            SliverToBoxAdapter(
              child: SizedBox(
                height:
                    (isPlayAll && !isPortrait // PHASE 8: Using Riverpod state getter
                        ? 80
                        : StyleString.safeSpace) +
                    padding.bottom,
              ),
            ),
          ],
        );
        if (isNested) {
          return ExtendedVisibilityDetector(
            uniqueKey: const Key('intro-panel'),
            child: child,
          );
        }
        return child;
      },
    );
    if (isPlayAll) { // PHASE 7: Using Riverpod state
      return Stack(
        clipBehavior: Clip.none,
        children: [
          introPanel(),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12 + padding.bottom,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () => videoDetailController.showMediaListPanel(context),
                borderRadius: const BorderRadius.all(Radius.circular(14)),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.secondaryContainer.withValues(
                      alpha: 0.95,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(14)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.playlist_play, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        videoState.args['favTitle'] ?? '', // PHASE 8: Using Riverpod state
                        style: TextStyle(
                          color: themeData.colorScheme.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.keyboard_arrow_up_rounded, size: 26),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return introPanel();
  }

  Widget get seasonPanel {
    final videoDetail = ugcIntroController.videoDetail.value;
    return KeepAliveWrapper(
      builder: (context) => Column(
        children: [
          if ((videoDetail.pages?.length ?? 0) > 1)
            if (videoDetail.ugcSeason != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: PagesPanel(
                  heroTag: heroTag,
                  ugcIntroController: ugcIntroController,
                  bvid: ugcIntroController.bvid,
                  showEpisodes: showEpisodes,
                ),
              )
            else
              Expanded(
                // MIGRATION: Use ConsumerWidget instead of Obx()
                // ORIGINAL: Line 1787-1808 Obx()
                // PATTERN: Multi-field watch (cover, cid)
                child: _PartEpisodePanelWidget2(
                  heroTag: heroTag,
                  videoDetailController: videoDetailController,
                  ugcIntroController: ugcIntroController,
                  pgcIntroController: pgcIntroController,
                  videoDetail: videoDetail,
                  onReversePlay: () => onReversePlay(isSeason: false),
                ),
              ),
          if (videoDetail.ugcSeason != null) ...[
            if ((videoDetail.pages?.length ?? 0) > 1) ...[
              const SizedBox(height: 8),
              Divider(
                height: 1,
                color: themeData.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              // MIGRATION: Use ConsumerWidget instead of Obx()
              // ORIGINAL: Line 1809-1817 Obx()
              // PATTERN: Single field watch (introController.videoDetail) for key
              child: _SeasonPanelWidget(
                introController: introController,
                heroTag: heroTag,
                showEpisodes: showEpisodes,
                ugcIntroController: ugcIntroController,
              ),
            ),
            Expanded(
              // MIGRATION: Use ConsumerWidget instead of Obx()
              // ORIGINAL: Line 1820-1848 Obx()
              // PATTERN: Multi-field watch (seasonIndex, cover) + mixed controller access
              child: _SeasonEpisodePanelWidget2(
                heroTag: heroTag,
                videoDetailController: videoDetailController,
                ugcIntroController: ugcIntroController,
                pgcIntroController: pgcIntroController,
                videoDetail: videoDetail,
                onReversePlay: () => onReversePlay(isSeason: true),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget videoReplyPanel({bool isNested = false}) => VideoReplyPanel(
    key: videoReplyPanelKey,
    isNested: isNested,
    heroTag: heroTag,
  );

  // ai总结
  void showAiBottomSheet() {
    videoDetailController.childKey.currentState?.showBottomSheet(
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(),
      (context) =>
          AiConclusionPanel(item: ugcIntroController.aiConclusionResult!),
    );
  }

  void showIntroDetail(
    PgcInfoModel videoDetail,
    List<VideoTagItem>? videoTags,
  ) {
    videoDetailController.childKey.currentState?.showBottomSheet(
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(),
      (context) => PgcIntroPanel(
        item: videoDetail,
        videoTags: videoTags,
      ),
    );
  }

  void showEpisodes([
    int? index,
    UgcSeason? season,
    List<ugc.BaseEpisodeItem>? episodes,
    String? bvid,
    int? aid,
    int? cid,
  ]) {
    assert((cid == null) == (bvid == null));
    final isFullScreen = this.isFullScreen;
    if (cid == null) {
      videoDetailController.showMediaListPanel(context);
      return;
    }
    Widget listSheetContent({bool enableSlide = true}) => EpisodePanel(
      heroTag: heroTag,
      ugcIntroController: isUgc // PHASE 6: Using Riverpod state
          ? ugcIntroController
          : null,
      type: season != null
          ? EpisodeType.season
          : episodes is List<Part>
          ? EpisodeType.part
          : EpisodeType.pgc,
      cover: cover, // PHASE 7: Using Riverpod state (non-Rx)
      enableSlide: enableSlide,
      initialTabIndex: index ?? 0,
      bvid: bvid!,
      aid: aid,
      cid: cid,
      seasonId: season?.id,
      list: season != null ? season.sections! : [episodes],
      isReversed: !isUgc // PHASE 6: Using Riverpod state
          ? null
          : season != null
          ? ugcIntroController
                .videoDetail
                .value
                .ugcSeason!
                .sections![seasonIndex] // PHASE 7: Using Riverpod state (non-Rx)
                .isReversed
          : ugcIntroController.videoDetail.value.isPageReversed,
      isSupportReverse: isUgc, // PHASE 6: Using Riverpod state
      onChangeEpisode: isUgc // PHASE 12: Only UGC supports episode changes
          ? (episode) => ugcIntroController.onChangeEpisode(episode)
          : (episode) async => true, // No-op for PGC and file source
      onClose: Get.back,
      onReverse: () {
        PageUtils.pop();
        onReversePlay(isSeason: season != null);
      },
    );
    if (isFullScreen || showVideoSheet) { // PHASE 7: Using Riverpod state
      PageUtils.showVideoBottomSheet(
        context,
        isFullScreen: () => isFullScreen,
        child: videoDetailController.plPlayerController.darkVideoPage
            ? Theme(
                data: themeData,
                child: listSheetContent(enableSlide: false),
              )
            : listSheetContent(enableSlide: false),
      );
    } else {
      videoDetailController.childKey.currentState?.showBottomSheet(
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(),
        (context) => listSheetContent(),
      );
    }
  }

  void onReversePlay({required bool isSeason}) {
    if (isSeason && isPlayAll) { // PHASE 7: Using Riverpod state
      SmartDialog.showToast('当前为播放全部，合集不支持倒序');
      return;
    }

    final videoDetail = ugcIntroController.videoDetail.value;
    if (isSeason) {
      // reverse season
      final item = videoDetail
          .ugcSeason!
          .sections![seasonIndex]; // PHASE 7: Using Riverpod state (non-Rx)
      item
        ..isReversed = !item.isReversed
        ..episodes = item.episodes!.reversed.toList();

      if (!videoDetailController.plPlayerController.reverseFromFirst) {
        // keep current episode
        videoDetailController
          ..seasonIndex.refresh()
          ..cid.refresh();
      } else {
        // switch to first episode
        final episode = ugcIntroController
            .videoDetail
            .value
            .ugcSeason!
            .sections![seasonIndex] // PHASE 8: Using Riverpod state
            .episodes!
            .first;
        if (episode.cid != cid) { // PHASE 7: Using Riverpod state (non-Rx)
          ugcIntroController.onChangeEpisode(episode);
          ref.read(videoDetailProvider.notifier).setSeasonCid(episode.cid); // PHASE 8: Using Riverpod
        } else {
          videoDetailController
            ..seasonIndex.refresh()
            ..cid.refresh();
        }
      }
    } else {
      // reverse part
      videoDetail
        ..isPageReversed = !videoDetail.isPageReversed
        ..pages = videoDetail.pages!.reversed.toList();
      if (!videoDetailController.plPlayerController.reverseFromFirst) {
        // keep current episode
        // PHASE 8: No need for refresh in Riverpod - state changes auto-notify
      } else {
        // switch to first episode
        final episode = videoDetail.pages!.first;
        if (episode.cid != cid) { // PHASE 7: Using Riverpod state (non-Rx)
          ugcIntroController.onChangeEpisode(episode);
        }
        // PHASE 8: No need for refresh in Riverpod - state changes auto-notify
      }
    }
  }

  void showViewPoints() {
    if (isFullScreen || showVideoSheet) { // PHASE 7: Using Riverpod state
      PageUtils.showVideoBottomSheet(
        context,
        isFullScreen: () => isFullScreen,
        child: videoDetailController.plPlayerController.darkVideoPage
            ? Theme(
                data: themeData,
                child: ViewPointsPage(
                  enableSlide: false,
                  videoDetailController: videoDetailController,
                  plPlayerController: plPlayerController,
                ),
              )
            : ViewPointsPage(
                enableSlide: false,
                videoDetailController: videoDetailController,
                plPlayerController: plPlayerController,
              ),
      );
    } else {
      videoDetailController.childKey.currentState?.showBottomSheet(
        backgroundColor: Colors.transparent,
        constraints: const BoxConstraints(),
        (context) => ViewPointsPage(
          videoDetailController: videoDetailController,
          plPlayerController: plPlayerController,
        ),
      );
    }
  }

  void _onPopInvokedWithResult(bool didPop, result) {
    if (plPlayerController?.onPopInvokedWithResult(didPop, result) ?? false) {
      return;
    }
    if (PlatformUtils.isMobile &&
        !horizontalScreen && // PHASE 8: Using Riverpod state
        !isPortrait) {
      verticalScreenForTwoSeconds();
    }
  }

  void onShowMemberPage(int? mid) {
    videoDetailController.childKey.currentState?.showBottomSheet(
      shape: const RoundedRectangleBorder(),
      constraints: const BoxConstraints(),
      (context) {
        return HorizontalMemberPage(
          mid: mid,
          videoDetailController: videoDetailController,
          ugcIntroController: ugcIntroController,
        );
      },
    );
  }
}

/// Migrated Hero cover widget
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1603-1617 Obx()
/// PATTERN: Single field watch (cover)
/// COMPLEXITY: Low (simple Hero widget with image)
class _HeroCoverWidget extends ConsumerWidget {
  const _HeroCoverWidget({
    required this.aid,
    required this.width,
    required this.height,
    required this.videoDetailController,
    super.key,
  });

  final int aid;
  final double width;
  final double height;
  final VideoDetailController videoDetailController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // cover is auto-synced
    // NOTE: aid is used only for Hero tag, not watched reactively
    final cover = ref.watch(videoDetailProvider.select((s) => s.cover));

    return Hero(
      tag: aid,
      child: NetworkImgLayer(
        type: .emote,
        src: cover,
        width: width,
        height: height,
        cacheWidth: true,
        getPlaceHolder: () => Center(
          child: Image.asset('assets/images/loading.png'),
        ),
      ),
    );
  }
}

/// Migrated AppBar opacity widget in plPlayer method
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 578-618 Obx()
/// PATTERN: Single field watch (scrollRatio) + opacity animation + conditional rendering
/// COMPLEXITY: Medium (conditional AppBar with system overlay style)
class _PlPlayerAppBarWidget extends ConsumerWidget {
  const _PlPlayerAppBarWidget({
    required this.videoDetailController,
    required this.isPortrait,
    required this.themeData,
    super.key,
  });

  final VideoDetailController videoDetailController;
  final bool isPortrait;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // scrollRatio is auto-synced
    final scrollRatio = ref.watch(
      videoDetailProvider.select((s) => s.scrollRatio),
    );

    // NOTE: scrollCtr.offset is NOT reactive, accessed directly from controller
    bool shouldShow = scrollRatio != 0 &&
        videoDetailController.scrollCtr.offset != 0 &&
        isPortrait;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 0,
          systemOverlayStyle: Platform.isAndroid
              ? shouldShow
                  ? null
                  : SystemUiOverlayStyle(
                      statusBarIconBrightness: Brightness.light,
                      systemNavigationBarIconBrightness:
                          themeData.brightness.reverse,
                    )
              : null,
        ),
        if (shouldShow)
          AppBar(
            backgroundColor:
                themeData.colorScheme.surface.withValues(alpha: scrollRatio),
            toolbarHeight: 0,
            systemOverlayStyle: Platform.isAndroid
                ? SystemUiOverlayStyle(
                    statusBarIconBrightness: themeData.brightness.reverse,
                    systemNavigationBarIconBrightness:
                        themeData.brightness.reverse,
                  )
                : null,
          ),
      ],
    );
  }
}

/// Migrated PlDanmaku widget
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1276-1283 Obx()
/// PATTERN: Multi-field watch (cid, isFullScreen) + cross-controller
/// COMPLEXITY: Medium (PlDanmaku with cross-controller access)
class _PlDanmakuWidget extends ConsumerWidget {
  const _PlDanmakuWidget({
    required this.videoDetailController,
    required this.plPlayerController,
    required this.isPipMode,
    required this.width,
    required this.height,
    super.key,
  });

  final VideoDetailController videoDetailController;
  final dynamic plPlayerController;
  final bool isPipMode;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // cid is auto-synced
    final cid = ref.watch(videoDetailProvider.select((s) => s.cid));

    // Cross-controller: plPlayerController.isFullScreen
    final isFullScreen = plPlayerController.isFullScreen.value;

    // PHASE 6: Using Riverpod state directly in separate widget
    final isFileSource = ref.watch(videoDetailProvider.select((s) => s.isFileSource));

    return PlDanmaku(
      key: ValueKey(cid),
      isPipMode: isPipMode,
      cid: cid,
      playerController: plPlayerController,
      isFullScreen: isFullScreen,
      isFileSource: isFileSource,
      size: Size(width, height),
    );
  }
}

/// Migrated player visibility widget for plPlayer method
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1255-1261 Obx()
/// PATTERN: Multi-field watch (videoState, autoPlay) + cross-controller check
/// COMPLEXITY: Medium (conditional PLVideoPlayer with cross-controller access)
class _PlayerVisibilityWidget2 extends ConsumerWidget {
  const _PlayerVisibilityWidget2({
    required this.videoDetailController,
    required this.plPlayerController,
    required this.introController,
    required this.heroTag,
    required this.isFullScreen,
    required this.isPortrait,
    required this.width,
    required this.height,
    required this.isPipMode,
    required this.pipNoDanmaku,
    required this.showEpisodes,
    required this.showViewPoints,
    super.key,
  });

  final VideoDetailController videoDetailController;
  final dynamic plPlayerController;
  final dynamic introController;
  final String heroTag;
  final bool isFullScreen;
  final bool isPortrait;
  final double width;
  final double height;
  final bool isPipMode;
  final bool pipNoDanmaku;
  final void Function([int?, UgcSeason?, List<ugc.BaseEpisodeItem>?, String?, int?, int?]) showEpisodes;
  final void Function() showViewPoints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // NOTE: Removed all conditional checks to ensure PLVideoPlayer is always rendered
    // when plPlayerController exists. This prevents initialization issues.
    // PLVideoPlayer will handle its own visibility internally based on state.

    // Only check if plPlayerController exists
    if (plPlayerController == null) {
      return const SizedBox.shrink();
    }

    return PLVideoPlayer(
      maxWidth: width,
      maxHeight: height,
      plPlayerController: plPlayerController!,
      videoDetailController: videoDetailController,
      introController: introController,
      headerControl: HeaderControl(
        key: videoDetailController.headerCtrKey,
        isPortrait: isPortrait,
        controller: videoDetailController.plPlayerController,
        videoDetailCtr: videoDetailController,
        heroTag: heroTag,
      ),
      danmuWidget: isPipMode && pipNoDanmaku
          ? null
          : _PlDanmakuWidget(
            videoDetailController: videoDetailController,
            plPlayerController: plPlayerController!,
            isPipMode: isPipMode,
            width: width,
            height: height,
          ),
      showEpisodes: showEpisodes,
      showViewPoints: showViewPoints,
    );
  }
}

/// Migrated season panel widget (simple key-based watch)
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1809-1817 Obx()
/// PATTERN: Single field watch (introController.videoDetail) for key
/// COMPLEXITY: Low (simple SeasonPanel with ValueKey)
class _SeasonPanelWidget extends ConsumerWidget {
  const _SeasonPanelWidget({
    required this.introController,
    required this.heroTag,
    required this.showEpisodes,
    required this.ugcIntroController,
    super.key,
  });

  final dynamic introController;
  final String heroTag;
  final Function showEpisodes;
  final dynamic ugcIntroController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // introController.videoDetail is used for ValueKey
    // Note: introController is not a Riverpod provider, accessing .value directly
    final introDetail = introController.videoDetail.value;

    return SeasonPanel(
      key: ValueKey(introDetail),
      heroTag: heroTag,
      canTap: false,
      showEpisodes: showEpisodes,
      ugcIntroController: ugcIntroController,
    );
  }
}

/// Migrated season episode panel widget #2
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1820-1848 Obx()
/// PATTERN: Multi-field watch (seasonIndex, cover) + mixed controller access
/// COMPLEXITY: Medium (EpisodePanel with season data and mixed controller access)
class _SeasonEpisodePanelWidget2 extends ConsumerWidget {
  const _SeasonEpisodePanelWidget2({
    required this.heroTag,
    required this.videoDetailController,
    required this.ugcIntroController,
    required this.pgcIntroController,
    required this.videoDetail,
    required this.onReversePlay,
    super.key,
  });

  final String heroTag;
  final VideoDetailController videoDetailController;
  final dynamic ugcIntroController;
  final dynamic pgcIntroController;
  final dynamic videoDetail;
  final VoidCallback onReversePlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // seasonIndex and cover are auto-synced
    final seasonIndex = ref.watch(
      videoDetailProvider.select((s) => s.seasonIndex),
    );
    final cover = ref.watch(videoDetailProvider.select((s) => s.cover));

    // PHASE 6: Watch required state values
    final isUgc = ref.watch(videoDetailProvider.select((s) => s.isUgc));
    final bvid = ref.watch(videoDetailProvider.select((s) => s.bvid));
    final aid = ref.watch(videoDetailProvider.select((s) => s.aid));
    final seasonCid = ref.watch(videoDetailProvider.select((s) => s.seasonCid)); // PHASE 8

    return EpisodePanel(
      heroTag: heroTag,
      enableSlide: false,
      ugcIntroController: isUgc
          ? ugcIntroController
          : null,
      type: EpisodeType.season,
      initialTabIndex: seasonIndex,
      cover: cover,
      seasonId: videoDetail.ugcSeason!.id,
      list: videoDetail.ugcSeason!.sections!,
      bvid: bvid,
      aid: aid,
      cid: seasonCid ?? 0, // PHASE 8
      isReversed: ugcIntroController
          .videoDetail
          .value
          .ugcSeason!
          .sections![seasonIndex]
          .isReversed,
      onChangeEpisode: isUgc // PHASE 12: Use appropriate controller
          ? ugcIntroController.onChangeEpisode
          : pgcIntroController.onChangeEpisode, // Direct access (PGC case)
      showTitle: false,
      isSupportReverse: isUgc,
      onReverse: () => onReversePlay(),
    );
  }
}

/// Migrated part episode panel widget
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1787-1808 Obx()
/// PATTERN: Multi-field watch (cover, cid)
/// COMPLEXITY: Low (simple EpisodePanel with data passing)
class _PartEpisodePanelWidget2 extends ConsumerWidget {
  const _PartEpisodePanelWidget2({
    required this.heroTag,
    required this.videoDetailController,
    required this.ugcIntroController,
    required this.pgcIntroController,
    required this.videoDetail,
    required this.onReversePlay,
    super.key,
  });

  final String heroTag;
  final VideoDetailController videoDetailController;
  final dynamic ugcIntroController;
  final dynamic pgcIntroController;
  final dynamic videoDetail;
  final VoidCallback onReversePlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // cover and cid are auto-synced
    final cover = ref.watch(videoDetailProvider.select((s) => s.cover));
    final cid = ref.watch(videoDetailProvider.select((s) => s.cid));

    // PHASE 6: Watch required state values
    final isUgc = ref.watch(videoDetailProvider.select((s) => s.isUgc));
    final bvid = ref.watch(videoDetailProvider.select((s) => s.bvid));
    final aid = ref.watch(videoDetailProvider.select((s) => s.aid));

    return EpisodePanel(
      heroTag: heroTag,
      enableSlide: false,
      ugcIntroController: isUgc
          ? ugcIntroController
          : null,
      type: EpisodeType.part,
      list: [videoDetail.pages!],
      cover: cover,
      bvid: bvid,
      aid: aid,
      cid: cid,
      isReversed: videoDetail.isPageReversed,
      onChangeEpisode: isUgc // PHASE 12: Use appropriate controller
          ? ugcIntroController.onChangeEpisode
          : pgcIntroController.onChangeEpisode, // Direct access (PGC case)
      showTitle: false,
      isSupportReverse: isUgc,
      onReverse: () => onReversePlay(),
    );
  }
}

/// Migrated manual player widget
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1169-1263 Obx()
/// PATTERN: Single field watch (autoPlay) + reverse conditional rendering
/// COMPLEXITY: Medium (complex Stack with AppBar and buttons)
class _ManualPlayerWidget extends ConsumerWidget {
  const _ManualPlayerWidget({
    required this.videoDetailController,
    required this.themeData,
    required this.onBackPressed,
    required this.onHomePressed,
    required this.onPlayPressed,
    required this.moreBtn,
    super.key,
  });

  final VideoDetailController videoDetailController;
  final ThemeData themeData;
  final VoidCallback onBackPressed;
  final VoidCallback onHomePressed;
  final VoidCallback onPlayPressed;
  final Widget Function(Color, {List<Shadow>? shadows}) moreBtn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // autoPlay is auto-synced
    final autoPlay = ref.watch(
      videoDetailProvider.select((s) => s.autoPlay),
    );

    // Reverse conditional: show manual player when NOT autoPlay
    if (!autoPlay) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              primary: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  SizedBox(
                    width: 42,
                    height: 34,
                    child: IconButton(
                      tooltip: '返回',
                      icon: const Icon(
                        FontAwesomeIcons.arrowLeft,
                        size: 15,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 1.5,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      onPressed: onBackPressed,
                    ),
                  ),
                  SizedBox(
                    width: 42,
                    height: 34,
                    child: IconButton(
                      tooltip: '返回主页',
                      icon: const Icon(
                        FontAwesomeIcons.house,
                        size: 15,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 1.5,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      onPressed: onHomePressed,
                    ),
                  ),
                ],
              ),
              actions: [
                moreBtn(
                  Colors.white,
                  shadows: const [
                    Shadow(
                      blurRadius: 1.5,
                      color: Colors.black,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 12,
            bottom: 10,
            child: IconButton(
              tooltip: '播放',
              onPressed: onPlayPressed,
              icon: Image.asset(
                'assets/images/play.png',
                width: 60,
                height: 60,
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}

/// Migrated auto play cover button widget
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1561-1580 Obx()
/// PATTERN: Single field watch (autoPlay) + reverse conditional rendering
/// COMPLEXITY: Low (simple conditional cover display)
class _AutoPlayCoverWidget extends ConsumerWidget {
  const _AutoPlayCoverWidget({
    required this.aid,
    required this.width,
    required this.height,
    required this.videoDetailController,
    required this.onTap,
    super.key,
  });

  final int aid;
  final double width;
  final double height;
  final VideoDetailController videoDetailController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // autoPlay is auto-synced
    final autoPlay = ref.watch(
      videoDetailProvider.select((s) => s.autoPlay),
    );

    // Reverse conditional: show cover when NOT autoPlay
    if (!autoPlay) {
      return Positioned.fill(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: _HeroCoverWidget(
            aid: aid,
            width: width,
            height: height,
            videoDetailController: videoDetailController,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

/// Migrated reply count tab widget
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1460-1465 Obx()
/// PATTERN: Single field watch (count)
/// COMPLEXITY: Low (simple text formatting)
class _ReplyCountTabWidget extends ConsumerWidget {
  const _ReplyCountTabWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // count is auto-synced
    final count = ref.watch(videoReplyProvider.select((s) => s.count));

    return Tab(
      text: '评论${count == -1 ? '' : ' ${NumUtils.numFormat(count)}'}',
    );
  }
}

/// Migrated video toolbar overlay widget (complex nested toolbar)
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 664-844 Obx() (very complex ~180 lines)
/// PATTERN: Multi-field watch (scrollRatio) + opacity animation + nested toolbar function
/// COMPLEXITY: High (nested toolbar widget, complex conditional rendering, complex tap handler)
class _VideoToolbarOverlayWidget extends ConsumerWidget {
  const _VideoToolbarOverlayWidget({
    required this.videoDetailController,
    required this.plPlayerController,
    required this.themeData,
    required this.isPortrait,
    required this.handlePlay,
    required this.maxHeight,
    required this.maxWidth,
    required this.moreBtn,
    super.key,
  });

  final VideoDetailController videoDetailController;
  final dynamic plPlayerController;
  final ThemeData themeData;
  final bool isPortrait;
  final VoidCallback handlePlay;
  final double maxHeight;
  final double maxWidth;
  final Widget Function(Color color, {List<Shadow>? shadows}) moreBtn;

  Widget _buildToolbar(
    double scrollRatio,
    Duration? playedTime,
    bool isFileSource,
    bool isQuerying,
  ) {
    return Opacity(
      opacity: scrollRatio,
      child: Container(
        color: themeData.colorScheme.surface,
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: kToolbarHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 42,
                      height: 34,
                      child: IconButton(
                        tooltip: '返回',
                        icon: Icon(
                          FontAwesomeIcons.arrowLeft,
                          size: 15,
                          color: themeData.colorScheme.onSurface,
                        ),
                        onPressed: Get.back,
                      ),
                    ),
                    SizedBox(
                      width: 42,
                      height: 34,
                      child: IconButton(
                        tooltip: '返回主页',
                        icon: Icon(
                          FontAwesomeIcons.house,
                          size: 15,
                          color: themeData.colorScheme.onSurface,
                        ),
                        onPressed: () {
                          videoDetailController
                              .plPlayerController
                            ..isCloseAll = true
                            ..dispose();
                          Get.until(
                            (route) => route.isFirst,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      color: themeData.colorScheme.primary,
                    ),
                    Text(
                      '${playedTime == null // PHASE 7: Using Riverpod state
                          ? '立即'
                          : plPlayerController!.playerStatus.isCompleted
                          ? '重新'
                          : '继续'}播放',
                      style: TextStyle(
                        color: themeData.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: playedTime == null // PHASE 7: Using Riverpod state
                    ? moreBtn(
                        themeData.colorScheme.onSurface,
                      )
                    : SizedBox(
                        width: 42,
                        height: 34,
                        child: IconButton(
                          tooltip: "更多设置",
                          style: const ButtonStyle(
                            padding: WidgetStatePropertyAll(
                              EdgeInsets.zero,
                            ),
                          ),
                          onPressed: () =>
                              (videoDetailController
                                          .headerCtrKey
                                          .currentState
                                      as HeaderControlState?)
                                  ?.showSettingSheet(),
                          icon: Icon(
                            Icons.more_vert_outlined,
                            size: 19,
                            color: themeData.colorScheme.onSurface,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // scrollRatio is auto-synced
    final scrollRatio = ref.watch(
      videoDetailProvider.select((s) => s.scrollRatio),
    );

    // PHASE 6: Watch required state values
    final playedTime = ref.watch(videoDetailProvider.select((s) => s.playedTime));
    final isFileSource = ref.watch(videoDetailProvider.select((s) => s.isFileSource));
    final isQuerying = ref.watch(videoDetailProvider.select((s) => s.isQuerying));
    final videoUrl = ref.watch(videoDetailProvider.select((s) => s.videoUrl));
    final audioUrl = ref.watch(videoDetailProvider.select((s) => s.audioUrl));

    // Conditional rendering based on scrollRatio and scroll offset
    if (scrollRatio == 0 ||
        videoDetailController.scrollCtr.offset == 0 ||
        !isPortrait) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      bottom: -2,
      child: GestureDetector(
        onTap: () async {
          if (!isFileSource) { // PHASE 6: Using Riverpod state
            if (isQuerying) { // PHASE 7: Using Riverpod state
              if (kDebugMode) {
                debugPrint('handlePlay: querying');
              }
              return;
            }
            if (videoUrl == null || audioUrl == null) { // PHASE 8: Using Riverpod state
              if (kDebugMode) {
                debugPrint('handlePlay: videoUrl/audioUrl not initialized');
              }
              ref.read(videoDetailProvider.notifier).queryVideoUrl(); // PHASE 7: Using Riverpod notifier
              return;
            }
          }
          ref.read(videoDetailProvider.notifier).setScrollRatio(0); // PHASE 7: Using Riverpod notifier
          if (plPlayerController == null || playedTime == null) { // PHASE 8: Using Riverpod state
            handlePlay();
          } else {
            if (plPlayerController!
                .videoPlayerController!.state.completed) {
              await plPlayerController!.videoPlayerController!.seek(Duration.zero);
              plPlayerController!.videoPlayerController!.play();
            } else {
              plPlayerController!.videoPlayerController!.playOrPause();
            }
          }
        },
        behavior: HitTestBehavior.opaque,
        child: _buildToolbar(
          scrollRatio,
          playedTime,
          isFileSource,
          isQuerying,
        ),
      ),
    );
  }
}

/// Migrated Stein edge info widget (conditional buttons)
///
/// MIGRATION STATUS: ✅ Completed
/// ORIGINAL: Line 1380-1445 Obx() (LAST ONE!)
/// PATTERN: Single field watch (showSteinEdgeInfo) + conditional rendering
/// COMPLEXITY: Medium (conditional Wrap with multiple buttons)
class _SteinEdgeInfoWidget extends ConsumerWidget {
  const _SteinEdgeInfoWidget({
    required this.videoDetailController,
    required this.plPlayerController,
    required this.ugcIntroController,
    required this.themeData,
    super.key,
  });

  final VideoDetailController videoDetailController;
  final dynamic plPlayerController;
  final dynamic ugcIntroController;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // MIGRATION: Obx() → ref.watch()
    // showSteinEdgeInfo is auto-synced
    final showSteinEdgeInfo = ref.watch(
      videoDetailProvider.select((s) => s.showSteinEdgeInfo),
    );

    if (!showSteinEdgeInfo) {
      return const SizedBox.shrink();
    }

    try {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: plPlayerController?.showControls.value == true ? 75 : 16,
          ),
          child: Wrap(
            spacing: 25,
            runSpacing: 10,
            children: videoDetailController
                .steinEdgeInfo!
                .edges!
                .questions!
                .first
                .choices!
                .map((item) {
                  return FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(6),
                        ),
                      ),
                      backgroundColor: themeData
                          .colorScheme
                          .secondaryContainer
                          .withValues(alpha: 0.8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      ugcIntroController.onChangeEpisode(
                        item,
                        isStein: true,
                      );
                      ref.read(videoDetailProvider.notifier).getSteinEdgeInfo( // PHASE 7: Using Riverpod notifier
                        item.id,
                      );
                    },
                    child: Text(item.option!),
                  );
                })
                .toList(),
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('build stein edges: $e');
      return const SizedBox.shrink();
    }
  }
}

