import 'package:PiliPlus/core/storage/storage.dart';
import 'package:PiliPlus/core/storage/storage_key.dart';
import 'package:PiliPlus/core/storage/storage_pref.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';

abstract final class DanmakuOptions {
  static final Set<int> blockTypes = Pref.danmakuBlockType;
  static bool blockColorful = blockTypes.contains(6);

  static int danmakuWeight = Pref.danmakuWeight;
  static double danmakuFontScaleFS = Pref.danmakuFontScaleFS;
  static double danmakuFontScale = Pref.danmakuFontScale;
  static int danmakuFontWeight = Pref.danmakuFontWeight;
  static double danmakuShowArea = Pref.danmakuShowArea;
  static double danmakuDuration = Pref.danmakuDuration;
  static double danmakuStaticDuration = Pref.danmakuStaticDuration;
  static double danmakuStrokeWidth = Pref.danmakuStrokeWidth;
  static bool danmakuFixedV = Pref.danmakuFixedV;
  static bool danmakuStatic2Scroll = Pref.danmakuStatic2Scroll;
  static bool danmakuMassiveMode = Pref.danmakuMassiveMode;
  static double danmakuLineHeight = Pref.danmakuLineHeight;

  static bool get sameFontScale => danmakuFontScale == danmakuFontScaleFS;

  static DanmakuOption get({
    required bool notFullscreen,
    double speed = 1.0,
  }) {
    return DanmakuOption(
      fontSize: 15 * (notFullscreen ? danmakuFontScale : danmakuFontScaleFS),
      fontWeight: danmakuFontWeight,
      area: danmakuShowArea,
      duration: danmakuDuration / speed,
      staticDuration: danmakuStaticDuration / speed,
      hideBottom: blockTypes.contains(4),
      hideScroll: blockTypes.contains(2),
      hideTop: blockTypes.contains(5),
      hideSpecial: blockTypes.contains(7),
      strokeWidth: danmakuStrokeWidth,
      scrollFixedVelocity: danmakuFixedV,
      massiveMode: danmakuMassiveMode,
      static2Scroll: danmakuStatic2Scroll,
      safeArea: true,
      lineHeight: danmakuLineHeight,
    );
  }

  static Future<void>? save(double danmakuOpacity) {
    GStorage.settingRepository.setStringList(SettingBoxKey.danmakuBlockType, blockTypes.toList());
    GStorage.settingRepository.setDouble(SettingBoxKey.danmakuShowArea, danmakuShowArea);
    GStorage.settingRepository.setDouble(SettingBoxKey.danmakuFontScale, danmakuFontScale);
    GStorage.settingRepository.setDouble(SettingBoxKey.danmakuFontScaleFS, danmakuFontScaleFS);
    GStorage.settingRepository.setDouble(SettingBoxKey.danmakuDuration, danmakuDuration);
    GStorage.settingRepository.setDouble(SettingBoxKey.danmakuStaticDuration, danmakuStaticDuration);
    GStorage.settingRepository.setDouble(SettingBoxKey.danmakuStrokeWidth, danmakuStrokeWidth);
    GStorage.settingRepository.setInt(SettingBoxKey.danmakuFontWeight, danmakuFontWeight);
    GStorage.settingRepository.setDouble(SettingBoxKey.danmakuLineHeight, danmakuLineHeight);
    GStorage.settingRepository.setBool(SettingBoxKey.danmakuMassiveMode, danmakuMassiveMode);
    GStorage.settingRepository.setBool(SettingBoxKey.danmakuStatic2Scroll, danmakuStatic2Scroll);
    GStorage.settingRepository.setBool(SettingBoxKey.danmakuFixedV, danmakuFixedV);
    GStorage.settingRepository.setInt(SettingBoxKey.danmakuWeight, danmakuWeight);
    GStorage.settingRepository.setDouble(SettingBoxKey.danmakuOpacity, danmakuOpacity);
    return null;
  }
}
