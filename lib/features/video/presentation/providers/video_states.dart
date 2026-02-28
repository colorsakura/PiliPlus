import 'package:PiliPlus/grpc/bilibili/main/community/reply/v1.pb.dart'
    show SubjectControl;
import 'package:PiliPlus/grpc/bilibili/pagination.pb.dart'
    show FeedPaginationReply;
import 'package:PiliPlus/http/loading_state.dart';
import 'package:PiliPlus/models/common/reply/reply_sort_type.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/source_type.dart';
import 'package:PiliPlus/models/common/video/video_decode_type.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/common/video/video_type.dart';
import 'package:PiliPlus/models/download/bili_download_entry_info.dart';
import 'package:PiliPlus/models/media_list/media_list.dart';
import 'package:PiliPlus/models/video/play/url.dart';
import 'package:PiliPlus/models/video/video_play_info/subtitle.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_status.dart';
import 'package:fixnum/fixnum.dart';

/// Video detail state - simplified for migration
class VideoDetailState {
  final Map<String, dynamic> args;
  final String bvid;
  final int aid;
  final int cid;
  final String heroTag;
  final VideoType videoType;
  final bool isUgc;
  final SourceType sourceType;
  final bool isFileSource;
  final BiliDownloadEntryInfo? entry;
  final LoadingState videoState;
  final VideoQuality? currentVideoQa;
  final AudioQuality? currentAudioQa;
  final VideoDecodeFormatType currentDecodeFormats;
  final bool autoPlay;
  final PlayUrlModel? data;
  final VideoItem? firstVideo;
  final String cover;
  final String? videoUrl;
  final String? audioUrl;
  final Duration? defaultST;
  final Duration? playedTime;
  final bool isVertical;
  final List<MediaListItemModel> mediaList;
  final List<Subtitle> subtitles;
  final int vttSubtitlesIndex;

  // Scroll and layout state
  final double scrollRatio;
  final bool isExpanding;
  final bool isCollapsing;
  final double videoHeight;
  final double minVideoHeight;
  final double maxVideoHeight;

  // UI state
  final bool isShowing;
  final bool showReply;
  final bool isQuerying;
  final bool showVideoSheet;
  final bool setSystemBrightness;
  final bool horizontalScreen;
  final bool imageview;
  final int seasonIndex;
  final PlayerStatus? playerStatus;
  final bool showSteinEdgeInfo;

  // Stein edge info for interactive videos
  final int? graphVersion;
  final dynamic steinEdgeInfo;

  // Additional tracking state
  final int? seasonCid; // PHASE 8: Track current season episode CID
  final double? brightness; // PHASE 8: Screen brightness value

  const VideoDetailState({
    required this.args,
    required this.bvid,
    required this.aid,
    required this.cid,
    required this.heroTag,
    required this.videoType,
    required this.isUgc,
    required this.sourceType,
    required this.isFileSource,
    this.entry,
    required this.videoState,
    this.currentVideoQa,
    this.currentAudioQa,
    required this.currentDecodeFormats,
    required this.autoPlay,
    this.data,
    this.firstVideo,
    this.cover = '',
    this.videoUrl,
    this.audioUrl,
    this.defaultST,
    this.playedTime,
    required this.isVertical,
    required this.mediaList,
    required this.subtitles,
    required this.vttSubtitlesIndex,
    this.scrollRatio = 0.0,
    this.isExpanding = false,
    this.isCollapsing = false,
    this.videoHeight = 0.0,
    this.minVideoHeight = 0.0,
    this.maxVideoHeight = 0.0,
    this.isShowing = true,
    this.showReply = false,
    this.isQuerying = false,
    this.showVideoSheet = false,
    this.setSystemBrightness = false,
    this.horizontalScreen = false,
    this.imageview = false,
    this.seasonIndex = 0,
    this.playerStatus,
    this.showSteinEdgeInfo = false,
    this.graphVersion,
    this.steinEdgeInfo,
    this.seasonCid, // PHASE 8
    this.brightness, // PHASE 8
  });

