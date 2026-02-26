import 'package:PiliPlus/models/model_owner.dart';
import 'package:PiliPlus/models/video/video_detail/argue_info.dart';
import 'package:PiliPlus/models/video/video_detail/desc_v2.dart';
import 'package:PiliPlus/models/video/video_detail/dimension.dart';
import 'package:PiliPlus/models/video/video_detail/page.dart';
import 'package:PiliPlus/models/video/video_detail/rights.dart';
import 'package:PiliPlus/models/video/video_detail/staff.dart';
import 'package:PiliPlus/models/video/video_detail/stat.dart';
import 'package:PiliPlus/models/video/video_detail/subtitle.dart';
import 'package:PiliPlus/models/video/video_detail/ugc_season.dart';
import 'package:PiliPlus/models/video/video_detail/user_garb.dart';

/// 视频详情实体
///
/// 包含视频的所有详细信息
class VideoDetailEntity {
  String? bvid;
  int? aid;
  int? videos;
  int? tid;
  int? tidV2;
  String? tname;
  String? tnameV2;
  int? copyright;
  String? pic;
  String? title;
  int? pubdate;
  int? ctime;
  String? desc;
  List<DescV2>? descV2;
  int? state;
  int? duration;
  Rights? rights;
  Owner? owner;
  VideoStat? stat;
  ArgueInfo? argueInfo;
  String? dynam1c;
  int? cid;
  Dimension? dimension;
  int? seasonId;
  int? teenageMode;
  bool? isChargeableSeason;
  bool? isStory;
  bool? isUpowerExclusive;
  bool? isUpowerPlay;
  bool? isUpowerPreview;
  int? enableVt;
  String? vtDisplay;
  bool? isUpowerExclusiveWithQa;
  bool? noCache;
  List<Part>? pages;
  Subtitle? subtitle;
  UgcSeason? ugcSeason;
  bool? isSeasonDisplay;
  UserGarb? userGarb;
  String? likeIcon;
  bool? needJumpBv;
  bool? disableShowUpInfo;
  int? isStoryPlay;
  bool? isViewSelf;
  List<Staff>? staff;
  String? redirectUrl;
  bool isPageReversed;

  VideoDetailEntity({
    this.bvid,
    this.aid,
    this.videos,
    this.tid,
    this.tidV2,
    this.tname,
    this.tnameV2,
    this.copyright,
    this.pic,
    this.title,
    this.pubdate,
    this.ctime,
    this.desc,
    this.descV2,
    this.state,
    this.duration,
    this.rights,
    this.owner,
    this.stat,
    this.argueInfo,
    this.dynam1c,
    this.cid,
    this.dimension,
    this.seasonId,
    this.teenageMode,
    this.isChargeableSeason,
    this.isStory,
    this.isUpowerExclusive,
    this.isUpowerPlay,
    this.isUpowerPreview,
    this.enableVt,
    this.vtDisplay,
    this.isUpowerExclusiveWithQa,
    this.noCache,
    this.pages,
    this.subtitle,
    this.ugcSeason,
    this.isSeasonDisplay,
    this.userGarb,
    this.likeIcon,
    this.needJumpBv,
    this.disableShowUpInfo,
    this.isStoryPlay,
    this.isViewSelf,
    this.staff,
    this.redirectUrl,
    this.isPageReversed = false,
  });

  /// 从Map创建实体
  factory VideoDetailEntity.fromMap(Map<String, dynamic> map) {
    return VideoDetailEntity(
      bvid: map['bvid'] as String?,
      aid: map['aid'] as int?,
      videos: map['videos'] as int?,
      tid: map['tid'] as int?,
      tidV2: map['tid_v2'] as int?,
      tname: map['tname'] as String?,
      tnameV2: map['tname_v2'] as String?,
      copyright: map['copyright'] as int?,
      pic: map['pic'] as String?,
      title: map['title'] as String?,
      pubdate: map['pubdate'] as int?,
      ctime: map['ctime'] as int?,
      desc: map['desc'] as String?,
      state: map['state'] as int?,
      duration: map['duration'] as int?,
      cid: map['cid'] as int?,
      seasonId: map['season_id'] as int?,
      teenageMode: map['teenage_mode'] as int?,
      isChargeableSeason: map['is_chargeable_season'] as bool?,
      isStory: map['is_story'] as bool?,
      isUpowerExclusive: map['is_upower_exclusive'] as bool?,
      isUpowerPlay: map['is_upower_play'] as bool?,
      isUpowerPreview: map['is_upower_preview'] as bool?,
      enableVt: map['enable_vt'] as int?,
      vtDisplay: map['vt_display'] as String?,
      isUpowerExclusiveWithQa: map['is_upower_exclusive_with_qa'] as bool?,
      noCache: map['no_cache'] as bool?,
      isSeasonDisplay: map['is_season_display'] as bool?,
      likeIcon: map['like_icon'] as String?,
      needJumpBv: map['need_jump_bv'] as bool?,
      disableShowUpInfo: map['disable_show_up_info'] as bool?,
      isStoryPlay: map['is_story_play'] as int?,
      isViewSelf: map['is_view_self'] as bool?,
      redirectUrl: map['redirect_url'] as String?,
      isPageReversed: map['is_page_reversed'] as bool? ?? false,
    );
  }

