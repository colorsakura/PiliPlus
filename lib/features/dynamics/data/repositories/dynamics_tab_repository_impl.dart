import 'package:PiliPlus/features/dynamics/data/datasources/dynamics_local_datasource.dart';
import 'package:PiliPlus/features/dynamics/domain/entities/dynamics_tab.dart';
import 'package:PiliPlus/features/dynamics/domain/repositories/dynamics_tab_repository.dart';

/// Implementation of the dynamics tab repository.
class DynamicsTabRepositoryImpl implements DynamicsTabRepository {
  const DynamicsTabRepositoryImpl({
    required DynamicsLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final DynamicsLocalDataSource _localDataSource;

  @override
  DynamicsTabConfig getTabConfig() {
    return DynamicsTabConfig(
      defaultTabIndex: _localDataSource.getDefaultTabIndex(),
      showAllFollowedUp: _localDataSource.isShowAllFollowedUp(),
      upPanelPosition: _localDataSource.getUpPanelPosition(),
    );
  }

  @override
  int getDefaultTabIndex() {
    return _localDataSource.getDefaultTabIndex();
  }

  @override
  bool isShowAllFollowedUp() {
    return _localDataSource.isShowAllFollowedUp();
  }

  @override
  String getUpPanelPosition() {
    return _localDataSource.getUpPanelPosition();
  }
}
