import 'package:PiliPlus/features/home_rcmd/data/datasources/recommendation_settings_local_datasource.dart';
import 'package:PiliPlus/features/home_rcmd/domain/repositories/recommendation_settings_repository.dart';

/// 推荐设置仓库实现
class RecommendationSettingsRepositoryImpl
    implements RecommendationSettingsRepository {
  final RecommendationSettingsLocalDataSource _localDataSource;

  RecommendationSettingsRepositoryImpl({
    required RecommendationSettingsLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  bool getEnableSaveLastData() {
    return _localDataSource.getEnableSaveLastData();
  }

  @override
  bool getUseAppRcmd() {
    return _localDataSource.getUseAppRcmd();
  }

  @override
  bool getShowSavedRcmdTip() {
    return _localDataSource.getShowSavedRcmdTip();
  }
}