  VideoDetailState.initial()
      : args = const {},
        bvid = '',
        aid = 0,
        cid = 0,
        heroTag = '',
        videoType = VideoType.ugc,
        isUgc = true,
        sourceType = SourceType.normal,
        isFileSource = false,
        entry = null,
        videoState = LoadingState.loading(),
        currentVideoQa = null,
        currentAudioQa = null,
        currentDecodeFormats = VideoDecodeFormatType.AVC,
        autoPlay = false,
        data = null,
        firstVideo = null,
        cover = '',
        videoUrl = null,
        audioUrl = null,
        defaultST = null,
        playedTime = null,
        isVertical = false,
        mediaList = const [],
        subtitles = const [],
        vttSubtitlesIndex = -1,
        scrollRatio = 0.0,
        isExpanding = false,
        isCollapsing = false,
        videoHeight = 0.0,
        minVideoHeight = 0.0,
        maxVideoHeight = 0.0,
        isShowing = true,
        showReply = false,
        isQuerying = false,
        showVideoSheet = false,
        setSystemBrightness = false,
        horizontalScreen = false,
        imageview = false,
        seasonIndex = 0,
        playerStatus = null,
        showSteinEdgeInfo = false,
        graphVersion = null,
        steinEdgeInfo = null,
        seasonCid = null, // PHASE 8
        brightness = null; // PHASE 8


  VideoDetailState copyWith({
    Map<String, dynamic>? args,
    String? bvid,
    int? aid,
    int? cid,
    String? heroTag,
    VideoType? videoType,
    bool? isUgc,
    SourceType? sourceType,
    bool? isFileSource,
    BiliDownloadEntryInfo? entry,
    LoadingState? videoState,
    VideoQuality? currentVideoQa,
    AudioQuality? currentAudioQa,
    VideoDecodeFormatType? currentDecodeFormats,
    bool? autoPlay,
    PlayUrlModel? data,
    VideoItem? firstVideo,
    String? cover,
    String? videoUrl,
    String? audioUrl,
    Duration? defaultST,
    Duration? playedTime,
    bool? isVertical,
    List<MediaListItemModel>? mediaList,
    List<Subtitle>? subtitles,
    int? vttSubtitlesIndex,
    double? scrollRatio,
    bool? isExpanding,
    bool? isCollapsing,
    double? videoHeight,
    double? minVideoHeight,
    double? maxVideoHeight,
    bool? isShowing,
    bool? showReply,
    bool? isQuerying,
    bool? showVideoSheet,
    bool? setSystemBrightness,
    bool? horizontalScreen,
    bool? imageview,
    int? seasonIndex,
    PlayerStatus? playerStatus,
    bool? showSteinEdgeInfo,
    int? graphVersion,
    dynamic steinEdgeInfo,
    int? seasonCid, // PHASE 8
    double? brightness, // PHASE 8
  }) {
    return VideoDetailState(
      args: args ?? this.args,
      bvid: bvid ?? this.bvid,
      aid: aid ?? this.aid,
      cid: cid ?? this.cid,
      heroTag: heroTag ?? this.heroTag,
      videoType: videoType ?? this.videoType,
      isUgc: isUgc ?? this.isUgc,
      sourceType: sourceType ?? this.sourceType,
      isFileSource: isFileSource ?? this.isFileSource,
      entry: entry ?? this.entry,
      videoState: videoState ?? this.videoState,
      currentVideoQa: currentVideoQa ?? this.currentVideoQa,
      currentAudioQa: currentAudioQa ?? this.currentAudioQa,
      currentDecodeFormats: currentDecodeFormats ?? this.currentDecodeFormats,
      autoPlay: autoPlay ?? this.autoPlay,
      data: data ?? this.data,
      firstVideo: firstVideo ?? this.firstVideo,
      cover: cover ?? this.cover,
      videoUrl: videoUrl ?? this.videoUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      defaultST: defaultST ?? this.defaultST,
      playedTime: playedTime ?? this.playedTime,
      isVertical: isVertical ?? this.isVertical,
      mediaList: mediaList ?? this.mediaList,
      subtitles: subtitles ?? this.subtitles,
      vttSubtitlesIndex: vttSubtitlesIndex ?? this.vttSubtitlesIndex,
      scrollRatio: scrollRatio ?? this.scrollRatio,
      isExpanding: isExpanding ?? this.isExpanding,
      isCollapsing: isCollapsing ?? this.isCollapsing,
      videoHeight: videoHeight ?? this.videoHeight,
      minVideoHeight: minVideoHeight ?? this.minVideoHeight,
      maxVideoHeight: maxVideoHeight ?? this.maxVideoHeight,
      isShowing: isShowing ?? this.isShowing,
      showReply: showReply ?? this.showReply,
      isQuerying: isQuerying ?? this.isQuerying,
      showVideoSheet: showVideoSheet ?? this.showVideoSheet,
      setSystemBrightness: setSystemBrightness ?? this.setSystemBrightness,
      horizontalScreen: horizontalScreen ?? this.horizontalScreen,
      imageview: imageview ?? this.imageview,
      seasonIndex: seasonIndex ?? this.seasonIndex,
      playerStatus: playerStatus ?? this.playerStatus,
      showSteinEdgeInfo: showSteinEdgeInfo ?? this.showSteinEdgeInfo,
      graphVersion: graphVersion ?? this.graphVersion,
      steinEdgeInfo: steinEdgeInfo ?? this.steinEdgeInfo,
      seasonCid: seasonCid ?? this.seasonCid, // PHASE 8
      brightness: brightness ?? this.brightness, // PHASE 8
    );
  }
}

