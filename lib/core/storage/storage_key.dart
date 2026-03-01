// ignore_for_file: constant_identifier_names

library;

/// Storage key constants
///
/// This file maintains backward compatibility by re-exporting all keys from the domain layer.
/// New code should import from 'package:PiliPlus/core/storage/domain/keys/' instead.

// Re-export all domain keys for forward compatibility
export 'domain/keys/setting/video_setting_keys.dart';
export 'domain/keys/setting/danmaku_setting_keys.dart';
export 'domain/keys/setting/subtitle_setting_keys.dart';
export 'domain/keys/setting/ui_setting_keys.dart';
export 'domain/keys/setting/desktop_setting_keys.dart';
export 'domain/keys/setting/webdav_setting_keys.dart';
export 'domain/keys/setting/sponsor_block_setting_keys.dart';
export 'domain/keys/setting/proxy_setting_keys.dart';
export 'domain/keys/local_cache_keys.dart';
export 'domain/keys/video_keys.dart';

// Backward compatibility: aggregate all setting keys into SettingBoxKey
// This maintains the original API where all keys were in one class
abstract final class SettingBoxKey {
  // Video settings
  static const String btmProgressBehavior = 'btmProgressBehavior',
      defaultVideoQa = 'defaultVideoQa',
      defaultVideoQaCellular = 'defaultVideoQaCellular',
      defaultAudioQa = 'defaultAudioQa',
      defaultAudioQaCellular = 'defaultAudioQaCellular',
      autoPlayEnable = 'autoPlayEnable',
      fullScreenMode = 'fullScreenMode',
      defaultDecode = 'defaultDecode',
      secondDecode = 'secondDecode',
      defaultToastOp = 'defaultToastOp',
      defaultPicQa = 'defaultPicQa',
      enableHA = 'enableHA',
      audioOutput = 'audioOutput',
      expandBuffer = 'expandBuffer',
      hardwareDecoding = 'hardwareDecoding',
      videoSync = 'videoSync',
      autosync = 'autosync',
      p1080 = 'p1080',
      enableAutoEnter = 'enableAutoEnter',
      enableAutoExit = 'enableAutoExit',
      enableOnlineTotal = 'enableOnlineTotal',
      superChatType = 'superChatType',
      keyboardControl = 'keyboardControl',
      pauseOnMinimize = 'pauseOnMinimize',
      pgcSkipType = 'pgcSkipType',
      audioPlayMode = 'audioPlayMode',
      showBatteryLevel = 'showBatteryLevel';