  VideoDetailEntity copyWith({
    String? bvid,
    int? aid,
    int? videos,
    int? tid,
    int? tidV2,
    String? tname,
    String? tnameV2,
    int? copyright,
    String? pic,
    String? title,
    int? pubdate,
    int? ctime,
    String? desc,
    List<DescV2>? descV2,
    int? state,
    int? duration,
    Rights? rights,
    Owner? owner,
    VideoStat? stat,
    ArgueInfo? argueInfo,
    String? dynam1c,
    int? cid,
    Dimension? dimension,
    int? seasonId,
    int? teenageMode,
    bool? isChargeableSeason,
    bool? isStory,
    bool? isUpowerExclusive,
    bool? isUpowerPlay,
    bool? isUpowerPreview,
    int? enableVt,
    String? vtDisplay,
    bool? isUpowerExclusiveWithQa,
    bool? noCache,
    List<Part>? pages,
    Subtitle? subtitle,
    UgcSeason? ugcSeason,
    bool? isSeasonDisplay,
    UserGarb? userGarb,
    String? likeIcon,
    bool? needJumpBv,
    bool? disableShowUpInfo,
    int? isStoryPlay,
    bool? isViewSelf,
    List<Staff>? staff,
    String? redirectUrl,
    bool? isPageReversed,
  }) {
    return VideoDetailEntity(
      bvid: bvid ?? this.bvid,
      aid: aid ?? this.aid,
      videos: videos ?? this.videos,
      tid: tid ?? this.tid,
      tidV2: tidV2 ?? this.tidV2,
      tname: tname ?? this.tname,
      tnameV2: tnameV2 ?? this.tnameV2,
      copyright: copyright ?? this.copyright,
      pic: pic ?? this.pic,
      title: title ?? this.title,
      pubdate: pubdate ?? this.pubdate,
      ctime: ctime ?? this.ctime,
      desc: desc ?? this.desc,
      descV2: descV2 ?? this.descV2,
      state: state ?? this.state,
      duration: duration ?? this.duration,
      rights: rights ?? this.rights,
      owner: owner ?? this.owner,
      stat: stat ?? this.stat,
      argueInfo: argueInfo ?? this.argueInfo,
      dynam1c: dynam1c ?? this.dynam1c,
      cid: cid ?? this.cid,
      dimension: dimension ?? this.dimension,
      seasonId: seasonId ?? this.seasonId,
      teenageMode: teenageMode ?? this.teenageMode,
      isChargeableSeason: isChargeableSeason ?? this.isChargeableSeason,
      isStory: isStory ?? this.isStory,
      isUpowerExclusive: isUpowerExclusive ?? this.isUpowerExclusive,
      isUpowerPlay: isUpowerPlay ?? this.isUpowerPlay,
      isUpowerPreview: isUpowerPreview ?? this.isUpowerPreview,
      enableVt: enableVt ?? this.enableVt,
      vtDisplay: vtDisplay ?? this.vtDisplay,
      isUpowerExclusiveWithQa: isUpowerExclusiveWithQa ?? this.isUpowerExclusiveWithQa,
      noCache: noCache ?? this.noCache,
      pages: pages ?? this.pages,
      subtitle: subtitle ?? this.subtitle,
      ugcSeason: ugcSeason ?? this.ugcSeason,
      isSeasonDisplay: isSeasonDisplay ?? this.isSeasonDisplay,
      userGarb: userGarb ?? this.userGarb,
      likeIcon: likeIcon ?? this.likeIcon,
      needJumpBv: needJumpBv ?? this.needJumpBv,
      disableShowUpInfo: disableShowUpInfo ?? this.disableShowUpInfo,
      isStoryPlay: isStoryPlay ?? this.isStoryPlay,
      isViewSelf: isViewSelf ?? this.isViewSelf,
      staff: staff ?? this.staff,
      redirectUrl: redirectUrl ?? this.redirectUrl,
      isPageReversed: isPageReversed ?? this.isPageReversed,
    );
  }
}
