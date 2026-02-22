import 'package:PiliPlus/core/storage/storage_pref.dart';

/// 推荐设置本地数据源
class RecommendationSettingsLocalDataSource {
  /// 获取是否启用保存上次看到的位置
  bool getEnableSaveLastData() {
    return Pref.enableSaveLastData;
  }

  /// 获取是否使用App推荐API
  bool getUseAppRcmd() {
    return Pref.appRcmd;
  }

  /// 获取是否显示"上次看到这里"提示
  bool getShowSavedRcmdTip() {
    return Pref.savedRcmdTip;
  }
}
