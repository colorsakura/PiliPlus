import 'dart:convert';
import 'dart:io';
import 'dart:math' show pow, sqrt;

import 'package:PiliPlus/shared/widgets/pair.dart';
import 'package:PiliPlus/http/constants.dart';
import 'package:PiliPlus/models/common/bar_hide_type.dart';
import 'package:PiliPlus/models/common/dynamic/dynamic_badge_mode.dart';
import 'package:PiliPlus/models/common/dynamic/dynamics_type.dart';
import 'package:PiliPlus/models/common/dynamic/up_panel_position.dart';
import 'package:PiliPlus/models/common/follow_order_type.dart';
import 'package:PiliPlus/models/common/member/tab_type.dart';
import 'package:PiliPlus/models/common/msg/msg_unread_type.dart';
import 'package:PiliPlus/models/common/nav_bar_config.dart';
import 'package:PiliPlus/models/common/reply/reply_sort_type.dart';
import 'package:PiliPlus/models/common/sponsor_block/segment_type.dart';
import 'package:PiliPlus/models/common/sponsor_block/skip_type.dart';
import 'package:PiliPlus/models/common/super_chat_type.dart';
import 'package:PiliPlus/models/common/super_resolution_type.dart';
import 'package:PiliPlus/app/theme/entities/theme_type.dart';
import 'package:PiliPlus/models/common/video/audio_quality.dart';
import 'package:PiliPlus/models/common/video/cdn_type.dart';
import 'package:PiliPlus/models/common/video/live_quality.dart';
import 'package:PiliPlus/models/common/video/subtitle_pref_type.dart';
import 'package:PiliPlus/models/common/video/video_decode_type.dart';
import 'package:PiliPlus/models/common/video/video_quality.dart';
import 'package:PiliPlus/models/user/danmaku_rule.dart';
import 'package:PiliPlus/models/user/info.dart';
import 'package:PiliPlus/plugin/pl_player/models/audio_output_type.dart';
import 'package:PiliPlus/plugin/pl_player/models/bottom_progress_behavior.dart';
import 'package:PiliPlus/plugin/pl_player/models/fullscreen_mode.dart';
import 'package:PiliPlus/plugin/pl_player/models/hwdec_type.dart';
import 'package:PiliPlus/plugin/pl_player/models/play_repeat.dart';
import 'package:PiliPlus/utils/extension/context_ext.dart';
import 'package:PiliPlus/utils/global_data.dart';
import 'package:PiliPlus/utils/login_utils.dart';
import 'package:PiliPlus/utils/platform_utils.dart';
import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/utils/utils.dart';
import 'package:crypto/crypto.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart' show FlexSchemeVariant;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract final class Pref {
  static UserInfoData? get userInfoCache =>
      GStorage.userInfoRepository.get('userInfoCache');

  static List<double> get dynamicDetailRatio {
    final strList = GStorage.settingRepository.getStringList(
      SettingBoxKey.dynamicDetailRatio,
    );
    if (strList != null) {
      return List<double>.from(
        strList.map((e) => double.tryParse(e) ?? 0.0),
      );
    }
    return const [60.0, 40.0];
  }

  static Set<int> get blackMids {
    final strList = GStorage.localCacheRepository.getStringList(
      LocalCacheKey.blackMids,
    );
    if (strList != null) {
      return strList.map((e) => int.tryParse(e) ?? 0).toSet();
    }
    return <int>{};
  }

  static set blackMids(Set<int> blackMidsSet) {
    GStorage.localCacheRepository.setStringList(
      LocalCacheKey.blackMids,
      blackMidsSet.map((e) => e.toString()).toList(),
    );
  }

  static RuleFilter get danmakuFilterRule {
    final jsonStr = GStorage.localCacheRepository.getString(
      LocalCacheKey.danmakuFilterRules,
    );
    if (jsonStr != null) {
      try {
        return RuleFilter.fromJson(jsonDecode(jsonStr));
      } catch (_) {
        return RuleFilter.empty();
      }
    }
    return RuleFilter.empty();
  }

  static void setBlackMid(int mid) {
    final updatedSet = GlobalData().blackMids..add(mid);
    GStorage.localCacheRepository.setStringList(
      LocalCacheKey.blackMids,
      updatedSet.map((e) => e.toString()).toList(),
    );
  }

  static void removeBlackMid(int mid) {
    final updatedSet = GlobalData().blackMids..remove(mid);
    GStorage.localCacheRepository.setStringList(
      LocalCacheKey.blackMids,
      updatedSet.map((e) => e.toString()).toList(),
    );
  }

  static MemberTabType get memberTab =>
      MemberTabType.values[GStorage.settingRepository.getInt(
        SettingBoxKey.memberTab,
      ) ?? 0];

  static int get _themeTypeInt => GStorage.settingRepository.getInt(
    SettingBoxKey.themeMode,
  ) ?? ThemeType.system.index;

  static ThemeType get themeType => ThemeType.values[_themeTypeInt];

  static ThemeMode get themeMode => switch (_themeTypeInt) {
    0 => ThemeMode.light,
    1 => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  static List<double> get springDescription {
    final strList = GStorage.settingRepository.getStringList(
      SettingBoxKey.springDescription,
    );
    if (strList != null) {
      return List<double>.from(
        strList.map((e) => double.tryParse(e) ?? 0.0),
      );
    }
    return [0.5, 100.0, 2.2 * sqrt(50)]; // [mass, stiffness, damping]
  }

  static List<double> get speedList {
    final strList = GStorage.videoRepository.getStringList(
      VideoBoxKey.speedsList,
    );
    if (strList != null) {
      return List<double>.from(
        strList.map((e) => double.tryParse(e) ?? 0.0),
      );
    }
    return const [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 3.0];
  }

  static List<Pair<SegmentType, SkipType>> get blockSettings {
    final strList = GStorage.settingRepository.getStringList(
      SettingBoxKey.blockSettings,
    );
    if (strList == null || strList.length != SegmentType.values.length) {
      return SegmentType.values
          .map((i) => Pair(first: i, second: SkipType.skipOnce))
          .toList();
    }
    return SegmentType.values
        .map(
          (item) => Pair(
            first: item,
            second: SkipType.values[int.tryParse(strList[item.index]) ?? 0],
          ),
        )
        .toList();
  }

  static List<Color> get blockColor {
    final strList = GStorage.settingRepository.getStringList(
      SettingBoxKey.blockColor,
    );
    if (strList == null || strList.length != SegmentType.values.length) {
      return SegmentType.values.map((i) => i.color).toList();
    }
    return SegmentType.values.map(
      (item) {
        final String e = strList[item.index];
        final color = e.isNotEmpty ? int.tryParse('FF$e', radix: 16) : null;
        return color != null ? Color(color) : item.color;
      },
    ).toList();
  }

  static bool get feedBackEnable =>
      GStorage.settingRepository.getBool(SettingBoxKey.feedBackEnable) ?? false;

  static int get picQuality =>
      GStorage.settingRepository.getInt(SettingBoxKey.defaultPicQa) ?? 10;

  static DynamicBadgeMode get dynamicBadgeType =>
      DynamicBadgeMode.values[GStorage.settingRepository.getInt(
        SettingBoxKey.dynamicBadgeMode,
      ) ?? DynamicBadgeMode.number.index];

  static DynamicBadgeMode get msgBadgeMode =>
      DynamicBadgeMode.values[GStorage.settingRepository.getInt(
        SettingBoxKey.msgBadgeMode,
      ) ?? DynamicBadgeMode.number.index];

  static Set<MsgUnReadType> get msgUnReadTypeV2 {
    final strList = GStorage.settingRepository.getStringList(
      SettingBoxKey.msgUnReadTypeV2,
    );
    if (strList != null) {
      return strList
          .map((index) => MsgUnReadType.values[int.tryParse(index) ?? 0])
          .toSet();
    }
    return MsgUnReadType.values.toSet();
  }

  static NavigationBarType get defaultHomePage =>
      NavigationBarType.values[defaultHomePageIndex];

  static int get defaultHomePageIndex => GStorage.settingRepository.getInt(
    SettingBoxKey.defaultHomePage,
  ) ?? NavigationBarType.home.index;

  static int get previewQ =>
      GStorage.settingRepository.getInt(SettingBoxKey.previewQuality) ?? 100;

  static double get smallCardWidth =>
      GStorage.settingRepository.getDouble(SettingBoxKey.smallCardWidth) ?? 240.0;

  static double get recommendCardWidth =>
      GStorage.settingRepository.getDouble(SettingBoxKey.recommendCardWidth) ?? 240.0;

  static UpPanelPosition get upPanelPosition =>
      UpPanelPosition.values[GStorage.settingRepository.getInt(
        SettingBoxKey.upPanelPosition,
      ) ?? UpPanelPosition.leftFixed.index];

  static FullScreenMode get fullScreenMode =>
      FullScreenMode.values[GStorage.settingRepository.getInt(
        SettingBoxKey.fullScreenMode,
      ) ?? FullScreenMode.auto.index];

  static BtmProgressBehavior get btmProgressBehavior =>
      BtmProgressBehavior.values[GStorage.settingRepository.getInt(
        SettingBoxKey.btmProgressBehavior,
      ) ?? BtmProgressBehavior.alwaysShow.index];

  static SubtitlePrefType get subtitlePreferenceV2 =>
      SubtitlePrefType.values[GStorage.settingRepository.getInt(
        SettingBoxKey.subtitlePreferenceV2,
      ) ?? SubtitlePrefType.off.index];

  static bool get useRelativeSlide =>
      GStorage.settingRepository.getBool(SettingBoxKey.useRelativeSlide) ?? false;

  static int get sliderDuration =>
      GStorage.settingRepository.getInt(SettingBoxKey.sliderDuration) ?? 90;

  static int get defaultVideoQa => GStorage.settingRepository.getInt(
    SettingBoxKey.defaultVideoQa,
  ) ?? VideoQuality.super8k.code;

  static int get defaultVideoQaCellular => GStorage.settingRepository.getInt(
    SettingBoxKey.defaultVideoQaCellular,
  ) ?? VideoQuality.high1080.code;

  static int get defaultAudioQa => GStorage.settingRepository.getInt(
    SettingBoxKey.defaultAudioQa,
  ) ?? AudioQuality.hiRes.code;

  static int get defaultAudioQaCellular => GStorage.settingRepository.getInt(
    SettingBoxKey.defaultAudioQaCellular,
  ) ?? AudioQuality.k192.code;

  static String get defaultDecode => GStorage.settingRepository.getString(
    SettingBoxKey.defaultDecode,
  ) ?? VideoDecodeFormatType.AVC.codes.first;

  static String get secondDecode => GStorage.settingRepository.getString(
    SettingBoxKey.secondDecode,
  ) ?? VideoDecodeFormatType.AV1.codes.first;

  static String get hardwareDecoding => GStorage.settingRepository.getString(
    SettingBoxKey.hardwareDecoding,
  ) ?? (Platform.isAndroid
        ? HwDecType.autoSafe.hwdec
        : HwDecType.auto.hwdec);

  static String get videoSync =>
      GStorage.settingRepository.getString(SettingBoxKey.videoSync) ?? 'display-resample';

  static String get autosync => GStorage.settingRepository.getString(
    SettingBoxKey.autosync,
  ) ?? (Platform.isAndroid ? '30' : '0');

  static CDNService get defaultCDNService {
    final cdnName = GStorage.settingRepository.getString(SettingBoxKey.CDNService);
    if (cdnName != null) {
      return CDNService.values.byName(cdnName);
    }
    return CDNService.backupUrl;
  }

  static String get banWordForRecommend =>
      GStorage.settingRepository.getString(SettingBoxKey.banWordForRecommend) ?? '';

  static String get banWordForReply =>
      GStorage.settingRepository.getString(SettingBoxKey.banWordForReply) ?? '';

  static String get banWordForZone =>
      GStorage.settingRepository.getString(SettingBoxKey.banWordForZone) ?? '';

  static bool get appRcmd =>
      GStorage.settingRepository.getBool(SettingBoxKey.appRcmd) ?? true;

  static String get systemProxyHost =>
      GStorage.settingRepository.getString(SettingBoxKey.systemProxyHost) ?? '';

  static String get systemProxyPort =>
      GStorage.settingRepository.getString(SettingBoxKey.systemProxyPort) ?? '';

  static DynamicsTabType get defaultDynamicType =>
      DynamicsTabType.values[defaultDynamicTypeIndex];

  static int get defaultDynamicTypeIndex => GStorage.settingRepository.getInt(
    SettingBoxKey.defaultDynamicType,
  ) ?? DynamicsTabType.all.index;

  static bool get showDynInteraction =>
      GStorage.settingRepository.getBool(SettingBoxKey.showDynInteraction) ?? true;

  static double get blockLimit =>
      GStorage.settingRepository.getDouble(SettingBoxKey.blockLimit) ?? 0.0;

  static double get refreshDragPercentage =>
      GStorage.settingRepository.getDouble(SettingBoxKey.refreshDragPercentage) ?? 0.25;

  static double get refreshDisplacement => GStorage.settingRepository.getDouble(
    SettingBoxKey.refreshDisplacement,
  ) ?? (PlatformUtils.isMobile ? 20.0 : 40.0);

  static String get blockUserID {
    String? blockUserID = GStorage.settingRepository.getString(SettingBoxKey.blockUserID);
    if (blockUserID == null || blockUserID.isEmpty) {
      blockUserID = Digest(
        List.generate(16, (_) => Utils.random.nextInt(256)),
      ).toString();
      GStorage.settingRepository.setString(SettingBoxKey.blockUserID, blockUserID);
    }
    return blockUserID;
  }

  static bool get blockToast =>
      GStorage.settingRepository.getBool(SettingBoxKey.blockToast) ?? true;

  static String get blockServer => GStorage.settingRepository.getString(
    SettingBoxKey.blockServer,
  ) ?? HttpString.sponsorBlockBaseUrl;

  static bool get blockTrack =>
      GStorage.settingRepository.getBool(SettingBoxKey.blockTrack) ?? !kDebugMode;

  static bool get checkDynamic =>
      GStorage.settingRepository.getBool(SettingBoxKey.checkDynamic) ?? true;

  static int get dynamicPeriod =>
      GStorage.settingRepository.getInt(SettingBoxKey.dynamicPeriod) ?? 5;

  static FlexSchemeVariant get schemeVariant =>
      FlexSchemeVariant.values[GStorage.settingRepository.getInt(
        SettingBoxKey.schemeVariant,
      ) ?? FlexSchemeVariant.material3Legacy.index];

  static double get danmakuFontScaleFS => GStorage.settingRepository.getDouble(
    SettingBoxKey.danmakuFontScaleFS,
  ) ?? (PlatformUtils.isMobile ? 1.2 : 1.7);

  static bool get danmakuMassiveMode =>
      GStorage.settingRepository.getBool(SettingBoxKey.danmakuMassiveMode) ?? false;

  static bool get danmakuFixedV =>
      GStorage.settingRepository.getBool(SettingBoxKey.danmakuFixedV) ?? false;

  static bool get danmakuStatic2Scroll =>
      GStorage.settingRepository.getBool(SettingBoxKey.danmakuStatic2Scroll) ?? false;

  static double get subtitleFontScale =>
      GStorage.settingRepository.getDouble(SettingBoxKey.subtitleFontScale) ?? 1.0;

  static double get subtitleFontScaleFS =>
      GStorage.settingRepository.getDouble(SettingBoxKey.subtitleFontScaleFS) ?? 1.5;

  static bool get showViewPoints =>
      GStorage.settingRepository.getBool(SettingBoxKey.showViewPoints) ?? true;

  static bool get showRelatedVideo =>
      GStorage.settingRepository.getBool(SettingBoxKey.showRelatedVideo) ?? true;

  static bool get showVideoReply =>
      GStorage.settingRepository.getBool(SettingBoxKey.showVideoReply) ?? true;

  static bool get showBangumiReply =>
      GStorage.settingRepository.getBool(SettingBoxKey.showBangumiReply) ?? true;

  static bool get alwaysExpandIntroPanel =>
      GStorage.settingRepository.getBool(SettingBoxKey.alwaysExpandIntroPanel) ?? false;

  static bool get expandIntroPanelH =>
      GStorage.settingRepository.getBool(SettingBoxKey.expandIntroPanelH) ?? false;

  static bool get horizontalSeasonPanel => GStorage.settingRepository.getBool(
    SettingBoxKey.horizontalSeasonPanel,
  ) ?? PlatformUtils.isDesktop;

  static bool get horizontalMemberPage => GStorage.settingRepository.getBool(
    SettingBoxKey.horizontalMemberPage,
  ) ?? PlatformUtils.isDesktop;

  static int? get replyLengthLimit {
    int length = GStorage.settingRepository.getInt(SettingBoxKey.replyLengthLimit) ?? 6;
    if (length <= 0) {
      return null;
    }
    return length;
  }

  static int get defaultPicQa =>
      GStorage.settingRepository.getInt(SettingBoxKey.defaultPicQa) ?? 10;

  static double get danmakuLineHeight =>
      GStorage.settingRepository.getDouble(SettingBoxKey.danmakuLineHeight) ?? 1.6;

  static bool get showArgueMsg =>
      GStorage.settingRepository.getBool(SettingBoxKey.showArgueMsg) ?? true;

  static bool get reverseFromFirst =>
      GStorage.settingRepository.getBool(SettingBoxKey.reverseFromFirst) ?? true;

  static int get subtitlePaddingH =>
      GStorage.settingRepository.getInt(SettingBoxKey.subtitlePaddingH) ?? 24;

  static int get subtitlePaddingB =>
      GStorage.settingRepository.getInt(SettingBoxKey.subtitlePaddingB) ?? 24;

  static double get subtitleBgOpacity =>
      GStorage.settingRepository.getDouble(SettingBoxKey.subtitleBgOpacity) ?? 0.67;

  static double get subtitleStrokeWidth =>
      GStorage.settingRepository.getDouble(SettingBoxKey.subtitleStrokeWidth) ?? 2.0;

  static int get subtitleFontWeight =>
      GStorage.settingRepository.getInt(SettingBoxKey.subtitleFontWeight) ?? 5;

  static bool get badCertificateCallback =>
      GStorage.settingRepository.getBool(SettingBoxKey.badCertificateCallback) ?? false;

  static bool get continuePlayingPart =>
      GStorage.settingRepository.getBool(SettingBoxKey.continuePlayingPart) ?? true;

  static bool get cdnSpeedTest =>
      GStorage.settingRepository.getBool(SettingBoxKey.cdnSpeedTest) ?? true;

  static bool get autoUpdate =>
      GStorage.settingRepository.getBool(SettingBoxKey.autoUpdate) ?? true;

  static bool get horizontalPreview =>
      GStorage.settingRepository.getBool(SettingBoxKey.horizontalPreview) ?? false;

  static bool get openInBrowser =>
      GStorage.settingRepository.getBool(SettingBoxKey.openInBrowser) ?? false;

  static bool get savedRcmdTip =>
      GStorage.settingRepository.getBool(SettingBoxKey.savedRcmdTip) ?? true;

  static bool get showVipDanmaku =>
      GStorage.settingRepository.getBool(SettingBoxKey.showVipDanmaku) ?? true;

  static bool get mergeDanmaku =>
      GStorage.settingRepository.getBool(SettingBoxKey.mergeDanmaku) ?? false;

  static bool get showHotRcmd =>
      GStorage.settingRepository.getBool(SettingBoxKey.showHotRcmd) ?? false;

  static String get audioNormalization =>
      GStorage.settingRepository.getString(SettingBoxKey.audioNormalization) ?? '0';

  static String get fallbackNormalization =>
      GStorage.settingRepository.getString(SettingBoxKey.fallbackNormalization) ?? '0';

  static SuperResolutionType get superResolutionType {
    final index = GStorage.settingRepository.getInt(SettingBoxKey.superResolutionType);
    if (index != null) {
      final superResolutionType = SuperResolutionType.values.elementAtOrNull(index);
      if (superResolutionType != null) {
        return superResolutionType;
      }
    }
    return SuperResolutionType.disable;
  }

  static bool get preInitPlayer =>
      GStorage.settingRepository.getBool(SettingBoxKey.preInitPlayer) ?? false;

  static bool get searchSuggestion =>
      GStorage.settingRepository.getBool(SettingBoxKey.searchSuggestion) ?? true;

  static bool get showDynDecorate =>
      GStorage.settingRepository.getBool(SettingBoxKey.showDynDecorate) ?? true;

  static bool get enableLivePhoto =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableLivePhoto) ?? true;

  static bool get showSeekPreview =>
      GStorage.settingRepository.getBool(SettingBoxKey.showSeekPreview) ?? true;

  static bool get showDmChart =>
      GStorage.settingRepository.getBool(SettingBoxKey.showDmChart) ?? false;

  static bool get enableCommAntifraud =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableCommAntifraud) ?? false;

  static bool get biliSendCommAntifraud =>
      Platform.isAndroid &&
      (GStorage.settingRepository.getBool(SettingBoxKey.biliSendCommAntifraud) ?? false);

  static bool get enableCreateDynAntifraud =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableCreateDynAntifraud) ?? false;

  static bool get coinWithLike =>
      GStorage.settingRepository.getBool(SettingBoxKey.coinWithLike) ?? false;

  static bool get isPureBlackTheme =>
      GStorage.settingRepository.getBool(SettingBoxKey.isPureBlackTheme) ?? false;

  static bool get antiGoodsDyn =>
      GStorage.settingRepository.getBool(SettingBoxKey.antiGoodsDyn) ?? false;

  static bool get antiGoodsReply =>
      GStorage.settingRepository.getBool(SettingBoxKey.antiGoodsReply) ?? false;

  static bool get expandDynLivePanel =>
      GStorage.settingRepository.getBool(SettingBoxKey.expandDynLivePanel) ?? false;

  static bool get slideDismissReplyPage => GStorage.settingRepository.getBool(
    SettingBoxKey.slideDismissReplyPage,
  ) ?? Platform.isIOS;

  static bool get showFSActionItem =>
      GStorage.settingRepository.getBool(SettingBoxKey.showFSActionItem) ?? true;

  static bool get enableShrinkVideoSize =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableShrinkVideoSize) ?? true;

  static bool get showDynActionBar =>
      GStorage.settingRepository.getBool(SettingBoxKey.showDynActionBar) ?? true;

  static bool get darkVideoPage =>
      GStorage.settingRepository.getBool(SettingBoxKey.darkVideoPage) ?? false;

  static bool get enableSlideVolumeBrightness => GStorage.settingRepository.getBool(
    SettingBoxKey.enableSlideVolumeBrightness,
  ) ?? true;

  static bool get enableSlideFS =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableSlideFS) ?? true;

  static int get retryCount =>
      GStorage.settingRepository.getInt(SettingBoxKey.retryCount) ?? 2;

  static int get retryDelay =>
      GStorage.settingRepository.getInt(SettingBoxKey.retryDelay) ?? 500;

  static int get liveQuality => GStorage.settingRepository.getInt(
    SettingBoxKey.liveQuality,
  ) ?? LiveQuality.origin.code;

  static int get liveQualityCellular => GStorage.settingRepository.getInt(
    SettingBoxKey.liveQualityCellular,
  ) ?? LiveQuality.superHD.code;

  static int get appFontWeight =>
      GStorage.settingRepository.getInt(SettingBoxKey.appFontWeight) ?? -1;

  static bool get enableDragSubtitle =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableDragSubtitle) ?? false;

  static int get fastForBackwardDuration =>
      GStorage.settingRepository.getInt(SettingBoxKey.fastForBackwardDuration) ?? 10;

  static bool get recordSearchHistory =>
      GStorage.settingRepository.getBool(SettingBoxKey.recordSearchHistory) ?? true;

  static String get webdavUri =>
      GStorage.settingRepository.getString(SettingBoxKey.webdavUri) ?? '';

  static String get webdavUsername =>
      GStorage.settingRepository.getString(SettingBoxKey.webdavUsername) ?? '';

  static String get webdavPassword =>
      GStorage.settingRepository.getString(SettingBoxKey.webdavPassword) ?? '';

  static String get webdavDirectory =>
      GStorage.settingRepository.getString(SettingBoxKey.webdavDirectory) ?? '/';

  static bool get showPgcTimeline =>
      GStorage.settingRepository.getBool(SettingBoxKey.showPgcTimeline) ?? true;

  static num get maxCacheSize =>
      GStorage.settingRepository.getInt(SettingBoxKey.maxCacheSize) ?? pow(1024, 3).toInt();

  static bool get optTabletNav =>
      GStorage.settingRepository.getBool(SettingBoxKey.optTabletNav) ?? true;

  static bool get horizontalScreen =>
      GStorage.settingRepository.getBool(SettingBoxKey.horizontalScreen) ?? isTablet;

  static bool get isTablet {
    bool isTablet;
    if (Get.context != null) {
      isTablet = Get.context!.isTablet;
    } else {
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final screenSize = view.physicalSize / view.devicePixelRatio;
      isTablet = screenSize.shortestSide >= 600;
    }
    GStorage.settingRepository.setBool(SettingBoxKey.horizontalScreen, isTablet);
    return isTablet;
  }

  static String get banWordForDyn =>
      GStorage.settingRepository.getString(SettingBoxKey.banWordForDyn) ?? '';

  static bool get enableLog =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableLog) ?? true;

  static bool get disableAudioCDN =>
      GStorage.settingRepository.getBool(SettingBoxKey.disableAudioCDN) ?? false;

  static int get minDurationForRcmd =>
      GStorage.settingRepository.getInt(SettingBoxKey.minDurationForRcmd) ?? 0;

  static int get minPlayForRcmd =>
      GStorage.settingRepository.getInt(SettingBoxKey.minPlayForRcmd) ?? 0;

  static int get minLikeRatioForRecommend =>
      GStorage.settingRepository.getInt(SettingBoxKey.minLikeRatioForRecommend) ?? 0;

  static bool get exemptFilterForFollowed =>
      GStorage.settingRepository.getBool(SettingBoxKey.exemptFilterForFollowed) ?? true;

  static bool get applyFilterToRelatedVideos => GStorage.settingRepository.getBool(
    SettingBoxKey.applyFilterToRelatedVideos,
  ) ?? true;

  static bool get enableBackgroundPlay =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableBackgroundPlay) ?? true;

  static bool get allowRotateScreen =>
      GStorage.settingRepository.getBool(SettingBoxKey.allowRotateScreen) ?? true;

  static bool get disableLikeMsg =>
      GStorage.settingRepository.getBool(SettingBoxKey.disableLikeMsg) ?? false;

  static bool get enableWordRe =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableWordRe) ?? false;

  static bool get autoExitFullscreen =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableAutoExit) ?? true;

  static bool get autoPlayEnable =>
      GStorage.settingRepository.getBool(SettingBoxKey.autoPlayEnable) ?? false;

  static bool get pipNoDanmaku =>
      GStorage.settingRepository.getBool(SettingBoxKey.pipNoDanmaku) ?? false;

  static bool get enableVerticalExpand =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableVerticalExpand) ?? false;

  static double get defaultTextScale =>
      GStorage.settingRepository.getDouble(SettingBoxKey.defaultTextScale) ?? 1.0;

  static double get uiScale =>
      GStorage.settingRepository.getDouble(SettingBoxKey.uiScale) ?? 1.0;

  static bool get dynamicsWaterfallFlow =>
      GStorage.settingRepository.getBool(SettingBoxKey.dynamicsWaterfallFlow) ?? true;

  static bool get hideTopBar => GStorage.settingRepository.getBool(
    SettingBoxKey.hideTopBar,
  ) ?? PlatformUtils.isMobile;

  static bool get hideBottomBar => GStorage.settingRepository.getBool(
    SettingBoxKey.hideBottomBar,
  ) ?? PlatformUtils.isMobile;

  static BarHideType get barHideType =>
      BarHideType.values[GStorage.settingRepository.getInt(
        SettingBoxKey.barHideType,
      ) ?? BarHideType.sync.index];

  static bool get enableSearchWord =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableSearchWord) ?? false;

  static bool get dynamicsShowAllFollowedUp => GStorage.settingRepository.getBool(
    SettingBoxKey.dynamicsShowAllFollowedUp,
  ) ?? false;

  static bool get enableShowDanmaku =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableShowDanmaku) ?? true;

  static bool get enableShowLiveDanmaku =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableShowLiveDanmaku) ?? true;

  static bool get enableQuickFav =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableQuickFav) ?? false;

  static bool get p1080 =>
      GStorage.settingRepository.getBool(SettingBoxKey.p1080) ?? true;

  static int get customColor =>
      GStorage.settingRepository.getInt(SettingBoxKey.customColor) ?? 0;

  static bool get autoClearCache =>
      GStorage.settingRepository.getBool(SettingBoxKey.autoClearCache) ?? false;

  static bool get enableSystemProxy =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableSystemProxy) ?? false;

  static bool get enableHttp2 =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableHttp2) ?? false;

  static ReplySortType get replySortType =>
      ReplySortType.values[GStorage.settingRepository.getInt(
        SettingBoxKey.replySortType,
      ) ?? ReplySortType.hot.index];

  static DynamicBadgeMode get dynamicBadgeMode =>
      DynamicBadgeMode.values[GStorage.settingRepository.getInt(
        SettingBoxKey.dynamicBadgeMode,
      ) ?? DynamicBadgeMode.number.index];

  static Transition get pageTransition =>
      Transition.values[GStorage.settingRepository.getInt(
        SettingBoxKey.pageTransition,
      ) ?? Transition.native.index];

  static bool get enableQuickDouble =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableQuickDouble) ?? true;

  static bool get fullScreenGestureReverse =>
      GStorage.settingRepository.getBool(SettingBoxKey.fullScreenGestureReverse) ?? false;

  static bool get autoPiP =>
      GStorage.settingRepository.getBool(SettingBoxKey.autoPiP) ?? false;

  static bool get enableSponsorBlock =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableSponsorBlock) ?? false;

  static bool get enableHA =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableHA) ?? true;

  static Set<int> get danmakuBlockType {
    final strList = GStorage.settingRepository.getStringList(
      SettingBoxKey.danmakuBlockType,
    );
    if (strList != null) {
      return strList.map((e) => int.tryParse(e) ?? 0).toSet();
    }
    return <int>{};
  }

  static int get danmakuWeight =>
      GStorage.settingRepository.getInt(SettingBoxKey.danmakuWeight) ?? 0;

  static double get danmakuShowArea =>
      GStorage.settingRepository.getDouble(SettingBoxKey.danmakuShowArea) ?? 0.5;

  static double get danmakuOpacity =>
      GStorage.settingRepository.getDouble(SettingBoxKey.danmakuOpacity) ?? 1.0;

  static double get danmakuFontScale => GStorage.settingRepository.getDouble(
    SettingBoxKey.danmakuFontScale,
  ) ?? (PlatformUtils.isMobile ? 1.0 : 1.4);

  static double get danmakuDuration =>
      GStorage.settingRepository.getDouble(SettingBoxKey.danmakuDuration) ?? 7.0;

  static double get danmakuStaticDuration =>
      GStorage.settingRepository.getDouble(SettingBoxKey.danmakuStaticDuration) ?? 4.0;

  static double get danmakuStrokeWidth => GStorage.settingRepository.getDouble(
    SettingBoxKey.danmakuStrokeWidth,
  ) ?? (PlatformUtils.isMobile ? 1.5 : 2.5);

  static int get danmakuFontWeight => GStorage.settingRepository.getInt(
    SettingBoxKey.danmakuFontWeight,
  ) ?? (PlatformUtils.isMobile ? 5 : 6);

  static bool get enableLongShowControl =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableLongShowControl) ?? false;

  static bool get expandBuffer =>
      GStorage.settingRepository.getBool(SettingBoxKey.expandBuffer) ?? false;

  static String get audioOutput => GStorage.settingRepository.getString(
    SettingBoxKey.audioOutput,
  ) ?? AudioOutput.defaultValue;

  static bool get enableAi =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableAi) ?? false;

  static bool get enableOnlineTotal =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableOnlineTotal) ?? false;

  static bool get enableAutoEnter =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableAutoEnter) ?? false;

  static bool get enableAutoLongPressSpeed =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableAutoLongPressSpeed) ?? false;

  static double get playSpeedDefault =>
      GStorage.videoRepository.getDouble(VideoBoxKey.playSpeedDefault) ?? 1.0;

  static double get longPressSpeedDefault =>
      GStorage.videoRepository.getDouble(VideoBoxKey.longPressSpeedDefault) ?? 3.0;

  static bool get defaultShowComment =>
      GStorage.settingRepository.getBool(SettingBoxKey.defaultShowComment) ?? false;

  static bool get enableTrending =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableHotKey) ?? true;

  static bool get enableSearchRcmd =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableSearchRcmd) ?? true;

  static bool get enableSaveLastData =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableSaveLastData) ?? true;

  static double get defaultToastOp =>
      GStorage.settingRepository.getDouble(SettingBoxKey.defaultToastOp) ?? 1.0;

  static PlayRepeat get playRepeat =>
      PlayRepeat.values[GStorage.videoRepository.getInt(
        VideoBoxKey.playRepeat,
      ) ?? PlayRepeat.pause.index];

  static int get cacheVideoFit =>
      GStorage.videoRepository.getInt(VideoBoxKey.cacheVideoFit) ?? 1;

  static bool get continuePlayInBackground =>
      GStorage.settingRepository.getBool(SettingBoxKey.continuePlayInBackground) ?? false;

  static bool get directExitOnBack =>
      GStorage.settingRepository.getBool(SettingBoxKey.directExitOnBack) ?? false;

  static bool get historyPause =>
      GStorage.localCacheRepository.getBool(LocalCacheKey.historyPause) ?? false;

  static int? get quickFavId => GStorage.settingRepository.getInt(SettingBoxKey.quickFavId);

  static bool get tempPlayerConf =>
      GStorage.settingRepository.getBool(SettingBoxKey.tempPlayerConf) ?? false;

  static Color? get reduceLuxColor {
    final color = GStorage.settingRepository.getInt(SettingBoxKey.reduceLuxColor);
    if (color != null && color != 0xFFFFFFFF) {
      return Color(color);
    }
    return null;
  }

  static bool get showFsScreenshotBtn =>
      GStorage.settingRepository.getBool(SettingBoxKey.showFsScreenshotBtn) ?? true;

  static bool get showFsLockBtn =>
      GStorage.settingRepository.getBool(SettingBoxKey.showFsLockBtn) ?? true;

  static bool get silentDownImg =>
      GStorage.settingRepository.getBool(SettingBoxKey.silentDownImg) ?? false;

  static String get buvid {
    String? buvid = GStorage.localCacheRepository.getString(LocalCacheKey.buvid);
    if (buvid == null) {
      buvid = LoginUtils.generateBuvid();
      GStorage.localCacheRepository.setString(LocalCacheKey.buvid, buvid);
    }
    return buvid;
  }

  static bool get showMemberShop =>
      GStorage.settingRepository.getBool(SettingBoxKey.showMemberShop) ?? false;

  static SuperChatType get superChatType =>
      SuperChatType.values[GStorage.settingRepository.getInt(
        SettingBoxKey.superChatType,
      ) ?? SuperChatType.valid.index];

  static bool get keyboardControl =>
      GStorage.settingRepository.getBool(SettingBoxKey.keyboardControl) ?? true;

  static bool get useSSD =>
      GStorage.settingRepository.getBool(SettingBoxKey.useSSD) ?? false;

  static double get desktopVolume =>
      GStorage.settingRepository.getDouble(SettingBoxKey.desktopVolume) ?? 1.0;

  static SkipType get pgcSkipType {
    final index = GStorage.settingRepository.getInt(SettingBoxKey.pgcSkipType);
    return SkipType.values[index ?? SkipType.skipOnce.index];
  }

  static PlayRepeat get audioPlayMode {
    final index = GStorage.settingRepository.getInt(SettingBoxKey.audioPlayMode);
    return PlayRepeat.values[index ?? PlayRepeat.listOrder.index];
  }

  static bool get enablePlayAll =>
      GStorage.settingRepository.getBool(SettingBoxKey.enablePlayAll) ?? true;

  static bool get enableTapDm =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableTapDm) ?? true;

  static bool get setSystemBrightness =>
      GStorage.settingRepository.getBool(SettingBoxKey.setSystemBrightness) ?? false;

  static String? get downloadPath => GStorage.settingRepository.getString(SettingBoxKey.downloadPath);

  static String? get liveCdnUrl => GStorage.settingRepository.getString(SettingBoxKey.liveCdnUrl);

  static bool get showBatteryLevel => GStorage.settingRepository.getBool(
    SettingBoxKey.showBatteryLevel,
  ) ?? PlatformUtils.isMobile;

  static FollowOrderType get followOrderType =>
      FollowOrderType.values[GStorage.settingRepository.getInt(
        SettingBoxKey.followOrderType,
      ) ?? FollowOrderType.def.index];

  static bool get enableImgMenu =>
      GStorage.settingRepository.getBool(SettingBoxKey.enableImgMenu) ?? false;

  static bool get showDynDispute =>
      GStorage.settingRepository.getBool(SettingBoxKey.showDynDispute) ?? false;

  static double get touchSlopH =>
      GStorage.settingRepository.getDouble(SettingBoxKey.touchSlopH) ?? 24.0;
}
