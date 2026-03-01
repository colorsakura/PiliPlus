import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/http/video.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/source_type.dart';
import 'package:PiliPlus/models/common/video/video_decode_type.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:PiliPlus/models/download/bili_download_entry_info.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/models/video/video_stein_edgeinfo/data.dart';
import 'package:PiliPlus/plugin/pl_player/controller.dart';
import 'package:PiliPlus/plugin/pl_player/models/data_source.dart';
import 'package:PiliPlus/plugin/pl_player/models/heart_beat_type.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_status.dart';
import 'package:PiliPlus/utils/video_utils.dart';
import 'package:PiliPlus/utils/extension/iterable_ext.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:PiliPlus/http/init.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:PiliPlus/utils/toast_utils.dart';

import 'video_states.dart';

/// Video detail notifier - manages video playback state
class VideoDetailNotifier extends Notifier<VideoDetailState> {
  @override
  VideoDetailState build() {
    // Initialize with empty state - actual args will be set via setArgs
    return VideoDetailState.initial();
  }

  PlPlayerController get _plPlayerController => PlPlayerController.getInstance();

  /// Set the route arguments
  void setArgs(Map<String, dynamic> args, {bool isInit = false}) {
    final videoType = args['videoType'] as VideoType? ?? VideoType.ugc;
    final sourceType = args['sourceType'] as SourceType? ?? SourceType.normal;
    final isFileSource = sourceType == SourceType.file;

    void updateState() {
      state = VideoDetailState(
        args: args,
        bvid: args['bvid'] as String? ?? '',
        aid: args['aid'] as int? ?? 0,
        cid: args['cid'] as int? ?? 0,
        heroTag: args['heroTag'] as String? ?? '',
        videoType: videoType,
        isUgc: videoType == VideoType.ugc,
        sourceType: sourceType,
        isFileSource: isFileSource,
        entry: args['entry'] as BiliDownloadEntryInfo?,
        videoState: LoadingState.loading(),
        currentVideoQa: null,
        currentAudioQa: null,
        currentDecodeFormats: VideoDecodeFormatType.fromString(
          args['cacheDecode'] as String? ?? 'avc',
        ),
        autoPlay: args['autoPlay'] as bool? ?? false,
        data: null,
        firstVideo: null,
        cover: args['cover'] as String? ?? '',
        videoUrl: null,
        audioUrl: null,
        defaultST: null,
        playedTime: null,
        isVertical: false,
        mediaList: const [],
        subtitles: const [],
        vttSubtitlesIndex: -1,
      );

      if (isFileSource && args['entry'] != null) {
        _initFileSource(args['entry'] as BiliDownloadEntryInfo);
      }
    }

    // Delay state update if called during widget lifecycle
    if (isInit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        updateState();
      });
    } else {
      updateState();
    }
  }

  /// Initialize file source (downloaded video)
  void _initFileSource(BiliDownloadEntryInfo entry) {
    final firstVideo = VideoItem(
      quality: VideoQuality.fromCode(entry.preferedVideoQuality),
      width: entry.ep?.width ?? entry.pageData?.width ?? 1,
      height: entry.ep?.height ?? entry.pageData?.height ?? 1,
    );

    final data = PlayUrlModel(timeLength: entry.totalTimeMilli);

    state = state.copyWith(
      entry: entry,
      firstVideo: firstVideo,
      data: data,
    );
  }

  /// Query video URL from API
  Future<void> queryVideoUrl({Duration? defaultST}) async {
    if (state.isFileSource) {
      return;
    }

    final plPlayerController = _plPlayerController;

    // Set quality if not set
    if (plPlayerController.cacheVideoQa == null) {
      final isWiFi = await Utils.isWiFi; // Note: Utils needs to be imported
      plPlayerController
        ..cacheVideoQa = isWiFi
            ? Pref.defaultVideoQa
            : Pref.defaultVideoQaCellular
        ..cacheAudioQa = isWiFi
            ? Pref.defaultAudioQa
            : Pref.defaultAudioQaCellular;
    }

    final result = await VideoHttp.videoUrl(
      cid: state.cid,
      bvid: state.bvid,
      epid: state.args['epId'] as int?,
      seasonId: state.args['seasonId'] as int?,
      tryLook: plPlayerController.tryLook,
      videoType: state.videoType,
      language: null,
    );

    if (result case Success(:final response)) {
      final videoList = response.dash?.video ?? [];
      if (videoList.isEmpty) {
        ToastUtils.showToast('视频资源不存在');
        state = state.copyWith(
          autoPlay: false,
          videoState: const Error('视频资源不存在'),
        );
        return;
      }

      final curHighestVideoQa = videoList.first.quality.code;
      int targetVideoQa = curHighestVideoQa;

      if (response.acceptQuality?.isNotEmpty == true &&
          plPlayerController.cacheVideoQa! <= curHighestVideoQa) {
        targetVideoQa = response.acceptQuality!.findClosestTarget(
          (e) => e <= plPlayerController.cacheVideoQa!,
          (a, b) => a > b ? a : b,
        );
      }

      final currentVideoQa = VideoQuality.fromCode(targetVideoQa);
      final videosList = videoList
          .where((e) => e.quality.code == targetVideoQa)
          .toList();

      // Find best codec
      final supportFormats = response.supportFormats!;
      final supportDecodeFormats = supportFormats
          .firstWhere(
            (e) => e.quality == targetVideoQa,
            orElse: () => supportFormats.first,
          )
          .codecs!;

      var currentDecodeFormats = VideoDecodeFormatType.fromString(state.currentDecodeFormats.name);

      final firstVideo = videosList.firstWhere(
        (e) => currentDecodeFormats.codes.any(e.codecs!.startsWith),
        orElse: () => videosList.first,
      );

      final videoUrl = VideoUtils.getCdnUrl(firstVideo.playUrls);

      // Find best audio quality
      String? audioUrl;
      AudioQuality? currentAudioQa;
      final audioList = response.dash?.audio;
      if (audioList != null && audioList.isNotEmpty) {
        final audioIds = audioList.map((e) => e.id!).toList();
        int closestNumber = audioIds.findClosestTarget(
          (e) => e <= plPlayerController.cacheAudioQa,
          (a, b) => a > b ? a : b,
        );
        final firstAudio = audioList.firstWhere(
          (e) => e.id == closestNumber,
          orElse: () => audioList.first,
        );
        audioUrl = VideoUtils.getCdnUrl(firstAudio.playUrls, isAudio: true);
        if (firstAudio.id != null) {
          currentAudioQa = AudioQuality.fromCode(firstAudio.id!);
        }
      } else {
        audioUrl = '';
      }

      state = state.copyWith(
        data: response,
        defaultST: defaultST,
        currentVideoQa: currentVideoQa,
        currentAudioQa: currentAudioQa,
        currentDecodeFormats: currentDecodeFormats,
        firstVideo: firstVideo,
        videoUrl: videoUrl,
        audioUrl: audioUrl,
      );
    } else {
      state = state.copyWith(
        autoPlay: false,
        videoState: result,
      );
      result.toast();
    }
  }

  /// Update player (quality change)
  void updatePlayer() {
    final currentVideoQa = state.currentVideoQa;
    if (currentVideoQa == null) return;

    state = state.copyWith(autoPlay: true);
    playerInit();
  }

  /// Initialize player
  Future<void> playerInit({
    String? video,
    String? audio,
    Duration? seekToTime,
    Duration? duration,
    bool? autoplay,
    Volume? volume,
  }) async {
    final plPlayerController = _plPlayerController;

    await plPlayerController.setDataSource(
      state.isFileSource
          ? FileSource(
              dir: state.args['dirPath'] as String? ?? '',
              typeTag: state.entry?.typeTag ?? '',
              isMp4: state.entry?.mediaType == 1,
            )
          : NetworkSource(
              videoSource: video ?? state.videoUrl ?? '',
              audioSource: audio ?? state.audioUrl,
            ),
      seekTo: seekToTime ?? state.defaultST,
      duration: duration ??
          (state.data?.timeLength != null
              ? Duration(milliseconds: state.data!.timeLength!)
              : null),
      isVertical: state.isVertical,
      aid: state.aid,
      bvid: state.bvid,
      cid: state.cid,
      autoplay: autoplay ?? state.autoPlay,
      epid: state.isUgc ? null : state.args['epId'] as int?,
      seasonId: state.isUgc ? null : state.args['seasonId'] as int?,
      pgcType: state.isUgc ? null : state.args['pgcType'] as int?,
      videoType: state.videoType,
      onInit: () {
        if (state.videoState is! Success) {
          state = state.copyWith(videoState: const Success(null));
        }
      },
      width: state.firstVideo?.width,
      height: state.firstVideo?.height,
      volume: volume,
    );
  }

  /// Make heartbeat request
  void makeHeartBeat() {
    final plPlayerController = _plPlayerController;
    if (plPlayerController.enableHeart &&
        plPlayerController.playerStatus.value != PlayerStatus.completed &&
        state.playedTime != null) {
      try {
        plPlayerController.makeHeartBeat(
          state.data?.timeLength != null
              ? (state.data!.timeLength! - state.playedTime!.inMilliseconds).abs() <= 1000
                  ? -1
                  : state.playedTime!.inSeconds
              : state.playedTime!.inSeconds,
          type: HeartBeatType.completed,
          isManual: true,
          aid: state.aid,
          bvid: state.bvid,
          cid: state.cid,
          epid: state.isUgc ? null : state.args['epId'] as int?,
          seasonId: state.isUgc ? null : state.args['seasonId'] as int?,
          pgcType: state.isUgc ? null : state.args['pgcType'] as int?,
          videoType: state.videoType,
        );
      } catch (_) {}
    }
  }

  /// Update played time
  void updatePlayedTime(Duration position) {
    state = state.copyWith(playedTime: position);
  }

  /// Update scroll ratio
  void setScrollRatio(double ratio) {
    state = state.copyWith(scrollRatio: ratio);
  }

  /// Update cover
  void setCover(String cover) {
    state = state.copyWith(cover: cover);
  }

  /// Update is vertical
  void setIsVertical(bool value) {
    state = state.copyWith(isVertical: value);
  }

  /// Update expanding/collapsing states
  void setExpanding(bool value) {
    state = state.copyWith(isExpanding: value);
  }

  void setCollapsing(bool value) {
    state = state.copyWith(isCollapsing: value);
  }

  /// Update video height
  void setVideoHeight(double height) {
    state = state.copyWith(videoHeight: height);
  }

  /// Set video height bounds
  void setVideoHeightBounds({
    required double min,
    required double max,
  }) {
    state = state.copyWith(
      minVideoHeight: min,
      maxVideoHeight: max,
    );
  }

  /// Update is showing (controls visibility)
  void setIsShowing(bool value) {
    state = state.copyWith(isShowing: value);
  }

  /// Update season index
  void setSeasonIndex(int index) {
    state = state.copyWith(seasonIndex: index);
  }

  /// Update player status
  void setPlayerStatus(PlayerStatus? status) {
    state = state.copyWith(playerStatus: status);
  }

  /// Update isQuerying
  void setIsQuerying(bool value) {
    state = state.copyWith(isQuerying: value);
  }

  /// Update showVideoSheet
  void setShowVideoSheet(bool value) {
    state = state.copyWith(showVideoSheet: value);
  }

  /// Update autoPlay
  void setAutoPlay(bool value) {
    state = state.copyWith(autoPlay: value);
  }

  /// Update setSystemBrightness
  void setSetSystemBrightness(bool value) {
    state = state.copyWith(setSystemBrightness: value);
  }

  /// Update horizontalScreen
  void setHorizontalScreen(bool value) {
    state = state.copyWith(horizontalScreen: value);
  }

  /// Update imageview
  void setImageview(bool value) {
    state = state.copyWith(imageview: value);
  }

  /// Update showReply
  void setShowReply(bool value) {
    state = state.copyWith(showReply: value);
  }

  /// Update videoState
  void setVideoState(LoadingState videoState) {
    state = state.copyWith(videoState: videoState);
  }

  /// Update showSteinEdgeInfo
  void setShowSteinEdgeInfo(bool value) {
    state = state.copyWith(showSteinEdgeInfo: value);
  }

  /// Update seasonCid
  void setSeasonCid(int? cid) {
    state = state.copyWith(seasonCid: cid);
  }

  /// Update brightness
  void setBrightness(double? brightness) {
    state = state.copyWith(brightness: brightness);
  }

  /// Get stein edge info for interactive videos
  Future<void> getSteinEdgeInfo([int? edgeId]) async {
    state = state.copyWith(steinEdgeInfo: null);

    try {
      final res = await Request().get(
        '/x/stein/edgeinfo_v2',
        queryParameters: {
          'bvid': state.bvid,
          'graph_version': state.graphVersion?.toString(),
          'edge_id': edgeId?.toString(),
        },
      );

      if (res.data['code'] == 0) {
        state = state.copyWith(
          steinEdgeInfo: EdgeInfoData.fromJson(res.data['data']),
        );
      } else {
        if (kDebugMode) {
          debugPrint('getSteinEdgeInfo error: ${res.data['message']}');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('getSteinEdgeInfo: $e');
    }
  }

  /// Add item to sponsor block list
  ///
  /// NOTE: This method manages sponsor block segments (from BlockMixin).
  /// The full implementation requires additional state fields:
  /// - blockListener (StreamSubscription)
  /// - segmentProgressList (for UI progress bar)
  /// - listData (for AnimatedList items)
  /// - skipTimer (Timer for auto-removal)
  ///
  /// Currently delegated to VideoDetailController.getBlockMixin() due to
  /// tight coupling with GetxController lifecycle and complex state management.
  ///
  /// Future enhancement: Extract sponsor block logic into separate Riverpod provider.
  void onAddItem(Object item) {
    // Delegated to VideoDetailController's BlockMixin
    // TODO: Migrate when sponsor block state is fully implemented in VideoDetailState
  }

  /// Cancel sponsor block listener
  ///
  /// NOTE: This method cancels the position listener that checks for
  /// sponsor block segments during playback. Requires tracking of
  /// StreamSubscription state.
  ///
  /// Currently delegated to VideoDetailController.getBlockMixin().
  void cancelBlockListener() {
    // Delegated to VideoDetailController's BlockMixin
    // TODO: Migrate when sponsor block state is fully implemented in VideoDetailState
  }

  /// Show note list panel
  ///
  /// NOTE: This is a UI method that displays a bottom sheet.
  /// UI methods should remain in the widget layer, not in business logic.
  ///
  /// To call from widget: Use video_page.dart to show NoteListPage directly.
  void showNoteList(BuildContext context) {
    // UI method - should be called from widget layer
    // Kept for API compatibility
  }

  /// Show download panel
  ///
  /// NOTE: This is a UI method that displays a modal bottom sheet.
  /// UI methods should remain in the widget layer.
  ///
  /// To call from widget: Use video_page.dart to show DownloadPanel directly.
  Future<void> onDownload(BuildContext context) async {
    // UI method - should be called from widget layer
    // Kept for API compatibility
  }

  /// Show media list panel (选集/稍后再看)
  ///
  /// NOTE: This is a UI method that displays a bottom sheet with
  /// episode/media list. UI methods should remain in widget layer.
  ///
  /// To call from widget: Use video_page.dart to show MediaListPanel directly.
  void showMediaListPanel(BuildContext context) {
    // UI method - should be called from widget layer
    // Kept for API compatibility
  }

  /// Build sponsor block list item widget
  ///
  /// NOTE: This is a UI widget builder method. It returns a Widget
  /// and should be in the widget layer, not in business logic.
  ///
  /// To use: Create a separate widget component in video_page.dart.
  Widget buildItem(Object item, Animation<double> animation) {
    // UI widget builder - should be in widget layer
    // Kept for API compatibility
    return const SizedBox.shrink();
  }
}


/// Provider for video detail controller
final videoDetailProvider = NotifierProvider<VideoDetailNotifier, VideoDetailState>(
  VideoDetailNotifier.new,
);

/// Global player controller provider
final plPlayerControllerProvider = Provider<PlPlayerController>(
  (ref) => PlPlayerController.getInstance(),
);
