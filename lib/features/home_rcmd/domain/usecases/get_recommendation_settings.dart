import 'package:PiliPlus/features/home_rcmd/domain/repositories/recommendation_settings_repository.dart';

/// 获取推荐设置用例
class GetRecommendationSettingsUseCase {
  final RecommendationSettingsRepository _repository;

  const GetRecommendationSettingsUseCase(this._repository);

  /// 是否启用保存上次看到的位置
  bool get enableSaveLastData => _repository.getEnableSaveLastData();

  /// 是否使用App推荐API
  bool get useAppRcmd => _repository.getUseAppRcmd();

  /// 是否显示"上次看到这里"提示
  bool get showSavedRcmdTip => _repository.getShowSavedRcmdTip();
}