/// Video reply state
class VideoReplyState {
  /// Loading state
  final LoadingState loadingState;

  /// Comment count
  final int count;

  /// Sort type
  final ReplySortType sortType;

  /// Is FAB visible
  final bool isFabVisible;

  /// Has UP top comment
  final bool hasUpTop;

  /// Subject control (input restrictions)
  final SubjectControl? subjectControl;

  /// UP mid
  final int? upMid;

  /// Cursor for pagination
  final Int64? cursorNext;

  /// Pagination reply
  final FeedPaginationReply? paginationReply;

  /// Is loading
  final bool isLoading;

  /// Is end of list
  final bool isEnd;

  /// Error message
  final String? errorMessage;

  /// Route arguments
  final Map<String, dynamic> args;

  const VideoReplyState({
    required this.loadingState,
    required this.count,
    required this.sortType,
    required this.isFabVisible,
    required this.hasUpTop,
    this.subjectControl,
    this.upMid,
    this.cursorNext,
    this.paginationReply,
    required this.isLoading,
    required this.isEnd,
    this.errorMessage,
    required this.args,
  });

  /// Initial state factory
  factory VideoReplyState.initial() => VideoReplyState(
        loadingState: LoadingState.loading(),
        count: -1,
        sortType: ReplySortType.time,
        isFabVisible: true,
        hasUpTop: false,
        subjectControl: null,
        upMid: null,
        cursorNext: null,
        paginationReply: null,
        isLoading: false,
        isEnd: false,
        errorMessage: null,
        args: const {},
      );

  /// CopyWith method
  VideoReplyState copyWith({
    LoadingState? loadingState,
    int? count,
    ReplySortType? sortType,
    bool? isFabVisible,
    bool? hasUpTop,
    SubjectControl? subjectControl,
    int? upMid,
    Int64? cursorNext,
    FeedPaginationReply? paginationReply,
    bool? isLoading,
    bool? isEnd,
    String? errorMessage,
    Map<String, dynamic>? args,
  }) {
    return VideoReplyState(
      loadingState: loadingState ?? this.loadingState,
      count: count ?? this.count,
      sortType: sortType ?? this.sortType,
      isFabVisible: isFabVisible ?? this.isFabVisible,
      hasUpTop: hasUpTop ?? this.hasUpTop,
      subjectControl: subjectControl ?? this.subjectControl,
      upMid: upMid ?? this.upMid,
      cursorNext: cursorNext ?? this.cursorNext,
      paginationReply: paginationReply ?? this.paginationReply,
      isLoading: isLoading ?? this.isLoading,
      isEnd: isEnd ?? this.isEnd,
      errorMessage: errorMessage ?? this.errorMessage,
      args: args ?? this.args,
    );
  }
}