  // UI settings
  static const String enableVerticalExpand = 'enableVerticalExpand',
      feedBackEnable = 'feedBackEnable',
      enableLongShowControl = 'enableLongShowControl',
      allowRotateScreen = 'allowRotateScreen',
      horizontalScreen = 'horizontalScreen',
      CDNService = 'CDNService',
      disableAudioCDN = 'disableAudioCDN',
      autoPiP = 'autoPiP',
      enableAutoLongPressSpeed = 'enableAutoLongPressSpeed',
      useRelativeSlide = 'useRelativeSlide',
      sliderDuration = 'sliderOffset',
      enableQuickDouble = 'enableQuickDouble',
      fullScreenGestureReverse = 'fullScreenGestureReverse',
      enableBackgroundPlay = 'enableBackgroundPlay',
      continuePlayInBackground = 'continuePlayInBackground',
      appRcmd = 'appRcmd',
      enableSaveLastData = 'enableSaveLastData',
      minDurationForRcmd = 'minDurationForRcmd',
      minPlayForRcmd = 'minPlayForRcmd',
      minLikeRatioForRecommend = 'minLikeRatioForRecommend',
      exemptFilterForFollowed = 'exemptFilterForFollowed',
      banWordForRecommend = 'banWordForRecommend',
      applyFilterToRelatedVideos = 'applyFilterToRelatedVideos',
      autoUpdate = 'autoUpdate',
      autoClearCache = 'autoClearCache',
      maxCacheSize = 'maxCacheSize',
      defaultShowComment = 'defaultShowComment',
      replySortType = 'replySortType',
      defaultDynamicType = 'defaultDynamicType',
      showDynInteraction = 'showDynInteraction',
      enableHotKey = 'enableHotKey',
      enableSearchRcmd = 'enableSearchRcmd',
      enableQuickFav = 'enableQuickFav',
      enableWordRe = 'enableWordRe',
      enableSearchWord = 'enableSearchWord',
      enableSystemProxy = 'enableSystemProxy',
      enableAi = 'enableAi',
      disableLikeMsg = 'disableLikeMsg',
      defaultHomePage = 'defaultHomePage',
      previewQuality = 'previewQuality',
      checkDynamic = 'checkDynamic',
      dynamicPeriod = 'dynamicPeriod',
      schemeVariant = 'schemeVariant',
      showViewPoints = 'showViewPoints',
      showRelatedVideo = 'showRelatedVideo',
      showVideoReply = 'showVideoReply',
      showBangumiReply = 'showBangumiReply',
      alwaysExpandIntroPanel = 'alwaysExapndIntroPanel',
      expandIntroPanelH = 'exapndIntroPanelH',
      horizontalSeasonPanel = 'horizontalSeasonPanel',
      horizontalMemberPage = 'horizontalMemberPage',
      replyLengthLimit = 'replyLengthLimit',
      showArgueMsg = 'showArgueMsg',
      reverseFromFirst = 'reverseFromFirst',
      badCertificateCallback = 'badCertificateCallback',
      continuePlayingPart = 'continuePlayingPart',
      cdnSpeedTest = 'cdnSpeedTest',
      horizontalPreview = 'horizontalPreview',
      banWordForReply = 'banWordForReply',
      banWordForZone = 'banWordForZone',
      savedRcmdTip = 'savedRcmdTip',
      openInBrowser = 'openInBrowser',
      refreshDragPercentage = 'refreshDragPercentage',
      refreshDisplacement = 'refreshDisplacement',
      showHotRcmd = 'showHotRcmd',
      audioNormalization = 'audioNormalization',
      fallbackNormalization = 'fallbackNormalization',
      superResolutionType = 'superResolutionType',
      preInitPlayer = 'preInitPlayer',
      searchSuggestion = 'searchSuggestion',
      showDynDecorate = 'showDynDecorate',
      enableLivePhoto = 'enableLivePhoto',
      showSeekPreview = 'showSeekPreview',
      showDmChart = 'showDmChart',
      enableCommAntifraud = 'enableCommAntifraud',
      biliSendCommAntifraud = 'biliSendCommAntifraud',
      enableCreateDynAntifraud = 'enableCreateDynAntifraud',
      coinWithLike = 'coinWithLike',
      isPureBlackTheme = 'isPureBlackTheme',
      antiGoodsDyn = 'antiGoodsDyn',
      antiGoodsReply = 'antiGoodsReply',
      expandDynLivePanel = 'expandDynLivePanel',
      springDescription = 'springDescription',
      enableHttp2 = 'enableHttp2',
      slideDismissReplyPage = 'slideDismissReplyPage',
      showFSActionItem = 'showFSActionItem',
      enableShrinkVideoSize = 'enableShrinkVideoSize',
      showDynActionBar = 'showDynActionBar',
      darkVideoPage = 'darkVideoPage',
      enableSlideVolumeBrightness = 'enableSlideVolumeBrightness',
      enableSlideFS = 'enableSlideFS',
      retryCount = 'retryCount',
      retryDelay = 'retryDelay',
      liveQuality = 'liveQuality',
      liveQualityCellular = 'liveQualityCellular',
      appFontWeight = 'appFontWeight',
      fastForBackwardDuration = 'fastForBackwardDuration',
      recordSearchHistory = 'recordSearchHistory',
      showPgcTimeline = 'showPgcTimeline',
      pageTransition = 'pageTransition',
      optTabletNav = 'optTabletNav',
      banWordForDyn = 'banWordForDyn',
      enableLog = 'enableLog',
      memberTab = 'memberTab',
      dynamicDetailRatio = 'dynamicDetailRatio',
      directExitOnBack = 'directExitOnBack',
      quickFavId = 'quickFavId',
      showFsScreenshotBtn = 'showFsScreenshotBtn',
      showFsLockBtn = 'showFsLockBtn',
      silentDownImg = 'silentDownImg',
      showMemberShop = 'showMemberShop',
      enablePlayAll = 'enablePlayAll',
      enableTapDm = 'enableTapDm',
      setSystemBrightness = 'setSystemBrightness',
      downloadPath = 'downloadPath',
      followOrderType = 'followOrderType',
      enableImgMenu = 'enableImgMenu',
      showDynDispute = 'showDynDispute',
      touchSlopH = 'touchSlopH';

