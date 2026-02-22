/// 推荐设置仓库接口
abstract interface class RecommendationSettingsRepository {
  /// 获取是否启用保存上次看到的位置
  bool getEnableSaveLastData();

  /// 获取是否使用App推荐API
  bool getUseAppRcmd();

  /// 获取是否显示"上次看到这里"提示
  bool getShowSavedRcmdTip();
}