  // Desktop settings
  static const String desktopVolume = 'desktopVolume',
      uiScale = 'uiScale',
      useSSD = 'useSSD';

  // Subtitle settings
  static const String subtitlePreferenceV2 = 'subtitlePreferenceV2',
      enableDragSubtitle = 'enableDragSubtitle',
      subtitlePaddingH = 'subtitlePaddingH',
      subtitlePaddingB = 'subtitlePaddingB',
      subtitleBgOpacity = 'subtitleBgOpaticy',
      subtitleStrokeWidth = 'subtitleStrokeWidth',
      subtitleFontScale = 'subtitleFontScale',
      subtitleFontScaleFS = 'subtitleFontScaleFS',
      subtitleFontWeight = 'subtitleFontWeight';

  // WebDAV settings
  static const String webdavUri = 'webdavUri',
      webdavUsername = 'webdavUsername',
      webdavPassword = 'webdavPassword',
      webdavDirectory = 'webdavDirectory';

  // SponsorBlock settings
  static const String enableSponsorBlock = 'enableSponsorBlock',
      blockSettings = 'blockSettings',
      blockLimit = 'blockLimit',
      blockColor = 'blockColor',
      blockUserID = 'blockUserID',
      blockToast = 'blockToast',
      blockServer = 'blockServer',
      blockTrack = 'blockTrack';

  // Danmaku settings
  static const String enableShowDanmaku = 'enableShowDanmaku',
      enableShowLiveDanmaku = 'enableShowLiveDanmaku',
      pipNoDanmaku = 'pipNoDanmaku',
      showVipDanmaku = 'showVipDanmaku',
      mergeDanmaku = 'mergeDanmaku',
      danmakuWeight = 'danmakuWeight',
      danmakuBlockType = 'danmakuBlockType',
      danmakuShowArea = 'danmakuShowArea',
      danmakuOpacity = 'danmakuOpacity',
      danmakuFontScale = 'danmakuFontScale',
      danmakuFontScaleFS = 'danmakuFontScaleFS',
      danmakuDuration = 'danmakuDuration',
      danmakuStaticDuration = 'danmakuStaticDuration',
      danmakuMassiveMode = 'danmakuMassiveMode',
      danmakuFixedV = 'danmakuFixedV',
      danmakuStatic2Scroll = 'danmakuStatic2Scroll',
      danmakuLineHeight = 'danmakuLineHeight',
      danmakuStrokeWidth = 'strokeWidth',
      danmakuFontWeight = 'fontWeight';

  // Proxy settings
  static const String systemProxyHost = 'systemProxyHost',
      systemProxyPort = 'systemProxyPort';

  // Theme and appearance settings
  static const String themeMode = 'themeMode',
      defaultTextScale = 'textScale',
      customColor = 'customColor',
      displayMode = 'displayMode',
      smallCardWidth = 'smallCardWidth',
      recommendCardWidth = 'recommendCardWidth',
      dynamicsWaterfallFlow = 'dynamicsWaterfallFlow',
      upPanelPosition = 'upPanelPosition',
      dynamicsShowAllFollowedUp = 'dynamicsShowAllFollowedUp',
      hideTopBar = 'hideSearchBar',
      hideBottomBar = 'hideTabBar',
      barHideType = 'barHideType',
      tabBarSort = 'tabBarSort',
      dynamicBadgeMode = 'dynamicBadgeMode',
      msgBadgeMode = 'msgBadgeMode',
      msgUnReadTypeV2 = 'msgUnReadTypeV2',
      navBarSort = 'navBarSort',
      tempPlayerConf = 'tempPlayerConf',
      reduceLuxColor = 'reduceLuxColor',
      liveCdnUrl = 'liveCdnUrl';
}

/// Backward compatibility: LocalCacheKeys class
abstract final class LocalCacheKey {
  static const String historyPause = 'historyPause',
      blackMids = 'blackMids',
      danmakuFilterRules = 'danmakuFilterRules',
      mixinKey = 'mixinKey',
      timeStamp = 'timeStamp',
      buvid = 'buvid';
}

/// Backward compatibility: VideoKeys class
abstract final class VideoBoxKey {
  static const String playRepeat = 'playRepeat',
      playSpeedDefault = 'playSpeedDefault',
      longPressSpeedDefault = 'longPressSpeedDefault',
      speedsList = 'speedsList',
      cacheVideoFit = 'cacheVideoFit';
}
